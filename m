From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 25 Jul 2011 13:36:31 +0000
Subject: [PATCH 2/7] dccp: support for exchanging of NN options in established state 2/2
Message-Id: <1311600996-6712-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch adds the receiver side and the (fast-path) activation part for
dynamic changes of non-negotiable (NN) parameters in (PART)OPEN state.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.uk>
---
 net/dccp/feat.c |  116 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 116 insertions(+), 0 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -344,6 +344,20 @@ static int __dccp_feat_activate(struct sock *sk, const int idx,
 	return dccp_feat_table[idx].activation_hdlr(sk, val, rx);
 }
 
+/**
+ * dccp_feat_activate  -  Activate feature value on socket
+ * @sk: fully connected DCCP socket (after handshake is complete)
+ * @feat_num: feature to activate, one of %dccp_feature_numbers
+ * @local: whether local (1) or remote (0) @feat_num is meant
+ * @fval: the value (SP or NN) to activate, or NULL to use the default value
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
@@ -1252,6 +1266,100 @@ confirmation_failed:
 }
 
 /**
+ * dccp_feat_handle_nn_established  -  Fast-path reception of NN options
+ * @sk:		socket of an established DCCP connection
+ * @mandatory:	whether @opt was preceded by a Mandatory option
+ * @opt:	%DCCPO_CHANGE_L | %DCCPO_CONFIRM_R (NN only)
+ * @feat:	NN number, one of %dccp_feature_numbers
+ * @val:	NN value
+ * @len:	length of @val in bytes
+ * This function combines the functionality of change_recv/confirm_recv, with
+ * the following differences (reset codes are the same):
+ *    - cleanup after receiving the Confirm;
+ *    - values are directly activated after successful parsing;
+ *    - deliberately restricted to NN features.
+ * The restriction to NN features is essential since SP features can have non-
+ * predictable outcomes (depending on the remote configuration), and are inter-
+ * dependent (CCIDs for instance cause further dependencies).
+ */
+static u8 dccp_feat_handle_nn_established(struct sock *sk, u8 mandatory, u8 opt,
+					  u8 feat, u8 *val, u8 len)
+{
+	struct list_head *fn = &dccp_sk(sk)->dccps_featneg;
+	const bool local = (opt = DCCPO_CONFIRM_R);
+	struct dccp_feat_entry *entry;
+	u8 type = dccp_feat_type(feat);
+	dccp_feat_val fval;
+
+	dccp_feat_print_opt(opt, feat, val, len, mandatory);
+
+	/* Ignore non-mandatory unknown and non-NN features */
+	if (type = FEAT_UNKNOWN) {
+		if (local && !mandatory)
+			return 0;
+		goto fast_path_unknown;
+	} else if (type != FEAT_NN) {
+		return 0;
+	}
+
+	/*
+	 * We don't accept empty Confirms, since in fast-path feature
+	 * negotiation the values are enabled immediately after sending
+	 * the Change option.
+	 * Empty Changes on the other hand are invalid (RFC 4340, 6.1).
+	 */
+	if (len = 0 || len > sizeof(fval.nn))
+		goto fast_path_unknown;
+
+	if (opt = DCCPO_CHANGE_L) {
+		fval.nn = dccp_decode_value_var(val, len);
+		if (!dccp_feat_is_valid_nn_val(feat, fval.nn))
+			goto fast_path_unknown;
+
+		if (dccp_feat_push_confirm(fn, feat, local, &fval) ||
+		    dccp_feat_activate(sk, feat, local, &fval))
+			return DCCP_RESET_CODE_TOO_BUSY;
+
+		/* set the `Ack Pending' flag to piggyback a Confirm */
+		inet_csk_schedule_ack(sk);
+
+	} else if (opt = DCCPO_CONFIRM_R) {
+		entry = dccp_feat_list_lookup(fn, feat, local);
+		if (entry = NULL || entry->state != FEAT_CHANGING)
+			return 0;
+
+		fval.nn = dccp_decode_value_var(val, len);
+		/*
+		 * Just ignore a value that doesn't match our current value.
+		 * If the option changes twice within two RTTs, then at least
+		 * one CONFIRM will be received for the old value after a
+		 * new CHANGE was sent.
+		 */
+		if (fval.nn != entry->val.nn)
+			return 0;
+
+		/* Only activate after receiving the Confirm option (6.6.1). */
+		dccp_feat_activate(sk, feat, local, &fval);
+
+		/* It has been confirmed - so remove the entry */
+		dccp_feat_list_pop(entry);
+
+	} else {
+		DCCP_WARN("Received illegal option %u\n", opt);
+		goto fast_path_failed;
+	}
+	return 0;
+
+fast_path_unknown:
+	if (!mandatory)
+		return dccp_push_empty_confirm(fn, feat, local);
+
+fast_path_failed:
+	return mandatory ? DCCP_RESET_CODE_MANDATORY_ERROR
+			 : DCCP_RESET_CODE_OPTION_ERROR;
+}
+
+/**
  * dccp_feat_parse_options  -  Process Feature-Negotiation Options
  * @sk: for general use and used by the client during connection setup
  * @dreq: used by the server during connection setup
@@ -1286,6 +1394,14 @@ int dccp_feat_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			return dccp_feat_confirm_recv(fn, mandatory, opt, feat,
 						      val, len, server);
 		}
+		break;
+	/*
+	 *	Support for exchanging NN options on an established connection.
+	 */
+	case DCCP_OPEN:
+	case DCCP_PARTOPEN:
+		return dccp_feat_handle_nn_established(sk, mandatory, opt, feat,
+						       val, len);
 	}
 	return 0;	/* ignore FN options in all other states */
 }
