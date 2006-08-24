From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 24 Aug 2006 03:29:19 +0000
Subject: [PATCH 7/7] [DCCP]: Introduce tx buffering
Message-Id: <200608241529.20373.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds transmit buffering to DCCP.

I have tested with CCID2/3 and with loss and rate limiting.

Signed off by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 676333b..2d7671c 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -438,6 +438,7 @@ struct dccp_ackvec;
  * @dccps_role - Role of this sock, one of %dccp_role
  * @dccps_ndp_count - number of Non Data Packets since last data packet
  * @dccps_hc_rx_ackvec - rx half connection ack vector
+ * @dccps_xmit_timer - timer for when CCID is not ready to send
  */
 struct dccp_sock {
 	/* inet_connection_sock has to be the first member of dccp_sock */
@@ -470,6 +471,7 @@ struct dccp_sock {
 	enum dccp_role			dccps_role:2;
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
+	struct timer_list		dccps_xmit_timer;
 };
  
 static inline struct dccp_sock *dccp_sk(const struct sock *sk)
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 84b477d..f9f0721 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -130,7 +130,7 @@ extern void dccp_send_delayed_ack(struct
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
 
-extern int dccp_write_xmit(struct sock *sk, struct sk_buff *skb, long *timeo);
+extern void dccp_write_xmit(struct sock *sk, int block);
 extern void dccp_write_space(struct sock *sk);
 
 extern void dccp_init_xmit_timers(struct sock *sk);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 58669be..5986cb9 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -198,7 +198,7 @@ static int dccp_wait_for_ccid(struct soc
 	while (1) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 
-		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+		if (sk->sk_err)
 			goto do_error;
 		if (!*timeo)
 			goto do_nonblock;
@@ -234,37 +234,72 @@ do_interrupted:
 	goto out;
 }
 
-int dccp_write_xmit(struct sock *sk, struct sk_buff *skb, long *timeo)
+static void dccp_write_xmit_timer(unsigned long data) {
+	struct sock *sk = (struct sock *)data;
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	bh_lock_sock(sk);
+	if (sock_owned_by_user(sk))
+		sk_reset_timer(sk, &dp->dccps_xmit_timer, jiffies+1);
+	else
+		dccp_write_xmit(sk, 0);
+	bh_unlock_sock(sk);
+	sock_put(sk);
+}
+
+void dccp_write_xmit(struct sock *sk, int block)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
-	int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct sk_buff *skb;
+	long timeo = 30000; 	/* If a packet is taking longer than 2 secs
+				   we have other issues */
+
+	while ((skb = skb_peek(&sk->sk_write_queue))) {
+		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
 					 skb->len);
+		
+		if (err > 0) {
+			if (!block) { 
+				sk_reset_timer(sk, &dp->dccps_xmit_timer, 
+						msecs_to_jiffies(err)+jiffies);
+				break;
+			} else 
+				err = dccp_wait_for_ccid(sk, skb, &timeo);
+			if (err) {
+				printk(KERN_CRIT "%s:err at dccp_wait_for_ccid"
+						 " %d\n", __FUNCTION__, err);
+				dump_stack();
+			}
+		}
 
-	if (err > 0)
-		err = dccp_wait_for_ccid(sk, skb, timeo);
+		skb_dequeue(&sk->sk_write_queue);
+		if (err = 0) {
+			struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+			const int len = skb->len;
 
-	if (err = 0) {
-		struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-		const int len = skb->len;
-
-		if (sk->sk_state = DCCP_PARTOPEN) {
-			/* See 8.1.5.  Handshake Completion */
-			inet_csk_schedule_ack(sk);
-			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
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
-
-	return err;
+				dcb->dccpd_type = DCCP_PKT_DATAACK;
+			} else if (dccp_ack_pending(sk))
+				dcb->dccpd_type = DCCP_PKT_DATAACK;
+			else
+				dcb->dccpd_type = DCCP_PKT_DATA;
+
+			err = dccp_transmit_skb(sk, skb);
+			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
+			if (err) {
+				printk(KERN_CRIT "%s:err from "
+					         "ccid_hc_tx_packet_sent %d\n", 
+					         __FUNCTION__, err);
+				dump_stack();
+			}
+		} else 
+			kfree(skb);
+	}
 }
 
 int dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
@@ -426,6 +461,9 @@ static inline void dccp_connect_init(str
 	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
 
 	icsk->icsk_retransmits = 0;
+	init_timer(&dp->dccps_xmit_timer);
+	dp->dccps_xmit_timer.data = (unsigned long)sk;
+	dp->dccps_xmit_timer.function = dccp_write_xmit_timer;
 }
 
 int dccp_connect(struct sock *sk)
@@ -560,8 +598,10 @@ void dccp_send_close(struct sock *sk, co
 					DCCP_PKT_CLOSE : DCCP_PKT_CLOSEREQ;
 
 	if (active) {
+		dccp_write_xmit(sk, 1);
 		dccp_skb_entail(sk, skb);
 		dccp_transmit_skb(sk, skb_clone(skb, prio));
+		/* FIXME do we need a retransmit timer here? */
 	} else
 		dccp_transmit_skb(sk, skb);
 }
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 6f14bb5..962df0e 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -662,17 +662,8 @@ int dccp_sendmsg(struct kiocb *iocb, str
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
+	skb_queue_tail(&sk->sk_write_queue, skb);
+	dccp_write_xmit(sk,0);
 out_release:
 	release_sock(sk);
 	return rc ? : len;
@@ -846,6 +837,7 @@ static int dccp_close_state(struct sock 
 
 void dccp_close(struct sock *sk, long timeout)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 	int state;
 
@@ -862,6 +854,8 @@ void dccp_close(struct sock *sk, long ti
 		goto adjudge_to_death;
 	}
 
+	sk_stop_timer(sk, &dp->dccps_xmit_timer);
+
 	/*
 	 * We need to flush the recv. buffs.  We do this only on the
 	 * descriptor close, not protocol-sourced closes, because the
