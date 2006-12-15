From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:51:17 +0000
Subject: [PATCH 8/8]: Truly larger initial windows
Message-Id: <200612151051.17489@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Use MSS for larger initial windows

This improves the slow-start phase by using the MSS
(as suggested in RFC 4342, sec. 5) instead of the packet size s.
Also figured out that __u32 is ample resource enough.

After applying, I got the following in the logs:

  ccid3_hc_tx_packet_recv: client(f7421700), s=6, MSS24, w_initC80, R_sample6us, X$886363

Had the previous variant been used, w_init would have been as low as 24.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -459,19 +459,19 @@ static void ccid3_hc_tx_packet_recv(stru
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
 			/*
 			 * Larger Initial Windows [RFC 4342, sec. 5]
-			 * We deviate in that we use `s' instead of `MSS'.
 			 */
-			__u64 w_init = min(4 * hctx->ccid3hctx_s,
-					   max(2 * hctx->ccid3hctx_s, 4380));
+			__u32 w_init = min(4 * dp->dccps_mss_cache,
+					   max(2 * dp->dccps_mss_cache, 4380U));
 			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_time(hctx);
 
-			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
+			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_s, w_init,
+				       sk, hctx->ccid3hctx_s,
+				       dp->dccps_mss_cache, w_init,
 				       (int)r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
