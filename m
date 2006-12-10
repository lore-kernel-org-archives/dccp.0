From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 18:06:43 +0000
Subject: [PATCH 2/2] [DCCP]: Whitespace cleanups
Message-Id: <20061210180641.GC25274@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

That accumulated over the last months hackaton, shame on me for not
using git-apply whitespace helping hand, will do that from now on.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 include/linux/dccp.h   |   26 ++++++-----
 net/dccp/ackvec.c      |    4 +-
 net/dccp/ccids/ccid2.c |   12 +++--
 net/dccp/ccids/ccid3.c |  111 +++++++++++++++++++++++++++---------------------
 net/dccp/ccids/ccid3.h |   22 +++++-----
 net/dccp/feat.c        |    6 +--
 net/dccp/input.c       |   26 ++++++-----
 net/dccp/ipv4.c        |   26 ++++++-----
 net/dccp/ipv6.c        |   24 +++++-----
 net/dccp/minisocks.c   |    2 -
 net/dccp/output.c      |    7 +--
 net/dccp/proto.c       |    6 +--
 net/dccp/timer.c       |   14 +++---
 13 files changed, 149 insertions(+), 137 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index ed6cc89..1cb054b 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -176,20 +176,20 @@ enum {
 };
 
 /* DCCP features (RFC 4340 section 6.4) */
- enum {
- 	DCCPF_RESERVED = 0,
- 	DCCPF_CCID = 1,
+enum {
+	DCCPF_RESERVED = 0,
+	DCCPF_CCID = 1,
 	DCCPF_SHORT_SEQNOS = 2,		/* XXX: not yet implemented */
- 	DCCPF_SEQUENCE_WINDOW = 3,
+	DCCPF_SEQUENCE_WINDOW = 3,
 	DCCPF_ECN_INCAPABLE = 4,	/* XXX: not yet implemented */
- 	DCCPF_ACK_RATIO = 5,
- 	DCCPF_SEND_ACK_VECTOR = 6,
- 	DCCPF_SEND_NDP_COUNT = 7,
+	DCCPF_ACK_RATIO = 5,
+	DCCPF_SEND_ACK_VECTOR = 6,
+	DCCPF_SEND_NDP_COUNT = 7,
 	DCCPF_MIN_CSUM_COVER = 8,
 	DCCPF_DATA_CHECKSUM = 9,	/* XXX: not yet implemented */
- 	/* 10-127 reserved */
- 	DCCPF_MIN_CCID_SPECIFIC = 128,
- 	DCCPF_MAX_CCID_SPECIFIC = 255,
+	/* 10-127 reserved */
+	DCCPF_MIN_CCID_SPECIFIC = 128,
+	DCCPF_MAX_CCID_SPECIFIC = 255,
 };
 
 /* this structure is argument to DCCP_SOCKOPT_CHANGE_X */
@@ -427,7 +427,7 @@ struct dccp_service_list {
 };
 
 #define DCCP_SERVICE_INVALID_VALUE htonl((__u32)-1)
-#define DCCP_SERVICE_CODE_IS_ABSENT 		 0
+#define DCCP_SERVICE_CODE_IS_ABSENT		0
 
 static inline int dccp_list_has_service(const struct dccp_service_list *sl,
 					const __be32 service)
@@ -436,7 +436,7 @@ static inline int dccp_list_has_service(
 		u32 i = sl->dccpsl_nr;
 		while (i--)
 			if (sl->dccpsl_list[i] = service)
-				return 1; 
+				return 1;
 	}
 	return 0;
 }
@@ -511,7 +511,7 @@ struct dccp_sock {
 	__u8				dccps_hc_tx_insert_options:1;
 	struct timer_list		dccps_xmit_timer;
 };
- 
+
 static inline struct dccp_sock *dccp_sk(const struct sock *sk)
 {
 	return (struct dccp_sock *)sk;
diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 1f4727d..a086c63 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -223,7 +223,7 @@ static inline int dccp_ackvec_set_buf_he
 			gap = -new_head;
 		}
 		new_head += DCCP_MAX_ACKVEC_LEN;
-	} 
+	}
 
 	av->dccpav_buf_head = new_head;
 
@@ -336,7 +336,7 @@ #ifdef CONFIG_IP_DCCP_DEBUG
 void dccp_ackvector_print(const u64 ackno, const unsigned char *vector, int len)
 {
 	dccp_pr_debug_cat("ACK vector len=%d, ackno=%llu |", len,
-			 		(unsigned long long)ackno);
+			 (unsigned long long)ackno);
 
 	while (len--) {
 		const u8 state = (*vector & DCCP_ACKVEC_STATE_MASK) >> 6;
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 2555be8..fd38b05 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -351,7 +351,7 @@ #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 
 		while (seqp != hctx->ccid2hctx_seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
-			       	       (unsigned long long)seqp->ccid2s_seq,
+				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
 		}
@@ -473,7 +473,7 @@ static inline void ccid2_new_ack(struct 
 		/* first measurement */
 		if (hctx->ccid2hctx_srtt = -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
-			       	       r, jiffies,
+				       r, jiffies,
 				       (unsigned long long)seqp->ccid2s_seq);
 			ccid2_change_srtt(hctx, r);
 			hctx->ccid2hctx_rttvar = r >> 1;
@@ -518,8 +518,8 @@ #endif
 		hctx->ccid2hctx_lastrtt = jiffies;
 
 		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
-		       	       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
-		       	       hctx->ccid2hctx_rto, HZ, r);
+			       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
+			       hctx->ccid2hctx_rto, HZ, r);
 		hctx->ccid2hctx_sent = 0;
 	}
 
