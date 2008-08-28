From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:45:08 +0000
Subject: [PATCH 33/37] dccp: Initialisation framework for feature negotiation
Message-Id: <1219945512-7723-34-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This initialises feature negotiation from two tables, which are initialised
from sysctls.

As a novel feature, specifics of the implementation (e.g. currently short
seqnos and ECN are not supported) are advertised for robustness.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 include/linux/dccp.h |   19 --------------
 net/dccp/feat.c      |   66 ++++++++++++++++++++++++++++++++++++++++++-------
 net/dccp/feat.h      |    2 +-
 3 files changed, 57 insertions(+), 30 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -369,28 +369,9 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
   * Will be used to pass the state from dccp_request_sock to dccp_sock.
   *
   * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
-  * @dccpms_pending - List of features being negotiated
-  * @dccpms_conf -
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
-	struct list_head	dccpms_pending;
-	struct list_head	dccpms_conf;
-};
-
-struct dccp_opt_conf {
-	__u8			*dccpoc_val;
-	__u8			dccpoc_len;
-};
-
-struct dccp_opt_pend {
-	struct list_head	dccpop_node;
-	__u8			dccpop_type;
-	__u8			dccpop_feat;
-	__u8		        *dccpop_val;
-	__u8			dccpop_len;
-	int			dccpop_conf;
-	struct dccp_opt_conf    *dccpop_sc;
 };
 
 extern void dccp_minisock_init(struct dccp_minisock *dmsk);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1122,24 +1122,70 @@ int dccp_feat_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 	return 0;	/* ignore FN options in all other states */
 }
 
+/**
+ * dccp_feat_init  -  Seed feature negotiation with host-specific defaults
+ * This initialises global defaults, depending on the value of the sysctls.
+ * These can later be overridden by registering changes via setsockopt calls.
+ * The last link in the chain is finalise_settings, to make sure that between
+ * here and the start of actual feature negotiation no inconsistencies enter.
+ *
+ * All features not appearing below use either defaults or are otherwise
+ * later adjusted through dccp_feat_finalise_settings().
+ */
 int dccp_feat_init(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
+	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
+	u8 on = 1, off = 0;
 	int rc;
+	struct {
+		u8 *val;
+		u8 len;
+	} tx, rx;
+
+	/* Non-negotiable (NN) features */
+	rc = __feat_register_nn(fn, DCCPF_SEQUENCE_WINDOW, 0,
+				    sysctl_dccp_feat_sequence_window);
+	if (rc)
+		return rc;
+
+	/* Server-priority (SP) features */
+
+	/* Advertise that short seqnos are not supported (7.6.1) */
+	rc = __feat_register_sp(fn, DCCPF_SHORT_SEQNOS, true, true, &off, 1);
+	if (rc)
+		return rc;
 
-	INIT_LIST_HEAD(&dmsk->dccpms_pending);	/* XXX no longer used */
-	INIT_LIST_HEAD(&dmsk->dccpms_conf);	/* XXX no longer used */
+	/* RFC 4340 12.1: "If a DCCP is not ECN capable, ..." */
+	rc = __feat_register_sp(fn, DCCPF_ECN_INCAPABLE, true, true, &on, 1);
+	if (rc)
+		return rc;
+
+	/*
+	 * We advertise the available list of CCIDs and reorder according to
+	 * preferences, to avoid failure resulting from negotiating different
+	 * singleton values (which always leads to failure).
+	 * These settings can still (later) be overridden via sockopts.
+	 */
+	if (ccid_get_builtin_ccids(&tx.val, &tx.len) ||
+	    ccid_get_builtin_ccids(&rx.val, &rx.len))
+		return -ENOBUFS;
 
-	/* Ack ratio */
-	rc = __feat_register_nn(&dp->dccps_featneg, DCCPF_ACK_RATIO, 0,
-				dp->dccps_l_ack_ratio);
-out:
+	if (!dccp_feat_prefer(sysctl_dccp_feat_tx_ccid, tx.val, tx.len) ||
+	    !dccp_feat_prefer(sysctl_dccp_feat_rx_ccid, rx.val, rx.len))
+		goto free_ccid_lists;
+
+	rc = __feat_register_sp(fn, DCCPF_CCID, true, false, tx.val, tx.len);
+	if (rc)
+		goto free_ccid_lists;
+
+	rc = __feat_register_sp(fn, DCCPF_CCID, false, false, rx.val, rx.len);
+
+free_ccid_lists:
+	kfree(tx.val);
+	kfree(rx.val);
 	return rc;
 }
 
-EXPORT_SYMBOL_GPL(dccp_feat_init);
-
 int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -110,13 +110,13 @@ static inline void dccp_feat_debug(const u8 type, const u8 feat, const u8 val)
 #define dccp_feat_debug(type, feat, val)
 #endif /* CONFIG_IP_DCCP_DEBUG */
 
+extern int  dccp_feat_init(struct sock *sk);
 extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
 				  u8 const *list, u8 len);
 extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
 				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
-extern int  dccp_feat_init(struct sock *sk);
 
 /*
  * Encoding variable-length options and their maximum length.
-- 
1.6.0.rc2

