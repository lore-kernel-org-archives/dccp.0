From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:13:28 +0000
Subject: [Patch 10/12]: Make debug output consistent
Message-Id: <200612072113.28416@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Make debug output consistent

This patch does not alter any algorithm, just the debug message format:

 * s#%s, sk=%p#%s(%p)#g

 * when a statename is present, it now uses %s(%p, state=%s)

 * when only function entry is debugged, it adds an `- entry'

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |   61 +++++++++++++++++++++++--------------------------
 1 file changed, 29 insertions(+), 32 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -201,7 +201,7 @@ static void ccid3_hc_tx_no_feedback_time
 		goto restart_timer;
 	}
 
-	ccid3_pr_debug("%s, sk=%p, state=%s\n", dccp_role(sk), sk,
+	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 	
 	switch (hctx->ccid3hctx_state) {
@@ -210,9 +210,8 @@ static void ccid3_hc_tx_no_feedback_time
 		hctx->ccid3hctx_x = max_t(u32, hctx->ccid3hctx_x / 2,
 					  (hctx->ccid3hctx_s << 6)/TFRC_T_MBI);
 
-		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %u "
-			       "bytes/s\n",
-			       dccp_role(sk), sk,
+		ccid3_pr_debug("%s(%p, state=%s), updated tx rate to %u "
+			       "bytes/s\n", dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
 			       (unsigned)(hctx->ccid3hctx_x >> 6));
 		/* The value of R is still undefined and so we can not recompute
@@ -230,7 +229,7 @@ static void ccid3_hc_tx_no_feedback_time
 		     scaled_div(hctx->ccid3hctx_s << 6, hctx->ccid3hctx_rtt))) {
 			struct timeval now;
 
-			ccid3_pr_debug("%s, sk=%p, state=%s, not idle\n",
+			ccid3_pr_debug("%s(%p, state=%s), not idle\n",
 				       dccp_role(sk), sk,
 				       ccid3_tx_state_name(hctx->ccid3hctx_state));
 
@@ -270,7 +269,7 @@ static void ccid3_hc_tx_no_feedback_time
 		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_SENT:
-		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
+		DCCP_BUG("%s(%p) - Illegal state NO_SENT", dccp_role(sk), sk);
 		/* fall through */
 	case TFRC_SSTATE_TERM:
 		goto out;
@@ -348,7 +347,7 @@ static int ccid3_hc_tx_send_packet(struc
 		ccid3_hc_tx_update_win_count(hctx, &now);
 		break;
 	case TFRC_SSTATE_TERM:
-		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
+		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return -EINVAL;
 	}
 
@@ -522,10 +521,9 @@ static void ccid3_hc_tx_packet_recv(stru
 		 */
 		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 			
-		ccid3_pr_debug("%s, sk=%p, Scheduled no feedback timer to "
-			       "expire in %lu jiffies (%luus)\n",
-			       dccp_role(sk), sk,
-			       usecs_to_jiffies(t_nfb), t_nfb);
+		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
+			       "expire in %lu jiffies (%luus)\n", dccp_role(sk),
+			       sk, usecs_to_jiffies(t_nfb), t_nfb);
 
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer, 
 				   jiffies + usecs_to_jiffies(t_nfb));
@@ -571,13 +569,13 @@ static int ccid3_hc_tx_parse_options(str
 	switch (option) {
 	case TFRC_OPT_LOSS_EVENT_RATE:
 		if (unlikely(len != 4)) {
-			DCCP_WARN("%s, sk=%p, invalid len %d "
+			DCCP_WARN("%s(%p), invalid len %d "
 				  "for TFRC_OPT_LOSS_EVENT_RATE\n",
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
 			opt_recv->ccid3or_loss_event_rate = ntohl(*(__be32 *)value);
-			ccid3_pr_debug("%s, sk=%p, LOSS_EVENT_RATE=%u\n",
+			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_loss_event_rate);
 		}
@@ -585,20 +583,20 @@ static int ccid3_hc_tx_parse_options(str
 	case TFRC_OPT_LOSS_INTERVALS:
 		opt_recv->ccid3or_loss_intervals_idx = idx;
 		opt_recv->ccid3or_loss_intervals_len = len;
-		ccid3_pr_debug("%s, sk=%p, LOSS_INTERVALS=(%u, %u)\n",
+		ccid3_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
 			       dccp_role(sk), sk,
 			       opt_recv->ccid3or_loss_intervals_idx,
 			       opt_recv->ccid3or_loss_intervals_len);
 		break;
 	case TFRC_OPT_RECEIVE_RATE:
 		if (unlikely(len != 4)) {
-			DCCP_WARN("%s, sk=%p, invalid len %d "
+			DCCP_WARN("%s(%p), invalid len %d "
 				  "for TFRC_OPT_RECEIVE_RATE\n",
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
 			opt_recv->ccid3or_receive_rate = ntohl(*(__be32 *)value);
-			ccid3_pr_debug("%s, sk=%p, RECEIVE_RATE=%u\n",
+			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_receive_rate);
 		}
@@ -684,7 +682,7 @@ static void ccid3_hc_rx_send_feedback(st
 	struct timeval now;
 	suseconds_t delta;
 
-	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
+	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
 
 	dccp_timestamp(sk, &now);
 
@@ -700,13 +698,13 @@ static void ccid3_hc_rx_send_feedback(st
 			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 		break;
 	case TFRC_RSTATE_TERM:
-		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
+		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return;
 	}
 
 	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
 	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s, sk=%p, no data packet in history!\n",
+		DCCP_WARN("%s(%p), no data packet in history!\n",
 			  dccp_role(sk), sk);
 		return;
 	}
@@ -802,13 +800,13 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	}
 
 	if (unlikely(step = 0)) {
-		DCCP_WARN("%s, sk=%p, packet history has no data packets!\n",
+		DCCP_WARN("%s(%p), packet history has no data packets!\n",
 			  dccp_role(sk), sk);
 		return ~0;
 	}
 
 	if (unlikely(interval = 0)) {
-		DCCP_WARN("%s, sk=%p, Could not find a win_count interval > 0."
+		DCCP_WARN("%s(%p), Could not find a win_count interval > 0."
 			  "Defaulting to 1\n", dccp_role(sk), sk);
 		interval = 1;
 	}
@@ -822,7 +820,7 @@ found:
 	DCCP_BUG_ON(delta < 0);
 
 	rtt = delta * 4 / interval;
-	ccid3_pr_debug("%s, sk=%p, approximated RTT to %ldus\n",
+	ccid3_pr_debug("%s(%p), approximated RTT to %ldus\n",
 		       dccp_role(sk), sk, rtt);
 
 	/*
@@ -855,7 +853,7 @@ found:
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
-	ccid3_pr_debug("%s, sk=%p, receive rate=%u bytes/s, implied "
+	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
 	if (p = 0)
@@ -1006,8 +1004,8 @@ static void ccid3_hc_rx_packet_recv(stru
 
 
 		if (rtt_prev != hcrx->ccid3hcrx_rtt)
-			ccid3_pr_debug("%s, New RTT=%uus, elapsed time=%u\n",
-				       dccp_role(sk), hcrx->ccid3hcrx_rtt,
+			ccid3_pr_debug("%s(%p), New RTT=%uus, elapsed time=%u\n",
+				       dccp_role(sk), sk, hcrx->ccid3hcrx_rtt,
 				       opt_recv->dccpor_elapsed_time);
 		break;
 	case DCCP_PKT_DATA:
@@ -1019,7 +1017,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
 					skb, SLAB_ATOMIC);
 	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s, sk=%p, Not enough mem to add rx packet "
+		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
 			  "to history, consider it lost!\n", dccp_role(sk), sk);
 		return;
 	}
@@ -1034,9 +1032,8 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
-		ccid3_pr_debug("%s, sk=%p(%s), skb=%p, sending initial "
-			       "feedback\n",
-			       dccp_role(sk), sk,
+		ccid3_pr_debug("%s(%p, state=%s), skb=%p, sending initial "
+			       "feedback\n", dccp_role(sk), sk,
 			       dccp_state_name(sk->sk_state), skb);
 		ccid3_hc_rx_send_feedback(sk);
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
@@ -1054,12 +1051,12 @@ static void ccid3_hc_rx_packet_recv(stru
 		}
 		return;
 	case TFRC_RSTATE_TERM:
-		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
+		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return;
 	}
 
 	/* Dealing with packet loss */
-	ccid3_pr_debug("%s, sk=%p(%s), data loss! Reacting...\n",
+	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
 		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
 
 	p_prev = hcrx->ccid3hcrx_p;
@@ -1084,7 +1081,7 @@ static int ccid3_hc_rx_init(struct ccid 
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
+	ccid3_pr_debug("entry\n");
 
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
