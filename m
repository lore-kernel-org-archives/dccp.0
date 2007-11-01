From: Leandro <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 00:31:50 +0000
Subject: [PATCH 16/25] Share ccid3_hc_rx_sock struct and ccid3_hc_rx_sk function via tfrc_ccids
Message-Id: <200710312131.50615.leandroal@gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID-3/4] Share ccid3_hc_rx_sock and ccid3_hc_rx_sk via tfrc_ccids

ccid3_hc_rx_sock is now tfrc_hc_rx_sock
ccid3_hc_rx_sk is now tfrc_hc_rx_sk

Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Index: leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
=================================--- leandro.new.orig/net/dccp/ccids/lib/tfrc_ccids.h
+++ leandro.new/net/dccp/ccids/lib/tfrc_ccids.h
@@ -122,3 +122,35 @@ static inline struct tfrc_hc_tx_sock *tf
     return hctx;
 }
 
+/** struct tfrc_hc_rx_sock - CCID3/4 receiver half-connection socket
+ *
+ *  @tfrchcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
+ *  @tfrchcrx_state  -  Receiver state, one of %tfrc_hc_rx_states
+ *  @tfrchcrx_bytes_recv  -  Total sum of DCCP payload bytes
+ *  @tfrchcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ *  @tfrchcrx_rtt  -  Receiver estimate of RTT
+ *  @tfrchcrx_last_feedback  -  Time at which last feedback was sent
+ *  @tfrchcrx_hist  -  Packet history, exported by TFRC module
+ *  @tfrchcrx_li_hist  -  Loss Interval database, exported by TFRC module
+ *  @tfrchcrx_s  -  Received packet size in bytes
+ *  @tfrchcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ */
+struct tfrc_hc_rx_sock {
+	u8				tfrchcrx_last_counter:4;
+	enum tfrc_hc_rx_states	tfrchcrx_state:8;
+	u32				tfrchcrx_bytes_recv;
+	u32				tfrchcrx_x_recv;
+	u32				tfrchcrx_rtt;
+	ktime_t				tfrchcrx_last_feedback;
+	struct tfrc_rx_hist		tfrchcrx_hist;
+	struct tfrc_loss_hist		tfrchcrx_li_hist;
+	u16				tfrchcrx_s;
+#define tfrchcrx_pinv			tfrchcrx_li_hist.i_mean
+};
+
+static inline struct tfrc_hc_rx_sock *tfrc_hc_rx_sk(const struct sock *sk)
+{
+    struct tfrc_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+    BUG_ON(hcrx = NULL);
+    return hcrx;
+}
Index: leandro.new/net/dccp/ccids/ccid3.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.c
+++ leandro.new/net/dccp/ccids/ccid3.c
@@ -51,7 +51,7 @@ DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
 /*
  *	Transmitter Half-Connection Routines
  */
