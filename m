From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:34:12 +0000
Subject: [PATCH 12/43]: New RX History Step 5 - CCID3 packet reception
Message-Id: <200704051634.12715@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 5 - CCID3 packet reception

This patch continues with the integration of the new RX history structure.
It takes care of
 1. Receiver RTT sampling until first loss occurs (this replaces the existing
    mechanism which was unreliable due to requiring timestamp/elapsed time
    option from the sender; now uses the algorithm from RFC 4343, 8.1);
 2. Recomputing p after the first loss occurred (RFC 3448, 6.1);
 3. Marking history entries as `loss is indicated';
 4. Sending first feedback (RFC 3448, 6.3; note the state transition is now
    in ccid3_hc_rx_send_feedback());		
 5. Loss detection wrt NDUPACK (RFC 4342, 6.1);
 6. Tracking of the highest-received-seqno so far (used for loss detection).

Due to the amount of required changes, (5) was split into a subsequent patch.
As a byproduct, the socket struct again gets a little smaller.

Documentation on http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |  131 +++++++++++++++++++------------------------------
 net/dccp/ccids/ccid3.h |    4 -
 2 files changed, 53 insertions(+), 82 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -133,10 +133,9 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
+ *  @ccid3hcrx_rtt  -  Receiver estimate of RTT (RFC 4342, 8.1)
  *  @ccid3hcrx_pinv  -  Reciprocal of Loss Event Rate p (RFC 4342, sec. 8.5)
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history exported by TFRC module
  *  @ccid3hcrx_li_hist  -  Loss Interval History
  *  @ccid3hcrx_elapsed_time  -  Time since packet reception
@@ -150,7 +149,6 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_rtt;
 	u32				ccid3hcrx_pinv;
 	struct timeval			ccid3hcrx_tstamp_last_feedback;
-	struct timeval			ccid3hcrx_tstamp_last_ack;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u32				ccid3hcrx_elapsed_time;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -729,9 +729,6 @@ static int ccid3_hc_rx_update_p(struct c
 	struct list_head *li_hist = &hcrx->ccid3hcrx_li_hist;
 	u32 pinv_prev = hcrx->ccid3hcrx_pinv;
 
-	if (list_empty(li_hist)) /* only empty if no loss so far, i.e. p = 0 */
-		return 0;
-
 	hcrx->ccid3hcrx_pinv = dccp_li_hist_calc_i_mean(li_hist);
 	if (hcrx->ccid3hcrx_pinv = 0) {
 		DCCP_BUG("non-empty LI history and yet I_mean = 0!");
@@ -755,6 +752,7 @@ static void ccid3_hc_rx_send_feedback(st
 	case TFRC_RSTATE_NO_DATA:
 		hcrx->ccid3hcrx_x_recv = 0;
 		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
+		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		break;
 	case TFRC_RSTATE_DATA:
 		delta = timeval_delta(&now,
@@ -966,96 +964,73 @@ detect_out:
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	const struct dccp_options_received *opt_recv;
-	struct dccp_rx_hist_entry *packet;
-	struct timeval now;
-	u32 r_sample, rtt_prev;
-	int loss, payload_size;
+	u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
+	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+	u8  is_data_packet = dccp_data_packet(skb), do_feedback = 0;
 
 	BUG_ON(hcrx = NULL);
 
-	opt_recv = &dccp_sk(sk)->dccps_options_received;
+	spin_lock(&hcrx->ccid3hcrx_hist.lock);
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_ACK:
-		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
-			return;
-	case DCCP_PKT_DATAACK:
-		if (opt_recv->dccpor_timestamp_echo = 0)
-			break;
-		rtt_prev = hcrx->ccid3hcrx_rtt;
-		do_gettimeofday(&now);
-		r_sample = dccp_sample_rtt(sk, &now, NULL);
-
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
+	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
+		/* Handle initial feedback */
+		if (is_data_packet) {
+			do_feedback = 1;
+			ccid3_hc_rx_update_s(hcrx, payload_size);
+		}
+		goto update_records;
 	}
 
-#if 0	/* XXX resolved by subsequent patch */
-	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
-					skb, GFP_ATOMIC);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
-			  "to history, consider it lost!\n", dccp_role(sk), sk);
+	if (tfrc_rx_duplicate(&hcrx->ccid3hcrx_hist, skb))
 		return;
+
+	if (is_data_packet) {
+		ccid3_hc_rx_update_s(hcrx, payload_size);
+		hcrx->ccid3hcrx_bytes_recv += payload_size;
+	}
+
+	/*
+	 *	Handle pending losses and otherwise check for new loss
+	 */
+	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist)) {
+		/*
+		 * Loss Handling
+		 *
+		 * XXX: part of subsequent patch
+		 */
+		goto sending_feedback;
 	}
 
-	loss = ccid3_hc_rx_detect_loss(sk, packet);
+	if (tfrc_rx_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
+		goto update_records;
 
-#endif
-	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
-		return;
+	/*
+	 *	Handle data packets: RTT sampling and monitoring p
+	 */
+	if (unlikely(!is_data_packet))
+		goto update_records;
 
-	payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
-	ccid3_hc_rx_update_s(hcrx, payload_size);
+	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
 
-	switch (hcrx->ccid3hcrx_state) {
-	case TFRC_RSTATE_NO_DATA:
-		ccid3_pr_debug("%s(%p, state=%s), skb=%p, sending initial "
-			       "feedback\n", dccp_role(sk), sk,
-			       dccp_state_name(sk->sk_state), skb);
-		ccid3_hc_rx_send_feedback(sk, skb);
-		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-		return;
-	case TFRC_RSTATE_DATA:
-		hcrx->ccid3hcrx_bytes_recv += payload_size;
-		if (loss)
-			break;
+		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+		if (sample != 0)
+			TFRC_EWMA(hcrx->ccid3hcrx_rtt, sample, 9);
 
-		do_gettimeofday(&now);
-		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
-		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
-			hcrx->ccid3hcrx_tstamp_last_ack = now;
-			ccid3_hc_rx_send_feedback(sk, skb);
-		}
-		return;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return;
-	}
+	} else if (ccid3_hc_rx_update_p(hcrx))	/* recompute p; RFC 3448, 6.1 */
+		do_feedback = 1;
 
-	/* Dealing with packet loss */
-	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
-		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
+	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
+		do_feedback = 1;
 
-	if (ccid3_hc_rx_update_p(hcrx))
-		ccid3_hc_rx_send_feedback(sk, skb);
+update_records:
+	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
 
-	/* Update highest received sequence number so far */
-	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, opt_recv->dccpor_ndp);
+sending_feedback:
+	spin_unlock(&hcrx->ccid3hcrx_hist.lock);
+
+	if (do_feedback)
+		ccid3_hc_rx_send_feedback(sk, skb);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
@@ -1067,8 +1042,6 @@ static int ccid3_hc_rx_init(struct ccid 
 	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
 		return 1;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	do_gettimeofday(&hcrx->ccid3hcrx_tstamp_last_ack);
-	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	hcrx->ccid3hcrx_s     = 0;
 	hcrx->ccid3hcrx_rtt   = 0;
