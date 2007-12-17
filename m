From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 17 Dec 2007 12:51:05 +0000
Subject: [RFC]: Break up a patch in two (rfc3448bis changes to feedback
Message-Id: <20071217125105.GE5128@ghostprotocols.net>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="DSayHWYpDlRfCAAQ"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org


--DSayHWYpDlRfCAAQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Gerrit,

	Please take a look at the two attached patches, they were made
from your patch "[CCID3]: Implement rfc3448bis changes to feedback reception",
that has this changeset comment:

----------------------
[CCID 3]: Implement rfc3448bis changes to feedback reception

This implements the algorithm to update the allowed sending rate X upon
receiving feedback packets, as described in draft rfc3448bis, 4.2/4.3.

The patch further removes two irrelevant states in TX feedback handling:

     * the NO_SENT state is only triggered in bidirectional mode,
       costing unnecessary processing.
     * the TERM (terminating) state is irrelevant.
------------------

	The second part "further removes", was made a separate patch
that I have applied before the rfc3448bis changes to feedback reception.
Doing it this way eases understanding the change as we don't mixup
identantion changes made due to removing the switch statement.

	The end result should be equivalent, but please take a look and
let me know if the algorithm was changed in any way.

Thanks a lot,

- Arnaldo

--DSayHWYpDlRfCAAQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0002-CCID3-Remove-two-irrelevant-states-in-TX-feedback.patch"

From 9165240abd3d4e8280647b9372dc3f223a802347 Mon Sep 17 00:00:00 2001
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Dec 2007 10:25:06 -0200
Subject: [PATCH 2/3] [CCID3]: Remove two irrelevant states in TX feedback handling

 * the NO_SENT state is only triggered in bidirectional mode,
   costing unnecessary processing.
 * the TERM (terminating) state is irrelevant.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |  173 +++++++++++++++++++++++-------------------------
 1 files changed, 84 insertions(+), 89 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 90e0454..1b1cb74 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -402,112 +402,107 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (!(DCCP_SKB_CB(skb)->dccpd_type == DCCP_PKT_ACK ||
 	      DCCP_SKB_CB(skb)->dccpd_type == DCCP_PKT_DATAACK))
 		return;
+	/* ... and only in the established state */
+	if (hctx->ccid3hctx_state != TFRC_SSTATE_FBACK &&
+	    hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
+		return;
 
 	opt_recv = &hctx->ccid3hctx_options_received;
+	now = ktime_get_real();
 
-	switch (hctx->ccid3hctx_state) {
-	case TFRC_SSTATE_NO_FBACK:
-	case TFRC_SSTATE_FBACK:
-		now = ktime_get_real();
-
-		/* estimate RTT from history if ACK number is valid */
-		r_sample = tfrc_tx_hist_rtt(hctx->ccid3hctx_hist,
-					    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
-		if (r_sample == 0) {
-			DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
-				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
-				  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
-			return;
-		}
+	/* Estimate RTT from history if ACK number is valid */
+	r_sample = tfrc_tx_hist_rtt(hctx->ccid3hctx_hist,
+				    DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
+	if (r_sample == 0) {
+		DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
+			  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
+			  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
+		return;
+	}
+
+	/* Update receive rate in units of 64 * bytes/second */
+	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+	hctx->ccid3hctx_x_recv <<= 6;
 
-		/* Update receive rate in units of 64 * bytes/second */
-		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
-		hctx->ccid3hctx_x_recv <<= 6;
+	/* Update loss event rate (which is scaled by 1e6) */
+	pinv = opt_recv->ccid3or_loss_event_rate;
+	if (pinv == ~0U || pinv == 0)	       /* see RFC 4342, 8.5   */
+		hctx->ccid3hctx_p = 0;
+	else				       /* can not exceed 100% */
+		hctx->ccid3hctx_p = 1000000 / pinv;
+	/*
+	 * Validate new RTT sample and update moving average
+	 */
+	r_sample = dccp_sample_rtt(sk, r_sample);
+	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
-		/* Update loss event rate */
-		pinv = opt_recv->ccid3or_loss_event_rate;
-		if (pinv == ~0U || pinv == 0)	       /* see RFC 4342, 8.5   */
-			hctx->ccid3hctx_p = 0;
-		else				       /* can not exceed 100% */
-			hctx->ccid3hctx_p = 1000000 / pinv;
+	if (hctx->ccid3hctx_state == TFRC_SSTATE_NO_FBACK) {
 		/*
-		 * Validate new RTT sample and update moving average
+		 * Larger Initial Windows [RFC 4342, sec. 5]
 		 */
-		r_sample = dccp_sample_rtt(sk, r_sample);
-		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
+		hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+		hctx->ccid3hctx_t_ld = now;
 
-		if (hctx->ccid3hctx_state == TFRC_SSTATE_NO_FBACK) {
-			/*
-			 * Larger Initial Windows [RFC 4342, sec. 5]
-			 */
-			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+		ccid3_update_send_interval(hctx);
 
-			ccid3_update_send_interval(hctx);
+		ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
+			       "R_sample=%uus, X=%u\n", dccp_role(sk),
+			       sk, hctx->ccid3hctx_s,
+			       dccp_sk(sk)->dccps_mss_cache, r_sample,
+			       (unsigned)(hctx->ccid3hctx_x >> 6));
 
-			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
-				       "R_sample=%uus, X=%u\n", dccp_role(sk),
-				       sk, hctx->ccid3hctx_s,
-				       dccp_sk(sk)->dccps_mss_cache, r_sample,
-				       (unsigned)(hctx->ccid3hctx_x >> 6));
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
+	} else {
 
-			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-		} else {
+		/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
+		if (hctx->ccid3hctx_p > 0)
+			hctx->ccid3hctx_x_calc =
+				tfrc_calc_x(hctx->ccid3hctx_s,
+					    hctx->ccid3hctx_rtt,
+					    hctx->ccid3hctx_p);
+		ccid3_hc_tx_update_x(sk, &now);
 
-			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-			if (hctx->ccid3hctx_p > 0)
-				hctx->ccid3hctx_x_calc =
-					tfrc_calc_x(hctx->ccid3hctx_s,
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
+		ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
+			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
+			       dccp_role(sk),
+			       sk, hctx->ccid3hctx_rtt, r_sample,
+			       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
+			       hctx->ccid3hctx_x_calc,
+			       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
+			       (unsigned)(hctx->ccid3hctx_x >> 6));
+	}
 
-		/* unschedule no feedback timer */
-		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
+	/* unschedule no feedback timer */
+	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/*
-		 * As we have calculated new ipi, delta, t_nom it is possible
-		 * that we now can send a packet, so wake up dccp_wait_for_ccid
-		 */
-		sk->sk_write_space(sk);
+	/*
+	 * As we have calculated new ipi, delta, t_nom it is possible
+	 * that we now can send a packet, so wake up dccp_wait_for_ccid
+	 */
+	sk->sk_write_space(sk);
 
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
+	/*
+	 * Update timeout interval for the nofeedback timer.
+	 * We use a configuration option to increase the lower bound.
+	 * This can help avoid triggering the nofeedback timer too
+	 * often ('spinning') on LANs with small RTTs.
+	 */
+	hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
+					   (CONFIG_IP_DCCP_CCID3_RTO *
+					    (USEC_PER_SEC / 1000)));
+	/*
+	 * Schedule no feedback timer to expire in
+	 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
+	 */
+	t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 
-		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
-			       "expire in %lu jiffies (%luus)\n",
-			       dccp_role(sk),
-			       sk, usecs_to_jiffies(t_nfb), t_nfb);
+	ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
+		       "expire in %lu jiffies (%luus)\n",
+		       dccp_role(sk),
+		       sk, usecs_to_jiffies(t_nfb), t_nfb);
 
-		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-				   jiffies + usecs_to_jiffies(t_nfb));
-		break;
-	case TFRC_SSTATE_NO_SENT:	/* fall through */
-	case TFRC_SSTATE_TERM:		/* ignore feedback when closing */
-		break;
-	}
+	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+			   jiffies + usecs_to_jiffies(t_nfb));
 }
 
 static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
