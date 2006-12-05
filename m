From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:38:48 +0000
Subject: [PATCH 7/7]: Debug timeval operations
Message-Id: <200612052038.48522@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Debug timeval operations

Problem:
--------
 Most target types in the CCID3 code are u32, so subtle conversion errors
 can occur if signed time calculations yield negative results: the original
 values are lost in the conversion to unsigned, calculation errors go undetected.

 This patch therefore
   * sets all critical time types from unsigned to suseconds_t 
   * avoids comparison between signed/unsigned via type-casting
   * provides ample warning messages in case time calculations are negative

 These warning messages can be removed at a later stage when the code
 has undergone more testing.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |   56 ++++++++++++++++++++++++++++---------------------
 net/dccp/dccp.h        |    1 
 2 files changed, 33 insertions(+), 24 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -434,6 +434,7 @@ static inline void timeval_sub_usecs(str
 		tv->tv_sec--;
 		tv->tv_usec += USEC_PER_SEC;
 	}
+	DCCP_BUG_ON(tv->tv_sec < 0);
 }
 
 #ifdef CONFIG_SYSCTL
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -128,8 +128,8 @@ static void ccid3_hc_tx_update_x(struct 
 		hctx->ccid3hctx_x = max_t(u64, hctx->ccid3hctx_x,
 					  (hctx->ccid3hctx_s << 6)/TFRC_T_MBI);
 
-	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) >-							  hctx->ccid3hctx_rtt) {
+	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) -
+			(suseconds_t)hctx->ccid3hctx_rtt >= 0 ) {
 
 		hctx->ccid3hctx_x = max(2 * min(hctx->ccid3hctx_x,
 						hctx->ccid3hctx_x_recv),
@@ -271,7 +271,7 @@ static int ccid3_hc_tx_send_packet(struc
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct dccp_tx_hist_entry *new_packet;
 	struct timeval now;
-	long delay;
+	suseconds_t delay;
 
 	BUG_ON(hctx = NULL);
 
@@ -331,7 +331,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (long)hctx->ccid3hctx_delta >= 0)
+		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
 			return delay / 1000L;
 		break;
 	case TFRC_SSTATE_TERM:
@@ -353,7 +353,7 @@ static void ccid3_hc_tx_packet_sent(stru
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
-	unsigned long quarter_rtt;
+	suseconds_t quarter_rtt;
 	struct dccp_tx_hist_entry *packet;
 
 	BUG_ON(hctx = NULL);
@@ -450,10 +450,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		r_sample  = timeval_delta(&now, &packet->dccphtx_tstamp);
 		t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
 
-		if (unlikely(r_sample <= 0)) {
-			DCCP_WARN("WARNING: R_sample (%ld) <= 0!\n", r_sample);
-			r_sample = 0;
-		} else if (unlikely(r_sample <= t_elapsed))
+		DCCP_BUG_ON(r_sample < 0);
+		if (unlikely(r_sample <= t_elapsed))
 			DCCP_WARN("WARNING: r_sample=%ldus <= t_elapsed=%ldus\n",
 				  r_sample, t_elapsed);
 		else
@@ -698,6 +696,7 @@ static void ccid3_hc_rx_send_feedback(st
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
+	suseconds_t delta;
 
 	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
 
@@ -707,12 +706,12 @@ static void ccid3_hc_rx_send_feedback(st
 	case TFRC_RSTATE_NO_DATA:
 		hcrx->ccid3hcrx_x_recv = 0;
 		break;
-	case TFRC_RSTATE_DATA: {
-		const u32 delta = timeval_delta(&now,
-					&hcrx->ccid3hcrx_tstamp_last_feedback);
+	case TFRC_RSTATE_DATA:
+		delta = timeval_delta(&now,
+				      &hcrx->ccid3hcrx_tstamp_last_feedback);
+		DCCP_BUG_ON(delta < 0);
 		hcrx->ccid3hcrx_x_recv  			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
-	}
 		break;
 	case TFRC_RSTATE_TERM:
 		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
@@ -730,9 +729,10 @@ static void ccid3_hc_rx_send_feedback(st
 	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
-	/* Convert to multiples of 10us */
-	hcrx->ccid3hcrx_elapsed_time -			timeval_delta(&now, &packet->dccphrx_tstamp) / 10;
+	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
+	delta = timeval_delta(&now, &packet->dccphrx_tstamp);
+	DCCP_BUG_ON(delta < 0);
+	hcrx->ccid3hcrx_elapsed_time = delta / 10;
 
 	if (hcrx->ccid3hcrx_p = 0)
 		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
@@ -785,7 +785,8 @@ static u32 ccid3_hc_rx_calc_first_li(str
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
-	u32 rtt, delta, x_recv, p;
+	u32 x_recv, p;
+	suseconds_t rtt, delta;
 	struct timeval tstamp = { 0, };
 	int interval = 0;
 	int win_count = 0;
@@ -830,8 +831,12 @@ found:
 		DCCP_CRIT("tail is null\n");
 		return ~0;
 	}
-	rtt = timeval_delta(&tstamp, &tail->dccphrx_tstamp) * 4 / interval;
-	ccid3_pr_debug("%s, sk=%p, approximated RTT to %uus\n",
+
+	delta = timeval_delta(&tstamp, &tail->dccphrx_tstamp);
+	DCCP_BUG_ON(delta < 0);
+
+	rtt = delta * 4 / interval;
+	ccid3_pr_debug("%s, sk=%p, approximated RTT to %ldus\n",
 		       dccp_role(sk), sk, rtt);
 
 	/*
@@ -849,8 +854,9 @@ found:
 
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	DCCP_BUG_ON(delta <= 0);
 
+	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
 		if((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
@@ -977,7 +983,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
-	u32 p_prev, rtt_prev, r_sample, t_elapsed;
+	u32 p_prev, rtt_prev;
+	suseconds_t r_sample, t_elapsed;
 	int loss, payload_size;
 
 	BUG_ON(hcrx = NULL);
@@ -997,8 +1004,9 @@ static void ccid3_hc_rx_packet_recv(stru
 		r_sample = timeval_usecs(&now);
 		t_elapsed = opt_recv->dccpor_elapsed_time * 10;
 
+		DCCP_BUG_ON(r_sample < 0);
 		if (unlikely(r_sample <= t_elapsed))
-			DCCP_WARN("r_sample=%uus, t_elapsed=%uus\n",
+			DCCP_WARN("r_sample=%ldus, t_elapsed=%ldus\n",
 				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
@@ -1051,8 +1059,8 @@ static void ccid3_hc_rx_packet_recv(stru
 			break;
 
 		dccp_timestamp(sk, &now);
-		if (timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) >-		    hcrx->ccid3hcrx_rtt) {
+		if (timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
+					(suseconds_t)hcrx->ccid3hcrx_rtt >= 0) {
 			hcrx->ccid3hcrx_tstamp_last_ack = now;
 			ccid3_hc_rx_send_feedback(sk);
 		}
