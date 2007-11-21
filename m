From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 21 Nov 2007 15:28:26 +0000
Subject: [PATCH 04/11] [CCID3]: Inline for moving average
Message-Id: <1195658913-24840-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The moving average computation occurs so frequently in the CCID 3 code that
it merits an inline function  of its own. This is uses a suggestion by
Arnaldo as per http://www.mail-archive.com/dccp@vger.kernel.org/msg01662.html

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c    |   25 +++++--------------------
 net/dccp/ccids/lib/tfrc.h |    9 +++++++++
 2 files changed, 14 insertions(+), 20 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a6111e5..964ec91 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -192,7 +192,7 @@ static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
 	const u16 old_s = hctx->ccid3hctx_s;
 
-	hctx->ccid3hctx_s = old_s = 0 ? len : (9 * old_s + len) / 10;
+	hctx->ccid3hctx_s = tfrc_ewma(hctx->ccid3hctx_s, len, 9);
 
 	if (hctx->ccid3hctx_s != old_s)
 		ccid3_update_send_interval(hctx);
@@ -449,25 +449,15 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 		now = ktime_get_real();
 		/*
-		 * Calculate new round trip sample as per [RFC 3448, 4.3] by
-		 *	R_sample  =  (now - t_recvdata) - t_elapsed
+		 * Calculate new RTT sample and update moving average
 		 */
 		r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, packet->dccphtx_tstamp));
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
 
@@ -481,8 +471,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
 		} else {
-			hctx->ccid3hctx_rtt = (9 * hctx->ccid3hctx_rtt +
-						   r_sample) / 10;
 
 			/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
 			if (hctx->ccid3hctx_p > 0)
@@ -700,11 +688,8 @@ static void ccid3_hc_rx_set_state(struct sock *sk,
 
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
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index faf5f7e..5a0ba86 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -37,6 +37,15 @@ static inline u32 scaled_div32(u64 a, u32 b)
 	return result;
 }
 
+/**
+ * tfrc_ewma  -  Exponentially weighted moving average
+ * @weight: Weight to be used as damping factor, in units of 1/10
+ */
+static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
+{
+	return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
+}
+
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
 
-- 
1.5.3.4

