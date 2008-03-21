From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 21 Mar 2008 13:22:07 +0000
Subject: [DCCP] [RFC] [Patch 1/1]: Deprecate dccp_so_feat interface
Message-Id: <20080321132207.GB12850@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch regards the DCCP test tree and is with regard to removing
the old socket interface (DCCP_SOCKOPT_CHANGE_L/R) which used the
following struct:

	struct dccp_so_feat {
	      __u8            dccpsf_feat;
	      void __user     *dccpsf_val;
       	      _u8             dccpsf_len;
	};

Originally there was code to keep supporting this interface, but
this was extremely ugly and unsafe (can be seen in the patch), since

  * `dccpsf_val' can be either server-priority list or single value;
  * if it is a single value, it requires typecasting as u64 (which
    is the base format for NN values, to accommodate Sequence Window);
  * it is very low-level - the test tree now handles the full 
    negotiation handshake by itself; it is not necessary to set a
    socket option to send ChangeL/R options.

Some of the ugliness can be seen in the patch. The proposed replacement is:

  * a separate socket option for all features of interest;
  * two internal routines local to feat.c:
    	__feat_register_sp() -- for Server-Priority features;
    	__feat_register_nn() -- for Non-Negotiable features.
  * wrappers around the internal functions to work with the sockopt code:
    	dccp_feat_register_sp()
	dccp_feat_register_nn()

This patch keeps the old socket options and issues a warning - maybe it
should also return a negative error code (EOPNOTSUPP)?

To me this design seems cleaner & safer - comments welcome.

---
 include/linux/dccp.h |   12 ---------
 net/dccp/feat.c      |   67 +++++++++++++++++++++++++--------------------------
 net/dccp/feat.h      |    5 ++-
 net/dccp/proto.c     |    4 +--
 4 files changed, 39 insertions(+), 49 deletions(-)

--- b/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -195,18 +195,6 @@
 	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
-/**
- * struct dccp_so_feat  -  setsockopt struct struct for DCCP_SOCKOPT_CHANGE_X
- * @dccpsf_feat: feature number (from RFC 4340, 6.4 or related)
- * @dccpsf_val: single u64 NN value or SP value (u8) plus preference list (u8)
- * @dccpsf_len: length of @dccpsf_val in bytes (ie. 8 when NN, min 1 when SP)
- */
-struct dccp_so_feat {
-	__u8		dccpsf_feat;
-	void __user	*dccpsf_val;
-	__u8		dccpsf_len;
-};
-
 /* DCCP socket options */
 #define DCCP_SOCKOPT_PACKET_SIZE	1 /* XXX deprecated, without effect */
 #define DCCP_SOCKOPT_SERVICE		2
--- b/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -535,9 +508,9 @@
 		DCCP_WARN("sockopt(PACKET_SIZE) is deprecated: fix your app\n");
 		return 0;
 	case DCCP_SOCKOPT_CHANGE_L:
-		return dccp_setsockopt_change(sk, optval, optlen, true);
 	case DCCP_SOCKOPT_CHANGE_R:
-		return dccp_setsockopt_change(sk, optval, optlen, false);
+		DCCP_WARN("sockopt(CHANGE_L/R) is deprecated: fix your app\n");
+		return 0;
 	case DCCP_SOCKOPT_CCID:
 	case DCCP_SOCKOPT_RX_CCID:
 	case DCCP_SOCKOPT_TX_CCID:
--- b/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -108,8 +108,9 @@
 
 extern int  dccp_feat_init(struct sock *sk);
 extern void dccp_feat_initialise_sysctls(void);
-extern int  dccp_feat_register_change(struct sock *sk, u8 feat,
-				      u8 is_local, u8 *val, u8 len);
+extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
+				  u8 const *list, u8 len);
+extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
 				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -668,15 +668,15 @@
 }
 
 /**
- * dccp_feat_register_nn  -  Register new NN value on socket
+ * __feat_register_nn  -  Register new NN value on socket
  * @fn: feature-negotiation list to register with
  * @feat: an NN feature from %dccp_feature_numbers
  * @mandatory: use Mandatory option if 1
  * @nn_val: value to register (restricted to 4 bytes)
  * Note that NN features are local by definition (RFC 4340, 6.3.2).
  */
-static int dccp_feat_register_nn(struct list_head *fn, u8 feat,
-				 u8 mandatory, u64 nn_val)
+static int __feat_register_nn(struct list_head *fn, u8 feat,
+			      u8 mandatory, u64 nn_val)
 {
 	dccp_feat_val fval = { .nn = nn_val };
 
@@ -692,7 +692,7 @@
 }
 
 /**
- * dccp_feat_register_sp  -  Register new SP value/list on socket
+ * __feat_register_sp  -  Register new SP value/list on socket
  * @fn: feature-negotiation list to register with
  * @feat: an SP feature from %dccp_feature_numbers
  * @is_local: whether the local (1) or the remote (0) @feat is meant
@@ -700,8 +700,8 @@
  * @sp_val: SP value followed by optional preference list
  * @sp_len: length of @sp_val in bytes
  */
-static int dccp_feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
-				 u8 mandatory, u8 const *sp_val, u8 sp_len)
+static int __feat_register_sp(struct list_head *fn, u8 feat, u8 is_local,
+			      u8 mandatory, u8 const *sp_val, u8 sp_len)
 {
 	dccp_feat_val fval;
 
@@ -720,32 +720,33 @@
 }
 
 /**
- * dccp_feat_register_change  -  Register requests for feature negotiation
+ * dccp_feat_register_sp  -  Register requests to change SP feature values
  * @sk: client or listening socket
  * @feat: one of %dccp_feature_numbers
  * @is_local: whether the local (1) or remote (0) @feat is meant
- * @val: either interpreted as u64* (NN) or u8* value/list (SP)
- * @len: length of @val in bytes
+ * @list: array of preferred values, in descending order of preference
+ * @len: length of @list in bytes
  */
-int dccp_feat_register_change(struct sock *sk, u8 feat, u8 is_local,
-			      u8 *val, u8 len)
-{
-	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
-	u8 type = dccp_feat_type(feat);
+int dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
+			  u8 const *list, u8 len)
+{	 /* any changes must be registered before establishing the connection */
+	if (sk->sk_state != DCCP_CLOSED)
+		return -EISCONN;
+	if (dccp_feat_type(feat) != FEAT_SP)
+		return -EINVAL;
+	return __feat_register_sp(&dccp_sk(sk)->dccps_featneg, feat, is_local,
+				  0, list, len);
+}
 
+/* Analogous to dccp_feat_register_sp(), but for non-negotiable values */
+int dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val)
+{
 	/* any changes must be registered before establishing the connection */
 	if (sk->sk_state != DCCP_CLOSED)
 		return -EISCONN;
-
-	if (type = FEAT_SP)
-		return dccp_feat_register_sp(fn, feat, is_local, 0, val, len);
-	else if (type = FEAT_NN) {
-		/* Change R is invalid for NN (6.3.2) */
-		if (len != sizeof(u64) || !is_local)
-			return -EINVAL;
-		return dccp_feat_register_nn(fn, feat, 0, *(u64 *)val);
-	}
-	return -EINVAL;
+	if (dccp_feat_type(feat) != FEAT_NN)
+		return -EINVAL;
+	return __feat_register_nn(&dccp_sk(sk)->dccps_featneg, feat, 0, val);
 }
 
 /**
@@ -906,14 +907,14 @@
 
 	for (i = 0; rc = 0 && table[i].dependent_feat != DCCPF_RESERVED; i++)
 		if (dccp_feat_type(table[i].dependent_feat) = FEAT_SP)
-			rc = dccp_feat_register_sp(fn, table[i].dependent_feat,
-						       table[i].is_local,
-						       table[i].is_mandatory,
-						      &table[i].val, 1);
+			rc = __feat_register_sp(fn, table[i].dependent_feat,
+						    table[i].is_local,
+						    table[i].is_mandatory,
+						    &table[i].val, 1);
 		else
-			rc = dccp_feat_register_nn(fn, table[i].dependent_feat,
-						       table[i].is_mandatory,
-						       table[i].val);
+			rc = __feat_register_nn(fn, table[i].dependent_feat,
+						    table[i].is_mandatory,
+						    table[i].val);
 	return rc;
 }
 
@@ -1446,10 +1447,10 @@
 		rc = -ENOPROTOOPT;
 
 	for (i = 0; rc = 0 && i < ARRAY_SIZE(nn); i++)
-		rc = dccp_feat_register_nn(fn, nn[i].feat_num, 0, nn[i].val);
+		rc = __feat_register_nn(fn, nn[i].feat_num, 0, nn[i].val);
 
 	for (i = 0; rc = 0 && i < ARRAY_SIZE(sp); i++)
-		rc = dccp_feat_register_sp(fn, sp[i].feat_num, sp[i].is_local,
+		rc = __feat_register_sp(fn, sp[i].feat_num, sp[i].is_local,
 					sp[i].mandatory, sp[i].val, sp[i].len);
 
 	kfree(sp[0].val);
