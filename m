From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 27 Nov 2006 14:46:37 +0000
Subject: [PATCH 7/8] [DCCP] ccid3: Resolve small FIXME
Message-Id: <20061127144636.GR11605@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This considers the  case - ACK received while no packet has been sent
so far. Resolved by printing a (rate-limited) warning message.

Further removes an unnecessary BUG_ON in ccid3_hc_tx_packet_recv,
received feedback on a terminating connection is simply ignored.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 58f7cac..6777a7f 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -413,9 +413,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	pinv = opt_recv->ccid3or_loss_event_rate;
 
 	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_NO_SENT:
-		/* FIXME: what to do here? */
-		return;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		/* Calculate new round trip sample by
@@ -521,8 +518,10 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;   
 		break;
-	case TFRC_SSTATE_TERM:
-		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
+	case TFRC_SSTATE_NO_SENT:
+		DCCP_WARN("Illegal ACK received - no packet has been sent\n");
+		/* fall through */
+	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
 		break;
 	}
 }
-- 
1.4.2.1.g3d5c

