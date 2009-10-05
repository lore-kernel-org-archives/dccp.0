From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Oct 2009 10:53:13 +0000
Subject: [PATCH 4/4][RFC] dccp ccid-3: Remove CCID naming redundancy 2/2
Message-Id: <1254739993-5051-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This continues the previous patch, by applying the same change to CCID-3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |  371 ++++++++++++++++++++++++------------------------
 net/dccp/probe.c       |   12 +-
 2 files changed, 191 insertions(+), 192 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -64,14 +64,14 @@ static const char *ccid3_tx_state_name(enum ccid3_hc_tx_states state)
 static void ccid3_hc_tx_set_state(struct sock *sk,
 				  enum ccid3_hc_tx_states state)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	enum ccid3_hc_tx_states oldstate = hctx->tx_state;
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
+	enum ccid3_hc_tx_states oldstate = hc->tx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_tx_state_name(oldstate),
 		       ccid3_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->tx_state = state;
+	hc->tx_state = state;
 }
 
 /*
@@ -85,32 +85,32 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
  */
 static inline u64 rfc3390_initial_rate(struct sock *sk)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 w_init = clamp_t(__u32, 4380U, 2 * hctx->tx_s, 4 * hctx->tx_s);
+	const struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
+	const __u32 w_init = clamp_t(__u32, 4380U, 2 * hc->tx_s, 4 * hc->tx_s);
 
-	return scaled_div(w_init << 6, hctx->tx_rtt);
+	return scaled_div(w_init << 6, hc->tx_rtt);
 }
 
 /*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
-static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
+static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hc)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->tx_t_ipi = scaled_div32(((u64)hctx->tx_s) << 6, hctx->tx_x);
+	hc->tx_t_ipi = scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->tx_delta = min_t(u32, hctx->tx_t_ipi / 2, TFRC_OPSYS_HALF_TIME_GRAN);
+	hc->tx_delta = min_t(u32, hc->tx_t_ipi / 2, TFRC_OPSYS_HALF_TIME_GRAN);
 
-	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n", hctx->tx_t_ipi,
-		       hctx->tx_delta, hctx->tx_s, (unsigned)(hctx->tx_x >> 6));
+	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n", hc->tx_t_ipi,
+		       hc->tx_delta, hc->tx_s, (unsigned)(hc->tx_x >> 6));
 }
 
-static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
+static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hc, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->tx_t_last_win_count);
+	u32 delta = ktime_us_delta(now, hc->tx_t_last_win_count);
 
-	return delta / hctx->tx_rtt;
+	return delta / hc->tx_rtt;
 }
 
 /**
@@ -125,9 +125,9 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->tx_x_recv;
-	const __u64 old_x = hctx->tx_x;
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
+	__u64 min_rate = 2 * hc->tx_x_recv;
+	const __u64 old_x = hc->tx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -136,31 +136,31 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
+	if (ccid3_hc_tx_idle_rtt(hc, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->tx_x_recv);
+		min_rate = max(min_rate, 2 * hc->tx_x_recv);
 	}
 
-	if (hctx->tx_p > 0) {
+	if (hc->tx_p > 0) {
 
-		hctx->tx_x = min(((__u64)hctx->tx_x_calc) << 6, min_rate);
-		hctx->tx_x = max(hctx->tx_x, (((__u64)hctx->tx_s) << 6) / TFRC_T_MBI);
+		hc->tx_x = min(((__u64)hc->tx_x_calc) << 6, min_rate);
+		hc->tx_x = max(hc->tx_x, (((__u64)hc->tx_s) << 6) / TFRC_T_MBI);
 
-	} else if (ktime_us_delta(now, hctx->tx_t_ld) - (s64)hctx->tx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hc->tx_t_ld) - (s64)hc->tx_rtt >= 0) {
 
-		hctx->tx_x = min(2 * hctx->tx_x, min_rate);
-		hctx->tx_x = max(hctx->tx_x, scaled_div(((__u64)hctx->tx_s) << 6,
-							hctx->tx_rtt));
-		hctx->tx_t_ld = now;
+		hc->tx_x = min(2 * hc->tx_x, min_rate);
+		hc->tx_x = max(hc->tx_x,
+			       scaled_div(((__u64)hc->tx_s) << 6, hc->tx_rtt));
+		hc->tx_t_ld = now;
 	}
 
-	if (hctx->tx_x != old_x) {
+	if (hc->tx_x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->tx_x >> 6), hctx->tx_x_calc,
-			       (unsigned)(hctx->tx_x_recv >> 6));
+			       (unsigned)(hc->tx_x >> 6), hc->tx_x_calc,
+			       (unsigned)(hc->tx_x_recv >> 6));
 
-		ccid3_update_send_interval(hctx);
+		ccid3_update_send_interval(hc);
 	}
 }
 
@@ -168,37 +168,37 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
  *	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
  *	@len: DCCP packet payload size in bytes
  */
