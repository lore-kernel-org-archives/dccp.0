From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 13 Dec 2008 13:41:25 +0000
Subject: [PATCH 5/5] dccp: Debugging functions for feature negotiation
Message-Id: <1229175685-18716-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Since all feature-negotiation processing now takes place in feat.c, functions
for producing verbose debugging output are concentrated there.

New functions to print out values, entry records, and options are provided,
and also a macro is defined to not always have the function name in the
output line.

Thanks to Wei Yongjun and Giuseppe Galeota for help ironing out errors in an
earlier revision of this patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h    |    2 +
 net/dccp/feat.c    |  153 ++++++++++++++++++++++++++++++++++++----------------
 net/dccp/feat.h    |   13 -----
 net/dccp/options.c |    4 --
 4 files changed, 109 insertions(+), 63 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -42,9 +42,11 @@
 extern int dccp_debug;
 #define dccp_pr_debug(format, a...)	  DCCP_PR_DEBUG(dccp_debug, format, ##a)
 #define dccp_pr_debug_cat(format, a...)   DCCP_PRINTK(dccp_debug, format, ##a)
+#define dccp_debug(fmt, a...)		  dccp_pr_debug_cat(KERN_DEBUG fmt, ##a)
 #else
 #define dccp_pr_debug(format, a...)
 #define dccp_pr_debug_cat(format, a...)
+#define dccp_debug(format, a...)
 #endif
 
 extern struct inet_hashinfo dccp_hashinfo;
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -208,6 +208,100 @@ static int dccp_feat_default_value(u8 feat_num)
 	return idx < 0 ? 0 : dccp_feat_table[idx].default_value;
 }
 
