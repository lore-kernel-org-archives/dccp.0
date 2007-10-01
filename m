From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:19 +0000
Subject: [PATCH 4/11]: Support for Mandatory options
Message-Id: <200710011518.19135@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Support for Mandatory options

Support for Mandatory options is provided by this patch, which will
be used by subsequent feature-negotiation patches.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.h    |    2 ++
 net/dccp/options.c |   15 +++++++++++++++
 2 files changed, 17 insertions(+)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -122,4 +122,6 @@ static inline u8 dccp_bytes_per_value(co
 
 extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
 extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
+
+extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -441,6 +441,21 @@ static int dccp_insert_option_timestamp_
 	return 0;
 }
 
+/**
+ * dccp_insert_option_mandatory  -  Mandatory option (5.8.2)
+ * Note that since we are using skb_push, this function needs to be called
+ * _after_ inserting the option it is supposed to influence (stack order).
+ */
+int dccp_insert_option_mandatory(struct sk_buff *skb)
+{
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len >= DCCP_MAX_OPT_LEN)
+		return -1;
+
+	DCCP_SKB_CB(skb)->dccpd_opt_len++;
+	*skb_push(skb, 1) = DCCPO_MANDATORY;
+	return 0;
+}
+
 static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
 				u8 *val, u8 len)
 {
