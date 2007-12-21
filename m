From: Leandro <leandroal@gmail.com>
Date: Fri, 21 Dec 2007 04:33:16 +0000
Subject: [PATCHv2 4/8] Fix name schema for tx-rx sock struct
Message-Id: <200712210133.16344.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP][TFRC_CCIDS] Fix name schema for tx-rx sock struct

Besides the dccp/ccids directory files, this patch also fixes the name schema for include/linux/tfrc.h.

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

--------------------> Patch v2 <-------------------------

The first version of this patch doest apply properly in the current ccid4 branch. This new version it is ok.

Index: ccid4.latest/include/linux/tfrc.h
=================================--- /dev/null
+++ ccid4.latest/include/linux/tfrc.h
@@ -0,0 +1,55 @@
+#ifndef _LINUX_TFRC_H_
+#define _LINUX_TFRC_H_
+/*
+ *  TFRC - Data Structures for the TCP-Friendly Rate Control congestion
+ *         control mechanism as specified in RFC 3448.
+ *
+ *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005 Ian McDonald <iam4@cs.waikato.ac.nz>
+ *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
+ *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
+ *
+ *  This program is free software; you can redistribute it and/or modify
+ *  it under the terms of the GNU General Public License as published by
+ *  the Free Software Foundation; either version 2 of the License, or
+ *  (at your option) any later version.
+ */
+#include <linux/types.h>
+
+/** 	tfrc_rx_info    -    TFRC Receiver Data Structure
+ *
+ * 	@x_recv:	receiver estimate of sending rate (3.2.2)
+ * 	@rtt:		round-trip-time (communicated by sender)
+ * 	@p:		current estimate of loss event rate (3.2.2)
+ */
+struct tfrc_rx_info {
+  	__u32 x_recv;
+	__u32 rtt;
+  	__u32 p;
+};
+
+/** 	tfrc_tx_info    -    TFRC Sender Data Structure
+ *
+ * 	@x_x:	computed transmit rate (4.3 (4))
+ * 	@x_recv: receiver estimate of send rate (4.3)
+ * 	@x_calc:	return value of throughput equation (3.1)
+ * 	@rtt:	(moving average) estimate of RTT (4.3)
+ * 	@p:	current loss event rate (5.4)
+ * 	@rto:	estimate of RTO, equals 4*RTT (4.3)
+ * 	@ipi:	inter-packet interval (4.6)
+ *
+ *  Note: X and X_recv are both maintained in units of 64 * bytes/second. This
+ *        enables a finer resolution of sending rates and avoids problems with
+ *        integer arithmetic; u32 is not sufficient as scaling consumes 6 bits.
+ */
+struct tfrc_tx_info {
+	__u64 x;
+	__u64 x_recv;
+	__u32 x_calc;
+	__u32 rtt;
+	__u32 p;
+	__u32 rto;
+	__u32 ipi;
+};
+
+#endif /* _LINUX_TFRC_H_ */
Index: ccid4.latest/net/dccp/ccids/ccid3.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid3.c
+++ ccid4.latest/net/dccp/ccids/ccid3.c
@@ -48,13 +48,13 @@ static void ccid3_hc_tx_set_state(struct
 				  enum tfrc_hc_tx_states state)
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
+	enum tfrc_hc_tx_states oldstate = hctx->ttx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, tfrc_tx_state_name(oldstate),
 		       tfrc_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->tfrchctx_state = state;
+	hctx->ttx_state = state;
 }
 
 /*
@@ -63,16 +63,15 @@ static void ccid3_hc_tx_set_state(struct
 static inline void ccid3_update_send_interval(struct tfrc_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->tfrchctx_t_ipi = scaled_div32(((u64)hctx->tfrchctx_s) << 6,
-					     hctx->tfrchctx_x);
+	hctx->ttx_t_ipi = scaled_div32(((u64)hctx->ttx_s) << 6, hctx->ttx_x);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->tfrchctx_delta = min_t(u32, hctx->tfrchctx_t_ipi / 2,
+	hctx->ttx_delta = min_t(u32, hctx->ttx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 
 	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
-		       hctx->tfrchctx_t_ipi, hctx->tfrchctx_delta,
-		       hctx->tfrchctx_s, (unsigned)(hctx->tfrchctx_x >> 6));
+		       hctx->ttx_t_ipi, hctx->ttx_delta,
+		       hctx->ttx_s, (unsigned)(hctx->ttx_x >> 6));
 
 }
 
@@ -89,8 +88,8 @@ static inline void ccid3_update_send_int
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->tfrchctx_x_recv;
-	const  __u64 old_x = hctx->tfrchctx_x;
+	__u64 min_rate = 2 * hctx->ttx_x_recv;
+	const  __u64 old_x = hctx->ttx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -101,33 +100,29 @@ static void ccid3_hc_tx_update_x(struct 
 	 */
 	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->tfrchctx_x_recv);
+		min_rate = max(min_rate, 2 * hctx->ttx_x_recv);
 	}
 
-	if (hctx->tfrchctx_p > 0) {
+	if (hctx->ttx_p > 0) {
 
-		hctx->tfrchctx_x = min(((__u64)hctx->tfrchctx_x_calc) << 6,
-					min_rate);
-		hctx->tfrchctx_x = max(hctx->tfrchctx_x,
-					(((__u64)hctx->tfrchctx_s) << 6) /
-								TFRC_T_MBI);
+		hctx->ttx_x = min(((__u64)hctx->ttx_x_calc) << 6, min_rate);
+		hctx->ttx_x = max(hctx->ttx_x, 
+				(((__u64)hctx->ttx_s) << 6) / TFRC_T_MBI);
 
-	} else if (ktime_us_delta(now, hctx->tfrchctx_t_ld)
-				- (s64)hctx->tfrchctx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hctx->ttx_t_ld)
+				- (s64)hctx->ttx_rtt >= 0) {
 
-		hctx->tfrchctx_x -			max(min(2 * hctx->tfrchctx_x, min_rate),
-			    scaled_div(((__u64)hctx->tfrchctx_s) << 6,
-				       hctx->tfrchctx_rtt));
-		hctx->tfrchctx_t_ld = now;
+		hctx->ttx_x = max(min(2 * hctx->ttx_x, min_rate),
+			    		scaled_div(((__u64)hctx->ttx_s) << 6,
+				       			hctx->ttx_rtt));
+		hctx->ttx_t_ld = now;
 	}
 
-	if (hctx->tfrchctx_x != old_x) {
+	if (hctx->ttx_x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->tfrchctx_x >> 6),
-			       hctx->tfrchctx_x_calc,
-			       (unsigned)(hctx->tfrchctx_x_recv >> 6));
+			       (unsigned)(hctx->ttx_x >> 6), hctx->ttx_x_calc,
+			       (unsigned)(hctx->ttx_x_recv >> 6));
 
 		ccid3_update_send_interval(hctx);
 	}
@@ -139,11 +134,11 @@ static void ccid3_hc_tx_update_x(struct 
  */
 static inline void ccid3_hc_tx_update_s(struct tfrc_hc_tx_sock *hctx, int len)
 {
-	const u16 old_s = hctx->tfrchctx_s;
+	const u16 old_s = hctx->ttx_s;
 
-	hctx->tfrchctx_s = tfrc_ewma(hctx->tfrchctx_s, len, 9);
+	hctx->ttx_s = tfrc_ewma(hctx->ttx_s, len, 9);
 
-	if (hctx->tfrchctx_s != old_s)
+	if (hctx->ttx_s != old_s)
 		ccid3_update_send_interval(hctx);
 }
 
@@ -161,22 +156,22 @@ static void ccid3_hc_tx_no_feedback_time
 	}
 
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       tfrc_tx_state_name(hctx->tfrchctx_state));
+		       tfrc_tx_state_name(hctx->ttx_state));
 
-	if (hctx->tfrchctx_state = TTX_STATE_FBACK)
+	if (hctx->ttx_state = TTX_STATE_FBACK)
 		ccid3_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
