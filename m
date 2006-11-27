From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 12:11:01 +0000
Subject: [PATCHv2 8/10] [UPDATE]: Larger initial windows
Message-Id: <200611271211.01961@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an update which improves on the previous version by 
 * doing the necessary adjustments in ccid3_hc_tx_packet_recv 
 * rather than in ccid3_update_x; thus reducing the numberof instructions.

Ian you acked the previous version - I haven't added an Acked-by line as
in the other patches (where provided), would be glad if you could have a look
at it.

----------------------> Commit Message <--------------------------------------
[CCID 3]: Larger initial windows

This implements the larger-initial-windows feature for CCID 3, as described
in section 5 of RFC 4342. When the first feedback packet arrives, the sender
can send up to 2..4 packets per RTT, instead of just one. 

The patch further
 * reduces the number of timestamping calls by passing the timestamp value
   (which is computed in one of the calling functions anyway) as argument

 * renames one constant with a very long name into one which is shorter and 
   resembles the one in RFC 3448 (t_mbi)

 * simplifies some of the min_t/max_t cases where both `x', `y' have the same
   type

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   66 +++++++++++++++++++++++++------------------------
 net/dccp/ccids/ccid3.h |    4 +-
 2 files changed, 37 insertions(+), 33 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -129,7 +129,8 @@ static inline void ccid3_update_send_tim
  * If X has changed, we also update the scheduled send time t_now,
  * the inter-packet interval t_ipi, and the delta value.
  */ 
-static void ccid3_hc_tx_update_x(struct sock *sk)
+static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
+
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const __u32 old_x = hctx->ccid3hctx_x;
@@ -141,23 +142,20 @@ static void ccid3_hc_tx_update_x(struct 
 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
 						     hctx->ccid3hctx_rtt,
 						     hctx->ccid3hctx_p);
-		hctx->ccid3hctx_x = max_t(u32, min_t(u32, hctx->ccid3hctx_x_calc,
-							  2 * hctx->ccid3hctx_x_recv),
-					       (hctx->ccid3hctx_s /
-					        TFRC_MAX_BACK_OFF_TIME));
-	} else {
-		struct timeval now;
+		hctx->ccid3hctx_x = max_t(u32, min(hctx->ccid3hctx_x_calc,
+						   hctx->ccid3hctx_x_recv * 2),
+					       hctx->ccid3hctx_s / TFRC_t_mbi );
+
+	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) >+							  hctx->ccid3hctx_rtt) {
+		hctx->ccid3hctx_x = max(min(hctx->ccid3hctx_x_recv,
+					    hctx->ccid3hctx_x      ) * 2,
+					usecs_div(hctx->ccid3hctx_s,
+					       	  hctx->ccid3hctx_rtt)   );
+		hctx->ccid3hctx_t_ld = *now;
+	} else
+		ccid3_pr_debug("Not changing X\n");
 
-		dccp_timestamp(sk, &now);
-	       	if (timeval_delta(&now, &hctx->ccid3hctx_t_ld) >-		    hctx->ccid3hctx_rtt) {
-			hctx->ccid3hctx_x = max_t(u32, min_t(u32, hctx->ccid3hctx_x_recv,
-								  hctx->ccid3hctx_x) * 2,
-						       usecs_div(hctx->ccid3hctx_s,
-							       	 hctx->ccid3hctx_rtt));
-			hctx->ccid3hctx_t_ld = now;
-		}
-	}
 	if(hctx->ccid3hctx_x != old_x)
 		ccid3_update_send_time(hctx);
 }
@@ -198,12 +196,9 @@ static void ccid3_hc_tx_no_feedback_time
 	
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
-		/* Halve send rate */
-		hctx->ccid3hctx_x /= 2;
-		if (hctx->ccid3hctx_x < (hctx->ccid3hctx_s /
-					 TFRC_MAX_BACK_OFF_TIME))
-			hctx->ccid3hctx_x = (hctx->ccid3hctx_s /
-					     TFRC_MAX_BACK_OFF_TIME);
+		/* RFC 3448, 4.4: Halve send rate directly */
+		hctx->ccid3hctx_x = min_t(u32, hctx->ccid3hctx_x / 2,
+					       hctx->ccid3hctx_s / TFRC_t_mbi);
 
 		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %d "
 			       "bytes/s\n",
@@ -223,6 +218,8 @@ static void ccid3_hc_tx_no_feedback_time
 		if (!hctx->ccid3hctx_idle ||
 		    (hctx->ccid3hctx_x_recv > 		     4 * usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_rtt))) {
+			struct timeval now;
+
 			ccid3_pr_debug("%s, sk=%p, state=%s, not idle\n",
 				       dccp_role(sk), sk,
 				       ccid3_tx_state_name(hctx->ccid3hctx_state));
@@ -240,12 +237,13 @@ static void ccid3_hc_tx_no_feedback_time
 			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P ||
 			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
 				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
-								    hctx->ccid3hctx_s / (2 * TFRC_MAX_BACK_OFF_TIME));
+								    hctx->ccid3hctx_s / (2 * TFRC_t_mbi));
 			else
 				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc / 4;
 
 			/* Update sending rate */
-			ccid3_hc_tx_update_x(sk);
+			dccp_timestamp(sk, &now);
+			ccid3_hc_tx_update_x(sk, &now);
 		}
 		/*
 		 * Schedule no feedback timer to expire in
@@ -489,11 +487,21 @@ static void ccid3_hc_tx_packet_recv(stru
 		 * q is a constant, RFC 3448 recomments 0.9
 		 */
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
+			/* Use Larger Initial Windows [RFC 4342, sec. 5]
+			 * We deviate in that we use `s' instead of `MSS'. */
+			u16 w_init = max(     4 * hctx->ccid3hctx_s,
+					 max( 2 * hctx->ccid3hctx_s, 4380));
+			hctx->ccid3hctx_rtt  = r_sample;
+			hctx->ccid3hctx_x    = usecs_div(w_init, r_sample);
+			hctx->ccid3hctx_t_ld = now;
+
+			ccid3_update_send_time(hctx);
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-			hctx->ccid3hctx_rtt = r_sample;
-		} else
+		} else {
 			hctx->ccid3hctx_rtt = (hctx->ccid3hctx_rtt * 9) / 10 +
 					      r_sample / 10;
+			ccid3_hc_tx_update_x(sk, &now);
+		}
 
 		ccid3_pr_debug("%s, sk=%p, New RTT estimate=%uus, "
 			       "r_sample=%us\n", dccp_role(sk), sk,
@@ -507,9 +515,6 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/* Update sending rate (and likely t_ipi, t_nom, and delta) */
-		ccid3_hc_tx_update_x(sk);
-
 		/* remove all packets older than the one acked from history */
 		dccp_tx_hist_purge_older(ccid3_tx_hist,
 					 &hctx->ccid3hctx_hist, packet);
@@ -519,7 +524,6 @@ static void ccid3_hc_tx_packet_recv(stru
 		 */
 		sk->sk_write_space(sk);
 
-
 		/* Update timeout interval. We use the alternative variant of
 		 * [RFC 3448, 3.1] which sets the upper bound of t_rto to one
 		 * second, as it is suggested for TCP (see RFC 2988, 2.4). */
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -48,8 +48,8 @@
 /* In usecs - half the scheduling granularity as per RFC3448 4.6 */
 #define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
 
-/* In seconds */
-#define TFRC_MAX_BACK_OFF_TIME	   64
+/* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
+#define TFRC_t_mbi		   64
 
 #define TFRC_SMALLEST_P		   40
 
