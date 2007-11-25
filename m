From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:30 +0000
Subject: [PATCH 05/18] [CCID2]: Deadlock and spurious timeouts when Ack Ratio > cwnd
Message-Id: <1195950103-18102-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This patch removes a bug in the current code. I agree with Andrea's comment
that there is a problem here but the way it is treated does not fix it.

The problem is that whenever Ack Ratio > cwnd, starvation/deadlock occurs:
 * the receiver will not send an Ack until (Ack Ratio - cwnd) data packets
   have arrived;
 * the sender will not send any data packet before the receipt of an Ack
   advances the send window.
The only way that the connection then progresses was via RTO timeout. In one
extreme case (bulk transfer), it was observed that this happened for every single
packet; i.e. hundreds of packets, each a RTO timeout of 1..3 seconds apart:
a transfer which normally would take a fraction of a second thus grew to
several minutes.

The solution taken by this approach is to observe the relation

                   "Ack Ratio <= cwnd"

by using the constraint (1) from RFC 4341, 6.1.2; i.e. set

                 Ack Ratio = ceil(cwnd / 2)

and update it whenever either Ack Ratio or cwnd change. This ensures that
the deadlock problem can not arise.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   39 +++++++++++++++++++++------------------
 1 files changed, 21 insertions(+), 18 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index f18235e..ef19fb8 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -143,32 +143,30 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
+	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->ccid2hctx_cwnd, 2);
+
 	/*
-	 * XXX I don't really agree with val != 2.  If cwnd is 1, ack ratio
-	 * should be 1... it shouldn't be allowed to become 2.
-	 * -sorbo.
+	 * Ensure that Ack Ratio does not exceed ceil(cwnd/2), which is (2) from
+	 * RFC 4341, 6.1.2. We ignore the statement that Ack Ratio 2 is always
+	 * acceptable since this causes starvation/deadlock whenever cwnd < 2.
+	 * The same problem arises when Ack Ratio is 0 (ie. Ack Ratio disabled).
 	 */
-	if (val != 2) {
-		const struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-		int max = hctx->ccid2hctx_cwnd / 2;
-
-		/* round up */
-		if (hctx->ccid2hctx_cwnd & 1)
-			max++;
-
-		if (val > max)
-			val = max;
+	if (val = 0 || val > max_ratio) {
+		DCCP_WARN("Limiting Ack Ratio (%u) to %u\n", val, max_ratio);
+		val = max_ratio;
 	}
 	if (val > 0xFFFF)		/* RFC 4340, 11.3 */
 		val = 0xFFFF;
 
+	if (val = dp->dccps_l_ack_ratio)
+		return;
+
 	ccid2_pr_debug("changing local ack ratio to %u\n", val);
 	dp->dccps_l_ack_ratio = val;
 }
 
 static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, u32 val)
 {
-	/* XXX do we need to change ack ratio? */
 	hctx->ccid2hctx_cwnd = val? : 1;
 	ccid2_pr_debug("changed cwnd to %u\n", hctx->ccid2hctx_cwnd);
 }
@@ -519,9 +517,10 @@ static void ccid2_hc_tx_dec_pipe(struct sock *sk)
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
-static void ccid2_congestion_event(struct ccid2_hc_tx_sock *hctx,
-				   struct ccid2_seq *seqp)
+static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 {
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
 	if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
 		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
 		return;
@@ -533,6 +532,10 @@ static void ccid2_congestion_event(struct ccid2_hc_tx_sock *hctx,
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
+
+	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
+	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->ccid2hctx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hctx->ccid2hctx_cwnd);
 }
 
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -648,7 +651,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				    !seqp->ccid2s_acked) {
 					if (state =
 					    DCCP_ACKVEC_STATE_ECN_MARKED) {
-						ccid2_congestion_event(hctx,
+						ccid2_congestion_event(sk,
 								       seqp);
 					} else
 						ccid2_new_ack(sk, seqp,
@@ -713,7 +716,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				 * order to detect multiple congestion events in
 				 * one ack vector.
 				 */
-				ccid2_congestion_event(hctx, seqp);
+				ccid2_congestion_event(sk, seqp);
 				ccid2_hc_tx_dec_pipe(sk);
 			}
 			if (seqp = hctx->ccid2hctx_seqt)
-- 
1.5.3.4

