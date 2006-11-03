From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Nov 2006 14:32:22 +0000
Subject: [PATCH 4/6] dccp: Make feature negotiation legible
Message-Id: <200611031432.22530@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Make feature negotiation legible

This patch replaces cryptic feature negotiation messages of type

Oct 31 15:42:20 kernel: dccp_feat_change: feat change type2 feat=1
Oct 31 15:42:21 kernel: dccp_feat_change: feat change type4 feat=1
Oct 31 15:42:21 kernel: dccp_feat_change: feat change type2 feat=5

into ones of type:

Nov  2 13:54:45 kernel: dccp_feat_change: ChangeL(CCID (1), 3)
Nov  2 13:54:45 kernel: dccp_feat_change: ChangeR(CCID (1), 3)
Nov  2 13:54:45 kernel: dccp_feat_change: ChangeL(Ack Ratio (5), 2)

Also,
        * completed the feature number list wrt RFC 4340 sec. 6.4
        * annotating which ones have been implemented so far
        * implemented rudimentary sanity checking in feat.c (FIXMEs)
        * some minor fixes

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    6 +++-
 net/dccp/feat.c      |   74 ++++++++++++++++++++++++++++++++-------------------
 net/dccp/feat.h      |   69 ++++++++++++++++++++++++++++++++++++++++++++++-
 net/dccp/options.c   |    4 ++
 4 files changed, 122 insertions(+), 31 deletions(-)


--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -175,14 +175,18 @@ enum {
 	DCCPC_CCID3 = 3,
 };
 
-/* DCCP features */
+/* DCCP features (RFC 4340 section 6.4) */
 enum {
 	DCCPF_RESERVED = 0,
 	DCCPF_CCID = 1,
+	DCCPF_SHORT_SEQNOS = 2,		/* XXX: not yet implemented */
 	DCCPF_SEQUENCE_WINDOW = 3,
+	DCCPF_ECN_INCAPABLE = 4,	/* XXX: not yet implemented */
 	DCCPF_ACK_RATIO = 5,
 	DCCPF_SEND_ACK_VECTOR = 6,
 	DCCPF_SEND_NDP_COUNT = 7,
+	DCCPF_MIN_CSUM_COVER = 8,	/* XXX: not yet implemented */
+	DCCPF_DATA_CHECKSUM = 9,	/* XXX: not yet implemented */
 	/* 10-127 reserved */
 	DCCPF_MIN_CCID_SPECIFIC = 128,
 	DCCPF_MAX_CCID_SPECIFIC = 255,
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -12,9 +12,74 @@
  */
 
 #include <linux/types.h>
+#include "dccp.h"
 
-struct sock;
-struct dccp_minisock;
+static inline int dccp_feat_is_valid_length(u8 type, u8 feature, u8 len)
+{
+	/* sec. 6.1: Confirm has at least length 3,
+	 * sec. 6.2: Change  has at least length 4 */
+	if (len < 3)
+		return 1;
+	if (len < 4  && (type = DCCPO_CHANGE_L || type = DCCPO_CHANGE_R))
+		return 1;
+	/* XXX: add per-feature length validation (sec. 6.6.8) */
+	return 0;
+}
+
+static inline int dccp_feat_is_reserved(const u8 feat)
+{
+	return ((feat > DCCPF_DATA_CHECKSUM && feat < DCCPF_MIN_CCID_SPECIFIC)
+		|| feat = DCCPF_RESERVED);
+}
+
+/* feature negotiation knows only these four option types (RFC 4340, sec. 6) */
+static inline int dccp_feat_is_valid_type(const u8 optnum)
+{
+	return (optnum >= DCCPO_CHANGE_L  &&  optnum <= DCCPO_CONFIRM_R);
+
+}
+
+#ifdef CONFIG_IP_DCCP_DEBUG
+static inline const char *dccp_feat_typename(const u8 type)
+{
+	switch(type) {
+	case DCCPO_CHANGE_L:  return("ChangeL");
+	case DCCPO_CONFIRM_L: return("ConfirmL");
+	case DCCPO_CHANGE_R:  return("ChangeR");
+	case DCCPO_CONFIRM_R: return("ConfirmR");
+	/* the following case must not appear in feature negotation  */
+	default: 	      dccp_pr_debug("unknown type %d [BUG!]\n", type);
+	}
+	return NULL;
+}
+static inline const char *dccp_feat_name(const u8 feat)
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
+	if (feat >= DCCPF_MIN_CCID_SPECIFIC)
+		return "CCID-specific";
+
+	if (dccp_feat_is_reserved(feat))
+		return feature_names[DCCPF_RESERVED];
+
+	return feature_names[feat];
+}
+#define dccp_feat_negotiation_debug(type, feature, val)		     \
+	dccp_pr_debug("%s(%s (%d), %d)\n", dccp_feat_typename(type), \
+					   dccp_feat_name(feature), feature, val)
+#else
+#define dccp_feat_negotiation_debug(type, feat, val)
+#endif /* CONFIG_IP_DCCP_DEBUG */
 
 extern int  dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 			     u8 *val, u8 len, gfp_t gfp);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -12,7 +12,6 @@
 
 #include <linux/module.h>
 
