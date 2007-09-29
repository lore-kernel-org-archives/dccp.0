From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:38:47 +0000
Subject: [PATCH 06/13] [CCID2]: Remove ugly BUG_ON
Message-Id: <20070929153847.GK23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes an ugly BUG_ON which has been pointed out by Arnaldo.

Instead of freezing up the machine, a `critical' message is now issued
to the system log.

There is potential of doing this more gracefully (eg. there are a few internal
variables which could be updated despite the lack of memory), but that requires
more complicated changes to the algorithm; thus a `FIXME' has been added.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 5c6b4f9..3e4fa6b 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -294,12 +294,11 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	next = hctx->ccid2hctx_seqh->ccid2s_next;
 	/* check if we need to alloc more space */
 	if (next = hctx->ccid2hctx_seqt) {
-		int rc;
-
-		ccid2_pr_debug("allocating more space in history\n");
-		rc = ccid2_hc_tx_alloc_seq(hctx);
-		BUG_ON(rc); /* XXX what do we do? */
-
+		if (ccid2_hc_tx_alloc_seq(hctx)) {
+			DCCP_CRIT("packet history - out of memory!");
+			/* FIXME: find a more graceful way to bail out */
+			return;
+		}
 		next = hctx->ccid2hctx_seqh->ccid2s_next;
 		BUG_ON(next = hctx->ccid2hctx_seqt);
 	}
-- 
1.5.2.2

