From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:36 +0000
Subject: [PATCH 11/11]: Processing Confirm options
Message-Id: <200710011518.36337@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Processing Confirm options

Analogous to the previous patch, this adds code to interpret incoming Confirm feature-negotiation
options. Both functions operate on the feature-negotiation list of either the request_sock (server)
or the dccp_sock (client).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c    |  151 ++++++++++++++++++++++++++++++++++-------------------
 net/dccp/feat.h    |    2 
 net/dccp/options.c |   16 -----
 3 files changed, 99 insertions(+), 70 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -95,6 +95,13 @@ static int dccp_feat_default_value(u8 fe
 	return idx < 0? idx : dccp_feat_table[idx].default_value;
 }
 
+/* Test for "Req'd" feature (RFC 4340, 6.4) */
+static inline int dccp_feat_must_be_understood(u8 feat_num)
+{
+	return	feat_num = DCCPF_CCID || feat_num = DCCPF_SHORT_SEQNOS ||
+		feat_num = DCCPF_SEQUENCE_WINDOW;
+}
+
 /* copy constructor, fval must not already contain allocated memory */
 static int dccp_feat_clone_sp_val(dccp_feat_val *fval, u8 const *val, u8 len)
 {
@@ -829,6 +836,92 @@ not_valid_or_not_known:
 }
 
 /**
+ * dccp_feat_confirm_recv  -  Process received Confirm options
+ * @fn: feature-negotiation list to update
+ * @is_mandatory: whether the Confirm was preceded by a Mandatory option
+ * @opt: %DCCPO_CONFIRM_L or %DCCPO_CONFIRM_R
+ * @feat: one of %dccp_feature_numbers
+ * @val: NN value or SP value/preference list
+ * @len: length of @val in bytes
+ * @server: whether this node is server (1) or client (0)
+ */
+static u8 dccp_feat_confirm_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
+				 u8 feat, u8 *val, u8 len, const bool server)
+{
+	u8 *plist, plen, type = dccp_feat_type(feat);
+	const bool local = (opt = DCCPO_CONFIRM_R);
+	struct dccp_feat_entry *entry = dccp_feat_list_lookup(fn, feat, local);
+
+	if (entry = NULL) {	/* nothing queued: ignore or handle error */
+		if (is_mandatory && type = FEAT_UNKNOWN)
+			return DCCP_RESET_CODE_MANDATORY_ERROR;
+
+		if (!local && type = FEAT_NN)		/* 6.3.2 */
+			goto confirmation_failed;
+		return 0;
+	}
+
+	if (entry->state != FEAT_CHANGING)		/* 6.6.2 */
+		return 0;
+
+	if (len = 0) {					/* Empty Confirm */
+		if (dccp_feat_must_be_understood(feat))	/* 6.6.7 */
+			goto confirmation_failed;
+		/*
+		 * Empty Confirm during connection setup: this means reverting
+		 * to the `old' value, which in this case is the default. Since
+		 * we handle default values automatically when no other values
+		 * have been set, we revert to the old value by removing this
+		 * entry from the list.
+		 */
+		list_del(&entry->node);
+		dccp_feat_entry_destructor(entry);
+		return 0;
+	}
+
+	if (type = FEAT_NN) {
+		if (len > sizeof(entry->val.nn))
+			goto confirmation_failed;
+
+		if (entry->val.nn = dccp_decode_value_var(val, len))
+			goto confirmation_succeeded;
+
+		DCCP_WARN("Bogus Confirm for non-existing value\n");
+		goto confirmation_failed;
+	}
+
+	/*
+	 * Parsing SP Confirms: the first element of @val is the preferred
+	 * SP value which the peer confirms, the remainder depends on @len.
+	 */
+	if (!dccp_feat_sp_list_ok(feat, val, len))
+		goto confirmation_failed;
+
+	if (len = 1) {		/* peer didn't supply a preference list */
+		plist = val;
+		plen  = len;
+	} else {		/* preferred value + preference list */
+		plist = val + 1;
+		plen  = len - 1;
+	}
+
+	/* Check whether the peer got the reconciliation right (6.6.8) */
+	if (dccp_feat_reconcile(&entry->val, plist, plen, server, 0) != *val) {
+		DCCP_WARN("Confirm selected the wrong value %u\n", *val);
+		return DCCP_RESET_CODE_OPTION_ERROR;
+	}
+	entry->val.sp.vec[0] = *val;
+
+confirmation_succeeded:
+	entry->state = FEAT_STABLE;
+	return 0;
+
+confirmation_failed:
+	return is_mandatory? DCCP_RESET_CODE_MANDATORY_ERROR
+			   : DCCP_RESET_CODE_OPTION_ERROR;
+}
+
+/**
  * dccp_feat_parse_options  -  Process Feature-Negotiation Options
  * @sk: for general use and used by the client during connection setup
  * @dreq: used by the server during connection setup
@@ -858,65 +951,15 @@ int dccp_feat_parse_options(struct sock 
 		case DCCPO_CHANGE_R:
 			return dccp_feat_change_recv(fn, mandatory, opt, feat,
 						     val, len, server);
+		case DCCPO_CONFIRM_R:
+		case DCCPO_CONFIRM_L:
+			return dccp_feat_confirm_recv(fn, mandatory, opt, feat,
+						      val, len, server);
 		}
 	}
 	return 0;	/* ignore FN options in all other states */
 }
 
