From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:44:46 +0000
Subject: [PATCH 11/37] dccp: Deprecate old setsockopt framework
Message-Id: <1219945512-7723-12-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The previous setsockopt interface, which passed socket options via struct
dccp_so_feat, is complicated/difficult to use. Continuing to support it leads to
ugly code since the old approach did not distinguish between NN and SP values.

This patch removes the old setsockopt interface and replaces it with two new
functions to register NN/SP values for feature negotiation. These are
essentially wrappers around the internal __feat_register functions, with
checking added to avoid
 * wrong usage (type);
 * changing values while the connection is in progress.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    7 -----
 net/dccp/feat.c      |   72 ++++++++++++++++++-------------------------------
 net/dccp/feat.h      |    5 ++-
 net/dccp/proto.c     |   53 +-----------------------------------
 4 files changed, 32 insertions(+), 105 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -193,13 +193,6 @@ enum dccp_feature_numbers {
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
-/* this structure is argument to DCCP_SOCKOPT_CHANGE_X */
-struct dccp_so_feat {
-	__u8 dccpsf_feat;
-	__u8 __user *dccpsf_val;
-	__u8 dccpsf_len;
-};
-
 /* DCCP socket options */
 #define DCCP_SOCKOPT_PACKET_SIZE	1 /* XXX deprecated, without effect */
 #define DCCP_SOCKOPT_SERVICE		2
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -390,53 +390,35 @@ static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
 	return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
 }
 
-int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
-		     u8 *val, u8 len, gfp_t gfp)
-{
-	struct dccp_opt_pend *opt;
-
-	dccp_feat_debug(type, feature, *val);
-
-	if (len > 3) {
-		DCCP_WARN("invalid length %d\n", len);
+/**
+ * dccp_feat_register_sp  -  Register requests to change SP feature values
+ * @sk: client or listening socket
+ * @feat: one of %dccp_feature_numbers
+ * @is_local: whether the local (1) or remote (0) @feat is meant
+ * @list: array of preferred values, in descending order of preference
+ * @len: length of @list in bytes
+ */
+int dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
+			  u8 const *list, u8 len)
+{	 /* any changes must be registered before establishing the connection */
+	if (sk->sk_state != DCCP_CLOSED)
+		return -EISCONN;
+	if (dccp_feat_type(feat) != FEAT_SP)
 		return -EINVAL;
-	}
-	/* XXX add further sanity checks */
-
-	/* check if that feature is already being negotiated */
-	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
-		/* ok we found a negotiation for this option already */
-		if (opt->dccpop_feat = feature && opt->dccpop_type = type) {
-			dccp_pr_debug("Replacing old\n");
-			/* replace */
-			BUG_ON(opt->dccpop_val = NULL);
-			kfree(opt->dccpop_val);
-			opt->dccpop_val	 = val;
-			opt->dccpop_len	 = len;
-			opt->dccpop_conf = 0;
-			return 0;
-		}
-	}
-
-	/* negotiation for a new feature */
-	opt = kmalloc(sizeof(*opt), gfp);
-	if (opt = NULL)
-		return -ENOMEM;
-
-	opt->dccpop_type = type;
-	opt->dccpop_feat = feature;
-	opt->dccpop_len	 = len;
-	opt->dccpop_val	 = val;
-	opt->dccpop_conf = 0;
-	opt->dccpop_sc	 = NULL;
-
-	BUG_ON(opt->dccpop_val = NULL);
-
-	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_pending);
-	return 0;
+	return __feat_register_sp(&dccp_sk(sk)->dccps_featneg, feat, is_local,
+				  0, list, len);
 }
 
-EXPORT_SYMBOL_GPL(dccp_feat_change);
+/* Analogous to dccp_feat_register_sp(), but for non-negotiable values */
+int dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val)
+{
+	/* any changes must be registered before establishing the connection */
+	if (sk->sk_state != DCCP_CLOSED)
+		return -EISCONN;
+	if (dccp_feat_type(feat) != FEAT_NN)
+		return -EINVAL;
+	return __feat_register_nn(&dccp_sk(sk)->dccps_featneg, feat, 0, val);
+}
 
 /*
  *	Tracking features whose value depend on the choice of CCID
@@ -1134,7 +1116,7 @@ int dccp_feat_init(struct sock *sk)
 
 	/* Ack ratio */
 	rc = __feat_register_nn(&dp->dccps_featneg, DCCPF_ACK_RATIO, 0,
-				dmsk->dccpms_ack_ratio);
+				dp->dccps_l_ack_ratio);
 out:
 	return rc;
 }
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -110,8 +110,9 @@ static inline void dccp_feat_debug(const u8 type, const u8 feat, const u8 val)
 #define dccp_feat_debug(type, feat, val)
 #endif /* CONFIG_IP_DCCP_DEBUG */
 
-extern int  dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
-			     u8 *val, u8 len, gfp_t gfp);
+extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
+				  u8 const *list, u8 len);
+extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
 extern int  dccp_feat_change_recv(struct sock *sk, u8 type, u8 feature,
 				  u8 *val, u8 len);
 extern int  dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -470,44 +470,6 @@ static int dccp_setsockopt_service(struct sock *sk, const __be32 service,
 	return 0;
 }
 
-/* byte 1 is feature.  the rest is the preference list */
-static int dccp_setsockopt_change(struct sock *sk, int type,
-				  struct dccp_so_feat __user *optval)
-{
-	struct dccp_so_feat opt;
-	u8 *val;
-	int rc;
-
-	if (copy_from_user(&opt, optval, sizeof(opt)))
-		return -EFAULT;
-	/*
-	 * rfc4340: 6.1. Change Options
-	 */
-	if (opt.dccpsf_len < 1)
-		return -EINVAL;
-
-	val = kmalloc(opt.dccpsf_len, GFP_KERNEL);
-	if (!val)
-		return -ENOMEM;
-
-	if (copy_from_user(val, opt.dccpsf_val, opt.dccpsf_len)) {
-		rc = -EFAULT;
-		goto out_free_val;
-	}
-
-	rc = dccp_feat_change(dccp_msk(sk), type, opt.dccpsf_feat,
-			      val, opt.dccpsf_len, GFP_KERNEL);
-	if (rc)
-		goto out_free_val;
-
-out:
-	return rc;
-
-out_free_val:
-	kfree(val);
-	goto out;
-}
-
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		char __user *optval, int optlen)
 {
@@ -530,20 +492,9 @@ static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
 		err = 0;
 		break;
 	case DCCP_SOCKOPT_CHANGE_L:
-		if (optlen != sizeof(struct dccp_so_feat))
-			err = -EINVAL;
-		else
-			err = dccp_setsockopt_change(sk, DCCPO_CHANGE_L,
-						     (struct dccp_so_feat __user *)
-						     optval);
-		break;
 	case DCCP_SOCKOPT_CHANGE_R:
-		if (optlen != sizeof(struct dccp_so_feat))
-			err = -EINVAL;
-		else
-			err = dccp_setsockopt_change(sk, DCCPO_CHANGE_R,
-						     (struct dccp_so_feat __user *)
-						     optval);
+		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
+		err = 0;
 		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		if (dp->dccps_role != DCCP_ROLE_SERVER)
-- 
1.6.0.rc2

