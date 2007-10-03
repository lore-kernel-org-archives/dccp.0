From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:49 +0000
Subject: [PATCH 10/14]: Initialisation framework for feature negotiation
Message-Id: <200710031502.49899@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Initialisation framework for feature negotiation

This initialises feature negotiation from two tables, which are initialised
from sysctls. Furthermore, specifics of the implementation (e.g. currently
short seqnos and ECN are not supported) are advertised for robustness.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |   19 -------------
 net/dccp/feat.c      |   71 +++++++++++++++++++++++++++++++++++++++++++--------
 net/dccp/feat.h      |    2 -
 3 files changed, 61 insertions(+), 31 deletions(-)

--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -101,12 +101,12 @@ static inline void dccp_feat_debug(const
 #define dccp_feat_debug(type, feat, val)
 #endif /* CONFIG_IP_DCCP_DEBUG */
 
+extern int  dccp_feat_init(struct sock *sk);
 extern int  dccp_feat_register_change(struct sock *sk, u8 feat,
 				      u8 is_local, u8 *val, u8 len);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
 				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
-extern int  dccp_feat_init(struct sock *sk);
 
 /*
  * Determining lengths of variable-length options.
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1016,24 +1016,73 @@ int dccp_feat_parse_options(struct sock 
 	return 0;	/* ignore FN options in all other states */
 }
 
+/**
+ * dccp_feat_init  -  Seed feature negotiation with host-specific defaults
+ * This initialises global defaults, depending on the value of the sysctls.
+ * These can later be overridden by registering changes via setsockopt calls.
+ * The last link in the chain is finalise_settings, to make sure that between
+ * here and the start of actual feature negotiation no inconsistencies enter.
+ */
 int dccp_feat_init(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	int rc;
+	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
+	u8 on = 1, off = 0;
+	int rc = 0, i;
+	/*
+	 * All features not appearing in these tables use either defaults or
+	 * are later adjusted in dccp_feat_finalise_settings().
+	 */
+	struct {
+		u8	feat_num;
+		u64	val;
+	} nn [] = {
+		{ DCCPF_SEQUENCE_WINDOW, sysctl_dccp_feat_sequence_window },
+		/* ACK Ratio may be overridden due to choice of CCID */
+		{ DCCPF_ACK_RATIO,	 sysctl_dccp_feat_ack_ratio }
+	};
+	struct {
+		u8	feat_num;
+		bool	is_local;
+		bool	mandatory;
+		u8	*val;
+		u8	len;
+	} sp[] = {
+		{ DCCPF_CCID,		true,	false }, /* local  / TX CCID */
+		{ DCCPF_CCID,		false,	false }, /* remote / RX CCID */
+		/* Advertise that short seqnos are not supported (7.6.1) */
+		{ DCCPF_SHORT_SEQNOS,	true,	true, &off, sizeof(off) },
+		/*
+		 * RFC 4340 12.1: "If a DCCP is not ECN capable, it MUST send
+		 * Mandatory `Change L(ECN Incapable, 1)' options [...]".
+		 */
+		{ DCCPF_ECN_INCAPABLE,	true,	true, &on, sizeof(on) },
+	};
 
-	INIT_LIST_HEAD(&dmsk->dccpms_pending);	/* XXX no longer used */
-	INIT_LIST_HEAD(&dmsk->dccpms_conf);	/* XXX no longer used */
+	/*
+	 * We advertise the available list of CCIDs and reorder according to
+	 * preferences, since negotiating conflicting singleton values inevitably
+	 * leads to failure (can still be overridden via sockopts).
+	 */
+	if (ccid_get_default_ccids(&sp[0].val, &sp[0].len) ||
+	    ccid_get_default_ccids(&sp[1].val, &sp[1].len))
+		return -ENOBUFS;
+
+	if (!dccp_feat_prefer(sysctl_dccp_feat_tx_ccid, sp[0].val, sp[0].len) ||
+	    !dccp_feat_prefer(sysctl_dccp_feat_rx_ccid, sp[1].val, sp[1].len))
+		rc = -ENOPROTOOPT;
+
+	for (i = 0; rc = 0 && i < ARRAY_SIZE(nn); i++)
+		rc = dccp_feat_register_nn(fn, nn[i].feat_num, 0, nn[i].val);
+
+	for (i = 0; rc = 0 && i < ARRAY_SIZE(sp); i++)
+		rc = dccp_feat_register_sp(fn, sp[i].feat_num, sp[i].is_local,
+					sp[i].mandatory, sp[i].val, sp[i].len);
 
-	/* Ack ratio */
-	rc = dccp_feat_register_nn(&dp->dccps_featneg, DCCPF_ACK_RATIO, 0,
-				   dmsk->dccpms_ack_ratio);
-out:
+	kfree(sp[0].val);
+	kfree(sp[1].val);
 	return rc;
 }
 
-EXPORT_SYMBOL_GPL(dccp_feat_init);
-
 int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -383,30 +383,11 @@ static inline unsigned int dccp_hdr_len(
   * @dccpms_sequence_window - Sequence Window Feature (section 7.5.2)
   * @dccpms_send_ndp_count - Send NDP Count Feature (7.7.2)
   * @dccpms_ack_ratio - Ack Ratio Feature (section 11.3)
-  * @dccpms_pending - List of features being negotiated
-  * @dccpms_conf -
   */
 struct dccp_minisock {
 	__u64			dccpms_sequence_window;
 	__u8			dccpms_send_ndp_count;
 	__u8			dccpms_ack_ratio;
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
