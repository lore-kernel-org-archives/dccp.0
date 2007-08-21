From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Aug 2007 06:55:17 +0000
Subject: [PATCH 1/1]: Reuse ktime_get_real() calls again
Message-Id: <200708210755.17774@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP] Reuse ktime_get_real() calls again

This patch reduces the number of timestamps taken in the receive path
for each packet, following a suggestion by Arnaldo in his recent patch set.

The ccid3_hc_tx_update_x() routine is called in
 * the receive path for each CCID3-controlled packet
 * for the nofeedback timer (if no feedback arrives during 4 RTT)

Currently, when there is no loss, each packet gets timestamped twice.
The patch resolves this by recycling the first timestamp taken on packet
reception for RTT sampling.

When the no_feedback_timer() is called, then the timestamp argument is
simply set to NULL - so that ccid3_hc_tx_update_x() takes care of the logic.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   39 ++++++++++++++++-----------------------
 1 file changed, 16 insertions(+), 23 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -113,27 +113,24 @@ static inline void ccid3_update_send_int
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
-static void ccid3_hc_tx_update_x(struct sock *sk)
+static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
+	ktime_t now = stamp? *stamp : ktime_get_real();
 
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
@@ -153,18 +150,14 @@ static void ccid3_hc_tx_update_x(struct 
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								TFRC_T_MBI);
 
-	} else {
-		const ktime_t now = ktime_get_real();
-
-		if ((ktime_us_delta(now, hctx->ccid3hctx_t_ld) -
-		     (s64)hctx->ccid3hctx_rtt) >= 0) {
+	} else if (ktime_us_delta(now, hctx->ccid3hctx_t_ld)
+				- (s64)hctx->ccid3hctx_rtt >= 0) {
 
-			hctx->ccid3hctx_x -				max(min(2 * hctx->ccid3hctx_x, min_rate),
-				    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-					       hctx->ccid3hctx_rtt));
-			hctx->ccid3hctx_t_ld = now;
-		}
+		hctx->ccid3hctx_x +			max(min(2 * hctx->ccid3hctx_x, min_rate),
+			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
+				       hctx->ccid3hctx_rtt));
+		hctx->ccid3hctx_t_ld = now;
 	}
 
 	if (hctx->ccid3hctx_x != old_x) {
@@ -273,7 +266,7 @@ static void ccid3_hc_tx_no_feedback_time
 			hctx->ccid3hctx_x_recv <<= 4;
 		}
 		/* Now recalculate X [RFC 3448, 4.3, step (4)] */
-		ccid3_hc_tx_update_x(sk);
+		ccid3_hc_tx_update_x(sk, NULL);
 		/*
 		 * Schedule no feedback timer to expire in
 		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
@@ -493,7 +486,7 @@ static void ccid3_hc_tx_packet_recv(stru
 					tfrc_calc_x(hctx->ccid3hctx_s,
 						    hctx->ccid3hctx_rtt,
 						    hctx->ccid3hctx_p);
-			ccid3_hc_tx_update_x(sk);
+			ccid3_hc_tx_update_x(sk, &now);
 
 			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
