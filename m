From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 09 Jun 2007 18:58:42 +0000
Subject: [PATCH 6/6]: Inline for moving average
Message-Id: <200706091958.42485@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Inline for moving average

The moving average computation occurs so frequently in the CCID 3 code that
it merits an inline function  of its own. This is built on a suggestion by
Arnaldo in http://www.mail-archive.com/dccp@vger.kernel.org/msg01662.html

Notes:
------
 1. The RTT estimate from the SYN exchange is now used when it is available, 
    increasing initial accuracy of RTT estimator.
 2. Shortened the statement for updating `s' a bit.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c    |   25 +++++--------------------
 net/dccp/ccids/lib/tfrc.h |    9 +++++++++
 2 files changed, 14 insertions(+), 20 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -37,6 +37,15 @@ static inline u32 scaled_div32(u64 a, u3
 	return result;
 }
 
+/**
+ * tfrc_ewma  -  Exponentially weighted moving average
+ * @weight: Weight to be used as damping factor, in units of 1/10
+ */
+static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
+{
+	return avg? (weight * avg + (10 - weight) * newval) / 10 : newval;
+}
+
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -188,7 +188,7 @@ static inline void ccid3_hc_tx_update_s(
 {
 	const u16 old_s = hctx->ccid3hctx_s;
 
-	hctx->ccid3hctx_s = old_s = 0 ? len : (9 * old_s + len) / 10;
+	hctx->ccid3hctx_s = tfrc_ewma(hctx->ccid3hctx_s, len, 9);
 
 	if (hctx->ccid3hctx_s != old_s)
 		ccid3_update_send_interval(hctx);
@@ -461,25 +461,15 @@ static void ccid3_hc_tx_packet_recv(stru
 		dccp_timestamp(sk, &now);
 
 		/*
-		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
-		 *	R_sample  =  (now - t_recvdata) - t_elapsed
+		 * Calculate new RTT sample and update moving average
 		 */
 		r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
+		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
-		/*
-		 * Update RTT estimate by
-		 * If (No feedback recv)
-		 *    R = R_sample;
-		 * Else
-		 *    R = q * R + (1 - q) * R_sample;
-		 *
-		 * q is a constant, RFC 3448 recomments 0.9
-		 */
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
 			/*
 			 * Larger Initial Windows [RFC 4342, sec. 5]
 			 */
-			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
 			hctx->ccid3hctx_t_ld = now;
 
@@ -493,8 +483,6 @@ static void ccid3_hc_tx_packet_recv(stru
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
-			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
-						   r_sample) / 10;
 
 			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
 			if (hctx->ccid3hctx_p > 0)
@@ -720,11 +708,8 @@ static void ccid3_hc_rx_set_state(struct
 
 static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
 {
-	if (unlikely(len = 0))	/* don't update on empty packets (e.g. ACKs) */
-		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
-	else
-		hcrx->ccid3hcrx_s = hcrx->ccid3hcrx_s = 0 ? len :
-				    (9 * hcrx->ccid3hcrx_s + len) / 10;
+	if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
+		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
