From: Ian McDonald <imcdnzl@gmail.com>
Date: Fri, 16 Dec 2005 04:01:12 +0000
Subject: [RFC] Move DCCP to buffers for transmitting
Message-Id: <cbec11ac0512152001q23fc0921jad5a920126bc8a4a@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Folks,

I'm trying to change DCCP transmission to use buffers like TCP rather
than current mechanism.

This code is not yet quite ready as have kernel asserts as per below:
Dec 16 16:50:59 localhost kernel: KERNEL: assertion
(skb_queue_empty(&sk->sk_write_queue)) failed at net/core/stream.c
(277)
Dec 16 16:50:59 localhost kernel: KERNEL: assertion
(!sk->sk_wmem_queued) failed at net/core/stream.c (282)
Dec 16 16:50:59 localhost kernel: KERNEL: assertion
(!sk->sk_forward_alloc) failed at net/core/stream.c (283)
Dec 16 16:50:59 localhost kernel: KERNEL: assertion
(!sk->sk_wmem_queued) failed at net/ipv4/af_inet.c (147)
Dec 16 16:50:59 localhost kernel: KERNEL: assertion
(!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (148)

I thought I would get it out there for discussion as I am finishing
for weekend now probably and wouldn't mind feedback on general
principle of my code. This is against davem's net-2.6.16 as of a day
or so ago. Code still needs tidying up as well in style a little....

Ian
--
Ian McDonald
http://wand.net.nz/~iam4
WAND Network Research Group
University of Waikato
New Zealand

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
diff --git a/include/net/sock.h b/include/net/sock.h
index 91d2895..49bd617 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1053,6 +1053,23 @@ static inline void sk_charge_skb(struct
 	sk->sk_forward_alloc -= skb->truesize;
 }

+static inline void skb_entail(struct sock *sk, struct sk_buff *skb)
+{
+	skb->csum = 0;
+	skb_header_release(skb);
+	__skb_queue_tail(&sk->sk_write_queue, skb);
+	sk_charge_skb(sk, skb);
+	if (!sk->sk_send_head)
+		sk->sk_send_head = skb;
+}
+
+static inline void skb_update_send_head(struct sock *sk, struct sk_buff *skb)
+{
+	sk->sk_send_head = skb->next;
+	if (sk->sk_send_head = (struct sk_buff *)&sk->sk_write_queue)
+		sk->sk_send_head = NULL;
+}
+
 static inline int skb_copy_to_page(struct sock *sk, char __user *from,
 				   struct sk_buff *skb, struct page *page,
 				   int off, int copy)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 93f26dd..3ecc417 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -126,7 +126,7 @@ extern void dccp_send_delayed_ack(struct
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);

-extern int dccp_write_xmit(struct sock *sk, struct sk_buff *skb, long *timeo);
+extern void dccp_write_xmit(struct sock *sk);
 extern void dccp_write_space(struct sock *sk);

 extern void dccp_init_xmit_timers(struct sock *sk);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 95a3c2c..1618106 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -26,12 +26,14 @@ static inline void dccp_event_ack_sent(s
 	inet_csk_clear_xmit_timer(sk, ICSK_TIME_DACK);
 }

+#if 0
 static inline void dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
 {
 	skb_set_owner_w(skb, sk);
 	WARN_ON(sk->sk_send_head);
 	sk->sk_send_head = skb;
 }
+#endif

 /*
  * All SKB's seen here are completely headerless. It is our
@@ -226,37 +228,47 @@ do_interrupted:
 	goto out;
 }

-int dccp_write_xmit(struct sock *sk, struct sk_buff *skb, long *timeo)
+void dccp_write_xmit(struct sock *sk)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
-	int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
+	struct sk_buff *skb;
+	long timeo = 2000; /* fixme iancrap - 2 second default */
+
+	while ((skb = sk->sk_send_head)) {
+		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
 					 skb->len);

-	if (err > 0)
-		err = dccp_wait_for_ccid(sk, skb, timeo);
+		if (err > 0)
+			err = dccp_wait_for_ccid(sk, skb, &timeo);

-	if (err = 0) {
-		struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-		const int len = skb->len;
-
-		if (sk->sk_state = DCCP_PARTOPEN) {
-			/* See 8.1.5.  Handshake Completion */
-			inet_csk_schedule_ack(sk);
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
+		if (err = 0) {
+			struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+			const int len = skb->len;
+
+			if (sk->sk_state = DCCP_PARTOPEN) {
+				/* See 8.1.5.  Handshake Completion */
+				inet_csk_schedule_ack(sk);
+				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
 						  inet_csk(sk)->icsk_rto,
 						  DCCP_RTO_MAX);
-			dcb->dccpd_type = DCCP_PKT_DATAACK;
-		} else if (dccp_ack_pending(sk))
-			dcb->dccpd_type = DCCP_PKT_DATAACK;
-		else
-			dcb->dccpd_type = DCCP_PKT_DATA;
-
-		err = dccp_transmit_skb(sk, skb);
-		ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
-	} else
-		kfree_skb(skb);
+				dcb->dccpd_type = DCCP_PKT_DATAACK;
+			} else if (dccp_ack_pending(sk))
+				dcb->dccpd_type = DCCP_PKT_DATAACK;
+			else
+				dcb->dccpd_type = DCCP_PKT_DATA;

+			err = dccp_transmit_skb(sk, skb);
+			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
+		}
+#if 0
+		} else
+			kfree_skb(skb);
+#endif
+		skb_update_send_head(sk, skb);
+	}
+#if 0
 	return err;
+#endif
 }

 int dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
@@ -414,7 +426,8 @@ int dccp_connect(struct sock *sk)
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 	skb->csum = 0;

