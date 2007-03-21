From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:48 +0000
Subject: [PATCH 9/25]: Ignore irrelevant states on receiving feedback
Message-Id: <200703211844.49105@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Ignore irrelevant states on receiving feedback

This removes two currently irrelevant states in TX feedback handling:

 * the NO_SENT state is not triggered, since currently DCCP only operates in 
   half-connections (in which this state is irrelevant). When upgrading to 
   bidirectional half-connections, other changes are required anyhow, so that
   there is no loss in removing this currently unsupported state.

 * the TERM (terminating) state is uninteresting.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk> 
---
 net/dccp/ccids/ccid3.c |  213 ++++++++++++++++++++++++-------------------------
 1 file changed, 105 insertions(+), 108 deletions(-)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -442,130 +442,127 @@ static void ccid3_hc_tx_packet_recv(stru
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
 		return;
 
+	/* only the established state is of interest here */
+	switch (hctx->ccid3hctx_state) {
+	case TFRC_SSTATE_NO_FBACK:	/* fall through */
+	case TFRC_SSTATE_FBACK:		break;
+	default:			return;
+	}
+
+	/* get packet from history to look up t_recvdata */
+	packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
+				         DCCP_SKB_CB(skb)->dccpd_ack_seq);
+	if (unlikely(packet = NULL)) {
+		DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist in history!\n",
+			  dccp_role(sk), sk,
+		          (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
+			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+		return;
+	}
+
 	opt_recv = &hctx->ccid3hctx_options_received;
 
-	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_NO_FBACK:
-	case TFRC_SSTATE_FBACK:
-		/* get packet from history to look up t_recvdata */
-		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
-					      DCCP_SKB_CB(skb)->dccpd_ack_seq);
-		if (unlikely(packet = NULL)) {
-			DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist "
-				  "in history!\n",  dccp_role(sk), sk,
-			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
-			return;
-		}
+	/* Update receive rate in units of 64 * bytes/second */
+	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+	hctx->ccid3hctx_x_recv <<= 6;
+
+	/* Update loss event rate */
+	pinv = opt_recv->ccid3or_loss_event_rate;
+	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
+		hctx->ccid3hctx_p = 0;
+	else				       /* can not exceed 100% */
+		hctx->ccid3hctx_p = 1000000 / pinv;
 
-		/* Update receive rate in units of 64 * bytes/second */
-		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
-		hctx->ccid3hctx_x_recv <<= 6;
-
-		/* Update loss event rate */
-		pinv = opt_recv->ccid3or_loss_event_rate;
-		if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
-			hctx->ccid3hctx_p = 0;
-		else				       /* can not exceed 100% */
-			hctx->ccid3hctx_p = 1000000 / pinv;
+	/*
+	 * Calculate new round trip sample as per [RFC 3448, 4.3] by
+	 * R_sample  =  (t_now - t_recvdata) - t_elapsed
+	 */
+	skb_get_timestamp(skb, &now);
+	r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
 
-		/*
-		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
-		 *	R_sample  =  (now - t_recvdata) - t_elapsed
-		 */
-		skb_get_timestamp(skb, &now);
-		r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
+	/*
+	 * Update RTT estimate (honours RTT from SYN exchange):
+	 * If (No RTT sample so far)
+	 *    R = R_sample;
+	 * Else
+	 *    R = q * R + (1 - q) * R_sample;
+	 *
+	 * q is a constant, RFC 3448 recommends 0.9
+	 */
+	hctx->ccid3hctx_rtt = hctx->ccid3hctx_rtt = 0 ?  r_sample
+			    : (9 * hctx->ccid3hctx_rtt + r_sample) / 10;
 
+	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
 		/*
-		 * Update RTT estimate (honours RTT from SYN exchange):
-		 * If (No RTT sample so far)
-		 *    R = R_sample;
-		 * Else
-		 *    R = q * R + (1 - q) * R_sample;
-		 *
-		 * q is a constant, RFC 3448 recomments 0.9
+		 * Larger Initial Windows [RFC 4342, sec. 5]
 		 */
-		hctx->ccid3hctx_rtt = hctx->ccid3hctx_rtt = 0 ?  r_sample
-				    : (9 * hctx->ccid3hctx_rtt + r_sample) / 10;
+		hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+		hctx->ccid3hctx_t_ld = now;
 
