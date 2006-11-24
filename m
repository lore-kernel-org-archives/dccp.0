From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:48 +0000
Subject: [PATCH 6/10]: Consolidate handling of t_RTO
Message-Id: <200611241619.48635@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3] Consolidate handling of t_RTO

This patch 
 * removes setting t_RTO in ccid3_hc_tx_init (per [RFC 3448, 4.2], t_RTO is
   undefined until feedback has been received);

 * makes some trivial changes (updates of comments);

 * performs a small optimisation by exploiting that the feedback timeout
   uses the value of t_ipi. The way it is done is safe, because the timeouts
   appear after the changes to t_ipi, ensuring that up-to-date values are used;

 * in ccid3_hc_tx_packet_recv, moves the t_rto statement closer to the calculation
   of the next_tmout. This makes the code clearer to read and is also safe, since
   t_rto is not updated until the next call of ccid3_hc_tx_packet_recv, and is not
   read by the functions called via ccid_wait_for_ccid();

 * removes a `max' statement in sk_reset_timer, this is not needed since the timeout
   value is always greater than 1E6 microseconds.

 * adds `XXX'es to highlight that currently the nofeedback timer is set
   in a non-standard way

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>	
---
 net/dccp/ccids/ccid3.c |   29 ++++++++++++++---------------
 1 file changed, 14 insertions(+), 15 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -244,11 +244,10 @@ static void ccid3_hc_tx_no_feedback_time
 		}
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * R, 2 * s / X)
+		 * max(4 * t_RTO, 2 * s/X)  =  max(4 * t_RTO, 2 * t_ipi)
+		 * XXX This is non-standard, RFC 3448, 4.3 uses 4 * R
 		 */
-		next_tmout = max_t(u32, hctx->ccid3hctx_t_rto, 
-					2 * usecs_div(hctx->ccid3hctx_s,
-						      hctx->ccid3hctx_x));
+		next_tmout = max(hctx->ccid3hctx_t_rto, 2*hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
@@ -482,10 +481,6 @@ static void ccid3_hc_tx_packet_recv(stru
 			       "r_sample=%us\n", dccp_role(sk), sk,
 			       hctx->ccid3hctx_rtt, r_sample);
 
-		/* Update timeout interval */
-		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
-					      USEC_PER_SEC);
-
 		/* Update receive rate */
 		hctx->ccid3hctx_x_recv = x_recv;/* X_recv in bytes per sec */
 
@@ -513,17 +508,22 @@ static void ccid3_hc_tx_packet_recv(stru
 					 &hctx->ccid3hctx_hist, packet);
 		/*
 		 * As we have calculated new ipi, delta, t_nom it is possible that
-		 * we now can send a packet, so wake up dccp_wait_for_ccids.
+		 * we now can send a packet, so wake up dccp_wait_for_ccid
 		 */
 		sk->sk_write_space(sk);
 
+
+		/* Update timeout interval. We use the alternative variant of
+		 * [RFC 3448, 3.1] which sets the upper bound of t_rto to one
+		 * second, as it is suggested for TCP (see RFC 2988, 2.4). */
+		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
+					      	   USEC_PER_SEC            );
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * R, 2 * s / X)
+		 * max(4 * t_RTO, 2 * s/X)  =  max(4 * t_RTO, 2 * t_ipi)
+		 * XXX This is non-standard, RFC 3448, 4.3 uses 4 * R
 		 */
-		next_tmout = max(hctx->ccid3hctx_t_rto,
-				 2 * usecs_div(hctx->ccid3hctx_s,
-					       hctx->ccid3hctx_x));
+		next_tmout = max(hctx->ccid3hctx_t_rto, 2*hctx->ccid3hctx_t_ipi);
 			
 		ccid3_pr_debug("%s, sk=%p, Scheduled no feedback timer to "
 			       "expire in %lu jiffies (%luus)\n",
@@ -531,7 +531,7 @@ static void ccid3_hc_tx_packet_recv(stru
 			       usecs_to_jiffies(next_tmout), next_tmout); 
 
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer, 
-			       jiffies + max_t(u32, 1, usecs_to_jiffies(next_tmout)));
+				   jiffies + usecs_to_jiffies(next_tmout));
 
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;   
@@ -621,7 +621,6 @@ static int ccid3_hc_tx_init(struct ccid 
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	hctx->ccid3hctx_s     = 0;
-	hctx->ccid3hctx_t_rto = USEC_PER_SEC;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
 
