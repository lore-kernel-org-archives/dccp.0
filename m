From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:38:33 +0000
Subject: [PATCH 4/7]: Finer-grained resolution of sending rates
Message-Id: <200612052038.33453@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Finer-grained resolution of sending rates

This patch
 * resolves a bug where packets smaller than 32/64 bytes resulted in sending rates of 0
 * supports all sending rates from 1/64 bytes/second up to 4Gbyte/second
 * simplifies the present overflow problems in calculations

Current sending rate X and the cached value X_recv of the receiver-estimated
sending rate are both scaled by 64 (2^6) in order to 
 * cope with low sending rates (minimally 1 byte/second)
 * allow upgrading to use a packets-per-second implementation of CCID 3
 * avoid calculation errors due to integer arithmetic cut-off

The patch implements a revised strategy from 
http://www.mail-archive.com/dccp@vger.kernel.org/msg01040.html

The only difference with regard to that strategy is that t_ipi is already
used in the calculation of the nofeedback timeout, which saves one division.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>   
---
 include/linux/tfrc.h   |    8 +++--
 net/dccp/ccids/ccid3.c |   74 +++++++++++++++++++++++++++++--------------------
 net/dccp/ccids/ccid3.h |   33 +++++++++++++++++----
 3 files changed, 77 insertions(+), 38 deletions(-)

