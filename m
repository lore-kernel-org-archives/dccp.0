From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 18 Jun 2007 14:40:47 +0000
Subject: [PATCH 1/3]: Clarify causes of feedback, compute X_recv more accurately
Message-Id: <200706181540.47633@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Clarify causes of feedback, compute X_recv more accurately

The computation of X_recv does currently not conform to TFRC/RFC 3448,
since this specification requires that X_recv be computed over the last
R_m seconds (sec. 6.2).  

The code, in contrast, computes X_recv over the time the last feedback was 
sent. This results in sending wrong estimates of X_recv, making it impossible
for the sender to find its allowed sending rate.

The patch addresses this problem and implements a clearer interface; it
 * explicitly distinguishes the types of feedback (using an enum);
 * uses previous value of X_recv when sending feedback due to a parameter change;
 * makes all state changes local to ccid3_hc_tx_packet_recv;
 * assigns feedback type according to incident (previously only used flag `do_feedback').

Further and detailed information is at
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/#8._Computing_X_recv_ 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   39 +++++++++++++++++++++++++++------------
 net/dccp/ccids/ccid3.h |   10 +++++++++-
 2 files changed, 36 insertions(+), 13 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -124,13 +124,21 @@ static inline struct ccid3_hc_tx_sock *c
 	return ccid3_tx_priv;
 }
 
-/* TFRC receiver states */
+/* CCID3 receiver states */
 enum ccid3_hc_rx_states {
 	TFRC_RSTATE_NO_DATA = 1,
 	TFRC_RSTATE_DATA,
 	TFRC_RSTATE_TERM    = 127,
 };
 
+/* CCID3 feedback types */
+enum ccid3_fback_type {
+	FBACK_NONE = 0,
+	FBACK_INITIAL,
+	FBACK_PERIODIC,
+	FBACK_PARAM_CHANGE
+};
+
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
  *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -665,7 +665,8 @@ static inline void ccid3_hc_rx_update_s(
 		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
 }
 
-static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb)
+static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
+				      enum ccid3_fback_type fbtype)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -675,13 +676,26 @@ static void ccid3_hc_rx_send_feedback(st
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
 		return;
 
-	switch (hcrx->ccid3hcrx_state) {
-	case TFRC_RSTATE_NO_DATA:
+	switch (fbtype) {
+	case FBACK_INITIAL:
 		hcrx->ccid3hcrx_x_recv = 0;
 		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
-		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		break;
-	case TFRC_RSTATE_DATA:
+	case FBACK_PARAM_CHANGE:
+		/*
+		 * When parameters change (new loss or p > p_prev), we do not
+		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
+		 * need to  reuse the previous value of X_recv. However, when
+		 * X_recv was 0 (due to early loss), this would kill X down to
+		 * s/t_mbi (i.e. one packet in 64 seconds).
+		 * To avoid such drastic reduction, we approximate X_recv as
+		 * the number of bytes since last feedback.
+		 * This is a safe fallback, since X is bounded above by X_calc.
+		 */
+		if (hcrx->ccid3hcrx_x_recv > 0)
+			break;
+		/* fall through */
+	case FBACK_PERIODIC:
 		delta = ktime_us_delta(now, hcrx->ccid3hcrx_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
@@ -769,16 +783,17 @@ static u32 ccid3_first_li(struct sock *s
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	enum   ccid3_fback_type  do_feedback = FBACK_NONE;
 	u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
 	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
-	u8  is_data_packet = dccp_data_packet(skb), do_feedback = 0;
+	u8  is_data_packet = dccp_data_packet(skb);
 
 	spin_lock(&hcrx->ccid3hcrx_hist.lock);
 
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
-		/* Handle initial feedback */
 		if (is_data_packet) {
-			do_feedback = 1;
+			do_feedback = FBACK_INITIAL;
+			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 			ccid3_hc_rx_update_s(hcrx, payload_size);
 		}
 		goto update_records;
@@ -799,7 +814,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
 				&hcrx->ccid3hcrx_li_hist,
 				skb, ndp, ccid3_first_li, sk) ) {
-		do_feedback = 1;
+		do_feedback = FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
@@ -828,11 +843,11 @@ static void ccid3_hc_rx_packet_recv(stru
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
 		 */
-		do_feedback = 1;
+		do_feedback = FBACK_PARAM_CHANGE;
 
 	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
 	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
-		do_feedback = 1;
+		do_feedback = FBACK_PERIODIC;
 
 update_records:
 	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
@@ -841,7 +856,7 @@ done_receiving:
 	spin_unlock(&hcrx->ccid3hcrx_hist.lock);
 
 	if (do_feedback)
-		ccid3_hc_rx_send_feedback(sk, skb);
+		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
