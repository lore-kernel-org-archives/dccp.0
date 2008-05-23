From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 23 May 2008 11:09:39 +0000
Subject: [RFT] [Announce]: DCCP Test Tree Updated
Message-Id: <20080523110939.GA14843@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is an annotated list of changes/fixes for the DCCP test tree, these fixes
have been applied, and the updated tree has been uploaded to 

	git://eden-feed.erg.abdn.ac.uk/dccp_exp
	subtree 'dccp' and 'ccid4'

--------------------------------------------------------------------------------
(1) Let dccp_feat_init() return proper return value instead of always -EPROTO.
--------------------------------------------------------------------------------
--- b/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -191,14 +191,12 @@
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
 	dp->dccps_tx_qlen	= sysctl_dccp_tx_qlen;
 
+	dccp_init_xmit_timers(sk);
+
 	INIT_LIST_HEAD(&dp->dccps_featneg);
 	/* control socket doesn't need feat nego */
 	if (likely(ctl_sock_initialized))
-		if (dccp_feat_init(sk))
-			return -EPROTO;
-
-	dccp_init_xmit_timers(sk);
-
+		return dccp_feat_init(sk);
 	return 0;
 }
--------------------------------------------------------------------------------
(2) The feature negotiation initialisation has been overhauled with regard to
    => replaced function to initialise the sysctls with manual initialisation;
    => resolved memory leak: in some cases, dccp_feat_init() returned an
                             error without de-allocating the preference lists
			     for the TX/RX CCIDs;
    => removed clumsy tables for the initialisation;			     
--------------------------------------------------------------------------------
--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -27,17 +27,16 @@
 #include "ccid.h"
 #include "feat.h"
 
-/* sysctls related to initialisation of option values */
-unsigned long	sysctl_dccp_feat_sequence_window;
-int		sysctl_dccp_feat_rx_ccid,
-		sysctl_dccp_feat_tx_ccid;
+/* feature-specific sysctls - initialised to the defaults from RFC 4340, 6.4 */
+unsigned long	sysctl_dccp_sequence_window __read_mostly = 100;
+int		sysctl_dccp_rx_ccid	    __read_mostly = 2,
+		sysctl_dccp_tx_ccid	    __read_mostly = 2;
 
 /*
  * Feature activation handlers.
  *
- * This uses an u64 argument in all cases to provide enough room for NN/SP
- * features. Verifiying that the values are within their allowed range happens
- * earlier and is not something that should be done at this late stage.
+ * These all use an u64 argument, to provide enough room for NN/SP features. At
+ * this stage the negotiated values have been checked to be within their range.
  */
 static int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx)
 {
@@ -1370,55 +1369,43 @@
 	return 0;	/* ignore FN options in all other states */
 }
 
