From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 08 Jul 2007 11:40:54 +0000
Subject: [PATCH 4/8]: Remove redundant case block
Message-Id: <200707081240.54570@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID2]: Remove redundant case block

skb's passed to ccid2_hc_tx_send_packet() are headerless, the 
packet type is decided later, in dccp_write_xmit(). Therefore
the first test of the switch/case block is always true, the
others are never reached.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   14 +-------------
 1 file changed, 1 insertion(+), 13 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -126,19 +126,7 @@ static int ccid2_hc_tx_alloc_seq(struct 
 
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
