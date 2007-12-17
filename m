From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 17 Dec 2007 15:00:17 +0000
Subject: [PATCH 3/5] [CCID3]: Implement rfc3448bis changes to feedback reception
Message-Id: <1197903619-12301-4-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This implements the algorithm to update the allowed sending rate X upon
receiving feedback packets, as described in draft rfc3448bis, 4.2/4.3.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   47 ++++++++++++++++++++++++++---------------------
 1 files changed, 26 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 1b1cb74..7c8e9ad 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -429,40 +429,46 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
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
 	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
-		/*
-		 * Larger Initial Windows [RFC 4342, sec. 5]
-		 */
-		hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-		hctx->ccid3hctx_t_ld = now;
+		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 
-		ccid3_update_send_interval(hctx);
+		if (hctx->ccid3hctx_t_rto = 0) {
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
+		} else if (hctx->ccid3hctx_p = 0) {
+			/*
+			 * First feedback after nofeedback timer expiry (4.3)
+			 */
+			goto done_computing_x;
+ 		}
+	}
 
-		/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
-		if (hctx->ccid3hctx_p > 0)
-			hctx->ccid3hctx_x_calc +	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
+	if (hctx->ccid3hctx_p > 0)
+		hctx->ccid3hctx_x_calc  				tfrc_calc_x(hctx->ccid3hctx_s,
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