-#include "dccp.h"
 #include "ccid.h"
 #include "feat.h"
 
@@ -23,9 +22,17 @@ int dccp_feat_change(struct dccp_minisoc
 {
 	struct dccp_opt_pend *opt;
 
-	dccp_pr_debug("feat change type=%d feat=%d\n", type, feature);
+	dccp_feat_negotiation_debug(type, feature, *val);
 
-	/* XXX sanity check feat change request */
+	if (! dccp_feat_is_valid_type(type)) {
+		pr_info("option type %d invalid in negotiation\n", type);
+		return 1;
+	}
+	if (! dccp_feat_is_valid_length(type, feature, len)) {
+		pr_info("invalid length %d\n", len);
+		return 1;
+	}
+	/* XXX add further sanity checks */
 
 	/* check if that feature is already being negotiated */
 	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
@@ -95,14 +102,14 @@ static int dccp_feat_update_ccid(struct 
 /* XXX taking only u8 vals */
 static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, u8 val)
 {
-	dccp_pr_debug("changing [%d] feat %d to %d\n", type, feat, val);
+	dccp_feat_negotiation_debug(type, feat, val);
 
 	switch (feat) {
 	case DCCPF_CCID:
 		return dccp_feat_update_ccid(sk, type, val);
 	default:
-		dccp_pr_debug("IMPLEMENT changing [%d] feat %d to %d\n",
-			      type, feat, val);
+		dccp_pr_debug("UNIMPLEMENTED: %s(%d, ...)\n",
+			      dccp_feat_typename(type), feat);
 		break;
 	}
 	return 0;
@@ -265,10 +272,10 @@ static int dccp_feat_nn(struct sock *sk,
 	u8 *copy;
 	int rc;
 
-	/* NN features must be change L */
-	if (type = DCCPO_CHANGE_R) {
-		dccp_pr_debug("received CHANGE_R %d for NN feat %d\n",
-			      type, feature);
+	/* NN features must be Change L (sec. 6.3.2) */
+	if (type != DCCPO_CHANGE_L) {
+		dccp_pr_debug("received %s for NN feature %d\n",
+				dccp_feat_typename(type), feature);
 		return -EFAULT;
 	}
 
@@ -299,7 +306,8 @@ static int dccp_feat_nn(struct sock *sk,
 		return rc;
 	}
 
-	dccp_pr_debug("Confirming NN feature %d (val=%d)\n", feature, *copy);
+	dccp_feat_negotiation_debug(type, feature, *copy);
+
 	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_conf);
 
 	return 0;
@@ -318,14 +326,19 @@ static void dccp_feat_empty_confirm(stru
 		return;
 	}
 
-	opt->dccpop_type = type = DCCPO_CHANGE_L ? DCCPO_CONFIRM_R :
-						    DCCPO_CONFIRM_L;
+	switch (type) {
+	case DCCPO_CHANGE_L: opt->dccpop_type = DCCPO_CONFIRM_R; break;
+	case DCCPO_CHANGE_R: opt->dccpop_type = DCCPO_CONFIRM_L; break;
+	default: 	     pr_info("invalid type %d\n", type); return;
+
+	}
 	opt->dccpop_feat = feature;
 	opt->dccpop_val	 = NULL;
 	opt->dccpop_len	 = 0;
 
 	/* change feature */
-	dccp_pr_debug("Empty confirm feature %d type %d\n", feature, type);
+	dccp_pr_debug("Empty %s(%d)\n", dccp_feat_typename(type), feature);
+
 	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_conf);
 }
 
@@ -359,7 +372,7 @@ int dccp_feat_change_recv(struct sock *s
 {
 	int rc;
 
-	dccp_pr_debug("got feat change type=%d feat=%d\n", type, feature);
+	dccp_feat_negotiation_debug(type, feature, *val);
 
 	/* figure out if it's SP or NN feature */
 	switch (feature) {
@@ -375,6 +388,8 @@ int dccp_feat_change_recv(struct sock *s
 
 	/* XXX implement other features */
 	default:
+		dccp_pr_debug("UNIMPLEMENTED: not handling %s(%d, ...)\n",
+			      dccp_feat_typename(type), feature);
 		rc = -EFAULT;
 		break;
 	}
@@ -403,20 +418,27 @@ int dccp_feat_confirm_recv(struct sock *
 	u8 t;
 	struct dccp_opt_pend *opt;
 	struct dccp_minisock *dmsk = dccp_msk(sk);
-	int rc = 1;
+	int found = 0;
 	int all_confirmed = 1;
 
-	dccp_pr_debug("got feat confirm type=%d feat=%d\n", type, feature);
-
-	/* XXX sanity check type & feat */
+	dccp_feat_negotiation_debug(type, feature, *val);
 
 	/* locate our change request */
-	t = type = DCCPO_CONFIRM_L ? DCCPO_CHANGE_R : DCCPO_CHANGE_L;
+	switch (type) {
+	case DCCPO_CONFIRM_L: t = DCCPO_CHANGE_R; break;
+	case DCCPO_CONFIRM_R: t = DCCPO_CHANGE_L; break;
+	default: 	      pr_info("invalid type %d\n", type);
+			      return 1;
+
+	}
+	/* XXX sanity check feature value */
 
 	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
 		if (!opt->dccpop_conf && opt->dccpop_type = t &&
 		    opt->dccpop_feat = feature) {
-			/* we found it */
+			found = 1;
+			dccp_pr_debug("feature %d found\n", opt->dccpop_feat);
+
 			/* XXX do sanity check */
 
 			opt->dccpop_conf = 1;
@@ -425,9 +447,7 @@ int dccp_feat_confirm_recv(struct sock *
 			dccp_feat_update(sk, opt->dccpop_type,
 					 opt->dccpop_feat, *val);
 
-			dccp_pr_debug("feat %d type %d confirmed %d\n",
-				      feature, type, *val);
-			rc = 0;
+			/* XXX check the return value of dccp_feat_update */
 			break;
 		}
 
@@ -446,9 +466,9 @@ int dccp_feat_confirm_recv(struct sock *
 		inet_csk_clear_xmit_timer(sk, ICSK_TIME_RETRANS);
 	}
 
-	if (rc)
-		dccp_pr_debug("feat %d type %d never requested\n",
-			      feature, type);
+	if (!found)
+		dccp_pr_debug("%s(%d, ...) never requested\n",
+			      dccp_feat_typename(type), feature);
 	return 0;
 }
 
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -466,7 +466,9 @@ static int dccp_insert_feat_opt(struct s
 
 	if (len)
 		memcpy(to, val, len);
-	dccp_pr_debug("option %d feat %d len %d\n", type, feat, len);
+
+	dccp_pr_debug("%s(%s (%d), ...), length %d\n", dccp_feat_typename(type),
+					       dccp_feat_name(feat), feat, len);
 
 	return 0;
 }

