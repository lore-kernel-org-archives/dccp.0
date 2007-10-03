From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:58 +0000
Subject: [PATCH 14/14]: Debugging Feature Negotiation
Message-Id: <200710031502.59142@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Debugging Feature Negotiation

Since all feature-negotiation processing now takes place in feat.c, functions for producing
verbose debugging output can be concentrated there. A number of functions to print out values,
entry records, and options are provided.

A new macro was defined to not always have the function name in the output line. I have refrained
from naming it dccp_pr_debug_dog ...

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h    |    2 
 net/dccp/feat.c    |  151 +++++++++++++++++++++++++++++++++++++----------------
 net/dccp/feat.h    |   13 ----
 net/dccp/options.c |    4 -
 4 files changed, 109 insertions(+), 61 deletions(-)

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
@@ -104,6 +104,100 @@ static int dccp_feat_default_value(u8 fe
 	return idx < 0 ? : dccp_feat_table[idx].default_value;
 }
 
+/*
+ *	Debugging and verbose-printing section
+ */
+static const char *dccp_feat_oname(const u8 opt)
+{
+	switch(opt) {
+	case DCCPO_CHANGE_L:  return("Change_L");
+	case DCCPO_CONFIRM_L: return("Confirm_L");
+	case DCCPO_CHANGE_R:  return("Change_R");
+	case DCCPO_CONFIRM_R: return("Confirm_R");
+	}
+	return NULL;
+}
+
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
+		   dccp_feat_fname(entry->feat_num));
+	dccp_feat_printval(entry->feat_num, &entry->val);
+	dccp_pr_debug_cat(", state=%s %s\n", dccp_feat_sname[entry->state],
+			  entry->needs_confirm ? "(Confirm pending)" : "");
+}
+
+#define dccp_feat_print_opt(opt, feat, val, len, mandatory)		      \
+	dccp_pr_debug("%s(%s, ", dccp_feat_oname(opt), dccp_feat_fname(feat));\
+	dccp_feat_printvals(feat, val, len);				      \
+	dccp_pr_debug_cat(") %s\n", mandatory ? "!" : "");
+
+#define dccp_feat_print_fnlist(fn_list)  {		\
+	const struct dccp_feat_entry *entry;		\
+							\
+	dccp_pr_debug("List Dump:\n");			\
+	list_for_each_entry(entry, fn_list, node)	\
+		dccp_feat_print_entry(entry);		\
+}
+#else	/* ! CONFIG_IP_DCCP_DEBUG */
+#define dccp_feat_print_opt(opt, feat, fval, mandatory)
+#define dccp_feat_print_fnlist(fn_list)
+#endif
+
 static int __dccp_feat_activate(struct sock *sk, const int idx,
 				const bool is_local, dccp_feat_val const *fval)
 {
@@ -136,6 +230,10 @@ static int __dccp_feat_activate(struct s
 	/* Location is RX if this is a local-RX or remote-TX feature */
 	rx = (is_local = (dccp_feat_table[idx].rxtx = FEAT_AT_RX));
 
+	dccp_debug("   -> activating %s %s, %sval=%llu\n", rx ? "RX" : "TX",
+		   dccp_feat_fname(dccp_feat_table[idx].feat_num),
+		   fval ? "" : "default ",  (unsigned long long)val);
+
 	return dccp_feat_table[idx].activation_hdlr(sk, val, rx);
 }
 
@@ -434,6 +532,7 @@ int dccp_feat_insert_opts(struct dccp_so
 				return -1;
 			}
 		}
+		dccp_feat_print_opt(opt, pos->feat_num, ptr, len, 0);
 
 		if (dccp_insert_fn_opt(skb, opt, pos->feat_num, ptr, len, rpt))
 			return -1;
@@ -689,6 +788,7 @@ int dccp_feat_finalise_settings(struct d
 	while (i--)
 		if (ccids[i] > 0 && dccp_feat_propagate_ccid(fn, ccids[i], i))
 			return -1;
+	dccp_feat_print_fnlist(fn);
 	return 0;
 }
 
@@ -802,6 +902,8 @@ static u8 dccp_feat_change_recv(struct l
 	if (len = 0 || type = FEAT_UNKNOWN)		/* 6.1 and 6.6.8 */
 		goto unknown_feature_or_value;
 
+	dccp_feat_print_opt(opt, feat, val, len, is_mandatory);
+
 	/*
 	 *	Negotiation of NN features: Change R is invalid, so there is no
 	 *	simultaneous negotiation; hence we do not consult the list.
@@ -909,6 +1011,8 @@ static u8 dccp_feat_confirm_recv(struct 
 	const bool local = (opt = DCCPO_CONFIRM_R);
 	struct dccp_feat_entry *entry = dccp_feat_list_lookup(fn, feat, local);
 
+	dccp_feat_print_opt(opt, feat, val, len, is_mandatory);
+
 	if (entry = NULL) {	/* nothing queued: ignore or handle error */
 		if (is_mandatory && type = FEAT_UNKNOWN)
 			return DCCP_RESET_CODE_MANDATORY_ERROR;
@@ -973,6 +1077,7 @@ confirmation_succeeded:
 	return 0;
 
 confirmation_failed:
+	dccp_pr_debug("Confirmation failed\n");
 	return is_mandatory ? DCCP_RESET_CODE_MANDATORY_ERROR
 			    : DCCP_RESET_CODE_OPTION_ERROR;
 }
@@ -1151,6 +1256,8 @@ int dccp_feat_activate_values(struct soc
 	return 0;
 
 activation_failed:
+	dccp_pr_debug("Activation of %s failed\n", idx < 0 ? "unknown feature" :
+		      dccp_feat_fname(dccp_feat_table[idx].feat_num));
 	/*
 	 * We clean up everything that may have been allocated, since
 	 * it is difficult to track at which stage negotiation failed.
@@ -1164,47 +1271,3 @@ activation_failed:
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
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -484,10 +484,6 @@ int dccp_insert_fn_opt(struct sk_buff *s
 		*to++ = *val;
 	if (len)
 		memcpy(to, val, len);
-
-	dccp_pr_debug("%s(%s (%d), ...), length %d\n",
-		      dccp_feat_typename(type),
-		      dccp_feat_name(feat), feat, len);
 	return 0;
 }
 
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -97,19 +97,6 @@ extern int sysctl_dccp_feat_rx_ccid;
 extern int sysctl_dccp_feat_tx_ccid;
 extern int sysctl_dccp_feat_send_ndp_count;
 
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
 extern int  dccp_feat_register_change(struct sock *sk, u8 feat,
