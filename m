From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:30:12 +0000
Subject: [PATCH 5/25] Enforces a minimum interval of 10 milliseconds as per CCID-4 draft
Message-Id: <200710312130.12981.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-4] Enforces a minimum interval of 10 milliseconds as per CCID-4 draft

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>
Signed-off-by: Tommi Saviranta <wnd@iki.fi>

Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -111,9 +111,11 @@ static inline u64 rfc3390_initial_rate(s
  */
 static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
 {
-	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
-					     hctx->ccid4hctx_x);
+        /* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second).
+         * TFRC-SP enforces a minimum interval of 10 milliseconds. */
+        hctx->ccid4hctx_t_ipi +              max_t(u32, scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
+                                      hctx->ccid4hctx_x), MIN_SEND_RATE);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid4hctx_delta = min_t(u32, hctx->ccid4hctx_t_ipi / 2,
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -68,6 +68,9 @@
 /* The nominal packet size to be used into TFRC equation as per CCID-4 draft*/
 #define NOM_PACKET_SIZE            1460
 
+/* Mininum sending rate as per CCID-4 draft */
+#define MIN_SEND_RATE              10000
+
 enum ccid4_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
