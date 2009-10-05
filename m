From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Oct 2009 10:53:11 +0000
Subject: [PATCH 2/4][RFC] dccp ccid-3: Overhaul CCID naming convention 2/2
Message-Id: <1254739993-5051-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements the new naming scheme also for CCID-3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |  120 +++++++++---------
 net/dccp/ccids/ccid3.c |  321 ++++++++++++++++++++++--------------------------
 net/dccp/probe.c       |   10 +-
 3 files changed, 213 insertions(+), 238 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -75,44 +75,44 @@ enum ccid3_hc_tx_states {
 
 /**
  * struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
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
+ * @tx_x:		  Current sending rate in 64 * bytes per second
+ * @tx_x_recv:		  Receive rate in 64 * bytes per second
+ * @tx_x_calc:		  Calculated rate in bytes per second
+ * @tx_rtt:		  Estimate of current round trip time in usecs
+ * @tx_p:		  Current loss event rate (0-1) scaled by 1000000
+ * @tx_s:		  Packet size in bytes
+ * @tx_t_rto:		  Nofeedback Timer setting in usecs
+ * @tx_t_ipi:		  Interpacket (send) interval (RFC 3448, 4.6) in usecs
+ * @tx_state:		  Sender state, one of %ccid3_hc_tx_states
+ * @tx_last_win_count:	  Last window counter sent
+ * @tx_t_last_win_count:  Timestamp of earliest packet
+ *			  with last_win_count value sent
+ * @tx_no_feedback_timer: Handle to no feedback timer
+ * @tx_t_ld:		  Time last doubled during slow start
+ * @tx_t_nom:		  Nominal send time of next packet
+ * @tx_delta:		  Send timer delta (RFC 3448, 4.6) in usecs
+ * @tx_hist:		  Packet history
+ * @tx_options_received:  Parsed set of retrieved options
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
+	struct tfrc_tx_info		tx_tfrc;
+#define tx_x				tx_tfrc.tfrctx_x
+#define tx_x_recv			tx_tfrc.tfrctx_x_recv
+#define tx_x_calc			tx_tfrc.tfrctx_x_calc
+#define tx_rtt				tx_tfrc.tfrctx_rtt
+#define tx_p				tx_tfrc.tfrctx_p
+#define tx_t_rto			tx_tfrc.tfrctx_rto
+#define tx_t_ipi			tx_tfrc.tfrctx_ipi
+	u16				tx_s;
+	enum ccid3_hc_tx_states		tx_state:8;
+	u8				tx_last_win_count;
+	ktime_t				tx_t_last_win_count;
+	struct timer_list		tx_no_feedback_timer;
+	ktime_t				tx_t_ld;
+	ktime_t				tx_t_nom;
+	u32				tx_delta;
+	struct tfrc_tx_hist_entry	*tx_hist;
+	struct ccid3_options_received	tx_options_received;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
@@ -131,32 +131,32 @@ enum ccid3_hc_rx_states {
 
 /**
  * struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
- * @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- * @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- * @ccid3hcrx_p  -  Current loss event rate (RFC 3448 5.4)
- * @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- * @ccid3hcrx_state  -  Receiver state, one of %ccid3_hc_rx_states
- * @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- * @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- * @ccid3hcrx_rtt  -  Receiver estimate of RTT
- * @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- * @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
- * @ccid3hcrx_hist  -  Packet history (loss detection + RTT sampling)
- * @ccid3hcrx_li_hist  -  Loss Interval database
- * @ccid3hcrx_s  -  Received packet size in bytes
- * @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448 4.3)
+ * @rx_rtt:		     Receiver estimate of rtt (non-standard)
+ * @rx_p:		     Current loss event rate (RFC 3448 5.4)
+ * @rx_last_counter:	     Tracks window counter (RFC 4342, 8.1)
+ * @rx_state:		     Receiver state, one of %ccid3_hc_rx_states
+ * @rx_bytes_recv:	     Total sum of DCCP payload bytes
+ * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ * @rx_rtt:		     Receiver estimate of RTT
+ * @rx_tstamp_last_feedback: Time at which last feedback was sent
+ * @rx_tstamp_last_ack:	     Time at which last feedback was sent
+ * @rx_hist:		     Packet history (loss detection + RTT sampling)
+ * @rx_li_hist:		     Loss Interval database
+ * @rx_s:		     Received packet size in bytes
+ * @rx_pinv:		     Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
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
+	u8				rx_last_counter:4;
+	enum ccid3_hc_rx_states		rx_state:8;
+	u32				rx_bytes_recv;
+	u32				rx_x_recv;
+	u32				rx_rtt;
+	ktime_t				rx_tstamp_last_feedback;
+	struct tfrc_rx_hist		rx_hist;
+	struct tfrc_loss_hist		rx_li_hist;
+	u16				rx_s;
+#define rx_pinv				rx_li_hist.i_mean
 };
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -65,13 +65,13 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
 				  enum ccid3_hc_tx_states state)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	enum ccid3_hc_tx_states oldstate = hctx->ccid3hctx_state;
+	enum ccid3_hc_tx_states oldstate = hctx->tx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
 		       ccid3_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->ccid3hctx_state = state;
+	hctx->tx_state = state;
 }
 
 /*
@@ -86,10 +86,9 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 w_init = clamp_t(__u32, 4380U,
-			2 * hctx->ccid3hctx_s, 4 * hctx->ccid3hctx_s);
+	const __u32 w_init = clamp_t(__u32, 4380U, 2 * hctx->tx_s, 4 * hctx->tx_s);
 
-	return scaled_div(w_init << 6, hctx->ccid3hctx_rtt);
+	return scaled_div(w_init << 6, hctx->tx_rtt);
 }
 
 /*
@@ -98,24 +97,20 @@ static inline u64 rfc3390_initial_rate(struct sock *sk)
 static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid3hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s) << 6,
-					     hctx->ccid3hctx_x);
+	hctx->tx_t_ipi = scaled_div32(((u64)hctx->tx_s) << 6, hctx->tx_x);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
-					   TFRC_OPSYS_HALF_TIME_GRAN);
-
-	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
-		       hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
-		       hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
+	hctx->tx_delta = min_t(u32, hctx->tx_t_ipi / 2, TFRC_OPSYS_HALF_TIME_GRAN);
 
+	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n", hctx->tx_t_ipi,
+		       hctx->tx_delta, hctx->tx_s, (unsigned)(hctx->tx_x >> 6));
 }
 
 static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
+	u32 delta = ktime_us_delta(now, hctx->tx_t_last_win_count);
 
-	return delta / hctx->ccid3hctx_rtt;
+	return delta / hctx->tx_rtt;
 }
 
 /**
@@ -131,8 +126,8 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
-	const  __u64 old_x = hctx->ccid3hctx_x;
+	__u64 min_rate = 2 * hctx->tx_x_recv;
+	const __u64 old_x = hctx->tx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -143,33 +138,27 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 	 */
 	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
+		min_rate = max(min_rate, 2 * hctx->tx_x_recv);
 	}
 
