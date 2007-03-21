From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:45:09 +0000
Subject: [PATCH 13/25]: Nofeedback timer according to rfc3448bis
Message-Id: <200703211845.10080@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Nofeedback timer according to rfc3448bis

This implements the changes to the nofeedback timer handling suggested
in draft rfc3448bis, section 4.4. In particular, these changes mean:

 * better handling of the lossless case (p = 0)
 * the timestamp for computing t_ld becomes obsolete
 * much more recent document (RFC 34484 is 4 years old)
 * concepts in rfc3448bis arose from a real, working implementation (cf. sec. 12)

 Further Changes:
 ----------------
 1. The CCID 3 state now changes from FBACK back to NO_FBACK when the nofeedback timer
    expires - this is required for updating X when feedback is received (cf. draft 
    rfc3448bis, 4.2); this better reflects that no feedback was heard since the time has 
    been started; the corresponding support for X is implemented in subsequent patch.
 2. Two more irrelevant states are removed (as in earlier patch for packet_sent): 
     o TFRC_SSTATE_NO_SENT (logically not possible), and 
     o TFRC_SSTATE_TERM    (irrelevant, since terminating anyway).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   48 ++++++++++++++++++++----------------------------
 1 file changed, 20 insertions(+), 28 deletions(-)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -220,7 +220,6 @@ static void ccid3_hc_tx_no_feedback_time
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct timeval now;
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -233,24 +232,27 @@ static void ccid3_hc_tx_no_feedback_time
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
+	 * Determine new allowed sending rate X as per draft rfc3448bis, 4.4
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
@@ -259,29 +261,19 @@ static void ccid3_hc_tx_no_feedback_time
 		 */
 		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
-		if (hctx->ccid3hctx_p = 0 ||
-		    (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))) {
-
+		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
 			hctx->ccid3hctx_x_recv  				max(hctx->ccid3hctx_x_recv / 2,
 				    (((__u64)hctx->ccid3hctx_s) << 6) /
 							      (2 * TFRC_T_MBI));
-
-			if (hctx->ccid3hctx_p = 0)
-				do_gettimeofday(&now);
-		} else {
+		else {
 			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
 			hctx->ccid3hctx_x_recv <<= 4;
 		}
-		/* Now recalculate X [RFC 3448, 4.3, step (4)] */
-		ccid3_hc_tx_update_x(sk, &now);
-		break;
-	case TFRC_SSTATE_NO_SENT:
-		DCCP_BUG("%s(%p) - Illegal state NO_SENT", dccp_role(sk), sk);
-		/* fall through */
-	case TFRC_SSTATE_TERM:
-		goto out;
+		ccid3_hc_tx_update_x(sk, NULL);		/* p > 0 */
 	}
+	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
+			(unsigned long long)hctx->ccid3hctx_x);
 
 	hctx->ccid3hctx_idle = 1;
 
