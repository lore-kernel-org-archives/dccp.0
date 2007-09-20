From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 20 Sep 2007 11:27:17 +0000
Subject: [PATCH 4/5] CCID 4: Reduce allowed sending rate by a factor that
Message-Id: <20070920112717.GC26233@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Tommi Saviranta <wnd@iki.fi>

---
diff -Nrup a/net/dccp/ccids/ccid4.c b/net/dccp/ccids/ccid4.c
--- a/net/dccp/ccids/ccid4.c	2007-09-20 13:32:42.000000000 +0300
+++ b/net/dccp/ccids/ccid4.c	2007-09-20 14:02:59.000000000 +0300
@@ -44,6 +44,12 @@ static int ccid4_debug;
 #define ccid4_pr_debug(format, a...)
 #endif
 
+/*
+ * The header size on data packets is estimated as 36 bytes [RFC XXXX,
+ * Section 5] (floyd-01)
+ */
+#define CCID4HCTX_H    36
+
 DECLARE_TFRC_TX_CACHE(ccid4_tx_hist);
 
 /*
@@ -121,6 +127,17 @@ static u32 ccid4_hc_tx_idle_rtt(struct c
 }
 
 /**
+ * ccid4_hc_tx_x_header_penalty  -  Update allower sending rate X
+ * @hctx: half-connection to adjust
+ * This function adjusts sending rate according to [TFRC-SP, Section 5]
+ */
+static inline void ccid4_hc_tx_x_header_penalty(struct ccid4_hc_tx_sock *hctx)
+{
+	hctx->ccid4hctx_x *= hctx->ccid4hctx_s;
+	do_div(hctx->ccid4hctx_x, (hctx->ccid4hctx_s + CCID4HCTX_H));
+}
+
+/**
  * ccid4_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
  * This function tracks draft rfc3448bis, check there for latest details.
@@ -156,6 +173,7 @@ static void ccid4_hc_tx_update_x(struct 
 		hctx->ccid4hctx_x = max(hctx->ccid4hctx_x,
 					(((__u64)hctx->ccid4hctx_s) << 6) /
 								TFRC_T_MBI);
+		ccid4_hc_tx_x_header_penalty(hctx);
 
 	} else if (ktime_us_delta(now, hctx->ccid4hctx_t_ld)
 				- (s64)hctx->ccid4hctx_rtt >= 0) {
@@ -164,6 +182,7 @@ static void ccid4_hc_tx_update_x(struct 
 			max(min(2 * hctx->ccid4hctx_x, min_rate),
 			    scaled_div(((__u64)hctx->ccid4hctx_s) << 6,
 				       hctx->ccid4hctx_rtt));
+		ccid4_hc_tx_x_header_penalty(hctx);
 		hctx->ccid4hctx_t_ld = now;
 	}
