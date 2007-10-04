From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 14:01:53 +0000
Subject: [PATCH 2/5]: Support for the exchange of NN options in established state
Message-Id: <200710041501.53141@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Support for the exchange of NN options in established state

This patch introduces a variant of feature negotiation which differs from 
feature negotiation during connection setup in the following aspects.
 * It is a restricted variant - only NN options can be exchanged;
 * NN options are activated directly after validating them. The rationale is
   that a peer must accept every valid NN value (RFC 4340, 6.3.2), hence it
   will either accept the value and send a ConfirmR, or it will send an
   empty Confirm (which will reset the connection according to FN rules). 
 * An Ack is scheduled directly after activation to accelerate communicating
   the update to the peer.

The facility of exchanging NN options is currently only needed by CCID2's Ack Ratio
(RFC 4341, 6.1.2). Although the code will in principle work for any NN option, this
fact has been the reason for limiting the current use to Ack Ratio. 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/dccp.h |    1 +
 net/dccp/feat.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 48 insertions(+)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -421,6 +421,7 @@ static inline int dccp_ack_pending(const
 	       inet_csk_ack_scheduled(sk);
 }
 
+extern int  dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val);
 extern int  dccp_feat_finalise_settings(struct dccp_sock *dp);
 extern int  dccp_feat_server_ccid_dependencies(struct dccp_request_sock *dreq);
 extern int  dccp_feat_insert_opts(struct dccp_sock*, struct dccp_request_sock*,
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -12,6 +12,7 @@
  *  -----------
  *  o Feature negotiation is coordinated with connection setup (as in TCP), wild
  *    changes of parameters of an established connection are not supported.
+ *  o Changing NN values (Ack Ratio only) is supported in state OPEN/PARTOPEN.
  *  o All currently known SP features have 1-byte quantities. If in the future
  *    extensions of RFCs 4340..42 define features with item lengths larger than
  *    one byte, a feature-specific extension of the code will be required.
@@ -634,6 +635,52 @@ int dccp_feat_register_change(struct soc
 	return -EINVAL;
 }
 
+/**
+ * dccp_feat_signal_nn_change  -  Update NN values for an established connection
+ * @sk: DCCP socket of an established connection
+ * @feat: NN feature number from %dccp_feature_numbers
+ * @nn_val: the new value to use
+ * This function is used to communicate NN updates out-of-band. The only known
+ * instance at the moment is %DCCPF_ACK_RATIO, used by CCID2. The difference to
+ * feature negotiation during connection setup is that existing entries are not
+ * replaced: Change entries remain in the queue until they have been confirmed,
+ * and are then removed. The other difference is that values are activated
+ * immediately after validation, ie. we don't wait for the Confirm: either the
+ * value is accepted by the peer (and then the waiting is futile), or it is not
+ * (reset or empty Confirm). We don't accept empty Confirms - transmitted values
+ * are validated, and the peer "MUST accept any valid value" (RFC 4340, 6.3.2).
+ */
+int dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val)
+{
+	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
+	dccp_feat_val fval = { .nn = nn_val };
+	struct dccp_feat_entry *entry;
+
+	if (sk->sk_state != DCCP_OPEN && sk->sk_state != DCCP_PARTOPEN)
+		return -ENOTCONN;
+
+	if (dccp_feat_type(feat) != FEAT_NN ||
+	    !dccp_feat_is_valid_nn_val(feat, nn_val))
+		return -EINVAL;
+
+	entry = dccp_feat_list_lookup(fn, feat, 1);
+	if (entry != NULL) {
+		dccp_pr_debug("Ignoring %llu, entry %llu exists in state %s\n",
+			      (unsigned long long)nn_val,
+			      (unsigned long long)entry->val.nn,
+			      dccp_feat_sname[entry->state]);
+		return 0;
+	}
+
+	if (dccp_feat_activate(sk, feat, 1, &fval))
+		return -EADV;
+
+	dccp_schedule_ack(sk);
+	return dccp_feat_push_change(fn, feat, 1, 0, &fval);
+}
+
+EXPORT_SYMBOL_GPL(dccp_feat_signal_nn_change);
+
 /*
  *	Tracking features whose value depend on the choice of CCID
  *