-#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
+#if defined(CONFIG_IP_DCCP_CCID3_DEBUG) || defined(CONFIG_IP_DCCP_CCID4_DEBUG)
 static const char *ccid3_tx_state_name(enum tfrc_hc_tx_states state)
 {
 	static char *ccid3_state_names[] = {
@@ -90,9 +90,22 @@ static const char *ccid3_tx_state_name(e
 #define ccid3hctx_x_calc tfrchctx_x_calc
 #define ccid3hctx_t_rto tfrchctx_t_rto
 #define ccid3hctx_x_recv tfrchctx_x_recv
-
 #define ccid3_hc_tx_sk tfrc_hc_tx_sk
 
+#define ccid3_hc_rx_sock tfrc_hc_rx_sock
+#define ccid3hcrx_s tfrchcrx_s
+#define ccid3hcrx_x_recv tfrchcrx_x_recv
+#define ccid3hcrx_pinv tfrchcrx_pinv
+#define ccid3hcrx_last_feedback tfrchcrx_last_feedback
+#define ccid3hcrx_bytes_recv tfrchcrx_bytes_recv
+#define ccid3hcrx_last_counter tfrchcrx_last_counter
+#define ccid3hcrx_rtt tfrchcrx_rtt
+#define ccid3hcrx_s tfrchcrx_s
+#define ccid3hcrx_hist tfrchcrx_hist
+#define ccid3hcrx_li_hist tfrchcrx_li_hist
+
+#define ccid3_hc_rx_sk tfrc_hc_rx_sk
+
 static void ccid3_hc_tx_set_state(struct sock *sk,
 				  enum tfrc_hc_tx_states state)
 {
Index: leandro.new/net/dccp/ccids/ccid4.c
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.c
+++ leandro.new/net/dccp/ccids/ccid4.c
@@ -100,9 +100,22 @@ static const char *ccid4_tx_state_name(e
 #define ccid4hctx_x_calc tfrchctx_x_calc
 #define ccid4hctx_t_rto tfrchctx_t_rto
 #define ccid4hctx_x_recv tfrchctx_x_recv
-
 #define ccid4_hc_tx_sk tfrc_hc_tx_sk
 
+#define ccid4_hc_rx_sock tfrc_hc_rx_sock
+#define ccid4hcrx_s tfrchcrx_s
+#define ccid4hcrx_x_recv tfrchcrx_x_recv
+#define ccid4hcrx_pinv tfrchcrx_pinv
+#define ccid4hcrx_last_feedback tfrchcrx_last_feedback
+#define ccid4hcrx_bytes_recv tfrchcrx_bytes_recv
+#define ccid4hcrx_last_counter tfrchcrx_last_counter
+#define ccid4hcrx_rtt tfrchcrx_rtt
+#define ccid4hcrx_s tfrchcrx_s
+#define ccid4hcrx_hist tfrchcrx_hist
+#define ccid4hcrx_li_hist tfrchcrx_li_hist
+
+#define ccid4_hc_rx_sk tfrc_hc_rx_sk
+
 static void ccid4_hc_tx_set_state(struct sock *sk,
 				  enum tfrc_hc_tx_states state)
 {
Index: leandro.new/net/dccp/ccids/ccid4.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid4.h
+++ leandro.new/net/dccp/ccids/ccid4.h
@@ -61,37 +61,4 @@
  */
 #define CCID4HCTX_H    36
 
-/** struct ccid4_hc_rx_sock - CCID4 receiver half-connection socket
- *
- *  @ccid4hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @tfrchcrx_state  -  Receiver state, one of %tfrc_hc_rx_states
- *  @ccid4hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @ccid4hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @ccid4hcrx_rtt  -  Receiver estimate of RTT
- *  @ccid4hcrx_last_feedback  -  Time at which last feedback was sent
- *  @ccid4hcrx_hist  -  Packet history, exported by TFRC module
- *  @ccid4hcrx_li_hist  -  Loss Interval database, exported by TFRC module
- *  @ccid4hcrx_s  -  Received packet size in bytes
- *  @ccid4hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
- */
-struct ccid4_hc_rx_sock {
-	u8				ccid4hcrx_last_counter:4;
-	enum tfrc_hc_rx_states	tfrchcrx_state:8;
-	u32				ccid4hcrx_bytes_recv;
-	u32				ccid4hcrx_x_recv;
-	u32				ccid4hcrx_rtt;
-	ktime_t				ccid4hcrx_last_feedback;
-	struct tfrc_rx_hist		ccid4hcrx_hist;
-	struct tfrc_loss_hist		ccid4hcrx_li_hist;
-	u16				ccid4hcrx_s;
-#define ccid4hcrx_pinv			ccid4hcrx_li_hist.i_mean
-};
-
-static inline struct ccid4_hc_rx_sock *ccid4_hc_rx_sk(const struct sock *sk)
-{
-    struct ccid4_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
-    BUG_ON(hcrx = NULL);
-    return hcrx;
-}
-
 #endif /* _DCCP_CCID4_H_ */
Index: leandro.new/net/dccp/ccids/ccid3.h
=================================--- leandro.new.orig/net/dccp/ccids/ccid3.h
+++ leandro.new/net/dccp/ccids/ccid3.h
@@ -38,37 +38,4 @@
  */
 #include "lib/tfrc_ccids.h"
 
-/** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
- *
- *  @ccid3hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
- *  @tfrchcrx_state  -  Receiver state, one of %tfrc_hc_rx_states
- *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of RTT
- *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
- *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
- *  @ccid3hcrx_s  -  Received packet size in bytes
- *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
- */
-struct ccid3_hc_rx_sock {
-	u8				ccid3hcrx_last_counter:4;
-	enum tfrc_hc_rx_states	        tfrchcrx_state:8;
-	u32				ccid3hcrx_bytes_recv;
-	u32				ccid3hcrx_x_recv;
-	u32				ccid3hcrx_rtt;
-	ktime_t				ccid3hcrx_last_feedback;
-	struct tfrc_rx_hist		ccid3hcrx_hist;
-	struct tfrc_loss_hist		ccid3hcrx_li_hist;
-	u16				ccid3hcrx_s;
-#define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
-};
-
-static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
-{
-    struct ccid3_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
-    BUG_ON(hcrx = NULL);
-    return hcrx;
-}
-
 #endif /* _DCCP_CCID3_H_ */
