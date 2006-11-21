From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Nov 2006 15:45:18 +0000
Subject: [PATCH 2/6]: Simplify control flow in the calculation of t_ipi
Message-Id: <200611211545.18544@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Simplify control flow in the calculation of t_ipi


This patch performs a simplifying (performance) optimisation:

 In each call of the inline function ccid3_calc_new_t_ipi(), the state is
 tested against TFRC_SSTATE_NO_FBACK. This is expensive when the function
 is called very often. A simpler solution, implemented by this patch, is
 to adapt the control flow.

Background:
-----------
 Upon sender initialisation, the values of t_ipi, t_nom = t_0, delta, as
 well as the initial packet sending rate, are all constants [RFC 3448, 4.2].
 Until feedback arrives, these values are not changed. Hence it is not necessary
 to recalculate t_ipi, t_nom, delta until the first feedback has arrived, i.e.
 as long as the state TFRC_SSTATE_NO_FBACK persists.

Justification:
--------------
 ccid3_calc_new_t_ipi() is called only in two places:
 
   * in ccid3_hc_tx_packet_recv(); here the state is never TFRC_SSTATE_NO_FBACK, due to
	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
		/* ... */
   * in ccid3_hc_tx_packet_sent()
	  
 => Only in the second case, the state might be TFRC_SSTATE_NO_FBACK and this only 
     during the initial phase of a connection.

Solution:
---------
 This patch avoids such a recalculation by a simple change of control flow in 
 ccid3_hc_tx_packet_sent(). As a consequence, ccid3_calc_new_t_ipi() is never called in 
 the state TFRC_SSTATE_NO_FBACK, hence the test against this state can safely be removed. 

 In addition, a problematic comment in ccid3_calc_new_t_ipi() was removed:
   * the first part of the comment (initial t_ipi = 1 second) is correct
   * the second part of the comment is not correct wrt. [RFC 3448, 4.4]

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    2 ++
 1 file changed, 2 insertions(+)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -103,13 +103,7 @@ static void ccid3_hc_tx_set_state(struct
 /* Calculate new t_ipi (inter packet interval) by t_ipi = s / X_inst */
 static inline void ccid3_calc_new_t_ipi(struct ccid3_hc_tx_sock *hctx)
 {
-	/*
-	 * If no feedback spec says t_ipi is 1 second (set elsewhere and then
-	 * doubles after every no feedback timer (separate function)
-	 */
-	if (hctx->ccid3hctx_state != TFRC_SSTATE_NO_FBACK)
-		hctx->ccid3hctx_t_ipi = usecs_div(hctx->ccid3hctx_s,
-						  hctx->ccid3hctx_x);
+	hctx->ccid3hctx_t_ipi = usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_x);
 }
 
 /* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
@@ -394,6 +388,8 @@ static void ccid3_hc_tx_packet_sent(stru
 				  "as a data packet",  dccp_role(sk));
 		return;
 	case TFRC_SSTATE_NO_FBACK:
+		/* t_nom, t_ipi, delta do not change until feedback arrives */
+		return;
 	case TFRC_SSTATE_FBACK:
 		if (len > 0) {
 			timeval_sub_usecs(&hctx->ccid3hctx_t_nom,
