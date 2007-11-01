From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:57 +0000
Subject: [PATCH 19/25] Share ccid3_hc_tx_idle_rtt function via tfrc_ccids
Message-Id: <200710312131.57558.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid3_hc_tx_idle_rtt function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -121,13 +121,6 @@ static inline void ccid3_update_send_int
 
 }
 
-static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
-{
-	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
-
-	return delta/hctx->ccid3hctx_rtt;
-}
-
 /**
  * ccid3_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
@@ -151,7 +144,7 @@ static void ccid3_hc_tx_update_x(struct 
 	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
+	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
 		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
 	}
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -133,13 +133,6 @@ static inline void ccid4_update_send_int
 
 }
 
-static u32 ccid4_hc_tx_idle_rtt(struct ccid4_hc_tx_sock *hctx, ktime_t now)
-{
-	u32 delta = ktime_us_delta(now, hctx->ccid4hctx_t_last_win_count);
-
-	return delta/hctx->ccid4hctx_rtt;
-}
-
 /**
  * ccid4_hc_tx_x_header_penalty  -  Update allower sending rate X
  * @hctx: half-connection to adjust
@@ -174,7 +167,7 @@ static void ccid4_hc_tx_update_x(struct 
 	 * a sender is idle if it has not sent anything over a 2-RTT-period.
 	 * For consistency with X and X_recv, min_rate is also scaled by 2^6.
 	 */
-	if (ccid4_hc_tx_idle_rtt(hctx, now) >= 2) {
+	if (tfrc_hc_tx_idle_rtt(hctx, now) >= 2) {
 		min_rate = rfc3390_initial_rate(sk);
 		min_rate = max(min_rate, 2 * hctx->ccid4hctx_x_recv);
 	}
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
@@ -32,3 +32,13 @@ inline u64 rfc3390_initial_rate(struct s
 }
 
 EXPORT_SYMBOL_GPL(rfc3390_initial_rate);
+
+u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now)
+{
+	u32 delta = ktime_us_delta(now, hctx->tfrchctx_t_last_win_count);
+
+	return delta/hctx->tfrchctx_rtt;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_hc_tx_idle_rtt);
+
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -173,3 +173,5 @@ static const char *tfrc_tx_state_name(en
 #endif
 
 extern u64 rfc3390_initial_rate(struct sock *sk);
+
+extern u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now);
