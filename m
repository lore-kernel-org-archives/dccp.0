From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 12 Nov 2008 06:37:22 +0000
Subject: v2 [PATCH 2/4] dccp: Registration routines for changing feature
Message-Id: <20081112063722.GD6405@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Registration routines for changing feature values

Two registration routines, for SP and NN features, are provided by this patch,
replacing a previous routine which was used for both feature types.

These are internal-only routines and therefore start with `__feat_register'.

It further exports the known limits of Sequence Window and Ack Ratio as symbolic
constants.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/ccid2.c |    6 -
 net/dccp/feat.c        |  192 +++++++++++++++++++++++++++++++++++++++++++------
 net/dccp/feat.h        |   25 ++++++
 net/dccp/proto.c       |    2 
 4 files changed, 197 insertions(+), 28 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -14,6 +14,15 @@
 #include <linux/types.h>
 #include "dccp.h"
 
+/*
+ * Known limit values
+ */
+/* Ack Ratio takes 2-byte integer values (11.3) */
+#define DCCPF_ACK_RATIO_MAX	0xFFFF
+/* Wmin2 and Wmax=2^46-1 from 7.5.2 */
+#define DCCPF_SEQ_WMIN		32
+#define DCCPF_SEQ_WMAX		0x3FFFFFFFFFFFull
+
 enum dccp_feat_type {
 	FEAT_AT_RX   = 1,	/* located at RX side of half-connection  */
 	FEAT_AT_TX   = 2,	/* located at TX side of half-connection  */
@@ -75,6 +84,20 @@ static inline u8 dccp_feat_genopt(struct
 	return entry->is_local ? DCCPO_CHANGE_L : DCCPO_CHANGE_R;
 }
 
+/**
+ * struct ccid_dependency  -  Track changes resulting from choosing a CCID
+ * @dependent_feat: one of %dccp_feature_numbers
+ * @is_local: local (1) or remote (0) @dependent_feat
+ * @is_mandatory: whether presence of @dependent_feat is mission-critical or not
+ * @val: corresponding default value for @dependent_feat (u8 is sufficient here)
+ */
+struct ccid_dependency {
+	u8	dependent_feat;
+	bool	is_local:1,
+		is_mandatory:1;
+	u8	val;
+};
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 extern const char *dccp_feat_typename(const u8 type);
 extern const char *dccp_feat_name(const u8 feat);
@@ -97,6 +120,6 @@ extern int  dccp_feat_confirm_recv(struc
 extern void dccp_feat_clean(struct dccp_minisock *dmsk);
 extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
-extern int  dccp_feat_init(struct dccp_minisock *dmsk);
+extern int  dccp_feat_init(struct sock *sk);
 
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -92,6 +92,18 @@ static u8 dccp_feat_type(u8 feat_num)
 	return dccp_feat_table[idx].reconciliation;
 }
 
+static int dccp_feat_default_value(u8 feat_num)
+{
+	int idx = dccp_feat_index(feat_num);
+	/*
+	 * There are no default values for unknown features, so encountering a
+	 * negative index here indicates a serious problem somewhere else.
+	 */
+	DCCP_BUG_ON(idx < 0);
+
+	return idx < 0 ? 0 : dccp_feat_table[idx].default_value;
+}
+
 /* copy constructor, fval must not already contain allocated memory */
 static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
 {
@@ -155,6 +167,63 @@ static void dccp_feat_entry_destructor(s
  * - list is sorted in increasing order of feature number (faster lookup)
  */
 
+/**
+ * dccp_feat_entry_new  -  Central list update routine (called by all others)
+ * @head:  list to add to
+ * @feat:  feature number
+ * @local: whether the local (1) or remote feature with number @feat is meant
+ * This is the only constructor and serves to ensure the above invariants.
+ */
+static struct dccp_feat_entry *
+	      dccp_feat_entry_new(struct list_head *head, u8 feat, bool local)
+{
+	struct dccp_feat_entry *entry;
+
+	list_for_each_entry(entry, head, node)
+		if (entry->feat_num = feat && entry->is_local = local) {
+			dccp_feat_val_destructor(entry->feat_num, &entry->val);
+			return entry;
+		} else if (entry->feat_num > feat) {
+			head = &entry->node;
+			break;
+		}
+
+	entry = kmalloc(sizeof(*entry), gfp_any());
+	if (entry != NULL) {
+		entry->feat_num = feat;
+		entry->is_local = local;
+		list_add_tail(&entry->node, head);
+	}
+	return entry;
+}
+
+/**
+ * dccp_feat_push_change  -  Add/overwrite a Change option in the list
+ * @fn_list: feature-negotiation list to update
+ * @feat: one of %dccp_feature_numbers
+ * @local: whether local (1) or remote (0) @feat_num is meant
+ * @needs_mandatory: whether to use Mandatory feature negotiation options
+ * @fval: pointer to NN/SP value to be inserted (will be copied)
+ */
+static int dccp_feat_push_change(struct list_head *fn_list, u8 feat, u8 local,
+				 u8 mandatory, dccp_feat_val *fval)
+{
+	struct dccp_feat_entry *new = dccp_feat_entry_new(fn_list, feat, local);
+
+	if (new = NULL)
+		return -ENOMEM;
+
+	new->feat_num	     = feat;
+	new->is_local	     = local;
+	new->state	     = FEAT_INITIALISING;
+	new->needs_confirm   = 0;
+	new->empty_confirm   = 0;
+	new->val	     = *fval;
+	new->needs_mandatory = mandatory;
+
+	return 0;
+}
+
 static inline void dccp_feat_list_pop(struct dccp_feat_entry *entry)
 {
 	list_del(&entry->node);
@@ -190,6 +259,95 @@ cloning_failed:
 	return -ENOMEM;
 }
 
+static u8 dccp_feat_is_valid_nn_val(u8 feat_num, u64 val)
+{
+	switch (feat_num) {
+	case DCCPF_ACK_RATIO:
+		return val <= DCCPF_ACK_RATIO_MAX;
+	case DCCPF_SEQUENCE_WINDOW:
+		return val >= DCCPF_SEQ_WMIN && val <= DCCPF_SEQ_WMAX;
+	}
+	return 0;	/* feature unknown - so we can't tell */
+}
+
+/* check that SP values are within the ranges defined in RFC 4340 */
+static u8 dccp_feat_is_valid_sp_val(u8 feat_num, u8 val)
+{
+	switch (feat_num) {
+	case DCCPF_CCID:
+		return val = DCCPC_CCID2 || val = DCCPC_CCID3;
+	/* Type-check Boolean feature values: */
+	case DCCPF_SHORT_SEQNOS:
+	case DCCPF_ECN_INCAPABLE:
+	case DCCPF_SEND_ACK_VECTOR:
+	case DCCPF_SEND_NDP_COUNT:
+	case DCCPF_DATA_CHECKSUM:
+	case DCCPF_SEND_LEV_RATE:
+		return val < 2;
+	case DCCPF_MIN_CSUM_COVER:
+		return val < 16;
+	}
+	return 0;			/* feature unknown */
+}
+
+static u8 dccp_feat_sp_list_ok(u8 feat_num, u8 const *sp_list, u8 sp_len)
+{
+	if (sp_list = NULL || sp_len < 1)
+		return 0;
+	while (sp_len--)
+		if (!dccp_feat_is_valid_sp_val(feat_num, *sp_list++))
+			return 0;
+	return 1;
+}
+
+/**
+ * __feat_register_nn  -  Register new NN value on socket
+ * @fn: feature-negotiation list to register with
+ * @feat: an NN feature from %dccp_feature_numbers
+ * @mandatory: use Mandatory option if 1
+ * @nn_val: value to register (restricted to 4 bytes)
+ * Note that NN features are local by definition (RFC 4340, 6.3.2).
+ */
+static int __feat_register_nn(struct list_head *fn, u8 feat,
+			      u8 mandatory, u64 nn_val)
+{
+	dccp_feat_val fval = { .nn = nn_val };
+
+	if (dccp_feat_type(feat) != FEAT_NN ||
+	    !dccp_feat_is_valid_nn_val(feat, nn_val))
+		return -EINVAL;
+
+	/* Don't bother with default values, they will be activated anyway. */
+	if (nn_val - (u64)dccp_feat_default_value(feat) = 0)
+		return 0;
+
+	return dccp_feat_push_change(fn, feat, 1, mandatory, &fval);
+}
+
+/**
+ * __feat_register_sp  -  Register new SP value/list on socket
+ * @fn: feature-negotiation list to register with
+ * @feat: an SP feature from %dccp_feature_numbers
+ * @is_local: whether the local (1) or the remote (0) @feat is meant
+ * @mandatory: use Mandatory option if 1
+ * @sp_val: SP value followed by optional preference list
+ * @sp_len: length of @sp_val in bytes
+ */
+static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
+			      u8 mandatory, u8 const *sp_val, u8 sp_len)
+{
+	dccp_feat_val fval;
+
+	if (dccp_feat_type(feat) != FEAT_SP ||
+	    !dccp_feat_sp_list_ok(feat, sp_val, sp_len))
+		return -EINVAL;
+
+	if (dccp_feat_clone_sp_val(&fval, sp_val, sp_len))
+		return -ENOMEM;
+
+	return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
+}
+
 int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
 		     u8 *val, u8 len, gfp_t gfp)
 {
@@ -726,42 +884,30 @@ out_clean:
 
 EXPORT_SYMBOL_GPL(dccp_feat_clone);
 
-static int __dccp_feat_init(struct dccp_minisock *dmsk, u8 type, u8 feat,
-			    u8 *val, u8 len)
-{
-	int rc = -ENOMEM;
-	u8 *copy = kmemdup(val, len, GFP_KERNEL);
-
-	if (copy != NULL) {
-		rc = dccp_feat_change(dmsk, type, feat, copy, len, GFP_KERNEL);
-		if (rc)
-			kfree(copy);
-	}
-	return rc;
-}
-
-int dccp_feat_init(struct dccp_minisock *dmsk)
+int dccp_feat_init(struct sock *sk)
 {
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_minisock *dmsk = dccp_msk(sk);
 	int rc;
 
-	INIT_LIST_HEAD(&dmsk->dccpms_pending);
-	INIT_LIST_HEAD(&dmsk->dccpms_conf);
+	INIT_LIST_HEAD(&dmsk->dccpms_pending);	/* XXX no longer used */
+	INIT_LIST_HEAD(&dmsk->dccpms_conf);	/* XXX no longer used */
 
 	/* CCID L */
-	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_L, DCCPF_CCID,
-			      &dmsk->dccpms_tx_ccid, 1);
+	rc = __feat_register_sp(&dp->dccps_featneg, DCCPF_CCID, 1, 0,
+				&dmsk->dccpms_tx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* CCID R */
-	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_R, DCCPF_CCID,
-			      &dmsk->dccpms_rx_ccid, 1);
+	rc = __feat_register_sp(&dp->dccps_featneg, DCCPF_CCID, 0, 0,
+				&dmsk->dccpms_rx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* Ack ratio */
-	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
-			      &dmsk->dccpms_ack_ratio, 1);
+	rc = __feat_register_nn(&dp->dccps_featneg, DCCPF_ACK_RATIO, 0,
+				dmsk->dccpms_ack_ratio);
 out:
 	return rc;
 }
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -202,7 +202,7 @@ int dccp_init_sock(struct sock *sk, cons
 	 * setsockopt(CCIDs-I-want/accept). -acme
 	 */
 	if (likely(ctl_sock_initialized)) {
-		int rc = dccp_feat_init(dmsk);
+		int rc = dccp_feat_init(sk);
 
 		if (rc)
 			return rc;
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -25,7 +25,7 @@
 /*
  * This implementation should follow RFC 4341
  */
-
+#include "../feat.h"
 #include "../ccid.h"
 #include "../dccp.h"
 #include "ccid2.h"
@@ -147,8 +147,8 @@ static void ccid2_change_l_ack_ratio(str
 		DCCP_WARN("Limiting Ack Ratio (%u) to %u\n", val, max_ratio);
 		val = max_ratio;
 	}
-	if (val > 0xFFFF)		/* RFC 4340, 11.3 */
-		val = 0xFFFF;
+	if (val > DCCPF_ACK_RATIO_MAX)
+		val = DCCPF_ACK_RATIO_MAX;
 
 	if (val = dp->dccps_l_ack_ratio)
 		return;
