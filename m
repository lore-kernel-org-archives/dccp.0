From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 04 Oct 2007 14:01:56 +0000
Subject: [PATCH 3/5]: Support exchange of NN options in (PART)OPEN state
Message-Id: <200710041501.56582@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Support exchange of NN options in (PART)OPEN state

This patch supports reception of NN options in established state. It is a combination
of change_recv() and confirm_recv(), specifically geared towards receiving `fast-path'
NN options. Such options are only accepted in OPEN/PARTOPEN state, and an additional
test currently limits the use to Ack Ratio (the routine can be used for any NN options,
but there is currently no use for that).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c |  100 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 100 insertions(+)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -1130,6 +1130,97 @@ confirmation_failed:
 }
 
 /**
+ * dccp_feat_handle_nn_established  -  Fast-path reception of NN options
+ * @sk: socket of an established DCCP connection
+ * @mandatory: whether @opt was preceded by a Mandatory option
+ * @opt: %DCCPO_CHANGE_L | %DCCPO_CONFIRM_R (NN only)
+ * @feat: NN number from %dccp_feature_numbers
+ * @val: NN value (has implications for @len)
+ * This function combines the functionality of change_recv/confirm_recv, with
+ * the following differences (reset codes are the same):
+ * - cleanup after receiving the Confirm;
+ * - values are directly activated after successful parsing;
+ * - restricted to NN features in general and Ack Ratio in particular.
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
+	/*
+	 * The restriction to Ack Ratio is here for safety: it may be possible
+	 * to lift this and also update Sequence Window dynamically.
+	 */
+	 if (feat != DCCPF_ACK_RATIO)
+		return 0;
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
+		dccp_schedule_ack(sk);
+
+	} else if (opt = DCCPO_CONFIRM_R) {
+		entry = dccp_feat_list_lookup(fn, feat, local);
+		if (entry = NULL || entry->state != FEAT_CHANGING)
+			return 0;
+
+		fval.nn = dccp_decode_value_var(val, len);
+		if (fval.nn != entry->val.nn) {
+			DCCP_WARN("Bogus Confirm for non-existing value\n");
+			goto fast_path_failed;
+		}
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
@@ -1164,6 +1255,15 @@ int dccp_feat_parse_options(struct sock 
 			return dccp_feat_confirm_recv(fn, mandatory, opt, feat,
 						      val, len, server);
 		}
+		break;
+	/*
+	 *	Support for exchanging NN options on an established connection
+	 *	This is currently restricted to Ack Ratio (RFC 4341, 6.1.2)
+	 */
+	case DCCP_OPEN:
+	case DCCP_PARTOPEN:
+		return dccp_feat_handle_nn_established(sk, mandatory, opt, feat,
+						       val, len);
 	}
 	return 0;	/* ignore FN options in all other states */
 }
