From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 07 Dec 2006 21:12:32 +0000
Subject: [Patch 2/12]: Only deliver to the CCID rx side in charge
Message-Id: <200612072112.33114@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Only deliver to the CCID rx side in charge

This is an optimisation to reduce CPU load. The received feedback is now
only directed to the active CCID component, without requiring processing
also by the inactive one.

As a consequence, a similar test in ccid3.c is now redundant and is
also removed.

Justification:
--------------
 Currently DCCP works as a unidirectional service, i.e. a listening server 
 is not at the same time a connecting client.
 As far as I can see, several modifications are necessary until that
 becomes possible.
 At the present time, received feedback is both fed to the rx/tx CCID
 modules. In unidirectional service, only one of these is active at any
 one time. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |    4 ++--
 net/dccp/input.c       |   21 +++++++++++++++++----
 2 files changed, 19 insertions(+), 6 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -543,8 +543,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		hctx->ccid3hctx_idle = 1;   
 		break;
 	case TFRC_SSTATE_NO_SENT:
-		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_CLIENT)
-			DCCP_WARN("Illegal ACK received - no packet sent\n");
+		/* XXX when implementing bidirectional rx/tx check this again */
+		DCCP_WARN("Illegal ACK received - no packet sent\n");
 		/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
 		break;
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -248,8 +248,18 @@ int dccp_rcv_established(struct sock *sk
 			    DCCP_ACKVEC_STATE_RECEIVED))
 		goto discard;
 
-	ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+	/*
+	 * Deliver to the CCID module in charge.
+	 * FIXME: Currently DCCP operates one-directional only, i.e. a listening
+	 *        server is not at the same time a connecting client. There is
+	 *        not much sense in delivering to both rx/tx sides at the moment
+	 *        (only one is active at a time); when moving to bidirectional
+	 *        service, this needs to be revised.
+	 */
+	if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
+		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+	else
+		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
 
 	return __dccp_rcv_established(sk, skb, dh, len);
 discard:
@@ -484,8 +494,11 @@ int dccp_rcv_state_process(struct sock *
  				    DCCP_ACKVEC_STATE_RECEIVED))
  			goto discard;
 
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+		/* XXX see the comments in dccp_rcv_established about this */
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
+			ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
+		else
+			ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
 	}
 
 	/*
