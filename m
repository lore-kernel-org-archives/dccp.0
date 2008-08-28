From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:45:00 +0000
Subject: [PATCH 25/37] dccp: Feature activation handlers
Message-Id: <1219945512-7723-26-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch provides the post-processing of feature negotiation state, after
the negotiation has completed.

To this purpose, handlers are used and added to the dccp_feat_table. Each
handler is passed a boolean flag whether the RX or TX side of the feature
is meant.

Several handlers are provided already, new handlers can easily be added.

The initialisation is now fully dynamic, i.e. CCIDs are activated only
after the feature negotiation. The integration of this dynamic activation
is done in the subsequent patches.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/dccp.h |    1 +
 net/dccp/feat.c |  220 ++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 211 insertions(+), 10 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -445,6 +445,7 @@ extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
 extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
 				  struct sk_buff *skb);
+extern int  dccp_feat_activate_values(struct sock *sk, struct list_head *fn);
 extern void dccp_feat_list_purge(struct list_head *fn_list);
 
 extern int dccp_insert_options(struct sock *sk, struct sk_buff *skb);
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -25,11 +25,101 @@
 
 #define DCCP_FEAT_SP_NOAGREE (-123)
 
+/*
+ * Feature activation handlers.
+ *
+ * These all use an u64 argument, to provide enough room for NN/SP features. At
+ * this stage the negotiated values have been checked to be within their range.
+ */
+static int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx)
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
+static int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
+{
+	if (!rx)
+		dccp_msk(sk)->dccpms_sequence_window = seq_win;
+	return 0;
+}
+
+static int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
+{
+	if (rx)
+		dccp_sk(sk)->dccps_r_ack_ratio = ratio;
+	else
+		dccp_sk(sk)->dccps_l_ack_ratio = ratio;
+	return 0;
+}
+
+static int dccp_hdlr_ackvec(struct sock *sk, u64 enable, bool rx)
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
+static int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx)
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
+static int dccp_hdlr_min_cscov(struct sock *sk, u64 cscov, bool rx)
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
@@ -49,16 +139,16 @@ static const struct {
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
 
@@ -99,6 +189,55 @@ static int dccp_feat_default_value(u8 feat_num)
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
@@ -1504,6 +1643,67 @@ out:
 
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
+		if (idx < 0) {
+			DCCP_BUG("Unknown feature %u", cur->feat_num);
+			goto activation_failed;
+		}
+		if (cur->state != FEAT_STABLE) {
+			DCCP_CRIT("Negotiation of %s %u failed in state %u",
+				  cur->is_local ? "local" : "remote",
+				  cur->feat_num, cur->state);
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
+		    __dccp_feat_activate(sk, idx, 1, fvals[idx][1])) {
+			DCCP_CRIT("Could not activate %d", idx);
+			goto activation_failed;
+		}
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
-- 
1.6.0.rc2

