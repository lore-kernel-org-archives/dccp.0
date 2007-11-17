From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:43 +0000
Subject: [PATCH 16/16] [CCID 3]: Nofeedback timer according to rfc3448bis
Message-Id: <1195291784711-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements the changes to the nofeedback timer handling suggested
in draft rfc3448bis00, section 4.4. In particular, these changes mean:

 * better handling of the lossless case (p = 0)
 * the timestamp for computing t_ld becomes obsolete
 * much more recent document (RFC 3448 is almost 5 years old)
 * concepts in rfc3448bis arose from a real, working implementation (cf. sec. 12)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid3.c |   63 ++++++++++++++++++++++--------------------------
 1 files changed, 29 insertions(+), 34 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c631c3b..b5f41f5 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -133,12 +133,11 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
  *
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
-
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
-	ktime_t now = stamp? *stamp : ktime_get_real();
+	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
@@ -232,27 +231,27 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 
-	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_NO_FBACK:
-		/* RFC 3448, 4.4: Halve send rate directly */
+	if (hctx->ccid3hctx_state = TFRC_SSTATE_FBACK)
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
+	else if (hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+		goto out;
+
+	/*
+	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
+	 */
+	if (hctx->ccid3hctx_t_rto = 0 ||	/* no feedback received yet */
+	    hctx->ccid3hctx_p = 0       ) {
+
+		/* halve send rate directly */
 		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x / 2,
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								    TFRC_T_MBI);
-
-		ccid3_pr_debug("%s(%p, state=%s), updated tx rate to %u "
-			       "bytes/s\n", dccp_role(sk), sk,
-			       ccid3_tx_state_name(hctx->ccid3hctx_state),
-			       (unsigned)(hctx->ccid3hctx_x >> 6));
-		/* The value of R is still undefined and so we can not recompute
-		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
-		t_nfb = TFRC_INITIAL_TIMEOUT;
 		ccid3_update_send_interval(hctx);
-		break;
-	case TFRC_SSTATE_FBACK:
+	} else {
 		/*
-		 *  Modify the cached value of X_recv [RFC 3448, 4.4]
+		 *  Modify the cached value of X_recv
 		 *
-		 *  If (p = 0 || X_calc > 2 * X_recv)
+		 *  If (X_calc > 2 * X_recv)
 		 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
 		 *  Else
 		 *    X_recv = X_calc / 4;
@@ -261,32 +260,28 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		 */
 		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
-		if (hctx->ccid3hctx_p = 0 ||
-		    (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))) {
-
+		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
 			hctx->ccid3hctx_x_recv  				max(hctx->ccid3hctx_x_recv / 2,
 				    (((__u64)hctx->ccid3hctx_s) << 6) /
 							      (2 * TFRC_T_MBI));
-		} else {
+		else {
 			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
 			hctx->ccid3hctx_x_recv <<= 4;
 		}
-		/* Now recalculate X [RFC 3448, 4.3, step (4)] */
 		ccid3_hc_tx_update_x(sk, NULL);
-		/*
-		 * Schedule no feedback timer to expire in
-		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
-		 * See comments in packet_recv() regarding the value of t_RTO.
-		 */
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
-		break;
-	case TFRC_SSTATE_NO_SENT:
-		DCCP_BUG("%s(%p) - Illegal state NO_SENT", dccp_role(sk), sk);
-		/* fall through */
-	case TFRC_SSTATE_TERM:
-		goto out;
 	}
+	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
+			(unsigned long long)hctx->ccid3hctx_x);
+
+	/*
+	 * Set new timeout for the nofeedback timer.
+	 * See comments in packet_recv() regarding the value of t_RTO.
+	 */
+	if (unlikely(hctx->ccid3hctx_t_rto = 0))	/* no feedback yet */
+		t_nfb = TFRC_INITIAL_TIMEOUT;
+	else
+		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-- 
1.5.2.2.238.g7cbf2f2-dirty