@@ -667,9 +667,9 @@ static void ccid2_hc_tx_packet_recv(stru
 				/* new packet received or marked */
 				if (state != DCCP_ACKVEC_STATE_NOT_RECEIVED &&
 				    !seqp->ccid2s_acked) {
-				    	if (state =
+					if (state =
 					    DCCP_ACKVEC_STATE_ECN_MARKED) {
-					    	ccid2_congestion_event(hctx,
+						ccid2_congestion_event(hctx,
 								       seqp);
 					} else
 						ccid2_new_ack(sk, seqp,
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 5e817e2..fa6b753 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -124,18 +124,18 @@ static void ccid3_hc_tx_update_x(struct 
 	if (hctx->ccid3hctx_p > 0) {
 
 		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
-					hctx->ccid3hctx_x_recv * 2           );
+					hctx->ccid3hctx_x_recv * 2);
 		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
 					(((__u64)hctx->ccid3hctx_s) << 6) /
-					 			   TFRC_T_MBI);
+								TFRC_T_MBI);
 
 	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) -
-			(suseconds_t)hctx->ccid3hctx_rtt >= 0 ) {
+			(suseconds_t)hctx->ccid3hctx_rtt >= 0) {
 
 		hctx->ccid3hctx_x  			max(2 * min(hctx->ccid3hctx_x, hctx->ccid3hctx_x_recv),
 			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-				       hctx->ccid3hctx_rtt             )      );
+				       hctx->ccid3hctx_rtt));
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
@@ -144,8 +144,8 @@ static void ccid3_hc_tx_update_x(struct 
 }
 
 /*
- * 	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
- * 	@len: DCCP packet payload size in bytes
+ *	Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
+ *	@len: DCCP packet payload size in bytes
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
@@ -163,8 +163,8 @@ static inline void ccid3_hc_tx_update_s(
 }
 
 /*
- * 	Update Window Counter using the algorithm from [RFC 4342, 8.1].
- * 	The algorithm is not applicable if RTT < 4 microseconds.
+ *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
+ *	The algorithm is not applicable if RTT < 4 microseconds.
  */
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
 						struct timeval *now)
@@ -228,12 +228,13 @@ static void ccid3_hc_tx_no_feedback_time
 		 */
 		if (!hctx->ccid3hctx_idle ||
 		    (hctx->ccid3hctx_x_recv >= 4 *
-		     scaled_div(((__u64)hctx->ccid3hctx_s) << 6, hctx->ccid3hctx_rtt))) {
+		     scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
+				hctx->ccid3hctx_rtt))) {
 			struct timeval now;
 
 			ccid3_pr_debug("%s(%p, state=%s), not idle\n",
 				       dccp_role(sk), sk,
-				       ccid3_tx_state_name(hctx->ccid3hctx_state));
+				   ccid3_tx_state_name(hctx->ccid3hctx_state));
 
 			/*
 			 *  Modify the cached value of X_recv [RFC 3448, 4.4]
@@ -248,12 +249,13 @@ static void ccid3_hc_tx_no_feedback_time
 			BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
 			if (hctx->ccid3hctx_p  = 0 ||
-			    hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))  {
+			    (hctx->ccid3hctx_x_calc >
+			     (hctx->ccid3hctx_x_recv >> 5))) {
 
 				hctx->ccid3hctx_x_recv  					max(hctx->ccid3hctx_x_recv / 2,
 					    (((__u64)hctx->ccid3hctx_s) << 6) /
-					      			(2*TFRC_T_MBI));
+							  (2 * TFRC_T_MBI));
 
 				if (hctx->ccid3hctx_p = 0)
 					dccp_timestamp(sk, &now);
@@ -316,7 +318,8 @@ static int ccid3_hc_tx_send_packet(struc
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-			       jiffies + usecs_to_jiffies(TFRC_INITIAL_TIMEOUT));
+			       (jiffies +
+			        usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
 		hctx->ccid3hctx_last_win_count	 = 0;
 		hctx->ccid3hctx_t_last_win_count = now;
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
@@ -338,7 +341,7 @@ static int ccid3_hc_tx_send_packet(struc
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
 		/*
-		 * 	Scheduling of packet transmissions [RFC 3448, 4.6]
+		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
 		 * if (t_now > t_nom - delta)
 		 *       // send the packet now
@@ -365,7 +368,8 @@ static int ccid3_hc_tx_send_packet(struc
 	return 0;
 }
 
-static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
+static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
+				    unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
@@ -415,12 +419,12 @@ static void ccid3_hc_tx_packet_recv(stru
 	case TFRC_SSTATE_FBACK:
 		/* get packet from history to look up t_recvdata */
 		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
