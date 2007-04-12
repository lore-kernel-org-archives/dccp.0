From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:17:34 +0000
Subject: [PATCH 25/29] Add test function for data packets
Message-Id: <20070412211734.GZ21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds a function which returns `true' when an skb contains one of the packet
types specified in [RFC 4340, 7.7] as `data packet'.

NB - Resisted the temptation to define
     int dccp_non_data_packet(skb) { return !dccp_data_packet(skb); },
     since maybe someone will define new packet types.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/dccp.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b00fc7a..0dc4b7e 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -320,6 +320,7 @@ struct dccp_skb_cb {
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+/* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
@@ -332,6 +333,17 @@ static inline int dccp_non_data_packet(const struct sk_buff *skb)
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
-- 
1.5.0.6

