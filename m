From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:33:09 +0000
Subject: [PATCH 3/3]: Update computation of X to use newer timeofday interface
Message-Id: <200706091933.09514@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Update computation of X to use newer timeofday interface

This updates the timestamping references in the computation of X to the newer
ktime_t interface. The time-last-doubled t_ld is now also upgraded to ktime_t;
furthermore up-to-date comments were added to ccid3_hc_tx_update_x().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   23 ++++++++++-------------
 net/dccp/ccids/ccid3.h |    2 +-
 2 files changed, 11 insertions(+), 14 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -110,7 +110,7 @@ struct ccid3_hc_tx_sock {
 	u8				ccid3hctx_idle;
 	ktime_t				ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
-	struct timeval			ccid3hctx_t_ld;
+	ktime_t				ccid3hctx_t_ld;
 	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
 	struct list_head		ccid3hctx_hist;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -114,27 +114,24 @@ static inline void ccid3_update_send_int
 		       hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
 
 }
-/*
- * Update X by
- *    If (p > 0)
- *       X_calc = calcX(s, R, p);
- *       X = max(min(X_calc, 2 * X_recv), s / t_mbi);
- *    Else
- *       If (now - tld >= R)
- *          X = max(min(2 * X, 2 * X_recv), s / R);
- *          tld = now;
+
+/**
+ * ccid3_hc_tx_update_x  -  Update allowed sending rate X
+ * @stamp: most recent time if available - can be left NULL.
+ * This function tracks draft rfc3448bis, check there for latest details.
  *
  * Note: X and X_recv are both stored in units of 64 * bytes/second, to support
  *       fine-grained resolution of sending rates. This requires scaling by 2^6
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
  *
  */
-static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
+static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
+	ktime_t now = stamp? *stamp : ktime_get_real();
 
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
@@ -154,14 +151,14 @@ static void ccid3_hc_tx_update_x(struct 
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								TFRC_T_MBI);
 
-	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) -
-			(suseconds_t)hctx->ccid3hctx_rtt >= 0) {
+	} else if (ktime_delta(now, hctx->ccid3hctx_t_ld)
+				- (s64)hctx->ccid3hctx_rtt >= 0) {
 
 		hctx->ccid3hctx_x  			max(min(2 * hctx->ccid3hctx_x, min_rate),
 			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
 				       hctx->ccid3hctx_rtt));
-		hctx->ccid3hctx_t_ld = *now;
+		hctx->ccid3hctx_t_ld = now;
 	}
 
 	if (hctx->ccid3hctx_x != old_x) {
