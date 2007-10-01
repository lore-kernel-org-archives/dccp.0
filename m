From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 01 Oct 2007 14:18:28 +0000
Subject: [PATCH 8/11]: Preference list reconciliation
Message-Id: <200710011518.29028@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Preference list reconciliation

This provides two functions to
 * reconcile preference lists (with appropriate return codes) and
 * reorder the preference list if successful reconciliation changed the
   preferred value.

The patch also removes the old code for processing SP/NN Change options, since
new code to process these is mostly there already; related references have been
commented out.
The code for processing Change options follows in the next patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/feat.c |  230 ++++++++++++--------------------------------------------
 1 file changed, 50 insertions(+), 180 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -655,200 +655,68 @@ static int dccp_feat_update(struct sock 
 	return 0;
 }
 
-static int dccp_feat_reconcile(struct sock *sk, struct dccp_opt_pend *opt,
-			       u8 *rpref, u8 rlen)
+/* Select the first entry in @servlist that also occurs in @clilist (6.3.1) */
+static int dccp_feat_preflist_match(u8 *servlist, u8 slen, u8 *clilist, u8 clen)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-	u8 *spref, slen, *res = NULL;
-	int i, j, rc, agree = 1;
-
-	BUG_ON(rpref = NULL);
-
-	/* check if we are the black sheep */
-	if (dp->dccps_role = DCCP_ROLE_CLIENT) {
-		spref = rpref;
-		slen  = rlen;
-		rpref = opt->dccpop_val;
-		rlen  = opt->dccpop_len;
-	} else {
-		spref = opt->dccpop_val;
-		slen  = opt->dccpop_len;
-	}
-	/*
-	 * Now we have server preference list in spref and client preference in
-	 * rpref
-	 */
-	BUG_ON(spref = NULL);
-	BUG_ON(rpref = NULL);
-
-	/* FIXME sanity check vals */
-
-	/* Are values in any order?  XXX Lame "algorithm" here */
-	for (i = 0; i < slen; i++) {
-		for (j = 0; j < rlen; j++) {
-			if (spref[i] = rpref[j]) {
-				res = &spref[i];
-				break;
-			}
-		}
-		if (res)
-			break;
-	}
-
-	/* we didn't agree on anything */
-	if (res = NULL) {
-		/* confirm previous value */
-		switch (opt->dccpop_feat) {
-		case DCCPF_CCID:
-			/* XXX did i get this right? =P */
-			if (opt->dccpop_type = DCCPO_CHANGE_L)
-				res = &dccp_msk(sk)->dccpms_tx_ccid;
-			else
-				res = &dccp_msk(sk)->dccpms_rx_ccid;
-			break;
-
-		default:
-			DCCP_BUG("Fell through, feat=%d", opt->dccpop_feat);
-			/* XXX implement res */
-			return -EFAULT;
-		}
+	u8 c, s;
 
-		dccp_pr_debug("Don't agree... reconfirming %d\n", *res);
-		agree = 0; /* this is used for mandatory options... */
-	}
-
-	/* need to put result and our preference list */
-	rlen = 1 + opt->dccpop_len;
-	rpref = kmalloc(rlen, GFP_ATOMIC);
-	if (rpref = NULL)
-		return -ENOMEM;
-
-	*rpref = *res;
-	memcpy(&rpref[1], opt->dccpop_val, opt->dccpop_len);
-
-	/* put it in the "confirm queue" */
-	if (opt->dccpop_sc = NULL) {
-		opt->dccpop_sc = kmalloc(sizeof(*opt->dccpop_sc), GFP_ATOMIC);
-		if (opt->dccpop_sc = NULL) {
-			kfree(rpref);
-			return -ENOMEM;
-		}
-	} else {
-		/* recycle the confirm slot */
-		BUG_ON(opt->dccpop_sc->dccpoc_val = NULL);
-		kfree(opt->dccpop_sc->dccpoc_val);
-		dccp_pr_debug("recycling confirm slot\n");
-	}
-	memset(opt->dccpop_sc, 0, sizeof(*opt->dccpop_sc));
-
-	opt->dccpop_sc->dccpoc_val = rpref;
-	opt->dccpop_sc->dccpoc_len = rlen;
-
-	/* update the option on our side [we are about to send the confirm] */
-	rc = dccp_feat_update(sk, opt->dccpop_type, opt->dccpop_feat, *res);
-	if (rc) {
-		kfree(opt->dccpop_sc->dccpoc_val);
-		kfree(opt->dccpop_sc);
-		opt->dccpop_sc = NULL;
-		return rc;
-	}
-
-	dccp_pr_debug("Will confirm %d\n", *rpref);
-
-	/* say we want to change to X but we just got a confirm X, suppress our
-	 * change
-	 */
-	if (!opt->dccpop_conf) {
-		if (*opt->dccpop_val = *res)
-			opt->dccpop_conf = 1;
-		dccp_pr_debug("won't ask for change of same feature\n");
-	}
-
-	return agree ? 0 : DCCP_FEAT_SP_NOAGREE; /* used for mandatory opts */
+	for (s = 0; s < slen; s++)
+		for (c = 0; c < clen; c++)
+			if (servlist[s] = clilist[c])
+				return servlist[s];
+	return -1;
 }
 