-	else if (hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
+	else if (hctx->ttx_state != TTX_STATE_NO_FBACK)
 		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
-	if (hctx->tfrchctx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->tfrchctx_p = 0) {
+	if (hctx->ttx_t_rto = 0 ||	/* no feedback received yet */
+	    hctx->ttx_p = 0) {
 
 		/* halve send rate directly */
-		hctx->tfrchctx_x = max(hctx->tfrchctx_x / 2,
-					(((__u64)hctx->tfrchctx_s) << 6) /
+		hctx->ttx_x = max(hctx->ttx_x / 2,
+					(((__u64)hctx->ttx_s) << 6) /
 								    TFRC_T_MBI);
 		ccid3_update_send_interval(hctx);
 	} else {
@@ -190,33 +185,32 @@ static void ccid3_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->tfrchctx_p && !hctx->tfrchctx_x_calc);
+		BUG_ON(hctx->ttx_p && !hctx->ttx_x_calc);
 
-		if (hctx->tfrchctx_x_calc > (hctx->tfrchctx_x_recv >> 5))
-			hctx->tfrchctx_x_recv -				max(hctx->tfrchctx_x_recv / 2,
-				    (((__u64)hctx->tfrchctx_s) << 6) /
+		if (hctx->ttx_x_calc > (hctx->ttx_x_recv >> 5))
+			hctx->ttx_x_recv = max(hctx->ttx_x_recv / 2,
+					    (((__u64)hctx->ttx_s) << 6) /
 							      (2 * TFRC_T_MBI));
 		else {
-			hctx->tfrchctx_x_recv = hctx->tfrchctx_x_calc;
-			hctx->tfrchctx_x_recv <<= 4;
+			hctx->ttx_x_recv = hctx->ttx_x_calc;
+			hctx->ttx_x_recv <<= 4;
 		}
 		ccid3_hc_tx_update_x(sk, NULL);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->tfrchctx_x);
+			(unsigned long long)hctx->ttx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->tfrchctx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hctx->ttx_t_rto = 0))	/* no feedback yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
+		t_nfb = max(hctx->ttx_t_rto, 2 * hctx->ttx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->ttx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -244,18 +238,18 @@ static int ccid3_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->tfrchctx_state) {
+	switch (hctx->ttx_state) {
 	case TTX_STATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
+		sk_reset_timer(sk, &hctx->ttx_no_feedback_timer,
 			       (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->tfrchctx_last_win_count	 = 0;
-		hctx->tfrchctx_t_last_win_count = now;
+		hctx->ttx_last_win_count = 0;
+		hctx->ttx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->tfrchctx_t_nom = now;
+		hctx->ttx_t_nom = now;
 
-		hctx->tfrchctx_s = skb->len;
+		hctx->ttx_s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -264,13 +258,13 @@ static int ccid3_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->tfrchctx_rtt  = dp->dccps_syn_rtt;
-			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
-			hctx->tfrchctx_t_ld = now;
+			hctx->ttx_rtt  = dp->dccps_syn_rtt;
+			hctx->ttx_x    = rfc3390_initial_rate(sk);
+			hctx->ttx_t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
-			hctx->tfrchctx_x = hctx->tfrchctx_s;
-			hctx->tfrchctx_x <<= 6;
+			hctx->ttx_x = hctx->ttx_s;
+			hctx->ttx_x <<= 6;
 		}
 		ccid3_update_send_interval(hctx);
 
@@ -278,7 +272,7 @@ static int ccid3_hc_tx_send_packet(struc
 		break;
 	case TTX_STATE_NO_FBACK:
 	case TTX_STATE_FBACK:
-		delay = ktime_us_delta(hctx->tfrchctx_t_nom, now);
+		delay = ktime_us_delta(hctx->ttx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -288,7 +282,7 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->tfrchctx_delta >= 1000)
+		if (delay - (s64)hctx->ttx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		tfrc_hc_tx_update_win_count(hctx, now);
@@ -300,11 +294,10 @@ static int ccid3_hc_tx_send_packet(struc
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->tfrchctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ttx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->tfrchctx_t_nom = ktime_add_us(hctx->tfrchctx_t_nom,
-					     hctx->tfrchctx_t_ipi);
+	hctx->ttx_t_nom = ktime_add_us(hctx->ttx_t_nom, hctx->ttx_t_ipi);
 	return 0;
 }
 
@@ -315,7 +308,7 @@ static void ccid3_hc_tx_packet_sent(stru
 
 	ccid3_hc_tx_update_s(hctx, len);
 
-	if (tfrc_tx_hist_add(&hctx->tfrchctx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hctx->ttx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
@@ -332,15 +325,15 @@ static void ccid3_hc_tx_packet_recv(stru
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->tfrchctx_state != TTX_STATE_FBACK &&
-	    hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
+	if (hctx->ttx_state != TTX_STATE_FBACK &&
+	    hctx->ttx_state != TTX_STATE_NO_FBACK)
 		return;
 
-	opt_recv = &hctx->tfrchctx_options_received;
+	opt_recv = &hctx->ttx_options_received;
 	now = ktime_get_real();
 
 	/* Estimate RTT from history if ACK number is valid */
-	r_sample = tfrc_tx_hist_rtt(hctx->tfrchctx_hist,
+	r_sample = tfrc_tx_hist_rtt(hctx->ttx_hist,
 				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
 	if (r_sample = 0) {
 		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
@@ -350,37 +343,37 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->tfrchctx_x_recv = opt_recv->tfrcor_receive_rate;
-	hctx->tfrchctx_x_recv <<= 6;
+	hctx->ttx_x_recv = opt_recv->tfrcor_receive_rate;
+	hctx->ttx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->tfrcor_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->tfrchctx_p = 0;
+		hctx->ttx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->tfrchctx_p = scaled_div(1, pinv);
+		hctx->ttx_p = scaled_div(1, pinv);
 	/*
 	 * Validate new RTT sample and update moving average
 	 */
 	r_sample = dccp_sample_rtt(sk, r_sample);
-	hctx->tfrchctx_rtt = tfrc_ewma(hctx->tfrchctx_rtt, r_sample, 9);
+	hctx->ttx_rtt = tfrc_ewma(hctx->ttx_rtt, r_sample, 9);
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->tfrchctx_state = TTX_STATE_NO_FBACK) {
+	if (hctx->ttx_state = TTX_STATE_NO_FBACK) {
 		ccid3_hc_tx_set_state(sk, TTX_STATE_FBACK);
 
-		if (hctx->tfrchctx_t_rto = 0) {
+		if (hctx->ttx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
-			hctx->tfrchctx_t_ld = now;
+			hctx->ttx_x = rfc3390_initial_rate(sk);
+			hctx->ttx_t_ld = now;
 
 			ccid3_update_send_interval(hctx);
 
 			goto done_computing_x;
-		} else if (hctx->tfrchctx_p = 0) {
+		} else if (hctx->ttx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -389,25 +382,23 @@ static void ccid3_hc_tx_packet_recv(stru
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->tfrchctx_p > 0)
-		hctx->tfrchctx_x_calc -				tfrc_calc_x(hctx->tfrchctx_s,
-					    hctx->tfrchctx_rtt,
-					    hctx->tfrchctx_p);
+	if (hctx->ttx_p > 0)
+		hctx->ttx_x_calc = tfrc_calc_x(hctx->ttx_s, hctx->ttx_rtt,
+								hctx->ttx_p);
 	ccid3_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
 			       dccp_role(sk),
-			       sk, hctx->tfrchctx_rtt, r_sample,
-			       hctx->tfrchctx_s, hctx->tfrchctx_p,
-			       hctx->tfrchctx_x_calc,
-			       (unsigned)(hctx->tfrchctx_x_recv >> 6),
-			       (unsigned)(hctx->tfrchctx_x >> 6));
+			       sk, hctx->ttx_rtt, r_sample,
+			       hctx->ttx_s, hctx->ttx_p,
+			       hctx->ttx_x_calc,
+			       (unsigned)(hctx->ttx_x_recv >> 6),
+			       (unsigned)(hctx->ttx_x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->ttx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -421,21 +412,21 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->tfrchctx_t_rto = max_t(u32, 4 * hctx->tfrchctx_rtt,
+	hctx->ttx_t_rto = max_t(u32, 4 * hctx->ttx_rtt,
 					   (CONFIG_IP_DCCP_CCID3_RTO *
 					    (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
+	t_nfb = max(hctx->ttx_t_rto, 2 * hctx->ttx_t_ipi);
 
 	ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
 		       dccp_role(sk),
 		       sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->ttx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
@@ -449,7 +440,7 @@ static int ccid3_hc_tx_parse_options(str
 	struct tfrc_options_received *opt_recv;
 	__be32 opt_val;
 
-	opt_recv = &hctx->tfrchctx_options_received;
+	opt_recv = &hctx->ttx_options_received;
 
 	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
 		opt_recv->tfrcor_seqno	      = dp->dccps_gsr;
@@ -505,10 +496,10 @@ static int ccid3_hc_tx_init(struct ccid 
 {
 	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->tfrchctx_state = TTX_STATE_NO_SENT;
-	hctx->tfrchctx_hist = NULL;
-	setup_timer(&hctx->tfrchctx_no_feedback_timer,
-			ccid3_hc_tx_no_feedback_timer, (unsigned long)sk);
+	hctx->ttx_state = TTX_STATE_NO_SENT;
+	hctx->ttx_hist = NULL;
+	setup_timer(&hctx->ttx_no_feedback_timer, ccid3_hc_tx_no_feedback_timer,
+			(unsigned long)sk);
 
 	return 0;
 }
@@ -518,15 +509,15 @@ static void ccid3_hc_tx_exit(struct sock
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	ccid3_hc_tx_set_state(sk, TTX_STATE_TERM);
-	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->ttx_no_feedback_timer);
 
-	tfrc_tx_hist_purge(&hctx->tfrchctx_hist);
+	tfrc_tx_hist_purge(&hctx->ttx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = tfrc_hc_tx_sk(sk)->tfrchctx_t_rto;
-	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->tfrchctx_rtt;
+	info->tcpi_rto = tfrc_hc_tx_sk(sk)->ttx_t_rto;
+	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->ttx_rtt;
 }
 
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
@@ -537,10 +528,10 @@ static int ccid3_hc_tx_getsockopt(struct
 
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->tfrchctx_tfrc))
+		if (len < sizeof(hctx->ttx_tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->tfrchctx_tfrc);
-		val = &hctx->tfrchctx_tfrc;
+		len = sizeof(hctx->ttx_tfrc);
+		val = &hctx->ttx_tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -556,13 +547,13 @@ static void ccid3_hc_rx_set_state(struct
 				  enum tfrc_hc_rx_states state)
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
+	enum tfrc_hc_rx_states oldstate = hcrx->trx_state;
 
 	ccid3_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, tfrc_rx_state_name(oldstate),
 		       tfrc_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->tfrchcrx_state = state;
+	hcrx->trx_state = state;
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk,
@@ -574,15 +565,15 @@ static void ccid3_hc_rx_send_feedback(st
 	ktime_t now;
 	s64 delta = 0;
 
-	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_TERM))
+	if (unlikely(hcrx->trx_state = TRX_STATE_TERM))
 		return;
 
 	now = ktime_get_real();
 
 	switch (fbtype) {
 	case TFRC_FBACK_INITIAL:
-		hcrx->tfrchcrx_x_recv = 0;
-		hcrx->tfrchcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
+		hcrx->trx_x_recv = 0;
+		hcrx->trx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
 	case TFRC_FBACK_PARAM_CHANGE:
 		/*
@@ -595,27 +586,27 @@ static void ccid3_hc_rx_send_feedback(st
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->tfrchcrx_x_recv > 0)
+		if (hcrx->trx_x_recv > 0)
 			break;
 		/* fall through */
 	case TFRC_FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->tfrchcrx_last_feedback);
+		delta = ktime_us_delta(now, hcrx->trx_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->tfrchcrx_x_recv -				scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
+			hcrx->trx_x_recv +				scaled_div32(hcrx->trx_bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 
 	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->tfrchcrx_x_recv, hcrx->tfrchcrx_pinv);
+		       hcrx->trx_x_recv, hcrx->trx_pinv);
 
-	hcrx->tfrchcrx_last_feedback = now;
-	hcrx->tfrchcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
-	hcrx->tfrchcrx_bytes_recv    = 0;
+	hcrx->trx_last_feedback = now;
+	hcrx->trx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->trx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -632,8 +623,8 @@ static int ccid3_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->tfrchcrx_x_recv);
-	pinv   = htonl(hcrx->tfrchcrx_pinv);
+	x_recv = htonl(hcrx->trx_x_recv);
+	pinv   = htonl(hcrx->trx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -659,22 +650,22 @@ static u32 ccid3_first_li(struct sock *s
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->tfrchcrx_rtt = 0) {
+	if (hcrx->trx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->tfrchcrx_rtt = DCCP_FALLBACK_RTT;
+		hcrx->trx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta = ktime_to_us(net_timedelta(hcrx->tfrchcrx_last_feedback));
-	x_recv = scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
+	delta = ktime_to_us(net_timedelta(hcrx->trx_last_feedback));
+	x_recv = scaled_div32(hcrx->trx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->tfrchcrx_x_recv) = 0) {
+		if ((x_recv = hcrx->trx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
 	}
 
-	fval = scaled_div(hcrx->tfrchcrx_s, hcrx->tfrchcrx_rtt);
+	fval = scaled_div(hcrx->trx_s, hcrx->trx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -691,14 +682,14 @@ static void ccid3_hc_rx_packet_recv(stru
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_NO_DATA)) {
+	if (unlikely(hcrx->trx_state = TRX_STATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = TFRC_FBACK_INITIAL;
 			ccid3_hc_rx_set_state(sk, TRX_STATE_DATA);
-			hcrx->tfrchcrx_s = payload;
+			hcrx->trx_s = payload;
 			/*
-			 * Not necessary to update tfrchcrx_bytes_recv here,
+			 * Not necessary to update trx_bytes_recv here,
 			 * since X_recv = 0 for the first feedback packet (cf.
 			 * RFC 3448, 6.3) -- gerrit
 			 */
@@ -706,7 +697,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		goto update_records;
 	}
 
-	if (tfrc_rx_hist_duplicate(&hcrx->tfrchcrx_hist, skb))
+	if (tfrc_rx_hist_duplicate(&hcrx->trx_hist, skb))
 		return; /* done receiving */
 
 	if (is_data_packet) {
@@ -714,22 +705,21 @@ static void ccid3_hc_rx_packet_recv(stru
 		/*
 		 * Update moving-average of s and the sum of received payload bytes
 		 */
-		hcrx->tfrchcrx_s = tfrc_ewma(hcrx->tfrchcrx_s, payload, 9);
-		hcrx->tfrchcrx_bytes_recv += payload;
+		hcrx->trx_s = tfrc_ewma(hcrx->trx_s, payload, 9);
+		hcrx->trx_bytes_recv += payload;
 	}
 
 	/*
 	 * Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_hist_loss_pending(&hcrx->tfrchcrx_hist) &&
-	    tfrc_rx_handle_loss(&hcrx->tfrchcrx_hist,
-				&hcrx->tfrchcrx_li_hist,
+	if (tfrc_rx_hist_loss_pending(&hcrx->trx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->trx_hist, &hcrx->trx_li_hist,
 				skb, ndp, ccid3_first_li, sk) ) {
 		do_feedback = TFRC_FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_hist_new_loss_indicated(&hcrx->tfrchcrx_hist, skb, ndp))
+	if (tfrc_rx_hist_new_loss_indicated(&hcrx->trx_hist, skb, ndp))
 		goto update_records;
 
 	/*
@@ -738,17 +728,17 @@ static void ccid3_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (!tfrc_lh_is_initialised(&hcrx->tfrchcrx_li_hist)) {
-		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->tfrchcrx_hist, skb);
+	if (!tfrc_lh_is_initialised(&hcrx->trx_li_hist)) {
+		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->trx_hist, skb);
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
 		if (sample != 0)
-			hcrx->tfrchcrx_rtt = tfrc_ewma(hcrx->tfrchcrx_rtt, sample, 9);
+			hcrx->trx_rtt = tfrc_ewma(hcrx->trx_rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->tfrchcrx_li_hist, skb)) {
+	} else if (tfrc_lh_update_i_mean(&hcrx->trx_li_hist, skb)) {
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -759,11 +749,11 @@ static void ccid3_hc_rx_packet_recv(stru
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->tfrchcrx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->trx_last_counter) > 3)
 		do_feedback = TFRC_FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_add_packet(&hcrx->tfrchcrx_hist, skb, ndp);
+	tfrc_rx_hist_add_packet(&hcrx->trx_hist, skb, ndp);
 
 done_receiving:
 	if (do_feedback)
@@ -774,9 +764,9 @@ static int ccid3_hc_rx_init(struct ccid 
 {
 	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->tfrchcrx_state = TRX_STATE_NO_DATA;
-	tfrc_lh_init(&hcrx->tfrchcrx_li_hist);
-	return tfrc_rx_hist_alloc(&hcrx->tfrchcrx_hist);
+	hcrx->trx_state = TRX_STATE_NO_DATA;
+	tfrc_lh_init(&hcrx->trx_li_hist);
+	return tfrc_rx_hist_alloc(&hcrx->trx_hist);
 }
 
 static void ccid3_hc_rx_exit(struct sock *sk)
@@ -785,15 +775,15 @@ static void ccid3_hc_rx_exit(struct sock
 
 	ccid3_hc_rx_set_state(sk, TRX_STATE_TERM);
 
-	tfrc_rx_hist_purge(&hcrx->tfrchcrx_hist);
-	tfrc_lh_cleanup(&hcrx->tfrchcrx_li_hist);
+	tfrc_rx_hist_purge(&hcrx->trx_hist);
+	tfrc_lh_cleanup(&hcrx->trx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = tfrc_hc_rx_sk(sk)->tfrchcrx_state;
+	info->tcpi_ca_state = tfrc_hc_rx_sk(sk)->trx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = tfrc_hc_rx_sk(sk)->tfrchcrx_rtt;
+	info->tcpi_rcv_rtt  = tfrc_hc_rx_sk(sk)->trx_rtt;
 }
 
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
@@ -807,10 +797,10 @@ static int ccid3_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->tfrchcrx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->tfrchcrx_rtt;
-		rx_info.tfrcrx_p      = hcrx->tfrchcrx_pinv = 0 ? ~0U :
-					   scaled_div(1, hcrx->tfrchcrx_pinv);
+		rx_info.tfrcrx_x_recv = hcrx->trx_x_recv;
+		rx_info.tfrcrx_rtt    = hcrx->trx_rtt;
+		rx_info.tfrcrx_p      = hcrx->trx_pinv = 0 ? ~0U :
+					   scaled_div(1, hcrx->trx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
Index: ccid4.latest/net/dccp/ccids/ccid4.c
=================================--- ccid4.latest.orig/net/dccp/ccids/ccid4.c
+++ ccid4.latest/net/dccp/ccids/ccid4.c
@@ -58,13 +58,13 @@ static void ccid4_hc_tx_set_state(struct
 				  enum tfrc_hc_tx_states state)
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	enum tfrc_hc_tx_states oldstate = hctx->tfrchctx_state;
+	enum tfrc_hc_tx_states oldstate = hctx->ttx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, tfrc_tx_state_name(oldstate),
 		       tfrc_tx_state_name(state));
 	WARN_ON(state = oldstate);
-	hctx->tfrchctx_state = state;
+	hctx->ttx_state = state;
 }
 
 /*
@@ -76,17 +76,17 @@ static inline void ccid4_update_send_int
 	 * Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second).
 	 * TFRC-SP enforces a minimum interval of 10 milliseconds.
 	 */
-	hctx->tfrchctx_t_ipi -		max_t(u32, scaled_div32(((u64)hctx->tfrchctx_s) << 6,
-			   hctx->tfrchctx_x), MIN_SEND_RATE);
+	hctx->ttx_t_ipi +		max_t(u32, scaled_div32(((u64)hctx->ttx_s) << 6,
+			   hctx->ttx_x), MIN_SEND_RATE);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->tfrchctx_delta = min_t(u32, hctx->tfrchctx_t_ipi / 2,
+	hctx->ttx_delta = min_t(u32, hctx->ttx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 
 	ccid4_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
-		       hctx->tfrchctx_t_ipi, hctx->tfrchctx_delta,
-		       hctx->tfrchctx_s, (unsigned)(hctx->tfrchctx_x >> 6));
+		       hctx->ttx_t_ipi, hctx->ttx_delta,
+		       hctx->ttx_s, (unsigned)(hctx->ttx_x >> 6));
 
 }
 
@@ -97,8 +97,8 @@ static inline void ccid4_update_send_int
  */
 static inline void ccid4_hc_tx_x_header_penalty(struct tfrc_hc_tx_sock *hctx)
 {
-	hctx->tfrchctx_x *= hctx->tfrchctx_s;
-	do_div(hctx->tfrchctx_x, (hctx->tfrchctx_s + CCID4HCTX_H));
+	hctx->ttx_x *= hctx->ttx_s;
+	do_div(hctx->ttx_x, (hctx->ttx_s + CCID4HCTX_H));
 }
 
 /**
@@ -114,8 +114,8 @@ static inline void ccid4_hc_tx_x_header_
 static void ccid4_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	__u64 min_rate = 2 * hctx->tfrchctx_x_recv;
-	const  __u64 old_x = hctx->tfrchctx_x;
+	__u64 min_rate = 2 * hctx->ttx_x_recv;
+	const  __u64 old_x = hctx->ttx_x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
@@ -126,36 +126,36 @@ static void ccid4_hc_tx_update_x(struct 
 	 */
 	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
-		min_rate = max(min_rate, 2 * hctx->tfrchctx_x_recv);
+		min_rate = max(min_rate, 2 * hctx->ttx_x_recv);
 	}
 
-	if (hctx->tfrchctx_p > 0) {
+	if (hctx->ttx_p > 0) {
 
-		hctx->tfrchctx_x = min(((__u64)hctx->tfrchctx_x_calc) << 6,
+		hctx->ttx_x = min(((__u64)hctx->ttx_x_calc) << 6,
 					min_rate);
-		hctx->tfrchctx_x = max(hctx->tfrchctx_x,
-					(((__u64)hctx->tfrchctx_s) << 6) /
+		hctx->ttx_x = max(hctx->ttx_x,
+					(((__u64)hctx->ttx_s) << 6) /
 								TFRC_T_MBI);
 		ccid4_hc_tx_x_header_penalty(hctx);
 
-	} else if (ktime_us_delta(now, hctx->tfrchctx_t_ld)
-				- (s64)hctx->tfrchctx_rtt >= 0) {
+	} else if (ktime_us_delta(now, hctx->ttx_t_ld)
+				- (s64)hctx->ttx_rtt >= 0) {
 
-		hctx->tfrchctx_x -			max(min(2 * hctx->tfrchctx_x, min_rate),
-			    scaled_div(((__u64)hctx->tfrchctx_s) << 6,
-				       hctx->tfrchctx_rtt));
+		hctx->ttx_x +			max(min(2 * hctx->ttx_x, min_rate),
+			    scaled_div(((__u64)hctx->ttx_s) << 6,
+				       hctx->ttx_rtt));
 
 		ccid4_hc_tx_x_header_penalty(hctx);
-		hctx->tfrchctx_t_ld = now;
+		hctx->ttx_t_ld = now;
 	}
 
-	if (hctx->tfrchctx_x != old_x) {
+	if (hctx->ttx_x != old_x) {
 		ccid4_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
 			       "X_recv=%u\n", (unsigned)(old_x >> 6),
-			       (unsigned)(hctx->tfrchctx_x >> 6),
-			       hctx->tfrchctx_x_calc,
-			       (unsigned)(hctx->tfrchctx_x_recv >> 6));
+			       (unsigned)(hctx->ttx_x >> 6),
+			       hctx->ttx_x_calc,
+			       (unsigned)(hctx->ttx_x_recv >> 6));
 
 		ccid4_update_send_interval(hctx);
 	}
@@ -167,11 +167,11 @@ static void ccid4_hc_tx_update_x(struct 
  */
 static inline void ccid4_hc_tx_update_s(struct tfrc_hc_tx_sock *hctx, int len)
 {
-	const u16 old_s = hctx->tfrchctx_s;
+	const u16 old_s = hctx->ttx_s;
 
-	hctx->tfrchctx_s = tfrc_ewma(hctx->tfrchctx_s, len, 9);
+	hctx->ttx_s = tfrc_ewma(hctx->ttx_s, len, 9);
 
-	if (hctx->tfrchctx_s != old_s)
+	if (hctx->ttx_s != old_s)
 		ccid4_update_send_interval(hctx);
 }
 
@@ -189,22 +189,22 @@ static void ccid4_hc_tx_no_feedback_time
 	}
 
 	ccid4_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
-		       tfrc_tx_state_name(hctx->tfrchctx_state));
+		       tfrc_tx_state_name(hctx->ttx_state));
 
-	if (hctx->tfrchctx_state = TTX_STATE_FBACK)
+	if (hctx->ttx_state = TTX_STATE_FBACK)
 		ccid4_hc_tx_set_state(sk, TTX_STATE_NO_FBACK);
-	else if (hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
+	else if (hctx->ttx_state != TTX_STATE_NO_FBACK)
 		goto out;
 
 	/*
 	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
-	if (hctx->tfrchctx_t_rto = 0 ||	/* no feedback received yet */
-	    hctx->tfrchctx_p = 0) {
+	if (hctx->ttx_t_rto = 0 ||	/* no feedback received yet */
+	    hctx->ttx_p = 0) {
 
 		/* halve send rate directly */
-		hctx->tfrchctx_x = max(hctx->tfrchctx_x / 2,
-					(((__u64)hctx->tfrchctx_s) << 6) /
+		hctx->ttx_x = max(hctx->ttx_x / 2,
+					(((__u64)hctx->ttx_s) << 6) /
 								    TFRC_T_MBI);
 		ccid4_update_send_interval(hctx);
 	} else {
@@ -218,33 +218,33 @@ static void ccid4_hc_tx_no_feedback_time
 		 *
 		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		BUG_ON(hctx->tfrchctx_p && !hctx->tfrchctx_x_calc);
+		BUG_ON(hctx->ttx_p && !hctx->ttx_x_calc);
 
-		if (hctx->tfrchctx_x_calc > (hctx->tfrchctx_x_recv >> 5))
-			hctx->tfrchctx_x_recv -				max(hctx->tfrchctx_x_recv / 2,
-				    (((__u64)hctx->tfrchctx_s) << 6) /
+		if (hctx->ttx_x_calc > (hctx->ttx_x_recv >> 5))
+			hctx->ttx_x_recv +				max(hctx->ttx_x_recv / 2,
+				    (((__u64)hctx->ttx_s) << 6) /
 							      (2 * TFRC_T_MBI));
 		else {
-			hctx->tfrchctx_x_recv = hctx->tfrchctx_x_calc;
-			hctx->tfrchctx_x_recv <<= 4;
+			hctx->ttx_x_recv = hctx->ttx_x_calc;
+			hctx->ttx_x_recv <<= 4;
 		}
 		ccid4_hc_tx_update_x(sk, NULL);
 	}
 	ccid4_pr_debug("Reduced X to %llu/64 bytes/sec\n",
-			(unsigned long long)hctx->tfrchctx_x);
+			(unsigned long long)hctx->ttx_x);
 
 	/*
 	 * Set new timeout for the nofeedback timer.
 	 * See comments in packet_recv() regarding the value of t_RTO.
 	 */
-	if (unlikely(hctx->tfrchctx_t_rto = 0))	/* no feedback yet */
+	if (unlikely(hctx->ttx_t_rto = 0))	/* no feedback yet */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
 	else
-		t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
+		t_nfb = max(hctx->ttx_t_rto, 2 * hctx->ttx_t_ipi);
 
 restart_timer:
-	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->ttx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
@@ -272,18 +272,18 @@ static int ccid4_hc_tx_send_packet(struc
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	switch (hctx->tfrchctx_state) {
+	switch (hctx->ttx_state) {
 	case TTX_STATE_NO_SENT:
-		sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
+		sk_reset_timer(sk, &hctx->ttx_no_feedback_timer,
 			       (jiffies +
 				usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
-		hctx->tfrchctx_last_win_count	 = 0;
-		hctx->tfrchctx_t_last_win_count = now;
+		hctx->ttx_last_win_count	 = 0;
+		hctx->ttx_t_last_win_count = now;
 
 		/* Set t_0 for initial packet */
-		hctx->tfrchctx_t_nom = now;
+		hctx->ttx_t_nom = now;
 
-		hctx->tfrchctx_s = skb->len;
+		hctx->ttx_s = skb->len;
 
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
@@ -292,13 +292,13 @@ static int ccid4_hc_tx_send_packet(struc
 		 */
 		if (dp->dccps_syn_rtt) {
 			ccid4_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
-			hctx->tfrchctx_rtt  = dp->dccps_syn_rtt;
-			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
-			hctx->tfrchctx_t_ld = now;
+			hctx->ttx_rtt  = dp->dccps_syn_rtt;
+			hctx->ttx_x    = rfc3390_initial_rate(sk);
+			hctx->ttx_t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X_pps = 1 pkt/sec */
-			hctx->tfrchctx_x = hctx->tfrchctx_s;
-			hctx->tfrchctx_x <<= 6;
+			hctx->ttx_x = hctx->ttx_s;
+			hctx->ttx_x <<= 6;
 		}
 		ccid4_update_send_interval(hctx);
 
@@ -306,7 +306,7 @@ static int ccid4_hc_tx_send_packet(struc
 		break;
 	case TTX_STATE_NO_FBACK:
 	case TTX_STATE_FBACK:
-		delay = ktime_us_delta(hctx->tfrchctx_t_nom, now);
+		delay = ktime_us_delta(hctx->ttx_t_nom, now);
 		ccid4_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -316,7 +316,7 @@ static int ccid4_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->tfrchctx_delta >= 1000)
+		if (delay - (s64)hctx->ttx_delta >= 1000)
 			return (u32)delay / 1000L;
 
 		tfrc_hc_tx_update_win_count(hctx, now);
@@ -328,11 +328,11 @@ static int ccid4_hc_tx_send_packet(struc
 
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
-	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->tfrchctx_last_win_count;
+	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ttx_last_win_count;
 
 	/* set the nominal send time for the next following packet */
-	hctx->tfrchctx_t_nom = ktime_add_us(hctx->tfrchctx_t_nom,
-					     hctx->tfrchctx_t_ipi);
+	hctx->ttx_t_nom = ktime_add_us(hctx->ttx_t_nom,
+					     hctx->ttx_t_ipi);
 	return 0;
 }
 
@@ -343,7 +343,7 @@ static void ccid4_hc_tx_packet_sent(stru
 
 	ccid4_hc_tx_update_s(hctx, len);
 
-	if (tfrc_tx_hist_add(&hctx->tfrchctx_hist, dccp_sk(sk)->dccps_gss))
+	if (tfrc_tx_hist_add(&hctx->ttx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
 }
 
@@ -360,15 +360,15 @@ static void ccid4_hc_tx_packet_recv(stru
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 	/* ... and only in the established state */
-	if (hctx->tfrchctx_state != TTX_STATE_FBACK &&
-	    hctx->tfrchctx_state != TTX_STATE_NO_FBACK)
+	if (hctx->ttx_state != TTX_STATE_FBACK &&
+	    hctx->ttx_state != TTX_STATE_NO_FBACK)
 		return;
 
-	opt_recv = &hctx->tfrchctx_options_received;
+	opt_recv = &hctx->ttx_options_received;
 	now = ktime_get_real();
 
 	/* Estimate RTT from history if ACK number is valid */
-	r_sample = tfrc_tx_hist_rtt(hctx->tfrchctx_hist,
+	r_sample = tfrc_tx_hist_rtt(hctx->ttx_hist,
 				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
 	if (r_sample = 0) {
 		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
@@ -378,37 +378,37 @@ static void ccid4_hc_tx_packet_recv(stru
 	}
 
 	/* Update receive rate in units of 64 * bytes/second */
-	hctx->tfrchctx_x_recv = opt_recv->tfrcor_receive_rate;
-	hctx->tfrchctx_x_recv <<= 6;
+	hctx->ttx_x_recv = opt_recv->tfrcor_receive_rate;
+	hctx->ttx_x_recv <<= 6;
 
 	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->tfrcor_loss_event_rate;
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-		hctx->tfrchctx_p = 0;
+		hctx->ttx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->tfrchctx_p = scaled_div(1, pinv);
+		hctx->ttx_p = scaled_div(1, pinv);
 	/*
 	 * Validate new RTT sample and update moving average
 	 */
 	r_sample = dccp_sample_rtt(sk, r_sample);
-	hctx->tfrchctx_rtt = tfrc_ewma(hctx->tfrchctx_rtt, r_sample, 9);
+	hctx->ttx_rtt = tfrc_ewma(hctx->ttx_rtt, r_sample, 9);
 	/*
 	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
-	if (hctx->tfrchctx_state = TTX_STATE_NO_FBACK) {
+	if (hctx->ttx_state = TTX_STATE_NO_FBACK) {
 		ccid4_hc_tx_set_state(sk, TTX_STATE_FBACK);
 
-		if (hctx->tfrchctx_t_rto = 0) {
+		if (hctx->ttx_t_rto = 0) {
 			/*
 			 * Initial feedback packet: Larger Initial Windows (4.2)
 			 */
-			hctx->tfrchctx_x    = rfc3390_initial_rate(sk);
-			hctx->tfrchctx_t_ld = now;
+			hctx->ttx_x    = rfc3390_initial_rate(sk);
+			hctx->ttx_t_ld = now;
 
 			ccid4_update_send_interval(hctx);
 
 			goto done_computing_x;
-		} else if (hctx->tfrchctx_p = 0) {
+		} else if (hctx->ttx_p = 0) {
 			/*
 			 * First feedback after nofeedback timer expiry (4.3)
 			 */
@@ -417,25 +417,25 @@ static void ccid4_hc_tx_packet_recv(stru
 	}
 
 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-	if (hctx->tfrchctx_p > 0)
-		hctx->tfrchctx_x_calc +	if (hctx->ttx_p > 0)
+		hctx->ttx_x_calc  				tfrc_calc_x(NOM_PACKET_SIZE,
-					    hctx->tfrchctx_rtt,
-					    hctx->tfrchctx_p);
+					    hctx->ttx_rtt,
+					    hctx->ttx_p);
 	ccid4_hc_tx_update_x(sk, &now);
 
 done_computing_x:
 	ccid4_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
 			       dccp_role(sk),
-			       sk, hctx->tfrchctx_rtt, r_sample,
-			       hctx->tfrchctx_s, hctx->tfrchctx_p,
-			       hctx->tfrchctx_x_calc,
-			       (unsigned)(hctx->tfrchctx_x_recv >> 6),
-			       (unsigned)(hctx->tfrchctx_x >> 6));
+			       sk, hctx->ttx_rtt, r_sample,
+			       hctx->ttx_s, hctx->ttx_p,
+			       hctx->ttx_x_calc,
+			       (unsigned)(hctx->ttx_x_recv >> 6),
+			       (unsigned)(hctx->ttx_x >> 6));
 
 	/* unschedule no feedback timer */
-	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->ttx_no_feedback_timer);
 
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
@@ -449,21 +449,21 @@ done_computing_x:
 	 * This can help avoid triggering the nofeedback timer too
 	 * often ('spinning') on LANs with small RTTs.
 	 */
-	hctx->tfrchctx_t_rto = max_t(u32, 4 * hctx->tfrchctx_rtt,
+	hctx->ttx_t_rto = max_t(u32, 4 * hctx->ttx_rtt,
 					   (CONFIG_IP_DCCP_CCID4_RTO *
 					    (USEC_PER_SEC / 1000)));
 	/*
 	 * Schedule no feedback timer to expire in
 	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
 	 */
-	t_nfb = max(hctx->tfrchctx_t_rto, 2 * hctx->tfrchctx_t_ipi);
+	t_nfb = max(hctx->ttx_t_rto, 2 * hctx->ttx_t_ipi);
 
 	ccid4_pr_debug("%s(%p), Scheduled no feedback timer to "
 		       "expire in %lu jiffies (%luus)\n",
 		       dccp_role(sk),
 		       sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-	sk_reset_timer(sk, &hctx->tfrchctx_no_feedback_timer,
+	sk_reset_timer(sk, &hctx->ttx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
@@ -477,14 +477,14 @@ static int ccid4_hc_tx_parse_options(str
 	struct tfrc_options_received *opt_recv;
 	u32 opt_val;
 
-	opt_recv = &hctx->tfrchctx_options_received;
+	opt_recv = &hctx->ttx_options_received;
 
 	if (opt_recv->tfrcor_seqno != dp->dccps_gsr) {
-		opt_recv->tfrcor_seqno		     = dp->dccps_gsr;
+		opt_recv->tfrcor_seqno		    = dp->dccps_gsr;
 		opt_recv->tfrcor_loss_event_rate    = ~0;
 		opt_recv->tfrcor_loss_intervals_idx = 0;
 		opt_recv->tfrcor_loss_intervals_len = 0;
-		opt_recv->tfrcor_receive_rate	     = 0;
+		opt_recv->tfrcor_receive_rate	    = 0;
 	}
 
 	switch (option) {
@@ -536,9 +536,9 @@ static int ccid4_hc_tx_init(struct ccid 
 {
 	struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->tfrchctx_state = TTX_STATE_NO_SENT;
-	hctx->tfrchctx_hist = NULL;
-	setup_timer(&hctx->tfrchctx_no_feedback_timer,
+	hctx->ttx_state = TTX_STATE_NO_SENT;
+	hctx->ttx_hist = NULL;
+	setup_timer(&hctx->ttx_no_feedback_timer,
 			ccid4_hc_tx_no_feedback_timer, (unsigned long)sk);
 
 	return 0;
@@ -549,15 +549,15 @@ static void ccid4_hc_tx_exit(struct sock
 	struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
 
 	ccid4_hc_tx_set_state(sk, TTX_STATE_TERM);
-	sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
+	sk_stop_timer(sk, &hctx->ttx_no_feedback_timer);
 
-	tfrc_tx_hist_purge(&hctx->tfrchctx_hist);
+	tfrc_tx_hist_purge(&hctx->ttx_hist);
 }
 
 static void ccid4_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_rto = tfrc_hc_tx_sk(sk)->tfrchctx_t_rto;
-	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->tfrchctx_rtt;
+	info->tcpi_rto = tfrc_hc_tx_sk(sk)->ttx_t_rto;
+	info->tcpi_rtt = tfrc_hc_tx_sk(sk)->ttx_rtt;
 }
 
 static int ccid4_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
@@ -568,10 +568,10 @@ static int ccid4_hc_tx_getsockopt(struct
 
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
-		if (len < sizeof(hctx->tfrchctx_tfrc))
+		if (len < sizeof(hctx->ttx_tfrc))
 			return -EINVAL;
-		len = sizeof(hctx->tfrchctx_tfrc);
-		val = &hctx->tfrchctx_tfrc;
+		len = sizeof(hctx->ttx_tfrc);
+		val = &hctx->ttx_tfrc;
 		break;
 	default:
 		return -ENOPROTOOPT;
@@ -587,13 +587,13 @@ static void ccid4_hc_rx_set_state(struct
 				  enum tfrc_hc_rx_states state)
 {
 	struct tfrc_hc_rx_sock *hcrx = tfrc_hc_rx_sk(sk);
-	enum tfrc_hc_rx_states oldstate = hcrx->tfrchcrx_state;
+	enum tfrc_hc_rx_states oldstate = hcrx->trx_state;
 
 	ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
 		       dccp_role(sk), sk, tfrc_rx_state_name(oldstate),
 		       tfrc_rx_state_name(state));
 	WARN_ON(state = oldstate);
-	hcrx->tfrchcrx_state = state;
+	hcrx->trx_state = state;
 }
 
 static void ccid4_hc_rx_send_feedback(struct sock *sk,
@@ -605,13 +605,13 @@ static void ccid4_hc_rx_send_feedback(st
 	ktime_t now = ktime_get_real();
 	s64 delta = 0;
 
-	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_TERM))
+	if (unlikely(hcrx->trx_state = TRX_STATE_TERM))
 		return;
 
 	switch (fbtype) {
 	case TFRC_FBACK_INITIAL:
-		hcrx->tfrchcrx_x_recv = 0;
-		hcrx->tfrchcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
+		hcrx->trx_x_recv = 0;
+		hcrx->trx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
 	case TFRC_FBACK_PARAM_CHANGE:
 		/*
@@ -624,26 +624,26 @@ static void ccid4_hc_rx_send_feedback(st
 		 * the number of bytes since last feedback.
 		 * This is a safe fallback, since X is bounded above by X_calc.
 		 */
-		if (hcrx->tfrchcrx_x_recv > 0)
+		if (hcrx->trx_x_recv > 0)
 			break;
 		/* fall through */
 	case TFRC_FBACK_PERIODIC:
-		delta = ktime_us_delta(now, hcrx->tfrchcrx_last_feedback);
+		delta = ktime_us_delta(now, hcrx->trx_last_feedback);
 		if (delta <= 0)
 			DCCP_BUG("delta (%ld) <= 0", (long)delta);
 		else
-			hcrx->tfrchcrx_x_recv -				scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
+			hcrx->trx_x_recv +				scaled_div32(hcrx->trx_bytes_recv, delta);
 		break;
 	default:
 		return;
 	}
 	ccid4_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
-		       hcrx->tfrchcrx_x_recv, hcrx->tfrchcrx_pinv);
+		       hcrx->trx_x_recv, hcrx->trx_pinv);
 
-	hcrx->tfrchcrx_last_feedback = now;
-	hcrx->tfrchcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
-	hcrx->tfrchcrx_bytes_recv    = 0;
+	hcrx->trx_last_feedback = now;
+	hcrx->trx_last_counter  = dccp_hdr(skb)->dccph_ccval;
+	hcrx->trx_bytes_recv    = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -660,8 +660,8 @@ static int ccid4_hc_rx_insert_options(st
 	if (dccp_packet_without_ack(skb))
 		return 0;
 
-	x_recv = htonl(hcrx->tfrchcrx_x_recv);
-	pinv   = htonl(hcrx->tfrchcrx_pinv);
+	x_recv = htonl(hcrx->trx_x_recv);
+	pinv   = htonl(hcrx->trx_pinv);
 
 	if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
@@ -687,22 +687,22 @@ static u32 ccid4_first_li(struct sock *s
 	u32 x_recv, p, delta;
 	u64 fval;
 
-	if (hcrx->tfrchcrx_rtt = 0) {
+	if (hcrx->trx_rtt = 0) {
 		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
-		hcrx->tfrchcrx_rtt = DCCP_FALLBACK_RTT;
+		hcrx->trx_rtt = DCCP_FALLBACK_RTT;
 	}
 
-	delta = ktime_to_us(net_timedelta(hcrx->tfrchcrx_last_feedback));
-	x_recv = scaled_div32(hcrx->tfrchcrx_bytes_recv, delta);
+	delta = ktime_to_us(net_timedelta(hcrx->trx_last_feedback));
+	x_recv = scaled_div32(hcrx->trx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->tfrchcrx_x_recv) = 0) {
+		if ((x_recv = hcrx->trx_x_recv) = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0U;
 		}
 	}
 
-	fval = scaled_div(NOM_PACKET_SIZE, hcrx->tfrchcrx_rtt);
+	fval = scaled_div(NOM_PACKET_SIZE, hcrx->trx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -719,14 +719,14 @@ static void ccid4_hc_rx_packet_recv(stru
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool  is_data_packet = dccp_data_packet(skb);
 
-	if (unlikely(hcrx->tfrchcrx_state = TRX_STATE_NO_DATA)) {
+	if (unlikely(hcrx->trx_state = TRX_STATE_NO_DATA)) {
 		if (is_data_packet) {
 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 			do_feedback = TFRC_FBACK_INITIAL;
 			ccid4_hc_rx_set_state(sk, TRX_STATE_DATA);
-			hcrx->tfrchcrx_s = payload;
+			hcrx->trx_s = payload;
                        /*
-                        * Not necessary to update tfrchcrx_bytes_recv here,
+                        * Not necessary to update trx_bytes_recv here,
                         * since X_recv = 0 for the first feedback packet (cf.
                         * RFC 3448, 6.3) -- gerrit
                         */
@@ -735,7 +735,7 @@ static void ccid4_hc_rx_packet_recv(stru
 		goto update_records;
 	}
 
-	if (tfrc_rx_hist_duplicate(&hcrx->tfrchcrx_hist, skb))
+	if (tfrc_rx_hist_duplicate(&hcrx->trx_hist, skb))
 		return; /* done receiving */
 
 	if (is_data_packet) {
@@ -743,22 +743,21 @@ static void ccid4_hc_rx_packet_recv(stru
 		/*
 		 * Update moving-average of s and the sum of received payload bytes
 		 */
-		hcrx->tfrchcrx_s = tfrc_ewma(hcrx->tfrchcrx_s, payload, 9);
-		hcrx->tfrchcrx_bytes_recv += payload;
+		hcrx->trx_s = tfrc_ewma(hcrx->trx_s, payload, 9);
+		hcrx->trx_bytes_recv += payload;
 	}
 
 	/*
 	 * Handle pending losses and otherwise check for new loss
 	 */
-	if (tfrc_rx_hist_loss_pending(&hcrx->tfrchcrx_hist) &&
-	    tfrc_rx_handle_loss(&hcrx->tfrchcrx_hist,
-				&hcrx->tfrchcrx_li_hist,
+	if (tfrc_rx_hist_loss_pending(&hcrx->trx_hist) &&
+	    tfrc_rx_handle_loss(&hcrx->trx_hist, &hcrx->trx_li_hist,
 				skb, ndp, ccid4_first_li, sk) ) {
 		do_feedback = TFRC_FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_hist_new_loss_indicated(&hcrx->tfrchcrx_hist, skb, ndp))
+	if (tfrc_rx_hist_new_loss_indicated(&hcrx->trx_hist, skb, ndp))
 		goto update_records;
 
 	/*
@@ -767,17 +766,17 @@ static void ccid4_hc_rx_packet_recv(stru
 	if (unlikely(!is_data_packet))
 		goto update_records;
 
-	if (!tfrc_lh_is_initialised(&hcrx->tfrchcrx_li_hist)) {
-		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->tfrchcrx_hist, skb);
+	if (!tfrc_lh_is_initialised(&hcrx->trx_li_hist)) {
+		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->trx_hist, skb);
 		/*
 		 * Empty loss history: no loss so far, hence p stays 0.
 		 * Sample RTT values, since an RTT estimate is required for the
 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
 		 */
 		if (sample != 0)
-			hcrx->tfrchcrx_rtt = tfrc_ewma(hcrx->tfrchcrx_rtt, sample, 9);
+			hcrx->trx_rtt = tfrc_ewma(hcrx->trx_rtt, sample, 9);
 
-	} else if (tfrc_lh_update_i_mean(&hcrx->tfrchcrx_li_hist, skb))
+	} else if (tfrc_lh_update_i_mean(&hcrx->trx_li_hist, skb))
 		/*
 		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
 		 * has decreased (resp. p has increased), send feedback now.
@@ -787,11 +786,11 @@ static void ccid4_hc_rx_packet_recv(stru
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->tfrchcrx_last_counter) > 3)
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->trx_last_counter) > 3)
 		do_feedback = TFRC_FBACK_PERIODIC;
 
 update_records:
-	tfrc_rx_hist_add_packet(&hcrx->tfrchcrx_hist, skb, ndp);
+	tfrc_rx_hist_add_packet(&hcrx->trx_hist, skb, ndp);
 
 done_receiving:
 	if (do_feedback)
@@ -802,9 +801,9 @@ static int ccid4_hc_rx_init(struct ccid 
 {
 	struct tfrc_hc_rx_sock *hcrx = ccid_priv(ccid);
 
-	hcrx->tfrchcrx_state = TRX_STATE_NO_DATA;
-	tfrc_lh_init(&hcrx->tfrchcrx_li_hist);
-	return tfrc_rx_hist_alloc(&hcrx->tfrchcrx_hist);
+	hcrx->trx_state = TRX_STATE_NO_DATA;
+	tfrc_lh_init(&hcrx->trx_li_hist);
+	return tfrc_rx_hist_alloc(&hcrx->trx_hist);
 }
 
 static void ccid4_hc_rx_exit(struct sock *sk)
@@ -813,15 +812,15 @@ static void ccid4_hc_rx_exit(struct sock
 
 	ccid4_hc_rx_set_state(sk, TRX_STATE_TERM);
 
-	tfrc_rx_hist_purge(&hcrx->tfrchcrx_hist);
-	tfrc_lh_cleanup(&hcrx->tfrchcrx_li_hist);
+	tfrc_rx_hist_purge(&hcrx->trx_hist);
+	tfrc_lh_cleanup(&hcrx->trx_li_hist);
 }
 
 static void ccid4_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	info->tcpi_ca_state = tfrc_hc_rx_sk(sk)->tfrchcrx_state;
+	info->tcpi_ca_state = tfrc_hc_rx_sk(sk)->trx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt  = tfrc_hc_rx_sk(sk)->tfrchcrx_rtt;
+	info->tcpi_rcv_rtt  = tfrc_hc_rx_sk(sk)->trx_rtt;
 }
 
 static int ccid4_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
@@ -835,10 +834,10 @@ static int ccid4_hc_rx_getsockopt(struct
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(rx_info))
 			return -EINVAL;
-		rx_info.tfrcrx_x_recv = hcrx->tfrchcrx_x_recv;
-		rx_info.tfrcrx_rtt    = hcrx->tfrchcrx_rtt;
-		rx_info.tfrcrx_p      = hcrx->tfrchcrx_pinv = 0 ? ~0U :
-					   scaled_div(1, hcrx->tfrchcrx_pinv);
+		rx_info.tfrcrx_x_recv = hcrx->trx_x_recv;
+		rx_info.tfrcrx_rtt    = hcrx->trx_rtt;
+		rx_info.tfrcrx_p      = hcrx->trx_pinv = 0 ? ~0U :
+					   scaled_div(1, hcrx->trx_pinv);
 		len = sizeof(rx_info);
 		val = &rx_info;
 		break;
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.c
@@ -23,19 +23,19 @@
 inline u64 rfc3390_initial_rate(struct sock *sk)
 {
 	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
-	const __u32 w_init = min_t(__u32, 4 * hctx->tfrchctx_s,
-				   max_t(__u32, 2 * hctx->tfrchctx_s, 4380));
+	const __u32 w_init = min_t(__u32, 4 * hctx->ttx_s,
+				   max_t(__u32, 2 * hctx->ttx_s, 4380));
 
-	return scaled_div(w_init << 6, hctx->tfrchctx_rtt);
+	return scaled_div(w_init << 6, hctx->ttx_rtt);
 }
 
 EXPORT_SYMBOL_GPL(rfc3390_initial_rate);
 
 u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now)
 {
-	u32 delta = ktime_us_delta(now, hctx->tfrchctx_t_last_win_count);
+	u32 delta = ktime_us_delta(now, hctx->ttx_t_last_win_count);
 
-	return delta / hctx->tfrchctx_rtt;
+	return delta / hctx->ttx_rtt;
 }
 
 EXPORT_SYMBOL_GPL(tfrc_hc_tx_idle_rtt);
@@ -49,16 +49,16 @@ inline void tfrc_hc_tx_update_win_count(
 {
 	u32 quarter_rtts;
 
-	if (unlikely(hctx->tfrchctx_rtt < 4))	/* avoid divide-by-zero */
+	if (unlikely(hctx->ttx_rtt < 4))	/* avoid divide-by-zero */
 		return;
 
-	quarter_rtts = ktime_us_delta(now, hctx->tfrchctx_t_last_win_count);
-	quarter_rtts /= hctx->tfrchctx_rtt / 4;
+	quarter_rtts = ktime_us_delta(now, hctx->ttx_t_last_win_count);
+	quarter_rtts /= hctx->ttx_rtt / 4;
 
 	if (quarter_rtts > 0) {
-		hctx->tfrchctx_t_last_win_count = now;
-		hctx->tfrchctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
-		hctx->tfrchctx_last_win_count	&= 0xF;		/* mod 16 */
+		hctx->ttx_t_last_win_count = now;
+		hctx->ttx_last_win_count	+= min_t(u32, quarter_rtts, 5);
+		hctx->ttx_last_win_count	&= 0xF;		/* mod 16 */
 	}
 }
 
Index: ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- ccid4.latest.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ ccid4.latest/net/dccp/ccids/lib/tfrc_ccids.h
@@ -73,44 +73,44 @@ enum tfrc_fback_type {
 
 /** struct tfrc_hc_tx_sock - CCID3/4 sender half-connection socket
  *
- * @tfrchctx_x - Current sending rate in 64 * bytes per second
- * @tfrchctx_x_recv - Receive rate    in 64 * bytes per second
- * @tfrchctx_x_calc - Calculated rate in bytes per second
- * @tfrchctx_rtt - Estimate of current round trip time in usecs
- * @tfrchctx_p - Current loss event rate (0-1) scaled by 1000000
- * @tfrchctx_s - Packet size in bytes
- * @tfrchctx_t_rto - Nofeedback Timer setting in usecs
- * @tfrchctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
- * @tfrchctx_state - Sender state, one of %tfrc_hc_tx_states
- * @tfrchctx_last_win_count - Last window counter sent
- * @tfrchctx_t_last_win_count - Timestamp of earliest packet
+ * @ttx_x - Current sending rate in 64 * bytes per second
+ * @ttx_x_recv - Receive rate    in 64 * bytes per second
+ * @ttx_x_calc - Calculated rate in bytes per second
+ * @ttx_rtt - Estimate of current round trip time in usecs
+ * @ttx_p - Current loss event rate (0-1) scaled by 1000000
+ * @ttx_s - Packet size in bytes
+ * @ttx_t_rto - Nofeedback Timer setting in usecs
+ * @ttx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
+ * @ttx_state - Sender state, one of %tfrc_hc_tx_states
+ * @ttx_last_win_count - Last window counter sent
+ * @ttx_t_last_win_count - Timestamp of earliest packet
  *				 with last_win_count value sent
- * @tfrchctx_no_feedback_timer - Handle to no feedback timer
- * @tfrchctx_t_ld - Time last doubled during slow start
- * @tfrchctx_t_nom - Nominal send time of next packet
- * @tfrchctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
- * @tfrchctx_hist - Packet history
- * @tfrchctx_options_received - Parsed set of retrieved options
+ * @ttx_no_feedback_timer - Handle to no feedback timer
+ * @ttx_t_ld - Time last doubled during slow start
+ * @ttx_t_nom - Nominal send time of next packet
+ * @ttx_delta - Send timer delta (RFC 3448, 4.6) in usecs
+ * @ttx_hist - Packet history
+ * @ttx_options_received - Parsed set of retrieved options
  */
 struct tfrc_hc_tx_sock {
-	struct tfrc_tx_info		tfrchctx_tfrc;
-#define tfrchctx_x			tfrchctx_tfrc.tfrctx_x
-#define tfrchctx_x_recv		tfrchctx_tfrc.tfrctx_x_recv
-#define tfrchctx_x_calc		tfrchctx_tfrc.tfrctx_x_calc
-#define tfrchctx_rtt			tfrchctx_tfrc.tfrctx_rtt
-#define tfrchctx_p			tfrchctx_tfrc.tfrctx_p
-#define tfrchctx_t_rto			tfrchctx_tfrc.tfrctx_rto
-#define tfrchctx_t_ipi			tfrchctx_tfrc.tfrctx_ipi
-	u16				tfrchctx_s;
-	enum tfrc_hc_tx_states	tfrchctx_state:8;
-	u8				tfrchctx_last_win_count;
-	ktime_t				tfrchctx_t_last_win_count;
-	struct timer_list		tfrchctx_no_feedback_timer;
-	ktime_t				tfrchctx_t_ld;
-	ktime_t				tfrchctx_t_nom;
-	u32				tfrchctx_delta;
-	struct tfrc_tx_hist_entry	*tfrchctx_hist;
-	struct tfrc_options_received	tfrchctx_options_received;
+	struct tfrc_tx_info		ttx_tfrc;
+#define ttx_x				ttx_tfrc.x
+#define ttx_x_recv			ttx_tfrc.x_recv
+#define ttx_x_calc			ttx_tfrc.x_calc
+#define ttx_rtt				ttx_tfrc.rtt
+#define ttx_p				ttx_tfrc.p
+#define ttx_t_rto			ttx_tfrc.rto
+#define ttx_t_ipi			ttx_tfrc.ipi
+	u16				ttx_s;
+	enum tfrc_hc_tx_states		ttx_state:8;
+	u8				ttx_last_win_count;
+	ktime_t				ttx_t_last_win_count;
+	struct timer_list		ttx_no_feedback_timer;
+	ktime_t				ttx_t_ld;
+	ktime_t				ttx_t_nom;
+	u32				ttx_delta;
+	struct tfrc_tx_hist_entry	*ttx_hist;
+	struct tfrc_options_received	ttx_options_received;
 };
 
 static inline struct tfrc_hc_tx_sock *tfrc_hc_tx_sk(const struct sock *sk)
@@ -122,28 +122,28 @@ static inline struct tfrc_hc_tx_sock *tf
 
 /** struct tfrc_hc_rx_sock - CCID3/4 receiver half-connection socket
  *
- *  @tfrchcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @tfrchcrx_state  -  Receiver state, one of %tfrc_hc_rx_states
- *  @tfrchcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @tfrchcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @tfrchcrx_rtt  -  Receiver estimate of RTT
- *  @tfrchcrx_last_feedback  -  Time at which last feedback was sent
- *  @tfrchcrx_hist  -  Packet history, exported by TFRC module
- *  @tfrchcrx_li_hist  -  Loss Interval database, exported by TFRC module
- *  @tfrchcrx_s  -  Received packet size in bytes
- *  @tfrchcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ *  @trx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @trx_state  -  Receiver state, one of %tfrc_hc_rx_states
+ *  @trx_bytes_recv  -  Total sum of DCCP payload bytes
+ *  @trx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ *  @trx_rtt  -  Receiver estimate of RTT
+ *  @trx_last_feedback  -  Time at which last feedback was sent
+ *  @trx_hist  -  Packet history, exported by TFRC module
+ *  @trx_li_hist  -  Loss Interval database, exported by TFRC module
+ *  @trx_s  -  Received packet size in bytes
+ *  @trx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
 struct tfrc_hc_rx_sock {
-	u8				tfrchcrx_last_counter:4;
-	enum tfrc_hc_rx_states	tfrchcrx_state:8;
-	u32				tfrchcrx_bytes_recv;
-	u32				tfrchcrx_x_recv;
-	u32				tfrchcrx_rtt;
-	ktime_t				tfrchcrx_last_feedback;
-	struct tfrc_rx_hist		tfrchcrx_hist;
-	struct tfrc_loss_hist		tfrchcrx_li_hist;
-	u16				tfrchcrx_s;
-#define tfrchcrx_pinv			tfrchcrx_li_hist.i_mean
+	u8				trx_last_counter:4;
+	enum tfrc_hc_rx_states	trx_state:8;
+	u32				trx_bytes_recv;
+	u32				trx_x_recv;
+	u32				trx_rtt;
+	ktime_t				trx_last_feedback;
+	struct tfrc_rx_hist		trx_hist;
+	struct tfrc_loss_hist		trx_li_hist;
+	u16				trx_s;
+#define trx_pinv			trx_li_hist.i_mean
 };
 
 static inline struct tfrc_hc_rx_sock *tfrc_hc_rx_sk(const struct sock *sk)
@@ -193,4 +193,3 @@ extern u32 tfrc_hc_tx_idle_rtt(struct tf
 
 extern void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
 				          ktime_t now);
-
