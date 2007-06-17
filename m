From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:54:10 +0000
Subject: [PATCH 7/9]: Let calling module compute First Loss Interval; convert to ktime_t
Message-Id: <200706171354.10827@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Let calling module compute First Loss Interval; convert to ktime_t

TFRC [RFC 3448] requires a synthetic value of the first loss interval length.
Since computing this value requires access to the internals of the calling 
module (parameters s, RTT, and X_recv), it is better to let the calling module
compute the First Loss Interval length.

Therefore, to highlight this, the function has been renamed into
`ccid3_first_li' (due to a max line length of 80 characters); the code has
been arranged and comments tidied up, but no functional change results.

Secondly, the patch implements the remaining changes to support the newer
timeofday/ktime_t interface (reduces to a one-liner).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   34 +++++++++++-----------------------
 1 file changed, 11 insertions(+), 23 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -730,39 +730,27 @@ static int ccid3_hc_rx_insert_options(st
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
-	u32 x_recv, p;
-	suseconds_t delta;
-	struct timeval tstamp;
+	u32 x_recv, p, delta;
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
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
 		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
 	}
-/* XXX this also has a forward dependency, which is resolved in the patch
- *     that does receiver RTT sampling. The problem with the code below is
- *     that it still used the old, struct timeval based, interface, and that
- *     the name of the variable `_last_feedback' is not yet adjusted.
-	dccp_timestamp(sk, &tstamp);
-	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
-	DCCP_BUG_ON(delta <= 0);
-*/
 
+	delta = ktime_to_us(net_timedelta(hcrx->ccid3hcrx_last_feedback));
 	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
