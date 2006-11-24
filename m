From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:41 +0000
Subject: [PATCH 5/10]: Consistently update t_nom, t_ipi, t_delta
Message-Id: <200611241619.41268@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3] Consistently update t_nom, t_ipi, t_delta

This patch 

 * consolidates updating of parameters (t_nom, t_ipi, t_delta) which 
   need to be updated at the same time, since they are inter-dependent

 * removes two inline functions which are no longer needed as a result of 
   the above consolidation

 * resolves a FIXME regarding the re-calculation of t_ipi within the nofeedback
   timer, in the state where no feedback has previously been received

 * ties updating these parameters to updating the sending rate X, exploiting
   that all three parameters in turn depend on X; and using a small optimisation
   which can reduce the number of required instructions: only update the three
   parameters when X really changes

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>   
---
 net/dccp/ccids/ccid3.c |   36 +++++++++++++++---------------------
 1 file changed, 15 insertions(+), 21 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -100,19 +100,22 @@ static void ccid3_hc_tx_set_state(struct
 	hctx->ccid3hctx_state = state;
 }
 
-/* Calculate new t_ipi (inter packet interval) by t_ipi = s / X_inst */
-static inline void ccid3_calc_new_t_ipi(struct ccid3_hc_tx_sock *hctx)
+/* Recalculate scheduled nominal send time t_nom, inter-packet interval
+ * t_ipi, and delta value. Should be called after each change to X.    */
+static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 {
+	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+
+	/* Calculate new t_ipi (inter packet interval) by t_ipi = s / X_inst */
 	hctx->ccid3hctx_t_ipi = usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_x);
-}
 
-/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-static inline void ccid3_calc_new_delta(struct ccid3_hc_tx_sock *hctx)
-{
+	/* Update nominal send time with regard to the new t_ipi */
+	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+
+	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
 }
-
 /*
  * Update X by
  *    If (p > 0)
@@ -126,6 +129,7 @@ static inline void ccid3_calc_new_delta(
 static void ccid3_hc_tx_update_x(struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	const __u32 old_x = hctx->ccid3hctx_x;
 
 	/* To avoid large error in calcX */
 	if (hctx->ccid3hctx_p >= TFRC_SMALLEST_P) {
@@ -149,6 +153,8 @@ static void ccid3_hc_tx_update_x(struct 
 			hctx->ccid3hctx_t_ld = now;
 		}
 	}
+	if(hctx->ccid3hctx_x != old_x)
+		ccid3_update_send_time(hctx);
 }
 
 /*
@@ -202,11 +208,7 @@ static void ccid3_hc_tx_no_feedback_time
 		/* We cannot restart the timer as per [RFC 3448, 4.4] step (3),
 		 * since RTT is still undefined. We keep the previous value.  */
 		next_tmout = TFRC_INITIAL_TIMEOUT;
-		/*
-		 * FIXME - not sure above calculation is correct. See section
-		 * 5 of CCID3 11 should adjust tx_t_ipi and double that to
-		 * achieve it really
-		 */
+		ccid3_update_send_time(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
@@ -503,17 +505,9 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/* Update sending rate */
+		/* Update sending rate (and likely t_ipi, t_nom, and delta) */
 		ccid3_hc_tx_update_x(sk);
 
-		/* Update next send time */
-		timeval_sub_usecs(&hctx->ccid3hctx_t_nom,
-				  hctx->ccid3hctx_t_ipi);
-		ccid3_calc_new_t_ipi(hctx);
-		timeval_add_usecs(&hctx->ccid3hctx_t_nom,
-				  hctx->ccid3hctx_t_ipi);
-		ccid3_calc_new_delta(hctx);
-
 		/* remove all packets older than the one acked from history */
 		dccp_tx_hist_purge_older(ccid3_tx_hist,
 					 &hctx->ccid3hctx_hist, packet);
