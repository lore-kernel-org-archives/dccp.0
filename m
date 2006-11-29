From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 29 Nov 2006 20:52:00 +0000
Subject: [PATCH] [RFC]: Fine-grained sending rate resolution / division errors
Message-Id: <200611292052.01303@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Here is now the patch, I have had a hard time due to division of u64 by
u32. I have also checked again - it is feasible to prune X_calc and
X_recv back to u32. If you prefer that, I can change the patch. 

I'd welcome suggestions about how to improve the division, I had wanted
to at least not throw away the remainder. 

Maybe in future time everything could be scaled by powers of 2, would
make things easier.

Gerrit
-------------------------> Commit Message <---------------------------
[DCCP]: Resolve lower sending rates, avoid integer division error

This patch
 * resolves a bug in CCID 3 where packets smaller than 32/64 bytes
   resulted in sending rates of 0
 * resolves sending rates for all practically applicable cases
 * simplifies the problem that, due to the necessary scaling, overflow
   is likely
 * it implements the strategy from 
   http://www.mail-archive.com/dccp@vger.kernel.org/msg00938.html

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>   
---
 include/linux/tfrc.h   |   11 +++++--
 net/dccp/ccids/ccid3.c |   70 +++++++++++++++++++------------------------------
 net/dccp/ccids/ccid3.h |   20 +++++++++-----
 3 files changed, 49 insertions(+), 52 deletions(-)

--- a/include/linux/tfrc.h
+++ b/include/linux/tfrc.h
@@ -37,11 +37,16 @@ struct tfrc_rx_info {
  * 	@tfrctx_p:	current loss event rate (5.4)
  * 	@tfrctx_rto:	estimate of RTO, equals 4*RTT (4.3)
  * 	@tfrctx_ipi:	inter-packet interval (4.6)
+ *
+ *  NOTE: The sender needs to store fractional sending rates in the range 1/64
+ *  (smallest sending rate: a packet of 1 byte every 64 seconds) up to 4 Gbyte
+ *  per second (IPv6 max jumbogram). Hence we store _all_ sending rates in units
+ *  of 64 * bytes/second - hence the use of __u64.
  */
 struct tfrc_tx_info {
-	__u32 tfrctx_x;
-	__u32 tfrctx_x_recv;
-	__u32 tfrctx_x_calc;
+	__u64 tfrctx_x;
+	__u64 tfrctx_x_recv;
+	__u64 tfrctx_x_calc;
 	__u32 tfrctx_rtt;
 	__u32 tfrctx_p;
 	__u32 tfrctx_rto;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -41,27 +41,6 @@
 #include "lib/tfrc.h"
 #include "ccid3.h"
 
-/*
- * Reason for maths here is to avoid 32 bit overflow when a is big.
- * With this we get close to the limit.
- */
-static u32 usecs_div(const u32 a, const u32 b)
-{
-	const u32 div = a < (UINT_MAX / (USEC_PER_SEC /    10)) ?    10 :
-			a < (UINT_MAX / (USEC_PER_SEC /    50)) ?    50 :
-			a < (UINT_MAX / (USEC_PER_SEC /   100)) ?   100 :
-			a < (UINT_MAX / (USEC_PER_SEC /   500)) ?   500 :
-			a < (UINT_MAX / (USEC_PER_SEC /  1000)) ?  1000 :
-			a < (UINT_MAX / (USEC_PER_SEC /  5000)) ?  5000 :
-			a < (UINT_MAX / (USEC_PER_SEC / 10000)) ? 10000 :
-			a < (UINT_MAX / (USEC_PER_SEC / 50000)) ? 50000 :
-								 100000;
-	const u32 tmp = a * (USEC_PER_SEC / div);
-	return (b >= 2 * div) ? tmp / (b / div) : tmp;
-}
-
-
-
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
@@ -109,7 +88,8 @@ static inline void ccid3_update_send_tim
 	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
 
 	/* Calculate new t_ipi (inter packet interval) by t_ipi = s / X_inst */
-	hctx->ccid3hctx_t_ipi = usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_x);
+	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
+					   hctx->ccid3hctx_x >> 6);
 
 	/* Update nominal send time with regard to the new t_ipi */
 	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
