From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 19 Oct 2009 05:32:31 +0000
Subject: ccid-4 [PATCH 1/1]: Add the new prefix scheme also to the CCID-4
Message-Id: <20091019053231.GF3366@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ivo,

please find below the patch to implement the prefix scheme introduced very recently,
so that the CCID-4 tree also has the same naming conventions as used for CCID-3 and
CCID-2. If you are ok with this, I would merge parts of it with the other patches
(in particular the first CCID-4 patch, ccid4.patch), in order to make the patch size
smaller.

>>>>>>>>>>>>>>>>>>>>>>> Patch v1 <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<


tfrc-sp: Implement prefix-scheme

This ports the new prefix scheme introduced for the CCID-structs to TFRC-SP/CCID-4.
It mainly does  s/hc\(tx\|rx\)->/hc->\1_/g; s/hc\(tx\|rx\)/hc/g

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |  280 +++++++++++++++---------------
 net/dccp/ccids/ccid4.c             |  338 ++++++++++++++++++-------------------
 net/dccp/ccids/lib/tfrc_ccids.c    |   20 +-
 net/dccp/ccids/lib/tfrc_ccids.h    |  110 ++++++------
 net/dccp/ccids/lib/tfrc_ccids_sp.h |  110 ++++++------
 5 files changed, 430 insertions(+), 428 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -55,11 +55,11 @@ static int ccid3_osc_prev = true;
  * This respects the granularity of X (64 * bytes/second) and enforces the
  * scaled minimum of s * 64 / t_mbi = `s' bytes/second as per RFC 3448/4342.
  */
-static void ccid3_update_send_interval(struct tfrc_hc_tx_sock *hctx)
+static void ccid3_update_send_interval(struct tfrc_hc_tx_sock *hc)
 {
-	if (unlikely(hctx->x <= hctx->s))
-		hctx->x	= hctx->s;
-	hctx->t_ipi = scaled_div32(((u64)hctx->s) << 6, hctx->x);
+	if (unlikely(hc->tx_x <= hc->tx_s))
+		hc->tx_x	= hc->tx_s;
+	hc->tx_t_ipi = scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 }
 
 /**
@@ -74,9 +74,9 @@ static void ccid3_update_send_interval(s
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	u64 min_rate = 2 * hctx->x_recv;
-	const u64 old_x = hctx->x;
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
+	u64 min_rate = 2 * hc->tx_x_recv;
+	const u64 old_x = hc->tx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -85,30 +85,30 @@ static void ccid3_hc_tx_update_x(struct 
 	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
+	if (tfrc_hc_tx_idle_rtt(hc, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->x_recv);
+		min_rate = max(min_rate, 2 * hc->tx_x_recv);
 	}
 
-	if (hctx->p > 0) {
+	if (hc->tx_p > 0) {
 
-		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
+		hc->tx_x = min(((u64)hc->tx_x_calc) << 6, min_rate);
 
-	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
+	} else if (ktime_us_delta(now, hc->tx_t_ld) - (s64)hc->tx_rtt >= 0) {
 
-		hctx->x = min(2 * hctx->x, min_rate);
-		hctx->x = max(hctx->x,
-			      scaled_div(((u64)hctx->s) << 6, hctx->rtt));
-		hctx->t_ld = now;
+		hc->tx_x = min(2 * hc->tx_x, min_rate);
+		hc->tx_x = max(hc->tx_x,
+			      scaled_div(((u64)hc->tx_s) << 6, hc->tx_rtt));
+		hc->tx_t_ld = now;
 	}
 
-	if (hctx->x != old_x) {
+	if (hc->tx_x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->x >> 6), hctx->x_calc,
-			       (unsigned)(hctx->x_recv >> 6));
+			       (unsigned)(hc->tx_x >> 6), hc->tx_x_calc,
+			       (unsigned)(hc->tx_x_recv >> 6));
 
-		ccid3_update_send_interval(hctx);
+		ccid3_update_send_interval(hc);
 	}
 }
 
@@ -130,7 +130,7 @@ static u32 ccid3_hc_tx_measure_packet_si
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -141,24 +141,24 @@ static void ccid3_hc_tx_no_feedback_time
 	}
 
 	ccid3_pr_debug("%s(%p) entry with%s feedback\n", dccp_role(sk), sk,
-		       hctx->feedback ? "" : "out");
+		       hc->tx_feedback ? "" : "out");
 
 	/* Ignore and do not restart after leaving the established state */
 	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
 		goto out;
 
 	/* Reset feedback state to "no feedback received" */
-	hctx->feedback = false;
+	hc->tx_feedback = false;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 * RTO is 0 if and only if no feedback has been received yet.
 	 */
-	if (hctx->t_rto = 0 || hctx->p = 0) {
+	if (hc->tx_t_rto = 0 || hc->tx_p = 0) {
 
 		/* halve send rate directly */
-		hctx->x /= 2;
-		ccid3_update_send_interval(hctx);
+		hc->tx_x /= 2;
+		ccid3_update_send_interval(hc);
 
 	} else {
 		/*
@@ -171,30 +171,30 @@ static void ccid3_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->p && !hctx->x_calc);
+		BUG_ON(hc->tx_p && !hc->tx_x_calc);
 
-		if (hctx->x_calc > (hctx->x_recv >> 5))
-			hctx->x_recv /= 2;
+		if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
+			hc->tx_x_recv /= 2;
 		else {
-			hctx->x_recv = hctx->x_calc;
-			hctx->x_recv <<= 4;
+			hc->tx_x_recv = hc->tx_x_calc;
+			hc->tx_x_recv <<= 4;
 		}
 		ccid3_hc_tx_update_x(sk, NULL);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->x);
+			(unsigned long long)hc->tx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->t_rto = 0))		/* no feedback received yet */
+	if (unlikely(hc->tx_t_rto = 0))		/* no feedback received yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->t_rto, 2 * hctx->t_ipi);
+		t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->no_feedback_timer,
+	sk_reset_timer(sk, &hc->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -210,7 +210,7 @@ out:
 static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delay;
 
@@ -222,14 +222,14 @@ static int ccid3_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	if (hctx->s = 0) {
-		sk_reset_timer(sk, &hctx->no_feedback_timer, (jiffies +
+	if (hc->tx_s = 0) {
+		sk_reset_timer(sk, &hc->tx_no_feedback_timer, (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->last_win_count   = 0;
-		hctx->t_last_win_count = now;
+		hc->tx_last_win_count   = 0;
+		hc->tx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->t_nom = now;
+		hc->tx_t_nom = now;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -238,9 +238,9 @@ static int ccid3_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->rtt  = dp->dccps_syn_rtt;
-			hctx->x    = rfc3390_initial_rate(sk);
-			hctx->t_ld = now;
+			hc->tx_rtt  = dp->dccps_syn_rtt;
+			hc->tx_x    = rfc3390_initial_rate(sk);
+			hc->tx_t_ld = now;
 		} else {
 			/*
 			 * Sender does not have RTT sample:
@@ -248,20 +248,20 @@ static int ccid3_hc_tx_send_packet(struc
 			 *   is needed in several parts (e.g.  window counter);
 			 * - set sending rate X_pps = 1pps as per RFC 3448, 4.2.
 			 */
-			hctx->rtt = DCCP_FALLBACK_RTT;
-			hctx->x	  = dp->dccps_mss_cache;
-			hctx->x <<= 6;
+			hc->tx_rtt = DCCP_FALLBACK_RTT;
+			hc->tx_x	  = dp->dccps_mss_cache;
+			hc->tx_x <<= 6;
 		}
 
 		/* Compute t_ipi = s / X */
-		hctx->s = ccid3_hc_tx_measure_packet_size(sk, skb->len);
-		ccid3_update_send_interval(hctx);
+		hc->tx_s = ccid3_hc_tx_measure_packet_size(sk, skb->len);
+		ccid3_update_send_interval(hc);
 
 		/* Seed value for Oscillation Prevention (sec. 4.5) */
-		hctx->r_sqmean = tfrc_scaled_sqrt(hctx->rtt);
+		hc->tx_r_sqmean = tfrc_scaled_sqrt(hc->tx_rtt);
 
 	} else {
-		delay = ktime_us_delta(hctx->t_nom, now);
+		delay = ktime_us_delta(hc->tx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -274,32 +274,32 @@ static int ccid3_hc_tx_send_packet(struc
 		if (delay >= TFRC_T_DELTA)
 			return (u32)delay / USEC_PER_MSEC;
 
-		tfrc_hc_tx_update_win_count(hctx, now);
+		tfrc_hc_tx_update_win_count(hc, now);
 	}
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval  = hctx->last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval  = hc->tx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->t_nom = ktime_add_us(hctx->t_nom, hctx->t_ipi);
+	hc->tx_t_nom = ktime_add_us(hc->tx_t_nom, hc->tx_t_ipi);
 	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 
 	/* Changes to s will become effective the next time X is computed */
-	hctx->s = ccid3_hc_tx_measure_packet_size(sk, len);
+	hc->tx_s = ccid3_hc_tx_measure_packet_size(sk, len);
 
-	if (tfrc_tx_hist_add(&hctx->hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hc->tx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	struct tfrc_tx_hist_entry *acked;
 	ktime_t now;
 	unsigned long t_nfb;
@@ -317,7 +317,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	 *  - the Ack is outdated (packet with higher Ack number was received),
 	 *  - it is a bogus Ack (for a packet not sent on this connection).
 	 */
-	acked = tfrc_tx_hist_find_entry(hctx->hist, dccp_hdr_ack_seq(skb));
+	acked = tfrc_tx_hist_find_entry(hc->tx_hist, dccp_hdr_ack_seq(skb));
 	if (acked = NULL)
 		return;
 	/* For the sake of RTT sampling, ignore/remove all older entries */
@@ -326,25 +326,25 @@ static void ccid3_hc_tx_packet_recv(stru
 	/* Update the moving average for the RTT estimate (RFC 3448, 4.3) */
 	now	  = ktime_get_real();
 	r_sample  = dccp_sample_rtt(sk, ktime_us_delta(now, acked->stamp));
-	hctx->rtt = tfrc_ewma(hctx->rtt, r_sample, 9);
+	hc->tx_rtt = tfrc_ewma(hc->tx_rtt, r_sample, 9);
 
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (!hctx->feedback) {
-		hctx->feedback = true;
+	if (!hc->tx_feedback) {
+		hc->tx_feedback = true;
 
-		if (hctx->t_rto = 0) {
+		if (hc->tx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->x    = rfc3390_initial_rate(sk);
-			hctx->t_ld = now;
+			hc->tx_x    = rfc3390_initial_rate(sk);
+			hc->tx_t_ld = now;
 
-			ccid3_update_send_interval(hctx);
+			ccid3_update_send_interval(hc);
 
 			goto done_computing_x;
-		} else if (hctx->p = 0) {
+		} else if (hc->tx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -353,17 +353,17 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->p > 0)
-		hctx->x_calc = tfrc_calc_x(hctx->s, hctx->rtt, hctx->p);
+	if (hc->tx_p > 0)
+		hc->tx_x_calc = tfrc_calc_x(hc->tx_s, hc->tx_rtt, hc->tx_p);
 	ccid3_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-			       dccp_role(sk), sk, hctx->rtt, r_sample,
-			       hctx->s, hctx->p, hctx->x_calc,
-			       (unsigned)(hctx->x_recv >> 6),
-			       (unsigned)(hctx->x >> 6));
+			       dccp_role(sk), sk, hc->tx_rtt, r_sample,
+			       hc->tx_s, hc->tx_p, hc->tx_x_calc,
+			       (unsigned)(hc->tx_x_recv >> 6),
+			       (unsigned)(hc->tx_x >> 6));
 	/*
 	 * Oscillation Reduction (RFC 3448, 4.5) - modifying t_ipi according to
 	 * RTT changes, multiplying by X/X_inst = sqrt(R_sample)/R_sqmean. This
@@ -389,16 +389,16 @@ done_computing_x:
 		 * naturally increases, where using the algorithm would cause
 		 * delays. Hence it is disabled during the initial slow-start.
 		 */
-		if (r_sample > hctx->r_sqmean && hctx->p > 0)
-			hctx->t_ipi = div_u64((u64)hctx->t_ipi * (u64)r_sample,
-					      hctx->r_sqmean);
-		hctx->t_ipi = min_t(u32, hctx->t_ipi, TFRC_T_MBI);
+		if (r_sample > hc->tx_r_sqmean && hc->tx_p > 0)
+			hc->tx_t_ipi = div_u64((u64)hc->tx_t_ipi * (u64)r_sample,
+					      hc->tx_r_sqmean);
+		hc->tx_t_ipi = min_t(u32, hc->tx_t_ipi, TFRC_T_MBI);
 		/* update R_sqmean _after_ computing the modulation factor */
-		hctx->r_sqmean = tfrc_ewma(hctx->r_sqmean, r_sample, 9);
+		hc->tx_r_sqmean = tfrc_ewma(hc->tx_r_sqmean, r_sample, 9);
 	}
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->no_feedback_timer);
+	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -412,26 +412,26 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->t_rto = max_t(u32, 4 * hctx->rtt, (CONFIG_IP_DCCP_CCID3_RTO *
+	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID3_RTO *
 						 (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->t_rto, 2 * hctx->t_ipi);
+	t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
 
 	ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
 		       dccp_role(sk), sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->no_feedback_timer,
+	sk_reset_timer(sk, &hc->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
 static int ccid3_hc_tx_parse_options(struct sock *sk, u8 packet_type,
 				     u8 option, u8 *optval, u8 optlen)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	__be32 opt_val;
 
 	switch (option) {
@@ -449,14 +449,14 @@ static int ccid3_hc_tx_parse_options(str
 
 		if (option = TFRC_OPT_RECEIVE_RATE) {
 			/* Receive Rate is kept in units of 64 bytes/second */
-			hctx->x_recv = opt_val;
-			hctx->x_recv <<= 6;
+			hc->tx_x_recv = opt_val;
+			hc->tx_x_recv <<= 6;
 
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		} else {
 			/* Update the fixpoint Loss Event Rate fraction */
-			hctx->p = tfrc_invert_loss_event_rate(opt_val);
+			hc->tx_p = tfrc_invert_loss_event_rate(opt_val);
 
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
@@ -467,32 +467,32 @@ static int ccid3_hc_tx_parse_options(str
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct tfrc_hc_tx_sock *hc = ccid_priv(ccid);
 
-	hctx->hist  = NULL;
-	setup_timer(&hctx->no_feedback_timer,
+	hc->tx_hist  = NULL;
+	setup_timer(&hc->tx_no_feedback_timer,
 		    ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
 	return 0;
 }
 
 static void ccid3_hc_tx_exit(struct sock *sk)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 
-	sk_stop_timer(sk, &hctx->no_feedback_timer);
-	tfrc_tx_hist_purge(&hctx->hist);
+	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
+	tfrc_tx_hist_purge(&hc->tx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = tfrc_hc_tx_sk(sk)->t_rto;
-	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->rtt;
+	info->tcpi_rto = tfrc_hc_tx_sk(sk)->tx_t_rto;
+	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->tx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	const struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	struct tfrc_tx_info tfrc;
 	const void *val;
 
@@ -500,13 +500,13 @@ static int ccid3_hc_tx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(tfrc))
 			return -EINVAL;
-		tfrc.tfrctx_x	   = hctx->x;
-		tfrc.tfrctx_x_recv = hctx->x_recv;
-		tfrc.tfrctx_x_calc = hctx->x_calc;
-		tfrc.tfrctx_rtt	   = hctx->rtt;
-		tfrc.tfrctx_p	   = hctx->p;
-		tfrc.tfrctx_rto	   = hctx->t_rto;
-		tfrc.tfrctx_ipi	   = hctx->t_ipi;
+		tfrc.tfrctx_x	   = hc->tx_x;
+		tfrc.tfrctx_x_recv = hc->tx_x_recv;
+		tfrc.tfrctx_x_calc = hc->tx_x_calc;
+		tfrc.tfrctx_rtt	   = hc->tx_rtt;
+		tfrc.tfrctx_p	   = hc->tx_p;
+		tfrc.tfrctx_rto	   = hc->tx_t_rto;
+		tfrc.tfrctx_ipi	   = hc->tx_t_ipi;
 		len = sizeof(tfrc);
 		val = &tfrc;
 		break;
@@ -527,15 +527,15 @@ static void ccid3_hc_rx_send_feedback(st
 				      const struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 
 	switch (fbtype) {
 	case TFRC_FBACK_INITIAL:
-		hcrx->x_recv = 0;
-		hcrx->p_inverse = ~0U;   /* see RFC 4342, 8.5 */
+		hc->rx_x_recv = 0;
+		hc->rx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case TFRC_FBACK_PARAM_CHANGE:
-		if (unlikely(hcrx->feedback = TFRC_FBACK_NONE)) {
+		if (unlikely(hc->rx_feedback = TFRC_FBACK_NONE)) {
 			/*
 			 * rfc3448bis-06, 6.3.1: First packet(s) lost or marked
 			 * FIXME: in rfc3448bis the receiver returns X_recv=0
@@ -548,10 +548,10 @@ static void ccid3_hc_rx_send_feedback(st
 			 * would bring X down to s/t_mbi. That is why we return
 			 * X_recv according to rfc3448bis-06 for the moment.
 			 */
-			u32 s = tfrc_rx_hist_packet_size(&hcrx->hist),
-			    rtt = tfrc_rx_hist_rtt(&hcrx->hist);
+			u32 s = tfrc_rx_hist_packet_size(&hc->rx_hist),
+			    rtt = tfrc_rx_hist_rtt(&hc->rx_hist);
 
-			hcrx->x_recv = scaled_div32(s, 2 * rtt);
+			hc->rx_x_recv = scaled_div32(s, 2 * rtt);
 			break;
 		}
 		/*
@@ -559,7 +559,7 @@ static void ccid3_hc_rx_send_feedback(st
 		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
 		 * always check whether at least RTT time units were covered.
 		 */
-		hcrx->x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		hc->rx_x_recv = tfrc_rx_hist_x_recv(&hc->rx_hist, hc->rx_x_recv);
 		break;
 	case TFRC_FBACK_PERIODIC:
 		/*
@@ -567,28 +567,28 @@ static void ccid3_hc_rx_send_feedback(st
 		 * - if no data packets have been received, just restart timer
 		 * - if data packets have been received, re-compute X_recv
 		 */
-		if (hcrx->hist.bytes_recvd = 0)
+		if (hc->rx_hist.bytes_recvd = 0)
 			goto prepare_for_next_time;
-		hcrx->x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		hc->rx_x_recv = tfrc_rx_hist_x_recv(&hc->rx_hist, hc->rx_x_recv);
 		break;
 	default:
 		return;
 	}
 
-	ccid3_pr_debug("X_recv=%u, 1/p=%u\n", hcrx->x_recv, hcrx->p_inverse);
+	ccid3_pr_debug("X_recv=%u, 1/p=%u\n", hc->rx_x_recv, hc->rx_pinv);
 
 	dccp_sk(sk)->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
 
 prepare_for_next_time:
-	tfrc_rx_hist_restart_byte_counter(&hcrx->hist);
-	hcrx->last_counter = dccp_hdr(skb)->dccph_ccval;
-	hcrx->feedback	   = fbtype;
+	tfrc_rx_hist_restart_byte_counter(&hc->rx_hist);
+	hc->rx_last_counter = dccp_hdr(skb)->dccph_ccval;
+	hc->rx_feedback	   = fbtype;
 }
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
@@ -597,8 +597,8 @@ static int ccid3_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->x_recv);
-	pinv   = htonl(hcrx->p_inverse);
+	x_recv = htonl(hc->rx_x_recv);
+	pinv   = htonl(hc->rx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -621,9 +621,9 @@ static int ccid3_hc_rx_insert_options(st
  */
 static u32 ccid3_first_li(struct sock *sk)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	u32 s = tfrc_rx_hist_packet_size(&hcrx->hist),
-	    rtt = tfrc_rx_hist_rtt(&hcrx->hist), x_recv, p;
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
+	u32 s = tfrc_rx_hist_packet_size(&hc->rx_hist),
+	    rtt = tfrc_rx_hist_rtt(&hc->rx_hist), x_recv, p;
 	u64 fval;
 
 	/*
@@ -631,10 +631,10 @@ static u32 ccid3_first_li(struct sock *s
 	 * to give the equivalent of X_target = s/(2*R). Thus fval = 2 and so p
 	 * is about 20.64%. This yields an interval length of 4.84 (rounded up).
 	 */
-	if (unlikely(hcrx->feedback = TFRC_FBACK_NONE))
+	if (unlikely(hc->rx_feedback = TFRC_FBACK_NONE))
 		return 5;
 
-	x_recv = tfrc_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+	x_recv = tfrc_rx_hist_x_recv(&hc->rx_hist, hc->rx_x_recv);
 	if (x_recv = 0)
 		goto failed;
 
@@ -652,55 +652,55 @@ failed:
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
 	/*
 	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_rx_congestion_event(&hcrx->hist, &hcrx->li_hist,
+	if (tfrc_rx_congestion_event(&hc->rx_hist, &hc->rx_li_hist,
 				     skb, ndp, ccid3_first_li, sk))
 		ccid3_hc_rx_send_feedback(sk, skb, TFRC_FBACK_PARAM_CHANGE);
 	/*
 	 * Feedback for first non-empty data packet (RFC 3448, 6.3)
 	 */
-	else if (unlikely(hcrx->feedback = TFRC_FBACK_NONE && is_data_packet))
+	else if (unlikely(hc->rx_feedback = TFRC_FBACK_NONE && is_data_packet))
 		ccid3_hc_rx_send_feedback(sk, skb, TFRC_FBACK_INITIAL);
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	else if (!tfrc_rx_hist_loss_pending(&hcrx->hist) && is_data_packet &&
-		 SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
+	else if (!tfrc_rx_hist_loss_pending(&hc->rx_hist) && is_data_packet &&
+		 SUB16(dccp_hdr(skb)->dccph_ccval, hc->rx_last_counter) > 3)
 		ccid3_hc_rx_send_feedback(sk, skb, TFRC_FBACK_PERIODIC);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
+	struct tfrc_hc_rx_sock *hc = ccid_priv(ccid);
 
-	tfrc_lh_init(&hcrx->li_hist);
-	return tfrc_rx_hist_init(&hcrx->hist, sk);
+	tfrc_lh_init(&hc->rx_li_hist);
+	return tfrc_rx_hist_init(&hc->rx_hist, sk);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 
-	tfrc_rx_hist_purge(&hcrx->hist);
-	tfrc_lh_cleanup(&hcrx->li_hist);
+	tfrc_rx_hist_purge(&hc->rx_hist);
+	tfrc_lh_cleanup(&hc->rx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = tfrc_rx_hist_rtt(&tfrc_hc_rx_sk(sk)->hist);
+	info->tcpi_rcv_rtt  = tfrc_rx_hist_rtt(&tfrc_hc_rx_sk(sk)->rx_hist);
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 	struct tfrc_rx_info rx_info;
 	const void *val;
 
@@ -708,9 +708,9 @@ static int ccid3_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->x_recv;
-		rx_info.tfrcrx_rtt    = tfrc_rx_hist_rtt(&hcrx->hist);
-		rx_info.tfrcrx_p      = tfrc_invert_loss_event_rate(hcrx->p_inverse);
+		rx_info.tfrcrx_x_recv = hc->rx_x_recv;
+		rx_info.tfrcrx_rtt    = tfrc_rx_hist_rtt(&hc->rx_hist);
+		rx_info.tfrcrx_p      = tfrc_invert_loss_event_rate(hc->rx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -74,15 +74,15 @@ static int ccid4_osc_prev = true;
  * This respects the granularity of X (64 * bytes/second) and enforces the
  * scaled minimum of s * 64 / t_mbi = `s' bytes/second as per RFC 3448/4342.
  */