--- a/include/linux/tfrc.h
+++ b/include/linux/tfrc.h
@@ -37,10 +37,14 @@ struct tfrc_rx_info {
  * 	@tfrctx_p:	current loss event rate (5.4)
  * 	@tfrctx_rto:	estimate of RTO, equals 4*RTT (4.3)
  * 	@tfrctx_ipi:	inter-packet interval (4.6)
+ *
+ *  Note: X and X_recv are both maintained in units of 64 * bytes/second. This
+ *        enables a finer resolution of sending rates and avoids problems with
+ *        integer arithmetic; u32 is not sufficient as scaling consumes 6 bits.
  */
 struct tfrc_tx_info {
-	__u32 tfrctx_x;
-	__u32 tfrctx_x_recv;
+	__u64 tfrctx_x;
+	__u64 tfrctx_x_recv;
 	__u32 tfrctx_x_calc;
 	__u32 tfrctx_rtt;
 	__u32 tfrctx_p;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -75,14 +75,14 @@ enum ccid3_hc_tx_states {
 
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
- * @ccid3hctx_x - Current sending rate
- * @ccid3hctx_x_recv - Receive rate
- * @ccid3hctx_x_calc - Calculated send rate (RFC 3448, 3.1)
+ * @ccid3hctx_x - Current sending rate in 64 * bytes per second
+ * @ccid3hctx_x_recv - Receive rate    in 64 * bytes per second
+ * @ccid3hctx_x_calc - Calculated rate in bytes per second
  * @ccid3hctx_rtt - Estimate of current round trip time in usecs
  * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
- * @ccid3hctx_s - Packet size
- * @ccid3hctx_t_rto - Retransmission Timeout (RFC 3448, 3.1)
- * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6)
+ * @ccid3hctx_s - Packet size in bytes
+ * @ccid3hctx_t_rto - Nofeedback Timer setting in usecs
+ * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
  * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
  * @ccid3hctx_last_win_count - Last window counter sent
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
@@ -91,7 +91,7 @@ enum ccid3_hc_tx_states {
  * @ccid3hctx_idle - Flag indicating that sender is idling
  * @ccid3hctx_t_ld - Time last doubled during slow start
  * @ccid3hctx_t_nom - Nominal send time of next packet
- * @ccid3hctx_delta - Send timer delta
+ * @ccid3hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
  * @ccid3hctx_hist - Packet history
  * @ccid3hctx_options_received - Parsed set of retrieved options
  */
@@ -171,4 +171,23 @@ static inline struct ccid3_hc_rx_sock *c
     return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
 }
 
+static inline u64 scaled_div(u64 a, u32 b)
+{
+	BUG_ON(b=0);
+	a *= 1000000;
+	do_div(a, b);
+	return a;
+}
+
+static inline u32 scaled_div32(u64 a, u32 b)
+{
+	u64 result = scaled_div(a, b);
+
+	if (result > UINT_MAX) {
+		DCCP_CRIT("Overflow: a(%llu)/b(%u) > ~0U",
+			  (unsigned long long)a, b);
+		return UINT_MAX;
+	}
+	return result;
+}
 #endif /* _DCCP_CCID3_H_ */
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -108,8 +108,9 @@ static inline void ccid3_update_send_tim
 {
 	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
 
-	/* Calculate new t_ipi (inter packet interval) by t_ipi = s / X_inst */
-	hctx->ccid3hctx_t_ipi = usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_x);
+	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
+	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
+					   hctx->ccid3hctx_x >> 6);
 
 	/* Update nominal send time with regard to the new t_ipi */
 	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
@@ -128,6 +129,10 @@ static inline void ccid3_update_send_tim
  *          X = max(min(2 * X, 2 * X_recv), s / R);
  *          tld = now;
  *
+ * Note: X and X_recv are both stored in units of 64 * bytes/second, to support
+ *       fine-grained resolution of sending rates. This requires scaling by 2^6
+ *       throughout the code. Only X_calc is unscaled (in bytes/second).
+ *
  * If X has changed, we also update the scheduled send time t_now,
  * the inter-packet interval t_ipi, and the delta value.
  */ 
@@ -135,19 +140,22 @@ static void ccid3_hc_tx_update_x(struct 
 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 old_x = hctx->ccid3hctx_x;
+	const  __u64 old_x = hctx->ccid3hctx_x;
 
 	if (hctx->ccid3hctx_p > 0) {
-		hctx->ccid3hctx_x = max_t(u32, min(hctx->ccid3hctx_x_calc,
-						   hctx->ccid3hctx_x_recv * 2),
-					       hctx->ccid3hctx_s / TFRC_T_MBI);
+
+		hctx->ccid3hctx_x = min_t(u64, hctx->ccid3hctx_x_calc << 6,
+					       hctx->ccid3hctx_x_recv * 2  );
+		hctx->ccid3hctx_x = max_t(u64, hctx->ccid3hctx_x,
+					  (hctx->ccid3hctx_s << 6)/TFRC_T_MBI);
 
 	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) > 							  hctx->ccid3hctx_rtt) {
-		hctx->ccid3hctx_x = max(min(hctx->ccid3hctx_x_recv,
-					    hctx->ccid3hctx_x      ) * 2,
-					usecs_div(hctx->ccid3hctx_s,
-					       	  hctx->ccid3hctx_rtt)   );
+
+		hctx->ccid3hctx_x = max(2 * min(hctx->ccid3hctx_x,
+						hctx->ccid3hctx_x_recv),
+					scaled_div(hctx->ccid3hctx_s << 6,
+						   hctx->ccid3hctx_rtt    ));
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
@@ -194,13 +202,13 @@ static void ccid3_hc_tx_no_feedback_time
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
 		hctx->ccid3hctx_x = max_t(u32, hctx->ccid3hctx_x / 2,
-					       hctx->ccid3hctx_s / TFRC_T_MBI);
+					  (hctx->ccid3hctx_s << 6)/TFRC_T_MBI);
 
-		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %d "
+		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %u "
 			       "bytes/s\n",
 			       dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
-			       hctx->ccid3hctx_x);
+			       (unsigned)(hctx->ccid3hctx_x >> 6));
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
@@ -209,11 +217,11 @@ static void ccid3_hc_tx_no_feedback_time
 	case TFRC_SSTATE_FBACK:
 		/*
 		 * Check if IDLE since last timeout and recv rate is less than
-		 * 4 packets per RTT
+		 * 4 packets (in units of 64*bytes/sec) per RTT
 		 */
 		if (!hctx->ccid3hctx_idle ||
-		    (hctx->ccid3hctx_x_recv >-		     4 * usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_rtt))) {
+		    (hctx->ccid3hctx_x_recv >= 4 *
+		     scaled_div(hctx->ccid3hctx_s << 6, hctx->ccid3hctx_rtt))) {
 			struct timeval now;
 
 			ccid3_pr_debug("%s, sk=%p, state=%s, not idle\n",
@@ -227,17 +235,23 @@ static void ccid3_hc_tx_no_feedback_time
 			 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
 			 *  Else
 			 *    X_recv = X_calc / 4;
+			 *
+			 *  Note that X_recv is scaled by 2^6 while X_calc is not
 			 */
 			BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
 			if (hctx->ccid3hctx_p  = 0 ||
-			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)  {
-				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
-								    hctx->ccid3hctx_s / (2 * TFRC_T_MBI));
+			    hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))  {
+
+				hctx->ccid3hctx_x_recv +					max_t(u64, hctx->ccid3hctx_x_recv / 2,
+					      	  (hctx->ccid3hctx_s << 6) /
+					      			(2*TFRC_T_MBI));
+
 				if (hctx->ccid3hctx_p = 0)
 					dccp_timestamp(sk, &now);
 			} else
