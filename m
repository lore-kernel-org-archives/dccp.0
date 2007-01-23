From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 23 Jan 2007 15:40:56 +0000
Subject: [PATCH 3/7]: Handle Idle and Application-Limited periods
Message-Id: <200701231540.56521@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Handle Idle and Application-Limited periods

This updates the code with regard to handling idle and application-limited periods as specified
in [RFC 4342, 5.1].

Background:
----------
 The current code does not conform with this, it implements TFRC as per RFC 3448, 4.4:
   "If the sender has been idle since this nofeedback timer has been set" and X_recv < 4 * s/R
    "then X_recv should not be halved in response to timer expiration."

 However, what is required from the code is that "the allowed sending rate is never reduced less than
 the [RFC3390] initial sending rate as the result of an idle period." [RFC 4342, 5.1].

Implementation:
---------------
 The CCID 3 RFC leaves implementation choices open as to implement the above; I have chosen the mechanism
 described in  draft-ietf-dccp-rfc3448bis, since it achieves exactly the described objective, and is likely
 to become standard in some future time.
 Since the expected normal behaviour is a non-idle connection (where ACKs continually come in), the test
 whether the connection is idle has been wrapped with the `unlikely' macro to favour this case.

Additional Notes.
-----------------
 As a minor optimisation, the setting of the `idle' flag was shifted from tx_packet_sent to tx_send_packet,
 as this happens slightly earlier.
 A further but small optimisation would be possible by not updating the cached value of X_recv when it is
 less than half the RFC 3390 initial sending rate. This however will bring only marginal gain in exchange
 for more complicated code, and is not compliant with 3448bis. Thus omitted.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   82 +++++++++++++++++++++++--------------------------
 1 file changed, 39 insertions(+), 43 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -132,12 +132,23 @@ static void ccid3_hc_tx_update_x(struct 
 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
 
+	/*
+	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
+	 * when idling [RFC 4342, 5.1]. See also draft-ietf-dccp-rfc3448bis.
+	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
+	 */
+	if (unlikely(hctx->ccid3hctx_idle)) {
+		min_rate = rfc3390_initial_rate(sk);
+		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
+	}
+
 	if (hctx->ccid3hctx_p > 0) {
 
 		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
-					hctx->ccid3hctx_x_recv * 2);
+					min_rate);
 		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								TFRC_T_MBI);
@@ -146,7 +157,7 @@ static void ccid3_hc_tx_update_x(struct 
 			(suseconds_t)hctx->ccid3hctx_rtt >= 0) {
 
 		hctx->ccid3hctx_x -			max(2 * min(hctx->ccid3hctx_x, hctx->ccid3hctx_x_recv),
+			max(min(2 * hctx->ccid3hctx_x, min_rate),
 			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
 				       hctx->ccid3hctx_rtt));
 		hctx->ccid3hctx_t_ld = *now;
@@ -210,6 +221,7 @@ static void ccid3_hc_tx_no_feedback_time
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct timeval now;
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -222,6 +234,8 @@ static void ccid3_hc_tx_no_feedback_time
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 
+	hctx->ccid3hctx_idle = 1;
+
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
@@ -240,49 +254,33 @@ static void ccid3_hc_tx_no_feedback_time
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
-		 * Check if IDLE since last timeout and recv rate is less than
-		 * 4 packets (in units of 64*bytes/sec) per RTT
+		 *  Modify the cached value of X_recv [RFC 3448, 4.4]
+		 *
+		 *  If (p = 0 || X_calc > 2 * X_recv)
+		 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
+		 *  Else
+		 *    X_recv = X_calc / 4;
+		 *
+		 *  Note that X_recv is scaled by 2^6 while X_calc is not
 		 */
-		if (!hctx->ccid3hctx_idle ||
-		    (hctx->ccid3hctx_x_recv >= 4 *
-		     scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-				hctx->ccid3hctx_rtt))) {
-			struct timeval now;
+		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
-			ccid3_pr_debug("%s(%p, state=%s), not idle\n",
-				       dccp_role(sk), sk,
-				   ccid3_tx_state_name(hctx->ccid3hctx_state));
+		if (hctx->ccid3hctx_p = 0 ||
+		    (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))) {
 
-			/*
-			 *  Modify the cached value of X_recv [RFC 3448, 4.4]
-			 *
-			 *  If (p = 0 || X_calc > 2 * X_recv)
-			 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
-			 *  Else
-			 *    X_recv = X_calc / 4;
-			 *
-			 *  Note that X_recv is scaled by 2^6 while X_calc is not
-			 */
-			BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
+			hctx->ccid3hctx_x_recv +				max(hctx->ccid3hctx_x_recv / 2,
+				    (((__u64)hctx->ccid3hctx_s) << 6) /
+							      (2 * TFRC_T_MBI));
 
-			if (hctx->ccid3hctx_p  = 0 ||
-			    (hctx->ccid3hctx_x_calc >
-			     (hctx->ccid3hctx_x_recv >> 5))) {
-
-				hctx->ccid3hctx_x_recv -					max(hctx->ccid3hctx_x_recv / 2,
-					    (((__u64)hctx->ccid3hctx_s) << 6) /
-							  (2 * TFRC_T_MBI));
-
-				if (hctx->ccid3hctx_p = 0)
-					dccp_timestamp(sk, &now);
-			} else {
-				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
-				hctx->ccid3hctx_x_recv <<= 4;
-			}
-			/* Now recalculate X [RFC 3448, 4.3, step (4)] */
-			ccid3_hc_tx_update_x(sk, &now);
+			if (hctx->ccid3hctx_p = 0)
+				dccp_timestamp(sk, &now);
+		} else {
+			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
+			hctx->ccid3hctx_x_recv <<= 4;
 		}
+		/* Now recalculate X [RFC 3448, 4.3, step (4)] */
+		ccid3_hc_tx_update_x(sk, &now);
 		/*
 		 * Schedule no feedback timer to expire in
 		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
@@ -297,8 +295,6 @@ static void ccid3_hc_tx_no_feedback_time
 		goto out;
 	}
 
-	hctx->ccid3hctx_idle = 1;
-
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
 		           jiffies + usecs_to_jiffies(t_nfb));
@@ -379,6 +375,7 @@ static int ccid3_hc_tx_send_packet(struc
 	/* prepare to send now (add options etc.) */
 	dp->dccps_hc_tx_insert_options = 1;
 	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
+	hctx->ccid3hctx_idle = 0;
 
 	/* set the nominal send time for the next following packet */
 	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
@@ -409,7 +406,6 @@ static void ccid3_hc_tx_packet_sent(stru
 	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
 	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
 	packet->dccphtx_sent   = 1;
-	hctx->ccid3hctx_idle   = 0;
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