-	dccp_skb_entail(sk, skb);
+	skb_entail(sk, skb);
+	/* iancrap */
 	dccp_transmit_skb(sk, skb_clone(skb, GFP_KERNEL));
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);

@@ -526,7 +539,8 @@ void dccp_send_close(struct sock *sk, co
 					DCCP_PKT_CLOSE : DCCP_PKT_CLOSEREQ;

 	if (active) {
-		dccp_skb_entail(sk, skb);
+		skb_entail(sk, skb);
+		/* iancrap */
 		dccp_transmit_skb(sk, skb_clone(skb, prio));
 	} else
 		dccp_transmit_skb(sk, skb);
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 40a4c68..c6a1138 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -387,6 +387,8 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	lock_sock(sk);
 	timeo = sock_sndtimeo(sk, noblock);

+	/* iancrap - use timeo for memory allocation */
+
 	/*
 	 * We have to use sk_stream_wait_connect here to set sk_write_pending,
 	 * so that the trick in dccp_rcv_request_sent_state_process.
@@ -408,17 +410,9 @@ int dccp_sendmsg(struct kiocb *iocb, str
 	if (rc != 0)
 		goto out_discard;

-	rc = dccp_write_xmit(sk, skb, &timeo);
-	/*
-	 * XXX we don't use sk_write_queue, so just discard the packet.
-	 *     Current plan however is to _use_ sk_write_queue with
-	 *     an algorith similar to tcp_sendmsg, where the main difference
-	 *     is that in DCCP we have to respect packet boundaries, so
-	 *     no coalescing of skbs.
-	 *
-	 *     This bug was _quickly_ found & fixed by just looking at an OSTRA
-	 *     generated callgraph 8) -acme
-	 */
+	skb_entail(sk, skb);
+
+	dccp_write_xmit(sk);
 out_release:
 	release_sock(sk);
 	return rc ? : len;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 00aa80e..e0b53b4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -458,19 +458,14 @@ static inline int forced_push(struct tcp
 	return after(tp->write_seq, tp->pushed_seq + (tp->max_window >> 1));
 }

-static inline void skb_entail(struct sock *sk, struct tcp_sock *tp,
+static inline void tcp_skb_entail(struct sock *sk, struct tcp_sock *tp,
 			      struct sk_buff *skb)
 {
-	skb->csum = 0;
+	skb_entail(sk,skb);
 	TCP_SKB_CB(skb)->seq = tp->write_seq;
 	TCP_SKB_CB(skb)->end_seq = tp->write_seq;
 	TCP_SKB_CB(skb)->flags = TCPCB_FLAG_ACK;
 	TCP_SKB_CB(skb)->sacked = 0;
-	skb_header_release(skb);
-	__skb_queue_tail(&sk->sk_write_queue, skb);
-	sk_charge_skb(sk, skb);
-	if (!sk->sk_send_head)
-		sk->sk_send_head = skb;
 	if (tp->nonagle & TCP_NAGLE_PUSH)
 		tp->nonagle &= ~TCP_NAGLE_PUSH;
 }
@@ -539,7 +534,7 @@ new_segment:
 			if (!skb)
 				goto wait_for_memory;

-			skb_entail(sk, tp, skb);
+			tcp_skb_entail(sk, tp, skb);
 			copy = size_goal;
 		}

@@ -730,7 +725,7 @@ new_segment:
 				     NETIF_F_HW_CSUM))
 					skb->ip_summed = CHECKSUM_HW;

-				skb_entail(sk, tp, skb);
+				tcp_skb_entail(sk, tp, skb);
 				copy = size_goal;
 			}

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3a0a914..1ec9128 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -51,12 +51,10 @@ int sysctl_tcp_retrans_collapse = 1;
  */
 int sysctl_tcp_tso_win_divisor = 3;

-static inline void update_send_head(struct sock *sk, struct tcp_sock *tp,
+static inline void tcp_update_send_head(struct sock *sk, struct tcp_sock *tp,
 				    struct sk_buff *skb)
 {
-	sk->sk_send_head = skb->next;
-	if (sk->sk_send_head = (struct sk_buff *)&sk->sk_write_queue)
-		sk->sk_send_head = NULL;
+	skb_update_send_head(sk, skb);
 	tp->snd_nxt = TCP_SKB_CB(skb)->end_seq;
 	tcp_packets_out_inc(sk, tp, skb);
 }
@@ -1060,7 +1058,7 @@ static int tcp_write_xmit(struct sock *s
 		/* Advance the send_head.  This one is sent out.
 		 * This call will increment packets_out.
 		 */
-		update_send_head(sk, tp, skb);
+		tcp_update_send_head(sk, tp, skb);

 		tcp_minshall_update(tp, mss_now, skb);
 		sent_pkts++;
@@ -1128,7 +1126,7 @@ void tcp_push_one(struct sock *sk, unsig
 		TCP_SKB_CB(skb)->when = tcp_time_stamp;

 		if (likely(!tcp_transmit_skb(sk, skb, 1, sk->sk_allocation))) {
-			update_send_head(sk, tp, skb);
+			tcp_update_send_head(sk, tp, skb);
 			tcp_cwnd_validate(sk, tp);
 			return;
 		}
@@ -2048,7 +2046,7 @@ int tcp_write_wakeup(struct sock *sk)
 			TCP_SKB_CB(skb)->when = tcp_time_stamp;
 			err = tcp_transmit_skb(sk, skb, 1, GFP_ATOMIC);
 			if (!err) {
-				update_send_head(sk, tp, skb);
+				tcp_update_send_head(sk, tp, skb);
 			}
 			return err;
 		} else {
