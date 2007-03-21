From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:45:15 +0000
Subject: [PATCH 14/25]: Implement rfc3448bis changes to feedback reception
Message-Id: <200703211845.15408@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Implement rfc3448bis changes to feedback reception

This implements the algorithm to update the allowed sending rate X upon 
receiving feedback packets, as described in draft rfc3448bis, 4.2/4.3.

Some changes (use of Larger Initial Windows) were already present, this patch
adds the remaining ones. In particular:

 * use t_RTO to distinguish the case "initial feedback packet":
   as per earlier patch, it uses "state = NO_FBACK" to imply that 
     (a) either nofeedback timer expired (when t_RTO != 0) or
     (b) initial feedback packet         (when t_RTO = 0);
 * no reduction of sending rate afer nofeedback timer expiry when p = 0;
 * implements the clause ``if [...] not the first packet after a nofeedback 
   timer'' of draft rfc3448bis, 4.3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   66 +++++++++++++++++++++++++------------------------
 1 file changed, 35 insertions(+), 31 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -419,7 +419,6 @@ static void ccid3_hc_tx_packet_sent(stru
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
-	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 	struct dccp_tx_hist_entry *packet;
@@ -481,41 +480,45 @@ static void ccid3_hc_tx_packet_recv(stru
 	hctx->ccid3hctx_rtt = hctx->ccid3hctx_rtt = 0 ?  r_sample
 			    : (9 * hctx->ccid3hctx_rtt + r_sample) / 10;
 
+	/*
+	 * Update allowed sending rate as per draft rfc3448bis, 4.2/4.3
+	 */
 	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
-		/*
-		 * Larger Initial Windows [RFC 4342, sec. 5]
-		 */
-		hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-		hctx->ccid3hctx_t_ld = now;
-
-		ccid3_update_send_interval(hctx);
-
-		ccid3_pr_debug("%s(%p), s=%u, MSS=%u, "
-			       "R_sample=%uus, X=%u\n", dccp_role(sk),
-			       sk, hctx->ccid3hctx_s,
-			       dp->dccps_mss_cache, r_sample,
-			       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
-	} else {
 
-		/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-		if (hctx->ccid3hctx_p > 0)
-			hctx->ccid3hctx_x_calc -				tfrc_calc_x(hctx->ccid3hctx_s,
-					    hctx->ccid3hctx_rtt,
-					    hctx->ccid3hctx_p);
-		ccid3_hc_tx_update_x(sk, &now);
-
-		ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
-			       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-			       dccp_role(sk),
-			       sk, hctx->ccid3hctx_rtt, r_sample,
-			       hctx->ccid3hctx_s, hctx->ccid3hctx_p,
-			       hctx->ccid3hctx_x_calc,
-			       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
-			       (unsigned)(hctx->ccid3hctx_x >> 6));
+		if (hctx->ccid3hctx_t_rto = 0) {
+			/*
+			 * Initial feedback packet: Larger Initial Windows (4.2)
+			 */
+			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
+			hctx->ccid3hctx_t_ld = now;
+
+			ccid3_update_send_interval(hctx);
+
+			goto done_computing_x;
+
+		} else if (hctx->ccid3hctx_p = 0) {
+			/*
+			 * First feedback after nofeedback timer expiry (4.3)
+			 */
+			goto done_computing_x;
+		}
 	}
+	/* perform step (4) of draft rfc3448bis, section 4.3 */
+	if (hctx->ccid3hctx_p > 0)
+		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
+						     hctx->ccid3hctx_rtt,
+						     hctx->ccid3hctx_p);
+	ccid3_hc_tx_update_x(sk, &now);
+
+done_computing_x:
+	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, p=%u, X_calc=%u, "
+		       "X_recv=%u, X=%u\n", dccp_role(sk), sk,
+		       hctx->ccid3hctx_rtt, r_sample, hctx->ccid3hctx_s,
+		       hctx->ccid3hctx_p, hctx->ccid3hctx_x_calc,
+		       (unsigned)(hctx->ccid3hctx_x_recv >> 6),
+		       (unsigned)(hctx->ccid3hctx_x >> 6));
 
 	/* unschedule no feedback timer */
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
@@ -526,6 +529,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	/*
 	 * As we have calculated new ipi, delta, t_nom it is possible
 	 * that we now can send a packet, so wake up dccp_wait_for_ccid
+	 * (NB: This currently only happens in dccp_send_close)
 	 */
 	sk->sk_write_space(sk);
 