-		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
-			/*
-			 * Larger Initial Windows [RFC 4342, sec. 5]
-			 */
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
-
-			ccid3_update_send_interval(hctx);
-
-			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
-				       "R_sample=%uus, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_s,
-				       dp->dccps_mss_cache, r_sample,
-				       (unsigned)(hctx->ccid3hctx_x >> 6));
+		ccid3_update_send_interval(hctx);
 
-			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-		} else {
+		ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
+			       "R_sample=%uus, X=%u\n", dccp_role(sk),
+			       sk, hctx->ccid3hctx_s,
+			       dp->dccps_mss_cache, r_sample,
+			       (unsigned)(hctx->ccid3hctx_x >> 6));
 
-			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-			if (hctx->ccid3hctx_p > 0)
-				hctx->ccid3hctx_x_calc -					tfrc_calc_x(hctx->ccid3hctx_s,
-						    hctx->ccid3hctx_rtt,
-						    hctx->ccid3hctx_p);
-			ccid3_hc_tx_update_x(sk, &now);
-
-			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
-				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-				       dccp_role(sk),
-				       sk, hctx->ccid3hctx_rtt, r_sample,
-				       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
-				       hctx->ccid3hctx_x_calc,
-				       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-				       (unsigned)(hctx->ccid3hctx_x >> 6));
-		}
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
+	} else {
 
-		/* unschedule no feedback timer */
-		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+		/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
+		if (hctx->ccid3hctx_p > 0)
+			hctx->ccid3hctx_x_calc +				tfrc_calc_x(hctx->ccid3hctx_s,
+					    hctx->ccid3hctx_rtt,
+					    hctx->ccid3hctx_p);
+		ccid3_hc_tx_update_x(sk, &now);
 
-		/* remove all packets older than the one acked from history */
-		dccp_tx_hist_purge_older(ccid3_tx_hist,
-					 &hctx->ccid3hctx_hist, packet);
-		/*
-		 * As we have calculated new ipi, delta, t_nom it is possible
-		 * that we now can send a packet, so wake up dccp_wait_for_ccid
-		 */
-		sk->sk_write_space(sk);
+		ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
+			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
+			       dccp_role(sk),
+			       sk, hctx->ccid3hctx_rtt, r_sample,
+			       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
+			       hctx->ccid3hctx_x_calc,
+			       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
+			       (unsigned)(hctx->ccid3hctx_x >> 6));
+	}
 
-		/*
-		 * Update timeout interval for the nofeedback timer.
-		 * We use a configuration option to increase the lower bound.
-		 * This can help avoid triggering the nofeedback timer too
-		 * often ('spinning') on LANs with small RTTs.
-		 */
-		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-						   CONFIG_IP_DCCP_CCID3_RTO *
-						   (USEC_PER_SEC/1000));
-		/*
-		 * Schedule no feedback timer to expire in
-		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
-		 */
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+	/* unschedule no feedback timer */
+	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
-			       "expire in %lu jiffies (%luus)\n",
-			       dccp_role(sk),
-			       sk, usecs_to_jiffies(t_nfb), t_nfb);
+	/* remove all packets older than the one acked from history */
+	dccp_tx_hist_purge_older(ccid3_tx_hist,
+				 &hctx->ccid3hctx_hist, packet);
+	/*
+	 * As we have calculated new ipi, delta, t_nom it is possible
+	 * that we now can send a packet, so wake up dccp_wait_for_ccid
+	 */
+	sk->sk_write_space(sk);
+
+	/*
+	 * Update timeout interval for the nofeedback timer.
+	 * We use a configuration option to increase the lower bound.
+	 * This can help avoid triggering the nofeedback timer too
+	 * often ('spinning') on LANs with small RTTs.
+	 */
+	hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
+					   CONFIG_IP_DCCP_CCID3_RTO *
+					   (USEC_PER_SEC/1000));
+	/*
+	 * Schedule no feedback timer to expire in
+	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
+	 */
+	t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 
-		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-				   jiffies + usecs_to_jiffies(t_nfb));
+	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+			   jiffies + usecs_to_jiffies(t_nfb));
 
-		/* set idle flag */
-		hctx->ccid3hctx_idle = 1;
-		break;
-	case TFRC_SSTATE_NO_SENT:	/* fall through */
-	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
-		break;
-	}
+	ccid3_pr_debug("Scheduled no feedback timer to expire in %lu jiffies"
+		       "(%luus)\n", usecs_to_jiffies(t_nfb), t_nfb);
+
+	/* set idle flag */
+	hctx->ccid3hctx_idle = 1;
 }
 
 static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
