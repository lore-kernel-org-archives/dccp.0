From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:35:34 +0000
Subject: [PATCH 24/43]: Hook up CCID3 with new Loss Intervals Database
Message-Id: <200704051635.34180@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Hook up CCID3 with new Loss Intervals Database

This hooks up the TFRC Loss Interval database with CCID 3 packet reception.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   47 +++++++++++++++++++----------------------------
 net/dccp/ccids/ccid3.h |    8 ++++----
 2 files changed, 23 insertions(+), 32 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -135,8 +135,8 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_rtt  -  Receiver estimate of RTT (RFC 4342, 8.1)
  *  @ccid3hcrx_pinv  -  Reciprocal of Loss Event Rate p (RFC 4342, sec. 8.5)
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history exported by TFRC module
- *  @ccid3hcrx_li_hist  -  Loss Interval History
+ *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
+ *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
  *  @ccid3hcrx_elapsed_time  -  Time since packet reception
  */
 struct ccid3_hc_rx_sock {
@@ -146,10 +146,10 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_bytes_recv;
 	u32				ccid3hcrx_x_recv;
 	u32				ccid3hcrx_rtt;
-	u32				ccid3hcrx_pinv;
+#define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
 	struct timeval			ccid3hcrx_tstamp_last_feedback;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
-	struct list_head		ccid3hcrx_li_hist;
+	struct tfrc_loss_hist		ccid3hcrx_li_hist;
 	u32				ccid3hcrx_elapsed_time;
 };
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -720,24 +720,6 @@ static inline void ccid3_hc_rx_update_s(
 		TFRC_EWMA(hcrx->ccid3hcrx_s, len, 9);
 }
 
-/* returns: 1 when p > p_prev (i.e. when feedback is required); 0 else */
-static int ccid3_hc_rx_update_p(struct ccid3_hc_rx_sock *hcrx)
-{
-	struct list_head *li_hist = &hcrx->ccid3hcrx_li_hist;
-	u32 pinv_prev = hcrx->ccid3hcrx_pinv;
-
-	/* XXX subsequent patch
-	hcrx->ccid3hcrx_pinv = dccp_li_hist_calc_i_mean(li_hist);
-	*/
-	if (hcrx->ccid3hcrx_pinv = 0) {
-		DCCP_BUG("non-empty LI history and yet I_mean = 0!");
-		return 0;
-	}
-
-	/* exploit that  p > p_prev  <=>  1/p < 1/p_prev  */
-	return (hcrx->ccid3hcrx_pinv < pinv_prev);
-}
-
 static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -886,9 +868,11 @@ static void ccid3_hc_rx_packet_recv(stru
 	/*
 	 *	Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist)) {
-
-		do_feedback = tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist, skb, ndp);
+	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
+				&hcrx->ccid3hcrx_li_hist,
+				skb, ndp, ccid3_first_li, sk) ) {
+		do_feedback = 1;
 		goto sending_feedback;
 	}
 
@@ -901,15 +885,24 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
-
+	if (! tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
+		/*
+		 * Empty loss history: no loss so far, hence p stays 0.
+		 * Sample RTT values, since an RTT estimate is required for the
+		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
+		 */
 		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
 		if (sample != 0)
 			TFRC_EWMA(hcrx->ccid3hcrx_rtt, sample, 9);
 
-	} else if (ccid3_hc_rx_update_p(hcrx))	/* recompute p; RFC 3448, 6.1 */
+	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb))
+		/*
+		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
+		 * has decreased (resp. p has increased), send feedback now.
+		 */
 		do_feedback = 1;
 
+
 	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
 	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
 		do_feedback = 1;
@@ -932,7 +925,7 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
 		return 1;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	hcrx->ccid3hcrx_s     = 0;
 	hcrx->ccid3hcrx_rtt   = 0;
@@ -948,9 +941,7 @@ static void ccid3_hc_rx_exit(struct sock
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
-
-	/* Empty loss interval history */
-	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
