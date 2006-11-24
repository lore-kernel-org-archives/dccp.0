From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:26 +0000
Subject: [PATCH 3/10]: Resolve small FIXME
Message-Id: <200611241619.26817@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Resolve small FIXME

This considers the  case - ACK received while no packet has been sent
so far. Resolved by printing a (rate-limited) warning message.

Further removes an unnecessary BUG_ON in ccid3_hc_tx_packet_recv,
received feedback on a terminating connection is simply ignored.	

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -437,9 +437,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	pinv = opt_recv->ccid3or_loss_event_rate;
 
 	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_NO_SENT:
-		/* FIXME: what to do here? */
-		return;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		/* Calculate new round trip sample by
@@ -545,8 +542,10 @@ static void ccid3_hc_tx_packet_recv(stru
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
