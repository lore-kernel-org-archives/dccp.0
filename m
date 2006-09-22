From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 22 Sep 2006 02:30:14 +0000
Subject: [PATCH 5/7] [DCCP]: Introduce two new socket options
Message-Id: <200609221430.14555.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This creates two new socket options DCCP_SOCKOPT_TX_PACKET_SIZE
and DCCP_SOCKOPT_RX_PACKET_SIZE. DCCP_SOCKOPT_PACKET_SIZE doesn't
work and packet size should be set independently on two half
connections.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index a073164..ef1c57b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -200,6 +200,8 @@ #define DCCP_SOCKOPT_PACKET_SIZE	1
 #define DCCP_SOCKOPT_SERVICE		2
 #define DCCP_SOCKOPT_CHANGE_L		3
 #define DCCP_SOCKOPT_CHANGE_R		4
+#define DCCP_SOCKOPT_TX_PACKET_SIZE	5
+#define DCCP_SOCKOPT_RX_PACKET_SIZE	6
 #define DCCP_SOCKOPT_CCID_RX_INFO	128
 #define DCCP_SOCKOPT_CCID_TX_INFO	192
 
