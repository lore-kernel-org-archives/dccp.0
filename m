From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Oct 2007 14:02:28 +0000
Subject: [PATCH 1/14]: Activation of features after negotiation
Message-Id: <200710031502.28594@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Activation of features after negotiation

This patch provides the post-processing of feature negotiation state, after
the negotiation has completed.

To this purpose, handlers are used and added to the dccp_feat_table. Each handler
is passed a boolean flag whether the RX or TX side of the feature is meant. 

Several handlers are provided already, new handlers can easily be added.

The initialisation is now fully dynamic, i.e. CCIDs are activated only
after the feature negotiation. The integration of this dynamic activation
is done in the subsequent patches.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h      |    1 
 net/dccp/feat.c      |  176 +++++++++++++++++++++++++++++++++++----------------
 net/dccp/minisocks.c |   90 ++++++++++++++++++++++++++
 3 files changed, 212 insertions(+), 55 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -426,6 +426,7 @@ extern int  dccp_feat_finalise_settings(
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
 extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
 				  struct sk_buff *skb);
+extern int  dccp_feat_activate_values(struct sock *sk, struct list_head *fn);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -23,11 +23,20 @@
 #include "ccid.h"
 #include "feat.h"
 
+/* Feature activation handlers */
+extern int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx);
+extern int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx);
+extern int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx);
+extern int dccp_hdlr_ackvec(struct sock *sk, u64 enable, bool rx);
+extern int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx);
+extern int dccp_hdlr_min_cscov(struct sock *sk, u64 cscov, bool rx);
+
 static const struct {
 	u8			feat_num;		/* DCCPF_xxx */
 	enum dccp_feat_type	rxtx;			/* RX or TX  */
 	enum dccp_feat_type	reconciliation;		/* SP or NN  */
 	u8			default_value;		/* as in 6.4 */
+	int (*activation_hdlr)(struct sock *sk, u64 val, bool rx);
 /*
  *    Lookup table for location and type of features (from RFC 4340/4342)
  *  +--------------------------+----+-----+----+----+---------+-----------+
@@ -47,16 +56,16 @@ static const struct {
  *  +--------------------------+----+-----+----+----+---------+-----------+
  */
 } dccp_feat_table[] = {
-	{ DCCPF_CCID,		 FEAT_AT_TX, FEAT_SP, 2 },
-	{ DCCPF_SHORT_SEQNOS,	 FEAT_AT_TX, FEAT_SP, 0 },
-	{ DCCPF_SEQUENCE_WINDOW, FEAT_AT_TX, FEAT_NN, 100 },
-	{ DCCPF_ECN_INCAPABLE,	 FEAT_AT_RX, FEAT_SP, 0 },
-	{ DCCPF_ACK_RATIO,	 FEAT_AT_TX, FEAT_NN, 2 },
-	{ DCCPF_SEND_ACK_VECTOR, FEAT_AT_RX, FEAT_SP, 0 },
-	{ DCCPF_SEND_NDP_COUNT,  FEAT_AT_TX, FEAT_SP, 0 },
-	{ DCCPF_MIN_CSUM_COVER,  FEAT_AT_RX, FEAT_SP, 0 },
-	{ DCCPF_DATA_CHECKSUM,	 FEAT_AT_RX, FEAT_SP, 0 },
-	{ DCCPF_SEND_LEV_RATE,	 FEAT_AT_RX, FEAT_SP, 0 },
+	{ DCCPF_CCID,		 FEAT_AT_TX, FEAT_SP, 2,   dccp_hdlr_ccid     },
+	{ DCCPF_SHORT_SEQNOS,	 FEAT_AT_TX, FEAT_SP, 0,   NULL },
+	{ DCCPF_SEQUENCE_WINDOW, FEAT_AT_TX, FEAT_NN, 100, dccp_hdlr_seq_win  },
+	{ DCCPF_ECN_INCAPABLE,	 FEAT_AT_RX, FEAT_SP, 0,   NULL },
+	{ DCCPF_ACK_RATIO,	 FEAT_AT_TX, FEAT_NN, 2,   dccp_hdlr_ack_ratio},
+	{ DCCPF_SEND_ACK_VECTOR, FEAT_AT_RX, FEAT_SP, 0,   dccp_hdlr_ackvec   },
+	{ DCCPF_SEND_NDP_COUNT,  FEAT_AT_TX, FEAT_SP, 0,   dccp_hdlr_ndp      },
+	{ DCCPF_MIN_CSUM_COVER,  FEAT_AT_RX, FEAT_SP, 0,   dccp_hdlr_min_cscov},
+	{ DCCPF_DATA_CHECKSUM,	 FEAT_AT_RX, FEAT_SP, 0,   NULL },
+	{ DCCPF_SEND_LEV_RATE,	 FEAT_AT_RX, FEAT_SP, 0,   NULL },
 };
 #define DCCP_FEAT_SUPPORTED_MAX		ARRAY_SIZE(dccp_feat_table)
 