-static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
+static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hc, int len)
 {
-	const u16 old_s = hctx->tx_s;
+	const u16 old_s = hc->tx_s;
 
-	hctx->tx_s = tfrc_ewma(hctx->tx_s, len, 9);
+	hc->tx_s = tfrc_ewma(hc->tx_s, len, 9);
 
-	if (hctx->tx_s != old_s)
-		ccid3_update_send_interval(hctx);
+	if (hc->tx_s != old_s)
+		ccid3_update_send_interval(hc);
 }
 
 /*
  *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
  *	As elsewhere, RTT > 0 is assumed by using dccp_sample_rtt().
  */
-static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
+static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hc,
 						ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->tx_t_last_win_count),
-	    quarter_rtts = (4 * delta) / hctx->tx_rtt;
+	u32 delta = ktime_us_delta(now, hc->tx_t_last_win_count),
+	    quarter_rtts = (4 * delta) / hc->tx_rtt;
 
 	if (quarter_rtts > 0) {
-		hctx->tx_t_last_win_count = now;
-		hctx->tx_last_win_count  += min(quarter_rtts, 5U);
-		hctx->tx_last_win_count	 &= 0xF;		/* mod 16 */
+		hc->tx_t_last_win_count = now;
+		hc->tx_last_win_count  += min(quarter_rtts, 5U);
+		hc->tx_last_win_count  &= 0xF;		/* mod 16 */
 	}
 }
 
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -209,23 +209,23 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	}
 
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       ccid3_tx_state_name(hctx->tx_state));
+		       ccid3_tx_state_name(hc->tx_state));
 
-	if (hctx->tx_state = TFRC_SSTATE_FBACK)
+	if (hc->tx_state = TFRC_SSTATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
-	else if (hctx->tx_state != TFRC_SSTATE_NO_FBACK)
+	else if (hc->tx_state != TFRC_SSTATE_NO_FBACK)
 		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
-	if (hctx->tx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->tx_p = 0) {
+	if (hc->tx_t_rto = 0 ||	/* no feedback received yet */
+	    hc->tx_p = 0) {
 
 		/* halve send rate directly */
-		hctx->tx_x = max(hctx->tx_x / 2,
-				 (((__u64)hctx->tx_s) << 6) / TFRC_T_MBI);
-		ccid3_update_send_interval(hctx);
+		hc->tx_x = max(hc->tx_x / 2,
+			       (((__u64)hc->tx_s) << 6) / TFRC_T_MBI);
+		ccid3_update_send_interval(hc);
 	} else {
 		/*
 		 *  Modify the cached value of X_recv
@@ -237,33 +237,32 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->tx_p && !hctx->tx_x_calc);
+		BUG_ON(hc->tx_p && !hc->tx_x_calc);
 
-		if (hctx->tx_x_calc > (hctx->tx_x_recv >> 5))
-			hctx->tx_x_recv -				max(hctx->tx_x_recv / 2,
-				    (((__u64)hctx->tx_s) << 6) /
-							      (2 * TFRC_T_MBI));
+		if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
+			hc->tx_x_recv +				max(hc->tx_x_recv / 2,
+				    (((__u64)hc->tx_s) << 6) / (2*TFRC_T_MBI));
 		else {
-			hctx->tx_x_recv = hctx->tx_x_calc;
-			hctx->tx_x_recv <<= 4;
+			hc->tx_x_recv = hc->tx_x_calc;
+			hc->tx_x_recv <<= 4;
 		}
 		ccid3_hc_tx_update_x(sk, NULL);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->tx_x);
+			(unsigned long long)hc->tx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->tx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hc->tx_t_rto = 0))	/* no feedback yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->tx_t_rto, 2 * hctx->tx_t_ipi);
+		t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->tx_no_feedback_timer,
+	sk_reset_timer(sk, &hc->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -279,7 +278,7 @@ out:
 static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delay;
 
@@ -291,17 +290,17 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->tx_state) {
+	switch (hc->tx_state) {
 	case TFRC_SSTATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->tx_no_feedback_timer, (jiffies +
-				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->tx_last_win_count	  = 0;
-		hctx->tx_t_last_win_count = now;
+		sk_reset_timer(sk, &hc->tx_no_feedback_timer, (jiffies +
+			       usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
+		hc->tx_last_win_count	= 0;
+		hc->tx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->tx_t_nom = now;
+		hc->tx_t_nom = now;
 
-		hctx->tx_s = skb->len;
+		hc->tx_s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -310,9 +309,9 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->tx_rtt  = dp->dccps_syn_rtt;
-			hctx->tx_x    = rfc3390_initial_rate(sk);
-			hctx->tx_t_ld = now;
+			hc->tx_rtt  = dp->dccps_syn_rtt;
+			hc->tx_x    = rfc3390_initial_rate(sk);
+			hc->tx_t_ld = now;
 		} else {
 			/*
 			 * Sender does not have RTT sample:
@@ -320,17 +319,17 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			 *   is needed in several parts (e.g.  window counter);
 			 * - set sending rate X_pps = 1pps as per RFC 3448, 4.2.
 			 */
-			hctx->tx_rtt = DCCP_FALLBACK_RTT;
-			hctx->tx_x   = hctx->tx_s;
-			hctx->tx_x <<= 6;
+			hc->tx_rtt = DCCP_FALLBACK_RTT;
+			hc->tx_x   = hc->tx_s;
+			hc->tx_x <<= 6;
 		}
-		ccid3_update_send_interval(hctx);
+		ccid3_update_send_interval(hc);
 
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = ktime_us_delta(hctx->tx_t_nom, now);
+		delay = ktime_us_delta(hc->tx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -340,10 +339,10 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->tx_delta >= 1000)
+		if (delay - (s64)hc->tx_delta >= 1000)
 			return (u32)delay / 1000L;
 
-		ccid3_hc_tx_update_win_count(hctx, now);
+		ccid3_hc_tx_update_win_count(hc, now);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
@@ -352,27 +351,27 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->tx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval  = hc->tx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->tx_t_nom = ktime_add_us(hctx->tx_t_nom, hctx->tx_t_ipi);
+	hc->tx_t_nom = ktime_add_us(hc->tx_t_nom, hc->tx_t_ipi);
 	return 0;
 }
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 				    unsigned int len)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 
-	ccid3_hc_tx_update_s(hctx, len);
+	ccid3_hc_tx_update_s(hc, len);
 
