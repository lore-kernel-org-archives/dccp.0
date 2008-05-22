From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 22 May 2008 03:36:03 +0000
Subject: [PATCH] DCCP: Fix to handle short sequence numbers packet correctly
Message-Id: <4834EA23.3070309@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

RFC4340 said:
  8.5.  Pseudocode
       ...
       If P.type is not Data, Ack, or DataAck and P.X = 0 (the packet
             has short sequence numbers), drop packet and return

But DCCP has some mistake to handle short sequence numbers packet, now 
it drop packet only if P.type is Data, Ack, or DataAck and P.X = 0.

This patch fixed this problem.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/dccp/ipv4.c	2008-05-18 11:54:29.000000000 -0400
+++ b/net/dccp/ipv4.c	2008-05-18 11:55:51.000000000 -0400
@@ -741,8 +741,8 @@ int dccp_invalid_packet(struct sk_buff *
 	 * If P.type is not Data, Ack, or DataAck and P.X = 0 (the packet
 	 * has short sequence numbers), drop packet and return
 	 */
-	if (dh->dccph_type >= DCCP_PKT_DATA    &&
-	    dh->dccph_type <= DCCP_PKT_DATAACK && dh->dccph_x = 0)  {
+	if ((dh->dccph_type < DCCP_PKT_DATA    ||
+	    dh->dccph_type > DCCP_PKT_DATAACK) && dh->dccph_x = 0)  {
 		DCCP_WARN("P.type (%s) not Data || [Data]Ack, while P.X = 0\n",
 			  dccp_packet_name(dh->dccph_type));
 		return 1;



