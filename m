From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 18:27:15 +0000
Subject: [PATCH 7/8]: Deprecate TFRC_SMALLEST_P
Message-Id: <200612011827.15505@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Deprecate TFRC_SMALLEST_P

 This patch deprecates the existing use of an arbitrary value TFRC_SMALLEST_P for
 low-threshold values of p. This avoids masking low-resolution errors. Instead,
 the code now checks against real boundaries (implemented by preceding patch)
 and provides warnings whenever a real value falls below the threshold.
 
 If such messages are observed, it is a better solution to take this as an 
 indication that the lookup table needs to be re-engineered.

Changelog:
----------
 This patch 
   * makes handling all TFRC resolution errors local to the TFRC library
   * removes unnecessary test whether X_calc is 'infinity' due to p=0 -- this condition
     is already caught by tfrc_calc_x() 
   * removes setting ccid3hctx_p = TFRC_SMALLEST_P in ccid3_hc_tx_packet_recv since this
     is now done by the TFRC library
   * updates BUG_ON test in ccid3_hc_tx_no_feedback_timer to take into account that p now
     is either 0 (and then X_calc is irrelevant), or it is > 0; since the handling of
     TFRC_SMALLEST_P is now taken care of in the tfrc library

Justification: 
--------------
 The TFRC code uses a lookup table which has a bounded resolution.
 The lowest possible value of the loss event rate `p' which can be
 resolved is currently 0.0001.  Substituting this lower threshold for
 p when p is less than 0.0001 results in a huge, exponentially-growing
 error.  The error can be computed by the following formula:

    (f(0.0001) - f(p))/f(p) * 100      for p < 0.0001
 
 Currently the solution is to use an (arbitrary) value
     TFRC_SMALLEST_P  =   40 * 1E-6   =   0.00004
 and to consider all values below this value as `virtually zero'.  Due to
 the exponentially growing resolution error, this is not a good idea, since
 it hides the fact that the table can not resolve practically occurring cases.
 Already at p = TFRC_SMALLEST_P, the error is as high as 58.19%!

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   21 +++++----------------
 net/dccp/ccids/ccid3.h |    2 --
 2 files changed, 5 insertions(+), 18 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -137,8 +137,7 @@ static void ccid3_hc_tx_update_x(struct 
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const __u32 old_x = hctx->ccid3hctx_x;
 
-	/* To avoid large error in calcX */
-	if (hctx->ccid3hctx_p >= TFRC_SMALLEST_P) {
+	if (hctx->ccid3hctx_p > 0) {
 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
 						     hctx->ccid3hctx_rtt,
 						     hctx->ccid3hctx_p);
@@ -231,12 +230,9 @@ static void ccid3_hc_tx_no_feedback_time
 			 *  Else
 			 *    X_recv = X_calc / 4;
 			 */
-			BUG_ON(hctx->ccid3hctx_p >= TFRC_SMALLEST_P &&
-			       hctx->ccid3hctx_x_calc = 0);
+			BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
-			/* check also if p is zero -> x_calc is infinity? */
-			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P ||
-			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
+			if (hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
 				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
 								    hctx->ccid3hctx_s / (2 * TFRC_T_MBI));
 			else
@@ -449,15 +445,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		pinv = opt_recv->ccid3or_loss_event_rate;
 		if (pinv = ~0U || pinv = 0)
 			hctx->ccid3hctx_p = 0;
-		else {
-			hctx->ccid3hctx_p = 1000000 / pinv;
-
-			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P) {
-				hctx->ccid3hctx_p = TFRC_SMALLEST_P;
-				ccid3_pr_debug("%s, sk=%p, Smallest p used!\n",
-					       dccp_role(sk), sk);
-			}
-		}
+		else
+ 			hctx->ccid3hctx_p = 1000000 / pinv;
 
 		dccp_timestamp(sk, &now);
 
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -51,8 +51,6 @@
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_T_MBI		   64
 
-#define TFRC_SMALLEST_P		   40
-
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
