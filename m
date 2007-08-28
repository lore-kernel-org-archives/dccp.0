From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Tue, 28 Aug 2007 23:34:44 +0000
Subject: [PATCH 3/6] DCCP: Introduce CCID3 extensions
Message-Id: <200708291134.45030.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In this patch we introduce the extension TFRC faster restart.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 5a23b62..6de73f7 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -116,6 +116,7 @@ struct ccid3_hc_tx_sock {
 	u32				ccid3hctx_delta;
 	struct tfrc_tx_hist_head	ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
+	u8				ccid3hctx_extensions;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
@@ -153,6 +154,7 @@ enum ccid3_fback_type {
  *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
+ *  @ccid3hcrx_extensions - what extensions to CCID3 are used
  */
 struct ccid3_hc_rx_sock {
 	u8				ccid3hcrx_last_counter:4;
@@ -165,6 +167,7 @@ struct ccid3_hc_rx_sock {
 	struct tfrc_loss_hist		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
 #define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
+	u8				ccid3hcrx_extensions;
 };
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index 6241e4a..0c25487 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -61,4 +61,6 @@ static inline u32 tfrc_ewma(const u32 avg, const u32 newval, 
const u8 weight)
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
 extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
 
+#define TFRC_EXT_FASTER_RESTART		1
+
 #endif /* _TFRC_H_ */
