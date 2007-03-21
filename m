From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:46:10 +0000
Subject: [PATCH 24/25]: Macro for moving average
Message-Id: <200703211846.10823@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Macro for moving average

The moving average computation occurs so frequently in the CCID 3 code that
it merits a macro of its own.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c    |    8 +++-----
 net/dccp/ccids/lib/tfrc.h |    8 ++++++++
 2 files changed, 11 insertions(+), 5 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -37,6 +37,14 @@ static inline u32 scaled_div32(u64 a, u3
 	return result;
 }
 
+/**
+ * Macro for exponentially weighted moving average
+ * @weight: Weight to be used as damping factor, in units of 1/10
+ * Beware that @val is evaluated multiple times.
+ */
+#define TFRC_EWMA(val, newval, weight) \
+	val = val? ((weight) * val + (10 - (weight)) * (newval)) / 10 : (newval)
+
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -183,7 +183,7 @@ static inline void ccid3_hc_tx_update_s(
 {
 	const u16 old_s = hctx->ccid3hctx_s;
 
-	hctx->ccid3hctx_s = old_s = 0 ? len : (9 * old_s + len) / 10;
+	TFRC_EWMA(hctx->ccid3hctx_s, len, 9);
 
 	if (hctx->ccid3hctx_s != old_s)
 		ccid3_update_send_interval(hctx);
@@ -474,8 +474,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	 *
 	 * q is a constant, RFC 3448 recommends 0.9
 	 */
-	hctx->ccid3hctx_rtt = hctx->ccid3hctx_rtt = 0 ?  r_sample
-			    : (9 * hctx->ccid3hctx_rtt + r_sample) / 10;
+	TFRC_EWMA(hctx->ccid3hctx_rtt, r_sample, 9);
 
 	/*
 	 * Update allowed sending rate as per draft rfc3448bis, 4.2/4.3
@@ -724,8 +723,7 @@ static inline void ccid3_hc_rx_update_s(
 	if (unlikely(len = 0))	/* don't update on empty packets (e.g. ACKs) */
 		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
 	else
-		hcrx->ccid3hcrx_s = hcrx->ccid3hcrx_s = 0 ? len :
-				    (9 * hcrx->ccid3hcrx_s + len) / 10;
+		TFRC_EWMA(hcrx->ccid3hcrx_s, len, 9);
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
