From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:15:24 +0000
Subject: [PATCH 10/29] Shorten statement for updating p
Message-Id: <20070412211524.GK21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This shortens the statement for updating the loss event
rate p when a feedback packet is received.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 22ba3f9..c3711e1 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -466,12 +466,9 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
 	hctx->ccid3hctx_x_recv <<= 6;
 
-	/* Update loss event rate */
+	/* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
 	pinv = opt_recv->ccid3or_loss_event_rate;
-	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->ccid3hctx_p = 0;
-	else				       /* can not exceed 100% */
-		hctx->ccid3hctx_p = 1000000 / pinv;
+	hctx->ccid3hctx_p = (pinv = ~0U || pinv = 0) ? 0 : scaled_div(1, pinv);
 
 	/*
 	 * Calculate new round trip sample as per [RFC 3448, 4.3] by
-- 
1.5.0.6