-	if (hctx->ccid3hctx_p > 0) {
+	if (hctx->tx_p > 0) {
 
-		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
-					min_rate);
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
-					(((__u64)hctx->ccid3hctx_s) << 6) /
-								TFRC_T_MBI);
+		hctx->tx_x = min(((__u64)hctx->tx_x_calc) << 6, min_rate);
+		hctx->tx_x = max(hctx->tx_x, (((__u64)hctx->tx_s) << 6) / TFRC_T_MBI);
 
-	} else if (ktime_us_delta(now, hctx->ccid3hctx_t_ld)
-				- (s64)hctx->ccid3hctx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hctx->tx_t_ld) - (s64)hctx->tx_rtt >= 0) {
 
-		hctx->ccid3hctx_x = min(2 * hctx->ccid3hctx_x, min_rate);
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
-			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-				       hctx->ccid3hctx_rtt));
-		hctx->ccid3hctx_t_ld = now;
+		hctx->tx_x = min(2 * hctx->tx_x, min_rate);
+		hctx->tx_x = max(hctx->tx_x, scaled_div(((__u64)hctx->tx_s) << 6,
+							hctx->tx_rtt));
+		hctx->tx_t_ld = now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x) {
+	if (hctx->tx_x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->ccid3hctx_x >> 6),
-			       hctx->ccid3hctx_x_calc,
-			       (unsigned)(hctx->ccid3hctx_x_recv >> 6));
+			       (unsigned)(hctx->tx_x >> 6), hctx->tx_x_calc,
+			       (unsigned)(hctx->tx_x_recv >> 6));
 
 		ccid3_update_send_interval(hctx);
 	}
@@ -181,11 +170,11 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-	const u16 old_s = hctx->ccid3hctx_s;
+	const u16 old_s = hctx->tx_s;
 
