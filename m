From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 18:25:59 +0000
Subject: [PATCH 1/8]:  Fix CCID 3 bug in calculation of send rate
Message-Id: <200612011825.59535@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Fix CCID 3 bug in calculation of send rate

The main object of this patch is the following bug:
 => In ccid3_hc_tx_packet_recv, the parameters p and X_recv were updated
     _after_ the send rate was calculated. This is clearly an error and is
     resolved by re-ordering statements.

In addition,
  * r_sample is converted from u32 to long to check whether the time difference
    was negative (it would otherwise be converted to a large u32 value)
  * protection against RTT=0 (this is possible) is provided in a further patch
  * t_elapsed is also converted to long, to match the type of r_sample
  * adds a a more debugging information regarding current send rates
  * various trivial comment/documentation updates

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   89 ++++++++++++++++++++++++++++---------------------
 1 file changed, 52 insertions(+), 37 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -121,12 +121,15 @@ static inline void ccid3_update_send_tim
 /*
  * Update X by
  *    If (p > 0)
- *       x_calc = calcX(s, R, p);
+ *       X_calc = calcX(s, R, p);
  *       X = max(min(X_calc, 2 * X_recv), s / t_mbi);
  *    Else
  *       If (now - tld >= R)
  *          X = max(min(2 * X, 2 * X_recv), s / R);
  *          tld = now;
+ *
+ * If X has changed, we also update the scheduled send time t_now,
+ * the inter-packet interval t_ipi, and the delta value.
  */ 
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
@@ -413,10 +416,8 @@ static void ccid3_hc_tx_packet_recv(stru
 	struct dccp_tx_hist_entry *packet;
 	struct timeval now;
 	unsigned long t_nfb;
-	u32 t_elapsed;
 	u32 pinv;
-	u32 x_recv;
-	u32 r_sample;
+	long r_sample, t_elapsed;
 
 	BUG_ON(hctx = NULL);
 
@@ -427,31 +428,51 @@ static void ccid3_hc_tx_packet_recv(stru
 
 	opt_recv = &hctx->ccid3hctx_options_received;
 
-	t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
-	x_recv = opt_recv->ccid3or_receive_rate;
-	pinv = opt_recv->ccid3or_loss_event_rate;
-
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		/* Calculate new round trip sample by
-		 * R_sample = (now - t_recvdata) - t_delay */
-		/* get t_recvdata from history */
+		/* get packet from history to look up t_recvdata */
 		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
 						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
 		if (unlikely(packet = NULL)) {
-			DCCP_WARN("%s, sk=%p, seqno %llu(%s) does't exist "
+			DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist "
 				  "in history!\n",  dccp_role(sk), sk,
 			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
 				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
 			return;
 		}
 
-		/* Update RTT */
+		/* Update receive rate */
+		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+
+		/* Update loss event rate */
+		pinv = opt_recv->ccid3or_loss_event_rate;
+		if (pinv = ~0U || pinv = 0)
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
 		dccp_timestamp(sk, &now);
-		r_sample = timeval_delta(&now, &packet->dccphtx_tstamp);
-		if (unlikely(r_sample <= t_elapsed))
-			DCCP_WARN("r_sample=%uus,t_elapsed=%uus\n",
+
+		/*
+		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
+		 * 	R_sample  =  (now - t_recvdata) - t_elapsed
+		 */
+		r_sample  = timeval_delta(&now, &packet->dccphtx_tstamp);
+		t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
+
+		if (unlikely(r_sample <= 0)) {
+			DCCP_WARN("WARNING: R_sample (%ld) <= 0!\n", r_sample);
+			r_sample = 0;
+		} else if (unlikely(r_sample <= t_elapsed))
+			DCCP_WARN("WARNING: r_sample=%ldus <= t_elapsed=%ldus\n",
 				  r_sample, t_elapsed);
 		else
 			r_sample -= t_elapsed;
@@ -474,31 +495,25 @@ static void ccid3_hc_tx_packet_recv(stru
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_time(hctx);
-			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-		} else {
-			hctx->ccid3hctx_rtt = (hctx->ccid3hctx_rtt * 9) / 10 +
-					      r_sample / 10;
-			ccid3_hc_tx_update_x(sk, &now);
-		}
 
-		ccid3_pr_debug("%s, sk=%p, New RTT estimate=%uus, "
-			       "r_sample=%us\n", dccp_role(sk), sk,
-			       hctx->ccid3hctx_rtt, r_sample);
+			ccid3_pr_debug("%s(%p), s=%u, w_init=%u, "
+				       "R_sample=%ldus, X=%u\n", dccp_role(sk),
+				       sk, hctx->ccid3hctx_s, w_init, r_sample,
+				       hctx->ccid3hctx_x);
 
-		/* Update receive rate */
-		hctx->ccid3hctx_x_recv = x_recv;/* X_recv in bytes per sec */
+			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
+		} else {
+			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
+					           (u32)r_sample        ) / 10;
 
-		/* Update loss event rate */
-		if (pinv = ~0 || pinv = 0)
-			hctx->ccid3hctx_p = 0;
-		else {
-			hctx->ccid3hctx_p = 1000000 / pinv;
+			ccid3_hc_tx_update_x(sk, &now);
 
-			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P) {
-				hctx->ccid3hctx_p = TFRC_SMALLEST_P;
-				ccid3_pr_debug("%s, sk=%p, Smallest p used!\n",
-					       dccp_role(sk), sk);
-			}
+			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%ldus), s=%u, "
+				       "p=%u, X_calc=%u, X=%u\n", dccp_role(sk),
+				       sk, hctx->ccid3hctx_rtt, r_sample,
+				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
+				       hctx->ccid3hctx_x_calc,
+				       hctx->ccid3hctx_x);
 		}
 
 		/* unschedule no feedback timer */
