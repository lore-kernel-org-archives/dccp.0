From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:38:56 +0000
Subject: [PATCH 07/13] [CCID2]: Remove redundant BUG_ON
Message-Id: <20070929153856.GL23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes a test for `val < 1' which would only have been triggered
when val < 0, due to a preceding test for 0.
Fixed by using an unsigned type for cwnd (as in TCP) instead.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   11 +++--------
 net/dccp/ccids/ccid2.h |    2 +-
 2 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 3e4fa6b..5114a2d 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -179,16 +179,11 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
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
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index ebd7949..d9daa53 100644
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
-- 
1.5.2.2

