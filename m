From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:30:18 +0000
Subject: [PATCH 6/25] Reduce allowed sending rate by a factor that accounts for packet header size
Message-Id: <200710312130.18806.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] Reduce allowed sending rate by a factor that accounts for packet header size

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
Signed-off-by: Tommi Saviranta <wnd@iki.fi>

Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -135,6 +135,17 @@ static u32 ccid4_hc_tx_idle_rtt(struct c
 }
 
 /**
+ * ccid4_hc_tx_x_header_penalty  -  Update allower sending rate X
+ * @hctx: half-connection to adjust
+ * This function adjusts sending rate according to [TFRC-SP, Section 5]
+ */
+static inline void ccid4_hc_tx_x_header_penalty(struct ccid4_hc_tx_sock *hctx)
+{
+        hctx->ccid4hctx_x *= hctx->ccid4hctx_s;
+        do_div(hctx->ccid4hctx_x, (hctx->ccid4hctx_s + CCID4HCTX_H));
+}
+
+/**
  * ccid4_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
  * This function tracks draft rfc3448bis, check there for latest details.
@@ -170,6 +181,7 @@ static void ccid4_hc_tx_update_x(struct 
 		hctx->ccid4hctx_x = max(hctx->ccid4hctx_x,
 					(((__u64)hctx->ccid4hctx_s) << 6) /
 								TFRC_T_MBI);
+                ccid4_hc_tx_x_header_penalty(hctx);
 
 	} else if (ktime_us_delta(now, hctx->ccid4hctx_t_ld)
 				- (s64)hctx->ccid4hctx_rtt >= 0) {
@@ -178,6 +190,8 @@ static void ccid4_hc_tx_update_x(struct 
 			max(min(2 * hctx->ccid4hctx_x, min_rate),
 			    scaled_div(((__u64)hctx->ccid4hctx_s) << 6,
 				       hctx->ccid4hctx_rtt));
+
+                ccid4_hc_tx_x_header_penalty(hctx);
 		hctx->ccid4hctx_t_ld = now;
 	}
 
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -71,6 +71,11 @@
 /* Mininum sending rate as per CCID-4 draft */
 #define MIN_SEND_RATE              10000
 
+/* The header size on data packets is estimated as 36 bytes as per CCID-4
+ * draft, [Section 5].
+ */
+#define CCID4HCTX_H    36
+
 enum ccid4_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
