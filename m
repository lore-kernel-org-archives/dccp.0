From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:32:10 +0000
Subject: [PATCH 25/25] Final adjustments to ccid3.c, ccid4.c and lib/tfrc_ccids.c
Message-Id: <200710312132.10510.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Final adjustments to ccid3.c, ccid4.c and lib/tfrc_ccids.c

According to the chosen strategy explained in [PATCH 15/25], some defines become unnecessary. This patch removes them and adjusts ccid3.c, ccid4.c and lib/ccid34_lib.c to use tfrc_ccids definitions directly.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -48,51 +48,10 @@ static int ccid3_debug;
 
 DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
 
-/**
- * Each of the following #define aims at maintain the current
- * dccp code nomenclature unchanged while still share
- * tfrc_hc_tx_sock struct and until it is defined a final
- * solution to share ccid3/ccid4 common code. This can also facilitate future
- * changes, for instance, if we decide to have two hc_tx_sock
- * struct, one for ccid3 and another for ccid4.
- */
-#define ccid3_hc_tx_sock tfrc_hc_tx_sock
-#define ccid3hctx_s tfrchctx_s
-#define ccid3hctx_tfrc tfrchctx_tfrc
-#define ccid3hctx_delta tfrchctx_delta
-#define ccid3hctx_t_last_win_count tfrchctx_t_last_win_count
-#define ccid3hctx_t_ld tfrchctx_t_ld
-#define ccid3hctx_last_win_count tfrchctx_last_win_count
-#define ccid3hctx_no_feedback_timer tfrchctx_no_feedback_timer
-#define ccid3hctx_t_nom tfrchctx_t_nom
-#define ccid3hctx_hist tfrchctx_hist
-#define ccid3hctx_rtt tfrchctx_rtt
-#define ccid3hctx_t_ipi tfrchctx_t_ipi
-#define ccid3hctx_x tfrchctx_x
-#define ccid3hctx_p tfrchctx_p
-#define ccid3hctx_x_calc tfrchctx_x_calc
-#define ccid3hctx_t_rto tfrchctx_t_rto
-#define ccid3hctx_x_recv tfrchctx_x_recv
-#define ccid3_hc_tx_sk tfrc_hc_tx_sk
-
-#define ccid3_hc_rx_sock tfrc_hc_rx_sock
-#define ccid3hcrx_s tfrchcrx_s
-#define ccid3hcrx_x_recv tfrchcrx_x_recv
-#define ccid3hcrx_pinv tfrchcrx_pinv
-#define ccid3hcrx_last_feedback tfrchcrx_last_feedback
-#define ccid3hcrx_bytes_recv tfrchcrx_bytes_recv
-#define ccid3hcrx_last_counter tfrchcrx_last_counter
-#define ccid3hcrx_rtt tfrchcrx_rtt
-#define ccid3hcrx_s tfrchcrx_s
-#define ccid3hcrx_hist tfrchcrx_hist
-#define ccid3hcrx_li_hist tfrchcrx_li_hist
-
-#define ccid3_hc_rx_sk tfrc_hc_rx_sk
-
 static void ccid3_hc_tx_set_state(struct sock *sk,
 				  enum tfrc_hc_tx_states state)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
@@ -105,19 +64,19 @@ static void ccid3_hc_tx_set_state(struct
 /*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
-static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
+static inline void ccid3_update_send_interval(struct tfrc_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid3hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s) << 6,
-					     hctx->ccid3hctx_x);
+	hctx->tfrchctx_t_ipi = scaled_div32(((u64)hctx->tfrchctx_s) << 6,
+					     hctx->tfrchctx_x);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
+	hctx->tfrchctx_delta = min_t(u32, hctx->tfrchctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 
 	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
-		       hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
-		       hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
+		       hctx->tfrchctx_t_ipi, hctx->tfrchctx_delta,
+		       hctx->tfrchctx_s, (unsigned)(hctx->tfrchctx_x >> 6));
 
 }
 
@@ -133,9 +92,9 @@ static inline void ccid3_update_send_int
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
-	const  __u64 old_x = hctx->ccid3hctx_x;
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	__u64 min_rate = 2 * hctx->tfrchctx_x_recv;
+	const  __u64 old_x = hctx->tfrchctx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -146,33 +105,33 @@ static void ccid3_hc_tx_update_x(struct 
 	 */
 	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
+		min_rate = max(min_rate, 2 * hctx->tfrchctx_x_recv);
 	}
 
-	if (hctx->ccid3hctx_p > 0) {
+	if (hctx->tfrchctx_p > 0) {
 
-		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
+		hctx->tfrchctx_x = min(((__u64)hctx->tfrchctx_x_calc) << 6,
 					min_rate);
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
-					(((__u64)hctx->ccid3hctx_s) << 6) /
+		hctx->tfrchctx_x = max(hctx->tfrchctx_x,
+					(((__u64)hctx->tfrchctx_s) << 6) /
 								TFRC_T_MBI);
 
-	} else if (ktime_us_delta(now, hctx->ccid3hctx_t_ld)
-				- (s64)hctx->ccid3hctx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hctx->tfrchctx_t_ld)
+				- (s64)hctx->tfrchctx_rtt >= 0) {
 
-		hctx->ccid3hctx_x -			max(min(2 * hctx->ccid3hctx_x, min_rate),
-			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-				       hctx->ccid3hctx_rtt));
-		hctx->ccid3hctx_t_ld = now;
+		hctx->tfrchctx_x +			max(min(2 * hctx->tfrchctx_x, min_rate),
+			    scaled_div(((__u64)hctx->tfrchctx_s) << 6,
+				       hctx->tfrchctx_rtt));
+		hctx->tfrchctx_t_ld = now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x) {
+	if (hctx->tfrchctx_x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->ccid3hctx_x >> 6),
-			       hctx->ccid3hctx_x_calc,
-			       (unsigned)(hctx->ccid3hctx_x_recv >> 6));
+			       (unsigned)(hctx->tfrchctx_x >> 6),
+			       hctx->tfrchctx_x_calc,
+			       (unsigned)(hctx->tfrchctx_x_recv >> 6));
 
 		ccid3_update_send_interval(hctx);
 	}
