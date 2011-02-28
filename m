From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Feb 2011 11:25:11 +0000
Subject: dccp test-tree [RFC] [Patch 1/1] dccp: Only activate NN values
Message-Id: <20110228112511.GE3620@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am sending this as RFC since I have not yet deeply tested this. It makes
the exchange of NN options in established state conform to RFC 4340, 6.6.1
and thus actually is a bug fix.

>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
dccp: Only activate NN values after receiving the Confirm option

This defers changing local values using exchange of NN options in established
connection state by only activating the value after receiving the Confirm
option, as mandated by RFC 4340, 6.6.1.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |    7 ++-----
 net/dccp/feat.c        |   13 ++++---------
 2 files changed, 6 insertions(+), 14 deletions(-)

--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -775,12 +775,7 @@ int dccp_feat_register_sp(struct sock *s
  * @sk: DCCP socket of an established connection
  * @feat: NN feature number from %dccp_feature_numbers
  * @nn_val: the new value to use
- * This function is used to communicate NN updates out-of-band. The difference
- * to feature negotiation during connection setup is that values are activated
- * immediately after validation, i.e. we don't wait for the Confirm: either the
- * value is accepted by the peer (and then the waiting is futile), or it is not
- * (Reset or empty Confirm). We don't accept empty Confirms - transmitted values
- * are validated, and the peer "MUST accept any valid value" (RFC 4340, 6.3.2).
+ * This function is used to communicate NN updates out-of-band.
  */
 int dccp_feat_signal_nn_change(struct sock *sk, u8 feat, u64 nn_val)
 {
@@ -805,9 +800,6 @@ int dccp_feat_signal_nn_change(struct so
 		dccp_feat_list_pop(entry);
 	}
 
-	if (dccp_feat_activate(sk, feat, 1, &fval))
-		return -EADV;
-
 	inet_csk_schedule_ack(sk);
 	return dccp_feat_push_change(fn, feat, 1, 0, &fval);
 }
@@ -1356,6 +1348,9 @@ static u8 dccp_feat_handle_nn_establishe
 		if (fval.nn != entry->val.nn)
 			return 0;
 
+		/* Only activate after receiving the Confirm option (6.6.1). */
+		dccp_feat_activate(sk, feat, local, &fval);
+
 		/* It has been confirmed - so remove the entry */
 		dccp_feat_list_pop(entry);
 
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -105,7 +105,6 @@ static void ccid2_change_l_ack_ratio(str
 		return;
 
 	ccid2_pr_debug("changing local ack ratio to %u\n", val);
-	dp->dccps_l_ack_ratio = val;
 	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO, val);
 }
 
@@ -117,11 +116,9 @@ static void ccid2_change_l_seq_window(st
 		val = DCCPF_SEQ_WMIN;
 	if (val > DCCPF_SEQ_WMAX)
 		val = DCCPF_SEQ_WMAX;
-	if (val = dp->dccps_l_seq_win)
-		return;
 
-	dp->dccps_l_seq_win = val;
-	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
+	if (val != dp->dccps_l_seq_win)
+		dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW, val);
 }
 
 static void ccid2_hc_tx_rto_expire(unsigned long data)

-- 