-- 
1.5.3.6


--DSayHWYpDlRfCAAQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0003-CCID3-Implement-rfc3448bis-changes-to-feedback-re.patch"

From 4dbbc1efa84b1162e70a9ac07057801c8fcdaa72 Mon Sep 17 00:00:00 2001
From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 17 Dec 2007 10:40:45 -0200
Subject: [PATCH 3/3] [CCID3]: Implement rfc3448bis changes to feedback reception

This implements the algorithm to update the allowed sending rate X upon
receiving feedback packets, as described in draft rfc3448bis, 4.2/4.3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   47 ++++++++++++++++++++++++++---------------------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 1b1cb74..689eeab 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -429,40 +429,46 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (pinv == ~0U || pinv == 0)	       /* see RFC 4342, 8.5   */
 		hctx->ccid3hctx_p = 0;
 	else				       /* can not exceed 100% */
-		hctx->ccid3hctx_p = 1000000 / pinv;
+		hctx->ccid3hctx_p = scaled_div(1, pinv);
 	/*
 	 * Validate new RTT sample and update moving average
 	 */
 	r_sample = dccp_sample_rtt(sk, r_sample);
 	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
-
+	/*
+	 * Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
+	 */
 	if (hctx->ccid3hctx_state == TFRC_SSTATE_NO_FBACK) {
-		/*
-		 * Larger Initial Windows [RFC 4342, sec. 5]
-		 */
-		hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-		hctx->ccid3hctx_t_ld = now;
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		ccid3_update_send_interval(hctx);
+		if (hctx->ccid3hctx_t_rto == 0) {
+ 			/*
+			 * Initial feedback packet: Larger Initial Windows (4.2)
+ 			 */
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+			hctx->ccid3hctx_t_ld = now;
 
-		ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
-			       "R_sample=%uus, X=%u\n", dccp_role(sk),
-			       sk, hctx->ccid3hctx_s,
-			       dccp_sk(sk)->dccps_mss_cache, r_sample,
-			       (unsigned)(hctx->ccid3hctx_x >> 6));
+			ccid3_update_send_interval(hctx);
 
-		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-	} else {
+			goto done_computing_x;
+		} else if (hctx->ccid3hctx_p == 0) {
+			/*
+			 * First feedback after nofeedback timer expiry (4.3)
+			 */
+			goto done_computing_x;
+ 		}
+	} 
 
-		/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-		if (hctx->ccid3hctx_p > 0)
-			hctx->ccid3hctx_x_calc =
+	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
+	if (hctx->ccid3hctx_p > 0)
+		hctx->ccid3hctx_x_calc =
 				tfrc_calc_x(hctx->ccid3hctx_s,
 					    hctx->ccid3hctx_rtt,
 					    hctx->ccid3hctx_p);
-		ccid3_hc_tx_update_x(sk, &now);
+	ccid3_hc_tx_update_x(sk, &now);
 
-		ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
+done_computing_x:
+	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
 			       dccp_role(sk),
 			       sk, hctx->ccid3hctx_rtt, r_sample,
@@ -470,7 +476,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			       hctx->ccid3hctx_x_calc,
 			       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
 			       (unsigned)(hctx->ccid3hctx_x >> 6));
-	}
 
 	/* unschedule no feedback timer */
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
-- 
1.5.3.6


--DSayHWYpDlRfCAAQ--
