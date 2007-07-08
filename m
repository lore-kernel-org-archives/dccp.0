From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:40:48 +0000
Subject: [PATCH 3/8]: Remove redundant BUG_ON
Message-Id: <200707081240.48718@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Remove redundant BUG_ON

This removes a test for `val < 1' which would only have been triggered
when val < 0, due to a preceding test for 0. 
Fixed by using an unsigned type for cwnd (as in TCP) instead. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   11 +++--------
 net/dccp/ccids/ccid2.h |    2 +-
 2 files changed, 4 insertions(+), 9 deletions(-)

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
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -50,7 +50,7 @@ struct ccid2_seq {
  * @ccid2hctx_rpdupack - dupacks since rpseq
 */
 struct ccid2_hc_tx_sock {
-	int			ccid2hctx_cwnd;
+	u32			ccid2hctx_cwnd;
 	int			ccid2hctx_ssacks;
 	int			ccid2hctx_acks;
 	unsigned int		ccid2hctx_ssthresh;