-static void ccid4_update_send_interval(struct tfrc_hc_tx_sock *hctx)
+static void ccid4_update_send_interval(struct tfrc_hc_tx_sock *hc)
 {
-	if (unlikely(hctx->x <= hctx->s))
-		hctx->x	= hctx->s;
-	hctx->t_ipi = scaled_div32(((u64)hctx->s) << 6, hctx->x);
+	if (unlikely(hc->tx_x <= hc->tx_s))
+		hc->tx_x = hc->tx_s;
+	hc->tx_t_ipi = scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 
 	/* TFRC-SP enforces a minimum interval of 10 milliseconds.  */
-	if (hctx->t_ipi < MIN_SEND_RATE)
-		hctx->t_ipi = MIN_SEND_RATE;
+	if (hc->tx_t_ipi < MIN_SEND_RATE)
+		hc->tx_t_ipi = MIN_SEND_RATE;
 }
 
 /**
@@ -97,9 +97,9 @@ static void ccid4_update_send_interval(s
  */
 static void ccid4_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	u64 min_rate = 2 * hctx->x_recv;
-	const u64 old_x = hctx->x;
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
+	u64 min_rate = 2 * hc->tx_x_recv;
+	const u64 old_x = hc->tx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -108,35 +108,35 @@ static void ccid4_hc_tx_update_x(struct 
 	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
+	if (tfrc_hc_tx_idle_rtt(hc, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->x_recv);
+		min_rate = max(min_rate, 2 * hc->tx_x_recv);
 	}
 
-	if (hctx->p > 0) {
+	if (hc->tx_p > 0) {
 
-		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
+		hc->tx_x = min(((u64)hc->tx_x_calc) << 6, min_rate);
 		/*
 		 * CCID-4 Header Penalty:
 		 * Adjust sending rate according to (TFRC-SP, Section 5)
 		 */
-		hctx->x = div_u64(hctx->x * hctx->s, hctx->s + CCID4HCTX_H);
+		hc->tx_x = div_u64(hc->tx_x * hc->tx_s, hc->tx_s + CCID4HCTX_H);
 
-	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
+	} else if (ktime_us_delta(now, hc->tx_t_ld) - (s64)hc->tx_rtt >= 0) {
 
-		hctx->x = min(2 * hctx->x, min_rate);
-		hctx->x = max(hctx->x,
-			      scaled_div(((u64)hctx->s) << 6, hctx->rtt));
-		hctx->t_ld = now;
+		hc->tx_x = min(2 * hc->tx_x, min_rate);
+		hc->tx_x = max(hc->tx_x,
+			      scaled_div(((u64)hc->tx_s) << 6, hc->tx_rtt));
+		hc->tx_t_ld = now;
 	}
 
-	if (hctx->x != old_x) {
+	if (hc->tx_x != old_x) {
 		ccid4_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->x >> 6), hctx->x_calc,
-			       (unsigned)(hctx->x_recv >> 6));
+			       (unsigned)(hc->tx_x >> 6), hc->tx_x_calc,
+			       (unsigned)(hc->tx_x_recv >> 6));
 
-		ccid4_update_send_interval(hctx);
+		ccid4_update_send_interval(hc);
 	}
 }
 
