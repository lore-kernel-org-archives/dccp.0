From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:48 +0000
Subject: [PATCH 3/7] dccp ccid-3: Always perform receiver RTT sampling
Message-Id: <1217325952-12337-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates the CCID-3 receiver in part with regard to errata 610 and 611
(http://www.rfc-editor.org/errata_list.php), which change RFC 4342 to use
the definition of the Receive Rate X_recv as specified in rfc3448bis.

This requires to constantly sample the RTT throughout the connection, and to
reuse the RX history for sampling after dealing with a loss.

Since this is all TFRC-based functionality, the RTT estimation is now also
performed by the dccp_tfrc_lib module. This further simplifies the CCID-3 code.

The patch does not resolve how to compute X_recv if the interval is less
than 1 RTT. A FIXME has been added (and is resolved by a subsequent patch).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   43 ++++++++-----------------
 net/dccp/ccids/ccid3.h              |    2 -
 net/dccp/ccids/lib/packet_history.c |   60 +++++++++++++++++++++++++---------
 net/dccp/ccids/lib/packet_history.h |   17 +++++++++-
 4 files changed, 73 insertions(+), 49 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -91,6 +91,7 @@ struct tfrc_rx_hist_entry {
  * @loss_count:		Number of entries in circular history
  * @loss_start:		Movable index (for loss detection)
  * @rtt_sample_prev:	Used during RTT sampling, points to candidate entry
+ * @rtt_estimate:	Receiver RTT estimate
  * @packet_size:	Packet size in bytes (as per RFC 3448, 3.1)
  * @bytes_recvd:	Number of bytes received since last sending feedback
  */
@@ -98,7 +99,10 @@ struct tfrc_rx_hist {
 	struct tfrc_rx_hist_entry *ring[TFRC_NDUPACK + 1];
 	u8			  loss_count:2,
 				  loss_start:2;
+	/* Receiver RTT sampling */
 #define rtt_sample_prev		  loss_start
+	u32			  rtt_estimate;
+	/* Receiver sampling of application payload lengths */
 	u32			  packet_size,
 				  bytes_recvd;
 };
@@ -154,6 +158,15 @@ static inline u32 tfrc_rx_hist_packet_size(const struct tfrc_rx_hist *h)
 		return TCP_MIN_RCVMSS;
 	}
 	return h->packet_size;
+
+}
+static inline u32 tfrc_rx_hist_rtt(const struct tfrc_rx_hist *h)
+{
+	if (h->rtt_estimate = 0) {
+		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
+		return  DCCP_FALLBACK_RTT;
+	}
+	return h->rtt_estimate;
 }
 
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
@@ -167,8 +180,8 @@ extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 				struct sk_buff *skb, const u64 ndp,
 				u32 (*first_li)(struct sock *sk),
 				struct sock *sk);
-extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
-				   const struct sk_buff *skb);
+extern void tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
+				    const struct sk_buff *skb);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *h, struct sock *sk);
 extern void tfrc_rx_hist_purge(struct tfrc_rx_hist *h);
 
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -151,14 +151,31 @@ int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_duplicate);
 
+
+static void __tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
+{
+	struct tfrc_rx_hist_entry *tmp = h->ring[a];
+
+	h->ring[a] = h->ring[b];
+	h->ring[b] = tmp;
+}
+
 static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
 {
-	const u8 idx_a = tfrc_rx_hist_index(h, a),
-		 idx_b = tfrc_rx_hist_index(h, b);
-	struct tfrc_rx_hist_entry *tmp = h->ring[idx_a];
+	__tfrc_rx_hist_swap(h, tfrc_rx_hist_index(h, a),
+			       tfrc_rx_hist_index(h, b));
+}
 
