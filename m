From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:02:14 +0000
Subject: [PATCH 11/22] [DCCP]: Only deliver to the CCID rx side in charge
Message-Id: <20061210030214.GM17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an optimisation to reduce CPU load. The received feedback is now
only directed to the active CCID component, without requiring processing
also by the inactive one.

As a consequence, a similar test in ccid3.c is now redundant and is
also removed.

Justification:

 Currently DCCP works as a unidirectional service, i.e. a listening server
 is not at the same time a connecting client.
 As far as I can see, several modifications are necessary until that
 becomes possible.
 At the present time, received feedback is both fed to the rx/tx CCID
 modules. In unidirectional service, only one of these is active at any
 one time.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    6 +++---
 net/dccp/input.c       |   21 +++++++++++++++++----
 2 files changed, 20 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 820bc25..936704d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -540,11 +540,11 @@ static void ccid3_hc_tx_packet_recv(stru
 				   jiffies + usecs_to_jiffies(t_nfb));
 
 		/* set idle flag */
-		hctx->ccid3hctx_idle = 1;   
+		hctx->ccid3hctx_idle = 1;
 		break;
 	case TFRC_SSTATE_NO_SENT:
-		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_CLIENT)
-			DCCP_WARN("Illegal ACK received - no packet sent\n");
+		/* XXX when implementing bidirectional rx/tx check this again */
+		DCCP_WARN("Illegal ACK received - no packet sent\n");
 		/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
 		break;
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 7371a2f..4a3279c 100644
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
-- 
1.4.2.1.g3d5c