-	if (tfrc_tx_hist_add(&hctx->tx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hc->tx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 	ktime_t now;
 	unsigned long t_nfb;
@@ -383,15 +382,15 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->tx_state != TFRC_SSTATE_FBACK &&
-	    hctx->tx_state != TFRC_SSTATE_NO_FBACK)
+	if (hc->tx_state != TFRC_SSTATE_FBACK &&
+	    hc->tx_state != TFRC_SSTATE_NO_FBACK)
 		return;
 
-	opt_recv = &hctx->tx_options_received;
+	opt_recv = &hc->tx_options_received;
 	now = ktime_get_real();
 
 	/* Estimate RTT from history if ACK number is valid */
-	r_sample = tfrc_tx_hist_rtt(hctx->tx_hist,
+	r_sample = tfrc_tx_hist_rtt(hc->tx_hist,
 				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
 	if (r_sample = 0) {
 		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
@@ -401,37 +400,37 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->tx_x_recv = opt_recv->ccid3or_receive_rate;
-	hctx->tx_x_recv <<= 6;
+	hc->tx_x_recv = opt_recv->ccid3or_receive_rate;
+	hc->tx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->ccid3or_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->tx_p = 0;
+		hc->tx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->tx_p = scaled_div(1, pinv);
+		hc->tx_p = scaled_div(1, pinv);
 	/*
 	 * Validate new RTT sample and update moving average
 	 */
 	r_sample = dccp_sample_rtt(sk, r_sample);
-	hctx->tx_rtt = tfrc_ewma(hctx->tx_rtt, r_sample, 9);
+	hc->tx_rtt = tfrc_ewma(hc->tx_rtt, r_sample, 9);
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->tx_state = TFRC_SSTATE_NO_FBACK) {
+	if (hc->tx_state = TFRC_SSTATE_NO_FBACK) {
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		if (hctx->tx_t_rto = 0) {
+		if (hc->tx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->tx_x    = rfc3390_initial_rate(sk);
-			hctx->tx_t_ld = now;
+			hc->tx_x    = rfc3390_initial_rate(sk);
+			hc->tx_t_ld = now;
 
-			ccid3_update_send_interval(hctx);
+			ccid3_update_send_interval(hc);
 
 			goto done_computing_x;
-		} else if (hctx->tx_p = 0) {
+		} else if (hc->tx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -440,20 +439,20 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->tx_p > 0)
-		hctx->tx_x_calc = tfrc_calc_x(hctx->tx_s, hctx->tx_rtt, hctx->tx_p);
+	if (hc->tx_p > 0)
+		hc->tx_x_calc = tfrc_calc_x(hc->tx_s, hc->tx_rtt, hc->tx_p);
 	ccid3_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-			       dccp_role(sk), sk, hctx->tx_rtt, r_sample,
-			       hctx->tx_s, hctx->tx_p, hctx->tx_x_calc,
-			       (unsigned)(hctx->tx_x_recv >> 6),
-			       (unsigned)(hctx->tx_x >> 6));
+			       dccp_role(sk), sk, hc->tx_rtt, r_sample,
+			       hc->tx_s, hc->tx_p, hc->tx_x_calc,
+			       (unsigned)(hc->tx_x_recv >> 6),
+			       (unsigned)(hc->tx_x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->tx_no_feedback_timer);
+	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -467,19 +466,19 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->tx_t_rto = max_t(u32, 4 * hctx->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
+	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
 						       (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->tx_t_rto, 2 * hctx->tx_t_ipi);
+	t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
 
 	ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
 		       dccp_role(sk), sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->tx_no_feedback_timer,
+	sk_reset_timer(sk, &hc->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
@@ -489,11 +488,11 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 {
 	int rc = 0;
 	const struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 	__be32 opt_val;
 
-	opt_recv = &hctx->tx_options_received;
+	opt_recv = &hc->tx_options_received;
 
 	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
 		opt_recv->ccid3or_seqno		     = dp->dccps_gsr;
@@ -547,55 +546,55 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct ccid3_hc_tx_sock *hc = ccid_priv(ccid);
 
-	hctx->tx_state = TFRC_SSTATE_NO_SENT;
-	hctx->tx_hist  = NULL;
-	setup_timer(&hctx->tx_no_feedback_timer,
+	hc->tx_state = TFRC_SSTATE_NO_SENT;
+	hc->tx_hist  = NULL;
+	setup_timer(&hc->tx_no_feedback_timer,
 			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
 	return 0;
 }
 
 static void ccid3_hc_tx_exit(struct sock *sk)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hc = ccid3_hc_tx_sk(sk);
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
-	sk_stop_timer(sk, &hctx->tx_no_feedback_timer);
+	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
 
-	tfrc_tx_hist_purge(&hctx->tx_hist);
+	tfrc_tx_hist_purge(&hc->tx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	struct ccid3_hc_tx_sock *hctx;
+	struct ccid3_hc_tx_sock *hc;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	hctx = ccid3_hc_tx_sk(sk);
-	info->tcpi_rto = hctx->tx_t_rto;
-	info->tcpi_rtt = hctx->tx_rtt;
+	hc = ccid3_hc_tx_sk(sk);
+	info->tcpi_rto = hc->tx_t_rto;
+	info->tcpi_rtt = hc->tx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_tx_sock *hctx;
+	const struct ccid3_hc_tx_sock *hc;
 	const void *val;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return -EINVAL;
 
-	hctx = ccid3_hc_tx_sk(sk);
+	hc = ccid3_hc_tx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->tx_tfrc))
+		if (len < sizeof(hc->tx_tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->tx_tfrc);
-		val = &hctx->tx_tfrc;
+		len = sizeof(hc->tx_tfrc);
+		val = &hc->tx_tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -635,34 +634,34 @@ static const char *ccid3_rx_state_name(enum ccid3_hc_rx_states state)
 static void ccid3_hc_rx_set_state(struct sock *sk,
 				  enum ccid3_hc_rx_states state)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum ccid3_hc_rx_states oldstate = hcrx->rx_state;
+	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
+	enum ccid3_hc_rx_states oldstate = hc->rx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, ccid3_rx_state_name(oldstate),
 		       ccid3_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->rx_state = state;
+	hc->rx_state = state;
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk,
 				      const struct sk_buff *skb,
 				      enum ccid3_fback_type fbtype)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	ktime_t now;
 	s64 delta = 0;
 
-	if (unlikely(hcrx->rx_state = TFRC_RSTATE_TERM))
+	if (unlikely(hc->rx_state = TFRC_RSTATE_TERM))
 		return;
 
 	now = ktime_get_real();
 
 	switch (fbtype) {
 	case CCID3_FBACK_INITIAL:
-		hcrx->rx_x_recv = 0;
-		hcrx->rx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
+		hc->rx_x_recv = 0;
+		hc->rx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case CCID3_FBACK_PARAM_CHANGE:
 		/*
@@ -675,26 +674,26 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->rx_x_recv > 0)
+		if (hc->rx_x_recv > 0)
 			break;
 		/* fall through */
 	case CCID3_FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->rx_tstamp_last_feedback);
+		delta = ktime_us_delta(now, hc->rx_tstamp_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->rx_x_recv = scaled_div32(hcrx->rx_bytes_recv, delta);
+			hc->rx_x_recv = scaled_div32(hc->rx_bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 
 	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->rx_x_recv, hcrx->rx_pinv);
+		       hc->rx_x_recv, hc->rx_pinv);
 
-	hcrx->rx_tstamp_last_feedback = now;
-	hcrx->rx_last_counter	      = dccp_hdr(skb)->dccph_ccval;
-	hcrx->rx_bytes_recv	      = 0;
+	hc->rx_tstamp_last_feedback = now;
+	hc->rx_last_counter	    = dccp_hdr(skb)->dccph_ccval;
+	hc->rx_bytes_recv	    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -702,19 +701,19 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk,
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid3_hc_rx_sock *hcrx;
+	const struct ccid3_hc_rx_sock *hc;
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
-	hcrx = ccid3_hc_rx_sk(sk);
+	hc = ccid3_hc_rx_sk(sk);
 
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->rx_x_recv);
-	pinv   = htonl(hcrx->rx_pinv);
+	x_recv = htonl(hc->rx_x_recv);
+	pinv   = htonl(hc->rx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -737,26 +736,26 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
  */
 static u32 ccid3_first_li(struct sock *sk)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->rx_rtt = 0) {
+	if (hc->rx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->rx_rtt = DCCP_FALLBACK_RTT;
+		hc->rx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta  = ktime_to_us(net_timedelta(hcrx->rx_tstamp_last_feedback));
-	x_recv = scaled_div32(hcrx->rx_bytes_recv, delta);
+	delta  = ktime_to_us(net_timedelta(hc->rx_tstamp_last_feedback));
+	x_recv = scaled_div32(hc->rx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->rx_x_recv) = 0) {
+		if ((x_recv = hc->rx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
 	}
 
-	fval = scaled_div(hcrx->rx_s, hcrx->rx_rtt);
+	fval = scaled_div(hc->rx_s, hc->rx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -768,17 +767,17 @@ static u32 ccid3_first_li(struct sock *sk)
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 	enum ccid3_fback_type do_feedback = CCID3_FBACK_NONE;
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->rx_state = TFRC_RSTATE_NO_DATA)) {
+	if (unlikely(hc->rx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = CCID3_FBACK_INITIAL;
 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
-			hcrx->rx_s  = payload;
+			hc->rx_s = payload;
 			/*
 			 * Not necessary to update rx_bytes_recv here,
 			 * since X_recv = 0 for the first feedback packet (cf.
@@ -788,7 +787,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		goto update_records;
 	}
 
-	if (tfrc_rx_hist_duplicate(&hcrx->rx_hist, skb))
+	if (tfrc_rx_hist_duplicate(&hc->rx_hist, skb))
 		return; /* done receiving */
 
 	if (is_data_packet) {
@@ -796,20 +795,20 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		/*
 		 * Update moving-average of s and the sum of received payload bytes
 		 */
-		hcrx->rx_s = tfrc_ewma(hcrx->rx_s, payload, 9);
-		hcrx->rx_bytes_recv += payload;
+		hc->rx_s = tfrc_ewma(hc->rx_s, payload, 9);
+		hc->rx_bytes_recv += payload;
 	}
 
 	/*
 	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_rx_handle_loss(&hcrx->rx_hist, &hcrx->rx_li_hist,
+	if (tfrc_rx_handle_loss(&hc->rx_hist, &hc->rx_li_hist,
 				skb, ndp, ccid3_first_li, sk)) {
 		do_feedback = CCID3_FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_hist_loss_pending(&hcrx->rx_hist))
+	if (tfrc_rx_hist_loss_pending(&hc->rx_hist))
 		return; /* done receiving */
 
 	/*
@@ -818,17 +817,17 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (!tfrc_lh_is_initialised(&hcrx->rx_li_hist)) {
-		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->rx_hist, skb);
+	if (!tfrc_lh_is_initialised(&hc->rx_li_hist)) {
+		const u32 sample = tfrc_rx_hist_sample_rtt(&hc->rx_hist, skb);
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
 		if (sample != 0)
-			hcrx->rx_rtt = tfrc_ewma(hcrx->rx_rtt, sample, 9);
+			hc->rx_rtt = tfrc_ewma(hc->rx_rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->rx_li_hist, skb)) {
+	} else if (tfrc_lh_update_i_mean(&hc->rx_li_hist, skb)) {
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -839,11 +838,11 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->rx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hc->rx_last_counter) > 3)
 		do_feedback = CCID3_FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_add_packet(&hcrx->rx_hist, skb, ndp);
+	tfrc_rx_hist_add_packet(&hc->rx_hist, skb, ndp);
 
 done_receiving:
 	if (do_feedback)
@@ -852,41 +851,41 @@ done_receiving:
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
+	struct ccid3_hc_rx_sock *hc = ccid_priv(ccid);
 
-	hcrx->rx_state = TFRC_RSTATE_NO_DATA;
-	tfrc_lh_init(&hcrx->rx_li_hist);
-	return tfrc_rx_hist_alloc(&hcrx->rx_hist);
+	hc->rx_state = TFRC_RSTATE_NO_DATA;
+	tfrc_lh_init(&hc->rx_li_hist);
+	return tfrc_rx_hist_alloc(&hc->rx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct ccid3_hc_rx_sock *hc = ccid3_hc_rx_sk(sk);
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	tfrc_rx_hist_purge(&hcrx->rx_hist);
-	tfrc_lh_cleanup(&hcrx->rx_li_hist);
+	tfrc_rx_hist_purge(&hc->rx_hist);
+	tfrc_lh_cleanup(&hc->rx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_rx_sock *hcrx;
+	const struct ccid3_hc_rx_sock *hc;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	hcrx = ccid3_hc_rx_sk(sk);
-	info->tcpi_ca_state = hcrx->rx_state;
+	hc = ccid3_hc_rx_sk(sk);
+	info->tcpi_ca_state = hc->rx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = hcrx->rx_rtt;
+	info->tcpi_rcv_rtt  = hc->rx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_rx_sock *hcrx;
+	const struct ccid3_hc_rx_sock *hc;
 	struct tfrc_rx_info rx_info;
 	const void *val;
 
@@ -894,15 +893,15 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	if (sk->sk_state = DCCP_LISTEN)
 		return -EINVAL;
 
-	hcrx = ccid3_hc_rx_sk(sk);
+	hc = ccid3_hc_rx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->rx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->rx_rtt;
-		rx_info.tfrcrx_p      = hcrx->rx_pinv = 0 ? ~0U :
-					   scaled_div(1, hcrx->rx_pinv);
+		rx_info.tfrcrx_x_recv = hc->rx_x_recv;
+		rx_info.tfrcrx_rtt    = hc->rx_rtt;
+		rx_info.tfrcrx_p      = hc->rx_pinv = 0 ? ~0U :
+					   scaled_div(1, hc->rx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -75,20 +75,20 @@ static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 			 struct msghdr *msg, size_t size)
 {
 	const struct inet_sock *inet = inet_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = NULL;
+	struct ccid3_hc_tx_sock *hc = NULL;
 
 	if (ccid_get_current_tx_ccid(dccp_sk(sk)) = DCCPC_CCID3)
-		hctx = ccid3_hc_tx_sk(sk);
+		hc = ccid3_hc_tx_sk(sk);
 
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
-		if (hctx)
+		if (hc)
 			printl("%pI4:%u %pI4:%u %d %d %d %d %u %llu %llu %d\n",
 			       &inet->saddr, ntohs(inet->sport),
 			       &inet->daddr, ntohs(inet->dport), size,
-			       hctx->tx_s, hctx->tx_rtt, hctx->tx_p,
-			       hctx->tx_x_calc, hctx->tx_x_recv >> 6,
-			       hctx->tx_x >> 6, hctx->tx_t_ipi);
+			       hc->tx_s, hc->tx_rtt, hc->tx_p,
+			       hc->tx_x_calc, hc->tx_x_recv >> 6,
+			       hc->tx_x >> 6, hc->tx_t_ipi);
 		else
 			printl("%pI4:%u %pI4:%u %d\n",
 			       &inet->saddr, ntohs(inet->sport),
-- 
1.6.0.rc2

