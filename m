From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:51 +0000
Subject: [PATCH 6/7] dccp ccid-3: Update the computation of X_recv
Message-Id: <1217325952-12337-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates the computation of X_recv with regard to Errata 610/611 for
RFC 4342 and draft rfc3448bis-06, ensuring that at least an interval of 1
RTT is used to compute X_recv.
That change is wrapped into a new function, ccid3_hc_rx_x_recv().

Further changes:
----------------
 * feedback is not sent when no data packets arrived (bytes_recv = 0), as per
   rfc3448bis-06, 6.2;
 * take the timestamp for the feedback /after/ dccp_send_ack() returns, to avoid
   taking the transmission time into account (in case layer-2 is busy);
 * clearer handling of failure in ccid3_first_li().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   64 +++++++++++++----------------------
 net/dccp/ccids/lib/packet_history.c |   30 ++++++++++++++++
 net/dccp/ccids/lib/packet_history.h |   13 ++++++-
 3 files changed, 66 insertions(+), 41 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -533,9 +533,6 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 				      enum ccid3_fback_type fbtype)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_sock *dp = dccp_sk(sk);
-	ktime_t now = ktime_get_real();
-	s64 delta = 0;
 
 	switch (fbtype) {
 	case CCID3_FBACK_INITIAL:
@@ -565,42 +562,33 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		/*
 		 * When parameters change (new loss or p > p_prev), we do not
 		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
-		 * need to  reuse the previous value of X_recv. However, when
-		 * X_recv was 0 (due to early loss), this would kill X down to
-		 * s/t_mbi (i.e. one packet in 64 seconds).
-		 * To avoid such drastic reduction, we approximate X_recv as
-		 * the number of bytes since last feedback.
-		 * This is a safe fallback, since X is bounded above by X_calc.
+		 * always check whether at least RTT time units were covered.
 		 */
-		if (hcrx->x_recv > 0)
-			break;
-		/* fall through */
+		hcrx->x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		break;
 	case CCID3_FBACK_PERIODIC:
 		/*
-		 * FIXME: check if delta is less than or equal to 1 RTT using
-		 * the receiver RTT sample. This is described in Errata 610/611
-		 * of RFC 4342 which reference section 6.2 of RFC 3448.
+		 * Step (2) of rfc3448bis-06, 6.2:
+		 * - if no data packets have been received, just restart timer
+		 * - if data packets have been received, re-compute X_recv
 		 */
-		delta = ktime_us_delta(now, hcrx->tstamp_last_feedback);
-		if (delta <= 0)
-			DCCP_BUG("delta (%ld) <= 0", (long)delta);
-		else
-			hcrx->x_recv = scaled_div32(hcrx->hist.bytes_recvd, delta);
+		if (hcrx->hist.bytes_recvd = 0)
+			goto prepare_for_next_time;
+		hcrx->x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
 		break;
 	default:
 		return;
 	}
 
-	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n",
-		       (long)delta, hcrx->x_recv, hcrx->p_inverse);
+	ccid3_pr_debug("X_recv=%u, 1/p=%u\n", hcrx->x_recv, hcrx->p_inverse);
 
