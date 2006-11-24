From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:56 +0000
Subject: [PATCH 7/10]: Avoid `division by zero' errors
Message-Id: <200611241619.56426@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Avoid `division by zero' errors

Several places of the code divide by the current RTT value. A division-by-zero
error results if this value is 0. 
To protect against this, 
   * DCCP_BUG_ON conditions are added throughout the tx code;
   * in ccid3_hc_tx_packet_recv, a code block is shifted, to avoid not updating
     p and x_recv in case the RTT estimation results in an error;

Since this could probably be done in a smarter way, a FIXME is added. Lastly,
some minor code comment updates.      

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |   53 ++++++++++++++++++++-----------------
 net/dccp/ccids/ccid3.h             |    2 -
 net/dccp/ccids/lib/tfrc_equation.c |    7 +---
 3 files changed, 33 insertions(+), 29 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -117,7 +117,7 @@ static inline void ccid3_update_send_tim
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 }
 /*
- * Update X by
+ * Update X by  (this implements step (4) of [RFC 3448, 4.3]):
  *    If (p > 0)
  *       x_calc = calcX(s, R, p);
  *       X = max(min(X_calc, 2 * X_recv), s / t_mbi);
@@ -125,12 +125,17 @@ static inline void ccid3_update_send_tim
  *       If (now - tld >= R)
  *          X = max(min(2 * X, 2 * X_recv), s / R);
  *          tld = now;
+ *
+ * If X has changed, we also update the scheduled send time t_now,
+ * the inter-packet interval t_ipi, and the delta value.
  */ 
 static void ccid3_hc_tx_update_x(struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const __u32 old_x = hctx->ccid3hctx_x;
 
+	DCCP_BUG_ON(hctx->ccid3hctx_rtt = 0);
+
 	/* To avoid large error in calcX */
 	if (hctx->ccid3hctx_p >= TFRC_SMALLEST_P) {
 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
@@ -421,7 +426,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	unsigned long next_tmout; 
 	u32 t_elapsed;
 	u32 pinv;
-	u32 x_recv;
 	u32 r_sample;
 
 	BUG_ON(hctx = NULL);
@@ -434,15 +438,11 @@ static void ccid3_hc_tx_packet_recv(stru
 	opt_recv = &hctx->ccid3hctx_options_received;
 
 	t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
-	x_recv = opt_recv->ccid3or_receive_rate;
 	pinv = opt_recv->ccid3or_loss_event_rate;
 
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		/* Calculate new round trip sample by
-		 * R_sample = (now - t_recvdata) - t_delay */
-		/* get t_recvdata from history */
 		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
 						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
 		if (unlikely(packet = NULL)) {
@@ -453,7 +453,25 @@ static void ccid3_hc_tx_packet_recv(stru
 			return;
 		}
 
-		/* Update RTT */
+		/* Update receive rate */
+		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+
+		/* Update loss event rate */
+		if (pinv = ~0 || pinv = 0)
+			hctx->ccid3hctx_p = 0;
+		else {
+			hctx->ccid3hctx_p = 1000000 / pinv;
+
+			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P) {
+				hctx->ccid3hctx_p = TFRC_SMALLEST_P;
+				ccid3_pr_debug("%s, sk=%p, Smallest p used!\n",
+					       dccp_role(sk), sk);
+			}
+		}
+
+		/* Calculate new round trip sample by
+		 * 	R_sample = (t_now - t_recvdata) - t_delay
+		 * t_recvdata is taken from packet history        */
 		dccp_timestamp(sk, &now);
 		r_sample = timeval_delta(&now, &packet->dccphtx_tstamp);
 		if (unlikely(r_sample <= t_elapsed))
@@ -462,7 +480,7 @@ static void ccid3_hc_tx_packet_recv(stru
 		else
 			r_sample -= t_elapsed;
 
-		/* Update RTT estimate by 
+		/* Update RTT estimate by  (step (2) of [RFC 3448, 4.3]):
 		 * If (No feedback recv)
 		 *    R = R_sample;
 		 * Else
@@ -481,21 +499,10 @@ static void ccid3_hc_tx_packet_recv(stru
 			       "r_sample=%us\n", dccp_role(sk), sk,
 			       hctx->ccid3hctx_rtt, r_sample);
 
-		/* Update receive rate */
-		hctx->ccid3hctx_x_recv = x_recv;/* X_recv in bytes per sec */
-
-		/* Update loss event rate */
-		if (pinv = ~0 || pinv = 0)
-			hctx->ccid3hctx_p = 0;
-		else {
-			hctx->ccid3hctx_p = 1000000 / pinv;
-
-			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P) {
-				hctx->ccid3hctx_p = TFRC_SMALLEST_P;
-				ccid3_pr_debug("%s, sk=%p, Smallest p used!\n",
-					       dccp_role(sk), sk);
-			}
-		}
+		/* Avoid `division-by zero' errors.
+		 * FIXME: We need a smarter and more robust way to
+		 *        protect against this possibility         */
+		DCCP_BUG_ON(hctx->ccid3hctx_rtt = 0);
 
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
--- a/net/dccp/ccids/lib/tfrc_equation.c
+++ b/net/dccp/ccids/lib/tfrc_equation.c
@@ -578,6 +578,8 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 	u32 f;
 	u64 tmp1, tmp2;
 
+	DCCP_BUG_ON(R = 0);	/* RTT can't be zero or else divide by zero */
+
 	if (p < TFRC_CALC_X_SPLIT)
 		index = (p / (TFRC_CALC_X_SPLIT / TFRC_CALC_X_ARRSIZE)) - 1;
 	else
@@ -587,11 +589,6 @@ u32 tfrc_calc_x(u16 s, u32 R, u32 p)
 		/* p should be 0 unless there is a bug in my code */
 		index = 0;
 
-	if (R = 0) {
-		DCCP_WARN("RTT=0, setting to 1\n");
-		R = 1; /* RTT can't be zero or else divide by zero */
-	}
-
 	BUG_ON(index >= TFRC_CALC_X_ARRSIZE);
 
 	if (p >= TFRC_CALC_X_SPLIT)
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -78,7 +78,7 @@ enum ccid3_hc_tx_states {
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
  * @ccid3hctx_x - Current sending rate
- * @ccid3hctx_x_recv - Receive rate
+ * @ccid3hctx_x_recv - Receive rate in bytes per second
  * @ccid3hctx_x_calc - Calculated send rate (RFC 3448, 3.1)
  * @ccid3hctx_rtt - Estimate of current round trip time in usecs
  * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
