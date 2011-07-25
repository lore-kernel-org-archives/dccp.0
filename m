From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jul 2011 13:36:30 +0000
Subject: [PATCH 1/7] dccp: support for the exchange of NN options in established state 1/2
Message-Id: <1311600996-6712-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In contrast to static feature negotiation at the begin of a connection, this
patch introduces support for exchange of dynamically changing options.

Such an update/exchange is necessary in at least two cases:
 * CCID-2's Ack Ratio (RFC 4341, 6.1.2) which changes during the connection;
 * Sequence Window values that, as per RFC 4340, 7.5.2, should be sent "as
   the connection progresses".

Both are non-negotiable (NN) features, which means that no new capabilities
are negotiated, but rather that changes in known parameters are brought
up-to-date at either end.

Thse characteristics are reflected by the implementation:
 * only NN options can be exchanged after connection setup;
 * an ack is scheduled directly after activation to speed up the update;
 * CCIDs may request changes to an NN feature even if a negotiation for that
   feature is already underway: this is required by CCID-2, where changes in
   cwnd necessitate Ack Ratio changes, such that the previous Ack Ratio (which
   is still being negotiated) would cause irrecoverable RTO timeouts (thanks
   to work by Samuel Jero).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.uk>
---
 net/dccp/dccp.h |    1 +
 net/dccp/feat.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/feat.h |    1 +
 3 files changed, 67 insertions(+), 0 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -474,6 +474,7 @@ static inline int dccp_ack_pending(const struct sock *sk)
 	return dccp_ackvec_pending(sk) || inet_csk_ack_scheduled(sk);
 }
 
+extern int  dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val);
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
 extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -129,6 +129,7 @@ extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
 
 extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
 extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
+extern u64  dccp_feat_nn_get(struct sock *sk, u8 feat);
 
 extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
 extern int  dccp_insert_fn_opt(struct sk_buff *skb, u8 type, u8 feat,
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -12,6 +12,7 @@
  *  -----------
  *  o Feature negotiation is coordinated with connection setup (as in TCP), wild
  *    changes of parameters of an established connection are not supported.
+ *  o Changing non-negotiable (NN) values is supported in state OPEN/PARTOPEN.
  *  o All currently known SP features have 1-byte quantities. If in the future
  *    extensions of RFCs 4340..42 define features with item lengths larger than
  *    one byte, a feature-specific extension of the code will be required.
@@ -730,6 +731,70 @@ int dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
 				  0, list, len);
 }
 
+/**
+ * dccp_feat_nn_get  -  Query current/pending value of NN feature
+ * @sk: DCCP socket of an established connection
+ * @feat: NN feature number from %dccp_feature_numbers
+ * For a known NN feature, returns value currently being negotiated, or
+ * current (confirmed) value if no negotiation is going on.
+ */
+u64 dccp_feat_nn_get(struct sock *sk, u8 feat)
+{
+	if (dccp_feat_type(feat) = FEAT_NN) {
+		struct dccp_sock *dp = dccp_sk(sk);
+		struct dccp_feat_entry *entry;
+
+		entry = dccp_feat_list_lookup(&dp->dccps_featneg, feat, 1);
+		if (entry != NULL)
+			return entry->val.nn;
+
+		switch (feat) {
+		case DCCPF_ACK_RATIO:
+			return dp->dccps_l_ack_ratio;
+		case DCCPF_SEQUENCE_WINDOW:
+			return dp->dccps_l_seq_win;
+		}
+	}
+	DCCP_BUG("attempt to look up unsupported feature %u", feat);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dccp_feat_nn_get);
+
+/**
+ * dccp_feat_signal_nn_change  -  Update NN values for an established connection
+ * @sk: DCCP socket of an established connection
+ * @feat: NN feature number from %dccp_feature_numbers
+ * @nn_val: the new value to use
+ * This function is used to communicate NN updates out-of-band.
+ */
+int dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val)
+{
+	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
+	dccp_feat_val fval = { .nn = nn_val };
+	struct dccp_feat_entry *entry;
+
+	if (sk->sk_state != DCCP_OPEN && sk->sk_state != DCCP_PARTOPEN)
+		return 0;
+
+	if (dccp_feat_type(feat) != FEAT_NN ||
+	    !dccp_feat_is_valid_nn_val(feat, nn_val))
+		return -EINVAL;
+
+	if (nn_val = dccp_feat_nn_get(sk, feat))
+		return 0;	/* already set or negotiation under way */
+
+	entry = dccp_feat_list_lookup(fn, feat, 1);
+	if (entry != NULL) {
+		dccp_pr_debug("Clobbering existing NN entry %llu -> %llu\n",
+			      (unsigned long long)entry->val.nn,
+			      (unsigned long long)nn_val);
+		dccp_feat_list_pop(entry);
+	}
+
+	inet_csk_schedule_ack(sk);
+	return dccp_feat_push_change(fn, feat, 1, 0, &fval);
+}
+EXPORT_SYMBOL_GPL(dccp_feat_signal_nn_change);
 
 /*
  *	Tracking features whose value depend on the choice of CCID
