From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:59 +0000
Subject: [PATCH 8/9]: New RX History Step 5 - CCID3 packet reception
Message-Id: <200706151532.00002@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 5 - CCID3 packet reception

This patch continues with the integration of the new RX history structure:
It takes care of
 1. recomputing p after the first loss occurred (RFC 3448, 6.1);
 2. marking history entries as `loss is indicated';
 3. sending the initial feedback (RFC 3448, 6.3)
    (Note: the state transition is now in ccid3_hc_rx_send_feedback());
 4. loss detection wrt NDUPACK (RFC 4342, 6.1).

Due to the amount of required changes, (4) was split into a subsequent patch.

Documentation on http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |  102 +++++++++++++++++++------------------------------
 1 file changed, 41 insertions(+), 61 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -685,6 +685,7 @@ static void ccid3_hc_rx_send_feedback(st
 	case TFRC_RSTATE_NO_DATA:
 		hcrx->ccid3hcrx_x_recv = 0;
 		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
+		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		break;
 	case TFRC_RSTATE_DATA:
 		delta = ktime_delta(now, hcrx->ccid3hcrx_last_feedback);
@@ -886,13 +887,44 @@ detect_out:
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *packet;
-	struct timeval now;
-	u32 p_prev, loss;
 	u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
 	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb), do_feedback = 0;
 
+	spin_lock(&hcrx->ccid3hcrx_hist.lock);
+
+	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
+		/* Handle initial feedback */
+		if (is_data_packet) {
+			do_feedback = 1;
+			ccid3_hc_rx_update_s(hcrx, payload_size);
+		}
+		goto update_records;
+	}
+
+	if (tfrc_rx_duplicate(&hcrx->ccid3hcrx_hist, skb))
+		goto done_receiving;
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
+		goto done_receiving;
+	}
+
+	if (tfrc_rx_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
+		goto update_records;
+
 	/*
 	 *	Handle data packets: RTT sampling and monitoring p
 	 */
@@ -908,70 +940,18 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	}
 
-	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, ndp, skb, GFP_ATOMIC);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
-			  "to history, consider it lost!\n", dccp_role(sk), sk);
-		return;
-	}
-
-	loss = ccid3_hc_rx_detect_loss(sk, packet);
-
-	ccid3_hc_rx_update_s(hcrx, payload_size);
-
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
-
-/* XXX periodic feedback is resolved later on, the problem with the following
- *     code is that it introduces a second variable `_tstamp_last_ack'. A
- *     solution is presented later on in the patch set, for the moment, we
- *     comment this out.
-		dccp_timestamp(sk, &now);
-		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
-		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
-			hcrx->ccid3hcrx_tstamp_last_ack = now;
-			ccid3_hc_rx_send_feedback(sk);
-		}
-*/
-		return;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return;
-	}
+	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
+		do_feedback = 1;
 
 update_records:
 	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
 
-	/* Dealing with packet loss */
-	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
-		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
-
-	p_prev = hcrx->ccid3hcrx_p;
-
-	/* Calculate loss event rate */
-	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
-
-		/* Scaling up by 1000000 as fixed decimal */
-		if (i_mean != 0)
-			hcrx->ccid3hcrx_p = 1000000 / i_mean;
-	} else
-		DCCP_BUG("empty loss history");
+done_receiving:
+	spin_unlock(&hcrx->ccid3hcrx_hist.lock);
 
-	if (hcrx->ccid3hcrx_p > p_prev) {
+	if (do_feedback)
 		ccid3_hc_rx_send_feedback(sk, skb);
-		return;
-	}
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