+/*
+ *	Debugging and verbose-printing section
+ */
+static const char *dccp_feat_fname(const u8 feat)
+{
+	static const char *feature_names[] = {
+		[DCCPF_RESERVED]	= "Reserved",
+		[DCCPF_CCID]		= "CCID",
+		[DCCPF_SHORT_SEQNOS]	= "Allow Short Seqnos",
+		[DCCPF_SEQUENCE_WINDOW]	= "Sequence Window",
+		[DCCPF_ECN_INCAPABLE]	= "ECN Incapable",
+		[DCCPF_ACK_RATIO]	= "Ack Ratio",
+		[DCCPF_SEND_ACK_VECTOR]	= "Send ACK Vector",
+		[DCCPF_SEND_NDP_COUNT]	= "Send NDP Count",
+		[DCCPF_MIN_CSUM_COVER]	= "Min. Csum Coverage",
+		[DCCPF_DATA_CHECKSUM]	= "Send Data Checksum",
+	};
+	if (feat > DCCPF_DATA_CHECKSUM && feat < DCCPF_MIN_CCID_SPECIFIC)
+		return feature_names[DCCPF_RESERVED];
+
+	if (feat =  DCCPF_SEND_LEV_RATE)
+		return "Send Loss Event Rate";
+	if (feat >= DCCPF_MIN_CCID_SPECIFIC)
+		return "CCID-specific";
+
+	return feature_names[feat];
+}
+
+static const char *dccp_feat_sname[] = { "DEFAULT", "INITIALISING", "CHANGING",
+					 "UNSTABLE", "STABLE" };
+
+#ifdef CONFIG_IP_DCCP_DEBUG
+static const char *dccp_feat_oname(const u8 opt)
+{
+	switch (opt) {
+	case DCCPO_CHANGE_L:  return "Change_L";
+	case DCCPO_CONFIRM_L: return "Confirm_L";
+	case DCCPO_CHANGE_R:  return "Change_R";
+	case DCCPO_CONFIRM_R: return "Confirm_R";
+	}
+	return NULL;
+}
+
+static void dccp_feat_printval(u8 feat_num, dccp_feat_val const *val)
+{
+	u8 i, type = dccp_feat_type(feat_num);
+
+	if (val = NULL || (type = FEAT_SP && val->sp.vec = NULL))
+		dccp_pr_debug_cat("(NULL)");
+	else if (type = FEAT_SP)
+		for (i = 0; i < val->sp.len; i++)
+			dccp_pr_debug_cat("%s%u", i ? " " : "", val->sp.vec[i]);
+	else if (type = FEAT_NN)
+		dccp_pr_debug_cat("%llu", (unsigned long long)val->nn);
+	else
+		dccp_pr_debug_cat("unknown type %u", type);
+}
+
+static void dccp_feat_printvals(u8 feat_num, u8 *list, u8 len)
+{
+	u8 type = dccp_feat_type(feat_num);
+	dccp_feat_val fval = { .sp.vec = list, .sp.len = len };
+
+	if (type = FEAT_NN)
+		fval.nn = dccp_decode_value_var(list, len);
+	dccp_feat_printval(feat_num, &fval);
+}
+
+static void dccp_feat_print_entry(struct dccp_feat_entry const *entry)
+{
+	dccp_debug("   * %s %s = ", entry->is_local ? "local" : "remote",
+				    dccp_feat_fname(entry->feat_num));
+	dccp_feat_printval(entry->feat_num, &entry->val);
+	dccp_pr_debug_cat(", state=%s %s\n", dccp_feat_sname[entry->state],
+			  entry->needs_confirm ? "(Confirm pending)" : "");
+}
+
+#define dccp_feat_print_opt(opt, feat, val, len, mandatory)	do {	      \
+	dccp_pr_debug("%s(%s, ", dccp_feat_oname(opt), dccp_feat_fname(feat));\
+	dccp_feat_printvals(feat, val, len);				      \
+	dccp_pr_debug_cat(") %s\n", mandatory ? "!" : "");	} while (0)
+
+#define dccp_feat_print_fnlist(fn_list)  {		\
+	const struct dccp_feat_entry *___entry;		\
+							\
+	dccp_pr_debug("List Dump:\n");			\
+	list_for_each_entry(___entry, fn_list, node)	\
+		dccp_feat_print_entry(___entry);	\
+}
+#else	/* ! CONFIG_IP_DCCP_DEBUG */
+#define dccp_feat_print_opt(opt, feat, val, len, mandatory)
+#define dccp_feat_print_fnlist(fn_list)
+#endif
+
 static int __dccp_feat_activate(struct sock *sk, const int idx,
 				const bool is_local, dccp_feat_val const *fval)
 {
@@ -240,6 +334,10 @@ static int __dccp_feat_activate(struct sock *sk, const int idx,
 	/* Location is RX if this is a local-RX or remote-TX feature */
 	rx = (is_local = (dccp_feat_table[idx].rxtx = FEAT_AT_RX));
 
+	dccp_debug("   -> activating %s %s, %sval=%llu\n", rx ? "RX" : "TX",
+		   dccp_feat_fname(dccp_feat_table[idx].feat_num),
+		   fval ? "" : "default ",  (unsigned long long)val);
+
 	return dccp_feat_table[idx].activation_hdlr(sk, val, rx);
 }
 
@@ -544,6 +642,7 @@ int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
 				return -1;
 			}
 		}
+		dccp_feat_print_opt(opt, pos->feat_num, ptr, len, 0);
 
 		if (dccp_insert_fn_opt(skb, opt, pos->feat_num, ptr, len, rpt))
 			return -1;
@@ -797,6 +896,7 @@ int dccp_feat_finalise_settings(struct dccp_sock *dp)
 	while (i--)
 		if (ccids[i] > 0 && dccp_feat_propagate_ccid(fn, ccids[i], i))
 			return -1;
+	dccp_feat_print_fnlist(fn);
 	return 0;
 }
 
@@ -915,6 +1015,8 @@ static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
 	if (len = 0 || type = FEAT_UNKNOWN)		/* 6.1 and 6.6.8 */
 		goto unknown_feature_or_value;
 
+	dccp_feat_print_opt(opt, feat, val, len, is_mandatory);
+
 	/*
 	 *	Negotiation of NN features: Change R is invalid, so there is no
 	 *	simultaneous negotiation; hence we do not look up in the list.
@@ -1020,6 +1122,8 @@ static u8 dccp_feat_confirm_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
 	const bool local = (opt = DCCPO_CONFIRM_R);
 	struct dccp_feat_entry *entry = dccp_feat_list_lookup(fn, feat, local);
 
+	dccp_feat_print_opt(opt, feat, val, len, is_mandatory);
+
 	if (entry = NULL) {	/* nothing queued: ignore or handle error */
 		if (is_mandatory && type = FEAT_UNKNOWN)
 			return DCCP_RESET_CODE_MANDATORY_ERROR;
