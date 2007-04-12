From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:17:27 +0000
Subject: [PATCH 24/29] Macro for moving average
Message-Id: <20070412211727.GY21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The moving average computation occurs so frequently in the CCID 3 code that
it merits a macro of its own.

Committer note: changed the patch to have it as an inline that returns the new
                value, keeping the logic.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c    |    8 +++-----
 net/dccp/ccids/lib/tfrc.h |   11 +++++++++++
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 9474331..428aa92 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -183,7 +183,7 @@ static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 {
 	const u16 old_s = hctx->ccid3hctx_s;
 
-	hctx->ccid3hctx_s = old_s = 0 ? len : (9 * old_s + len) / 10;
+	hctx->ccid3hctx_s = tfrc_ewma(hctx->ccid3hctx_s, len, 9);
 
 	if (hctx->ccid3hctx_s != old_s)
 		ccid3_update_send_interval(hctx);
@@ -474,8 +474,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	 *
 	 * q is a constant, RFC 3448 recommends 0.9
 	 */
-	hctx->ccid3hctx_rtt = hctx->ccid3hctx_rtt = 0 ?  r_sample
-			    : (9 * hctx->ccid3hctx_rtt + r_sample) / 10;
+	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
 	/*
 	 * Update allowed sending rate as per draft rfc3448bis, 4.2/4.3
@@ -724,8 +723,7 @@ static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
 	if (unlikely(len = 0))	/* don't update on empty packets (e.g. ACKs) */
 		ccid3_pr_debug("Packet payload length is 0 - not updating\n");
 	else
-		hcrx->ccid3hcrx_s = hcrx->ccid3hcrx_s = 0 ? len :
-				    (9 * hcrx->ccid3hcrx_s + len) / 10;
+		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
 }
 
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index faf5f7e..6addc23 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -37,6 +37,17 @@ static inline u32 scaled_div32(u64 a, u32 b)
 	return result;
 }
 
+/**
+ * Exponentially weighted moving average
+ * @weight: Weight to be used as damping factor, in units of 1/10
+ */
+static inline u32 tfrc_ewma(const u32 val, const u32 newval, const u8 weight)
+{
+	if (val != 0)
+		return (weight * val + (10 - weight) * newval) / 10;
+	return newval;
+}
+
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
 
-- 
1.5.0.6

