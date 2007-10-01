From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:21 +0000
Subject: [PATCH 5/11]: Update insertion routine for feature-negotiation options
Message-Id: <200710011518.21775@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Update insertion routine for feature-negotiation options

The patch extends existing code:
 * Confirm options divide into the confirmed value plus an optional preference
   list for SP values. Previously only the preference list was echoed for SP values,
   now the confirmed value is added as per RFC 4340, 6.1;
 * length and sanity checks are added to avoid illegal memory (or NULL) access;
 * clarified the use of TLV length constant, which does not have anything to do with ECN, but
   with the fact that Type-Length-Value options whose length is determined by an u8 
   field provide Value space for at most 255 - 2 = 253 bytes due to the Type/Length fields.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c  |    8 ++++----
 net/dccp/ackvec.h  |    6 +++---
 net/dccp/feat.h    |    1 +
 net/dccp/options.c |   39 +++++++++++++++++++++++++++++++--------
 4 files changed, 39 insertions(+), 15 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -124,4 +124,5 @@ extern void dccp_encode_value_var(const 
 extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
 
 extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
+extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8, u8, u8 *, u8, bool);
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -456,23 +456,46 @@ int dccp_insert_option_mandatory(struct 
 	return 0;
 }
 
-static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
-				u8 *val, u8 len)
+/**
+ * dccp_insert_fn_opt  -  Insert single Feature-Negotiation option into @skb
+ * @type: %DCCPO_CHANGE_L, %DCCPO_CHANGE_R, %DCCPO_CONFIRM_L, %DCCPO_CONFIRM_R
+ * @feat: one out of %dccp_feature_numbers
+ * @val: NN value or SP array (preferred element first) to copy
+ * @len: true length of @val in bytes (excluding first element repetition)
+ * @repeat_first: whether to copy the first element of @val twice
+ * The last argument is used to construct Confirm options, where the preferred
+ * value and the preference list appear separately (RFC 4340, 6.3.1). Preference
+ * lists are kept such that the preferred entry is always first, so we only need
+ * to copy twice, and avoid the overhead of cloning into a bigger array.
+ */
+int dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
+		       u8 *val, u8 len, bool repeat_first)
 {
-	u8 *to;
+	u8 tot_len, *to;
 
-	if (DCCP_SKB_CB(skb)->dccpd_opt_len + len + 3 > DCCP_MAX_OPT_LEN) {
-		DCCP_WARN("packet too small for feature %d option!\n", feat);
+	/* take the `Feature' field and possible repetition into account */
+	if (len > (DCCP_SINGLE_OPT_MAXLEN - 2)) {
+		DCCP_WARN("length %u for feature %u too large\n", len, feat);
 		return -1;
 	}
 
-	DCCP_SKB_CB(skb)->dccpd_opt_len += len + 3;
+	if (unlikely(val = NULL || len = 0))
+		len = repeat_first = 0;
+	tot_len = 3 + repeat_first + len;
+
+	if (DCCP_SKB_CB(skb)->dccpd_opt_len + tot_len > DCCP_MAX_OPT_LEN) {
+		DCCP_WARN("packet too small for feature %d option!\n", feat);
+		return -1;
+	}
+	DCCP_SKB_CB(skb)->dccpd_opt_len += tot_len;
 
-	to    = skb_push(skb, len + 3);
+	to    = skb_push(skb, tot_len);
 	*to++ = type;
-	*to++ = len + 3;
+	*to++ = tot_len;
 	*to++ = feat;
 
+	if (repeat_first)
+		*to++ = *val;
 	if (len)
 		memcpy(to, val, len);
 
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -16,10 +16,10 @@
 #include <linux/list.h>
 #include <linux/types.h>
 
-/* Read about the ECN nonce to see why it is 253 */
-#define DCCP_MAX_ACKVEC_OPT_LEN 253
+/* maximum size of a single TLV-encoded option (sans type/len bytes) */
+#define DCCP_SINGLE_OPT_MAXLEN  253
 /* We can spread an ack vector across multiple options */
-#define DCCP_MAX_ACKVEC_LEN (DCCP_MAX_ACKVEC_OPT_LEN * 2)
+#define DCCP_MAX_ACKVEC_LEN (DCCP_SINGLE_OPT_MAXLEN * 2)
 
 #define DCCP_ACKVEC_STATE_RECEIVED	0
 #define DCCP_ACKVEC_STATE_ECN_MARKED	(1 << 6)
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -70,7 +70,7 @@ int dccp_insert_option_ackvec(struct soc
 	struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
 	/* Figure out how many options do we need to represent the ackvec */
 	const u16 nr_opts = DIV_ROUND_UP(av->dccpav_vec_len,
-					 DCCP_MAX_ACKVEC_OPT_LEN);
+					 DCCP_SINGLE_OPT_MAXLEN);
 	u16 len = av->dccpav_vec_len + 2 * nr_opts, i;
 	u32 elapsed_time;
 	const unsigned char *tail, *from;
@@ -102,8 +102,8 @@ int dccp_insert_option_ackvec(struct soc
 	for (i = 0; i < nr_opts; ++i) {
 		int copylen = len;
 
-		if (len > DCCP_MAX_ACKVEC_OPT_LEN)
-			copylen = DCCP_MAX_ACKVEC_OPT_LEN;
+		if (len > DCCP_SINGLE_OPT_MAXLEN)
+			copylen = DCCP_SINGLE_OPT_MAXLEN;
 
 		*to++ = DCCPO_ACK_VECTOR_0;
 		*to++ = copylen + 2;
@@ -466,7 +466,7 @@ found:
 int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 		      u64 *ackno, const u8 opt, const u8 *value, const u8 len)
 {
-	if (len > DCCP_MAX_ACKVEC_OPT_LEN)
+	if (len > DCCP_SINGLE_OPT_MAXLEN)
 		return -1;
 
 	/* dccp_ackvector_print(DCCP_SKB_CB(skb)->dccpd_ack_seq, value, len); */