-						 DCCP_SKB_CB(skb)->dccpd_ack_seq);
+					      DCCP_SKB_CB(skb)->dccpd_ack_seq);
 		if (unlikely(packet = NULL)) {
 			DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist "
 				  "in history!\n",  dccp_role(sk), sk,
 			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+				dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
 			return;
 		}
 
@@ -433,13 +437,13 @@ static void ccid3_hc_tx_packet_recv(stru
 		if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
 			hctx->ccid3hctx_p = 0;
 		else				       /* can not exceed 100% */
- 			hctx->ccid3hctx_p = 1000000 / pinv;
+			hctx->ccid3hctx_p = 1000000 / pinv;
 
 		dccp_timestamp(sk, &now);
 
 		/*
 		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
-		 * 	R_sample  =  (now - t_recvdata) - t_elapsed
+		 *	R_sample  =  (now - t_recvdata) - t_elapsed
 		 */
 		r_sample  = timeval_delta(&now, &packet->dccphtx_tstamp);
 		t_elapsed = dp->dccps_options_received.dccpor_elapsed_time * 10;
@@ -465,7 +469,7 @@ static void ccid3_hc_tx_packet_recv(stru
 			 * Larger Initial Windows [RFC 4342, sec. 5]
 			 * We deviate in that we use `s' instead of `MSS'.
 			 */
-			__u64 w_init = min(    4 * hctx->ccid3hctx_s,
+			__u64 w_init = min(4 * hctx->ccid3hctx_s,
 					   max(2 * hctx->ccid3hctx_s, 4380));
 			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
@@ -475,13 +479,14 @@ static void ccid3_hc_tx_packet_recv(stru
 
 			ccid3_pr_debug("%s(%p), s=%u, w_init=%llu, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_s, w_init, (int)r_sample,
+				       sk, hctx->ccid3hctx_s, w_init,
+				       (int)r_sample,
 				       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
 			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
-					           (u32)r_sample        ) / 10;
+					           (u32)r_sample) / 10;
 
 			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
 			if (hctx->ccid3hctx_p > 0)
@@ -492,12 +497,13 @@ static void ccid3_hc_tx_packet_recv(stru
 			ccid3_hc_tx_update_x(sk, &now);
 
 			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%dus), s=%u, "
-				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n", dccp_role(sk),
+				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
+				       dccp_role(sk),
 				       sk, hctx->ccid3hctx_rtt, (int)r_sample,
 				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
 				       hctx->ccid3hctx_x_calc,
 				       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-				       (unsigned)(hctx->ccid3hctx_x >> 6)     );
+				       (unsigned)(hctx->ccid3hctx_x >> 6));
 		}
 
 		/* unschedule no feedback timer */
@@ -507,20 +513,20 @@ static void ccid3_hc_tx_packet_recv(stru
 		dccp_tx_hist_purge_older(ccid3_tx_hist,
 					 &hctx->ccid3hctx_hist, packet);
 		/*
-		 * As we have calculated new ipi, delta, t_nom it is possible that
-		 * we now can send a packet, so wake up dccp_wait_for_ccid
+		 * As we have calculated new ipi, delta, t_nom it is possible
+		 * that we now can send a packet, so wake up dccp_wait_for_ccid
 		 */
 		sk->sk_write_space(sk);
 
 		/*
 		 * Update timeout interval for the nofeedback timer.
 		 * We use a configuration option to increase the lower bound.
-		 * This can help avoid triggering the nofeedback timer too often
-		 * ('spinning') on LANs with small RTTs.
+		 * This can help avoid triggering the nofeedback timer too
+		 * often ('spinning') on LANs with small RTTs.
 		 */
 		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
 						   CONFIG_IP_DCCP_CCID3_RTO *
-						   (USEC_PER_SEC/1000)	     );
+						   (USEC_PER_SEC/1000));
 		/*
 		 * Schedule no feedback timer to expire in
 		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
@@ -528,7 +534,8 @@ static void ccid3_hc_tx_packet_recv(stru
 		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 
 		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
-			       "expire in %lu jiffies (%luus)\n", dccp_role(sk),
+			       "expire in %lu jiffies (%luus)\n",
+			       dccp_role(sk),
 			       sk, usecs_to_jiffies(t_nfb), t_nfb);
 
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
@@ -538,7 +545,9 @@ static void ccid3_hc_tx_packet_recv(stru
 		hctx->ccid3hctx_idle = 1;
 		break;
 	case TFRC_SSTATE_NO_SENT:
-		/* XXX when implementing bidirectional rx/tx check this again */
+		/*
+		 * XXX when implementing bidirectional rx/tx check this again
+		 */
 		DCCP_WARN("Illegal ACK received - no packet sent\n");
 		/* fall through */
 	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
