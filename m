From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:59 +0000
Subject: [PATCH 20/25] Share ccid3_hc_tx_update_win_count function via tfrc_ccids
Message-Id: <200710312131.59697.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid3_hc_tx_update_win_count function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -192,28 +192,6 @@ static inline void ccid3_hc_tx_update_s(
 		ccid3_update_send_interval(hctx);
 }
 
-/*
- *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
- *	The algorithm is not applicable if RTT < 4 microseconds.
- */
-static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
-						ktime_t now)
-{
-	u32 quarter_rtts;
-
-	if (unlikely(hctx->ccid3hctx_rtt < 4))	/* avoid divide-by-zero */
-		return;
-
-	quarter_rtts = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
-	quarter_rtts /= hctx->ccid3hctx_rtt / 4;
-
-	if (quarter_rtts > 0) {
-		hctx->ccid3hctx_t_last_win_count = now;
-		hctx->ccid3hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
-		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
-	}
-}
-
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -358,7 +336,7 @@ static int ccid3_hc_tx_send_packet(struc
 		if (delay - (s64)hctx->ccid3hctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
-		ccid3_hc_tx_update_win_count(hctx, now);
+		tfrc_hc_tx_update_win_count(hctx, now);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -218,28 +218,6 @@ static inline void ccid4_hc_tx_update_s(
 		ccid4_update_send_interval(hctx);
 }
 
-/*
- *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
- *	The algorithm is not applicable if RTT < 4 microseconds.
- */
-static inline void ccid4_hc_tx_update_win_count(struct ccid4_hc_tx_sock *hctx,
-						ktime_t now)
-{
-	u32 quarter_rtts;
-
-	if (unlikely(hctx->ccid4hctx_rtt < 4))	/* avoid divide-by-zero */
-		return;
-
-	quarter_rtts = ktime_us_delta(now, hctx->ccid4hctx_t_last_win_count);
-	quarter_rtts /= hctx->ccid4hctx_rtt / 4;
-
-	if (quarter_rtts > 0) {
-		hctx->ccid4hctx_t_last_win_count = now;
-		hctx->ccid4hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
-		hctx->ccid4hctx_last_win_count	&= 0xF;		/* mod 16 */
-	}
-}
-
 static void ccid4_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -384,7 +362,7 @@ static int ccid4_hc_tx_send_packet(struc
 		if (delay - (s64)hctx->ccid4hctx_delta >= 1000)
 			return (u32)delay / 1000L;
 
-		ccid4_hc_tx_update_win_count(hctx, now);
+		tfrc_hc_tx_update_win_count(hctx, now);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
@@ -42,3 +42,27 @@ u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_t
 
 EXPORT_SYMBOL_GPL(tfrc_hc_tx_idle_rtt);
 
+/*
+ *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
+ *	The algorithm is not applicable if RTT < 4 microseconds.
+ */
+inline void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
+				          ktime_t now)
+{
+	u32 quarter_rtts;
+
+	if (unlikely(hctx->tfrchctx_rtt < 4))	/* avoid divide-by-zero */
+		return;
+
+	quarter_rtts = ktime_us_delta(now, hctx->tfrchctx_t_last_win_count);
+	quarter_rtts /= hctx->tfrchctx_rtt / 4;
+
+	if (quarter_rtts > 0) {
+		hctx->tfrchctx_t_last_win_count = now;
+		hctx->tfrchctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
+		hctx->tfrchctx_last_win_count	&= 0xF;		/* mod 16 */
+	}
+}
+
+EXPORT_SYMBOL_GPL(tfrc_hc_tx_update_win_count);
+
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -175,3 +175,7 @@ static const char *tfrc_tx_state_name(en
 extern u64 rfc3390_initial_rate(struct sock *sk);
 
 extern u32 tfrc_hc_tx_idle_rtt(struct tfrc_hc_tx_sock *hctx, ktime_t now);
+
+extern void tfrc_hc_tx_update_win_count(struct tfrc_hc_tx_sock *hctx,
+				          ktime_t now);
+