@@ -158,7 +158,7 @@ static u32 ccid4_hc_tx_measure_packet_si
 static void ccid4_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -169,24 +169,24 @@ static void ccid4_hc_tx_no_feedback_time
 	}
 
 	ccid4_pr_debug("%s(%p) entry with%s feedback\n", dccp_role(sk), sk,
-		       hctx->feedback ? "" : "out");
+		       hc->tx_feedback ? "" : "out");
 
 	/* Ignore and do not restart after leaving the established state */
 	if ((1 << sk->sk_state) & ~(DCCPF_OPEN | DCCPF_PARTOPEN))
 		goto out;
 
 	/* Reset feedback state to "no feedback received" */
-	hctx->feedback = false;
+	hc->tx_feedback = false;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 * RTO is 0 if and only if no feedback has been received yet.
 	 */
-	if (hctx->t_rto = 0 || hctx->p = 0) {
+	if (hc->tx_t_rto = 0 || hc->tx_p = 0) {
 
 		/* halve send rate directly */
-		hctx->x /= 2;
-		ccid4_update_send_interval(hctx);
+		hc->tx_x /= 2;
+		ccid4_update_send_interval(hc);
 
 	} else {
 		/*
@@ -199,30 +199,30 @@ static void ccid4_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->p && !hctx->x_calc);
+		BUG_ON(hc->tx_p && !hc->tx_x_calc);
 
-		if (hctx->x_calc > (hctx->x_recv >> 5))
-			hctx->x_recv /= 2;
+		if (hc->tx_x_calc > (hc->tx_x_recv >> 5))
+			hc->tx_x_recv /= 2;
 		else {
-			hctx->x_recv = hctx->x_calc;
-			hctx->x_recv <<= 4;
+			hc->tx_x_recv = hc->tx_x_calc;
+			hc->tx_x_recv <<= 4;
 		}
 		ccid4_hc_tx_update_x(sk, NULL);
 	}
 	ccid4_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->x);
+			(unsigned long long)hc->tx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->t_rto = 0))		/* no feedback received yet */
+	if (unlikely(hc->tx_t_rto = 0))		/* no feedback received yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->t_rto, 2 * hctx->t_ipi);
+		t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->no_feedback_timer,
+	sk_reset_timer(sk, &hc->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -238,7 +238,7 @@ out:
 static int ccid4_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delay;
 
@@ -250,14 +250,14 @@ static int ccid4_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	if (hctx->s = 0) {
-		sk_reset_timer(sk, &hctx->no_feedback_timer, (jiffies +
+	if (hc->tx_s = 0) {
+		sk_reset_timer(sk, &hc->tx_no_feedback_timer, (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->last_win_count   = 0;
-		hctx->t_last_win_count = now;
+		hc->tx_last_win_count   = 0;
+		hc->tx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->t_nom = now;
+		hc->tx_t_nom = now;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -266,9 +266,9 @@ static int ccid4_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid4_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->rtt  = dp->dccps_syn_rtt;
-			hctx->x    = rfc3390_initial_rate(sk);
-			hctx->t_ld = now;
+			hc->tx_rtt  = dp->dccps_syn_rtt;
+			hc->tx_x    = rfc3390_initial_rate(sk);
+			hc->tx_t_ld = now;
 		} else {
 			/*
 			 * Sender does not have RTT sample:
@@ -276,20 +276,20 @@ static int ccid4_hc_tx_send_packet(struc
 			 *   is needed in several parts (e.g.  window counter);
 			 * - set sending rate X_pps = 1pps as per RFC 3448, 4.2.
 			 */
-			hctx->rtt = DCCP_FALLBACK_RTT;
-			hctx->x	  = dp->dccps_mss_cache;
-			hctx->x <<= 6;
+			hc->tx_rtt = DCCP_FALLBACK_RTT;
+			hc->tx_x	  = dp->dccps_mss_cache;
+			hc->tx_x <<= 6;
 		}
 
 		/* Compute t_ipi = s / X */
-		hctx->s = ccid4_hc_tx_measure_packet_size(sk, skb->len);
-		ccid4_update_send_interval(hctx);
+		hc->tx_s = ccid4_hc_tx_measure_packet_size(sk, skb->len);
+		ccid4_update_send_interval(hc);
 
 		/* Seed value for Oscillation Prevention (sec. 4.5) */
-		hctx->r_sqmean = tfrc_scaled_sqrt(hctx->rtt);
+		hc->tx_r_sqmean = tfrc_scaled_sqrt(hc->tx_rtt);
 
 	} else {
-		delay = ktime_us_delta(hctx->t_nom, now);
+		delay = ktime_us_delta(hc->tx_t_nom, now);
 		ccid4_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -302,38 +302,38 @@ static int ccid4_hc_tx_send_packet(struc
 		if (delay >= TFRC_T_DELTA)
 			return (u32)delay / USEC_PER_MSEC;
 
-		tfrc_sp_hc_tx_update_win_count(hctx, now);
+		tfrc_sp_hc_tx_update_win_count(hc, now);
 	}
 
 	if (dccp_data_packet(skb))
 		DCCP_SKB_CB(skb)->dccpd_ecn -			tfrc_sp_get_random_ect(&hctx->li_data,
+			tfrc_sp_get_random_ect(&hc->tx_li_data,
 					       DCCP_SKB_CB(skb)->dccpd_seq);
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval  = hctx->last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval  = hc->tx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->t_nom = ktime_add_us(hctx->t_nom, hctx->t_ipi);
+	hc->tx_t_nom = ktime_add_us(hc->tx_t_nom, hc->tx_t_ipi);
 	return CCID_PACKET_SEND_AT_ONCE;
 }
 
 static void ccid4_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 
 	/* Changes to s will become effective the next time X is computed */
-	hctx->s = ccid4_hc_tx_measure_packet_size(sk, len);
+	hc->tx_s = ccid4_hc_tx_measure_packet_size(sk, len);
 
-	if (tfrc_sp_tx_hist_add(&hctx->hist, dccp_sk(sk)->dccps_gss,
-		hctx->last_win_count))
+	if (tfrc_sp_tx_hist_add(&hc->tx_hist, dccp_sk(sk)->dccps_gss,
+		hc->tx_last_win_count))
 			DCCP_CRIT("packet history - out of memory!");
 }
 
 static void ccid4_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	struct tfrc_tx_hist_entry *acked, *old;
 	ktime_t now;
 	unsigned long t_nfb;
