From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Feb 2008 13:48:22 +0000
Subject: [PATCH 1/5] [DCCP]: Extend CCID packet dequeueing interface
Message-Id: <1202996906-29652-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This extends the packet dequeuing interface of dccp_write_xmit() to allow
 1. CCIDs to take care of timing when the next packet may be sent;
 2. delayed sending (as before, with an inter-packet gap up to 65.535 seconds).

The main purpose is to take CCID2 out of its polling mode (when it is network-
limited, it tries every millisecond to send, without interruption).
The interface can also be used to support other CCIDs.

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

If the tasklet finds that the socket is locked, it re-schedules the tasklet
function (not the tasklet) after one jiffy.

Changed DCCP_BUG to DCCP_WARN when transmit_skb returns an error (e.g. when a
local qdisc is used, NET_XMIT_DROP=1 can be returned for many packets).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h   |    4 +-
 net/dccp/ccid.h        |   37 ++++++++++++++++-
 net/dccp/ccids/ccid3.c |    4 +-
 net/dccp/output.c      |  103 +++++++++++++++++++++++++++++++----------------
 net/dccp/timer.c       |   25 ++++++-----
 5 files changed, 122 insertions(+), 51 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -476,7 +476,8 @@ struct dccp_ackvec;
  * @dccps_hc_tx_insert_options - sender wants to add options when sending
  * @dccps_server_timewait - server holds timewait state on close (RFC 4340, 8.3)
  * @dccps_sync_scheduled - flag which signals "send out-of-band message soon"
- * @dccps_xmit_timer - timer for when CCID is not ready to send
+ * @dccps_xmitlet - tasklet scheduled by the TX CCID to dequeue data packets
+ * @dccps_xmit_timer - used by the TX CCID to delay sending (rate-based pacing)
  * @dccps_syn_rtt - RTT sample from Request/Response exchange (in usecs)
  */
 struct dccp_sock {
@@ -517,6 +518,7 @@ struct dccp_sock {
 	__u8				dccps_hc_tx_insert_options:1;
 	__u8				dccps_server_timewait:1;
 	__u8				dccps_sync_scheduled:1;
+	struct tasklet_struct		dccps_xmitlet;
 	struct timer_list		dccps_xmit_timer;
 };
 
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -124,13 +124,44 @@ static inline int ccid_get_current_id(struct dccp_sock *dp, bool rx)
 extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
 extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
+/*
+ * Congestion control of queued data packets via CCID decision.
+ *
+ * The TX CCID performs its congestion-control by indicating whether and when a
+ * queued packet may be sent, using the return code of ccid_hc_tx_send_packet().
+ * The following modes are supported:
+ *  - autonomous dequeueing (CCID internally schedules dccps_xmitlet);
+ *  - timer-based pacing (CCID returns a delay value in milliseconds).
+ * Modes and error handling are identified using the symbolic constants below.
+ */
+enum ccid_dequeueing_decision {
+	CCID_PACKET_SEND_AT_ONCE =	 0x00000,
+	CCID_PACKET_DELAY =		 0x10000,
+	CCID_PACKET_WILL_DEQUEUE_LATER = 0x20000,
+	CCID_PACKET_ERR =		 0xF0000,
+};
+
+/* maximum possible number of milliseconds to delay a packet (65.535 seconds) */
+#define CCID_PACKET_DELAY_MAX		0xFFFF
+#define CCID_PACKET_DELAY_MAX_USEC	(CCID_PACKET_DELAY_MAX * USEC_PER_MSEC)
+
+static inline int ccid_packet_dequeue_eval(int return_code)
+{
+	if (return_code < 0)
+		return CCID_PACKET_ERR;
+	if (return_code = 0)
+		return CCID_PACKET_SEND_AT_ONCE;
+	if (return_code <= CCID_PACKET_DELAY_MAX)
+		return CCID_PACKET_DELAY;
+	return return_code;
+}
+
 static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
 					 struct sk_buff *skb)
 {
-	int rc = 0;
 	if (ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
-		rc = ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb);
-	return rc;
+		return ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb);
+	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -346,6 +346,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	case TFRC_SSTATE_FBACK:
 		delay = ktime_us_delta(hctx->ccid3hctx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
+		if (delay > CCID_PACKET_DELAY_MAX_USEC)
+			delay = CCID_PACKET_DELAY_MAX_USEC;
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
@@ -371,7 +373,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	/* set the nominal send time for the next following packet */
 	hctx->ccid3hctx_t_nom = ktime_add_us(hctx->ccid3hctx_t_nom,
 					     hctx->ccid3hctx_t_ipi);
-	return 0;
+	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -249,52 +249,85 @@ do_interrupted:
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
+		/* See 8.1.5.  Handshake Completion */
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
+		DCCP_WARN("transmit_skb() returned err=%d\n", err);
+	/*
+	 * Register this one as sent even if an error occurred. To the remote
+	 * end this error is indistinguishable from loss, so that finally (if
+	 * the peer has no bugs) the drop is reported via receiver feedback.
+	 */
+	ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
+
+	/*
+	 * If the CCID needs to transfer additional header options out-of-band
+	 * (e.g. Ack Vectors or feature-negotiation options), it activates the
+	 * flag to schedule a Sync. The Sync will automatically incorporate all
+	 * currently valid header options so that this backlog is now cleared.
+	 */
+	if (dp->dccps_sync_scheduled)
+		dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
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
-				/* See 8.1.5.  Handshake Completion */
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
-			ccid_hc_tx_packet_sent(dp->dccps_hc_tx_ccid, sk, 0, len);
-			if (err)
-				DCCP_BUG("err=%d after ccid_hc_tx_packet_sent",
-					 err);
-			if (dp->dccps_sync_scheduled)
-				dccp_send_sync(sk, dp->dccps_gsr, DCCP_PKT_SYNC);
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
@@ -249,32 +249,35 @@ out:
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
