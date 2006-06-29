From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 29 Jun 2006 23:18:24 +0000
Subject: [PATCH 1/1] [DCCP]: Introduce tx buffering
Message-Id: <200606301118.25071.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds transmit buffering to DCCP.

I have tested with CCID2/3 and with loss and rate limiting.

The only slight downside I have observed is that there can be memory pressure
on the receiver as they receive packets faster. However I can reproduce
without my patch also if I send fast enough. I believe that this is due to
lack of buffer limiting and/or slight flaws in congestion algorithm - neither
of which is due to this patch! I checked for memory consumption on the
transmitter and did not observe any problems here.

I would like this to be considered for 2.6.18 and I believe it could help
Andrea's work with CCID2.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
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
index 1fe5091..1ba5ac5 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -5,7 +5,7 @@ #define _DCCP_H
  *
  *  An implementation of the DCCP protocol
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
- *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *	This program is free software; you can redistribute it and/or modify it
  *	under the terms of the GNU General Public License version 2 as
@@ -123,7 +123,7 @@ extern void dccp_send_delayed_ack(struct
 extern void dccp_send_sync(struct sock *sk, const u64 seq,
 			   const enum dccp_pkt_type pkt_type);
 
-extern int dccp_write_xmit(struct sock *sk, struct sk_buff *skb, long *timeo);
+extern void dccp_write_xmit(struct sock *sk, int block);
 extern void dccp_write_space(struct sock *sk);
 
 extern void dccp_init_xmit_timers(struct sock *sk);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 7409e4a..73da2b6 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -199,7 +199,7 @@ static int dccp_wait_for_ccid(struct soc
 	while (1) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 
-		if (sk->sk_err || (sk->sk_shutdown & SEND_SHUTDOWN))
+		if (sk->sk_err)
 			goto do_error;
 		if (!*timeo)
 			goto do_nonblock;
@@ -235,37 +235,70 @@ do_interrupted:
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
-					 skb->len);
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct sk_buff *skb;
+	long timeo = 2000; 	/* If a packet is taking longer than 2 secs
+				   we have other issues */
 
-	if (err > 0)
-		err = dccp_wait_for_ccid(sk, skb, timeo);
+	while ((skb = skb_peek(&sk->sk_write_queue))) {
+		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
+					 skb->len);
+		
+		if (err > 0) {
+			if (!block) { 
+				sk_reset_timer(sk, &dp->dccps_xmit_timer, 
+						msecs_to_jiffies(err)+jiffies);
+				break;
+			} else
+				err = dccp_wait_for_ccid(sk, skb, &timeo);
+		}
 
-	if (err = 0) {
-		struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-		const int len = skb->len;
+		skb_dequeue(&sk->sk_write_queue);
+		if (err = 0) {
+			struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+			const int len = skb->len;
 
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
+				dcb->dccpd_type = DCCP_PKT_DATAACK;
+			} else if (dccp_ack_pending(sk))
+				dcb->dccpd_type = DCCP_PKT_DATAACK;
+			else
+				dcb->dccpd_type = DCCP_PKT_DATA;
+
+			err = dccp_transmit_skb(sk, skb);
+			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
+			if (err != 0) {
+				BUG();
+				break;
+			}
+		} else 
+			kfree(skb);
+		if (err != 0) {
+			BUG();
+			break;
+		}
 
-	return err;
+	}
 }
 
 int dccp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
@@ -427,6 +460,9 @@ static inline void dccp_connect_init(str
 	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
 
 	icsk->icsk_retransmits = 0;
+	init_timer(&dp->dccps_xmit_timer);
+	dp->dccps_xmit_timer.data = (unsigned long)sk;
+	dp->dccps_xmit_timer.function = dccp_write_xmit_timer;
 }
 
 int dccp_connect(struct sock *sk)
@@ -561,8 +597,10 @@ void dccp_send_close(struct sock *sk, co
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
index 5317fd3..6432a60 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -663,17 +663,8 @@ int dccp_sendmsg(struct kiocb *iocb, str
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
@@ -847,6 +838,7 @@ static int dccp_close_state(struct sock 
 
 void dccp_close(struct sock *sk, long timeout)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 	int state;
 
@@ -863,6 +855,8 @@ void dccp_close(struct sock *sk, long ti
 		goto adjudge_to_death;
 	}
 
+	sk_stop_timer(sk, &dp->dccps_xmit_timer);
+
 	/*
 	 * We need to flush the recv. buffs.  We do this only on the
 	 * descriptor close, not protocol-sourced closes, because the