@@ -351,11 +351,11 @@ static void ccid4_hc_tx_packet_recv(stru
 	 *  - the Ack is outdated (packet with higher Ack number was received),
 	 *  - it is a bogus Ack (for a packet not sent on this connection).
 	 */
-	acked = tfrc_tx_hist_find_entry(hctx->hist, dccp_hdr_ack_seq(skb));
+	acked = tfrc_tx_hist_find_entry(hc->tx_hist, dccp_hdr_ack_seq(skb));
 	if (acked = NULL)
 		return;
 	/* For the sake of RTT sampling, ignore/remove all older entries */
-	old = tfrc_tx_hist_two_rtt_old(hctx->hist,
+	old = tfrc_tx_hist_two_rtt_old(hc->tx_hist,
 				       DCCP_SKB_CB(skb)->dccpd_ccval);
 	if (old != NULL)
 		tfrc_sp_tx_hist_purge(&old->next);
@@ -363,25 +363,25 @@ static void ccid4_hc_tx_packet_recv(stru
 	/* Update the moving average for the RTT estimate (RFC 3448, 4.3) */
 	now	  = ktime_get_real();
 	r_sample  = dccp_sample_rtt(sk, ktime_us_delta(now, acked->stamp));
-	hctx->rtt = tfrc_ewma(hctx->rtt, r_sample, 9);
+	hc->tx_rtt = tfrc_ewma(hc->tx_rtt, r_sample, 9);
 
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (!hctx->feedback) {
-		hctx->feedback = true;
+	if (!hc->tx_feedback) {
+		hc->tx_feedback = true;
 
-		if (hctx->t_rto = 0) {
+		if (hc->tx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->x    = rfc3390_initial_rate(sk);
-			hctx->t_ld = now;
+			hc->tx_x    = rfc3390_initial_rate(sk);
+			hc->tx_t_ld = now;
 
-			ccid4_update_send_interval(hctx);
+			ccid4_update_send_interval(hc);
 
 			goto done_computing_x;
-		} else if (hctx->p = 0) {
+		} else if (hc->tx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -390,17 +390,17 @@ static void ccid4_hc_tx_packet_recv(stru
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->p > 0)
-		hctx->x_calc = tfrc_sp_calc_x(NOM_PACKET_SIZE, hctx->rtt, hctx->p);
+	if (hc->tx_p > 0)
+		hc->tx_x_calc = tfrc_sp_calc_x(NOM_PACKET_SIZE, hc->tx_rtt, hc->tx_p);
 	ccid4_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid4_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-			       dccp_role(sk), sk, hctx->rtt, r_sample,
-			       hctx->s, hctx->p, hctx->x_calc,
-			       (unsigned)(hctx->x_recv >> 6),
-			       (unsigned)(hctx->x >> 6));
+			       dccp_role(sk), sk, hc->tx_rtt, r_sample,
+			       hc->tx_s, hc->tx_p, hc->tx_x_calc,
+			       (unsigned)(hc->tx_x_recv >> 6),
+			       (unsigned)(hc->tx_x >> 6));
 	/*
 	 * Oscillation Reduction (RFC 3448, 4.5) - modifying t_ipi according to
 	 * RTT changes, multiplying by X/X_inst = sqrt(R_sample)/R_sqmean. This
@@ -426,16 +426,16 @@ done_computing_x:
 		 * naturally increases, where using the algorithm would cause
 		 * delays. Hence it is disabled during the initial slow-start.
 		 */
-		if (r_sample > hctx->r_sqmean && hctx->p > 0)
-			hctx->t_ipi = div_u64((u64)hctx->t_ipi * (u64)r_sample,
-					      hctx->r_sqmean);
-		hctx->t_ipi = min_t(u32, hctx->t_ipi, TFRC_T_MBI);
+		if (r_sample > hc->tx_r_sqmean && hc->tx_p > 0)
+			hc->tx_t_ipi = div_u64((u64)hc->tx_t_ipi * (u64)r_sample,
+					      hc->tx_r_sqmean);
+		hc->tx_t_ipi = min_t(u32, hc->tx_t_ipi, TFRC_T_MBI);
 		/* update R_sqmean _after_ computing the modulation factor */
-		hctx->r_sqmean = tfrc_ewma(hctx->r_sqmean, r_sample, 9);
+		hc->tx_r_sqmean = tfrc_ewma(hc->tx_r_sqmean, r_sample, 9);
 	}
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->no_feedback_timer);
+	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -449,26 +449,26 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->t_rto = max_t(u32, 4 * hctx->rtt, (CONFIG_IP_DCCP_CCID4_RTO *
+	hc->tx_t_rto = max_t(u32, 4 * hc->tx_rtt, (CONFIG_IP_DCCP_CCID4_RTO *
 						 (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->t_rto, 2 * hctx->t_ipi);
+	t_nfb = max(hc->tx_t_rto, 2 * hc->tx_t_ipi);
 
 	ccid4_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
 		       dccp_role(sk), sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->no_feedback_timer,
+	sk_reset_timer(sk, &hc->tx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
 static int ccid4_hc_tx_parse_options(struct sock *sk, u8 packet_type,
 				     u8 option, u8 *optval, u8 optlen)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	struct sk_buff *skb;
 	u32 new_p;
 	__be32 opt_val;
@@ -488,21 +488,21 @@ static int ccid4_hc_tx_parse_options(str
 
 		if (option = TFRC_OPT_RECEIVE_RATE) {
 			/* Receive Rate is kept in units of 64 bytes/second */
-			hctx->x_recv = opt_val;
-			hctx->x_recv <<= 6;
+			hc->tx_x_recv = opt_val;
+			hc->tx_x_recv <<= 6;
 
 			ccid4_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		} else {
 			/* Update the fixpoint Loss Event Rate fraction */
-			hctx->p = tfrc_sp_invert_loss_event_rate(opt_val);
+			hc->tx_p = tfrc_sp_invert_loss_event_rate(opt_val);
 
 			ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk, opt_val);
 		}
 		break;
 	case TFRC_OPT_DROPPED_PACKETS:
-		tfrc_sp_parse_dropped_packets_opt(&hctx->li_data,
+		tfrc_sp_parse_dropped_packets_opt(&hc->tx_li_data,
 						  optval, optlen);
 
 		skb = skb_peek(&sk->sk_receive_queue);
@@ -510,7 +510,7 @@ static int ccid4_hc_tx_parse_options(str
 		if (skb = NULL)
 			break;
 
-		if (!tfrc_sp_check_ecn_sum(&hctx->li_data,
+		if (!tfrc_sp_check_ecn_sum(&hc->tx_li_data,
 					   optval, optlen, skb)) {
 			/*
 			 * TODO: consider ecn sum test fail
@@ -519,11 +519,11 @@ static int ccid4_hc_tx_parse_options(str
 		}
 
 		new_p -		tfrc_sp_p_from_loss_intervals_opt(&hctx->li_data,
-						  hctx->hist,
-						  hctx->last_win_count,
+		tfrc_sp_p_from_loss_intervals_opt(&hc->tx_li_data,
+						  hc->tx_hist,
+						  hc->tx_last_win_count,
 						  DCCP_SKB_CB(skb)->dccpd_seq);
-		if (hctx->p != new_p) {
+		if (hc->tx_p != new_p) {
 			/*
 			 * TODO: use p value obtained
 			 * from loss intervals option
@@ -533,8 +533,8 @@ static int ccid4_hc_tx_parse_options(str
 		break;
 	case TFRC_OPT_LOSS_INTERVALS:
 
-		hctx->li_data.skip_length = *optval;
-		tfrc_sp_parse_loss_intervals_opt(&hctx->li_data,
+		hc->tx_li_data.skip_length = *optval;
+		tfrc_sp_parse_loss_intervals_opt(&hc->tx_li_data,
 						 optval, optlen);
 
 		skb = skb_peek(&sk->sk_receive_queue);
@@ -542,7 +542,7 @@ static int ccid4_hc_tx_parse_options(str
 		if (skb = NULL)
 			break;
 
-		if (!tfrc_sp_check_ecn_sum(&hctx->li_data,
+		if (!tfrc_sp_check_ecn_sum(&hc->tx_li_data,
 					   optval, optlen, skb)) {
 			/*
 			 * TODO: consider ecn sum test fail
@@ -551,11 +551,11 @@ static int ccid4_hc_tx_parse_options(str
 		}
 
 		new_p -		tfrc_sp_p_from_loss_intervals_opt(&hctx->li_data,
-						  hctx->hist,
-						  hctx->last_win_count,
+		tfrc_sp_p_from_loss_intervals_opt(&hc->tx_li_data,
+						  hc->tx_hist,
+						  hc->tx_last_win_count,
 						  DCCP_SKB_CB(skb)->dccpd_seq);
-		if (hctx->p != new_p) {
+		if (hc->tx_p != new_p) {
 			/*
 			 * TODO: use p value obtained
 			 * from loss intervals option
@@ -568,33 +568,33 @@ static int ccid4_hc_tx_parse_options(str
 
 static int ccid4_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct tfrc_hc_tx_sock *hc = ccid_priv(ccid);
 
-	hctx->hist  = NULL;
-	setup_timer(&hctx->no_feedback_timer,
+	hc->tx_hist  = NULL;
+	setup_timer(&hc->tx_no_feedback_timer,
 		    ccid4_hc_tx_no_feedback_timer, (unsigned long)sk);
 	return 0;
 }
 
 static void ccid4_hc_tx_exit(struct sock *sk)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 
-	sk_stop_timer(sk, &hctx->no_feedback_timer);
-	tfrc_sp_tx_hist_purge(&hctx->hist);
-	tfrc_sp_tx_ld_cleanup(&hctx->li_data.ecn_sums_head);
+	sk_stop_timer(sk, &hc->tx_no_feedback_timer);
+	tfrc_sp_tx_hist_purge(&hc->tx_hist);
+	tfrc_sp_tx_ld_cleanup(&hc->tx_li_data.ecn_sums_head);
 }
 
 static void ccid4_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = tfrc_hc_tx_sk(sk)->t_rto;
-	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->rtt;
+	info->tcpi_rto = tfrc_hc_tx_sk(sk)->tx_t_rto;
+	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->tx_rtt;
 }
 
 static int ccid4_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	const struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 	struct tfrc_tx_info tfrc;
 	const void *val;
 
@@ -602,13 +602,13 @@ static int ccid4_hc_tx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(tfrc))
 			return -EINVAL;
-		tfrc.tfrctx_x	   = hctx->x;
-		tfrc.tfrctx_x_recv = hctx->x_recv;
-		tfrc.tfrctx_x_calc = hctx->x_calc;
-		tfrc.tfrctx_rtt	   = hctx->rtt;
-		tfrc.tfrctx_p	   = hctx->p;
-		tfrc.tfrctx_rto	   = hctx->t_rto;
-		tfrc.tfrctx_ipi	   = hctx->t_ipi;
+		tfrc.tfrctx_x	   = hc->tx_x;
+		tfrc.tfrctx_x_recv = hc->tx_x_recv;
+		tfrc.tfrctx_x_calc = hc->tx_x_calc;
+		tfrc.tfrctx_rtt	   = hc->tx_rtt;
+		tfrc.tfrctx_p	   = hc->tx_p;
+		tfrc.tfrctx_rto	   = hc->tx_t_rto;
+		tfrc.tfrctx_ipi	   = hc->tx_t_ipi;
 		len = sizeof(tfrc);
 		val = &tfrc;
 		break;
@@ -629,15 +629,15 @@ static void ccid4_hc_rx_send_feedback(st
 				      const struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 
 	switch (fbtype) {
 	case TFRC_FBACK_INITIAL:
-		hcrx->x_recv = 0;
-		hcrx->p_inverse = ~0U;   /* see RFC 4342, 8.5 */
+		hc->rx_x_recv = 0;
+		hc->rx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
 		break;
 	case TFRC_FBACK_PARAM_CHANGE:
-		if (unlikely(hcrx->feedback = TFRC_FBACK_NONE)) {
+		if (unlikely(hc->rx_feedback = TFRC_FBACK_NONE)) {
 			/*
 			 * rfc3448bis-06, 6.3.1: First packet(s) lost or marked
 			 * FIXME: in rfc3448bis the receiver returns X_recv=0
@@ -650,10 +650,10 @@ static void ccid4_hc_rx_send_feedback(st
 			 * would bring X down to s/t_mbi. That is why we return
 			 * X_recv according to rfc3448bis-06 for the moment.
 			 */
-			u32 s = tfrc_rx_hist_packet_size(&hcrx->hist),
-			    rtt = tfrc_rx_hist_rtt(&hcrx->hist);
+			u32 s = tfrc_rx_hist_packet_size(&hc->rx_hist),
+			    rtt = tfrc_rx_hist_rtt(&hc->rx_hist);
 
-			hcrx->x_recv = scaled_div32(s, 2 * rtt);
+			hc->rx_x_recv = scaled_div32(s, 2 * rtt);
 			break;
 		}
 		/*
@@ -661,7 +661,7 @@ static void ccid4_hc_rx_send_feedback(st
 		 * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
 		 * always check whether at least RTT time units were covered.
 		 */
-		hcrx->x_recv = tfrc_sp_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		hc->rx_x_recv = tfrc_sp_rx_hist_x_recv(&hc->rx_hist, hc->rx_x_recv);
 		break;
 	case TFRC_FBACK_PERIODIC:
 		/*
@@ -669,29 +669,29 @@ static void ccid4_hc_rx_send_feedback(st
 		 * - if no data packets have been received, just restart timer
 		 * - if data packets have been received, re-compute X_recv
 		 */
-		if (hcrx->hist.bytes_recvd = 0)
+		if (hc->rx_hist.bytes_recvd = 0)
 			goto prepare_for_next_time;
-		hcrx->x_recv = tfrc_sp_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+		hc->rx_x_recv = tfrc_sp_rx_hist_x_recv(&hc->rx_hist, hc->rx_x_recv);
 		break;
 	default:
 		return;
 	}
 
-	ccid4_pr_debug("X_recv=%u, 1/p=%u\n", hcrx->x_recv, hcrx->p_inverse);
+	ccid4_pr_debug("X_recv=%u, 1/p=%u\n", hc->rx_x_recv, hc->rx_pinv);
 
 	dccp_sk(sk)->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
 
 prepare_for_next_time:
-	tfrc_rx_hist_restart_byte_counter(&hcrx->hist);
-	hcrx->last_counter = dccp_hdr(skb)->dccph_ccval;
-	hcrx->feedback	   = fbtype;
+	tfrc_rx_hist_restart_byte_counter(&hc->rx_hist);
+	hc->rx_last_counter = dccp_hdr(skb)->dccph_ccval;
+	hc->rx_feedback	   = fbtype;
 }
 
 static int ccid4_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
 	u16 dropped_length, loss_intervals_length;
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
@@ -700,27 +700,27 @@ static int ccid4_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->x_recv);
-	pinv   = htonl(hcrx->p_inverse);
+	x_recv = htonl(hc->rx_x_recv);
+	pinv   = htonl(hc->rx_pinv);
 
 	loss_intervals_length	-		(hcrx->li_data.counter > TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH) ?
-		 TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH : hcrx->li_data.counter;
+		(hc->rx_li_data.counter > TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH) ?
+		 TFRC_LOSS_INTERVALS_OPT_MAX_LENGTH : hc->rx_li_data.counter;
 	dropped_length		-		(hcrx->li_data.counter > TFRC_DROP_OPT_MAX_LENGTH) ?
-		 TFRC_DROP_OPT_MAX_LENGTH : hcrx->li_data.counter;
+		(hc->rx_li_data.counter > TFRC_DROP_OPT_MAX_LENGTH) ?
+		 TFRC_DROP_OPT_MAX_LENGTH : hc->rx_li_data.counter;
 
-	tfrc_sp_ld_prepare_data(hcrx->hist.loss_count, &hcrx->li_data);
+	tfrc_sp_ld_prepare_data(hc->rx_hist.loss_count, &hc->rx_li_data);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
 			       &x_recv, sizeof(x_recv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_INTERVALS,
-			       &hcrx->li_data.loss_intervals_opts[0],
+			       &hc->rx_li_data.loss_intervals_opts[0],
 			       1 + loss_intervals_length*9) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_DROPPED_PACKETS,
-			       &hcrx->li_data.drop_opts[0], dropped_length*3))
+			       &hc->rx_li_data.drop_opts[0], dropped_length*3))
 		return -1;
 
 	return 0;
@@ -737,8 +737,8 @@ static int ccid4_hc_rx_insert_options(st
  */
 static u32 ccid4_first_li(struct sock *sk)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	u32 rtt = tfrc_rx_hist_rtt(&hcrx->hist), x_recv, p;
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
+	u32 rtt = tfrc_rx_hist_rtt(&hc->rx_hist), x_recv, p;
 	u64 fval;
 
 	/*
@@ -746,10 +746,10 @@ static u32 ccid4_first_li(struct sock *s
 	 * to give the equivalent of X_target = s/(2*R). Thus fval = 2 and so p
 	 * is about 20.64%. This yields an interval length of 4.84 (rounded up).
 	 */
-	if (unlikely(hcrx->feedback = TFRC_FBACK_NONE))
+	if (unlikely(hc->rx_feedback = TFRC_FBACK_NONE))
 		return 5;
 
-	x_recv = tfrc_sp_rx_hist_x_recv(&hcrx->hist, hcrx->x_recv);
+	x_recv = tfrc_sp_rx_hist_x_recv(&hc->rx_hist, hc->rx_x_recv);
 	if (x_recv = 0)
 		goto failed;
 
@@ -767,59 +767,59 @@ failed:
 
 static void ccid4_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
 	/*
 	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_sp_rx_congestion_event(&hcrx->hist, &hcrx->li_hist,
-					&hcrx->li_data,
+	if (tfrc_sp_rx_congestion_event(&hc->rx_hist, &hc->rx_li_hist,
+					&hc->rx_li_data,
 					skb, ndp, ccid4_first_li, sk))
 		ccid4_hc_rx_send_feedback(sk, skb, TFRC_FBACK_PARAM_CHANGE);
 	/*
 	 * Feedback for first non-empty data packet (RFC 3448, 6.3)
 	 */
-	else if (unlikely(hcrx->feedback = TFRC_FBACK_NONE && is_data_packet))
+	else if (unlikely(hc->rx_feedback = TFRC_FBACK_NONE && is_data_packet))
 		ccid4_hc_rx_send_feedback(sk, skb, TFRC_FBACK_INITIAL);
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	else if (!tfrc_rx_hist_loss_pending(&hcrx->hist) && is_data_packet &&
-		 SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
+	else if (!tfrc_rx_hist_loss_pending(&hc->rx_hist) && is_data_packet &&
+		 SUB16(dccp_hdr(skb)->dccph_ccval, hc->rx_last_counter) > 3)
 		ccid4_hc_rx_send_feedback(sk, skb, TFRC_FBACK_PERIODIC);
 }
 
 static int ccid4_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
+	struct tfrc_hc_rx_sock *hc = ccid_priv(ccid);
 
-	tfrc_lh_init(&hcrx->li_hist);
-	tfrc_ld_init(&hcrx->li_data);
+	tfrc_lh_init(&hc->rx_li_hist);
+	tfrc_ld_init(&hc->rx_li_data);
 
-	return tfrc_sp_rx_hist_init(&hcrx->hist, sk);
+	return tfrc_sp_rx_hist_init(&hc->rx_hist, sk);
 }
 
 static void ccid4_hc_rx_exit(struct sock *sk)
 {
-	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 
-	tfrc_sp_rx_hist_purge(&hcrx->hist);
-	tfrc_sp_lh_cleanup(&hcrx->li_hist);
-	tfrc_sp_ld_cleanup(&hcrx->li_data);
+	tfrc_sp_rx_hist_purge(&hc->rx_hist);
+	tfrc_sp_lh_cleanup(&hc->rx_li_hist);
+	tfrc_sp_ld_cleanup(&hc->rx_li_data);
 }
 
 static void ccid4_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = tfrc_rx_hist_rtt(&tfrc_hc_rx_sk(sk)->hist);
+	info->tcpi_rcv_rtt  = tfrc_rx_hist_rtt(&tfrc_hc_rx_sk(sk)->rx_hist);
 }
 
 static int ccid4_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hc = tfrc_hc_rx_sk(sk);
 	struct tfrc_rx_info rx_info;
 	const void *val;
 
@@ -827,9 +827,9 @@ static int ccid4_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->x_recv;
-		rx_info.tfrcrx_rtt    = tfrc_rx_hist_rtt(&hcrx->hist);
-		rx_info.tfrcrx_p      = tfrc_sp_invert_loss_event_rate(hcrx->p_inverse);
+		rx_info.tfrcrx_x_recv = hc->rx_x_recv;
+		rx_info.tfrcrx_rtt    = tfrc_rx_hist_rtt(&hc->rx_hist);
+		rx_info.tfrcrx_p      = tfrc_sp_invert_loss_event_rate(hc->rx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
--- a/net/dccp/ccids/lib/tfrc_ccids.c
+++ b/net/dccp/ccids/lib/tfrc_ccids.c
@@ -15,27 +15,27 @@
  *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
  *	As elsewhere, RTT > 0 is assumed by using dccp_sample_rtt().
  */
-void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx, ktime_t now)
+void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hc, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->t_last_win_count),
-	    quarter_rtts = (4 * delta) / hctx->rtt;
+	u32 delta = ktime_us_delta(now, hc->tx_t_last_win_count),
+	    quarter_rtts = (4 * delta) / hc->tx_rtt;
 
 	if (quarter_rtts > 0) {
-		hctx->t_last_win_count = now;
-		hctx->last_win_count  += min(quarter_rtts, 5U);
-		hctx->last_win_count  &= 0xF;		/* mod 16 */
+		hc->tx_t_last_win_count = now;
+		hc->tx_last_win_count  += min(quarter_rtts, 5U);
+		hc->tx_last_win_count  &= 0xF;		/* mod 16 */
 	}
 }
 
 size_t tfrc_hc_tx_probe(struct sock *sk, char *buf, const size_t maxlen)
 {
-	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hc = tfrc_hc_tx_sk(sk);
 
 	/* Specific field numbering:
 			5   6     7   8        9        10   11
 			s   rtt   p   X_calc   X_recv   X    t_ipi  */
 	return snprintf(buf, maxlen, " %d %d %d %u %u %u %d",
-			hctx->s, hctx->rtt, hctx->p, hctx->x_calc,
-			(unsigned)(hctx->x_recv >> 6),
-			(unsigned)(hctx->x >> 6), hctx->t_ipi);
+			hc->tx_s, hc->tx_rtt, hc->tx_p, hc->tx_x_calc,
+			(unsigned)(hc->tx_x_recv >> 6),
+			(unsigned)(hc->tx_x >> 6), hc->tx_t_ipi);
 }
--- a/net/dccp/ccids/lib/tfrc_ccids.h
+++ b/net/dccp/ccids/lib/tfrc_ccids.h
@@ -46,43 +46,44 @@ enum tfrc_options {
 	TFRC_OPT_DROPPED_PACKETS = 195,	/* as per ccid-4 draft, section 8 */
 };
 
-/** struct tfrc_hc_tx_sock - CCID3/4 sender half-connection socket
+/**
  *
- * @x - Current sending rate in 64 * bytes per second
- * @x_recv - Receive rate    in 64 * bytes per second
- * @x_calc - Calculated rate in bytes per second
- * @rtt - Estimate of current round trip time in usecs
- * @r_sqmean - Estimate of long-term RTT (RFC 3448, 4.5)
- * @p - Current loss event rate (0-1) scaled by 1000000
- * @t_rto - Nofeedback Timer setting in usecs
- * @t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @s - Packet size in bytes
- * @feedback - Whether feedback has been received or not
- * @last_win_count - Last window counter sent
- * @t_last_win_count - Timestamp of earliest packet with
- *                     last_win_count value sent
- * @no_feedback_timer - Handle to no feedback timer
- * @t_ld - Time last doubled during slow start
- * @t_nom - Nominal send time of next packet
- * @hist - Packet history
+ * struct tfrc_hc_tx_sock - CCID3/4 sender half-connection socket
+ * @tx_x:		  Current sending rate in 64 * bytes per second
+ * @tx_x_recv:		  Receive rate in 64 * bytes per second
+ * @tx_x_calc:		  Calculated rate in bytes per second
+ * @tx_rtt:		  Estimate of current round trip time in usecs
+ * @tx_r_sqmean:	  Estimate of long-term RTT (RFC 5348, 4.5)
+ * @tx_p:		  Current loss event rate (0-1) scaled by 1000000
+ * @tx_t_rto:		  Nofeedback Timer setting in usecs
+ * @tx_t_ipi:		  Interpacket (send) interval (RFC 3448, 4.6) in usecs
+ * @tx_s:		  Packet size in bytes
+ * @tx_feedback:	  Whether feedback has been received or not
+ * @tx_last_win_count:	  Last window counter sent
+ * @tx_t_last_win_count:  Timestamp of earliest packet
+ *			  with last_win_count value sent
+ * @tx_no_feedback_timer: Handle to no feedback timer
+ * @tx_t_ld:		  Time last doubled during slow start
+ * @tx_t_nom:		  Nominal send time of next packet
+ * @tx_hist:		  Packet history
  */
 struct tfrc_hc_tx_sock {
-	u64				x;
-	u64				x_recv;
-	u32				x_calc;
-	u32				rtt;
-	u16				r_sqmean;
-	u32				p;
-	u32				t_rto;
-	u32				t_ipi;
-	u16				s;
-	bool				feedback:1;
-	u8				last_win_count;
-	ktime_t				t_last_win_count;
-	struct timer_list		no_feedback_timer;
-	ktime_t				t_ld;
-	ktime_t				t_nom;
-	struct tfrc_tx_hist_entry	*hist;
+	u64				tx_x;
+	u64				tx_x_recv;
+	u32				tx_x_calc;
+	u32				tx_rtt;
+	u16				tx_r_sqmean;
+	u32				tx_p;
+	u32				tx_t_rto;
+	u32				tx_t_ipi;
+	u16				tx_s;
+	bool				tx_feedback:1;
+	u8				tx_last_win_count;
+	ktime_t				tx_t_last_win_count;
+	struct timer_list		tx_no_feedback_timer;
+	ktime_t				tx_t_ld;
+	ktime_t				tx_t_nom;
+	struct tfrc_tx_hist_entry	*tx_hist;
 };
 
 static inline struct tfrc_hc_tx_sock *tfrc_hc_tx_sk(const struct sock *sk)
@@ -104,10 +105,10 @@ static inline u64 rfc3390_initial_rate(s
 	const u32 mps = dccp_sk(sk)->dccps_mss_cache,
 	       w_init = clamp(4380U, 2 * mps, 4 * mps);
 
-	return scaled_div(w_init << 6, tfrc_hc_tx_sk(sk)->rtt);
+	return scaled_div(w_init << 6, tfrc_hc_tx_sk(sk)->tx_rtt);
 }
 
-extern void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
+extern void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hc,
 					ktime_t now);
 
 extern size_t tfrc_hc_tx_probe(struct sock *sk, char *buf, const size_t maxlen);
@@ -120,24 +121,25 @@ enum tfrc_fback_type {
 	TFRC_FBACK_PARAM_CHANGE
 };
 
-/** struct tfrc_hc_rx_sock - CCID3/4 receiver half-connection socket
+/**
  *
- *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @feedback  -  The type of the feedback last sent
- *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @tstamp_last_feedback  -  Time at which last feedback was sent
- *  @hist  -  Packet history (loss detection + RTT sampling)
- *  @li_hist  -  Loss Interval database
- *  @p_inverse  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ * struct tfrc_hc_rx_sock - CCID3/4 receiver half-connection socket
+ * @rx_last_counter:	     Tracks window counter (RFC 4342, 8.1)
+ * @rx_feedback:	     The type of the feedback last sent
+ * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ * @rx_tstamp_last_feedback: Time at which last feedback was sent
+ * @rx_hist:		     Packet history (loss detection + RTT sampling)
+ * @rx_li_hist:		     Loss Interval database
+ * @rx_pinv:		     Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct tfrc_hc_rx_sock {
-	u8				last_counter:4;
-	enum tfrc_fback_type		feedback:4;
-	u32				x_recv;
-	ktime_t				tstamp_last_feedback;
-	struct tfrc_rx_hist		hist;
-	struct tfrc_loss_hist		li_hist;
-#define p_inverse			li_hist.i_mean
+	u8				rx_last_counter:4;
+	enum tfrc_fback_type		rx_feedback:4;
+	u32				rx_x_recv;
+	ktime_t				rx_tstamp_last_feedback;
+	struct tfrc_rx_hist		rx_hist;
+	struct tfrc_loss_hist		rx_li_hist;
+#define rx_pinv				rx_li_hist.i_mean
 };
 
 static inline struct tfrc_hc_rx_sock *tfrc_hc_rx_sk(const struct sock *sk)
@@ -147,10 +149,10 @@ static inline struct tfrc_hc_rx_sock *tf
 	return hcrx;
 }
 
-static inline u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now)
+static inline u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hc, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->t_last_win_count);
+	u32 delta = ktime_us_delta(now, hc->tx_t_last_win_count);
 
-	return delta / hctx->rtt;
+	return delta / hc->tx_rtt;
 }
 #endif /* _TFRC_CCIDS_H_ */
--- a/net/dccp/ccids/lib/tfrc_ccids_sp.h
+++ b/net/dccp/ccids/lib/tfrc_ccids_sp.h
@@ -49,43 +49,43 @@ enum tfrc_options {
 
 /**
  * struct tfrc_hc_tx_sock - CCID3/4 sender half-connection socket
- *
- * @x - Current sending rate in 64 * bytes per second
- * @x_recv - Receive rate    in 64 * bytes per second
- * @x_calc - Calculated rate in bytes per second
- * @rtt - Estimate of current round trip time in usecs
- * @r_sqmean - Estimate of long-term RTT (RFC 3448, 4.5)
- * @p - Current loss event rate (0-1) scaled by 1000000
- * @t_rto - Nofeedback Timer setting in usecs
- * @t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @s - Packet size in bytes
- * @feedback - Whether feedback has been received or not
- * @last_win_count - Last window counter sent
- * @t_last_win_count - Timestamp of earliest packet with
- *                     last_win_count value sent
- * @no_feedback_timer - Handle to no feedback timer
- * @t_ld - Time last doubled during slow start
- * @t_nom - Nominal send time of next packet
- * @hist - Packet history
+ * @tx_x:		  Current sending rate in 64 * bytes per second
+ * @tx_x_recv:		  Receive rate in 64 * bytes per second
+ * @tx_x_calc:		  Calculated rate in bytes per second
+ * @tx_rtt:		  Estimate of current round trip time in usecs
+ * @tx_r_sqmean:	  Estimate of long-term RTT (RFC 5348, 4.5)
+ * @tx_p:		  Current loss event rate (0-1) scaled by 1000000
+ * @tx_t_rto:		  Nofeedback Timer setting in usecs
+ * @tx_t_ipi:		  Interpacket (send) interval (RFC 3448, 4.6) in usecs
+ * @tx_s:		  Packet size in bytes
+ * @tx_feedback:	  Whether feedback has been received or not
+ * @tx_last_win_count:	  Last window counter sent
+ * @tx_t_last_win_count:  Timestamp of earliest packet
+ *			  with last_win_count value sent
+ * @tx_no_feedback_timer: Handle to no feedback timer
+ * @tx_t_ld:		  Time last doubled during slow start
+ * @tx_t_nom:		  Nominal send time of next packet
+ * @tx_hist:		  Packet history
+ * @tx_li_data:		  FIXME
  */
 struct tfrc_hc_tx_sock {
-	u64				x;
-	u64				x_recv;
-	u32				x_calc;
-	u32				rtt;
-	u16				r_sqmean;
-	u32				p;
-	u32				t_rto;
-	u32				t_ipi;
-	u16				s;
-	bool				feedback:1;
-	u8				last_win_count;
-	ktime_t				t_last_win_count;
-	struct timer_list		no_feedback_timer;
-	ktime_t				t_ld;
-	ktime_t				t_nom;
-	struct tfrc_tx_hist_entry	*hist;
-	struct tfrc_tx_li_data		li_data;
+	u64				tx_x;
+	u64				tx_x_recv;
+	u32				tx_x_calc;
+	u32				tx_rtt;
+	u16				tx_r_sqmean;
+	u32				tx_p;
+	u32				tx_t_rto;
+	u32				tx_t_ipi;
+	u16				tx_s;
+	bool				tx_feedback:1;
+	u8				tx_last_win_count;
+	ktime_t				tx_t_last_win_count;
+	struct timer_list		tx_no_feedback_timer;
+	ktime_t				tx_t_ld;
+	ktime_t				tx_t_nom;
+	struct tfrc_tx_hist_entry	*tx_hist;
+	struct tfrc_tx_li_data		tx_li_data;
 };
 
 static inline struct tfrc_hc_tx_sock *tfrc_hc_tx_sk(const struct sock *sk)
@@ -107,7 +107,7 @@ static inline u64 rfc3390_initial_rate(s
 	const u32 mps = dccp_sk(sk)->dccps_mss_cache,
 	       w_init = clamp(4380U, 2 * mps, 4 * mps);
 
-	return scaled_div(w_init << 6, tfrc_hc_tx_sk(sk)->rtt);
+	return scaled_div(w_init << 6, tfrc_hc_tx_sk(sk)->tx_rtt);
 }
 
 extern void tfrc_sp_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
@@ -127,24 +127,24 @@ enum tfrc_fback_type {
 /**
  * struct tfrc_hc_rx_sock - CCID3/4 receiver half-connection socket
  *
- *  @last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @feedback  -  The type of the feedback last sent
- *  @x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @tstamp_last_feedback  -  Time at which last feedback was sent
- *  @hist  -  Packet history (loss detection + RTT sampling)
- *  @li_hist  -  Loss Interval database
- *  @p_inverse  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
- *  @li_data  -  loss interval data for options
+ * @rx_last_counter:	     Tracks window counter (RFC 4342, 8.1)
+ * @rx_feedback:	     The type of the feedback last sent
+ * @rx_x_recv:		     Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ * @rx_tstamp_last_feedback: Time at which last feedback was sent
+ * @rx_hist:		     Packet history (loss detection + RTT sampling)
+ * @rx_li_hist:		     Loss Interval database
+ * @rx_pinv:		     Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ * @rx_li_data:		     Loss Interval data for options
  */
 struct tfrc_hc_rx_sock {
-	u8				last_counter:4;
-	enum tfrc_fback_type		feedback:4;
-	u32				x_recv;
-	ktime_t				tstamp_last_feedback;
-	struct tfrc_rx_hist		hist;
-	struct tfrc_loss_hist		li_hist;
-#define p_inverse			li_hist.i_mean
-	struct tfrc_loss_data		li_data;
+	u8				rx_last_counter:4;
+	enum tfrc_fback_type		rx_feedback:4;
+	u32				rx_x_recv;
+	ktime_t				rx_tstamp_last_feedback;
+	struct tfrc_rx_hist		rx_hist;
+	struct tfrc_loss_hist		rx_li_hist;
+#define rx_pinv				rx_li_hist.i_mean
+	struct tfrc_loss_data		rx_li_data;
 };
 
 static inline struct tfrc_hc_rx_sock *tfrc_hc_rx_sk(const struct sock *sk)
@@ -154,10 +154,10 @@ static inline struct tfrc_hc_rx_sock *tf
 	return hcrx;
 }
 
-static inline u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now)
+static inline u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hc, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->t_last_win_count);
+	u32 delta = ktime_us_delta(now, hc->tx_t_last_win_count);
 
-	return delta / hctx->rtt;
+	return delta / hc->tx_rtt;
 }
 #endif /* _TFRC_CCIDS_SP_H_ */

-- 
