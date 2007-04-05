From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:35:12 +0000
Subject: [PATCH 21/43]: Let calling module compute First Loss Interval
Message-Id: <200704051635.12467@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Let calling module compute First Loss Interval

TFRC [RFC 3448] requires a synthetic value of the first loss interval length.
Since computing this value requires access to the internals of the calling 
module (parameters s, RTT, and X_recv), it is better to let the calling module
compute the First Loss Interval length.

Therefore, to highlight this, the function has been renamed into
`ccid3_first_li' (due to a max line length of 80 characters); the code has
been arranged and comments tidied up, but no functional change results.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   23 ++++++++++-------------
 1 file changed, 10 insertions(+), 13 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -812,11 +812,16 @@ static int ccid3_hc_rx_insert_options(st
 	return 0;
 }
 
-/* calculate first loss interval
+/** ccid3_first_li  -  Implements [RFC 3448, 6.3.1]
  *
- * returns estimated loss interval in usecs */
-
-static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
+ * Determine the length of the first loss interval via inverse lookup.
+ * Assume that X_recv can be computed by the throughput equation
+ *		    s
+ *	X_recv = --------
+ *		 R * fval
+ * Find some p such that f(p) = fval; return 1/p (scaled).
+ */
+static u32 ccid3_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	u32 x_recv, p;
@@ -824,14 +829,6 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	struct timeval tstamp;
 	u64 fval;
 
-	/*
-	 * Determine the length of the first loss interval via inverse lookup.
-	 * Assume that X_recv can be computed by the throughput equation
-	 *		    s
-	 *	X_recv = --------
-	 *		 R * fval
-	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
-	 */
 	if (hcrx->ccid3hcrx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using 0.2sec fallback\n");
 		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
@@ -842,7 +839,7 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	DCCP_BUG_ON(delta <= 0);
 
 	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
-	if (x_recv = 0) {		/* would also trigger divide-by-zero */
+	if (x_recv = 0) {
 		DCCP_WARN("X_recv=0\n");
 		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