@@ -93,6 +102,55 @@ static int dccp_feat_default_value(u8 fe
 	return idx < 0 ? : dccp_feat_table[idx].default_value;
 }
 
+static int __dccp_feat_activate(struct sock *sk, const int idx,
+				const bool is_local, dccp_feat_val const *fval)
+{
+	bool rx;
+	u64 val;
+
+	if (idx < 0 || idx >= DCCP_FEAT_SUPPORTED_MAX)
+		return -1;
+	if (dccp_feat_table[idx].activation_hdlr = NULL)
+		return 0;
+
+	if (fval = NULL) {
+		val = dccp_feat_table[idx].default_value;
+	} else if (dccp_feat_table[idx].reconciliation = FEAT_SP) {
+		if (fval->sp.vec = NULL) {
+			/*
+			 * This can happen when an empty Confirm is sent
+			 * for an SP (i.e. known) feature. In this case
+			 * we would be using the default anyway.
+			 */
+			DCCP_CRIT("Feature #%d undefined: using default", idx);
+			val = dccp_feat_table[idx].default_value;
+		} else {
+			val = fval->sp.vec[0];
+		}
+	} else {
+		val = fval->nn;
+	}
+
+	/* Location is RX if this is a local-RX or remote-TX feature */
+	rx = (is_local = (dccp_feat_table[idx].rxtx = FEAT_AT_RX));
+
+	return dccp_feat_table[idx].activation_hdlr(sk, val, rx);
+}
+
+/**
+ * dccp_feat_activate  -  Activate feature value on socket
+ * @sk: fully connected DCCP socket (after handshake is complete)
+ * @feat_num: feature to activate, one of %dccp_feature_numbers
+ * @local: whether local (1) or remote (0) @feat_num is meant
+ * @fval: the value (SP or NN) to activate, or NULL to mean the default value
+ * For general use this function is preferable over __dccp_feat_activate().
+ */
+static int dccp_feat_activate(struct sock *sk, u8 feat_num, bool local,
+			      dccp_feat_val const *fval)
+{
+	return __dccp_feat_activate(sk, dccp_feat_index(feat_num), local, fval);
+}
+
 /* Test for "Req'd" feature (RFC 4340, 6.4) */
 static inline int dccp_feat_must_be_understood(u8 feat_num)
 {
@@ -657,51 +715,6 @@ int dccp_feat_server_ccid_dependencies(s
 	return 0;
 }
 
-static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	/* figure out if we are changing our CCID or the peer's */
-	const int rx = type = DCCPO_CHANGE_R;
-	const u8 ccid_nr = rx ? dmsk->dccpms_rx_ccid : dmsk->dccpms_tx_ccid;
-	struct ccid *new_ccid;
-
-	/* Check if nothing is being changed. */
-	if (ccid_nr = new_ccid_nr)
-		return 0;
-
-	new_ccid = ccid_new(new_ccid_nr, sk, rx, GFP_ATOMIC);
-	if (new_ccid = NULL)
-		return -ENOMEM;
-
-	if (rx) {
-		ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
-		dp->dccps_hc_rx_ccid = new_ccid;
-		dmsk->dccpms_rx_ccid = new_ccid_nr;
-	} else {
-		ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-		dp->dccps_hc_tx_ccid = new_ccid;
-		dmsk->dccpms_tx_ccid = new_ccid_nr;
-	}
-
-	return 0;
-}
-
-static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, u8 val)
-{
-	dccp_feat_debug(type, feat, val);
-
-	switch (feat) {
-	case DCCPF_CCID:
-		return dccp_feat_update_ccid(sk, type, val);
-	default:
-		dccp_pr_debug("UNIMPLEMENTED: %s(%d, ...)\n",
-			      dccp_feat_typename(type), feat);
-		break;
-	}
-	return 0;
-}
-
 /* Select the first entry in @servlist that also occurs in @clilist (6.3.1) */
 static int dccp_feat_preflist_match(u8 *servlist, u8 slen, u8 *clilist, u8 clen)
 {
@@ -1116,6 +1129,59 @@ out:
 
 EXPORT_SYMBOL_GPL(dccp_feat_init);
 
+int dccp_feat_activate_values(struct sock *sk, struct list_head *fn_list)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct dccp_feat_entry *cur, *next;
+	int idx;
+	dccp_feat_val *fvals[DCCP_FEAT_SUPPORTED_MAX][2] = {
+		 [0 ... DCCP_FEAT_SUPPORTED_MAX-1] = { NULL, NULL }
+	};
+
+	list_for_each_entry(cur, fn_list, node) {
+
+		idx = dccp_feat_index(cur->feat_num);
+		if (cur->state != FEAT_STABLE || idx < 0) {
+			DCCP_BUG("Failed negotiation in state %u", cur->state);
+			goto activation_failed;
+		}
+		fvals[idx][cur->is_local] = &cur->val;
+	}
+
+	/*
+	 * Activate in decreasing order of index, so that the CCIDs are always
+	 * activated as the last feature. This avoids the case where a CCID
+	 * relies on the initialisation of one or more features that it depends
+	 * on (e.g. Send NDP Count, Send Ack Vector, and Ack Ratio features).
+	 */
+	for (idx = DCCP_FEAT_SUPPORTED_MAX; --idx >= 0;)
+		if (__dccp_feat_activate(sk, idx, 0, fvals[idx][0]) ||
+		    __dccp_feat_activate(sk, idx, 1, fvals[idx][1])   )
+			goto activation_failed;
+
+	/* Clean up Change options which have been confirmed already */
+	list_for_each_entry_safe(cur, next, fn_list, node)
+		if (!cur->needs_confirm)
+			dccp_feat_list_pop(cur);
+
+	dccp_pr_debug("Activation OK\n");
+	return 0;
+
+activation_failed:
+	/*
+	 * We clean up everything that may have been allocated, since
+	 * it is difficult to track at which stage negotiation failed.
+	 * This is ok, since all allocation functions below are robust
+	 * against NULL arguments.
+	 */
+	ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+	ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
+	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
+	dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
+	dp->dccps_hc_rx_ackvec = NULL;
+	return -1;
+}
+
 #ifdef CONFIG_IP_DCCP_DEBUG
 const char *dccp_feat_typename(const u8 type)
 {
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -319,3 +319,93 @@ int dccp_reqsk_init(struct request_sock 
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_init);
+
+/*
+ *	Handlers for activating features on the (mini)socket.
+ *
+ * We consistently use an u64 argument in all cases to have enough room;
+ * verifiying that the values are within their allowed range happens earlier
+ * and is not something that should be done at this late stage.
+ */
+int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+	struct ccid *new_ccid = ccid_new(ccid, sk, rx, gfp_any());
+
+	if (new_ccid = NULL)
+		return -ENOMEM;
+
+	if (rx) {
+		ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+		dp->dccps_hc_rx_ccid = new_ccid;
+	} else {
+		ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
+		dp->dccps_hc_tx_ccid = new_ccid;
+	}
+	return 0;
+}
+
+int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
+{
+	if (!rx)
+		dccp_msk(sk)->dccpms_sequence_window = seq_win;
+	return 0;
+}
+
+int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
+{
+	if (rx)
+		dccp_sk(sk)->dccps_r_ack_ratio = ratio;
+	else
+		dccp_sk(sk)->dccps_l_ack_ratio = ratio;
+	return 0;
+}
+
+int dccp_hdlr_ackvec(struct sock *sk, u64 enable, bool rx)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	if (rx) {
+		if (enable && dp->dccps_hc_rx_ackvec = NULL) {
+			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(gfp_any());
+			if (dp->dccps_hc_rx_ackvec = NULL)
+				return -ENOMEM;
+		} else if (!enable) {
+			dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
+			dp->dccps_hc_rx_ackvec = NULL;
+		}
+	}
+	return 0;
+}
+
+int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx)
+{
+	if (!rx)
+		dccp_msk(sk)->dccpms_send_ndp_count = (enable > 0);
+	return 0;
+}
+
+/*
+ * Minimum Checksum Coverage is located at the RX side (9.2.1). This means that
+ * `rx' holds when the sending peer informs about his partial coverage via a
+ * ChangeR() option. In the other case, we are the sender and the receiver
+ * announces its coverage via ChangeL() options. The policy here is to honour
+ * such communication by enabling the corresponding partial coverage - but only
+ * if it has not been set manually before; the warning here means that all
+ * packets will be dropped.
+ */
+int dccp_hdlr_min_cscov(struct sock *sk, u64 cscov, bool rx)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	if (rx)
+		dp->dccps_pcrlen = cscov;
+	else {
+		if (dp->dccps_pcslen = 0)
+			dp->dccps_pcslen = cscov;
+		else if (cscov > dp->dccps_pcslen)
+			DCCP_WARN("CsCov %u too small, peer requires >= %u\n",
+				  dp->dccps_pcslen, (u8)cscov);
+	}
+	return 0;
+}
