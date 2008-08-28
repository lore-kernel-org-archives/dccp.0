From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 28 Aug 2008 17:44:57 +0000
Subject: [PATCH 22/37] dccp: Preference list reconciliation
Message-Id: <1219945512-7723-23-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides two functions to
 * reconcile preference lists (with appropriate return codes) and
 * reorder the preference list if successful reconciliation changed the
   preferred value.

The patch also removes the old code for processing SP/NN Change options, since
new code to process these is mostly there already; related references have been
commented out.

The code for processing Change options follows in the next patch.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/feat.c |   77 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 75 insertions(+), 2 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -715,6 +715,76 @@ static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, u8 val)
 	return 0;
 }
 
+/* Select the first entry in @servlist that also occurs in @clilist (6.3.1) */
+static int dccp_feat_preflist_match(u8 *servlist, u8 slen, u8 *clilist, u8 clen)
+{
+	u8 c, s;
+
+	for (s = 0; s < slen; s++)
+		for (c = 0; c < clen; c++)
+			if (servlist[s] = clilist[c])
+				return servlist[s];
+	return -1;
+}
+
+/**
+ * dccp_feat_prefer  -  Move preferred entry to the start of array
+ * Reorder the @array_len elements in @array so that @preferred_value comes
+ * first. Returns >0 to indicate that @preferred_value does occur in @array.
+ */
+static u8 dccp_feat_prefer(u8 preferred_value, u8 *array, u8 array_len)
+{
+	u8 i, does_occur = 0;
+
+	if (array != NULL) {
+		for (i = 0; i < array_len; i++)
+			if (array[i] = preferred_value) {
+				array[i] = array[0];
+				does_occur++;
+			}
+		if (does_occur)
+			array[0] = preferred_value;
+	}
+	return does_occur;
+}
+
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
+{
+	int rc;
+
+	if (!fv->sp.vec || !arr) {
+		DCCP_CRIT("NULL feature value or array");
+		return 0;
+	}
+
+	if (is_server)
+		rc = dccp_feat_preflist_match(fv->sp.vec, fv->sp.len, arr, len);
+	else
+		rc = dccp_feat_preflist_match(arr, len, fv->sp.vec, fv->sp.len);
+
+	if (!reorder)
+		return rc;
+	if (rc < 0)
+		return 0;
+
+	/*
+	 * Reorder list: used for activating features and in dccp_insert_fn_opt.
+	 */
+	return dccp_feat_prefer(rc, fv->sp.vec, fv->sp.len);
+}
+
+#ifdef __this_is_the_old_framework_and_will_be_removed_later_in_a_subsequent_patch
 static int dccp_feat_reconcile(struct sock *sk, struct dccp_opt_pend *opt,
 			       u8 *rpref, u8 rlen)
 {
@@ -910,6 +980,7 @@ static int dccp_feat_nn(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
 
 	return 0;
 }
+#endif /* (later) */
 
 static void dccp_feat_empty_confirm(struct dccp_minisock *dmsk,
 				    u8 type, u8 feature)
@@ -985,12 +1056,14 @@ int dccp_feat_change_recv(struct sock *sk, u8 type, u8 feature, u8 *val, u8 len)
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
-- 
1.6.0.rc2

