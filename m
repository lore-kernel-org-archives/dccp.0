From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 03 Dec 2006 22:07:53 +0000
Subject: [PATCH 4/10] [DCCP] ccid3: Fix warning message about illegal ACK
Message-Id: <20061203220752.GJ17803@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

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
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index bd35304..721efc7 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -555,7 +555,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		hctx->ccid3hctx_idle = 1;   
 		break;
 	case TFRC_SSTATE_NO_SENT:
-		DCCP_WARN("Illegal ACK received - no packet has been sent\n");
+		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_CLIENT)
+			DCCP_WARN("Illegal ACK received - no packet sent\n");
 		/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
 		break;
-- 
1.4.2.1.g3d5c

