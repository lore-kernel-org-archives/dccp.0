From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 18:49:59 +0000
Subject: [PATCH 2/3]: Avoid masking of low-resolution errors
Message-Id: <200611271849.59609@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Avoid masking of low-resolution errors

 This patch makes handling of all TFRC table lookup resolution errors local
 to the TFRC library and removes such checks/warnings from calling code. 

 A warning message is printed out whenever the value of `p' is so small that
 it falls below the resolution of the lookup table. 


Justification: 
--------------
 The TFRC code uses a lookup table which has a bounded resolution.
 The lowest possible value of the loss event rate `p' which can be
 resolved is currently 0.0001.  Substituting this lower threshold for
 p when p is less than 0.0001 results in a huge, exponentially-growing
 error.  Currently the solution is to use an (arbitrary) value
     TFRC_SMALLEST_P  =   40 * 1E-6   =   0.00004
 and to consider all values below this value as `virtually zero'.  Due to
 the exponentially growing resolution error, this is not a good idea, since
 it hides the fact that the table can not resolve practically occurring cases.
 Furthermore, at p = TFRC_SMALLEST_P, the error is still as large as 58.1%!

 The first half to resolve this problem has been implemented in the previous patch,
 which will print warning messages whenever p is less than the given minimal resolution.
 If such messages are observed, it is a better solution to take this as an indication
 that the lookup table needs to be re-engineered (which is trivial to do, the table
 can be computed using a tiny C program).

Detailed Changelog:
-------------------
 This patch therefore completes the protection against masking table-lookup resolution
 errors by 
   * not substituting 0 if the value can not be resolved
   * not using an arbitrary threshold such as TFRC_SMALLEST_P
   * makes handling all TFRC resolution errors local to the TFRC library
   * removes unnecessary test whether X_calc is 'infinity' due to p=0 -- this condition
     is already caught by tfrc_calc_x() 
   * remove setting ccid3hctx_p = TFRC_SMALLEST_P in ccid3_hc_tx_packet_recv since this
     is now done by the TFRC library
   * updated BUG_ON test in ccid3_hc_tx_no_feedback_timer to take into account that p now
     is either 0 (and then X_calc is irrelevant), or it is > 0; since the handling of
     TFRC_SMALLEST_P is now taken care of in the tfrc library
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   18 ++++--------------
 net/dccp/ccids/ccid3.h |    2 --
 2 files changed, 4 insertions(+), 16 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -137,8 +137,7 @@ static void ccid3_hc_tx_update_x(struct 
 
 	DCCP_BUG_ON(hctx->ccid3hctx_rtt = 0);
 
-	/* To avoid large error in calcX */
-	if (hctx->ccid3hctx_p >= TFRC_SMALLEST_P) {
+	if (hctx->ccid3hctx_p > 0) {
 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
 						     hctx->ccid3hctx_rtt,
 						     hctx->ccid3hctx_p);
@@ -230,12 +229,10 @@ static void ccid3_hc_tx_no_feedback_time
 			 *  Else
 			 *    X_recv = X_calc / 4;
 			 */
-			BUG_ON(hctx->ccid3hctx_p >= TFRC_SMALLEST_P &&
+			BUG_ON(hctx->ccid3hctx_p > 0 &&
 			       hctx->ccid3hctx_x_calc = 0);
 
-			/* check also if p is zero -> x_calc is infinity? */
-			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P ||
-			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
+			if (hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
 				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
 								    hctx->ccid3hctx_s / (2 * TFRC_t_mbi));
 			else
@@ -457,16 +454,9 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* Update loss event rate */
 		if (pinv = ~0 || pinv = 0)
 			hctx->ccid3hctx_p = 0;
-		else {
+		else
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P) {
-				hctx->ccid3hctx_p = TFRC_SMALLEST_P;
-				ccid3_pr_debug("%s, sk=%p, Smallest p used!\n",
-					       dccp_role(sk), sk);
-			}
-		}
-
 		/* Calculate new round trip sample by
 		 * 	R_sample = (t_now - t_recvdata) - t_delay
 		 * t_recvdata is taken from packet history        */
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -51,8 +51,6 @@
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_t_mbi		   64
 
-#define TFRC_SMALLEST_P		   40
-
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
