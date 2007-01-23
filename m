From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:40:46 +0000
Subject: [PATCHv2 1/7]: Remove build warnings
Message-Id: <200701231540.46450@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Remove build warnings

This 
 1) Clears the following sparc64 build warning:
    warning: format "%ld" expects type "long int", but argument 3 has type "suseconds_t"

 2) Makes the use of "%llu" consistent for all u64/__u64 datatypes.
    Thanks to Ian McDonald for this.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -139,8 +139,10 @@ static void ccid3_hc_tx_update_x(struct 
 
 	if (hctx->ccid3hctx_x != old_x) {
 		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
-			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
-			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
+			       "X_recv=%llu\n",
+			       old_x >> 6, hctx->ccid3hctx_x >> 6,
+			       hctx->ccid3hctx_x_calc,
+			       hctx->ccid3hctx_x_recv >> 6);
 
 		ccid3_update_send_interval(hctx);
 	}
@@ -212,10 +214,10 @@ static void ccid3_hc_tx_no_feedback_time
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								    TFRC_T_MBI);
 
-		ccid3_pr_debug("%s(%p, state=%s), updated tx rate to %u "
+		ccid3_pr_debug("%s(%p, state=%s), updated tx rate to %llu "
 			       "bytes/s\n", dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
-			       (unsigned)(hctx->ccid3hctx_x >> 6));
+			       hctx->ccid3hctx_x >> 6);
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
@@ -478,11 +480,11 @@ static void ccid3_hc_tx_packet_recv(stru
 			ccid3_update_send_interval(hctx);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
-				       "R_sample=%dus, X=%u\n", dccp_role(sk),
+				       "R_sample=%dus, X=%llu\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s,
 				       dp->dccps_mss_cache, w_init,
 				       (int)r_sample,
-				       (unsigned)(hctx->ccid3hctx_x >> 6));
+				       hctx->ccid3hctx_x >> 6);
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
@@ -498,13 +500,13 @@ static void ccid3_hc_tx_packet_recv(stru
 			ccid3_hc_tx_update_x(sk, &now);
 
 			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%dus), s=%u, "
-				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
+				       "p=%u, X_calc=%u, X_recv=%llu, X=%llu\n",
 				       dccp_role(sk),
 				       sk, hctx->ccid3hctx_rtt, (int)r_sample,
 				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
 				       hctx->ccid3hctx_x_calc,
-				       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-				       (unsigned)(hctx->ccid3hctx_x >> 6));
+				       hctx->ccid3hctx_x_recv >> 6,
+				       hctx->ccid3hctx_x >> 6);
 		}
 
 		/* unschedule no feedback timer */
@@ -897,7 +899,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		DCCP_BUG_ON(r_sample < 0);
 		if (unlikely(r_sample <= t_elapsed))
 			DCCP_WARN("r_sample=%ldus, t_elapsed=%ldus\n",
-				  r_sample, t_elapsed);
+				  (long)r_sample, (long)t_elapsed);
 		else
 			r_sample -= t_elapsed;
 		CCID3_RTT_SANITY_CHECK(r_sample);
