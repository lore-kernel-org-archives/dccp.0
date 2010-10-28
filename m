From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Oct 2010 05:16:26 +0000
Subject: [PATCH 2/4] dccp: Extend CCID packet dequeueing interface
Message-Id: <1288242988-5333-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This extends the packet dequeuing interface of dccp_write_xmit() to allow
 1. CCIDs to take care of timing when the next packet may be sent;
 2. delayed sending (as before, with an inter-packet gap up to 65.535 seconds).

The main purpose is to take CCID-2 out of its polling mode (when it is network-
limited, it tries every millisecond to send, without interruption).

The mode of operation for (2) is as follows:
 * new packet is enqueued via dccp_sendmsg() => dccp_write_xmit(),
 * ccid_hc_tx_send_packet() detects that it may not send (e.g. window full),
 * it signals this condition via `CCID_PACKET_WILL_DEQUEUE_LATER',
 * dccp_write_xmit() returns without further action;
 * after some time the wait-condition for CCID becomes true,
 * that CCID schedules the tasklet,
 * tasklet function calls ccid_hc_tx_send_packet() via dccp_write_xmit(),
 * since the wait-condition is now true, ccid_hc_tx_packet() returns "send now",
 * packet is sent, and possibly more (since dccp_write_xmit() loops).

Code reuse: the taskled function calls dccp_write_xmit(), the timer function
            reduces to a wrapper around the same code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 +-
 net/dccp/output.c    |  118 ++++++++++++++++++++++++++++++-------------------
 net/dccp/timer.c     |   25 ++++++-----
 3 files changed, 89 insertions(+), 58 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -462,7 +462,8 @@ struct dccp_ackvec;
  * @dccps_hc_rx_insert_options - receiver wants to add options when acking
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
  * @dccps_server_timewait - server holds timewait state on close (RFC 4340, 8.3)
- * @dccps_xmit_timer - timer for when CCID is not ready to send
+ * @dccps_xmitlet - tasklet scheduled by the TX CCID to dequeue data packets
+ * @dccps_xmit_timer - used by the TX CCID to delay sending (rate-based pacing)
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
 struct dccp_sock {
@@ -502,6 +503,7 @@ struct dccp_sock {
 	__u8				dccps_hc_rx_insert_options:1;
 	__u8				dccps_hc_tx_insert_options:1;
 	__u8				dccps_server_timewait:1;
+	struct tasklet_struct		dccps_xmitlet;
 	struct timer_list		dccps_xmit_timer;
 };
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -254,63 +254,89 @@ do_interrupted:
 	goto out;
 }
 
+/**
+ * dccp_xmit_packet  -  Send data packet under control of CCID
+ * Transmits next-queued payload and informs CCID to account for the packet.
+ */
+static void dccp_xmit_packet(struct sock *sk)
+{
+	int err, len;
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct sk_buff *skb = skb_dequeue(&sk->sk_write_queue);
+
+	if (unlikely(skb = NULL))
+		return;
+	len = skb->len;
+
+	if (sk->sk_state = DCCP_PARTOPEN) {
+		const u32 cur_mps = dp->dccps_mss_cache - DCCP_FEATNEG_OVERHEAD;
+		/*
+		 * See 8.1.5 - Handshake Completion.
+		 *
+		 * For robustness we resend Confirm options until the client has
+		 * entered OPEN. During the initial feature negotiation, the MPS
+		 * is smaller than usual, reduced by the Change/Confirm options.
+		 */
+		if (!list_empty(&dp->dccps_featneg) && len > cur_mps) {
+			DCCP_WARN("Payload too large (%d) for featneg.\n", len);
+			dccp_send_ack(sk);
+			dccp_feat_list_purge(&dp->dccps_featneg);
+		}
+
+		inet_csk_schedule_ack(sk);
+		inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
+					      inet_csk(sk)->icsk_rto,
+					      DCCP_RTO_MAX);
+		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK;
+	} else if (dccp_ack_pending(sk)) {
+		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK;
+	} else {
+		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATA;
+	}
+
+	err = dccp_transmit_skb(sk, skb);
+	if (err)
+		dccp_pr_debug("transmit_skb() returned err=%d\n", err);
+	/*
+	 * Register this one as sent even if an error occurred. To the remote
+	 * end a local packet drop is indistinguishable from network loss, i.e.
+	 * any local drop will eventually be reported via receiver feedback.
+	 */
+	ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, len);
+}
+
 void dccp_write_xmit(struct sock *sk, int block)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct sk_buff *skb;
 
 	while ((skb = skb_peek(&sk->sk_write_queue))) {
-		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
+		int rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 
-		if (err > 0) {
+		switch (ccid_packet_dequeue_eval(rc)) {
+		case CCID_PACKET_WILL_DEQUEUE_LATER:
+			return;
+		case CCID_PACKET_DELAY:
 			if (!block) {
 				sk_reset_timer(sk, &dp->dccps_xmit_timer,
-						msecs_to_jiffies(err)+jiffies);
+						msecs_to_jiffies(rc)+jiffies);
+				return;
+			}
+			rc = dccp_wait_for_ccid(sk, skb, rc);
+			if (rc && rc != -EINTR) {
+				DCCP_BUG("err=%d after dccp_wait_for_ccid", rc);
+				skb_dequeue(&sk->sk_write_queue);
+				kfree_skb(skb);
 				break;
-			} else
-				err = dccp_wait_for_ccid(sk, skb, err);
-			if (err && err != -EINTR)
-				DCCP_BUG("err=%d after dccp_wait_for_ccid", err);
-		}
-
-		skb_dequeue(&sk->sk_write_queue);
-		if (err = 0) {
-			struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-			const int len = skb->len;
-
-			if (sk->sk_state = DCCP_PARTOPEN) {
-				const u32 cur_mps = dp->dccps_mss_cache - DCCP_FEATNEG_OVERHEAD;
-				/*
-				 * See 8.1.5 - Handshake Completion.
-				 *
-				 * For robustness we resend Confirm options until the client has
-				 * entered OPEN. During the initial feature negotiation, the MPS
-				 * is smaller than usual, reduced by the Change/Confirm options.
-				 */
-				if (!list_empty(&dp->dccps_featneg) && len > cur_mps) {
-					DCCP_WARN("Payload too large (%d) for featneg.\n", len);
-					dccp_send_ack(sk);
-					dccp_feat_list_purge(&dp->dccps_featneg);
-				}
-
-				inet_csk_schedule_ack(sk);
-				inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
-						  inet_csk(sk)->icsk_rto,
-						  DCCP_RTO_MAX);
-				dcb->dccpd_type = DCCP_PKT_DATAACK;
-			} else if (dccp_ack_pending(sk))
-				dcb->dccpd_type = DCCP_PKT_DATAACK;
-			else
-				dcb->dccpd_type = DCCP_PKT_DATA;
-
-			err = dccp_transmit_skb(sk, skb);
-			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, len);
-			if (err)
-				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
-					 err);
-		} else {
-			dccp_pr_debug("packet discarded due to err=%d\n", err);
+			}
+			/* fall through */
+		case CCID_PACKET_SEND_AT_ONCE:
+			dccp_xmit_packet(sk);
+			break;
+		case CCID_PACKET_ERR:
+			skb_dequeue(&sk->sk_write_queue);
 			kfree_skb(skb);
+			dccp_pr_debug("packet discarded due to err=%d\n", rc);
 		}
 	}
 }
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -237,32 +237,35 @@ out:
 	sock_put(sk);
 }
 
-/* Transmit-delay timer: used by the CCIDs to delay actual send time */
-static void dccp_write_xmit_timer(unsigned long data)
+/**
+ * dccp_write_xmitlet  -  Workhorse for CCID packet dequeueing interface
+ * See the comments above %ccid_dequeueing_decision for supported modes.
+ */
+static void dccp_write_xmitlet(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct dccp_sock *dp = dccp_sk(sk);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk))
-		sk_reset_timer(sk, &dp->dccps_xmit_timer, jiffies+1);
+		sk_reset_timer(sk, &dccp_sk(sk)->dccps_xmit_timer, jiffies + 1);
 	else
 		dccp_write_xmit(sk, 0);
 	bh_unlock_sock(sk);
-	sock_put(sk);
 }
 
-static void dccp_init_write_xmit_timer(struct sock *sk)
+static void dccp_write_xmit_timer(unsigned long data)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	setup_timer(&dp->dccps_xmit_timer, dccp_write_xmit_timer,
-			(unsigned long)sk);
+	dccp_write_xmitlet(data);
+	sock_put((struct sock *)data);
 }
 
 void dccp_init_xmit_timers(struct sock *sk)
 {
-	dccp_init_write_xmit_timer(sk);
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	tasklet_init(&dp->dccps_xmitlet, dccp_write_xmitlet, (unsigned long)sk);
+	setup_timer(&dp->dccps_xmit_timer, dccp_write_xmit_timer,
+							     (unsigned long)sk);
 	inet_csk_init_xmit_timers(sk, &dccp_write_timer, &dccp_delack_timer,
 				  &dccp_keepalive_timer);
 }