-int dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
-			   u8 *val, u8 len)
-{
-	u8 t;
-	struct dccp_opt_pend *opt;
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	int found = 0;
-	int all_confirmed = 1;
-
-	/* Ignore Confirm options other than during connection setup */
-	if (sk->sk_state != DCCP_LISTEN && sk->sk_state != DCCP_REQUESTING)
-		return 0;
-	dccp_feat_debug(type, feature, *val);
-
-	/* locate our change request */
-	switch (type) {
-	case DCCPO_CONFIRM_L: t = DCCPO_CHANGE_R; break;
-	case DCCPO_CONFIRM_R: t = DCCPO_CHANGE_L; break;
-	default:	      DCCP_WARN("invalid type %d\n", type);
-			      return 1;
-
-	}
-	/* XXX sanity check feature value */
-
-	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
-		if (!opt->dccpop_conf && opt->dccpop_type = t &&
-		    opt->dccpop_feat = feature) {
-			found = 1;
-			dccp_pr_debug("feature %d found\n", opt->dccpop_feat);
-
-			/* XXX do sanity check */
-
-			opt->dccpop_conf = 1;
-
-			/* We got a confirmation---change the option */
-			dccp_feat_update(sk, opt->dccpop_type,
-					 opt->dccpop_feat, *val);
-
-			/* XXX check the return value of dccp_feat_update */
-			break;
-		}
-
-		if (!opt->dccpop_conf)
-			all_confirmed = 0;
-	}
-
-	if (!found)
-		dccp_pr_debug("%s(%d, ...) never requested\n",
-			      dccp_feat_typename(type), feature);
-	return 0;
-}
-
-EXPORT_SYMBOL_GPL(dccp_feat_confirm_recv);
-
 void dccp_feat_clean(struct dccp_minisock *dmsk)
 {
 	struct dccp_opt_pend *opt, *next;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -125,26 +125,14 @@ int dccp_parse_options(struct sock *sk, 
 			dccp_pr_debug("%s opt: NDP count=%llu\n", dccp_role(sk),
 				      (unsigned long long)opt_recv->dccpor_ndp);
 			break;
-		case DCCPO_CHANGE_L:
-		case DCCPO_CHANGE_R:
-			if (pkt_type = DCCP_PKT_DATA)
+		case DCCPO_CHANGE_L ... DCCPO_CONFIRM_R:
+			if (pkt_type = DCCP_PKT_DATA)      /* RFC 4340, 6 */
 				break;
 			rc = dccp_feat_parse_options(sk, dreq, mandatory, opt,
 						    *value, value + 1, len - 1);
 			if (rc)
 				goto out_invalid_option;
 			break;
-		case DCCPO_CONFIRM_L:
-			/* fall through */
-		case DCCPO_CONFIRM_R:
-			if (pkt_type = DCCP_PKT_DATA)
-				break;
-			if (len < 2)	/* FIXME this disallows empty confirm */
-				goto out_invalid_option;
-			if (dccp_feat_confirm_recv(sk, opt, *value,
-						   value + 1, len - 1))
-				goto out_invalid_option;
-			break;
 		case DCCPO_ACK_VECTOR_0:
 		case DCCPO_ACK_VECTOR_1:
 			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
--- a/net/dccp/feat.h
+++ b/net/dccp/feat.h
@@ -105,8 +105,6 @@ extern int  dccp_feat_register_change(st
 				      u8 is_local, u8 *val, u8 len);
 extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
 				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
-extern int  dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
-				   u8 *val, u8 len);
 extern void dccp_feat_clean(struct dccp_minisock *dmsk);
 extern int  dccp_feat_clone(struct sock *oldsk, struct sock *newsk);
 extern int  dccp_feat_clone_list(struct list_head const *, struct list_head *);