-	hctx->ccid3hctx_s = tfrc_ewma(hctx->ccid3hctx_s, len, 9);
+	hctx->tx_s = tfrc_ewma(hctx->tx_s, len, 9);
 
-	if (hctx->ccid3hctx_s != old_s)
+	if (hctx->tx_s != old_s)
 		ccid3_update_send_interval(hctx);
 }
 
@@ -196,13 +185,13 @@ static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
 						ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count),
-	    quarter_rtts = (4 * delta) / hctx->ccid3hctx_rtt;
+	u32 delta = ktime_us_delta(now, hctx->tx_t_last_win_count),
+	    quarter_rtts = (4 * delta) / hctx->tx_rtt;
 
 	if (quarter_rtts > 0) {
-		hctx->ccid3hctx_t_last_win_count = now;
-		hctx->ccid3hctx_last_win_count  += min(quarter_rtts, 5U);
-		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
+		hctx->tx_t_last_win_count = now;
+		hctx->tx_last_win_count  += min(quarter_rtts, 5U);
+		hctx->tx_last_win_count	 &= 0xF;		/* mod 16 */
 	}
 }
 
@@ -220,23 +209,22 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	}
 
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid3_tx_state_name(hctx->ccid3hctx_state));
+		       ccid3_tx_state_name(hctx->tx_state));
 
