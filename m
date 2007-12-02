From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 02 Dec 2007 21:36:51 +0000
Subject: [PATCH 2/7] [DCCP]: Introduce generic function to test for `data packets'
Message-Id: <1196631416-17778-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

as per  RFC 4340, sec. 7.7.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index ee97950..f4a5ea1 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -334,6 +334,7 @@ struct dccp_skb_cb {
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+/* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
@@ -346,6 +347,17 @@ static inline int dccp_non_data_packet(const struct sk_buff *skb)
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
1.5.3.4

