From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:54 +0000
Subject: [PATCH 7/9]: New RX History Step 4 - Integrate Receiver RTT sampling (part 3 of 3)
Message-Id: <200706151531.54253@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 4 - Integrate Receiver RTT sampling (part 3 of 3)

The previous patch introduced the new algorithm to perform receiver RTT sampling.
This patch integrates this new algorithm into CCID3. 

This results in the following changes:
 * Receiver does no longer send Timestamp option to sample the RTT.
   => This is for completeness, since the option is no longer used. If this
      algorithm proves not so good, switching back to using timestamp options
      requires to re-think the timestamp-based RTT estimation algorithm with
      regard to the issues raised in RFC 1323 (and its erratum) for RTTM; meaning
      in particular re-ordered packets and idle phases.
 * The corresponding code in the receiver has been removed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   58 ++++++++++++++++---------------------------------
 1 file changed, 19 insertions(+), 39 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -722,8 +722,7 @@ static int ccid3_hc_rx_insert_options(st
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
 
-	if (dccp_insert_option_timestamp(sk, skb) ||
-	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
+	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
 			       &x_recv, sizeof(x_recv)))
@@ -887,44 +886,29 @@ detect_out:
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
-	u32 p_prev, r_sample, rtt_prev;
-	int loss, payload_size;
+	u32 p_prev, loss;
+	u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
+	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	u8  is_data_packet = dccp_data_packet(skb), do_feedback = 0;
 
-	opt_recv = &dccp_sk(sk)->dccps_options_received;
+	/*
+	 *	Handle data packets: RTT sampling and monitoring p
+	 */
+	if (unlikely(!is_data_packet))
+		goto update_records;
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_ACK:
-		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
-			return;
-	case DCCP_PKT_DATAACK:
-		if (opt_recv->dccpor_timestamp_echo = 0)
-			break;
-		rtt_prev = hcrx->ccid3hcrx_rtt;
-		dccp_timestamp(sk, &now);
-		r_sample = dccp_sample_rtt(sk, &now, NULL);
+	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
+
+		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+		if (sample != 0)
+			hcrx->ccid3hcrx_rtt +				tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
 
-		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
-			hcrx->ccid3hcrx_rtt = r_sample;
-		else
-			hcrx->ccid3hcrx_rtt = (hcrx->ccid3hcrx_rtt * 9) / 10 +
-					      r_sample / 10;
-
-		if (rtt_prev != hcrx->ccid3hcrx_rtt)
-			ccid3_pr_debug("%s(%p), New RTT=%uus, elapsed time=%u\n",
-				       dccp_role(sk), sk, hcrx->ccid3hcrx_rtt,
-				       opt_recv->dccpor_elapsed_time);
-		break;
-	case DCCP_PKT_DATA:
-		break;
-	default: /* We're not interested in other packet types, move along */
-		return;
 	}
 
-	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
-					skb, GFP_ATOMIC);
+	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, ndp, skb, GFP_ATOMIC);
 	if (unlikely(packet = NULL)) {
 		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
 			  "to history, consider it lost!\n", dccp_role(sk), sk);
@@ -933,10 +917,6 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	loss = ccid3_hc_rx_detect_loss(sk, packet);
 
-	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
-		return;
-
-	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	ccid3_hc_rx_update_s(hcrx, payload_size);
 
 	switch (hcrx->ccid3hcrx_state) {
@@ -969,8 +949,8 @@ static void ccid3_hc_rx_packet_recv(stru
 		return;
 	}
 
-	/* Update highest received sequence number so far */
-	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, opt_recv->dccpor_ndp);
+update_records:
+	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
 
 	/* Dealing with packet loss */
 	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