@@ -130,6 +110,10 @@ static inline void ccid3_update_send_tim
  *
  * If X has changed, we also update the scheduled send time t_now,
  * the inter-packet interval t_ipi, and the delta value.
+ *
+ * NOTE: X, X_calc, and X_recv are all stored in units of 64bytes / second in
+ *       order to enable a minimal resolution of 1byte / 64second. This is the
+ *       smallest possible `s' with the minimal sending rate from RFC 3448.
  */ 
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
@@ -143,16 +127,17 @@ static void ccid3_hc_tx_update_x(struct 
 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
 						     hctx->ccid3hctx_rtt,
 						     hctx->ccid3hctx_p);
-		hctx->ccid3hctx_x = max_t(u32, min(hctx->ccid3hctx_x_calc,
+		hctx->ccid3hctx_x_calc <<= 6;	/* in units of 64bytes/sec */
+		hctx->ccid3hctx_x = max_t(u64, min(hctx->ccid3hctx_x_calc,
 						   hctx->ccid3hctx_x_recv * 2),
-					       hctx->ccid3hctx_s / TFRC_T_MBI);
+					  (hctx->ccid3hctx_s <<6) / TFRC_T_MBI);
 
 	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) > 							  hctx->ccid3hctx_rtt) {
-		hctx->ccid3hctx_x = max(min(hctx->ccid3hctx_x_recv,
-					    hctx->ccid3hctx_x      ) * 2,
-					usecs_div(hctx->ccid3hctx_s,
-					       	  hctx->ccid3hctx_rtt)   );
+		hctx->ccid3hctx_x = max( 2  *  min(hctx->ccid3hctx_x_recv,
+					    	   hctx->ccid3hctx_x      ),
+					scaled_div(hctx->ccid3hctx_s << 6,
+						   hctx->ccid3hctx_rtt    ));
 		hctx->ccid3hctx_t_ld = *now;
 	} else
 		ccid3_pr_debug("Not changing X\n");
@@ -199,14 +184,14 @@ static void ccid3_hc_tx_no_feedback_time
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
-		hctx->ccid3hctx_x = min_t(u32, hctx->ccid3hctx_x / 2,
-					       hctx->ccid3hctx_s / TFRC_T_MBI);
+		hctx->ccid3hctx_x = min_t(u64, hctx->ccid3hctx_x / 2,
+				  	      (hctx->ccid3hctx_s << 6) / TFRC_T_MBI);
 
 		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %d "
 			       "bytes/s\n",
 			       dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
-			       hctx->ccid3hctx_x);
+			       (int) hctx->ccid3hctx_x >> 6);
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
@@ -219,13 +204,13 @@ static void ccid3_hc_tx_no_feedback_time
 		 */
 		if (!hctx->ccid3hctx_idle ||
 		    (hctx->ccid3hctx_x_recv >-		     4 * usecs_div(hctx->ccid3hctx_s, hctx->ccid3hctx_rtt))) {
+		     		4 * scaled_div(hctx->ccid3hctx_s << 6,
+					       hctx->ccid3hctx_rtt    ) ) ) {
 			struct timeval now;
 
 			ccid3_pr_debug("%s, sk=%p, state=%s, not idle\n",
 				       dccp_role(sk), sk,
 				       ccid3_tx_state_name(hctx->ccid3hctx_state));
-			/* Halve sending rate */
 
 			/*  If (X_calc > 2 * X_recv)
 			 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
@@ -236,8 +221,9 @@ static void ccid3_hc_tx_no_feedback_time
 			       hctx->ccid3hctx_x_calc = 0);
 
 			if (hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
-				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
-								    hctx->ccid3hctx_s / (2 * TFRC_T_MBI));
+				hctx->ccid3hctx_x_recv +					max_t(u64, hctx->ccid3hctx_x_recv / 2,
+					          (hctx->ccid3hctx_s << 6)/(2 * TFRC_T_MBI));
 			else
 				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc / 4;
 
@@ -317,9 +303,9 @@ static int ccid3_hc_tx_send_packet(struc
 		hctx->ccid3hctx_t_last_win_count = now;
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
-		/* Set initial sending rate to 1 packet per second */
+		/* Set initial sending rate to 1pps: X = s * 64 bytes/sec */
 		ccid3_hc_tx_update_s(hctx, skb->len);
-		hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
+		hctx->ccid3hctx_x     = hctx->ccid3hctx_s << 6;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
 		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
@@ -443,8 +429,8 @@ static void ccid3_hc_tx_packet_recv(stru
 			return;
 		}
 
-		/* Update receive rate */
-		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
+		/* Update receive rate in units of 64 * bytes/second */
+		hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate << 6;
 
 		/* Update loss event rate */
 		if (pinv = ~0 || pinv = 0)
@@ -477,7 +463,7 @@ static void ccid3_hc_tx_packet_recv(stru
 			u16 w_init = max(    4 * hctx->ccid3hctx_s,
 					 max(2 * hctx->ccid3hctx_s, 4380));
 			hctx->ccid3hctx_rtt  = r_sample;
-			hctx->ccid3hctx_x    = usecs_div(w_init, r_sample);
+			hctx->ccid3hctx_x    = scaled_div(w_init <<6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
 			ccid3_update_send_time(hctx);
@@ -696,7 +682,7 @@ static void ccid3_hc_rx_send_feedback(st
 	case TFRC_RSTATE_DATA: {
 		const u32 delta = timeval_delta(&now,
 					&hcrx->ccid3hcrx_tstamp_last_feedback);
-		hcrx->ccid3hcrx_x_recv = usecs_div(hcrx->ccid3hcrx_bytes_recv,
+		hcrx->ccid3hcrx_x_recv = scaled_div(hcrx->ccid3hcrx_bytes_recv,
 						   delta);
 	}
 		break;
@@ -822,7 +808,7 @@ found:
 
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
-	x_recv = usecs_div(hcrx->ccid3hcrx_bytes_recv, delta);
+	x_recv = scaled_div(hcrx->ccid3hcrx_bytes_recv, delta);
 
 	if (x_recv = 0)
 		x_recv = hcrx->ccid3hcrx_x_recv;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -75,14 +75,14 @@ enum ccid3_hc_tx_states {
 
 /** struct ccid3_hc_tx_sock - CCID3 sender half-connection socket
  *
- * @ccid3hctx_x - Current sending rate
- * @ccid3hctx_x_recv - Receive rate in bytes per second
- * @ccid3hctx_x_calc - Calculated send rate (RFC 3448, 3.1)
- * @ccid3hctx_rtt - Estimate of current round trip time in usecs
+ * @ccid3hctx_x - Current sending rate in 64 * bytes per second
+ * @ccid3hctx_x_recv - Receive rate    in 64 * bytes per second
+ * @ccid3hctx_x_calc - Calculated rate in 64 * bytes per second
+ * @ccid3hctx_rtt - Estimate of current round trip time           in usecs
  * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
- * @ccid3hctx_s - Packet size
- * @ccid3hctx_t_rto - Retransmission Timeout (RFC 3448, 3.1)
- * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6)
+ * @ccid3hctx_s - Packet size in bytes
+ * @ccid3hctx_t_rto - Retransmission Timeout (RFC 3448, 3.1)      in usecs
+ * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
  * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
  * @ccid3hctx_last_win_count - Last window counter sent
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
@@ -171,4 +171,10 @@ static inline struct ccid3_hc_rx_sock *c
     return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
 }
 
+static inline u64 scaled_div(u64 a, u32 b)
+{
+	a *= 1000000;
+	do_div(a, b);
+	return a;
+}
 #endif /* _DCCP_CCID3_H_ */

