From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:46 +0000
Subject: [PATCH 1/7] dccp tfrc: Let dccp_tfrc_lib do the sampling work
Message-Id: <1217325952-12337-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This migrates more TFRC-related code into the dccp_tfrc_lib:
 * sampling of the packet size `s' (which is only needed until the first
   loss interval is computed (ccid3_first_li));
 * updating the byte-counter `bytes_recvd' in between sending feedbacks.

The result is a better separation of CCID-3 specific and TFRC specific
code, which aids future integration with ECN and e.g. CCID-4.

Further changes:
----------------
 * replaced magic number of 536 with equivalent constant TCP_MIN_RCVMSS;
   (this constant is also used when no estimate for `s' is available).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   38 +++++++---------------------------
 net/dccp/ccids/ccid3.h              |    4 ---
 net/dccp/ccids/lib/packet_history.c |   10 +++++++++
 net/dccp/ccids/lib/packet_history.h |   16 ++++++++++++++
 net/dccp/proto.c                    |    2 +-
 5 files changed, 35 insertions(+), 35 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -91,12 +91,16 @@ struct tfrc_rx_hist_entry {
  * @loss_count:		Number of entries in circular history
  * @loss_start:		Movable index (for loss detection)
  * @rtt_sample_prev:	Used during RTT sampling, points to candidate entry
+ * @packet_size:	Packet size in bytes (as per RFC 3448, 3.1)
+ * @bytes_recvd:	Number of bytes received since last sending feedback
  */
 struct tfrc_rx_hist {
 	struct tfrc_rx_hist_entry *ring[TFRC_NDUPACK + 1];
 	u8			  loss_count:2,
 				  loss_start:2;
 #define rtt_sample_prev		  loss_start
+	u32			  packet_size,
+				  bytes_recvd;
 };
 
 /**
@@ -140,6 +144,18 @@ static inline bool tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
 	return h->loss_count > 0;
 }
 
+/*
+ * Accessor functions to retrieve parameters sampled by the RX history
+ */
+static inline u32 tfrc_rx_hist_packet_size(const struct tfrc_rx_hist *h)
+{
+	if (h->packet_size = 0) {
+		DCCP_WARN("No sample for s, using fallback\n");
+		return TCP_MIN_RCVMSS;
+	}
+	return h->packet_size;
+}
+
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 				    const struct sk_buff *skb, const u64 ndp);
 
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -352,6 +352,16 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 		__three_after_loss(h);
 	}
 
+	/*
+	 * Update moving-average of `s' and the sum of received payload bytes.
+	 */
+	if (dccp_data_packet(skb)) {
+		const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
+
+		h->packet_size = tfrc_ewma(h->packet_size, payload, 9);
+		h->bytes_recvd += payload;
+	}
+
 	/* RFC 3448, 6.1: update I_0, whose growth implies p <= p_prev */
 	if (!is_new_loss)
 		tfrc_lh_update_i_mean(lh, skb);
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -124,25 +124,21 @@ enum ccid3_hc_rx_states {
  *
  *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @state  -  Receiver state, one of %ccid3_hc_rx_states
- *  @bytes_recv  -  Total sum of DCCP payload bytes
  *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
  *  @rtt  -  Receiver estimate of RTT
  *  @tstamp_last_feedback  -  Time at which last feedback was sent
  *  @hist  -  Packet history (loss detection + RTT sampling)
  *  @li_hist  -  Loss Interval database
- *  @s  -  Received packet size in bytes
  *  @p_inverse  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct ccid3_hc_rx_sock {
 	u8				last_counter:4;
 	enum ccid3_hc_rx_states		state:8;
-	u32				bytes_recv;
 	u32				x_recv;
 	u32				rtt;
 	ktime_t				tstamp_last_feedback;
 	struct tfrc_rx_hist		hist;
 	struct tfrc_loss_hist		li_hist;
-	u16				s;
 #define p_inverse			li_hist.i_mean
 };
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -590,12 +590,9 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 			 * would bring X down to s/t_mbi. That is why we return
 			 * X_recv according to rfc3448bis-06 for the moment.
 			 */
-			u32 rtt = hcrx->rtt ? : DCCP_FALLBACK_RTT, s = hcrx->s;
+			u32 rtt = hcrx->rtt ? : DCCP_FALLBACK_RTT,
+			    s	= tfrc_rx_hist_packet_size(&hcrx->hist);
 
-			if (s = 0) {
-				DCCP_WARN("No sample for s, using fallback\n");
-				s = TCP_MIN_RCVMSS;
-			}
 			hcrx->x_recv = scaled_div32(s, 2 * rtt);
 			break;
 		}
@@ -617,7 +614,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->x_recv = scaled_div32(hcrx->bytes_recv, delta);
+			hcrx->x_recv = scaled_div32(hcrx->hist.bytes_recvd, delta);
 		break;
 	default:
 		return;
@@ -628,7 +625,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 
 	hcrx->tstamp_last_feedback = now;
 	hcrx->last_counter	   = dccp_hdr(skb)->dccph_ccval;
-	hcrx->bytes_recv	   = 0;
+	hcrx->hist.bytes_recvd	   = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -669,7 +666,8 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 static u32 ccid3_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	u32 x_recv, p, delta;
+	u32 x_recv, p, delta,
+	    s = tfrc_rx_hist_packet_size(&hcrx->hist);
 	u64 fval;
 
 	/*
@@ -686,7 +684,7 @@ static u32 ccid3_first_li(struct sock *sk)
 	}
 
 	delta = ktime_to_us(net_timedelta(hcrx->tstamp_last_feedback));
-	x_recv = scaled_div32(hcrx->bytes_recv, delta);
+	x_recv = scaled_div32(hcrx->hist.bytes_recvd, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
 		if (hcrx->x_recv = 0) {
@@ -696,8 +694,7 @@ static u32 ccid3_first_li(struct sock *sk)
 		x_recv = hcrx->x_recv;
 	}
 
-	fval = scaled_div(hcrx->s, hcrx->rtt);
-	fval = scaled_div32(fval, x_recv);
+	fval = scaled_div32(scaled_div(s, hcrx->rtt), x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
 	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
@@ -724,31 +721,12 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
-			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = CCID3_FBACK_INITIAL;
 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-			hcrx->s = payload;
-			/*
-			 * Not necessary to update bytes_recv here,
-			 * since X_recv = 0 for the first feedback packet (cf.
-			 * RFC 3448, 6.3) -- gerrit
-			 */
 		}
 		goto update_records;
 	}
 
-	if (tfrc_rx_hist_duplicate(&hcrx->hist, skb))
-		return; /* done receiving */
-
-	if (is_data_packet) {
-		const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
-		/*
-		 * Update moving-average of s and the sum of received payload bytes
-		 */
-		hcrx->s = tfrc_ewma(hcrx->s, payload, 9);
-		hcrx->bytes_recv += payload;
-	}
-
 	if (tfrc_rx_hist_loss_pending(&hcrx->hist))
 		return; /* done receiving */
 
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -185,7 +185,7 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 	sk->sk_state		= DCCP_CLOSED;
 	sk->sk_write_space	= dccp_write_space;
 	icsk->icsk_sync_mss	= dccp_sync_mss;
-	dp->dccps_mss_cache	= 536;
+	dp->dccps_mss_cache	= TCP_MIN_RCVMSS;
 	dp->dccps_rate_last	= jiffies;
 	dp->dccps_role		= DCCP_ROLE_UNDEFINED;
 	dp->dccps_service	= DCCP_SERVICE_CODE_IS_ABSENT;
