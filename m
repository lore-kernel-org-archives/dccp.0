From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:48:38 +0000
Subject: [PATCH 01/15] Allocation in atomic context
Message-Id: <20070819234838.GE24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes the following bug reported in syslog:

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

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid2.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 248d20f..d29b88f 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -298,7 +298,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 		int rc;
 
 		ccid2_pr_debug("allocating more space in history\n");
-		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, GFP_KERNEL);
+		rc = ccid2_hc_tx_alloc_seq(hctx, CCID2_SEQBUF_LEN, gfp_any());
 		BUG_ON(rc); /* XXX what do we do? */
 
 		next = hctx->ccid2hctx_seqh->ccid2s_next;
-- 
1.5.2.2

