From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:14 +0000
Subject: [PATCH 1/9]: Registration routines for changing feature values
Message-Id: <200709281630.14291@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Registration routines for changing feature values

Two registration routines, for SP and NN features, are provided by this patch,
replacing a previous routine which was used for both feature types.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c  |  120 ++++++++++++++++++++++++++++++++++++++++++++-----------
 net/dccp/feat.h  |    2 
 net/dccp/proto.c |    2 
 3 files changed, 99 insertions(+), 25 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -294,6 +294,92 @@ cloning_failed:
 	return -ENOMEM;
 }
 
+static u8 dccp_feat_is_valid_nn_val(u8 feat_num, u64 val)
+{
+	switch (feat_num) {
+		/* Ack Ratio takes 2-byte integer values (11.3) */
+		case DCCPF_ACK_RATIO:       return (val <= 0xFFFF);
+		/* Must be between Wmin2 and Wmax=2^46-1 (7.5.2) */
+		case DCCPF_SEQUENCE_WINDOW: return (val >= 32 &&
+						    val <= 0x3FFFFFFFFFFFull);
+	}
+	return 0;	/* feature unknown - so we can't tell */
+}
+
+/* check that SP values are within the ranges defined in RFC 4340 */
+static u8 dccp_feat_is_valid_sp_val(u8 feat_num, u8 val)
+{
+	switch (feat_num) {
+	case DCCPF_CCID:		return val = 2 || val = 3;
+	case DCCPF_SHORT_SEQNOS:	/* fall through */
+	case DCCPF_ECN_INCAPABLE:	/* fall through */
+	case DCCPF_SEND_ACK_VECTOR:	/* fall through */
+	case DCCPF_SEND_NDP_COUNT:	/* fall through */
+	case DCCPF_DATA_CHECKSUM:	/* fall through */
+	case DCCPF_SEND_LEV_RATE:	return val < 2;
+	case DCCPF_MIN_CSUM_COVER:	return val < 16;
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
+ * dccp_feat_register_nn  -  Register new NN value on socket
+ * @fn: feature-negotiation list to register with
+ * @feat: an NN feature from %dccp_feature_numbers
+ * @mandatory: use Mandatory option if 1
+ * @nn_val: value to register (restricted to 4 bytes)
+ * Note that NN features are local by definition (RFC 4340, 6.3.2).
+ */
+static int dccp_feat_register_nn(struct list_head *fn, u8 feat,
+				 u8 mandatory, u64 nn_val)
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
+ * dccp_feat_register_sp  -  Register new SP value/list on socket
+ * @fn: feature-negotiation list to register with
+ * @feat: an SP feature from %dccp_feature_numbers
+ * @is_local: whether the local (1) or the remote (0) @feat is meant
+ * @mandatory: use Mandatory option if 1
+ * @sp_val: SP value followed by optional preference list
+ * @sp_len: length of @sp_val in bytes
+ */
+static int dccp_feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
+				 u8 mandatory, u8 const *sp_val, u8 sp_len)
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
@@ -830,42 +916,30 @@ out_clean:
 
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
+	rc = dccp_feat_register_sp(&dp->dccps_featneg, DCCPF_CCID, 1, 0,
+				   &dmsk->dccpms_tx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* CCID R */
-	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_R, DCCPF_CCID,
-			      &dmsk->dccpms_rx_ccid, 1);
+	rc = dccp_feat_register_sp(&dp->dccps_featneg, DCCPF_CCID, 0, 0,
+				   &dmsk->dccpms_rx_ccid, 1);
 	if (rc)
 		goto out;
 
 	/* Ack ratio */
-	rc = __dccp_feat_init(dmsk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
-			      &dmsk->dccpms_ack_ratio, 1);
+	rc = dccp_feat_register_nn(&dp->dccps_featneg, DCCPF_ACK_RATIO, 0,
+				   dmsk->dccpms_ack_ratio);
 out:
 	return rc;
 }
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -96,6 +96,6 @@ extern int  dccp_feat_confirm_recv(struc
 extern void dccp_feat_clean(struct dccp_minisock *dmsk);
 extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
-extern int  dccp_feat_init(struct dccp_minisock *dmsk);
+extern int  dccp_feat_init(struct sock *sk);
 
 #endif /* _DCCP_FEAT_H */
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -186,7 +186,7 @@ int dccp_init_sock(struct sock *sk, cons
 	 * setsockopt(CCIDs-I-want/accept). -acme
 	 */
 	if (likely(ctl_sock_initialized)) {
-		int rc = dccp_feat_init(dmsk);
+		int rc = dccp_feat_init(sk);
 
 		if (rc)
 			return rc;