-static int dccp_feat_sp(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
+/* Reorder array so that the preferred value comes first. Returns > 0 on success. */
+static u8 dccp_feat_prefer(u8 preferred_value, u8 *array, u8 array_len)
 {
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	struct dccp_opt_pend *opt;
-	int rc = 1;
-	u8 t;
-
-	/*
-	 * We received a CHANGE.  We gotta match it against our own preference
-	 * list.  If we got a CHANGE_R it means it's a change for us, so we need
-	 * to compare our CHANGE_L list.
-	 */
-	if (type = DCCPO_CHANGE_L)
-		t = DCCPO_CHANGE_R;
-	else
-		t = DCCPO_CHANGE_L;
+	u8 i, does_occur = 0;
 
-	/* find our preference list for this feature */
-	list_for_each_entry(opt, &dmsk->dccpms_pending, dccpop_node) {
-		if (opt->dccpop_type != t || opt->dccpop_feat != feature)
-			continue;
-
-		/* find the winner from the two preference lists */
-		rc = dccp_feat_reconcile(sk, opt, val, len);
-		break;
+	if (array != NULL) {
+		for (i = 0; i < array_len; i++)
+			if (array[i] = preferred_value) {
+				array[i] = array[0];
+				does_occur++;
+			}
+		if (does_occur)
+			array[0] = preferred_value;
 	}
-
-	/* We didn't deal with the change.  This can happen if we have no
-	 * preference list for the feature.  In fact, it just shouldn't
-	 * happen---if we understand a feature, we should have a preference list
-	 * with at least the default value.
-	 */
-	BUG_ON(rc = 1);
-
-	return rc;
+	return does_occur;
 }
 
-static int dccp_feat_nn(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
+/**
+ * dccp_feat_reconcile  -  Reconcile SP preference lists
+ *  @fval: SP list to reconcile into
+ *  @arr: received SP preference list
+ *  @len: length of @arr in bytes
+ *  @is_server: whether this side is the server (and @fv is the server's list)
+ *  @reorder: whether to reorder the list in @fv after reconciling with @arr
+ * When successful, > 0 is returned and the reconciled list is in @fval.
+ * A value of 0 means that negotiation failed (no shared entry).
+ */
+static int dccp_feat_reconcile(dccp_feat_val *fv, u8 *arr, u8 len,
+			       bool is_server, bool reorder)
 {
-	struct dccp_opt_pend *opt;
-	struct dccp_minisock *dmsk = dccp_msk(sk);
-	u8 *copy;
 	int rc;
 
-	/* NN features must be Change L (sec. 6.3.2) */
-	if (type != DCCPO_CHANGE_L) {
-		dccp_pr_debug("received %s for NN feature %d\n",
-				dccp_feat_typename(type), feature);
-		return -EFAULT;
-	}
-
-	/* XXX sanity check opt val */
-
-	/* copy option so we can confirm it */
-	opt = kzalloc(sizeof(*opt), GFP_ATOMIC);
-	if (opt = NULL)
-		return -ENOMEM;
-
-	copy = kmemdup(val, len, GFP_ATOMIC);
-	if (copy = NULL) {
-		kfree(opt);
-		return -ENOMEM;
-	}
+	BUG_TRAP(fv->sp.vec != NULL && arr != NULL);
+	if (!fv->sp.vec || !arr)
+		return 0;
 
-	opt->dccpop_type = DCCPO_CONFIRM_R; /* NN can only confirm R */
-	opt->dccpop_feat = feature;
-	opt->dccpop_val	 = copy;
-	opt->dccpop_len	 = len;
+	if (is_server)
+		rc = dccp_feat_preflist_match(fv->sp.vec, fv->sp.len, arr, len);
+	else
+		rc = dccp_feat_preflist_match(arr, len, fv->sp.vec, fv->sp.len);
 
-	/* change feature */
-	rc = dccp_feat_update(sk, type, feature, *val);
-	if (rc) {
-		kfree(opt->dccpop_val);
-		kfree(opt);
+	if (!reorder)
 		return rc;
-	}
-
-	dccp_feat_debug(type, feature, *copy);
-
-	list_add_tail(&opt->dccpop_node, &dmsk->dccpms_conf);
+	if (rc < 0)
+		return 0;
 
-	return 0;
+	/*
+	 * Reorder list: used for activating features and in dccp_insert_fn_opt.
+	 */
+	return dccp_feat_prefer(rc, fv->sp.vec, fv->sp.len);
 }
 
 static void dccp_feat_empty_confirm(struct dccp_minisock *dmsk,
@@ -925,12 +793,14 @@ int dccp_feat_change_recv(struct sock *s
 	switch (feature) {
 	/* deal with SP features */
 	case DCCPF_CCID:
-		rc = dccp_feat_sp(sk, type, feature, val, len);
+		/* XXX Obsoleted by next patch
+		rc = dccp_feat_sp(sk, type, feature, val, len); */
 		break;
 
 	/* deal with NN features */
 	case DCCPF_ACK_RATIO:
-		rc = dccp_feat_nn(sk, type, feature, val, len);
+		/* XXX Obsoleted by next patch
+		rc = dccp_feat_nn(sk, type, feature, val, len); */
 		break;
 
 	/* XXX implement other features */
