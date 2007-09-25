From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 10:03:00 +0000
Subject: [PATCH v2 1/1][UPDATE]: [CCID2]: Remove redundant BUG_ON
Message-Id: <200709251103.00966@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a resubmission for the test tree, the change to version 2 is that
ssthresh has, after cwnd, also been converted to u32; which suggested itself
since there are many operations and comparisons between these two variables.


-----------------------------> Patch v2 <-----------------------------------
[CCID2]: Remove redundant BUG_ON

This removes a test for `val < 1' which would only have been triggered
when val < 0, due to a preceding test for 0. 
Fixed by using an unsigned type for cwnd (as in TCP) instead. 
Since ssthresh derives from cwnd and appears in assignments and comparisons,
the type of ssthresh was changed to matched that of cwnd.      

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   15 +++++----------
 net/dccp/ccids/ccid2.h |    4 ++--
 2 files changed, 7 insertions(+), 12 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -179,16 +179,11 @@ static void ccid2_change_l_ack_ratio(str
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, int val)
+static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, u32 val)
 {
-	if (val = 0)
-		val = 1;
-
 	/* XXX do we need to change ack ratio? */
-	ccid2_pr_debug("change cwnd to %d\n", val);
-
-	BUG_ON(val < 1);
-	hctx->ccid2hctx_cwnd = val;
+	hctx->ccid2hctx_cwnd = val? : 1;
+	ccid2_pr_debug("changed cwnd to %u\n", hctx->ccid2hctx_cwnd);
 }
 
 static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
@@ -232,7 +227,7 @@ static void ccid2_hc_tx_rto_expire(unsig
 
 	/* adjust pipe, cwnd etc */
 	ccid2_change_pipe(hctx, 0);
-	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd >> 1;
+	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
 	ccid2_change_cwnd(hctx, 1);
@@ -764,7 +759,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	 * initial slow-start after the first packet loss.  This is what we
 	 * want.
 	 */
-	hctx->ccid2hctx_ssthresh  = ~0;
+	hctx->ccid2hctx_ssthresh  = ~0U;
 	hctx->ccid2hctx_numdupack = 3;
 	hctx->ccid2hctx_seqbufc   = 0;
 
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -50,10 +50,10 @@ struct ccid2_seq {
  * @ccid2hctx_rpdupack - dupacks since rpseq
 */
 struct ccid2_hc_tx_sock {
-	int			ccid2hctx_cwnd;
+	u32			ccid2hctx_cwnd;
+	u32			ccid2hctx_ssthresh;
 	int			ccid2hctx_ssacks;
 	int			ccid2hctx_acks;
-	unsigned int		ccid2hctx_ssthresh;
 	int			ccid2hctx_pipe;
 	int			ccid2hctx_numdupack;
 	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
