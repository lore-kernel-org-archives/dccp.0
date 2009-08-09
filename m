From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:40 +0000
Subject: dccp-test-tree [PATCH 3/10] Add feature-negotiation handler for ECN-Incapable feature
Message-Id: <1249847327-6792-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This completes the feature-negotiation support for ECN in DCCP:
 * a socket field to indicate whether this end is ECN-incapable,
 * a socket field to record whether the remote end is ECN-capable,
 * a feature-negotiation handler to activate the local/remote features.

When local ECN support is disabled, the ECN bits are erased before passing
the skb on to the CCIDs (which perform the actual ECN processing). If the
remote end is ECN-capable, dccp_transmit_skb() sets the ECT(0) codepoint.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    4 ++++
 net/dccp/feat.c      |   13 ++++++++++++-
 net/dccp/input.c     |   13 +++++++++++++
 net/dccp/output.c    |    3 +++
 4 files changed, 32 insertions(+), 1 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -467,6 +467,8 @@ struct dccp_ackvec;
  * @dccps_r_ack_ratio - feature-remote Ack Ratio
  * @dccps_l_seq_win - local Sequence Window (influences ack number validity)
  * @dccps_r_seq_win - remote Sequence Window (influences seq number validity)
+ * @dccps_l_ecn_ok - this host understands ECN bits (RFC 4340, 12.1)
+ * @dccps_r_ecn_ok - the remote end understands ECN bits
  * @dccps_pcslen - sender   partial checksum coverage (via sockopt)
  * @dccps_pcrlen - receiver partial checksum coverage (via sockopt)
  * @dccps_send_ndp_count - local Send NDP Count feature (7.7.2)
@@ -512,6 +514,8 @@ struct dccp_sock {
 	__u16				dccps_r_ack_ratio;
 	__u64				dccps_l_seq_win:48;
 	__u64				dccps_r_seq_win:48;
+	bool				dccps_l_ecn_ok:1,
+					dccps_r_ecn_ok:1;
 	__u8				dccps_pcslen:4;
 	__u8				dccps_pcrlen:4;
 	__u8				dccps_send_ndp_count:1;
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -72,6 +72,17 @@ static int dccp_hdlr_seq_win(struct sock *sk, u64 seq_win, bool rx)
 	return 0;
 }
 
+static int dccp_hdlr_ecn(struct sock *sk, u64 ecn_incapable, bool rx)
+{
+	struct dccp_sock *dp = dccp_sk(sk);
+
+	if (rx)
+		dp->dccps_l_ecn_ok = (ecn_incapable = 0);
+	else
+		dp->dccps_r_ecn_ok = (ecn_incapable = 0);
+	return 0;
+}
+
 static int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
 {
 #ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
@@ -170,7 +181,7 @@ static const struct {
 	{ DCCPF_CCID,		 FEAT_AT_TX, FEAT_SP, 2,   dccp_hdlr_ccid     },
 	{ DCCPF_SHORT_SEQNOS,	 FEAT_AT_TX, FEAT_SP, 0,   NULL },
 	{ DCCPF_SEQUENCE_WINDOW, FEAT_AT_TX, FEAT_NN, 100, dccp_hdlr_seq_win  },
-	{ DCCPF_ECN_INCAPABLE,	 FEAT_AT_RX, FEAT_SP, 0,   NULL },
+	{ DCCPF_ECN_INCAPABLE,	 FEAT_AT_RX, FEAT_SP, 0,   dccp_hdlr_ecn      },
 	{ DCCPF_ACK_RATIO,	 FEAT_AT_TX, FEAT_NN, 2,   dccp_hdlr_ack_ratio},
 	{ DCCPF_SEND_ACK_VECTOR, FEAT_AT_RX, FEAT_SP, 0,   dccp_hdlr_ackvec   },
 	{ DCCPF_SEND_NDP_COUNT,  FEAT_AT_TX, FEAT_SP, 0,   dccp_hdlr_ndp      },
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -159,6 +159,17 @@ static void dccp_rcv_reset(struct sock *sk, struct sk_buff *skb)
 	dccp_time_wait(sk, DCCP_TIME_WAIT, 0);
 }
 
+static void dccp_handle_ecn_codepoints(struct sock *sk, struct sk_buff *skb)
+{
+	/*
+	 * When locally disabled, erase ECN codepoints (a peer conforming to
+	 * RFC 4340, 12.2 should set these to zero anyway).
+	 */
+	if (!dccp_sk(sk)->dccps_l_ecn_ok)
+		DCCP_SKB_CB(skb)->dccpd_ecn = INET_ECN_NOT_ECT;
+
+}
+
 static void dccp_handle_ackvec_processing(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_ackvec *av = dccp_sk(sk)->dccps_hc_rx_ackvec;
@@ -372,6 +383,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 	if (dccp_parse_options(sk, NULL, skb))
 		return 1;
 
+	dccp_handle_ecn_codepoints(sk, skb);
 	dccp_handle_ackvec_processing(sk, skb);
 	dccp_deliver_input_to_ccids(sk, skb);
 
@@ -665,6 +677,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 	case DCCP_PARTOPEN:
 		/* Step 8: if using Ack Vectors, mark packet acknowledgeable */
+		dccp_handle_ecn_codepoints(sk, skb);
 		dccp_handle_ackvec_processing(sk, skb);
 		dccp_deliver_input_to_ccids(sk, skb);
 		/* fall through */
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -130,6 +130,9 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			break;
 		}
 
+		if (dp->dccps_r_ecn_ok)
+			INET_ECN_xmit(sk);
+
 		icsk->icsk_af_ops->send_check(sk, 0, skb);
 
 		if (set_ack)
-- 
1.6.0.rc2