-/* initialise sysctls with default values from the table */
-void __init dccp_feat_initialise_sysctls(void)
-{
-	sysctl_dccp_feat_rx_ccid = dccp_feat_default_value(DCCPF_CCID);
-	sysctl_dccp_feat_tx_ccid = dccp_feat_default_value(DCCPF_CCID);
-	sysctl_dccp_feat_sequence_window -				dccp_feat_default_value(DCCPF_SEQUENCE_WINDOW);
-}
-
 /**
  * dccp_feat_init  -  Seed feature negotiation with host-specific defaults
  * This initialises global defaults, depending on the value of the sysctls.
  * These can later be overridden by registering changes via setsockopt calls.
  * The last link in the chain is finalise_settings, to make sure that between
  * here and the start of actual feature negotiation no inconsistencies enter.
+ *
+ * All features not appearing below use either defaults or are otherwise
+ * later adjusted through dccp_feat_finalise_settings().
  */
 int dccp_feat_init(struct sock *sk)
 {
 	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
 	u8 on = 1, off = 0;
-	int rc = 0, i;
-	/*
-	 * All features not appearing in these tables use either defaults or
-	 * are later adjusted in dccp_feat_finalise_settings().
-	 */
-	struct {
-		u8	feat_num;
-		u64	val;
-	} nn [] = {
-		{ DCCPF_SEQUENCE_WINDOW, sysctl_dccp_feat_sequence_window },
-		/* Ack Ratio is via sockopt, currently no other NN features */
-	};
+	int rc;
 	struct {
-		u8	feat_num;
-		bool	is_local;
-		bool	mandatory;
-		u8	*val;
-		u8	len;
-	} sp[] = {
-		{ DCCPF_CCID,		true,	false }, /* local  / TX CCID */
-		{ DCCPF_CCID,		false,	false }, /* remote / RX CCID */
-		/* Advertise that short seqnos are not supported (7.6.1) */
-		{ DCCPF_SHORT_SEQNOS,	true,	true, &off, sizeof(off) },
-		/*
-		 * RFC 4340 12.1: "If a DCCP is not ECN capable, it MUST send
-		 * Mandatory `Change L(ECN Incapable, 1)' options [...]".
-		 */
-		{ DCCPF_ECN_INCAPABLE,	true,	true, &on, sizeof(on) },
-	};
+		u8 *val;
+		u8 len;
+	} tx, rx;
+
+	/* Non-negotiable (NN) features */
+	rc = __feat_register_nn(fn, DCCPF_SEQUENCE_WINDOW, 0,
+				    sysctl_dccp_sequence_window);
+	if (rc)
+		return rc;
+
+	/* Server-priority (SP) features */
+
+	/* Advertise that short seqnos are not supported (7.6.1) */
+	rc = __feat_register_sp(fn, DCCPF_SHORT_SEQNOS, true, true, &off, 1);
+	if (rc)
+		return rc;
+
+	/* RFC 4340 12.1: "If a DCCP is not ECN capable, ..." */
+	rc = __feat_register_sp(fn, DCCPF_ECN_INCAPABLE, true, true, &on, 1);
+	if (rc)
+		return rc;
 
 	/*
 	 * We advertise the available list of CCIDs and reorder according to
@@ -1426,27 +1413,28 @@
 	 * singleton values (which always leads to failure).
 	 * These settings can still (later) be overridden via sockopts.
 	 */
-	if (ccid_get_default_ccids(&sp[0].val, &sp[0].len) ||
-	    ccid_get_default_ccids(&sp[1].val, &sp[1].len))
+	if (ccid_get_builtin_ccids(&tx.val, &tx.len) ||
+	    ccid_get_builtin_ccids(&rx.val, &rx.len))
 		return -ENOBUFS;
 
 	/* Pre-load all CCID modules that are going to be advertised */
-	if (ccid_request_modules(sp[0].val, sp[0].len))
-		return -EUNATCH;
-
-	if (!dccp_feat_prefer(sysctl_dccp_feat_tx_ccid, sp[0].val, sp[0].len) ||
-	    !dccp_feat_prefer(sysctl_dccp_feat_rx_ccid, sp[1].val, sp[1].len))
-		rc = -ENOPROTOOPT;
-
-	for (i = 0; rc = 0 && i < ARRAY_SIZE(nn); i++)
-		rc = __feat_register_nn(fn, nn[i].feat_num, 0, nn[i].val);
-
-	for (i = 0; rc = 0 && i < ARRAY_SIZE(sp); i++)
-		rc = __feat_register_sp(fn, sp[i].feat_num, sp[i].is_local,
-					sp[i].mandatory, sp[i].val, sp[i].len);
-
-	kfree(sp[0].val);
-	kfree(sp[1].val);
+	rc = -EUNATCH;
+	if (ccid_request_modules(tx.val, tx.len))
+		goto free_ccid_lists;
+
+	if (!dccp_feat_prefer(sysctl_dccp_tx_ccid, tx.val, tx.len) ||
+	    !dccp_feat_prefer(sysctl_dccp_rx_ccid, rx.val, rx.len))
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
--------------------------------------------------------------------------------
(3) The following functions have been renamed for consistency.
--------------------------------------------------------------------------------
--- b/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -99,10 +99,10 @@
 	return (void *)ccid->ccid_priv;
 }
 
-extern int  ccid_get_default_ccids(u8 **ccid_array, u8 *array_len);
 extern bool ccid_support_check(u8 const *ccid_array, u8 array_len);
-extern int  ccid_getsockopt_available_ccids(struct sock *sk, int len,
-					    char __user *, int __user *);
+extern int  ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len);
+extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
+					  char __user *, int __user *);
-- 