-	h->ring[idx_a] = h->ring[idx_b];
-	h->ring[idx_b] = tmp;
+/**
+ * tfrc_rx_hist_resume_rtt_sampling  -  Prepare RX history for RTT sampling
+ * This is called after loss detection has finished, when the history entry
+ * with the index of `loss_count' holds the highest-received sequence number.
+ * RTT sampling requires this information at ring[0] (tfrc_rx_hist_sample_rtt).
+ */
+static inline void tfrc_rx_hist_resume_rtt_sampling(struct tfrc_rx_hist *h)
+{
+	__tfrc_rx_hist_swap(h, 0, tfrc_rx_hist_index(h, h->loss_count));
+	h->loss_count = h->loss_start = 0;
 }
 
 /*
@@ -200,8 +217,7 @@ static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2
 
 		if (dccp_loss_free(s2, s1, n1)) {
 			/* hole is filled: S0, S2, and S1 are consecutive */
-			h->loss_count = 0;
-			h->loss_start = tfrc_rx_hist_index(h, 1);
+			tfrc_rx_hist_resume_rtt_sampling(h);
 		} else
 			/* gap between S2 and S1: just update loss_prev */
 			tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_loss_prev(h), skb, n2);
@@ -254,8 +270,7 @@ static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
 
 			if (dccp_loss_free(s1, s2, n2)) {
 				/* entire hole filled by S0, S3, S1, S2 */
-				h->loss_start = tfrc_rx_hist_index(h, 2);
-				h->loss_count = 0;
+				tfrc_rx_hist_resume_rtt_sampling(h);
 			} else {
 				/* gap remains between S1 and S2 */
 				h->loss_start = tfrc_rx_hist_index(h, 1);
@@ -299,8 +314,7 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
 
 		if (dccp_loss_free(s2, s3, n3)) {
 			/* no gap between S2 and S3: entire hole is filled */
-			h->loss_start = tfrc_rx_hist_index(h, 3);
-			h->loss_count = 0;
+			tfrc_rx_hist_resume_rtt_sampling(h);
 		} else {
 			/* gap between S2 and S3 */
 			h->loss_start = tfrc_rx_hist_index(h, 2);
@@ -340,6 +354,7 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 
 	if (h->loss_count = 0) {
 		__do_track_loss(h, skb, ndp);
+		tfrc_rx_hist_sample_rtt(h, skb);
 	} else if (h->loss_count = 1) {
 		__one_after_loss(h, skb, ndp);
 	} else if (h->loss_count != 2) {
@@ -435,11 +450,24 @@ static inline struct tfrc_rx_hist_entry *
  * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
  * to compute a sample with given data - calling function should check this.
  */
-u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
+void tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
 {
-	u32 sample = 0,
-	    delta_v = SUB16(dccp_hdr(skb)->dccph_ccval,
-			    tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
+	u32 sample = 0, delta_v;
+
+	/*
+	 * When not to sample:
+	 * - on non-data packets
+	 *   (RFC 4342, 8.1: CCVal only fully defined for data packets);
+	 * - when no data packets have been received yet
+	 *   (FIXME: using sampled packet size as indicator here);
+	 * - as long as there are gaps in the sequence space (pending loss).
+	 */
+	if (!dccp_data_packet(skb) || h->packet_size = 0 ||
+	    tfrc_rx_hist_loss_pending(h))
+		return;
+
+	delta_v = SUB16(dccp_hdr(skb)->dccph_ccval,
+			tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
 
 	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
 		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
@@ -479,6 +507,6 @@ u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
 	h->rtt_sample_prev = 0;	       /* use current entry as next reference */
 keep_ref_for_next_time:
 
-	return sample;
+	h->rtt_estimate = tfrc_ewma(h->rtt_estimate, sample, 9);
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_sample_rtt);
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -127,7 +127,6 @@ enum ccid3_fback_type {
  *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @feedback  -  The type of the feedback last sent
  *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @rtt  -  Receiver estimate of RTT
  *  @tstamp_last_feedback  -  Time at which last feedback was sent
  *  @hist  -  Packet history (loss detection + RTT sampling)
  *  @li_hist  -  Loss Interval database
@@ -137,7 +136,6 @@ struct ccid3_hc_rx_sock {
 	u8				last_counter:4;
 	enum ccid3_fback_type		feedback:4;
 	u32				x_recv;
-	u32				rtt;
 	ktime_t				tstamp_last_feedback;
 	struct tfrc_rx_hist		hist;
 	struct tfrc_loss_hist		li_hist;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -556,8 +556,8 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 			 * would bring X down to s/t_mbi. That is why we return
 			 * X_recv according to rfc3448bis-06 for the moment.
 			 */
-			u32 rtt = hcrx->rtt ? : DCCP_FALLBACK_RTT,
-			    s	= tfrc_rx_hist_packet_size(&hcrx->hist);
+			u32 s = tfrc_rx_hist_packet_size(&hcrx->hist),
+			    rtt = tfrc_rx_hist_rtt(&hcrx->hist);
 
 			hcrx->x_recv = scaled_div32(s, 2 * rtt);
 			break;
@@ -576,6 +576,11 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 			break;
 		/* fall through */
 	case CCID3_FBACK_PERIODIC:
+		/*
+		 * FIXME: check if delta is less than or equal to 1 RTT using
+		 * the receiver RTT sample. This is described in Errata 610/611
+		 * of RFC 4342 which reference section 6.2 of RFC 3448.
+		 */
 		delta = ktime_us_delta(now, hcrx->tstamp_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
@@ -633,8 +638,8 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 static u32 ccid3_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	u32 x_recv, p, delta,
-	    s = tfrc_rx_hist_packet_size(&hcrx->hist);
+	u32 s = tfrc_rx_hist_packet_size(&hcrx->hist),
+	    rtt = tfrc_rx_hist_rtt(&hcrx->hist), x_recv, p, delta;
 	u64 fval;
 
 	/*
@@ -645,11 +650,6 @@ static u32 ccid3_first_li(struct sock *sk)
 	if (unlikely(hcrx->feedback = CCID3_FBACK_NONE))
 		return 5;
 
-	if (hcrx->rtt = 0) {
-		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->rtt = DCCP_FALLBACK_RTT;
-	}
-
 	delta = ktime_to_us(net_timedelta(hcrx->tstamp_last_feedback));
 	x_recv = scaled_div32(hcrx->hist.bytes_recvd, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
@@ -661,7 +661,7 @@ static u32 ccid3_first_li(struct sock *sk)
 		x_recv = hcrx->x_recv;
 	}
 
-	fval = scaled_div32(scaled_div(s, hcrx->rtt), x_recv);
+	fval = scaled_div32(scaled_div(s, rtt), x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
 	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
@@ -696,25 +696,10 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		return; /* done receiving */
 
 	/*
-	 * Handle data packets: RTT sampling and monitoring p
-	 */
-	if (unlikely(!is_data_packet))
-		goto update_records;
-
-	if (!tfrc_lh_is_initialised(&hcrx->li_hist)) {
-		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->hist, skb);
-		/*
-		 * Empty loss history: no loss so far, hence p stays 0.
-		 * Sample RTT values, since an RTT estimate is required for the
-		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
-		 */
-		if (sample != 0)
-			hcrx->rtt = tfrc_ewma(hcrx->rtt, sample, 9);
-	}
-	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
+	if (is_data_packet &&
+	    SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
 		do_feedback = CCID3_FBACK_PERIODIC;
 
 update_records:
@@ -744,7 +729,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->rtt;
+	info->tcpi_rcv_rtt  = tfrc_rx_hist_rtt(&ccid3_hc_rx_sk(sk)->hist);
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
@@ -759,7 +744,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 		if (len < sizeof(rx_info))
 			return -EINVAL;
 		rx_info.tfrcrx_x_recv = hcrx->x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->rtt;
+		rx_info.tfrcrx_rtt    = tfrc_rx_hist_rtt(&hcrx->hist);
 		rx_info.tfrcrx_p      = tfrc_invert_loss_event_rate(hcrx->p_inverse);
 		len = sizeof(rx_info);
 		val = &rx_info;
