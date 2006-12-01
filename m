From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 01 Dec 2006 18:26:06 +0000
Subject: [PATCH 2/8]: Fix warning message about illegal ACK
Message-Id: <200612011826.06645@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP] Fix warning message about illegal ACK

This avoids a (harmless) warning message being printed at the DCCP server 
(the receiver of a DCCP half connection). 

Incoming packets are both directed to

 * ccid_hc_rx_packet_recv() for the server half
 * ccid_hc_tx_packet_recv() for the client half

The message gets printed since on a server the client half is currently not
sending data packets.
This is resolved for the moment by checking the DCCP-role first. In future
times (bidirectional DCCP connections), this test may have to be more 
sophisticated.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

---
 net/dccp/ccids/ccid3.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -555,7 +555,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		hctx->ccid3hctx_idle = 1;   
 		break;
 	case TFRC_SSTATE_NO_SENT:
-		DCCP_WARN("Illegal ACK received - no packet has been sent\n");
+		if(dccp_sk(sk)->dccps_role = DCCP_ROLE_CLIENT)
+			DCCP_WARN("Illegal ACK received - no packet sent\n");
 		/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
 		break;
