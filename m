From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:55 +0000
Subject: [PATCH 18/25] Share rfc3390_initial_rate function via tfrc_ccids
Message-Id: <200710312131.55301.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share rfc3390_initial_rate function via tfrc_ccids

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -103,24 +103,6 @@ static void ccid3_hc_tx_set_state(struct
 }
 
 /*
- * Compute the initial sending rate X_init in the manner of RFC 3390:
- *
- *	X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
- *
- * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
- * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
- * For consistency with other parts of the code, X_init is scaled by 2^6.
- */
-static inline u64 rfc3390_initial_rate(struct sock *sk)
-{
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	const __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
-				   max_t(__u32, 2 * hctx->ccid3hctx_s, 4380));
-
-	return scaled_div(w_init << 6, hctx->ccid3hctx_rtt);
-}
-
-/*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
 static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -113,24 +113,6 @@ static void ccid4_hc_tx_set_state(struct
 }
 
 /*
- * Compute the initial sending rate X_init in the manner of RFC 3390:
- *
- *	X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
- *
- * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
- * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
- * For consistency with other parts of the code, X_init is scaled by 2^6.
- */
-static inline u64 rfc3390_initial_rate(struct sock *sk)
-{
-	const struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
-	const __u32 w_init = min_t(__u32, 4 * hctx->ccid4hctx_s,
-				   max_t(__u32, 2 * hctx->ccid4hctx_s, 4380));
-
-	return scaled_div(w_init << 6, hctx->ccid4hctx_rtt);
-}
-
-/*
  * Recalculate t_ipi and delta (should be called whenever X changes)
  */
 static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.c
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.c
@@ -12,3 +12,23 @@
  *  (at your option) any later version.
  */
 #include "tfrc_ccids.h"
+
+/*
+ * Compute the initial sending rate X_init in the manner of RFC 3390:
+ *
+ *	X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
+ *
+ * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
+ * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
+ * For consistency with other parts of the code, X_init is scaled by 2^6.
+ */
+inline u64 rfc3390_initial_rate(struct sock *sk)
+{
+	const struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
+	const __u32 w_init = min_t(__u32, 4 * hctx->tfrchctx_s,
+				   max_t(__u32, 2 * hctx->tfrchctx_s, 4380));
+
+	return scaled_div(w_init << 6, hctx->tfrchctx_rtt);
+}
+
+EXPORT_SYMBOL_GPL(rfc3390_initial_rate);
Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -172,3 +172,4 @@ static const char *tfrc_tx_state_name(en
 }
 #endif
 
+extern u64 rfc3390_initial_rate(struct sock *sk);
