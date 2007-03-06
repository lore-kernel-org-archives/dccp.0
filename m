From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 06 Mar 2007 09:36:41 +0000
Subject: [PATCH 1/2]
Message-Id: <200703060936.41327@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Correctly split CCID half connections

This fixes a bug caused by a previous patch, which causes DCCP 
servers in LISTEN state to not receive packets.

This patch changes the logic so that
 * servers in either LISTEN or OPEN state get the RX half connection packets
 * clients in OPEN state get the TX half connection packets

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/input.c |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -258,10 +258,10 @@ int dccp_rcv_established(struct sock *sk
 	 *        (only one is active at a time); when moving to bidirectional
 	 *        service, this needs to be revised.
 	 */
-	if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
-		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-	else
+	if (dccp_sk(sk)->dccps_role = DCCP_ROLE_CLIENT)
 		ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+	else	/* listening or connected server */
+		ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
 
 	return __dccp_rcv_established(sk, skb, dh, len);
 discard:
@@ -505,10 +505,10 @@ int dccp_rcv_state_process(struct sock *
 			goto discard;
 
 		/* XXX see the comments in dccp_rcv_established about this */
-		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
-			ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
-		else
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_CLIENT)
 			ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
+		else
+			ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
 	}
 
 	/*