@@ -1222,9 +1326,10 @@ int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
 			goto activation_failed;
 		}
 		if (cur->state != FEAT_STABLE) {
-			DCCP_CRIT("Negotiation of %s %u failed in state %u",
+			DCCP_CRIT("Negotiation of %s %s failed in state %s",
 				  cur->is_local ? "local" : "remote",
-				  cur->feat_num, cur->state);
+				  dccp_feat_fname(cur->feat_num),
+				  dccp_feat_sname[cur->state]);
 			goto activation_failed;
 		}
 		fvals[idx][cur->is_local] = &cur->val;
@@ -1265,47 +1370,3 @@ activation_failed:
 	dp->dccps_hc_rx_ackvec = NULL;
 	return -1;
 }
-
-#ifdef CONFIG_IP_DCCP_DEBUG
-const char *dccp_feat_typename(const u8 type)
-{
-	switch(type) {
-	case DCCPO_CHANGE_L:  return("ChangeL");
-	case DCCPO_CONFIRM_L: return("ConfirmL");
-	case DCCPO_CHANGE_R:  return("ChangeR");
-	case DCCPO_CONFIRM_R: return("ConfirmR");
-	/* the following case must not appear in feature negotation  */
-	default:	      dccp_pr_debug("unknown type %d [BUG!]\n", type);
-	}
-	return NULL;
-}
-
-EXPORT_SYMBOL_GPL(dccp_feat_typename);
-
-const char *dccp_feat_name(const u8 feat)
-{
-	static const char *feature_names[] = {
-		[DCCPF_RESERVED]	= "Reserved",
-		[DCCPF_CCID]		= "CCID",
-		[DCCPF_SHORT_SEQNOS]	= "Allow Short Seqnos",
-		[DCCPF_SEQUENCE_WINDOW]	= "Sequence Window",
-		[DCCPF_ECN_INCAPABLE]	= "ECN Incapable",
-		[DCCPF_ACK_RATIO]	= "Ack Ratio",
-		[DCCPF_SEND_ACK_VECTOR]	= "Send ACK Vector",
-		[DCCPF_SEND_NDP_COUNT]	= "Send NDP Count",
-		[DCCPF_MIN_CSUM_COVER]	= "Min. Csum Coverage",
-		[DCCPF_DATA_CHECKSUM]	= "Send Data Checksum",
-	};
-	if (feat > DCCPF_DATA_CHECKSUM && feat < DCCPF_MIN_CCID_SPECIFIC)
-		return feature_names[DCCPF_RESERVED];
-
-	if (feat =  DCCPF_SEND_LEV_RATE)
-		return "Send Loss Event Rate";
-	if (feat >= DCCPF_MIN_CCID_SPECIFIC)
-		return "CCID-specific";
-
-	return feature_names[feat];
-}
-
-EXPORT_SYMBOL_GPL(dccp_feat_name);
-#endif /* CONFIG_IP_DCCP_DEBUG */
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -107,19 +107,6 @@ extern unsigned long sysctl_dccp_sequence_window;
 extern int	     sysctl_dccp_rx_ccid;
 extern int	     sysctl_dccp_tx_ccid;
 
-#ifdef CONFIG_IP_DCCP_DEBUG
-extern const char *dccp_feat_typename(const u8 type);
-extern const char *dccp_feat_name(const u8 feat);
-
-static inline void dccp_feat_debug(const u8 type, const u8 feat, const u8 val)
-{
-	dccp_pr_debug("%s(%s (%d), %d)\n", dccp_feat_typename(type),
-					   dccp_feat_name(feat), feat, val);
-}
-#else
-#define dccp_feat_debug(type, feat, val)
-#endif /* CONFIG_IP_DCCP_DEBUG */
-
 extern int  dccp_feat_init(struct sock *sk);
 extern void dccp_feat_initialise_sysctls(void);
 extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -498,10 +498,6 @@ int dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
 		*to++ = *val;
 	if (len)
 		memcpy(to, val, len);
-
-	dccp_pr_debug("%s(%s (%d), ...), length %d\n",
-		      dccp_feat_typename(type),
-		      dccp_feat_name(feat), feat, len);
 	return 0;
 }
 
