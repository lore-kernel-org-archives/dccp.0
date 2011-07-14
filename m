From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jul 2011 13:42:35 +0000
Subject: [PATCH 07/07] dccp ccid-2: check ack ratio when reducing cwnd
Message-Id: <1310650955-5159-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

This patch causes CCID-2 to check the ack ratio after reducing the congestion
window. If the ack ratio is greater than the congestion window, it is
reduced. This prevents timeouts caused by an ack ratio larger than the
congestion window.

In this situation, we choose to set the ack ratio to half the congestion window
(or one if that's zero) so that if we loose one ack we don't trigger a timeout.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Acked-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -101,6 +101,24 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 				   min_t(u32, val, DCCPF_ACK_RATIO_MAX));
 }
 
+static void ccid2_check_l_ack_ratio(struct sock *sk)
+{
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+
+	/*
+	 * After a loss, idle period, application limited period, or RTO we
+	 * need to check that the ack ratio is still less than the congestion
+	 * window. Otherwise, we will send an entire congestion window of
+	 * packets and got no response because we haven't sent ack ratio
+	 * packets yet.
+	 * If the ack ratio does need to be reduced, we reduce it to half of
+	 * the congestion window (or 1 if that's zero) instead of to the
+	 * congestion window. This prevents problems if one ack is lost.
+	 */
+	if (dccp_feat_nn_get(sk, DCCPF_ACK_RATIO) > hc->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd/2 ? : 1U);
+}
+
 static void ccid2_change_l_seq_window(struct sock *sk, u64 val)
 {
 	dccp_feat_signal_nn_change(sk, DCCPF_SEQUENCE_WINDOW,
@@ -187,6 +205,8 @@ static void ccid2_cwnd_application_limited(struct sock *sk, const u32 now)
 	}
 	hc->tx_cwnd_used  = 0;
 	hc->tx_cwnd_stamp = now;
+
+	ccid2_check_l_ack_ratio(sk);
 }
 
 /* This borrows the code of tcp_cwnd_restart() */
@@ -205,6 +225,8 @@ static void ccid2_cwnd_restart(struct sock *sk, const u32 now)
 
 	hc->tx_cwnd_stamp = now;
 	hc->tx_cwnd_used  = 0;
+
+	ccid2_check_l_ack_ratio(sk);
 }
 
 static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
@@ -461,9 +483,7 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 	hc->tx_cwnd      = hc->tx_cwnd / 2 ? : 1U;
 	hc->tx_ssthresh  = max(hc->tx_cwnd, 2U);
 
-	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
-	if (dccp_sk(sk)->dccps_l_ack_ratio > hc->tx_cwnd)
-		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd);
+	ccid2_check_l_ack_ratio(sk);
 }
 
 static int ccid2_hc_tx_parse_options(struct sock *sk, u8 packet_type,