-				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc / 4;
+				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc << 4;
 
 			/* Now recalculate X [RFC 3448, 4.3, step (4)] */
 			ccid3_hc_tx_update_x(sk, &now);
@@ -315,9 +329,9 @@ static int ccid3_hc_tx_send_packet(struc
 		hctx->ccid3hctx_t_last_win_count = now;
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
-		/* Set initial sending rate to 1 packet per second */
+		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
 		ccid3_hc_tx_update_s(hctx, skb->len);
-		hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
+		hctx->ccid3hctx_x = hctx->ccid3hctx_s << 6;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
 		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
@@ -438,8 +452,8 @@ static void ccid3_hc_tx_packet_recv(stru
 			return;
 		}
 
-		/* Update receive rate */
-		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+		/* Update receive rate in units of 64 * bytes/second */
+		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate << 6;
 
 		/* Update loss event rate */
 		pinv = opt_recv->ccid3or_loss_event_rate;
@@ -475,12 +489,14 @@ static void ccid3_hc_tx_packet_recv(stru
 		 * q is a constant, RFC 3448 recomments 0.9
 		 */
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
-			/* Use Larger Initial Windows [RFC 4342, sec. 5]
-			 * We deviate in that we use `s' instead of `MSS'. */
+			/*
+			 * Larger Initial Windows [RFC 4342, sec. 5]
+			 * We deviate in that we use `s' instead of `MSS'.
+			 */
 			u16 w_init = min(    4 * hctx->ccid3hctx_s,
 					 max(2 * hctx->ccid3hctx_s, 4380));
 			hctx->ccid3hctx_rtt  = r_sample;
-			hctx->ccid3hctx_x    = usecs_div(w_init, r_sample);
+			hctx->ccid3hctx_x    = scaled_div(w_init<< 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_time(hctx);
@@ -488,7 +504,7 @@ static void ccid3_hc_tx_packet_recv(stru
 			ccid3_pr_debug("%s(%p), s=%u, w_init=%u, "
 				       "R_sample=%ldus, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s, w_init, r_sample,
-				       hctx->ccid3hctx_x);
+				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
@@ -508,7 +524,7 @@ static void ccid3_hc_tx_packet_recv(stru
 				       sk, hctx->ccid3hctx_rtt, r_sample,
 				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
 				       hctx->ccid3hctx_x_calc,
-				       hctx->ccid3hctx_x);
+				       (unsigned)(hctx->ccid3hctx_x >> 6));
 		}
 
 		/* unschedule no feedback timer */