@@ -575,7 +584,8 @@ static int ccid3_hc_tx_parse_options(str
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
-			opt_recv->ccid3or_loss_event_rate = ntohl(*(__be32 *)value);
+			opt_recv->ccid3or_loss_event_rate +						ntohl(*(__be32 *)value);
 			ccid3_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_loss_event_rate);
@@ -596,7 +606,8 @@ static int ccid3_hc_tx_parse_options(str
 				  dccp_role(sk), sk, len);
 			rc = -EINVAL;
 		} else {
-			opt_recv->ccid3or_receive_rate = ntohl(*(__be32 *)value);
+			opt_recv->ccid3or_receive_rate +						ntohl(*(__be32 *)value);
 			ccid3_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
 				       dccp_role(sk), sk,
 				       opt_recv->ccid3or_receive_rate);
@@ -616,7 +627,8 @@ static int ccid3_hc_tx_init(struct ccid 
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
 
-	hctx->ccid3hctx_no_feedback_timer.function = ccid3_hc_tx_no_feedback_timer;
+	hctx->ccid3hctx_no_feedback_timer.function +				ccid3_hc_tx_no_feedback_timer;
 	hctx->ccid3hctx_no_feedback_timer.data     = (unsigned long)sk;
 	init_timer(&hctx->ccid3hctx_no_feedback_timer);
 
@@ -754,9 +766,9 @@ static int ccid3_hc_rx_insert_options(st
 					     hcrx->ccid3hcrx_elapsed_time)) ||
 	    dccp_insert_option_timestamp(sk, skb) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
-		    	       &pinv, sizeof(pinv)) ||
+			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
-		    	       &x_recv, sizeof(x_recv)))
+			       &x_recv, sizeof(x_recv)))
 		return -1;
 
 	return 0;
@@ -827,9 +839,9 @@ found:
 	/*
 	 * Determine the length of the first loss interval via inverse lookup.
 	 * Assume that X_recv can be computed by the throughput equation
-	 *      	    s
-	 * 	X_recv = --------
-	 * 		 R * fval
+	 *		    s
+	 *	X_recv = --------
+	 *		 R * fval
 	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
 	 */
 	if (rtt = 0) {			/* would result in divide-by-zero */
@@ -860,7 +872,7 @@ found:
 	if (p = 0)
 		return ~0;
 	else
-		return 1000000 / p; 
+		return 1000000 / p;
 }
 
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
@@ -914,7 +926,8 @@ static int ccid3_hc_rx_detect_loss(struc
                                     struct dccp_rx_hist_entry *packet)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *rx_hist = dccp_rx_hist_head(&hcrx->ccid3hcrx_hist);
+	struct dccp_rx_hist_entry *rx_hist +				dccp_rx_hist_head(&hcrx->ccid3hcrx_hist);
 	u64 seqno = packet->dccphrx_seqno;
 	u64 tmp_seqno;
 	int loss = 0;
@@ -942,7 +955,7 @@ static int ccid3_hc_rx_detect_loss(struc
 		dccp_inc_seqno(&tmp_seqno);
 		while (dccp_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
 		   tmp_seqno, &ccval)) {
-		   	hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
+			hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
 			hcrx->ccid3hcrx_ccval_nonloss = ccval;
 			dccp_inc_seqno(&tmp_seqno);
 		}
