From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 22 Nov 2008 10:30:41 +0000
Subject: [PATCH 5/5] dccp: Header option insertion routine for feature-negotiation
Message-Id: <1227349841-9440-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The patch extends existing code:
 * Confirm options divide into the confirmed value plus an optional preference
   list for SP values. Previously only the preference list was echoed for SP
   values, now the confirmed value is added as per RFC 4340, 6.1;
 * length and sanity checks are added to avoid illegal memory (or NULL) access.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/feat.h    |    2 +
 net/dccp/options.c |   91 ++++++++++++++++++----------------------------------
 2 files changed, 33 insertions(+), 60 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -140,4 +140,6 @@ extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
 extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
 
 extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
+extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
+			       u8 *val, u8 len, bool repeat_first);
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -482,23 +482,46 @@ int dccp_insert_option_mandatory(struct sk_buff *skb)
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
 
@@ -508,51 +531,6 @@ static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
 	return 0;
 }
 
-static int dccp_insert_options_feat(struct sock *sk, struct sk_buff *skb)
-{
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	struct dccp_opt_pend *opt, *next;
-	int change = 0;
-
-	/* confirm any options [NN opts] */
-	list_for_each_entry_safe(opt, next, &dmsk->dccpms_conf, dccpop_node) {
-		dccp_insert_feat_opt(skb, opt->dccpop_type,
-				     opt->dccpop_feat, opt->dccpop_val,
-				     opt->dccpop_len);
-		/* fear empty confirms */
-		if (opt->dccpop_val)
-			kfree(opt->dccpop_val);
-		kfree(opt);
-	}
-	INIT_LIST_HEAD(&dmsk->dccpms_conf);
-
-	/* see which features we need to send */
-	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
-		/* see if we need to send any confirm */
-		if (opt->dccpop_sc) {
-			dccp_insert_feat_opt(skb, opt->dccpop_type + 1,
-					     opt->dccpop_feat,
-					     opt->dccpop_sc->dccpoc_val,
-					     opt->dccpop_sc->dccpoc_len);
-
-			BUG_ON(!opt->dccpop_sc->dccpoc_val);
-			kfree(opt->dccpop_sc->dccpoc_val);
-			kfree(opt->dccpop_sc);
-			opt->dccpop_sc = NULL;
-		}
-
-		/* any option not confirmed, re-send it */
-		if (!opt->dccpop_conf) {
-			dccp_insert_feat_opt(skb, opt->dccpop_type,
-					     opt->dccpop_feat, opt->dccpop_val,
-					     opt->dccpop_len);
-			change++;
-		}
-	}
-
-	return 0;
-}
-
 /* The length of all options needs to be a multiple of 4 (5.8) */
 static void dccp_insert_option_padding(struct sk_buff *skb)
 {
@@ -589,13 +567,6 @@ int dccp_insert_options(struct sock *sk, struct sk_buff *skb)
 		dp->dccps_hc_rx_insert_options = 0;
 	}
 
-	/* Feature negotiation */
-	/* Data packets can't do feat negotiation */
-	if (DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATA &&
-	    DCCP_SKB_CB(skb)->dccpd_type != DCCP_PKT_DATAACK &&
-	    dccp_insert_options_feat(sk, skb))
-		return -1;
-
 	/*
 	 * Obtain RTT sample from Request/Response exchange.
 	 * This is currently used in CCID 3 initialisation.
