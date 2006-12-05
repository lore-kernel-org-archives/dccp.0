From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:38:43 +0000
Subject: [PATCH 6/7]: Simplify calculation for reverse lookup of p
Message-Id: <200612052038.43708@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Simplify calculation for reverse lookup of p

 This simplifies the calculation of a value p for a given fval when the
 first loss interval is computed (RFC 3448, 6.3.1). It makes use of the
 two new functions scaled_div/scaled_div32 to provide overflow protection.

 Additionally, protection against divide-by-zero is extended - in this
 case the function will return the maximally possible value of p0%.

Background:
-----------
 The maximum fval, f(100%), is approximately 244, i.e. the scaled value of fval 
 should never exceed 244E6, which fits easily into u32. The problem is the scaling
 by 10^6, since additionally R(TT) is in microseconds.
 This is resolved by breaking the division into two stages: the first stage
 computes fval=(s*10^6)/R, stores that into u64; the second stage computes
 fval = (fval*10^6)/X_recv and complains if overflow is reached for u32. 
 This case is safe since the TFRC reverse-lookup routine then returns p0%. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |   39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -785,12 +785,12 @@ static u32 ccid3_hc_rx_calc_first_li(str
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
-	u32 rtt, delta, x_recv, fval, p, tmp2;
+	u32 rtt, delta, x_recv, p;
 	struct timeval tstamp = { 0, };
 	int interval = 0;
 	int win_count = 0;
 	int step = 0;
-	u64 tmp1;
+	u64 fval;
 
 	list_for_each_entry_safe(entry, next, &hcrx->ccid3hcrx_hist,
 				 dccphrx_node) {
@@ -834,30 +834,35 @@ found:
 	ccid3_pr_debug("%s, sk=%p, approximated RTT to %uus\n",
 		       dccp_role(sk), sk, rtt);
 
-	if (rtt = 0) {
-		DCCP_WARN("RTT=0, setting to 1\n");
- 		rtt = 1;
+	/*
+	 * Determine the length of the first loss interval via inverse lookup.
+	 * Assume that X_recv can be computed by the throughput equation
+	 *      	    s
+	 * 	X_recv = --------
+	 * 		 R * fval
+	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
+	 */
+	if (rtt = 0) {			/* would result in divide-by-zero */
+		DCCP_WARN("RTT=0, returning 1/p = 1\n");
+		return 1000000;
 	}
 
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
 	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 
-	if (x_recv = 0)
-		x_recv = hcrx->ccid3hcrx_x_recv;
-
-	tmp1 = (u64)x_recv * (u64)rtt;
-	do_div(tmp1,10000000);
-	tmp2 = (u32)tmp1;
-
-	if (!tmp2) {
-		DCCP_CRIT("tmp2 = 0, x_recv = %u, rtt =%u\n", x_recv, rtt);
-		return ~0;
+	if (x_recv = 0) {		/* would also trigger divide-by-zero */
+		DCCP_WARN("X_recv=0\n");
+		if((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+			DCCP_BUG("stored value of X_recv is zero");
+			return 1000000;
+		}
 	}
 
-	fval = (hcrx->ccid3hcrx_s * 100000) / tmp2;
-	/* do not alter order above or you will get overflow on 32 bit */
+	fval = scaled_div(hcrx->ccid3hcrx_s, rtt);
+	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
+
 	ccid3_pr_debug("%s, sk=%p, receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
