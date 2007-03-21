From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:54 +0000
Subject: [PATCH 10/25]: Shorten statement for updating p
Message-Id: <200703211844.54487@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Shorten statement for updating p

This shortens the statement for updating the loss event
rate p when a feedback packet is received.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -466,12 +466,9 @@ static void ccid3_hc_tx_packet_recv(stru
 	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
 	hctx->ccid3hctx_x_recv <<= 6;
 
-	/* Update loss event rate */
+	/* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
 	pinv = opt_recv->ccid3or_loss_event_rate;
-	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->ccid3hctx_p = 0;
-	else				       /* can not exceed 100% */
-		hctx->ccid3hctx_p = 1000000 / pinv;
+	hctx->ccid3hctx_p = (pinv = ~0U || pinv = 0)? 0 : scaled_div(1, pinv);
 
 	/*
 	 * Calculate new round trip sample as per [RFC 3448, 4.3] by
