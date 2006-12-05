From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 05 Dec 2006 20:38:23 +0000
Subject: [PATCH 2/7]: Two optimisations for sending rate recomputation
Message-Id: <200612052038.23876@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Two optimisations for sending rate recomputation

This performs two optimisations for the recomputation of the sending rate.

1) Currently the target sending rate X_calc is recalculated whenever
	a) the nofeedback timer expires, or 
	b) a feedback packet is received. 
   In the (a) case, recomputing X_calc is redundant, since

    * the parameters p and RTT do not change in between the
      reception of feedback packets;

    * the parameter X_recv is either modified from received
      feedback or via the nofeedback timer;

    * a test (`p = 0') in the nofeedback timer avoids using
      a stale/undefined value of X_calc if p was previously 0.

2) The nofeedback timer now only recomputes a timestamp when p = 0. 
   This is according to step (4) of [RFC 3448, 4.3] and avoids 
   unnecessarily determining a timestamp.

A debug statement about not updating X is also removed - it helps very
little in debugging and just clutters the logs.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>   
---
 net/dccp/ccids/ccid3.c |   27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -138,9 +138,6 @@ static void ccid3_hc_tx_update_x(struct 
 	const __u32 old_x = hctx->ccid3hctx_x;
 
 	if (hctx->ccid3hctx_p > 0) {
-		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
-						     hctx->ccid3hctx_rtt,
-						     hctx->ccid3hctx_p);
 		hctx->ccid3hctx_x = max_t(u32, min(hctx->ccid3hctx_x_calc,
 						   hctx->ccid3hctx_x_recv * 2),
 					       hctx->ccid3hctx_s / TFRC_T_MBI);
@@ -152,8 +149,7 @@ static void ccid3_hc_tx_update_x(struct 
 					usecs_div(hctx->ccid3hctx_s,
 					       	  hctx->ccid3hctx_rtt)   );
 		hctx->ccid3hctx_t_ld = *now;
-	} else
-		ccid3_pr_debug("Not changing X\n");
+	}
 
 	if (hctx->ccid3hctx_x != old_x)
 		ccid3_update_send_time(hctx);
@@ -223,9 +219,11 @@ static void ccid3_hc_tx_no_feedback_time
 			ccid3_pr_debug("%s, sk=%p, state=%s, not idle\n",
 				       dccp_role(sk), sk,
 				       ccid3_tx_state_name(hctx->ccid3hctx_state));
-			/* Halve sending rate */
 
-			/*  If (p = 0 || X_calc > 2 * X_recv)
+			/*
+			 *  Modify the cached value of X_recv [RFC 3448, 4.4]
+			 *
+			 *  If (p = 0 || X_calc > 2 * X_recv)
 			 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
 			 *  Else
 			 *    X_recv = X_calc / 4;
@@ -233,14 +231,15 @@ static void ccid3_hc_tx_no_feedback_time
 			BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
 
 			if (hctx->ccid3hctx_p  = 0 ||
-			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
+			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)  {
 				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
 								    hctx->ccid3hctx_s / (2 * TFRC_T_MBI));
-			else
+				if (hctx->ccid3hctx_p = 0)
+					dccp_timestamp(sk, &now);
+			} else
 				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc / 4;
 
-			/* Update sending rate */
-			dccp_timestamp(sk, &now);
+			/* Now recalculate X [RFC 3448, 4.3, step (4)] */
 			ccid3_hc_tx_update_x(sk, &now);
 		}
 		/*
@@ -496,6 +495,12 @@ static void ccid3_hc_tx_packet_recv(stru
 			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
 					           (u32)r_sample        ) / 10;
 
+			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
+			if (hctx->ccid3hctx_p > 0)
+				hctx->ccid3hctx_x_calc +					tfrc_calc_x(hctx->ccid3hctx_s,
+						    hctx->ccid3hctx_rtt,
+						    hctx->ccid3hctx_p);
 			ccid3_hc_tx_update_x(sk, &now);
 
 			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%ldus), s=%u, "
