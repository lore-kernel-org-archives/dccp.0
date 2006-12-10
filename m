From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:04:06 +0000
Subject: [PATCH 22/22] [DCCP] ccid3: BUG-FIX - conversion errors
Message-Id: <20061210030405.GX17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes conversion errors which arose by not properly type-casting
from u32 to __u64. Fixed by explicitly casting each type which is not
__u64, or by performing operation after assignment.

The patch further adds missing debug information to track the current
value of X_recv.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   54 +++++++++++++++++++++++++++---------------------
 1 files changed, 30 insertions(+), 24 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index d23af7b..6bc77ff 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -123,18 +123,19 @@ static void ccid3_hc_tx_update_x(struct 
 
 	if (hctx->ccid3hctx_p > 0) {
 
-		hctx->ccid3hctx_x = min_t(u64, hctx->ccid3hctx_x_calc << 6,
-					       hctx->ccid3hctx_x_recv * 2  );
-		hctx->ccid3hctx_x = max_t(u64, hctx->ccid3hctx_x,
-					  (hctx->ccid3hctx_s << 6)/TFRC_T_MBI);
+		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
+					hctx->ccid3hctx_x_recv * 2           );
+		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
+					(((__u64)hctx->ccid3hctx_s) << 6) /
+					 			   TFRC_T_MBI);
 
 	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) -
 			(suseconds_t)hctx->ccid3hctx_rtt >= 0 ) {
 
-		hctx->ccid3hctx_x = max(2 * min(hctx->ccid3hctx_x,
-						hctx->ccid3hctx_x_recv),
-					scaled_div(hctx->ccid3hctx_s << 6,
-						   hctx->ccid3hctx_rtt    ));
+		hctx->ccid3hctx_x +			max(2 * min(hctx->ccid3hctx_x, hctx->ccid3hctx_x_recv),
+			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
+				       hctx->ccid3hctx_rtt             )      );
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
@@ -207,8 +208,9 @@ static void ccid3_hc_tx_no_feedback_time
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
-		hctx->ccid3hctx_x = max_t(u32, hctx->ccid3hctx_x / 2,
-					  (hctx->ccid3hctx_s << 6)/TFRC_T_MBI);
+		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x / 2,
+					(((__u64)hctx->ccid3hctx_s) << 6) /
+								    TFRC_T_MBI);
 
 		ccid3_pr_debug("%s(%p, state=%s), updated tx rate to %u "
 			       "bytes/s\n", dccp_role(sk), sk,
@@ -226,7 +228,7 @@ static void ccid3_hc_tx_no_feedback_time
 		 */
 		if (!hctx->ccid3hctx_idle ||
 		    (hctx->ccid3hctx_x_recv >= 4 *
-		     scaled_div(hctx->ccid3hctx_s << 6, hctx->ccid3hctx_rtt))) {
+		     scaled_div(((__u64)hctx->ccid3hctx_s) << 6, hctx->ccid3hctx_rtt))) {
 			struct timeval now;
 
 			ccid3_pr_debug("%s(%p, state=%s), not idle\n",
@@ -249,15 +251,16 @@ static void ccid3_hc_tx_no_feedback_time
 			    hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))  {
 
 				hctx->ccid3hctx_x_recv -					max_t(u64, hctx->ccid3hctx_x_recv / 2,
-					      	  (hctx->ccid3hctx_s << 6) /
+					max(hctx->ccid3hctx_x_recv / 2,
+					    (((__u64)hctx->ccid3hctx_s) << 6) /
 					      			(2*TFRC_T_MBI));
 
 				if (hctx->ccid3hctx_p = 0)
 					dccp_timestamp(sk, &now);
-			} else
-				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc << 4;
-
+			} else {
+				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
+				hctx->ccid3hctx_x_recv <<= 4;
+			}
 			/* Now recalculate X [RFC 3448, 4.3, step (4)] */
 			ccid3_hc_tx_update_x(sk, &now);
 		}
@@ -320,7 +323,8 @@ static int ccid3_hc_tx_send_packet(struc
 
 		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
 		ccid3_hc_tx_update_s(hctx, skb->len);
-		hctx->ccid3hctx_x = hctx->ccid3hctx_s << 6;
+		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
+		hctx->ccid3hctx_x <<= 6;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
 		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
@@ -421,7 +425,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		}
 
 		/* Update receive rate in units of 64 * bytes/second */
-		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate << 6;
+		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+		hctx->ccid3hctx_x_recv <<= 6;
 
 		/* Update loss event rate */
 		pinv = opt_recv->ccid3or_loss_event_rate;
@@ -460,15 +465,15 @@ static void ccid3_hc_tx_packet_recv(stru
 			 * Larger Initial Windows [RFC 4342, sec. 5]
 			 * We deviate in that we use `s' instead of `MSS'.
 			 */
-			u16 w_init = min(    4 * hctx->ccid3hctx_s,
-					 max(2 * hctx->ccid3hctx_s, 4380));
+			__u64 w_init = min(    4 * hctx->ccid3hctx_s,
+					   max(2 * hctx->ccid3hctx_s, 4380));
 			hctx->ccid3hctx_rtt  = r_sample;
-			hctx->ccid3hctx_x    = scaled_div(w_init<< 6, r_sample);
+			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_time(hctx);
 
-			ccid3_pr_debug("%s(%p), s=%u, w_init=%u, "
+			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
 				       "R_sample=%ldus, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s, w_init, r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
@@ -487,11 +492,12 @@ static void ccid3_hc_tx_packet_recv(stru
 			ccid3_hc_tx_update_x(sk, &now);
 
 			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%ldus), s=%u, "
-				       "p=%u, X_calc=%u, X=%u\n", dccp_role(sk),
+				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_rtt, r_sample,
 				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
 				       hctx->ccid3hctx_x_calc,
-				       (unsigned)(hctx->ccid3hctx_x >> 6));
+				       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
+				       (unsigned)(hctx->ccid3hctx_x >> 6)     );
 		}
 
 		/* unschedule no feedback timer */
-- 
1.4.2.1.g3d5c

