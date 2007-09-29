From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:38:38 +0000
Subject: [PATCH 05/13] [CCID2]: Simplify interface
Message-Id: <20070929153838.GJ23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch simplifies the interface of ccid2_hc_tx_alloc_seq():

   * ccid2_hc_tx_alloc_seq() is always called with an argument of CCID2_SEQBUF_LEN;

   * other code - ccid2_hc_tx_check_sanity() - even depends on the assumption that
     ccid2_hc_tx_alloc_seq() has been called with this particular size;

   * passing the `gfp_t' argument to ccid2_hc_tx_alloc_seq() is redundant with gfp_any().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   19 +++++++++----------
 1 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index c199f34..5c6b4f9 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -83,8 +83,7 @@ static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 #define ccid2_hc_tx_check_sanity(hctx)
 #endif
 
-static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num,
-				 gfp_t gfp)
+static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 {
 	struct ccid2_seq *seqp;
 	int i;
@@ -95,16 +94,16 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num,
 		return -ENOMEM;
 
 	/* allocate buffer and initialize linked list */
-	seqp = kmalloc(sizeof(*seqp) * num, gfp);
+	seqp = kmalloc(CCID2_SEQBUF_LEN * sizeof(struct ccid2_seq), gfp_any());
 	if (seqp = NULL)
 		return -ENOMEM;
 
-	for (i = 0; i < (num - 1); i++) {
+	for (i = 0; i < (CCID2_SEQBUF_LEN - 1); i++) {
 		seqp[i].ccid2s_next = &seqp[i + 1];
 		seqp[i + 1].ccid2s_prev = &seqp[i];
 	}
-	seqp[num - 1].ccid2s_next = seqp;
-	seqp->ccid2s_prev = &seqp[num - 1];
+	seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = seqp;
+	seqp->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
 
 	/* This is the first allocation.  Initiate the head and tail.  */
 	if (hctx->ccid2hctx_seqbufc = 0)
@@ -114,8 +113,8 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num,
 		hctx->ccid2hctx_seqh->ccid2s_next = seqp;
 		seqp->ccid2s_prev = hctx->ccid2hctx_seqh;
 
-		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[num - 1];
-		seqp[num - 1].ccid2s_next = hctx->ccid2hctx_seqt;
+		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
+		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->ccid2hctx_seqt;
 	}
 
 	/* store the original pointer to the buffer so we can free it */
@@ -298,7 +297,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 		int rc;
 
 		ccid2_pr_debug("allocating more space in history\n");
-		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, gfp_any());
+		rc = ccid2_hc_tx_alloc_seq(hctx);
 		BUG_ON(rc); /* XXX what do we do? */
 
 		next = hctx->ccid2hctx_seqh->ccid2s_next;
@@ -771,7 +770,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	hctx->ccid2hctx_seqbufc   = 0;
 
 	/* XXX init ~ to window size... */
-	if (ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_ATOMIC) != 0)
+	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
 	hctx->ccid2hctx_sent	 = 0;
-- 
1.5.2.2

