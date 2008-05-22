From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 22 May 2008 14:59:35 +0000
Subject: [DCCP] [CCID-3] [Patch 1/1]: Simplify (readability of) two complex
Message-Id: <20080522145935.GB18242@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an update of the test tree, two changesets which had previously
been sitting in different patches, both have now been given an explanation
of what is going on.  Test tree will be updated accordingly.

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
[CCID-3]: Simplify (readability of) two complex expressions

This simplifies the complex way in which two statements are written:

 (a) It simplifies the control flow of update_x in the following manner,
     where in addition the function call to `scaled_div()' was taken out
     of the max() macro to avoid multiple evaluation.

     The RFC 3448 control flow is (point (4) in section 4.3):

	If (p > 0)
		Calculate X_calc using the TCP throughput equation.
		X = max(min(X_calc, 2*X_recv), s/t_mbi);
	Else
		If (t_now - tld >= R)
			X = max(min(2*X, 2*X_recv), s/R);
			tld = t_now;

     In real life we must scale X by 2^6, to approximate the floating-point
     operations of RFC 3448. This makes most expressions very hard to read.

     So the patch introduces a new parameter low_thresh, which corresponds to
       * scaled s/t_mbi if p > 0;
       * scaled s/R     if p = 0 and if t_now - tld >= R.

     This parameter gives the case-dependent minimum value of X; the first is
     the requirement to send at least one packet per t_mbid seconds; the
     second ensures that at least one packet per RTT is sent during slow-start.

     Hence it is a general constraint, so that if X does not change in 
     subsequent calls to update_x(), we need not check if X is below the 
     minimum value. Only if X has changed as a result of entering either
     of the if/else cases above, do we need to check if it is below minimum.

     A similar idea is in the upcoming rfc3448bis, section 4.5 ("Reducing
     Oscillations"). This is a second point why the patch is needed: without
     separating the test of "X < minimum", it is not possible to add the
     "Preventing Oscillation" mechanism, whose use rfc3448bis recommends.

 (b) It replaces the statement

 	X_recv = max(X_recv / 2, s * 64 / (2 * TFRC_T_MBI))

     with the equivalent

      	X_recv = max(s * 64 / TFRC_T_MBI, X_recv) / 2

     by putting the common factor `1/2' outside the max().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   18 ++++++++++--------
 1 file changed, 10 insertions(+), 8 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -128,7 +128,8 @@ static u32 ccid3_hc_tx_idle_rtt(struct c
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	u64 min_rate = 2 * hctx->x_recv;
+	u64 min_rate = 2 * hctx->x_recv,
+	    low_thresh = ((u64)hctx->s) << 6;
 	const u64 old_x = hctx->x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
@@ -146,17 +147,19 @@ static void ccid3_hc_tx_update_x(struct 
 	if (hctx->p > 0) {
 
 		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
-		hctx->x = max(hctx->x, (((u64)hctx->s) << 6) / TFRC_T_MBI);
+		low_thresh /= TFRC_T_MBI;
 
 	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
 
-		hctx->x = min(2 * old_x, min_rate);
-		hctx->x = max(hctx->x, scaled_div(low_thresh, hctx->rtt));
-
+		hctx->x    = min(2 * old_x, min_rate);
+		low_thresh = scaled_div(low_thresh, hctx->rtt);
 		hctx->t_ld = now;
 	}
 
 	if (hctx->x != old_x) {
+		if (hctx->x < low_thresh)
+			hctx->x = low_thresh;
+
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
 			       (unsigned)(hctx->x >> 6), hctx->x_calc,
@@ -241,9 +244,8 @@ static void ccid3_hc_tx_no_feedback_time
 		BUG_ON(hctx->p && !hctx->x_calc);
 
 		if (hctx->x_calc > (hctx->x_recv >> 5))
-			hctx->x_recv -				max(hctx->x_recv / 2,
-				    (((__u64)hctx->s) << 6) / (2 * TFRC_T_MBI));
+			hctx->x_recv = max((((u64)hctx->s) << 6) / TFRC_T_MBI,
+					   hctx->x_recv) / 2;
 		else {
 			hctx->x_recv = hctx->x_calc;
 			hctx->x_recv <<= 4;
