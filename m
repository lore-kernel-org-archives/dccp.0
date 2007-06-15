From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:48 +0000
Subject: [PATCH 6/9]: New RX History Step 4 - Data Packet Utility Function (part 2 RX RTT sampling)
Message-Id: <200706151531.48562@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: New RX History Step 4 - Data Packet Utility Function (part 2 RX RTT sampling)

For a clean integration of receiver-based RTT sampling, the next patch needs
a test function which says whether a received packet is a data packet according
to [RFC 4340, 7.7].

Such a function is provided by this patch, and it is integrated into the main
DCCP code, since it is generic and usable by other parts of the DCCP/CCID code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |   12 ++++++++++++
 1 file changed, 12 insertions(+)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -322,6 +322,7 @@ struct dccp_skb_cb {
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+/* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
@@ -334,6 +335,17 @@ static inline int dccp_non_data_packet(c
 	       type = DCCP_PKT_SYNCACK;
 }
 
+/* RFC 4340, sec. 7.7 */
+static inline int dccp_data_packet(const struct sk_buff *skb)
+{
+	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
+
+	return type = DCCP_PKT_DATA	 ||
+	       type = DCCP_PKT_DATAACK  ||
+	       type = DCCP_PKT_REQUEST  ||
+	       type = DCCP_PKT_RESPONSE;
+}
+
 static inline int dccp_packet_without_ack(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
