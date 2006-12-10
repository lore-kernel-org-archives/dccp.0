From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:00:07 +0000
Subject: [PATCH 3/22] [DCCP] ccid3: Check against too large p
Message-Id: <20061210030007.GE17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch follows a suggestion by Ian McDonald and ensures that in
the current code the value of p can not exceed 100%.  Such a value is
illegal and would consequently cause a bug condition in tfrc_calc_x().

The receiver case is also tested, and a warning message is added.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 66a27b9..f1b745e 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -444,9 +444,9 @@ static void ccid3_hc_tx_packet_recv(stru
 
 		/* Update loss event rate */
 		pinv = opt_recv->ccid3or_loss_event_rate;
-		if (pinv = ~0U || pinv = 0)
+		if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
 			hctx->ccid3hctx_p = 0;
-		else
+		else				       /* can not exceed 100% */
  			hctx->ccid3hctx_p = 1000000 / pinv;
 
 		dccp_timestamp(sk, &now);
@@ -733,10 +733,15 @@ static void ccid3_hc_rx_send_feedback(st
 	/* Convert to multiples of 10us */
 	hcrx->ccid3hcrx_elapsed_time  			timeval_delta(&now, &packet->dccphrx_tstamp) / 10;
+
 	if (hcrx->ccid3hcrx_p = 0)
-		hcrx->ccid3hcrx_pinv = ~0;
-	else
+		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
+	else if (hcrx->ccid3hcrx_p > 1000000) {
+		DCCP_WARN("p (%u) > 100%%\n", hcrx->ccid3hcrx_p);
+		hcrx->ccid3hcrx_pinv = 1;	/* use 100% in this case */
+	} else
 		hcrx->ccid3hcrx_pinv = 1000000 / hcrx->ccid3hcrx_p;
+
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
 }
-- 
1.4.2.1.g3d5c

