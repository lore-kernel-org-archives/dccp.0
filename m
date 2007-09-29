From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 29 Sep 2007 15:39:10 +0000
Subject: [PATCH 08/13] [CCID2]: Remove redundant case block
Message-Id: <20070929153910.GM23546@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

skb's passed to ccid2_hc_tx_send_packet() are headerless, the
packet type is decided later, in dccp_write_xmit(). Therefore
the first test of the switch/case block is always true, the
others are never reached.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 5114a2d..1dff418 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -126,19 +126,7 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 
 static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid2_hc_tx_sock *hctx;
-
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case 0: /* XXX data packets from userland come through like this */
-	case DCCP_PKT_DATA:
-	case DCCP_PKT_DATAACK:
-		break;
-	/* No congestion control on other packets */
-	default:
-		return 0;
-	}
-
-	hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
 	ccid2_pr_debug("pipe=%d cwnd=%d\n", hctx->ccid2hctx_pipe,
 		       hctx->ccid2hctx_cwnd);
-- 
1.5.2.2

