From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 07 Mar 2007 07:23:34 +0000
Subject: [PATCHv2] [DCCP]: Revert changes which disallow bidirectional communication
Message-Id: <200703070723.34995@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo, can you please consider this patch instead of the one sent
yesterday. It fully restores bidirectional communication, the one
yesterday will not help. 
Gerrit

----------------------------> Patch v2 <--------------------------------------
[DCCP]: Revert patch which disables bidirectional mode

This reverts an earlier patch which disabled bidirectional mode, meaning that
a listening (passive) socket was not allowed to write to the other (active)
end of the connection.

This mode had been disabled when there were problems with CCID3, but it
imposes a constraint on socket programming and thus hinders deployment.

A change is included to ignore RX feedback received by the TX CCID3 module.

Many thanks to Andre Noll for pointing out this bug.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    7 +------
 net/dccp/input.c       |   21 ++++-----------------
 2 files changed, 5 insertions(+), 23 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -250,18 +250,8 @@ int dccp_rcv_established(struct sock *sk
 			    DCCP_ACKVEC_STATE_RECEIVED))
 		goto discard;
 
-	/*
-	 * Deliver to the CCID module in charge.
-	 * FIXME: Currently DCCP operates one-directional only, i.e. a listening
-	 *        server is not at the same time a connecting client. There is
-	 *        not much sense in delivering to both rx/tx sides at the moment
-	 *        (only one is active at a time); when moving to bidirectional
-	 *        service, this needs to be revised.
-	 */
-	if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	else
-		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
 
 	return __dccp_rcv_established(sk, skb, dh, len);
 discard:
@@ -504,11 +494,8 @@ int dccp_rcv_state_process(struct sock *
 				    DCCP_ACKVEC_STATE_RECEIVED))
 			goto discard;
 
-		/* XXX see the comments in dccp_rcv_established about this */
-		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
-			ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		else
-			ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
 	}
 
 	/*
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -554,12 +554,7 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;
 		break;
-	case TFRC_SSTATE_NO_SENT:
-		/*
-		 * XXX when implementing bidirectional rx/tx check this again
-		 */
-		DCCP_WARN("Illegal ACK received - no packet sent\n");
-		/* fall through */
+	case TFRC_SSTATE_NO_SENT:	/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
 		break;
 	}
