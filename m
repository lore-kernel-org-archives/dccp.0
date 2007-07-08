From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:40:28 +0000
Subject: [PATCH 1/8][PATCH v2]:  Allocation in atomic context and simplify interface
Message-Id: <200707081240.28357@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Allocation in atomic context and simplify interface

1.) This fixes the following bug reported in syslog:

[ 4039.051658] BUG: sleeping function called from invalid context at /usr/src/davem-2.6/mm/slab.c:3032
[ 4039.051668] in_atomic():1, irqs_disabled():0
[ 4039.051670] INFO: lockdep is turned off.
[ 4039.051674]  [<c0104c0f>] show_trace_log_lvl+0x1a/0x30
[ 4039.051687]  [<c0104d4d>] show_trace+0x12/0x14
[ 4039.051691]  [<c0104d65>] dump_stack+0x16/0x18
[ 4039.051695]  [<c011371e>] __might_sleep+0xaf/0xbe
[ 4039.051700]  [<c0157b66>] __kmalloc+0xb1/0xd0
[ 4039.051706]  [<f090416f>] ccid2_hc_tx_alloc_seq+0x35/0xc3 [dccp_ccid2]
[ 4039.051717]  [<f09048d6>] ccid2_hc_tx_packet_sent+0x27f/0x2d9 [dccp_ccid2]
[ 4039.051723]  [<f085486b>] dccp_write_xmit+0x1eb/0x338 [dccp]
[ 4039.051741]  [<f085603d>] dccp_sendmsg+0x113/0x18f [dccp]
[ 4039.051750]  [<c03907fc>] inet_sendmsg+0x2e/0x4c
[ 4039.051758]  [<c033a47d>] sock_aio_write+0xd5/0x107
[ 4039.051766]  [<c015abc1>] do_sync_write+0xcd/0x11c
[ 4039.051772]  [<c015b296>] vfs_write+0x118/0x11f
[ 4039.051840]  [<c015b932>] sys_write+0x3d/0x64
[ 4039.051845]  [<c0103e7c>] syscall_call+0x7/0xb
[ 4039.051848]  ===========
The problem was that GFP_KERNEL was used; fixed by using gfp_any().


2.) While at it, the interface of ccid2_hc_tx_alloc_seq() has been simplified:

   * ccid2_hc_tx_alloc_seq() is always called with an argument of CCID2_SEQBUF_LEN;

   * other code - ccid2_hc_tx_check_sanity() - even depends on the assumption that
     ccid2_hc_tx_alloc_seq() has been called with this particular size;

   * passing the `gfp_t' argument to ccid2_hc_tx_alloc_seq() is redundant with gfp_any().


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -83,8 +83,7 @@ static void ccid2_hc_tx_check_sanity(con
 #define ccid2_hc_tx_check_sanity(hctx)
 #endif
 
-static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num,
-				 gfp_t gfp)
+static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 {
 	struct ccid2_seq *seqp;
 	int i;
@@ -95,16 +94,16 @@ static int ccid2_hc_tx_alloc_seq(struct 
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
@@ -114,8 +113,8 @@ static int ccid2_hc_tx_alloc_seq(struct 
 		hctx->ccid2hctx_seqh->ccid2s_next = seqp;
 		seqp->ccid2s_prev = hctx->ccid2hctx_seqh;
 
-		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[num - 1];
-		seqp[num - 1].ccid2s_next = hctx->ccid2hctx_seqt;
+		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
+		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->ccid2hctx_seqt;
 	}
 
 	/* store the original pointer to the buffer so we can free it */
@@ -298,7 +297,7 @@ static void ccid2_hc_tx_packet_sent(stru
 		int rc;
 
 		ccid2_pr_debug("allocating more space in history\n");
-		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_KERNEL);
+		rc = ccid2_hc_tx_alloc_seq(hctx);
 		BUG_ON(rc); /* XXX what do we do? */
 
 		next = hctx->ccid2hctx_seqh->ccid2s_next;
@@ -771,7 +770,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_seqbufc   = 0;
 
 	/* XXX init ~ to window size... */
-	if (ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_ATOMIC) != 0)
+	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
 	hctx->ccid2hctx_sent	 = 0;