@@ -182,20 +141,20 @@ static void ccid3_hc_tx_update_x(struct 
  *	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
  *	@len: DCCP packet payload size in bytes
  */
-static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
+static inline void ccid3_hc_tx_update_s(struct tfrc_hc_tx_sock *hctx, int len)
 {
-	const u16 old_s = hctx->ccid3hctx_s;
+	const u16 old_s = hctx->tfrchctx_s;
 
-	hctx->ccid3hctx_s = tfrc_ewma(hctx->ccid3hctx_s, len, 9);
+	hctx->tfrchctx_s = tfrc_ewma(hctx->tfrchctx_s, len, 9);
 
-	if (hctx->ccid3hctx_s != old_s)
+	if (hctx->tfrchctx_s != old_s)
 		ccid3_update_send_interval(hctx);
 }
 
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -216,12 +175,12 @@ static void ccid3_hc_tx_no_feedback_time
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
-	if (hctx->ccid3hctx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->ccid3hctx_p = 0       ) {
+	if (hctx->tfrchctx_t_rto = 0 ||	/* no feedback received yet */
+	    hctx->tfrchctx_p = 0       ) {
 
 		/* halve send rate directly */
-		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x / 2,
-					(((__u64)hctx->ccid3hctx_s) << 6) /
+		hctx->tfrchctx_x = max(hctx->tfrchctx_x / 2,
+					(((__u64)hctx->tfrchctx_s) << 6) /
 								    TFRC_T_MBI);
 		ccid3_update_send_interval(hctx);
 	} else {
@@ -235,33 +194,33 @@ static void ccid3_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
+		BUG_ON(hctx->tfrchctx_p && !hctx->tfrchctx_x_calc);
 
-		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
-			hctx->ccid3hctx_x_recv -				max(hctx->ccid3hctx_x_recv / 2,
-				    (((__u64)hctx->ccid3hctx_s) << 6) /
+		if (hctx->tfrchctx_x_calc > (hctx->tfrchctx_x_recv >> 5))
+			hctx->tfrchctx_x_recv +				max(hctx->tfrchctx_x_recv / 2,
+				    (((__u64)hctx->tfrchctx_s) << 6) /
 							      (2 * TFRC_T_MBI));
 		else {
-			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
-			hctx->ccid3hctx_x_recv <<= 4;
+			hctx->tfrchctx_x_recv = hctx->tfrchctx_x_calc;
+			hctx->tfrchctx_x_recv <<= 4;
 		}
 		ccid3_hc_tx_update_x(sk, NULL);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->ccid3hctx_x);
+			(unsigned long long)hctx->tfrchctx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->ccid3hctx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hctx->tfrchctx_t_rto = 0))	/* no feedback yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -277,7 +236,7 @@ out:
 static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delay;
 
@@ -291,16 +250,16 @@ static int ccid3_hc_tx_send_packet(struc
 
 	switch (hctx->tfrchctx_state) {
 	case TFRC_SSTATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+		sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			       (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->ccid3hctx_last_win_count	 = 0;
-		hctx->ccid3hctx_t_last_win_count = now;
+		hctx->tfrchctx_last_win_count	 = 0;
+		hctx->tfrchctx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->ccid3hctx_t_nom = now;
+		hctx->tfrchctx_t_nom = now;
 
-		hctx->ccid3hctx_s = skb->len;
+		hctx->tfrchctx_s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -309,13 +268,13 @@ static int ccid3_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->tfrchctx_rtt  = dp->dccps_syn_rtt;
+			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
+			hctx->tfrchctx_t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
-			hctx->ccid3hctx_x = hctx->ccid3hctx_s;
-			hctx->ccid3hctx_x <<= 6;
+			hctx->tfrchctx_x = hctx->tfrchctx_s;
+			hctx->tfrchctx_x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
 
@@ -323,7 +282,7 @@ static int ccid3_hc_tx_send_packet(struc
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = ktime_us_delta(hctx->ccid3hctx_t_nom, now);
+		delay = ktime_us_delta(hctx->tfrchctx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -333,7 +292,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
+		if (delay - (s64)hctx->tfrchctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		tfrc_hc_tx_update_win_count(hctx, now);
@@ -345,28 +304,28 @@ static int ccid3_hc_tx_send_packet(struc
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->tfrchctx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->ccid3hctx_t_nom = ktime_add_us(hctx->ccid3hctx_t_nom,
-					     hctx->ccid3hctx_t_ipi);
+	hctx->tfrchctx_t_nom = ktime_add_us(hctx->tfrchctx_t_nom,
+					     hctx->tfrchctx_t_ipi);
 	return 0;
 }
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 				    unsigned int len)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	ccid3_hc_tx_update_s(hctx, len);
 
-	if (tfrc_tx_hist_add(&hctx->ccid3hctx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hctx->tfrchctx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	struct tfrc_options_received *opt_recv;
 	ktime_t t_send, now;
 	unsigned long t_nfb;
@@ -385,7 +344,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 
 	/* estimate RTT from history if ACK number is valid */
-	if (! tfrc_tx_hist_when(&t_send, &hctx->ccid3hctx_hist,
+	if (! tfrc_tx_hist_when(&t_send, &hctx->tfrchctx_hist,
 			        DCCP_SKB_CB(skb)->dccpd_ack_seq)) {
 		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
 			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
@@ -396,22 +355,22 @@ static void ccid3_hc_tx_packet_recv(stru
 	opt_recv = &hctx->tfrchctx_options_received;
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ccid3hctx_x_recv = opt_recv->tfrcor_receive_rate;
-	hctx->ccid3hctx_x_recv <<= 6;
+	hctx->tfrchctx_x_recv = opt_recv->tfrcor_receive_rate;
+	hctx->tfrchctx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->tfrcor_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->ccid3hctx_p = 0;
+		hctx->tfrchctx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->ccid3hctx_p = scaled_div(1, pinv);
+		hctx->tfrchctx_p = scaled_div(1, pinv);
 
 	/*
 	 * Calculate new RTT sample and update moving average
 	 */
 	now = ktime_get_real();
 	r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, t_send));
-	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
+	hctx->tfrchctx_rtt = tfrc_ewma(hctx->tfrchctx_rtt, r_sample, 9);
 
 	/*
 	 *	Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
@@ -420,18 +379,18 @@ static void ccid3_hc_tx_packet_recv(stru
 
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		if (hctx->ccid3hctx_t_rto = 0) {
+		if (hctx->tfrchctx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
+			hctx->tfrchctx_t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
 			goto done_computing_x;
 
-		} else if (hctx->ccid3hctx_p = 0) {
+		} else if (hctx->tfrchctx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -439,22 +398,22 @@ static void ccid3_hc_tx_packet_recv(stru
 		}
 	}
 	/* perform step (4) of draft rfc3448bis, section 4.3 */
-	if (hctx->ccid3hctx_p > 0)
-		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
-						     hctx->ccid3hctx_rtt,
-						     hctx->ccid3hctx_p);
+	if (hctx->tfrchctx_p > 0)
+		hctx->tfrchctx_x_calc = tfrc_calc_x(hctx->tfrchctx_s,
+						     hctx->tfrchctx_rtt,
+						     hctx->tfrchctx_p);
 	ccid3_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, p=%u, X_calc=%u, "
 		       "X_recv=%u, X=%u\n", dccp_role(sk), sk,
-		       hctx->ccid3hctx_rtt, r_sample, hctx->ccid3hctx_s,
-		       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
-		       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-		       (unsigned)(hctx->ccid3hctx_x >> 6));
+		       hctx->tfrchctx_rtt, r_sample, hctx->tfrchctx_s,
+		       hctx->tfrchctx_p, hctx->tfrchctx_x_calc,
+		       (unsigned)(hctx->tfrchctx_x_recv >> 6),
+		       (unsigned)(hctx->tfrchctx_x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -468,16 +427,16 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
+	hctx->tfrchctx_t_rto = max_t(u32, 4 * hctx->tfrchctx_rtt,
 					   CONFIG_IP_DCCP_CCID3_RTO *
 					   (USEC_PER_SEC/1000));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+	t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
 
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 
 	ccid3_pr_debug("Scheduled no feedback timer to expire in %lu jiffies"
@@ -490,7 +449,7 @@ static int ccid3_hc_tx_parse_options(str
 {
 	int rc = 0;
 	const struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	struct tfrc_options_received *opt_recv;
 	__be32 opt_val;
 
@@ -548,48 +507,48 @@ static int ccid3_hc_tx_parse_options(str
 
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
-	tfrc_tx_hist_init(&hctx->ccid3hctx_hist, ccid3_tx_hist);
+	tfrc_tx_hist_init(&hctx->tfrchctx_hist, ccid3_tx_hist);
 
-	hctx->ccid3hctx_no_feedback_timer.function +	hctx->tfrchctx_no_feedback_timer.function  				ccid3_hc_tx_no_feedback_timer;
-	hctx->ccid3hctx_no_feedback_timer.data     = (unsigned long)sk;
-	init_timer(&hctx->ccid3hctx_no_feedback_timer);
+	hctx->tfrchctx_no_feedback_timer.data     = (unsigned long)sk;
+	init_timer(&hctx->tfrchctx_no_feedback_timer);
 
 	return 0;
 }
 
 static void ccid3_hc_tx_exit(struct sock *sk)
 {
-	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
-	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
 
 	/* Empty packet history */
-	tfrc_tx_hist_cleanup(&hctx->ccid3hctx_hist);
+	tfrc_tx_hist_cleanup(&hctx->tfrchctx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = ccid3_hc_tx_sk(sk)->ccid3hctx_t_rto;
-	info->tcpi_rtt = ccid3_hc_tx_sk(sk)->ccid3hctx_rtt;
+	info->tcpi_rto = tfrc_hc_tx_sk(sk)->tfrchctx_t_rto;
+	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->tfrchctx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	const void *val;
 
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->ccid3hctx_tfrc))
+		if (len < sizeof(hctx->tfrchctx_tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->ccid3hctx_tfrc);
-		val = &hctx->ccid3hctx_tfrc;
+		len = sizeof(hctx->tfrchctx_tfrc);
+		val = &hctx->tfrchctx_tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -604,7 +563,7 @@ static int ccid3_hc_tx_getsockopt(struct
 static void ccid3_hc_rx_set_state(struct sock *sk,
 				  enum tfrc_hc_rx_states state)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
@@ -614,16 +573,16 @@ static void ccid3_hc_rx_set_state(struct
 	hcrx->tfrchcrx_state = state;
 }
 
-static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
+static inline void ccid3_hc_rx_update_s(struct tfrc_hc_rx_sock *hcrx, int len)
 {
 	if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
-		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
+		hcrx->tfrchcrx_s = tfrc_ewma(hcrx->tfrchcrx_s, len, 9);
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delta = 0;
@@ -633,8 +592,8 @@ static void ccid3_hc_rx_send_feedback(st
 
 	switch (fbtype) {
 	case FBACK_INITIAL:
-		hcrx->ccid3hcrx_x_recv = 0;
-		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
+		hcrx->tfrchcrx_x_recv = 0;
+		hcrx->tfrchcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
 	case FBACK_PARAM_CHANGE:
 		/*
@@ -647,26 +606,26 @@ static void ccid3_hc_rx_send_feedback(st
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->ccid3hcrx_x_recv > 0)
+		if (hcrx->tfrchcrx_x_recv > 0)
 			break;
 		/* fall through */
 	case FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->ccid3hcrx_last_feedback);
+		delta = ktime_us_delta(now, hcrx->tfrchcrx_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->ccid3hcrx_x_recv -				scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+			hcrx->tfrchcrx_x_recv +				scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
+		       hcrx->tfrchcrx_x_recv, hcrx->tfrchcrx_pinv);
 
-	hcrx->ccid3hcrx_last_feedback = now;
-	hcrx->ccid3hcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
-	hcrx->ccid3hcrx_bytes_recv    = 0;
+	hcrx->tfrchcrx_last_feedback = now;
+	hcrx->tfrchcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->tfrchcrx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -674,7 +633,7 @@ static void ccid3_hc_rx_send_feedback(st
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
@@ -683,8 +642,8 @@ static int ccid3_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
-	pinv   = htonl(hcrx->ccid3hcrx_pinv);
+	x_recv = htonl(hcrx->tfrchcrx_x_recv);
+	pinv   = htonl(hcrx->tfrchcrx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -706,26 +665,26 @@ static int ccid3_hc_rx_insert_options(st
  */
 static u32 ccid3_first_li(struct sock *sk)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->ccid3hcrx_rtt = 0) {
+	if (hcrx->tfrchcrx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
+		hcrx->tfrchcrx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta = ktime_to_us(net_timedelta(hcrx->ccid3hcrx_last_feedback));
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	delta = ktime_to_us(net_timedelta(hcrx->tfrchcrx_last_feedback));
+	x_recv = scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+		if ((x_recv = hcrx->tfrchcrx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
 	}
 
-	fval = scaled_div(hcrx->ccid3hcrx_s, hcrx->ccid3hcrx_rtt);
+	fval = scaled_div(hcrx->tfrchcrx_s, hcrx->tfrchcrx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -737,13 +696,13 @@ static u32 ccid3_first_li(struct sock *s
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	enum   tfrc_fback_type  do_feedback = FBACK_NONE;
 	u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
 
-	spin_lock(&hcrx->ccid3hcrx_hist.lock);
+	spin_lock(&hcrx->tfrchcrx_hist.lock);
 
 	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
@@ -754,26 +713,26 @@ static void ccid3_hc_rx_packet_recv(stru
 		goto update_records;
 	}
 
-	if (tfrc_rx_duplicate(&hcrx->ccid3hcrx_hist, skb))
+	if (tfrc_rx_duplicate(&hcrx->tfrchcrx_hist, skb))
 		goto done_receiving;
 
 	if (is_data_packet) {
 		ccid3_hc_rx_update_s(hcrx, payload_size);
-		hcrx->ccid3hcrx_bytes_recv += payload_size;
+		hcrx->tfrchcrx_bytes_recv += payload_size;
 	}
 
 	/*
 	 *	Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist) &&
-	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
-				&hcrx->ccid3hcrx_li_hist,
+	if (tfrc_rx_loss_pending(&hcrx->tfrchcrx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->tfrchcrx_hist,
+				&hcrx->tfrchcrx_li_hist,
 				skb, ndp, ccid3_first_li, sk) ) {
 		do_feedback = FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
+	if (tfrc_rx_new_loss_indicated(&hcrx->tfrchcrx_hist, skb, ndp))
 		goto update_records;
 
 	/*
@@ -782,18 +741,18 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (! tfrc_lh_is_initialised(&hcrx->ccid3hcrx_li_hist)) {
+	if (! tfrc_lh_is_initialised(&hcrx->tfrchcrx_li_hist)) {
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
-		sample = tfrc_rx_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
+		sample = tfrc_rx_sample_rtt(&hcrx->tfrchcrx_hist, skb);
 		if (sample != 0)
-			hcrx->ccid3hcrx_rtt -				tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
+			hcrx->tfrchcrx_rtt +				tfrc_ewma(hcrx->tfrchcrx_rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->ccid3hcrx_li_hist, skb))
+	} else if (tfrc_lh_update_i_mean(&hcrx->tfrchcrx_li_hist, skb))
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -801,14 +760,14 @@ static void ccid3_hc_rx_packet_recv(stru
 		do_feedback = FBACK_PARAM_CHANGE;
 
 	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->tfrchcrx_last_counter) > 3)
 		do_feedback = FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, ndp);
+	tfrc_rx_hist_update(&hcrx->tfrchcrx_hist, skb, ndp);
 
 done_receiving:
-	spin_unlock(&hcrx->ccid3hcrx_hist.lock);
+	spin_unlock(&hcrx->tfrchcrx_hist.lock);
 
 	if (do_feedback)
 		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
@@ -816,36 +775,36 @@ done_receiving:
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
+	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	ccid3_pr_debug("entry\n");
 
 	hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA;
-	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
-	return tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist);
+	tfrc_lh_init(&hcrx->tfrchcrx_li_hist);
+	return tfrc_rx_hist_init(&hcrx->tfrchcrx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
-	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
+	tfrc_rx_hist_cleanup(&hcrx->tfrchcrx_hist);
+	tfrc_lh_cleanup(&hcrx->tfrchcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = ccid3_hc_rx_sk(sk)->tfrchcrx_state;
+	info->tcpi_ca_state = tfrc_hc_rx_sk(sk)->tfrchcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = ccid3_hc_rx_sk(sk)->ccid3hcrx_rtt;
+	info->tcpi_rcv_rtt  = tfrc_hc_rx_sk(sk)->tfrchcrx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	const void *val;
 	struct tfrc_rx_info rx_info;
 
@@ -855,10 +814,10 @@ static int ccid3_hc_rx_getsockopt(struct
 			return -EINVAL;
 		len = sizeof(rx_info);
 		val = &rx_info;
-		rx_info.tfrcrx_x_recv	= hcrx->ccid3hcrx_x_recv;
-		rx_info.tfrcrx_rtt	= hcrx->ccid3hcrx_rtt;
-		rx_info.tfrcrx_p	= hcrx->ccid3hcrx_pinv = 0 ? ~0U
-					: scaled_div(1, hcrx->ccid3hcrx_pinv);
+		rx_info.tfrcrx_x_recv	= hcrx->tfrchcrx_x_recv;
+		rx_info.tfrcrx_rtt	= hcrx->tfrchcrx_rtt;
+		rx_info.tfrcrx_p	= hcrx->tfrchcrx_pinv = 0 ? ~0U
+					: scaled_div(1, hcrx->tfrchcrx_pinv);
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -874,14 +833,14 @@ static struct ccid_operations ccid3 = {
 	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "TCP-Friendly Rate Control",
 	.ccid_owner		   = THIS_MODULE,
-	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
+	.ccid_hc_tx_obj_size	   = sizeof(struct tfrc_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
 	.ccid_hc_tx_exit	   = ccid3_hc_tx_exit,
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid3_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
 	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
-	.ccid_hc_rx_obj_size	   = sizeof(struct ccid3_hc_rx_sock),
+	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid3_hc_rx_exit,
 	.ccid_hc_rx_insert_options = ccid3_hc_rx_insert_options,
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -58,51 +58,10 @@ static int ccid4_debug;
 
 DECLARE_TFRC_TX_CACHE(ccid4_tx_hist);
 
-/**
- * Each of the following #define aims at maintain the current
- * dccp code nomenclature unchanged while still share
- * tfrc_hc_tx_sock struct and until it is defined a final
- * solution to share ccid3/ccid4 common code. This can also facilitate future
- * changes, for instance, if we decide to have two hc_tx_sock
- * struct, one for ccid3 and another for ccid4.
- */
-#define ccid4_hc_tx_sock tfrc_hc_tx_sock
-#define ccid4hctx_s tfrchctx_s
-#define ccid4hctx_tfrc tfrchctx_tfrc
-#define ccid4hctx_delta tfrchctx_delta
-#define ccid4hctx_t_last_win_count tfrchctx_t_last_win_count
-#define ccid4hctx_t_ld tfrchctx_t_ld
-#define ccid4hctx_last_win_count tfrchctx_last_win_count
-#define ccid4hctx_no_feedback_timer tfrchctx_no_feedback_timer
-#define ccid4hctx_t_nom tfrchctx_t_nom
-#define ccid4hctx_hist tfrchctx_hist
-#define ccid4hctx_rtt tfrchctx_rtt
-#define ccid4hctx_t_ipi tfrchctx_t_ipi
-#define ccid4hctx_x tfrchctx_x
-#define ccid4hctx_p tfrchctx_p
-#define ccid4hctx_x_calc tfrchctx_x_calc
-#define ccid4hctx_t_rto tfrchctx_t_rto
-#define ccid4hctx_x_recv tfrchctx_x_recv
-#define ccid4_hc_tx_sk tfrc_hc_tx_sk
-
-#define ccid4_hc_rx_sock tfrc_hc_rx_sock
-#define ccid4hcrx_s tfrchcrx_s
-#define ccid4hcrx_x_recv tfrchcrx_x_recv
-#define ccid4hcrx_pinv tfrchcrx_pinv
-#define ccid4hcrx_last_feedback tfrchcrx_last_feedback
-#define ccid4hcrx_bytes_recv tfrchcrx_bytes_recv
-#define ccid4hcrx_last_counter tfrchcrx_last_counter
-#define ccid4hcrx_rtt tfrchcrx_rtt
-#define ccid4hcrx_s tfrchcrx_s
-#define ccid4hcrx_hist tfrchcrx_hist
-#define ccid4hcrx_li_hist tfrchcrx_li_hist
-
-#define ccid4_hc_rx_sk tfrc_hc_rx_sk
-
 static void ccid4_hc_tx_set_state(struct sock *sk,
 				  enum tfrc_hc_tx_states state)
 {
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
@@ -115,21 +74,21 @@ static void ccid4_hc_tx_set_state(struct
 /*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
-static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
+static inline void ccid4_update_send_interval(struct tfrc_hc_tx_sock *hctx)
 {
         /* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second).
          * TFRC-SP enforces a minimum interval of 10 milliseconds. */
-        hctx->ccid4hctx_t_ipi -              max_t(u32, scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
-                                      hctx->ccid4hctx_x), MIN_SEND_RATE);
+        hctx->tfrchctx_t_ipi +              max_t(u32, scaled_div32(((u64)hctx->tfrchctx_s) << 6,
+                                      hctx->tfrchctx_x), MIN_SEND_RATE);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->ccid4hctx_delta = min_t(u32, hctx->ccid4hctx_t_ipi / 2,
+	hctx->tfrchctx_delta = min_t(u32, hctx->tfrchctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 
 	ccid4_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
-		       hctx->ccid4hctx_t_ipi, hctx->ccid4hctx_delta,
-		       hctx->ccid4hctx_s, (unsigned)(hctx->ccid4hctx_x >> 6));
+		       hctx->tfrchctx_t_ipi, hctx->tfrchctx_delta,
+		       hctx->tfrchctx_s, (unsigned)(hctx->tfrchctx_x >> 6));
 
 }
 
@@ -138,10 +97,10 @@ static inline void ccid4_update_send_int
  * @hctx: half-connection to adjust
  * This function adjusts sending rate according to [TFRC-SP, Section 5]
  */
-static inline void ccid4_hc_tx_x_header_penalty(struct ccid4_hc_tx_sock *hctx)
+static inline void ccid4_hc_tx_x_header_penalty(struct tfrc_hc_tx_sock *hctx)
 {
-        hctx->ccid4hctx_x *= hctx->ccid4hctx_s;
-        do_div(hctx->ccid4hctx_x, (hctx->ccid4hctx_s + CCID4HCTX_H));
+        hctx->tfrchctx_x *= hctx->tfrchctx_s;
+        do_div(hctx->tfrchctx_x, (hctx->tfrchctx_s + CCID4HCTX_H));
 }
 
 /**
@@ -156,9 +115,9 @@ static inline void ccid4_hc_tx_x_header_
  */
 static void ccid4_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->ccid4hctx_x_recv;
-	const  __u64 old_x = hctx->ccid4hctx_x;
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	__u64 min_rate = 2 * hctx->tfrchctx_x_recv;
+	const  __u64 old_x = hctx->tfrchctx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -169,36 +128,36 @@ static void ccid4_hc_tx_update_x(struct 
 	 */
 	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->ccid4hctx_x_recv);
+		min_rate = max(min_rate, 2 * hctx->tfrchctx_x_recv);
 	}
 
-	if (hctx->ccid4hctx_p > 0) {
+	if (hctx->tfrchctx_p > 0) {
 
-		hctx->ccid4hctx_x = min(((__u64)hctx->ccid4hctx_x_calc) << 6,
+		hctx->tfrchctx_x = min(((__u64)hctx->tfrchctx_x_calc) << 6,
 					min_rate);
-		hctx->ccid4hctx_x = max(hctx->ccid4hctx_x,
-					(((__u64)hctx->ccid4hctx_s) << 6) /
+		hctx->tfrchctx_x = max(hctx->tfrchctx_x,
+					(((__u64)hctx->tfrchctx_s) << 6) /
 								TFRC_T_MBI);
                 ccid4_hc_tx_x_header_penalty(hctx);
 
-	} else if (ktime_us_delta(now, hctx->ccid4hctx_t_ld)
-				- (s64)hctx->ccid4hctx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hctx->tfrchctx_t_ld)
+				- (s64)hctx->tfrchctx_rtt >= 0) {
 
-		hctx->ccid4hctx_x -			max(min(2 * hctx->ccid4hctx_x, min_rate),
-			    scaled_div(((__u64)hctx->ccid4hctx_s) << 6,
-				       hctx->ccid4hctx_rtt));
+		hctx->tfrchctx_x +			max(min(2 * hctx->tfrchctx_x, min_rate),
+			    scaled_div(((__u64)hctx->tfrchctx_s) << 6,
+				       hctx->tfrchctx_rtt));
 
                 ccid4_hc_tx_x_header_penalty(hctx);
-		hctx->ccid4hctx_t_ld = now;
+		hctx->tfrchctx_t_ld = now;
 	}
 
-	if (hctx->ccid4hctx_x != old_x) {
+	if (hctx->tfrchctx_x != old_x) {
 		ccid4_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->ccid4hctx_x >> 6),
-			       hctx->ccid4hctx_x_calc,
-			       (unsigned)(hctx->ccid4hctx_x_recv >> 6));
+			       (unsigned)(hctx->tfrchctx_x >> 6),
+			       hctx->tfrchctx_x_calc,
+			       (unsigned)(hctx->tfrchctx_x_recv >> 6));
 
 		ccid4_update_send_interval(hctx);
 	}
@@ -208,20 +167,20 @@ static void ccid4_hc_tx_update_x(struct 
  *	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
  *	@len: DCCP packet payload size in bytes
  */
-static inline void ccid4_hc_tx_update_s(struct ccid4_hc_tx_sock *hctx, int len)
+static inline void ccid4_hc_tx_update_s(struct tfrc_hc_tx_sock *hctx, int len)
 {
-	const u16 old_s = hctx->ccid4hctx_s;
+	const u16 old_s = hctx->tfrchctx_s;
 
-	hctx->ccid4hctx_s = tfrc_ewma(hctx->ccid4hctx_s, len, 9);
+	hctx->tfrchctx_s = tfrc_ewma(hctx->tfrchctx_s, len, 9);
 
-	if (hctx->ccid4hctx_s != old_s)
+	if (hctx->tfrchctx_s != old_s)
 		ccid4_update_send_interval(hctx);
 }
 
 static void ccid4_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -242,12 +201,12 @@ static void ccid4_hc_tx_no_feedback_time
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
-	if (hctx->ccid4hctx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->ccid4hctx_p = 0       ) {
+	if (hctx->tfrchctx_t_rto = 0 ||	/* no feedback received yet */
+	    hctx->tfrchctx_p = 0       ) {
 
 		/* halve send rate directly */
-		hctx->ccid4hctx_x = max(hctx->ccid4hctx_x / 2,
-					(((__u64)hctx->ccid4hctx_s) << 6) /
+		hctx->tfrchctx_x = max(hctx->tfrchctx_x / 2,
+					(((__u64)hctx->tfrchctx_s) << 6) /
 								    TFRC_T_MBI);
 		ccid4_update_send_interval(hctx);
 	} else {
@@ -261,33 +220,33 @@ static void ccid4_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->ccid4hctx_p && !hctx->ccid4hctx_x_calc);
+		BUG_ON(hctx->tfrchctx_p && !hctx->tfrchctx_x_calc);
 
-		if (hctx->ccid4hctx_x_calc > (hctx->ccid4hctx_x_recv >> 5))
-			hctx->ccid4hctx_x_recv -				max(hctx->ccid4hctx_x_recv / 2,
-				    (((__u64)hctx->ccid4hctx_s) << 6) /
+		if (hctx->tfrchctx_x_calc > (hctx->tfrchctx_x_recv >> 5))
+			hctx->tfrchctx_x_recv +				max(hctx->tfrchctx_x_recv / 2,
+				    (((__u64)hctx->tfrchctx_s) << 6) /
 							      (2 * TFRC_T_MBI));
 		else {
-			hctx->ccid4hctx_x_recv = hctx->ccid4hctx_x_calc;
-			hctx->ccid4hctx_x_recv <<= 4;
+			hctx->tfrchctx_x_recv = hctx->tfrchctx_x_calc;
+			hctx->tfrchctx_x_recv <<= 4;
 		}
 		ccid4_hc_tx_update_x(sk, NULL);
 	}
 	ccid4_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->ccid4hctx_x);
+			(unsigned long long)hctx->tfrchctx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->ccid4hctx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hctx->tfrchctx_t_rto = 0))	/* no feedback yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->ccid4hctx_t_rto, 2 * hctx->ccid4hctx_t_ipi);
+		t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -303,7 +262,7 @@ out:
 static int ccid4_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delay;
 
@@ -317,16 +276,16 @@ static int ccid4_hc_tx_send_packet(struc
 
 	switch (hctx->tfrchctx_state) {
 	case TFRC_SSTATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
+		sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			       (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->ccid4hctx_last_win_count	 = 0;
-		hctx->ccid4hctx_t_last_win_count = now;
+		hctx->tfrchctx_last_win_count	 = 0;
+		hctx->tfrchctx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->ccid4hctx_t_nom = now;
+		hctx->tfrchctx_t_nom = now;
 
-		hctx->ccid4hctx_s = skb->len;
+		hctx->tfrchctx_s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -335,13 +294,13 @@ static int ccid4_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid4_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->ccid4hctx_rtt  = dp->dccps_syn_rtt;
-			hctx->ccid4hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid4hctx_t_ld = now;
+			hctx->tfrchctx_rtt  = dp->dccps_syn_rtt;
+			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
+			hctx->tfrchctx_t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
-			hctx->ccid4hctx_x = hctx->ccid4hctx_s;
-			hctx->ccid4hctx_x <<= 6;
+			hctx->tfrchctx_x = hctx->tfrchctx_s;
+			hctx->tfrchctx_x <<= 6;
 		}
 		ccid4_update_send_interval(hctx);
 
@@ -349,7 +308,7 @@ static int ccid4_hc_tx_send_packet(struc
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = ktime_us_delta(hctx->ccid4hctx_t_nom, now);
+		delay = ktime_us_delta(hctx->tfrchctx_t_nom, now);
 		ccid4_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -359,7 +318,7 @@ static int ccid4_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->ccid4hctx_delta >= 1000)
+		if (delay - (s64)hctx->tfrchctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		tfrc_hc_tx_update_win_count(hctx, now);
@@ -371,28 +330,28 @@ static int ccid4_hc_tx_send_packet(struc
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid4hctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->tfrchctx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->ccid4hctx_t_nom = ktime_add_us(hctx->ccid4hctx_t_nom,
-					     hctx->ccid4hctx_t_ipi);
+	hctx->tfrchctx_t_nom = ktime_add_us(hctx->tfrchctx_t_nom,
+					     hctx->tfrchctx_t_ipi);
 	return 0;
 }
 
 static void ccid4_hc_tx_packet_sent(struct sock *sk, int more,
 				    unsigned int len)
 {
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	ccid4_hc_tx_update_s(hctx, len);
 
-	if (tfrc_tx_hist_add(&hctx->ccid4hctx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hctx->tfrchctx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
 static void ccid4_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	struct tfrc_options_received *opt_recv;
 	ktime_t t_send, now;
 	unsigned long t_nfb;
@@ -411,7 +370,7 @@ static void ccid4_hc_tx_packet_recv(stru
 	}
 
 	/* estimate RTT from history if ACK number is valid */
-	if (! tfrc_tx_hist_when(&t_send, &hctx->ccid4hctx_hist,
+	if (! tfrc_tx_hist_when(&t_send, &hctx->tfrchctx_hist,
 			        DCCP_SKB_CB(skb)->dccpd_ack_seq)) {
 		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
 			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
@@ -422,22 +381,22 @@ static void ccid4_hc_tx_packet_recv(stru
 	opt_recv = &hctx->tfrchctx_options_received;
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->ccid4hctx_x_recv = opt_recv->tfrcor_receive_rate;
-	hctx->ccid4hctx_x_recv <<= 6;
+	hctx->tfrchctx_x_recv = opt_recv->tfrcor_receive_rate;
+	hctx->tfrchctx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->tfrcor_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->ccid4hctx_p = 0;
+		hctx->tfrchctx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->ccid4hctx_p = scaled_div(1, pinv);
+		hctx->tfrchctx_p = scaled_div(1, pinv);
 
 	/*
 	 * Calculate new RTT sample and update moving average
 	 */
 	now = ktime_get_real();
 	r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, t_send));
-	hctx->ccid4hctx_rtt = tfrc_ewma(hctx->ccid4hctx_rtt, r_sample, 9);
+	hctx->tfrchctx_rtt = tfrc_ewma(hctx->tfrchctx_rtt, r_sample, 9);
 
 	/*
 	 *	Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
@@ -446,18 +405,18 @@ static void ccid4_hc_tx_packet_recv(stru
 
 		ccid4_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		if (hctx->ccid4hctx_t_rto = 0) {
+		if (hctx->tfrchctx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->ccid4hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid4hctx_t_ld = now;
+			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
+			hctx->tfrchctx_t_ld = now;
 
 			ccid4_update_send_interval(hctx);
 
 			goto done_computing_x;
 
-		} else if (hctx->ccid4hctx_p = 0) {
+		} else if (hctx->tfrchctx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -465,22 +424,22 @@ static void ccid4_hc_tx_packet_recv(stru
 		}
 	}
         /* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->ccid4hctx_p > 0)
-		hctx->ccid4hctx_x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
-						     hctx->ccid4hctx_rtt,
-						     hctx->ccid4hctx_p);
+	if (hctx->tfrchctx_p > 0)
+		hctx->tfrchctx_x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
+						     hctx->tfrchctx_rtt,
+						     hctx->tfrchctx_p);
 	ccid4_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid4_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, p=%u, X_calc=%u, "
 		       "X_recv=%u, X=%u\n", dccp_role(sk), sk,
-		       hctx->ccid4hctx_rtt, r_sample, hctx->ccid4hctx_s,
-		       hctx->ccid4hctx_p, hctx->ccid4hctx_x_calc,
-		       (unsigned)(hctx->ccid4hctx_x_recv >> 6),
-		       (unsigned)(hctx->ccid4hctx_x >> 6));
+		       hctx->tfrchctx_rtt, r_sample, hctx->tfrchctx_s,
+		       hctx->tfrchctx_p, hctx->tfrchctx_x_calc,
+		       (unsigned)(hctx->tfrchctx_x_recv >> 6),
+		       (unsigned)(hctx->tfrchctx_x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->ccid4hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -494,16 +453,16 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->ccid4hctx_t_rto = max_t(u32, 4 * hctx->ccid4hctx_rtt,
+	hctx->tfrchctx_t_rto = max_t(u32, 4 * hctx->tfrchctx_rtt,
 					   CONFIG_IP_DCCP_CCID4_RTO *
 					   (USEC_PER_SEC/1000));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->ccid4hctx_t_rto, 2 * hctx->ccid4hctx_t_ipi);
+	t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
 
-	sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 
 	ccid4_pr_debug("Scheduled no feedback timer to expire in %lu jiffies"
@@ -516,7 +475,7 @@ static int ccid4_hc_tx_parse_options(str
 {
 	int rc = 0;
 	const struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	struct tfrc_options_received *opt_recv;
 	u32 opt_val;
 
@@ -577,48 +536,48 @@ static int ccid4_hc_tx_parse_options(str
 
 static int ccid4_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid4_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
-	tfrc_tx_hist_init(&hctx->ccid4hctx_hist, ccid4_tx_hist);
+	tfrc_tx_hist_init(&hctx->tfrchctx_hist, ccid4_tx_hist);
 
-	hctx->ccid4hctx_no_feedback_timer.function +	hctx->tfrchctx_no_feedback_timer.function  				ccid4_hc_tx_no_feedback_timer;
-	hctx->ccid4hctx_no_feedback_timer.data     = (unsigned long)sk;
-	init_timer(&hctx->ccid4hctx_no_feedback_timer);
+	hctx->tfrchctx_no_feedback_timer.data     = (unsigned long)sk;
+	init_timer(&hctx->tfrchctx_no_feedback_timer);
 
 	return 0;
 }
 
 static void ccid4_hc_tx_exit(struct sock *sk)
 {
-	struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	ccid4_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
-	sk_stop_timer(sk, &hctx->ccid4hctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
 
 	/* Empty packet history */
-	tfrc_tx_hist_cleanup(&hctx->ccid4hctx_hist);
+	tfrc_tx_hist_cleanup(&hctx->tfrchctx_hist);
 }
 
 static void ccid4_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = ccid4_hc_tx_sk(sk)->ccid4hctx_t_rto;
-	info->tcpi_rtt = ccid4_hc_tx_sk(sk)->ccid4hctx_rtt;
+	info->tcpi_rto = tfrc_hc_tx_sk(sk)->tfrchctx_t_rto;
+	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->tfrchctx_rtt;
 }
 
 static int ccid4_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
+	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 	const void *val;
 
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->ccid4hctx_tfrc))
+		if (len < sizeof(hctx->tfrchctx_tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->ccid4hctx_tfrc);
-		val = &hctx->ccid4hctx_tfrc;
+		len = sizeof(hctx->tfrchctx_tfrc);
+		val = &hctx->tfrchctx_tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -633,7 +592,7 @@ static int ccid4_hc_tx_getsockopt(struct
 static void ccid4_hc_rx_set_state(struct sock *sk,
 				  enum tfrc_hc_rx_states state)
 {
-	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
@@ -643,16 +602,16 @@ static void ccid4_hc_rx_set_state(struct
 	hcrx->tfrchcrx_state = state;
 }
 
-static inline void ccid4_hc_rx_update_s(struct ccid4_hc_rx_sock *hcrx, int len)
+static inline void ccid4_hc_rx_update_s(struct tfrc_hc_rx_sock *hcrx, int len)
 {
 	if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
-		hcrx->ccid4hcrx_s = tfrc_ewma(hcrx->ccid4hcrx_s, len, 9);
+		hcrx->tfrchcrx_s = tfrc_ewma(hcrx->tfrchcrx_s, len, 9);
 }
 
 static void ccid4_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
 				      enum tfrc_fback_type fbtype)
 {
-	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	ktime_t now = ktime_get_real();
 	s64 delta = 0;
@@ -662,8 +621,8 @@ static void ccid4_hc_rx_send_feedback(st
 
 	switch (fbtype) {
 	case FBACK_INITIAL:
-		hcrx->ccid4hcrx_x_recv = 0;
-		hcrx->ccid4hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
+		hcrx->tfrchcrx_x_recv = 0;
+		hcrx->tfrchcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
 	case FBACK_PARAM_CHANGE:
 		/*
@@ -676,26 +635,26 @@ static void ccid4_hc_rx_send_feedback(st
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->ccid4hcrx_x_recv > 0)
+		if (hcrx->tfrchcrx_x_recv > 0)
 			break;
 		/* fall through */
 	case FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->ccid4hcrx_last_feedback);
+		delta = ktime_us_delta(now, hcrx->tfrchcrx_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->ccid4hcrx_x_recv -				scaled_div32(hcrx->ccid4hcrx_bytes_recv, delta);
+			hcrx->tfrchcrx_x_recv +				scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 	ccid4_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->ccid4hcrx_x_recv, hcrx->ccid4hcrx_pinv);
+		       hcrx->tfrchcrx_x_recv, hcrx->tfrchcrx_pinv);
 
-	hcrx->ccid4hcrx_last_feedback = now;
-	hcrx->ccid4hcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
-	hcrx->ccid4hcrx_bytes_recv    = 0;
+	hcrx->tfrchcrx_last_feedback = now;
+	hcrx->tfrchcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->tfrchcrx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -703,7 +662,7 @@ static void ccid4_hc_rx_send_feedback(st
 
 static int ccid4_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
@@ -712,8 +671,8 @@ static int ccid4_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->ccid4hcrx_x_recv);
-	pinv   = htonl(hcrx->ccid4hcrx_pinv);
+	x_recv = htonl(hcrx->tfrchcrx_x_recv);
+	pinv   = htonl(hcrx->tfrchcrx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -735,26 +694,26 @@ static int ccid4_hc_rx_insert_options(st
  */
 static u32 ccid4_first_li(struct sock *sk)
 {
-	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->ccid4hcrx_rtt = 0) {
+	if (hcrx->tfrchcrx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->ccid4hcrx_rtt = DCCP_FALLBACK_RTT;
+		hcrx->tfrchcrx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta = ktime_to_us(net_timedelta(hcrx->ccid4hcrx_last_feedback));
-	x_recv = scaled_div32(hcrx->ccid4hcrx_bytes_recv, delta);
+	delta = ktime_to_us(net_timedelta(hcrx->tfrchcrx_last_feedback));
+	x_recv = scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->ccid4hcrx_x_recv) = 0) {
+		if ((x_recv = hcrx->tfrchcrx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
 	}
 
-	fval = scaled_div(NOM_PACKET_SIZE, hcrx->ccid4hcrx_rtt);
+	fval = scaled_div(NOM_PACKET_SIZE, hcrx->tfrchcrx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -766,13 +725,13 @@ static u32 ccid4_first_li(struct sock *s
 
 static void ccid4_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	enum   tfrc_fback_type  do_feedback = FBACK_NONE;
 	u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb);
 
-	spin_lock(&hcrx->ccid4hcrx_hist.lock);
+	spin_lock(&hcrx->tfrchcrx_hist.lock);
 
 	if (unlikely(hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA)) {
 		if (is_data_packet) {
@@ -783,26 +742,26 @@ static void ccid4_hc_rx_packet_recv(stru
 		goto update_records;
 	}
 
-	if (tfrc_rx_duplicate(&hcrx->ccid4hcrx_hist, skb))
+	if (tfrc_rx_duplicate(&hcrx->tfrchcrx_hist, skb))
 		goto done_receiving;
 
 	if (is_data_packet) {
 		ccid4_hc_rx_update_s(hcrx, payload_size);
-		hcrx->ccid4hcrx_bytes_recv += payload_size;
+		hcrx->tfrchcrx_bytes_recv += payload_size;
 	}
 
 	/*
 	 *	Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_loss_pending(&hcrx->ccid4hcrx_hist) &&
-	    tfrc_rx_handle_loss(&hcrx->ccid4hcrx_hist,
-				&hcrx->ccid4hcrx_li_hist,
+	if (tfrc_rx_loss_pending(&hcrx->tfrchcrx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->tfrchcrx_hist,
+				&hcrx->tfrchcrx_li_hist,
 				skb, ndp, ccid4_first_li, sk) ) {
 		do_feedback = FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_new_loss_indicated(&hcrx->ccid4hcrx_hist, skb, ndp))
+	if (tfrc_rx_new_loss_indicated(&hcrx->tfrchcrx_hist, skb, ndp))
 		goto update_records;
 
 	/*
@@ -811,18 +770,18 @@ static void ccid4_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (! tfrc_lh_is_initialised(&hcrx->ccid4hcrx_li_hist)) {
+	if (! tfrc_lh_is_initialised(&hcrx->tfrchcrx_li_hist)) {
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
-		sample = tfrc_rx_sample_rtt(&hcrx->ccid4hcrx_hist, skb);
+		sample = tfrc_rx_sample_rtt(&hcrx->tfrchcrx_hist, skb);
 		if (sample != 0)
-			hcrx->ccid4hcrx_rtt -				tfrc_ewma(hcrx->ccid4hcrx_rtt, sample, 9);
+			hcrx->tfrchcrx_rtt +				tfrc_ewma(hcrx->tfrchcrx_rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->ccid4hcrx_li_hist, skb))
+	} else if (tfrc_lh_update_i_mean(&hcrx->tfrchcrx_li_hist, skb))
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -830,14 +789,14 @@ static void ccid4_hc_rx_packet_recv(stru
 		do_feedback = FBACK_PARAM_CHANGE;
 
 	/* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid4hcrx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->tfrchcrx_last_counter) > 3)
 		do_feedback = FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_update(&hcrx->ccid4hcrx_hist, skb, ndp);
+	tfrc_rx_hist_update(&hcrx->tfrchcrx_hist, skb, ndp);
 
 done_receiving:
-	spin_unlock(&hcrx->ccid4hcrx_hist.lock);
+	spin_unlock(&hcrx->tfrchcrx_hist.lock);
 
 	if (do_feedback)
 		ccid4_hc_rx_send_feedback(sk, skb, do_feedback);
@@ -845,37 +804,37 @@ done_receiving:
 
 static int ccid4_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid4_hc_rx_sock *hcrx = ccid_priv(ccid);
+	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	ccid4_pr_debug("entry\n");
 
-	tfrc_lh_init(&hcrx->ccid4hcrx_li_hist);
+	tfrc_lh_init(&hcrx->tfrchcrx_li_hist);
 	hcrx->tfrchcrx_state = TFRC_RSTATE_NO_DATA;
 
-	return tfrc_rx_hist_init(&hcrx->ccid4hcrx_hist);
+	return tfrc_rx_hist_init(&hcrx->tfrchcrx_hist);
 }
 
 static void ccid4_hc_rx_exit(struct sock *sk)
 {
-	struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 
 	ccid4_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	tfrc_rx_hist_cleanup(&hcrx->ccid4hcrx_hist);
-	tfrc_lh_cleanup(&hcrx->ccid4hcrx_li_hist);
+	tfrc_rx_hist_cleanup(&hcrx->tfrchcrx_hist);
+	tfrc_lh_cleanup(&hcrx->tfrchcrx_li_hist);
 }
 
 static void ccid4_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = ccid4_hc_rx_sk(sk)->tfrchcrx_state;
+	info->tcpi_ca_state = tfrc_hc_rx_sk(sk)->tfrchcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = ccid4_hc_rx_sk(sk)->ccid4hcrx_rtt;
+	info->tcpi_rcv_rtt  = tfrc_hc_rx_sk(sk)->tfrchcrx_rtt;
 }
 
 static int ccid4_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
+	const struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
 	const void *val;
 	struct tfrc_rx_info rx_info;
 
@@ -885,10 +844,10 @@ static int ccid4_hc_rx_getsockopt(struct
 			return -EINVAL;
 		len = sizeof(rx_info);
 		val = &rx_info;
-		rx_info.tfrcrx_x_recv	= hcrx->ccid4hcrx_x_recv;
-		rx_info.tfrcrx_rtt	= hcrx->ccid4hcrx_rtt;
-		rx_info.tfrcrx_p	= hcrx->ccid4hcrx_pinv = 0 ? ~0U
-					: scaled_div(1, hcrx->ccid4hcrx_pinv);
+		rx_info.tfrcrx_x_recv	= hcrx->tfrchcrx_x_recv;
+		rx_info.tfrcrx_rtt	= hcrx->tfrchcrx_rtt;
+		rx_info.tfrcrx_p	= hcrx->tfrchcrx_pinv = 0 ? ~0U
+					: scaled_div(1, hcrx->tfrchcrx_pinv);
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -904,14 +863,14 @@ static struct ccid_operations ccid4 = {
 	.ccid_id		   = DCCPC_CCID4,
 	.ccid_name		   = "TCP-Friendly Rate Control (Small-Packet variant)",
 	.ccid_owner		   = THIS_MODULE,
-	.ccid_hc_tx_obj_size	   = sizeof(struct ccid4_hc_tx_sock),
+	.ccid_hc_tx_obj_size	   = sizeof(struct tfrc_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid4_hc_tx_init,
 	.ccid_hc_tx_exit	   = ccid4_hc_tx_exit,
 	.ccid_hc_tx_send_packet	   = ccid4_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	   = ccid4_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid4_hc_tx_packet_recv,
 	.ccid_hc_tx_parse_options  = ccid4_hc_tx_parse_options,
-	.ccid_hc_rx_obj_size	   = sizeof(struct ccid4_hc_rx_sock),
+	.ccid_hc_rx_obj_size	   = sizeof(struct tfrc_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid4_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid4_hc_rx_exit,
 	.ccid_hc_rx_insert_options = ccid4_hc_rx_insert_options,
