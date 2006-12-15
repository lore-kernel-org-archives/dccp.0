From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Dec 2006 10:51:03 +0000
Subject: [PATCH 6/8]: Remove redundant `len' test
Message-Id: <200612151051.03560@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3] Remove redundant `len' test

Since CCID3 avoids  sending 0-byte data packets (cf. ccid3_hc_tx_send_packet), 
testing for zero-payload length, as performed by ccid3_hc_tx_update_s, is 
redundant - hence removed by this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -142,11 +142,8 @@ static void ccid3_hc_tx_update_x(struct 
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-	if (unlikely(len = 0))
-		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
-	else
-		hctx->ccid3hctx_s = hctx->ccid3hctx_s = 0 ? len :
-				    (9 * hctx->ccid3hctx_s + len) / 10;
+	hctx->ccid3hctx_s = hctx->ccid3hctx_s = 0 ? len :
+			    (9 * hctx->ccid3hctx_s + len) / 10;
 	/*
 	 * Note: We could do a potential optimisation here - when `s' changes,
 	 *	 recalculate sending rate and consequently t_ipi, t_delta, and
