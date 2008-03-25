From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 16:20:07 +0000
Subject: [PATCH 3/7] [RFC] [CCID-3]: Get rid of ccid3hc{tx,rx}_ prefixes
Message-Id: <1206462011-24907-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo can you please check if you are ok with this - it is a follow-up
to the earlier patch, for consistency.

--------------------------> Patch <-----------------------------------------
This continues work done in an earlier patch for CCID-2, where there was
agreement on dccp@vger that the `hctx->ccid3hctx_' prefixes were too long.

Thus this patch does the same for CCID-3 as the previous patch for CCID-2:

	s#ccid3hctx_##g;
	s#ccid3hcrx_##g;

plus manual editing to retain consistency (updated comments, moved assignment
within an `if' expression into standalone expression).

As in the previous patch, the code becomes much clearer to read, and many 
multi-line expressions are reduced in size.

Note: expanded the fields of the `struct tfrc_tx_info' in the hc_tx_sock, since
      using short #define identifiers is not a good idea. The only place where
      this embedded struct was used is ccid3_hc_tx_getsockopt().
      (It may be that removing the embedded struct allows to reduce the size of
      the socket, by re-arranging fields; I haven't checked this.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |  335 +++++++++++++++++++++++--------------------------
 net/dccp/ccids/ccid3.h |  119 ++++++++---------
 net/dccp/probe.c       |    8 -
 3 files changed, 221 insertions(+), 241 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -77,44 +77,43 @@ enum ccid3_hc_tx_states {
 
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
- * @ccid3hctx_x - Current sending rate in 64 * bytes per second
- * @ccid3hctx_x_recv - Receive rate    in 64 * bytes per second
- * @ccid3hctx_x_calc - Calculated rate in bytes per second
- * @ccid3hctx_rtt - Estimate of current round trip time in usecs
- * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
- * @ccid3hctx_s - Packet size in bytes
- * @ccid3hctx_t_rto - Nofeedback Timer setting in usecs
- * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
- * @ccid3hctx_last_win_count - Last window counter sent
- * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
- *				 with last_win_count value sent
- * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
- * @ccid3hctx_t_ld - Time last doubled during slow start
- * @ccid3hctx_t_nom - Nominal send time of next packet
- * @ccid3hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
- * @ccid3hctx_hist - Packet history
- * @ccid3hctx_options_received - Parsed set of retrieved options
+ * @x - Current sending rate in 64 * bytes per second
+ * @x_recv - Receive rate    in 64 * bytes per second
+ * @x_calc - Calculated rate in bytes per second
+ * @rtt - Estimate of current round trip time in usecs
+ * @p - Current loss event rate (0-1) scaled by 1000000
+ * @s - Packet size in bytes
+ * @t_rto - Nofeedback Timer setting in usecs
+ * @t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
+ * @state - Sender state, one of %ccid3_hc_tx_states
+ * @last_win_count - Last window counter sent
+ * @t_last_win_count - Timestamp of earliest packet with
+ *                     last_win_count value sent
+ * @no_feedback_timer - Handle to no feedback timer
+ * @t_ld - Time last doubled during slow start
+ * @t_nom - Nominal send time of next packet
+ * @delta - Send timer delta (RFC 3448, 4.6) in usecs
+ * @hist - Packet history
+ * @options_received - Parsed set of retrieved options
  */
 struct ccid3_hc_tx_sock {
-	struct tfrc_tx_info		ccid3hctx_tfrc;
-#define ccid3hctx_x			ccid3hctx_tfrc.tfrctx_x
-#define ccid3hctx_x_recv		ccid3hctx_tfrc.tfrctx_x_recv
-#define ccid3hctx_x_calc		ccid3hctx_tfrc.tfrctx_x_calc
-#define ccid3hctx_rtt			ccid3hctx_tfrc.tfrctx_rtt
-#define ccid3hctx_p			ccid3hctx_tfrc.tfrctx_p
-#define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
-#define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
-	u16				ccid3hctx_s;
-	enum ccid3_hc_tx_states		ccid3hctx_state:8;
-	u8				ccid3hctx_last_win_count;
-	ktime_t				ccid3hctx_t_last_win_count;
-	struct timer_list		ccid3hctx_no_feedback_timer;
-	ktime_t				ccid3hctx_t_ld;
-	ktime_t				ccid3hctx_t_nom;
-	u32				ccid3hctx_delta;
-	struct tfrc_tx_hist_entry	*ccid3hctx_hist;
-	struct ccid3_options_received	ccid3hctx_options_received;
+	u64				x;
+	u64				x_recv;
+	u32				x_calc;
+	u32				rtt;
+	u32				p;
+	u32				t_rto;
+	u32				t_ipi;
+	u16				s;
+	enum ccid3_hc_tx_states		state:8;
+	u8				last_win_count;
+	ktime_t				t_last_win_count;
+	struct timer_list		no_feedback_timer;
+	ktime_t				t_ld;
+	ktime_t				t_nom;
+	u32				delta;
+	struct tfrc_tx_hist_entry	*hist;
+	struct ccid3_options_received	options_received;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
@@ -133,32 +132,32 @@ enum ccid3_hc_rx_states {
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- *  @ccid3hcrx_p  -  Current loss event rate (RFC 3448 5.4)
- *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
- *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of RTT
- *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history (loss detection + RTT sampling)
- *  @ccid3hcrx_li_hist  -  Loss Interval database
- *  @ccid3hcrx_s  -  Received packet size in bytes
- *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ *  @x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
+ *  @rtt  -  Receiver estimate of rtt (non-standard)
+ *  @p  -  Current loss event rate (RFC 3448 5.4)
+ *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @state  -  Receiver state, one of %ccid3_hc_rx_states
+ *  @bytes_recv  -  Total sum of DCCP payload bytes
+ *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ *  @rtt  -  Receiver estimate of RTT
+ *  @tstamp_last_feedback  -  Time at which last feedback was sent
+ *  @tstamp_last_ack  -  Time at which last feedback was sent
+ *  @hist  -  Packet history (loss detection + RTT sampling)
+ *  @li_hist  -  Loss Interval database
+ *  @s  -  Received packet size in bytes
+ *  @p_inverse  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct ccid3_hc_rx_sock {
-	u8				ccid3hcrx_last_counter:4;
-	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
-	u32				ccid3hcrx_bytes_recv;
-	u32				ccid3hcrx_x_recv;
-	u32				ccid3hcrx_rtt;
-	ktime_t				ccid3hcrx_tstamp_last_feedback;
-	struct tfrc_rx_hist		ccid3hcrx_hist;
-	struct tfrc_loss_hist		ccid3hcrx_li_hist;
-	u16				ccid3hcrx_s;
-#define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
+	u8				last_counter:4;
+	enum ccid3_hc_rx_states		state:8;
+	u32				bytes_recv;
+	u32				x_recv;
+	u32				rtt;
+	ktime_t				tstamp_last_feedback;
+	struct tfrc_rx_hist		hist;
+	struct tfrc_loss_hist		li_hist;
+	u16				s;
+#define p_inverse			li_hist.i_mean
 };
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -67,13 +67,13 @@ static void ccid3_hc_tx_set_state(struct
 				  enum ccid3_hc_tx_states state)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	enum ccid3_hc_tx_states oldstate = hctx->ccid3hctx_state;
+	enum ccid3_hc_tx_states oldstate = hctx->state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
 		       ccid3_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->ccid3hctx_state = state;
+	hctx->state = state;
 }
 
 /*
@@ -88,10 +88,10 @@ static void ccid3_hc_tx_set_state(struct
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
-				   max_t(__u32, 2 * hctx->ccid3hctx_s, 4380));
+	const u32 w_init = min_t(u32, 4 * hctx->s,
+				 max_t(u32, 2 * hctx->s, 4380U));
 
-	return scaled_div(w_init << 6, hctx->ccid3hctx_rtt);
+	return scaled_div(w_init << 6, hctx->rtt);
 }
 
 /*
@@ -100,24 +100,21 @@ static inline u64 rfc3390_initial_rate(s
 static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid3hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s) << 6,
-					     hctx->ccid3hctx_x);
+	hctx->t_ipi = scaled_div32(((u64)hctx->s) << 6, hctx->x);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
-					   TFRC_OPSYS_HALF_TIME_GRAN);
+	hctx->delta = min_t(u32, hctx->t_ipi / 2, TFRC_OPSYS_HALF_TIME_GRAN);
 
-	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
-		       hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
-		       hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
+	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n", hctx->t_ipi,
+		       hctx->delta, hctx->s, (unsigned)(hctx->x >> 6));
 
 }
 
 static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
+	u32 delta = ktime_us_delta(now, hctx->t_last_win_count);
 
-	return delta / hctx->ccid3hctx_rtt;
+	return delta / hctx->rtt;
 }
 
 /**
@@ -133,8 +130,8 @@ static u32 ccid3_hc_tx_idle_rtt(struct c
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
-	const  __u64 old_x = hctx->ccid3hctx_x;
+	u64 min_rate = 2 * hctx->x_recv;
+	const u64 old_x = hctx->x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -145,33 +142,26 @@ static void ccid3_hc_tx_update_x(struct 
 	 */
 	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
+		min_rate = max(min_rate, 2 * hctx->x_recv);
 	}
 
-	if (hctx->ccid3hctx_p > 0) {
+	if (hctx->p > 0) {
 
-		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
-					min_rate);
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
-					(((__u64)hctx->ccid3hctx_s) << 6) /
-								TFRC_T_MBI);
+		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
+		hctx->x = max(hctx->x, (((u64)hctx->s) << 6) / TFRC_T_MBI);
 
-	} else if (ktime_us_delta(now, hctx->ccid3hctx_t_ld)
-				- (s64)hctx->ccid3hctx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
 
-		hctx->ccid3hctx_x -			max(min(2 * hctx->ccid3hctx_x, min_rate),
-			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-				       hctx->ccid3hctx_rtt));
-		hctx->ccid3hctx_t_ld = now;
+		hctx->x = max(min(2 * hctx->x, min_rate),
+			      scaled_div(((u64)hctx->s) << 6, hctx->rtt));
+		hctx->t_ld = now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x) {
+	if (hctx->x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->ccid3hctx_x >> 6),
-			       hctx->ccid3hctx_x_calc,
-			       (unsigned)(hctx->ccid3hctx_x_recv >> 6));
+			       (unsigned)(hctx->x >> 6), hctx->x_calc,
+			       (unsigned)(hctx->x_recv >> 6));
 
 		ccid3_update_send_interval(hctx);
 	}
@@ -183,11 +173,11 @@ static void ccid3_hc_tx_update_x(struct 
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-	const u16 old_s = hctx->ccid3hctx_s;
+	const u16 old_s = hctx->s;
 
-	hctx->ccid3hctx_s = tfrc_ewma(hctx->ccid3hctx_s, len, 9);
+	hctx->s = tfrc_ewma(hctx->s, len, 9);
 
-	if (hctx->ccid3hctx_s != old_s)
+	if (hctx->s != old_s)
 		ccid3_update_send_interval(hctx);
 }
 
@@ -198,13 +188,13 @@ static inline void ccid3_hc_tx_update_s(
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
 						ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count),
-	    quarter_rtts = (4 * delta) / hctx->ccid3hctx_rtt;
+	u32 delta = ktime_us_delta(now, hctx->t_last_win_count),
+	    quarter_rtts = (4 * delta) / hctx->rtt;
 
 	if (quarter_rtts > 0) {
-		hctx->ccid3hctx_t_last_win_count = now;
-		hctx->ccid3hctx_last_win_count	+= min(quarter_rtts, 5U);
-		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
+		hctx->t_last_win_count = now;
+		hctx->last_win_count  += min(quarter_rtts, 5U);
+		hctx->last_win_count  &= 0xF;		/* mod 16 */
 	}
 }
 
@@ -222,23 +212,21 @@ static void ccid3_hc_tx_no_feedback_time
 	}
 
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid3_tx_state_name(hctx->ccid3hctx_state));
+		       ccid3_tx_state_name(hctx->state));
 
-	if (hctx->ccid3hctx_state = TFRC_SSTATE_FBACK)
+	if (hctx->state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+	else if (hctx->state != TFRC_SSTATE_NO_FBACK)
 		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
+	 * RTO is 0 if and only if no feedback has been received yet.
 	 */
-	if (hctx->ccid3hctx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->ccid3hctx_p = 0) {
+	if (hctx->t_rto = 0 || hctx->p = 0) {
 
 		/* halve send rate directly */
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x / 2,
-					(((__u64)hctx->ccid3hctx_s) << 6) /
-								    TFRC_T_MBI);
+		hctx->x = max(hctx->x / 2, (((u64)hctx->s) << 6) / TFRC_T_MBI);
 		ccid3_update_send_interval(hctx);
 	} else {
 		/*
@@ -251,33 +239,31 @@ static void ccid3_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
+		BUG_ON(hctx->p && !hctx->x_calc);
 
-		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
-			hctx->ccid3hctx_x_recv -				max(hctx->ccid3hctx_x_recv / 2,
-				    (((__u64)hctx->ccid3hctx_s) << 6) /
-							      (2 * TFRC_T_MBI));
+		if (hctx->x_calc > (hctx->x_recv >> 5))
+			hctx->x_recv = max((((u64)hctx->s) << 6) / TFRC_T_MBI,
+					   hctx->x_recv) / 2;
 		else {
-			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
-			hctx->ccid3hctx_x_recv <<= 4;
+			hctx->x_recv = hctx->x_calc;
+			hctx->x_recv <<= 4;
 		}
 		ccid3_hc_tx_update_x(sk, NULL);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->ccid3hctx_x);
+			(unsigned long long)hctx->x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->ccid3hctx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hctx->t_rto = 0))		/* no feedback received yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->t_rto, 2 * hctx->t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -305,18 +291,17 @@ static int ccid3_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->ccid3hctx_state) {
+	switch (hctx->state) {
 	case TFRC_SSTATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-			       (jiffies +
+		sk_reset_timer(sk, &hctx->no_feedback_timer, (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->ccid3hctx_last_win_count	 = 0;
-		hctx->ccid3hctx_t_last_win_count = now;
+		hctx->last_win_count   = 0;
+		hctx->t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->ccid3hctx_t_nom = now;
+		hctx->t_nom = now;
 
-		hctx->ccid3hctx_s = skb->len;
+		hctx->s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -325,13 +310,13 @@ static int ccid3_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->rtt  = dp->dccps_syn_rtt;
+			hctx->x    = rfc3390_initial_rate(sk);
+			hctx->t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
-			hctx->ccid3hctx_x = hctx->ccid3hctx_s;
-			hctx->ccid3hctx_x <<= 6;
+			hctx->x = hctx->s;
+			hctx->x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
 
@@ -339,7 +324,7 @@ static int ccid3_hc_tx_send_packet(struc
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = ktime_us_delta(hctx->ccid3hctx_t_nom, now);
+		delay = ktime_us_delta(hctx->t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		if (delay > CCID_PACKET_DELAY_MAX_USEC)
 			delay = CCID_PACKET_DELAY_MAX_USEC;
@@ -351,7 +336,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
+		if (delay - (s64)hctx->delta >= 1000)
 			return (u32)delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
@@ -363,11 +348,10 @@ static int ccid3_hc_tx_send_packet(struc
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval  = hctx->last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->ccid3hctx_t_nom = ktime_add_us(hctx->ccid3hctx_t_nom,
-					     hctx->ccid3hctx_t_ipi);
+	hctx->t_nom = ktime_add_us(hctx->t_nom, hctx->t_ipi);
 	return CCID_PACKET_SEND_AT_ONCE;
 }
 
@@ -377,7 +361,7 @@ static void ccid3_hc_tx_packet_sent(stru
 
 	ccid3_hc_tx_update_s(hctx, len);
 
-	if (tfrc_tx_hist_add(&hctx->ccid3hctx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hctx->hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
@@ -391,21 +375,20 @@ static void ccid3_hc_tx_packet_recv(stru
 	u32 pinv, r_sample;
 
 	/* Ignore if nothing has been sent; feedback is on Ack/DataAck only */
-	if (tfrc_tx_hist_is_empty(hctx->ccid3hctx_hist) ||
+	if (tfrc_tx_hist_is_empty(hctx->hist) ||
 	    !(dcb->dccpd_type = DCCP_PKT_ACK ||
 	      dcb->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->ccid3hctx_state != TFRC_SSTATE_FBACK &&
-	    hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+	if (hctx->state != TFRC_SSTATE_FBACK &&
+	    hctx->state != TFRC_SSTATE_NO_FBACK)
 		return;
 
-	opt_recv = &hctx->ccid3hctx_options_received;
+	opt_recv = &hctx->options_received;
 	now = ktime_get_real();
 
 	/* Estimate RTT from history if ACK number is valid */
-	r_sample = tfrc_tx_hist_rtt(hctx->ccid3hctx_hist,
-				    dcb->dccpd_ack_seq, now);
+	r_sample = tfrc_tx_hist_rtt(hctx->hist, dcb->dccpd_ack_seq, now);
 	if (r_sample = 0) {
 		DCCP_WARN("%s(%p): %s with bogus ACK #%llu\n",
 			  dccp_role(sk), sk, dccp_packet_name(dcb->dccpd_type),
@@ -414,37 +397,37 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
-	hctx->ccid3hctx_x_recv <<= 6;
+	hctx->x_recv = opt_recv->ccid3or_receive_rate;
+	hctx->x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->ccid3or_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->ccid3hctx_p = 0;
+		hctx->p = 0;
 	else				       /* can not exceed 100% */
-		hctx->ccid3hctx_p = scaled_div(1, pinv);
+		hctx->p = scaled_div(1, pinv);
 	/*
 	 * Validate new RTT sample and update moving average
 	 */
 	r_sample = dccp_sample_rtt(sk, r_sample);
-	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
+	hctx->rtt = tfrc_ewma(hctx->rtt, r_sample, 9);
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
+	if (hctx->state = TFRC_SSTATE_NO_FBACK) {
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		if (hctx->ccid3hctx_t_rto = 0) {
+		if (hctx->t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->x    = rfc3390_initial_rate(sk);
+			hctx->t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
 			goto done_computing_x;
-		} else if (hctx->ccid3hctx_p = 0) {
+		} else if (hctx->p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -453,25 +436,20 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->ccid3hctx_p > 0)
-		hctx->ccid3hctx_x_calc -				tfrc_calc_x(hctx->ccid3hctx_s,
-					    hctx->ccid3hctx_rtt,
-					    hctx->ccid3hctx_p);
+	if (hctx->p > 0)
+		hctx->x_calc = tfrc_calc_x(hctx->s, hctx->rtt, hctx->p);
 	ccid3_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-			       dccp_role(sk),
-			       sk, hctx->ccid3hctx_rtt, r_sample,
-			       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
-			       hctx->ccid3hctx_x_calc,
-			       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-			       (unsigned)(hctx->ccid3hctx_x >> 6));
+			       dccp_role(sk), sk, hctx->rtt, r_sample,
+			       hctx->s, hctx->p, hctx->x_calc,
+			       (unsigned)(hctx->x_recv >> 6),
+			       (unsigned)(hctx->x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -485,21 +463,19 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-					   (CONFIG_IP_DCCP_CCID3_RTO *
-					    (USEC_PER_SEC / 1000)));
+	hctx->t_rto = max_t(u32, 4 * hctx->rtt, (CONFIG_IP_DCCP_CCID3_RTO *
+						 (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+	t_nfb = max(hctx->t_rto, 2 * hctx->t_ipi);
 
 	ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
-		       dccp_role(sk),
-		       sk, usecs_to_jiffies(t_nfb), t_nfb);
+		       dccp_role(sk), sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
@@ -513,7 +489,7 @@ static int ccid3_hc_tx_parse_options(str
 	struct ccid3_options_received *opt_recv;
 	__be32 opt_val;
 
-	opt_recv = &hctx->ccid3hctx_options_received;
+	opt_recv = &hctx->options_received;
 
 	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
 		opt_recv->ccid3or_seqno		     = dp->dccps_gsr;
@@ -569,9 +545,9 @@ static int ccid3_hc_tx_init(struct ccid 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
-	hctx->ccid3hctx_hist = NULL;
-	setup_timer(&hctx->ccid3hctx_no_feedback_timer,
+	hctx->state = TFRC_SSTATE_NO_SENT;
+	hctx->hist = NULL;
+	setup_timer(&hctx->no_feedback_timer,
 			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
 
 	return 0;
@@ -582,29 +558,37 @@ static void ccid3_hc_tx_exit(struct sock
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
-	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->no_feedback_timer);
 
-	tfrc_tx_hist_purge(&hctx->ccid3hctx_hist);
+	tfrc_tx_hist_purge(&hctx->hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = ccid3_hc_tx_sk(sk)->ccid3hctx_t_rto;
-	info->tcpi_rtt = ccid3_hc_tx_sk(sk)->ccid3hctx_rtt;
+	info->tcpi_rto = ccid3_hc_tx_sk(sk)->t_rto;
+	info->tcpi_rtt = ccid3_hc_tx_sk(sk)->rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_tx_info tfrc;
 	const void *val;
 
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->ccid3hctx_tfrc))
+		if (len < sizeof(tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->ccid3hctx_tfrc);
-		val = &hctx->ccid3hctx_tfrc;
+		tfrc.tfrctx_x	   = hctx->x;
+		tfrc.tfrctx_x_recv = hctx->x_recv;
+		tfrc.tfrctx_x_calc = hctx->x_calc;
+		tfrc.tfrctx_rtt	   = hctx->rtt;
+		tfrc.tfrctx_p	   = hctx->p;
+		tfrc.tfrctx_rto	   = hctx->t_rto;
+		tfrc.tfrctx_ipi	   = hctx->t_ipi;
+		len = sizeof(tfrc);
+		val = &tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -645,13 +629,13 @@ static void ccid3_hc_rx_set_state(struct
 				  enum ccid3_hc_rx_states state)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum ccid3_hc_rx_states oldstate = hcrx->ccid3hcrx_state;
+	enum ccid3_hc_rx_states oldstate = hcrx->state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
 		       ccid3_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->ccid3hcrx_state = state;
+	hcrx->state = state;
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk,
@@ -663,15 +647,15 @@ static void ccid3_hc_rx_send_feedback(st
 	ktime_t now;
 	s64 delta = 0;
 
-	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hcrx->state = TFRC_RSTATE_TERM))
 		return;
 
 	now = ktime_get_real();
 
 	switch (fbtype) {
 	case CCID3_FBACK_INITIAL:
-		hcrx->ccid3hcrx_x_recv = 0;
-		hcrx->ccid3hcrx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
+		hcrx->x_recv = 0;
+		hcrx->p_inverse = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case CCID3_FBACK_PARAM_CHANGE:
 		/*
@@ -684,27 +668,26 @@ static void ccid3_hc_rx_send_feedback(st
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->ccid3hcrx_x_recv > 0)
+		if (hcrx->x_recv > 0)
 			break;
 		/* fall through */
 	case CCID3_FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->ccid3hcrx_tstamp_last_feedback);
+		delta = ktime_us_delta(now, hcrx->tstamp_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->ccid3hcrx_x_recv -				scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+			hcrx->x_recv = scaled_div32(hcrx->bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 
-	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
+	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n",
+		       (long)delta, hcrx->x_recv, hcrx->p_inverse);
 
-	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_last_counter	     = dccp_hdr(skb)->dccph_ccval;
-	hcrx->ccid3hcrx_bytes_recv	     = 0;
+	hcrx->tstamp_last_feedback = now;
+	hcrx->last_counter	   = dccp_hdr(skb)->dccph_ccval;
+	hcrx->bytes_recv	   = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -721,8 +704,8 @@ static int ccid3_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
-	pinv   = htonl(hcrx->ccid3hcrx_pinv);
+	x_recv = htonl(hcrx->x_recv);
+	pinv   = htonl(hcrx->p_inverse);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -748,22 +731,23 @@ static u32 ccid3_first_li(struct sock *s
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->ccid3hcrx_rtt = 0) {
+	if (hcrx->rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
+		hcrx->rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta = ktime_to_us(net_timedelta(hcrx->ccid3hcrx_tstamp_last_feedback));
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	delta = ktime_to_us(net_timedelta(hcrx->tstamp_last_feedback));
+	x_recv = scaled_div32(hcrx->bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+		if (hcrx->x_recv = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
+		x_recv = hcrx->x_recv;
 	}
 
-	fval = scaled_div(hcrx->ccid3hcrx_s, hcrx->ccid3hcrx_rtt);
+	fval = scaled_div(hcrx->s, hcrx->rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -780,14 +764,14 @@ static void ccid3_hc_rx_packet_recv(stru
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hcrx->state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = CCID3_FBACK_INITIAL;
 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-			hcrx->ccid3hcrx_s = payload;
+			hcrx->s = payload;
 			/*
-			 * Not necessary to update ccid3hcrx_bytes_recv here,
+			 * Not necessary to update bytes_recv here,
 			 * since X_recv = 0 for the first feedback packet (cf.
 			 * RFC 3448, 6.3) -- gerrit
 			 */
@@ -795,7 +779,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		goto update_records;
 	}
 
-	if (tfrc_rx_hist_duplicate(&hcrx->ccid3hcrx_hist, skb))
+	if (tfrc_rx_hist_duplicate(&hcrx->hist, skb))
 		return; /* done receiving */
 
 	if (is_data_packet) {
@@ -803,22 +787,21 @@ static void ccid3_hc_rx_packet_recv(stru
 		/*
 		 * Update moving-average of s and the sum of received payload bytes
 		 */
-		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, payload, 9);
-		hcrx->ccid3hcrx_bytes_recv += payload;
+		hcrx->s = tfrc_ewma(hcrx->s, payload, 9);
+		hcrx->bytes_recv += payload;
 	}
 
 	/*
 	 * Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_hist_loss_pending(&hcrx->ccid3hcrx_hist) &&
-	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
-				&hcrx->ccid3hcrx_li_hist,
-				skb, ndp, ccid3_first_li, sk) ) {
+	if (tfrc_rx_hist_loss_pending(&hcrx->hist) &&
+	    tfrc_rx_handle_loss(&hcrx->hist, &hcrx->li_hist,
+				skb, ndp, ccid3_first_li, sk)) {
 		do_feedback = CCID3_FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_hist_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
+	if (tfrc_rx_hist_new_loss_indicated(&hcrx->hist, skb, ndp))
 		goto update_records;
 
 	/*
@@ -827,17 +810,17 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (!tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
-		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+	if (!tfrc_lh_is_initialised(&hcrx->li_hist)) {
+		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->hist, skb);
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
 		if (sample != 0)
-			hcrx->ccid3hcrx_rtt = tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
+			hcrx->rtt = tfrc_ewma(hcrx->rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb)) {
+	} else if (tfrc_lh_update_i_mean(&hcrx->li_hist, skb)) {
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -848,11 +831,11 @@ static void ccid3_hc_rx_packet_recv(stru
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
 		do_feedback = CCID3_FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist, skb, ndp);
+	tfrc_rx_hist_add_packet(&hcrx->hist, skb, ndp);
 
 done_receiving:
 	if (do_feedback)
@@ -863,9 +846,9 @@ static int ccid3_hc_rx_init(struct ccid 
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
-	return tfrc_rx_hist_alloc(&hcrx->ccid3hcrx_hist);
+	hcrx->state = TFRC_RSTATE_NO_DATA;
+	tfrc_lh_init(&hcrx->li_hist);
+	return tfrc_rx_hist_alloc(&hcrx->hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
@@ -874,15 +857,15 @@ static void ccid3_hc_rx_exit(struct sock
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	tfrc_rx_hist_purge(&hcrx->ccid3hcrx_hist);
-	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
+	tfrc_rx_hist_purge(&hcrx->hist);
+	tfrc_lh_cleanup(&hcrx->li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->ccid3hcrx_state;
+	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->ccid3hcrx_rtt;
+	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
@@ -896,10 +879,10 @@ static int ccid3_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->ccid3hcrx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->ccid3hcrx_rtt;
-		rx_info.tfrcrx_p      = hcrx->ccid3hcrx_pinv = 0 ? ~0U :
-					   scaled_div(1, hcrx->ccid3hcrx_pinv);
+		rx_info.tfrcrx_x_recv = hcrx->x_recv;
+		rx_info.tfrcrx_rtt    = hcrx->rtt;
+		rx_info.tfrcrx_p      = hcrx->p_inverse = 0 ? ~0U :
+					   scaled_div(1, hcrx->p_inverse);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -71,11 +71,9 @@ static void jdccp_write_xmit(struct sock
 
 		if (hctx)
 			len += sprintf(tbuf + len, " %d %d %d %u %u %u %d",
-			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
-			       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-			       (unsigned)(hctx->ccid3hctx_x >> 6),
-			       hctx->ccid3hctx_t_ipi);
+			       hctx->s, hctx->rtt, hctx->p, hctx->x_calc,
+			       (unsigned)(hctx->x_recv >> 6),
+			       (unsigned)(hctx->x >> 6), hctx->t_ipi);
 
 		len += sprintf(tbuf + len, "\n");
 		kfifo_put(dccpw.fifo, tbuf, len);