-	if (hctx->ccid3hctx_state = TFRC_SSTATE_FBACK)
+	if (hctx->tx_state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+	else if (hctx->tx_state != TFRC_SSTATE_NO_FBACK)
 		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
-	if (hctx->ccid3hctx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->ccid3hctx_p = 0) {
+	if (hctx->tx_t_rto = 0 ||	/* no feedback received yet */
+	    hctx->tx_p = 0) {
 
 		/* halve send rate directly */
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x / 2,
-					(((__u64)hctx->ccid3hctx_s) << 6) /
-								    TFRC_T_MBI);
+		hctx->tx_x = max(hctx->tx_x / 2,
+				 (((__u64)hctx->tx_s) << 6) / TFRC_T_MBI);
 		ccid3_update_send_interval(hctx);
 	} else {
 		/*
@@ -249,33 +237,33 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
+		BUG_ON(hctx->tx_p && !hctx->tx_x_calc);
 
-		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
-			hctx->ccid3hctx_x_recv -				max(hctx->ccid3hctx_x_recv / 2,
-				    (((__u64)hctx->ccid3hctx_s) << 6) /
+		if (hctx->tx_x_calc > (hctx->tx_x_recv >> 5))
+			hctx->tx_x_recv +				max(hctx->tx_x_recv / 2,
+				    (((__u64)hctx->tx_s) << 6) /
 							      (2 * TFRC_T_MBI));
 		else {
-			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
-			hctx->ccid3hctx_x_recv <<= 4;
+			hctx->tx_x_recv = hctx->tx_x_calc;
+			hctx->tx_x_recv <<= 4;
 		}
 		ccid3_hc_tx_update_x(sk, NULL);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->ccid3hctx_x);
+			(unsigned long long)hctx->tx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->ccid3hctx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hctx->tx_t_rto = 0))	/* no feedback yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->tx_t_rto, 2 * hctx->tx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -303,18 +291,17 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->ccid3hctx_state) {
+	switch (hctx->tx_state) {
 	case TFRC_SSTATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-			       (jiffies +
+		sk_reset_timer(sk, &hctx->tx_no_feedback_timer, (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->ccid3hctx_last_win_count	 = 0;
-		hctx->ccid3hctx_t_last_win_count = now;
+		hctx->tx_last_win_count	  = 0;
+		hctx->tx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->ccid3hctx_t_nom = now;
+		hctx->tx_t_nom = now;
 
-		hctx->ccid3hctx_s = skb->len;
+		hctx->tx_s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -323,9 +310,9 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->tx_rtt  = dp->dccps_syn_rtt;
+			hctx->tx_x    = rfc3390_initial_rate(sk);
+			hctx->tx_t_ld = now;
 		} else {
 			/*
 			 * Sender does not have RTT sample:
@@ -333,9 +320,9 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			 *   is needed in several parts (e.g.  window counter);
 			 * - set sending rate X_pps = 1pps as per RFC 3448, 4.2.
 			 */
-			hctx->ccid3hctx_rtt = DCCP_FALLBACK_RTT;
-			hctx->ccid3hctx_x   = hctx->ccid3hctx_s;
-			hctx->ccid3hctx_x <<= 6;
+			hctx->tx_rtt = DCCP_FALLBACK_RTT;
+			hctx->tx_x   = hctx->tx_s;
+			hctx->tx_x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
 
@@ -343,7 +330,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = ktime_us_delta(hctx->ccid3hctx_t_nom, now);
+		delay = ktime_us_delta(hctx->tx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -353,7 +340,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
+		if (delay - (s64)hctx->tx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
@@ -365,11 +352,10 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->tx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->ccid3hctx_t_nom = ktime_add_us(hctx->ccid3hctx_t_nom,
-					     hctx->ccid3hctx_t_ipi);
+	hctx->tx_t_nom = ktime_add_us(hctx->tx_t_nom, hctx->tx_t_ipi);
 	return 0;
 }
 
@@ -380,7 +366,7 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 
 	ccid3_hc_tx_update_s(hctx, len);
 
-	if (tfrc_tx_hist_add(&hctx->ccid3hctx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hctx->tx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
@@ -397,15 +383,15 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->ccid3hctx_state != TFRC_SSTATE_FBACK &&
-	    hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+	if (hctx->tx_state != TFRC_SSTATE_FBACK &&
+	    hctx->tx_state != TFRC_SSTATE_NO_FBACK)
 		return;
 
-	opt_recv = &hctx->ccid3hctx_options_received;
+	opt_recv = &hctx->tx_options_received;
 	now = ktime_get_real();
 
 	/* Estimate RTT from history if ACK number is valid */
-	r_sample = tfrc_tx_hist_rtt(hctx->ccid3hctx_hist,
+	r_sample = tfrc_tx_hist_rtt(hctx->tx_hist,
 				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
 	if (r_sample = 0) {
 		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
@@ -415,37 +401,37 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
-	hctx->ccid3hctx_x_recv <<= 6;
+	hctx->tx_x_recv = opt_recv->ccid3or_receive_rate;
+	hctx->tx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->ccid3or_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->ccid3hctx_p = 0;
+		hctx->tx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->ccid3hctx_p = scaled_div(1, pinv);
+		hctx->tx_p = scaled_div(1, pinv);
 	/*
 	 * Validate new RTT sample and update moving average
 	 */
 	r_sample = dccp_sample_rtt(sk, r_sample);
-	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
+	hctx->tx_rtt = tfrc_ewma(hctx->tx_rtt, r_sample, 9);
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
+	if (hctx->tx_state = TFRC_SSTATE_NO_FBACK) {
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		if (hctx->ccid3hctx_t_rto = 0) {
+		if (hctx->tx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->tx_x    = rfc3390_initial_rate(sk);
+			hctx->tx_t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
 			goto done_computing_x;
-		} else if (hctx->ccid3hctx_p = 0) {
+		} else if (hctx->tx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -454,25 +440,20 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->ccid3hctx_p > 0)
-		hctx->ccid3hctx_x_calc -				tfrc_calc_x(hctx->ccid3hctx_s,
-					    hctx->ccid3hctx_rtt,
-					    hctx->ccid3hctx_p);
+	if (hctx->tx_p > 0)
+		hctx->tx_x_calc = tfrc_calc_x(hctx->tx_s, hctx->tx_rtt, hctx->tx_p);
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
+			       dccp_role(sk), sk, hctx->tx_rtt, r_sample,
+			       hctx->tx_s, hctx->tx_p, hctx->tx_x_calc,
+			       (unsigned)(hctx->tx_x_recv >> 6),
+			       (unsigned)(hctx->tx_x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->tx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -486,21 +467,19 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-					   (CONFIG_IP_DCCP_CCID3_RTO *
-					    (USEC_PER_SEC / 1000)));
+	hctx->tx_t_rto = max_t(u32, 4 * hctx->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
+						       (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+	t_nfb = max(hctx->tx_t_rto, 2 * hctx->tx_t_ipi);
 
 	ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
-		       dccp_role(sk),
-		       sk, usecs_to_jiffies(t_nfb), t_nfb);
+		       dccp_role(sk), sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
@@ -514,7 +493,7 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 	struct ccid3_options_received *opt_recv;
 	__be32 opt_val;
 
-	opt_recv = &hctx->ccid3hctx_options_received;
+	opt_recv = &hctx->tx_options_received;
 
 	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
 		opt_recv->ccid3or_seqno		     = dp->dccps_gsr;
@@ -570,11 +549,10 @@ static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
-	hctx->ccid3hctx_hist = NULL;
-	setup_timer(&hctx->ccid3hctx_no_feedback_timer,
+	hctx->tx_state = TFRC_SSTATE_NO_SENT;
+	hctx->tx_hist  = NULL;
+	setup_timer(&hctx->tx_no_feedback_timer,
 			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
-
 	return 0;
 }
 
@@ -583,9 +561,9 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
-	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->tx_no_feedback_timer);
 
-	tfrc_tx_hist_purge(&hctx->ccid3hctx_hist);
+	tfrc_tx_hist_purge(&hctx->tx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
@@ -597,8 +575,8 @@ static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 		return;
 
 	hctx = ccid3_hc_tx_sk(sk);
-	info->tcpi_rto = hctx->ccid3hctx_t_rto;
-	info->tcpi_rtt = hctx->ccid3hctx_rtt;
+	info->tcpi_rto = hctx->tx_t_rto;
+	info->tcpi_rtt = hctx->tx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
@@ -614,10 +592,10 @@ static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 	hctx = ccid3_hc_tx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->ccid3hctx_tfrc))
+		if (len < sizeof(hctx->tx_tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->ccid3hctx_tfrc);
-		val = &hctx->ccid3hctx_tfrc;
+		len = sizeof(hctx->tx_tfrc);
+		val = &hctx->tx_tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -658,13 +636,13 @@ static void ccid3_hc_rx_set_state(struct sock *sk,
 				  enum ccid3_hc_rx_states state)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum ccid3_hc_rx_states oldstate = hcrx->ccid3hcrx_state;
+	enum ccid3_hc_rx_states oldstate = hcrx->rx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
 		       ccid3_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->ccid3hcrx_state = state;
+	hcrx->rx_state = state;
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk,
@@ -676,15 +654,15 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 	ktime_t now;
 	s64 delta = 0;
 
-	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hcrx->rx_state = TFRC_RSTATE_TERM))
 		return;
 
 	now = ktime_get_real();
 
 	switch (fbtype) {
 	case CCID3_FBACK_INITIAL:
-		hcrx->ccid3hcrx_x_recv = 0;
-		hcrx->ccid3hcrx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
+		hcrx->rx_x_recv = 0;
+		hcrx->rx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case CCID3_FBACK_PARAM_CHANGE:
 		/*
@@ -697,27 +675,26 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->ccid3hcrx_x_recv > 0)
+		if (hcrx->rx_x_recv > 0)
 			break;
 		/* fall through */
 	case CCID3_FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->ccid3hcrx_tstamp_last_feedback);
+		delta = ktime_us_delta(now, hcrx->rx_tstamp_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->ccid3hcrx_x_recv -				scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+			hcrx->rx_x_recv = scaled_div32(hcrx->rx_bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 
 	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
+		       hcrx->rx_x_recv, hcrx->rx_pinv);
 
-	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_last_counter	     = dccp_hdr(skb)->dccph_ccval;
-	hcrx->ccid3hcrx_bytes_recv	     = 0;
+	hcrx->rx_tstamp_last_feedback = now;
+	hcrx->rx_last_counter	      = dccp_hdr(skb)->dccph_ccval;
+	hcrx->rx_bytes_recv	      = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -736,8 +713,8 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
-	pinv   = htonl(hcrx->ccid3hcrx_pinv);
+	x_recv = htonl(hcrx->rx_x_recv);
+	pinv   = htonl(hcrx->rx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -764,22 +741,22 @@ static u32 ccid3_first_li(struct sock *sk)
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->ccid3hcrx_rtt = 0) {
+	if (hcrx->rx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
+		hcrx->rx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta = ktime_to_us(net_timedelta(hcrx->ccid3hcrx_tstamp_last_feedback));
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	delta  = ktime_to_us(net_timedelta(hcrx->rx_tstamp_last_feedback));
+	x_recv = scaled_div32(hcrx->rx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+		if ((x_recv = hcrx->rx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
 	}
 
-	fval = scaled_div(hcrx->ccid3hcrx_s, hcrx->ccid3hcrx_rtt);
+	fval = scaled_div(hcrx->rx_s, hcrx->rx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -796,14 +773,14 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hcrx->rx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = CCID3_FBACK_INITIAL;
 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-			hcrx->ccid3hcrx_s = payload;
+			hcrx->rx_s  = payload;
 			/*
-			 * Not necessary to update ccid3hcrx_bytes_recv here,
+			 * Not necessary to update rx_bytes_recv here,
 			 * since X_recv = 0 for the first feedback packet (cf.
 			 * RFC 3448, 6.3) -- gerrit
 			 */
@@ -811,7 +788,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		goto update_records;
 	}
 
-	if (tfrc_rx_hist_duplicate(&hcrx->ccid3hcrx_hist, skb))
+	if (tfrc_rx_hist_duplicate(&hcrx->rx_hist, skb))
 		return; /* done receiving */
 
 	if (is_data_packet) {
@@ -819,20 +796,20 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/*
 		 * Update moving-average of s and the sum of received payload bytes
 		 */
-		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, payload, 9);
-		hcrx->ccid3hcrx_bytes_recv += payload;
+		hcrx->rx_s = tfrc_ewma(hcrx->rx_s, payload, 9);
+		hcrx->rx_bytes_recv += payload;
 	}
 
 	/*
 	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist, &hcrx->ccid3hcrx_li_hist,
+	if (tfrc_rx_handle_loss(&hcrx->rx_hist, &hcrx->rx_li_hist,
 				skb, ndp, ccid3_first_li, sk)) {
 		do_feedback = CCID3_FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_hist_loss_pending(&hcrx->ccid3hcrx_hist))
+	if (tfrc_rx_hist_loss_pending(&hcrx->rx_hist))
 		return; /* done receiving */
 
 	/*
@@ -841,17 +818,17 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (!tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
-		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+	if (!tfrc_lh_is_initialised(&hcrx->rx_li_hist)) {
+		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->rx_hist, skb);
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
 		if (sample != 0)
-			hcrx->ccid3hcrx_rtt = tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
+			hcrx->rx_rtt = tfrc_ewma(hcrx->rx_rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb)) {
+	} else if (tfrc_lh_update_i_mean(&hcrx->rx_li_hist, skb)) {
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -862,11 +839,11 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->rx_last_counter) > 3)
 		do_feedback = CCID3_FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist, skb, ndp);
+	tfrc_rx_hist_add_packet(&hcrx->rx_hist, skb, ndp);
 
 done_receiving:
 	if (do_feedback)
@@ -877,9 +854,9 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
-	return tfrc_rx_hist_alloc(&hcrx->ccid3hcrx_hist);
+	hcrx->rx_state = TFRC_RSTATE_NO_DATA;
+	tfrc_lh_init(&hcrx->rx_li_hist);
+	return tfrc_rx_hist_alloc(&hcrx->rx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
@@ -888,8 +865,8 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	tfrc_rx_hist_purge(&hcrx->ccid3hcrx_hist);
-	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
+	tfrc_rx_hist_purge(&hcrx->rx_hist);
+	tfrc_lh_cleanup(&hcrx->rx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -901,9 +878,9 @@ static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 		return;
 
 	hcrx = ccid3_hc_rx_sk(sk);
-	info->tcpi_ca_state = hcrx->ccid3hcrx_state;
+	info->tcpi_ca_state = hcrx->rx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
+	info->tcpi_rcv_rtt  = hcrx->rx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
@@ -922,10 +899,10 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->ccid3hcrx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->ccid3hcrx_rtt;
-		rx_info.tfrcrx_p      = hcrx->ccid3hcrx_pinv = 0 ? ~0U :
-					   scaled_div(1, hcrx->ccid3hcrx_pinv);
+		rx_info.tfrcrx_x_recv = hcrx->rx_x_recv;
+		rx_info.tfrcrx_rtt    = hcrx->rx_rtt;
+		rx_info.tfrcrx_p      = hcrx->rx_pinv = 0 ? ~0U :
+					   scaled_div(1, hcrx->rx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -83,14 +83,12 @@ static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
 		if (hctx)
-			printl("%pI4:%u %pI4:%u %d %d %d %d %u "
-			       "%llu %llu %d\n",
+			printl("%pI4:%u %pI4:%u %d %d %d %d %u %llu %llu %d\n",
 			       &inet->saddr, ntohs(inet->sport),
 			       &inet->daddr, ntohs(inet->dport), size,
-			       hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
-			       hctx->ccid3hctx_x_recv >> 6,
-			       hctx->ccid3hctx_x >> 6, hctx->ccid3hctx_t_ipi);
+			       hctx->tx_s, hctx->tx_rtt, hctx->tx_p,
+			       hctx->tx_x_calc, hctx->tx_x_recv >> 6,
+			       hctx->tx_x >> 6, hctx->tx_t_ipi);
 		else
 			printl("%pI4:%u %pI4:%u %d\n",
 			       &inet->saddr, ntohs(inet->sport),
