From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jul 2011 13:42:33 +0000
Subject: [PATCH 05/07] dccp ccid-2: prevent cwnd > sequence window
Message-Id: <1310650955-5159-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

Add a check to prevent CCID-2 from increasing the Congestion Window greater
than the Sequence Window.

When the congestion window becomes bigger than the sequence window, CCID-2
will attempt to keep more data in the network than the DCCP sequence window
code considers possible. This results in the sequence window code issuing
a sync, thereby inducing needless overhead. Further, if this occurs at the
sender, CCID-2 will never detect the problem because th Acks it receives
will indicate no losses. I have seen this cause a drop of 1/3rd in throughput
for a connection.

Also add code to adjust the sequence window to be about 5 times the number of
packets in the network (RFC 4340 7.5.2) and to adjust the Ack Ratio so that
the remote sequence window will hold about 5 times the number of packets in
the network. This allows the congestion window to increase correctly without
being limited by the sequence window.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

**** EDITORIAL: patches merged into this one from earlier iterations ***********
dccp ccid-2: use new interface to refactor dynamic negotiation

Using the new function dccp_feat_get_nn_next_val(), this simplifies existing
code to not trigger a new negotiation if the requested new value equals the
old one.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
**** EDITORIAL: patches merged into this one from earlier iterations ***********
---
 net/dccp/ccids/ccid2.h |    6 +++++
 net/dccp/ccids/ccid2.c |   50 +++++++++++++++++++++++++++++++++--------------
 2 files changed, 41 insertions(+), 15 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -43,6 +43,12 @@ struct ccid2_seq {
 #define CCID2_SEQBUF_LEN 1024
 #define CCID2_SEQBUF_MAX 128
 
+/*
+ * Multiple of congestion window to keep the sequence window at
+ * (RFC 4340 7.5.2)
+ */
+#define CCID2_WIN_CHANGE_FACTOR 5
+
 /**
  * struct ccid2_hc_tx_sock - CCID2 TX half connection
  * @tx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -85,7 +85,6 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->tx_cwnd, 2);
 
 	/*
@@ -98,14 +97,15 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 		DCCP_WARN("Limiting Ack Ratio (%u) to %u\n", val, max_ratio);
 		val = max_ratio;
 	}
-	if (val > DCCPF_ACK_RATIO_MAX)
-		val = DCCPF_ACK_RATIO_MAX;
-
-	if (val = dp->dccps_l_ack_ratio)
-		return;
+	dccp_feat_signal_nn_change(sk, DCCPF_ACK_RATIO,
+				   min_t(u32, val, DCCPF_ACK_RATIO_MAX));
+}
 
-	ccid2_pr_debug("changing local ack ratio to %u\n", val);
-	dp->dccps_l_ack_ratio = val;
+static void ccid2_change_l_seq_window(struct sock *sk, u64 val)
+{
+	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW,
+				   clamp_val(val, DCCPF_SEQ_WMIN,
+						  DCCPF_SEQ_WMAX));
 }
 
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -405,17 +405,37 @@ static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
 			  unsigned int *maxincr)
 {
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
-
-	if (hc->tx_cwnd < hc->tx_ssthresh) {
-		if (*maxincr > 0 && ++hc->tx_packets_acked = 2) {
+	struct dccp_sock *dp = dccp_sk(sk);
+	int r_seq_used = hc->tx_cwnd / dp->dccps_l_ack_ratio;
+
+	if (hc->tx_cwnd < dp->dccps_l_seq_win &&
+	    r_seq_used < dp->dccps_r_seq_win) {
+		if (hc->tx_cwnd < hc->tx_ssthresh) {
+			if (*maxincr > 0 && ++hc->tx_packets_acked = 2) {
+				hc->tx_cwnd += 1;
+				*maxincr    -= 1;
+				hc->tx_packets_acked = 0;
+			}
+		} else if (++hc->tx_packets_acked >= hc->tx_cwnd) {
 			hc->tx_cwnd += 1;
-			*maxincr    -= 1;
 			hc->tx_packets_acked = 0;
 		}
-	} else if (++hc->tx_packets_acked >= hc->tx_cwnd) {
-			hc->tx_cwnd += 1;
-			hc->tx_packets_acked = 0;
 	}
+
+	/*
+	 * Adjust the local sequence window and the ack ratio to allow about
+	 * 5 times the number of packets in the network (RFC 4340 7.5.2)
+	 */
+	if (r_seq_used * CCID2_WIN_CHANGE_FACTOR >= dp->dccps_r_seq_win)
+		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio * 2);
+	else if (r_seq_used * CCID2_WIN_CHANGE_FACTOR < dp->dccps_r_seq_win/2)
+		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio / 2 ? : 1U);
+
+	if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR >= dp->dccps_l_seq_win)
+		ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win * 2);
+	else if (hc->tx_cwnd * CCID2_WIN_CHANGE_FACTOR < dp->dccps_l_seq_win/2)
+		ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win / 2);
+
 	/*
 	 * FIXME: RTT is sampled several times per acknowledgment (for each
 	 * entry in the Ack Vector), instead of once per Ack (as in TCP SACK).
