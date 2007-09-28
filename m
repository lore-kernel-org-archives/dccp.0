From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 28 Sep 2007 15:30:25 +0000
Subject: [PATCH 5/9]: Glue function to support sockopt code
Message-Id: <200709281630.25278@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Glue function to support sockopt code

This adds a glue function so that change requests can still be made via setsockopt
calls. This is useful for testing and maybe even from an API point of view.

The test whether the socket is not already connected is made deeper in the function
call hierarchy - when dccp_feat_register_change is called. This is on purpose, since
it enables to write further functions on top of the latter function without having
to test for this condition in each calling function.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c  |   67 +++++++++++++++++++------------------------------------
 net/dccp/feat.h  |    4 +--
 net/dccp/proto.c |   45 +++++++++++-------------------------
 3 files changed, 40 insertions(+), 76 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -101,8 +101,8 @@ static inline void dccp_feat_debug(const
 #define dccp_feat_debug(type, feat, val)
 #endif /* CONFIG_IP_DCCP_DEBUG */
 
-extern int  dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
-			     u8 *val, u8 len, gfp_t gfp);
+extern int  dccp_feat_register_change(struct sock *sk, u8 feat,
+				      u8 is_local, u8 *val, u8 len);
 extern int  dccp_feat_change_recv(struct sock *sk, u8 type, u8 feature,
 				  u8 *val, u8 len);
 extern int  dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -444,36 +444,29 @@ static int dccp_setsockopt_service(struc
 	return 0;
 }
 
-static int dccp_setsockopt_change(struct sock *sk, int type,
-				  struct dccp_so_feat __user *optval)
+static int dccp_setsockopt_change(struct sock *sk, char __user *optval,
+				  int optlen, bool is_local)
 {
 	struct dccp_so_feat opt;
 	u8 *val;
-	int rc;
+	int rc = -EFAULT;
 
-	if (copy_from_user(&opt, optval, sizeof(opt)))
+	if (optlen != sizeof(struct dccp_so_feat))
+		return -EINVAL;
+
+	if (copy_from_user(&opt, optval, sizeof(struct dccp_so_feat)))
 		return -EFAULT;
 
 	val = kmalloc(opt.dccpsf_len, GFP_KERNEL);
-	if (!val)
+	if (val = NULL)
 		return -ENOMEM;
 
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
+	if (copy_from_user(val, opt.dccpsf_val, opt.dccpsf_len) = 0)
+		rc = dccp_feat_register_change(sk, opt.dccpsf_feat, is_local,
+					       val, opt.dccpsf_len);
 
-out_free_val:
 	kfree(val);
-	goto out;
+	return rc;
 }
 
 static int do_dccp_setsockopt(struct sock *sk, int level, int optname,
@@ -498,20 +491,10 @@ static int do_dccp_setsockopt(struct soc
 		err = 0;
 		break;
 	case DCCP_SOCKOPT_CHANGE_L:
-		if (optlen != sizeof(struct dccp_so_feat))
-			err = -EINVAL;
-		else
-			err = dccp_setsockopt_change(sk, DCCPO_CHANGE_L,
-						     (struct dccp_so_feat __user *)
-						     optval);
+		err = dccp_setsockopt_change(sk, optval, optlen, true);
 		break;
 	case DCCP_SOCKOPT_CHANGE_R:
-		if (optlen != sizeof(struct dccp_so_feat))
-			err = -EINVAL;
-		else
-			err = dccp_setsockopt_change(sk, DCCPO_CHANGE_R,
-						     (struct dccp_so_feat __user *)
-						     optval);
+		err = dccp_setsockopt_change(sk, optval, optlen, false);
 		break;
 	case DCCP_SOCKOPT_SERVER_TIMEWAIT:
 		if (dp->dccps_role != DCCP_ROLE_SERVER)
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -385,54 +385,35 @@ static int dccp_feat_register_sp(struct 
 	return dccp_feat_push_change(fn, feat, is_local, mandatory, &fval);
 }
 
-int dccp_feat_change(struct dccp_minisock *dmsk, u8 type, u8 feature,
-		     u8 *val, u8 len, gfp_t gfp)
+/**
+ * dccp_feat_register_change  -  Register requests for feature negotiation
+ * @sk: client or listening socket
+ * @feat: one of %dccp_feature_numbers
+ * @is_local: whether the local (1) or remote (0) @feat is meant
+ * @val: either interpreted as u64* (NN) or u8* value/list (SP)
+ * @len: length of @val in bytes
+ */
+int dccp_feat_register_change(struct sock *sk, u8 feat, u8 is_local,
+			      u8 *val, u8 len)
 {
-	struct dccp_opt_pend *opt;
-
-	dccp_feat_debug(type, feature, *val);
+	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
+	u8 type = dccp_feat_type(feat);
 
-	if (len > 3) {
-		DCCP_WARN("invalid length %d\n", len);
-		return 1;
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
+	/* any changes must be registered before establishing the connection */
+	if (sk->sk_state != DCCP_CLOSED)
+		return -EISCONN;
+
+	if (type = FEAT_SP)
+		return dccp_feat_register_sp(fn, feat, is_local, 0, val, len);
+	else if (type = FEAT_NN) {
+		/* Change R is invalid for NN (6.3.2) */
+		if (len != sizeof(u64) || !is_local)
+			return -EINVAL;
+		return dccp_feat_register_nn(fn, feat, 0, *(u64 *)val);
 	}
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
+	return -EINVAL;
 }
 
-EXPORT_SYMBOL_GPL(dccp_feat_change);
-
 /*
  *	Tracking features whose value depend on the choice of CCID
  *