@@ -1044,8 +1057,8 @@ static void ccid3_hc_rx_packet_recv(stru
 			break;
 
 		dccp_timestamp(sk, &now);
-		if (timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
-					(suseconds_t)hcrx->ccid3hcrx_rtt >= 0) {
+		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
+		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
 			hcrx->ccid3hcrx_tstamp_last_ack = now;
 			ccid3_hc_rx_send_feedback(sk);
 		}
@@ -1118,9 +1131,9 @@ static void ccid3_hc_rx_get_info(struct 
 
 	BUG_ON(hcrx = NULL);
 
-	info->tcpi_ca_state	= hcrx->ccid3hcrx_state;
-	info->tcpi_options	|= TCPI_OPT_TIMESTAMPS;
-	info->tcpi_rcv_rtt	= hcrx->ccid3hcrx_rtt;
+	info->tcpi_ca_state = hcrx->ccid3hcrx_state;
+	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
+	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1212,7 +1225,7 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_rx_getsockopt	   = ccid3_hc_rx_getsockopt,
 	.ccid_hc_tx_getsockopt	   = ccid3_hc_tx_getsockopt,
 };
- 
+
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 module_param(ccid3_debug, int, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
@@ -1235,7 +1248,7 @@ static __init int ccid3_module_init(void
 		goto out_free_tx;
 
 	rc = ccid_register(&ccid3);
-	if (rc != 0) 
+	if (rc != 0)
 		goto out_free_loss_interval_history;
 out:
 	return rc;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 3e3a9cc..15776a8 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -77,7 +77,7 @@ struct ccid3_options_received {
 
 /* TFRC sender states */
 enum ccid3_hc_tx_states {
-       	TFRC_SSTATE_NO_SENT = 1,
+	TFRC_SSTATE_NO_SENT = 1,
 	TFRC_SSTATE_NO_FBACK,
 	TFRC_SSTATE_FBACK,
 	TFRC_SSTATE_TERM,
@@ -96,7 +96,7 @@ enum ccid3_hc_tx_states {
  * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
  * @ccid3hctx_last_win_count - Last window counter sent
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
- * 				 with last_win_count value sent
+ *				 with last_win_count value sent
  * @ccid3hctx_no_feedback_timer - Handle to no feedback timer
  * @ccid3hctx_idle - Flag indicating that sender is idling
  * @ccid3hctx_t_ld - Time last doubled during slow start
@@ -115,7 +115,7 @@ #define ccid3hctx_p			ccid3hctx_tfrc.tfr
 #define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
 #define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
 	u16				ccid3hctx_s;
-  	enum ccid3_hc_tx_states 	ccid3hctx_state:8;
+	enum ccid3_hc_tx_states		ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
 	u8				ccid3hctx_idle;
 	struct timeval			ccid3hctx_t_last_win_count;
@@ -129,7 +129,7 @@ #define ccid3hctx_t_ipi			ccid3hctx_tfrc
 
 /* TFRC receiver states */
 enum ccid3_hc_rx_states {
-       	TFRC_RSTATE_NO_DATA = 1,
+	TFRC_RSTATE_NO_DATA = 1,
 	TFRC_RSTATE_DATA,
 	TFRC_RSTATE_TERM    = 127,
 };
@@ -157,18 +157,18 @@ struct ccid3_hc_rx_sock {
 #define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
 #define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
 #define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
-  	u64				ccid3hcrx_seqno_nonloss:48,
+	u64				ccid3hcrx_seqno_nonloss:48,
 					ccid3hcrx_ccval_nonloss:4,
 					ccid3hcrx_ccval_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
-  	u32				ccid3hcrx_bytes_recv;
-  	struct timeval			ccid3hcrx_tstamp_last_feedback;
-  	struct timeval			ccid3hcrx_tstamp_last_ack;
+	u32				ccid3hcrx_bytes_recv;
+	struct timeval			ccid3hcrx_tstamp_last_feedback;
+	struct timeval			ccid3hcrx_tstamp_last_ack;
 	struct list_head		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
-  	u16				ccid3hcrx_s;
-  	u32				ccid3hcrx_pinv;
-  	u32				ccid3hcrx_elapsed_time;
+	u16				ccid3hcrx_s;
+	u32				ccid3hcrx_pinv;
+	u32				ccid3hcrx_elapsed_time;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 4dc487f..95b6927 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -329,7 +329,7 @@ static void dccp_feat_empty_confirm(stru
 	switch (type) {
 	case DCCPO_CHANGE_L: opt->dccpop_type = DCCPO_CONFIRM_R; break;
 	case DCCPO_CHANGE_R: opt->dccpop_type = DCCPO_CONFIRM_L; break;
-	default: 	     DCCP_WARN("invalid type %d\n", type); return;
+	default:	     DCCP_WARN("invalid type %d\n", type); return;
 
 	}
 	opt->dccpop_feat = feature;
@@ -427,7 +427,7 @@ int dccp_feat_confirm_recv(struct sock *
 	switch (type) {
 	case DCCPO_CONFIRM_L: t = DCCPO_CHANGE_R; break;
 	case DCCPO_CONFIRM_R: t = DCCPO_CHANGE_L; break;
-	default: 	      DCCP_WARN("invalid type %d\n", type);
+	default:	      DCCP_WARN("invalid type %d\n", type);
 			      return 1;
 
 	}
@@ -610,7 +610,7 @@ const char *dccp_feat_typename(const u8 
 	case DCCPO_CHANGE_R:  return("ChangeR");
 	case DCCPO_CONFIRM_R: return("ConfirmR");
 	/* the following case must not appear in feature negotation  */
-	default: 	      dccp_pr_debug("unknown type %d [BUG!]\n", type);
+	default:	      dccp_pr_debug("unknown type %d [BUG!]\n", type);
 	}
 	return NULL;
 }
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 4a3279c..565bc80 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -1,6 +1,6 @@
 /*
  *  net/dccp/input.c
- * 
+ *
  *  An implementation of the DCCP protocol
  *  Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
@@ -82,7 +82,7 @@ static int dccp_check_seqno(struct sock 
 	 *	  Otherwise,
 	 *	     Drop packet and return
 	 */
-	if (dh->dccph_type = DCCP_PKT_SYNC || 
+	if (dh->dccph_type = DCCP_PKT_SYNC ||
 	    dh->dccph_type = DCCP_PKT_SYNCACK) {
 		if (between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
 			      dp->dccps_awl, dp->dccps_awh) &&
@@ -185,8 +185,8 @@ static int __dccp_rcv_established(struct
 		dccp_rcv_close(sk, skb);
 		return 0;
 	case DCCP_PKT_REQUEST:
-		/* Step 7 
-            	 *   or (S.is_server and P.type = Response)
+		/* Step 7
+		 *   or (S.is_server and P.type = Response)
 		 *   or (S.is_client and P.type = Request)
 		 *   or (S.state >= OPEN and P.type = Request
 		 *	and P.seqno >= S.OSR)
@@ -274,7 +274,7 @@ static int dccp_rcv_request_sent_state_p
 					       const struct dccp_hdr *dh,
 					       const unsigned len)
 {
-	/* 
+	/*
 	 *  Step 4: Prepare sequence numbers in REQUEST
 	 *     If S.state = REQUEST,
 	 *	  If (P.type = Response or P.type = Reset)
@@ -342,7 +342,7 @@ static int dccp_rcv_request_sent_state_p
 		 *	      from the Response * /
 		 *	  S.state := PARTOPEN
 		 *	  Set PARTOPEN timer
-		 * 	  Continue with S.state = PARTOPEN
+		 *	  Continue with S.state = PARTOPEN
 		 *	  / * Step 12 will send the Ack completing the
 		 *	      three-way handshake * /
 		 */
@@ -373,7 +373,7 @@ static int dccp_rcv_request_sent_state_p
 			 */
 			__kfree_skb(skb);
 			return 0;
-		} 
+		}
 		dccp_send_ack(sk);
 		return -1;
 	}
@@ -381,7 +381,7 @@ static int dccp_rcv_request_sent_state_p
 out_invalid_packet:
 	/* dccp_v4_do_rcv will send a reset */
 	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_PACKET_ERROR;
-	return 1; 
+	return 1;
 }
 
 static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
@@ -488,11 +488,11 @@ int dccp_rcv_state_process(struct sock *
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
 			dccp_event_ack_recv(sk, skb);
 
- 		if (dccp_msk(sk)->dccpms_send_ack_vector &&
+		if (dccp_msk(sk)->dccpms_send_ack_vector &&
 		    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
- 				    DCCP_SKB_CB(skb)->dccpd_seq,
- 				    DCCP_ACKVEC_STATE_RECEIVED))
- 			goto discard;
+				    DCCP_SKB_CB(skb)->dccpd_seq,
+				    DCCP_ACKVEC_STATE_RECEIVED))
+			goto discard;
 
 		/* XXX see the comments in dccp_rcv_established about this */
 		if (dccp_sk(sk)->dccps_role = DCCP_ROLE_SERVER)
@@ -580,7 +580,7 @@ int dccp_rcv_state_process(struct sock *
 		}
 	}
 
-	if (!queued) { 
+	if (!queued) {
 discard:
 		__kfree_skb(skb);
 	}
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ff81679..90c74b4 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -157,7 +157,7 @@ static inline void dccp_do_pmtu_discover
 	/* We don't check in the destentry if pmtu discovery is forbidden
 	 * on this route. We just assume that no packet_to_big packets
 	 * are send back when pmtu discovery is not active.
-     	 * There is a small race when the user changes this flag in the
+ 	 * There is a small race when the user changes this flag in the
 	 * route, but I think that's acceptable.
 	 */
 	if ((dst = __sk_dst_check(sk, 0)) = NULL)
@@ -467,7 +467,7 @@ static struct dst_entry* dccp_v4_route_s
 			    .uli_u = { .ports  				       { .sport = dccp_hdr(skb)->dccph_dport,
 					 .dport = dccp_hdr(skb)->dccph_sport }
-			   	     }
+				     }
 			  };
 
 	security_skb_classify_flow(skb, &fl);
@@ -595,7 +595,7 @@ int dccp_v4_conn_request(struct sock *sk
 	struct inet_request_sock *ireq;
 	struct request_sock *req;
 	struct dccp_request_sock *dreq;
- 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
+	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
 
@@ -609,7 +609,7 @@ int dccp_v4_conn_request(struct sock *sk
 	if (dccp_bad_service_code(sk, service)) {
 		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
 		goto drop;
- 	}
+	}
 	/*
 	 * TW buckets are converted to open requests without
 	 * limitations, they conserve resources and peer is
@@ -644,7 +644,7 @@ int dccp_v4_conn_request(struct sock *sk
 	ireq->rmt_addr = skb->nh.iph->saddr;
 	ireq->opt	= NULL;
 
-	/* 
+	/*
 	 * Step 3: Process LISTEN state
 	 *
 	 * Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
@@ -846,15 +846,15 @@ static int dccp_v4_rcv(struct sk_buff *s
 	}
 
 	/* Step 2:
-	 * 	Look up flow ID in table and get corresponding socket */
+	 *	Look up flow ID in table and get corresponding socket */
 	sk = __inet_lookup(&dccp_hashinfo,
 			   skb->nh.iph->saddr, dh->dccph_sport,
 			   skb->nh.iph->daddr, dh->dccph_dport,
 			   inet_iif(skb));
 
-	/* 
+	/*
 	 * Step 2:
-	 * 	If no socket ...
+	 *	If no socket ...
 	 */
 	if (sk = NULL) {
 		dccp_pr_debug("failed to look up flow ID in table and "
@@ -862,9 +862,9 @@ static int dccp_v4_rcv(struct sk_buff *s
 		goto no_dccp_socket;
 	}
 
-	/* 
+	/*
 	 * Step 2:
-	 * 	... or S.state = TIMEWAIT,
+	 *	... or S.state = TIMEWAIT,
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
@@ -876,8 +876,8 @@ static int dccp_v4_rcv(struct sk_buff *s
 
 	/*
 	 * RFC 4340, sec. 9.2.1: Minimum Checksum Coverage
-	 * 	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
-	 * 	o if MinCsCov > 0, also accept packets with CsCov >= MinCsCov
+	 *	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
+	 *	o if MinCsCov > 0, also accept packets with CsCov >= MinCsCov
 	 */
 	min_cov = dccp_sk(sk)->dccps_pcrlen;
 	if (dh->dccph_cscov && (min_cov = 0 || dh->dccph_cscov < min_cov))  {
@@ -900,7 +900,7 @@ no_dccp_socket:
 		goto discard_it;
 	/*
 	 * Step 2:
-	 * 	If no socket ...
+	 *	If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index c7aaa25..6b91a9d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -77,7 +77,7 @@ static inline void dccp_v6_send_check(st
 }
 
 static inline __u32 secure_dccpv6_sequence_number(__be32 *saddr, __be32 *daddr,
-				   		  __be16 sport, __be16 dport   )
+						  __be16 sport, __be16 dport   )
 {
 	return secure_tcpv6_sequence_number(saddr, daddr, sport, dport);
 }
@@ -329,7 +329,7 @@ static void dccp_v6_ctl_send_reset(struc
 	skb = alloc_skb(dccp_v6_ctl_socket->sk->sk_prot->max_header,
 			GFP_ATOMIC);
 	if (skb = NULL)
-	  	return;
+		return;
 
 	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
 
@@ -353,7 +353,7 @@ static void dccp_v6_ctl_send_reset(struc
 
 	dccp_csum_outgoing(skb);
 	dh->dccph_checksum = dccp_v6_csum_finish(skb, &rxskb->nh.ipv6h->saddr,
-				   		      &rxskb->nh.ipv6h->daddr);
+						      &rxskb->nh.ipv6h->daddr);
 
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &rxskb->nh.ipv6h->saddr);
@@ -424,7 +424,7 @@ static int dccp_v6_conn_request(struct s
 	struct dccp_request_sock *dreq;
 	struct inet6_request_sock *ireq6;
 	struct ipv6_pinfo *np = inet6_sk(sk);
- 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
+	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
 
@@ -437,7 +437,7 @@ static int dccp_v6_conn_request(struct s
 	if (dccp_bad_service_code(sk, service)) {
 		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
 		goto drop;
- 	}
+	}
 	/*
 	 * There are no SYN attacks on IPv6, yet...
 	 */
@@ -787,7 +787,7 @@ static int dccp_v6_do_rcv(struct sock *s
 		 * otherwise we just shortcircuit this and continue with
 		 * the new socket..
 		 */
- 		if (nsk != sk) {
+		if (nsk != sk) {
 			if (dccp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb != NULL)
@@ -843,14 +843,14 @@ static int dccp_v6_rcv(struct sk_buff **
 		DCCP_SKB_CB(skb)->dccpd_ack_seq = dccp_hdr_ack_seq(skb);
 
 	/* Step 2:
-	 * 	Look up flow ID in table and get corresponding socket */
+	 *	Look up flow ID in table and get corresponding socket */
 	sk = __inet6_lookup(&dccp_hashinfo, &skb->nh.ipv6h->saddr,
 			    dh->dccph_sport,
 			    &skb->nh.ipv6h->daddr, ntohs(dh->dccph_dport),
 			    inet6_iif(skb));
 	/*
 	 * Step 2:
-	 * 	If no socket ...
+	 *	If no socket ...
 	 */
 	if (sk = NULL) {
 		dccp_pr_debug("failed to look up flow ID in table and "
@@ -860,7 +860,7 @@ static int dccp_v6_rcv(struct sk_buff **
 
 	/*
 	 * Step 2:
-	 * 	... or S.state = TIMEWAIT,
+	 *	... or S.state = TIMEWAIT,
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
@@ -872,8 +872,8 @@ static int dccp_v6_rcv(struct sk_buff **
 
 	/*
 	 * RFC 4340, sec. 9.2.1: Minimum Checksum Coverage
-	 * 	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
-	 * 	o if MinCsCov > 0, also accept packets with CsCov >= MinCsCov
+	 *	o if MinCsCov = 0, only packets with CsCov = 0 are accepted
+	 *	o if MinCsCov > 0, also accept packets with CsCov >= MinCsCov
 	 */
 	min_cov = dccp_sk(sk)->dccps_pcrlen;
 	if (dh->dccph_cscov  &&  (min_cov = 0 || dh->dccph_cscov < min_cov))  {
@@ -893,7 +893,7 @@ no_dccp_socket:
 		goto discard_it;
 	/*
 	 * Step 2:
-	 * 	If no socket ...
+	 *	If no socket ...
 	 *		Generate Reset(No Connection) unless P.type = Reset
 	 *		Drop packet and return
 	 */
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 4c9e267..6656bb4 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -182,7 +182,7 @@ out_free:
 
 EXPORT_SYMBOL_GPL(dccp_create_openreq_child);
 
-/* 
+/*
  * Process an incoming packet for RESPOND sockets represented
  * as an request_sock.
  */
diff --git a/net/dccp/output.c b/net/dccp/output.c
index b4df12b..8245696 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -1,6 +1,6 @@
 /*
  *  net/dccp/output.c
- * 
+ *
  *  An implementation of the DCCP protocol
  *  Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
@@ -338,7 +338,6 @@ EXPORT_SYMBOL_GPL(dccp_make_response);
 
 static struct sk_buff *dccp_make_reset(struct sock *sk, struct dst_entry *dst,
 				       const enum dccp_reset_codes code)
-				   
 {
 	struct dccp_hdr *dh;
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -419,14 +418,14 @@ static inline void dccp_connect_init(str
 	
 	dccp_sync_mss(sk, dst_mtu(dst));
 
- 	/*
+	/*
 	 * SWL and AWL are initially adjusted so that they are not less than
 	 * the initial Sequence Numbers received and sent, respectively:
 	 *	SWL := max(GSR + 1 - floor(W/4), ISR),
 	 *	AWL := max(GSS - W' + 1, ISS).
 	 * These adjustments MUST be applied only at the beginning of the
 	 * connection.
- 	 */
+	 */
 	dccp_update_gss(sk, dp->dccps_iss);
 	dccp_set_seqno(&dp->dccps_awl, max48(dp->dccps_awl, dp->dccps_iss));
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 5ec47d9..63b3fa2 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -196,7 +196,7 @@ int dccp_init_sock(struct sock *sk, cons
 						      sk, GFP_KERNEL);
 		dp->dccps_hc_tx_ccid = ccid_hc_tx_new(dmsk->dccpms_tx_ccid,
 						      sk, GFP_KERNEL);
-	    	if (unlikely(dp->dccps_hc_rx_ccid = NULL ||
+		if (unlikely(dp->dccps_hc_rx_ccid = NULL ||
 			     dp->dccps_hc_tx_ccid = NULL)) {
 			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
 			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
@@ -390,7 +390,7 @@ static int dccp_setsockopt_service(struc
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_service_list *sl = NULL;
 
-	if (service = DCCP_SERVICE_INVALID_VALUE || 
+	if (service = DCCP_SERVICE_INVALID_VALUE ||
 	    optlen > DCCP_SERVICE_LIST_MAX_LEN * sizeof(u32))
 		return -EINVAL;
 
@@ -830,7 +830,7 @@ EXPORT_SYMBOL_GPL(inet_dccp_listen);
 static const unsigned char dccp_new_state[] = {
 	/* current state:   new state:      action:	*/
 	[0]		  = DCCP_CLOSED,
-	[DCCP_OPEN] 	  = DCCP_CLOSING | DCCP_ACTION_FIN,
+	[DCCP_OPEN]	  = DCCP_CLOSING | DCCP_ACTION_FIN,
 	[DCCP_REQUESTING] = DCCP_CLOSED,
 	[DCCP_PARTOPEN]	  = DCCP_CLOSING | DCCP_ACTION_FIN,
 	[DCCP_LISTEN]	  = DCCP_CLOSED,
diff --git a/net/dccp/timer.c b/net/dccp/timer.c
index e8f519e..e5348f3 100644
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -1,6 +1,6 @@
 /*
  *  net/dccp/timer.c
- * 
+ *
  *  An implementation of the DCCP protocol
  *  Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
@@ -102,13 +102,13 @@ static void dccp_retransmit_timer(struct
 	 * sk->sk_send_head has to have one skb with
 	 * DCCP_SKB_CB(skb)->dccpd_type set to one of the retransmittable DCCP
 	 * packet types. The only packets eligible for retransmission are:
-	 * 	-- Requests in client-REQUEST  state (sec. 8.1.1)
-	 * 	-- Acks     in client-PARTOPEN state (sec. 8.1.5)
-	 * 	-- CloseReq in server-CLOSEREQ state (sec. 8.3)
-	 * 	-- Close    in   node-CLOSING  state (sec. 8.3)                */
+	 *	-- Requests in client-REQUEST  state (sec. 8.1.1)
+	 *	-- Acks     in client-PARTOPEN state (sec. 8.1.5)
+	 *	-- CloseReq in server-CLOSEREQ state (sec. 8.3)
+	 *	-- Close    in   node-CLOSING  state (sec. 8.3)                */
 	BUG_TRAP(sk->sk_send_head != NULL);
 
-	/* 
+	/*
 	 * More than than 4MSL (8 minutes) has passed, a RESET(aborted) was
 	 * sent, no need to retransmit, this sock is dead.
 	 */
@@ -200,7 +200,7 @@ static void dccp_keepalive_timer(unsigne
 	/* Only process if socket is not in use. */
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
-		/* Try again later. */ 
+		/* Try again later. */
 		inet_csk_reset_keepalive_timer(sk, HZ / 20);
 		goto out;
 	}
-- 
1.4.2.1.g3d5c

