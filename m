From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Mar 2008 07:01:06 +0000
Subject: [Announce]: Test-tree fixed & updated
Message-Id: <20080317070106.GA5171@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

After some more testing with sparse, the test tree has been revised, with
the following changes:

 1. dccp_insert_option_ackvec() now declared static;
 2. re-homed activation handlers from minisocks.c to feat.c and 
    declared all of them static;
 3. fixed patch inter-dependency.

The feature-negotiation patches are in many small fragments, will at the
end of the week combine these and make sure that the test tree is fully
bisectable & send updated test tree inventory.

For the moment, the diff below reflects the changes applied to the test tree.

--- b/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -33,13 +33,116 @@
 		sysctl_dccp_feat_tx_ccid,
 		sysctl_dccp_feat_ack_ratio;
 
-/* Feature activation handlers */
-extern int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx);
-extern int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx);
-extern int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx);
-extern int dccp_hdlr_ackvec(struct sock *sk, u64 enable, bool rx);
-extern int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx);
-extern int dccp_hdlr_min_cscov(struct sock *sk, u64 cscov, bool rx);
+/*
+ * Feature activation handlers.
+ *
+ * This uses an u64 argument in all cases to provide enough room for NN/SP
+ * features. Verifiying that the values are within their allowed range happens
+ * earlier and is not something that should be done at this late stage.
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
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	if (rx) {
+		dp->dccps_r_seq_win = seq_win;
+		/* propagate changes to update SWL/SWH */
+		dccp_update_gsr(sk, dp->dccps_gsr);
+	} else {
+		dp->dccps_l_seq_win = seq_win;
+		/* propagate changes to update AWL */
+		dccp_update_gss(sk, dp->dccps_gss);
+	}
+	return 0;
+}
+
+static int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
+{
+#ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
+	/*
+	 * FIXME: This hack is required to remain bug-compatible with CCID2.
+	 * Using Ack Ratios > 1 lead to hangups and long RTO timeouts
+	 * (1..3 seconds). CCID2 code needs to be fixed first before being
+	 * able to use dynamic updates of Ack Ratio.
+	 */
+	DCCP_WARN("Not changing %s Ack Ratio from 1 to %u\n", rx ? "RX" : "TX",
+		  (u16)ratio);
+	dccp_sk(sk)->dccps_l_ack_ratio = dccp_sk(sk)->dccps_r_ack_ratio = 1;
+#else
+	if (rx)
+		dccp_sk(sk)->dccps_r_ack_ratio = ratio;
+	else
+		dccp_sk(sk)->dccps_l_ack_ratio = ratio;
+#endif
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
+		dccp_sk(sk)->dccps_send_ndp_count = (enable > 0);
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
 
 static const struct {
 	u8			feat_num;		/* DCCPF_xxx */
@@ -1381,7 +1484,7 @@
 	 */
 	for (idx = DCCP_FEAT_SUPPORTED_MAX; --idx >= 0;)
 		if (__dccp_feat_activate(sk, idx, 0, fvals[idx][0]) ||
-		    __dccp_feat_activate(sk, idx, 1, fvals[idx][1])   )
+		    __dccp_feat_activate(sk, idx, 1, fvals[idx][1]))
 			goto activation_failed;
 
 	/* Clean up Change options which have been confirmed already */
--- b/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -276,111 +275,0 @@
-
-/*
- *	Handlers for activating features on the (mini)socket.
- *
- * We consistently use an u64 argument in all cases to have enough room;
- * verifiying that the values are within their allowed range happens earlier
- * and is not something that should be done at this late stage.
- */
-int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid *new_ccid = ccid_new(ccid, sk, rx, gfp_any());
-
-	if (new_ccid = NULL)
-		return -ENOMEM;
-
-	if (rx) {
-		ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
-		dp->dccps_hc_rx_ccid = new_ccid;
-	} else {
-		ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
-		dp->dccps_hc_tx_ccid = new_ccid;
-	}
-	return 0;
-}
-
-int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	if (rx) {
-		dp->dccps_r_seq_win = seq_win;
-		/* propagate changes to update SWL/SWH */
-		dccp_update_gsr(sk, dp->dccps_gsr);
-	} else {
-		dp->dccps_l_seq_win = seq_win;
-		/* propagate changes to update AWL */
-		dccp_update_gss(sk, dp->dccps_gss);
-	}
-	return 0;
-}
-
-int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
-{
-#ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
-	/*
-	 * FIXME: This hack is required to remain bug-compatible with CCID2.
-	 * Using Ack Ratios > 1 lead to hangups and long RTO timeouts
-	 * (1..3 seconds). CCID2 code needs to be fixed first before being
-	 * able to use dynamic updates of Ack Ratio.
-	 */
-	DCCP_WARN("Not changing %s Ack Ratio from 1 to %u\n", rx ? "RX" : "TX",
-		  (u16)ratio);
-	dccp_sk(sk)->dccps_l_ack_ratio = dccp_sk(sk)->dccps_r_ack_ratio = 1;
-#else
-	if (rx)
-		dccp_sk(sk)->dccps_r_ack_ratio = ratio;
-	else
-		dccp_sk(sk)->dccps_l_ack_ratio = ratio;
-#endif
-	return 0;
-}
-
-int dccp_hdlr_ackvec(struct sock *sk, u64 enable, bool rx)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	if (rx) {
-		if (enable && dp->dccps_hc_rx_ackvec = NULL) {
-			dp->dccps_hc_rx_ackvec = dccp_ackvec_alloc(gfp_any());
-			if (dp->dccps_hc_rx_ackvec = NULL)
-				return -ENOMEM;
-		} else if (!enable) {
-			dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
-			dp->dccps_hc_rx_ackvec = NULL;
-		}
-	}
-	return 0;
-}
-
-int dccp_hdlr_ndp(struct sock *sk, u64 enable, bool rx)
-{
-	if (!rx)
-		dccp_sk(sk)->dccps_send_ndp_count = (enable > 0);
-	return 0;
-}
-
-/*
- * Minimum Checksum Coverage is located at the RX side (9.2.1). This means that
- * `rx' holds when the sending peer informs about his partial coverage via a
- * ChangeR() option. In the other case, we are the sender and the receiver
- * announces its coverage via ChangeL() options. The policy here is to honour
- * such communication by enabling the corresponding partial coverage - but only
- * if it has not been set manually before; the warning here means that all
- * packets will be dropped.
- */
-int dccp_hdlr_min_cscov(struct sock *sk, u64 cscov, bool rx)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	if (rx)
-		dp->dccps_pcrlen = cscov;
-	else {
-		if (dp->dccps_pcslen = 0)
-			dp->dccps_pcslen = cscov;
-		else if (cscov > dp->dccps_pcslen)
-			DCCP_WARN("CsCov %u too small, peer requires >= %u\n",
-				  dp->dccps_pcslen, (u8)cscov);
-	}
-	return 0;
-}
-- 
