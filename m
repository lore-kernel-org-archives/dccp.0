From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 24 Jan 2007 11:19:00 +0000
Subject: [PATCHv2 1/1]: Update t_ipi when `s' changes
Message-Id: <200701241119.01030@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the same 3e patch as before, but now updates t_ipi whenever `s' 
changes. This follows a suggestion by Ian, the inter-diff to the previous patch is:

--------------------------------------------------------------------------------------
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-       hctx->ccid3hctx_s = hctx->ccid3hctx_s = 0 ? len :
-                           (9 * hctx->ccid3hctx_s + len) / 10;
-       /*
-        * Note: We could do a potential optimisation here - when `s' changes,
-        *       recalculate sending rate and consequently t_ipi, t_delta, and
-        *       t_now. This is however non-standard, and the benefits are not
-        *       clear, so it is currently left out.
-        */
+       const u16 old_s = hctx->ccid3hctx_s;
+
+       hctx->ccid3hctx_s  =  old_s = 0 ?  len  :  (9 * old_s + len) / 10;
+
+       if (hctx->ccid3hctx_s != old_s)
+               ccid3_update_send_interval(hctx);
 }

 /*
@@ -325,8 +323,7 @@
                ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);

                /* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
-               ccid3_hc_tx_update_s(hctx, skb->len);
-               hctx->ccid3hctx_x = hctx->ccid3hctx_s;
+               hctx->ccid3hctx_x  =  hctx->ccid3hctx_s  =  skb->len;
                hctx->ccid3hctx_x <<= 6;

                /* First timeout, according to [RFC 3448, 4.2], is 1 second */
--------------------------------------------------------------------------------------
================> PATCH V2 <=====================
[CCID 3]: Remove race condition and update t_ipi when `s' changes

This 

 1. removes a race condition in the access to the scheduled send time t_nom which 
    results from allowing asynchronous r/w access to t_nom without locks;

 2. updates the inter-packet interval t_ipi = s/X when `s' changes, following a
    suggestion by Ian McDonald. 
		  


			D e t a i l e d   B a c k g r o u n d [not commit message]
			----------------------------------------------------------
 ccid3_hc_tx_packet_recv and ccid3_hc_tx_no_feedback_timer both have, via ccid3_hc_tx_update_x,
 asynchronous write access to ccid3hctx_t_nom. Thus it can happen that ccid3_hc_tx_send_packet
 tries to read/write the value of t_nom while at the same time this value is being changed. 
 
 In the worst case, t_ipi has just been subtracted, which means that the packet will be sent 
 immediately, thereby defeating the whole intention of the rate-based packet scheduling. There 
 is no locking protection against this simultaneous access, hence this race condition is entirely 
 possible and likely. 
 
 Currently several different functions have asynchronous access to ccid3hctx_t_nom:
 
  * ccid3_hc_tx_send_packet - read access to check whether further delaying is needed
                            - write access to designate send time for next packet
  * ccid3_update_send_time  - write access to re-calculate send interval
 
 The latter function is called 
  1) whenever the sending rate X changes (via ccid3_hc_tx_update_x) 
      --> if X increases, a smaller send interval and a sooner t_nom results
      --> if X decreases, a larger send interval and a later t_nom results;
  2) when the nofeedback timer expires in state NO_FBACK;
  3) when receiving the first feedback packet (ccid3_hc_tx_packet_recv, state NO_FBACK).
 
 Cases 2/3 happen at most once during the lifetime of a connection, whereas (1) happens
 
  a) whenever as a result of receiving feedback the sending rate X changes
  b) whenever the sending rate is halved as a result of an expiring nofeedback timer
 
 Hence, in case (b) the send interval is always increased, whereas in (a) it is decreased
 or increased depending on the nature of received feedback. 
 
 The modification of t_nom via ccid3_update_send_time has an impact and relevance only for a 
 single packet: the immediately next one. It is really questionable whether this modification 
 has any benefit, as t_nom can be influenced in both directions (for good or for worse). 
 

Fix: By monopolising read/write access of t_nom to ccid3_hc_tx_send_packet. This removes
     the potential race condition.
     No harm occurs if t_ipi/delta change while ccid3_hc_tx_send_packet is in the process
     of sending a packet - in this case the most recently available values will be used.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   35 ++++++++++++-----------------------
 1 file changed, 12 insertions(+), 23 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -81,20 +81,14 @@ static void ccid3_hc_tx_set_state(struct
 }
 
 /*
- * Recalculate scheduled nominal send time t_nom, inter-packet interval
- * t_ipi, and delta value. Should be called after each change to X.
+ * Recalculate t_ipi and delta (should be called whenver X changes)
  */
-static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
+static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
-	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
 	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
 					   hctx->ccid3hctx_x >> 6);
 
-	/* Update nominal send time with regard to the new t_ipi */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
@@ -118,8 +112,6 @@ static inline void ccid3_update_send_tim
  *       fine-grained resolution of sending rates. This requires scaling by 2^6
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
  *
- * If X has changed, we also update the scheduled send time t_now,
- * the inter-packet interval t_ipi, and the delta value.
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
@@ -150,7 +142,7 @@ static void ccid3_hc_tx_update_x(struct 
 			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
 			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
 
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_interval(hctx);
 	}
 }
 
@@ -160,14 +152,12 @@ static void ccid3_hc_tx_update_x(struct 
  */
 static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
-	hctx->ccid3hctx_s = hctx->ccid3hctx_s = 0 ? len :
-			    (9 * hctx->ccid3hctx_s + len) / 10;
-	/*
-	 * Note: We could do a potential optimisation here - when `s' changes,
-	 *	 recalculate sending rate and consequently t_ipi, t_delta, and
-	 *	 t_now. This is however non-standard, and the benefits are not
-	 *	 clear, so it is currently left out.
-	 */
+	const u16 old_s = hctx->ccid3hctx_s;
+
+	hctx->ccid3hctx_s  =  old_s = 0 ?  len  :  (9 * old_s + len) / 10;
+
+	if (hctx->ccid3hctx_s != old_s)
+		ccid3_update_send_interval(hctx);
 }
 
 /*
@@ -227,7 +217,7 @@ static void ccid3_hc_tx_no_feedback_time
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_interval(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
@@ -333,8 +323,7 @@ static int ccid3_hc_tx_send_packet(struc
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
 		/* Set initial sending rate X/s to 1pps (X is scaled by 2^6) */
-		ccid3_hc_tx_update_s(hctx, skb->len);
-		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
+		hctx->ccid3hctx_x  =  hctx->ccid3hctx_s  =  skb->len;
 		hctx->ccid3hctx_x <<= 6;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
@@ -483,7 +472,7 @@ static void ccid3_hc_tx_packet_recv(stru
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
-			ccid3_update_send_time(hctx);
+			ccid3_update_send_interval(hctx);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