-	hcrx->tstamp_last_feedback = now;
-	hcrx->last_counter	   = dccp_hdr(skb)->dccph_ccval;
-	hcrx->hist.bytes_recvd	   = 0;
-	hcrx->feedback		   = fbtype;
-
-	dp->dccps_hc_rx_insert_options = 1;
+	dccp_sk(sk)->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
+
+prepare_for_next_time:
+	tfrc_rx_hist_restart_byte_counter(&hcrx->hist);
+	hcrx->last_counter = dccp_hdr(skb)->dccph_ccval;
+	hcrx->feedback	   = fbtype;
 }
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
@@ -639,7 +627,7 @@ static u32 ccid3_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	u32 s = tfrc_rx_hist_packet_size(&hcrx->hist),
-	    rtt = tfrc_rx_hist_rtt(&hcrx->hist), x_recv, p, delta;
+	    rtt = tfrc_rx_hist_rtt(&hcrx->hist), x_recv, p;
 	u64 fval;
 
 	/*
@@ -650,16 +638,9 @@ static u32 ccid3_first_li(struct sock *sk)
 	if (unlikely(hcrx->feedback = CCID3_FBACK_NONE))
 		return 5;
 
-	delta = ktime_to_us(net_timedelta(hcrx->tstamp_last_feedback));
-	x_recv = scaled_div32(hcrx->hist.bytes_recvd, delta);
-	if (x_recv = 0) {		/* would also trigger divide-by-zero */
-		DCCP_WARN("X_recv=0\n");
-		if (hcrx->x_recv = 0) {
-			DCCP_BUG("stored value of X_recv is zero");
-			return ~0U;
-		}
-		x_recv = hcrx->x_recv;
-	}
+	x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+	if (x_recv = 0)
+		goto failed;
 
 	fval = scaled_div32(scaled_div(s, rtt), x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
@@ -667,7 +648,10 @@ static u32 ccid3_first_li(struct sock *sk)
 	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
-	return p = 0 ? ~0U : scaled_div(1, p);
+	if (p > 0)
+		return scaled_div(1, p);
+failed:
+	return UINT_MAX;
 }
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -93,7 +93,8 @@ struct tfrc_rx_hist_entry {
  * @rtt_sample_prev:	Used during RTT sampling, points to candidate entry
  * @rtt_estimate:	Receiver RTT estimate
  * @packet_size:	Packet size in bytes (as per RFC 3448, 3.1)
- * @bytes_recvd:	Number of bytes received since last sending feedback
+ * @bytes_recvd:	Number of bytes received since @bytes_start
+ * @bytes_start:	Start time for counting @bytes_recvd
  */
 struct tfrc_rx_hist {
 	struct tfrc_rx_hist_entry *ring[TFRC_NDUPACK + 1];
@@ -105,6 +106,7 @@ struct tfrc_rx_hist {
 	/* Receiver sampling of application payload lengths */
 	u32			  packet_size,
 				  bytes_recvd;
+	ktime_t			  bytes_start;
 };
 
 /**
@@ -169,6 +171,15 @@ static inline u32 tfrc_rx_hist_rtt(const struct tfrc_rx_hist *h)
 	return h->rtt_estimate;
 }
 
+static inline void tfrc_rx_hist_restart_byte_counter(struct tfrc_rx_hist *h)
+{
+	h->bytes_recvd = 0;
+	h->bytes_start = ktime_get_real();
+}
+
+extern u32  tfrc_rx_hist_x_recv(struct tfrc_rx_hist *h, const u32 last_x_recv);
+
+
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 				    const struct sk_buff *skb, const u64 ndp);

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -385,6 +385,36 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
 
+/* Compute the sending rate X_recv measured between feedback intervals */
+u32 tfrc_rx_hist_x_recv(struct tfrc_rx_hist *h, const u32 last_x_recv)
+{
+	u64 bytes = h->bytes_recvd, last_rtt = h->rtt_estimate;
+	s64 delta = ktime_to_us(net_timedelta(h->bytes_start));
+
+	WARN_ON(delta <= 0);
+	/*
+	 * Ensure that the sampling interval for X_recv is at least one RTT,
+	 * by extending the sampling interval backwards in time, over the last
+	 * R_(m-1) seconds, as per rfc3448bis-06, 6.2.
+	 * To reduce noise (e.g. when the RTT changes often), this is only
+	 * done when delta is smaller than RTT/2.
+	 */
+	if (last_x_recv > 0 && delta < last_rtt/2) {
+		tfrc_pr_debug("delta < RTT => %ld us < %u us\n",
+			      (long)delta, (unsigned)last_rtt);
+
+		delta = (bytes ? delta : 0) + last_rtt;
+		bytes += div_u64((u64)last_x_recv * last_rtt, USEC_PER_SEC);
+	}
+
+	if (unlikely(bytes = 0)) {
+		DCCP_WARN("X_recv = 0, using old value of %u\n", last_x_recv);
+		return last_x_recv;
+	}
+	return scaled_div32(bytes, delta);
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_x_recv);
+
 void tfrc_rx_hist_purge(struct tfrc_rx_hist *h)
 {
 	int i;
