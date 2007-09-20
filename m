From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 20 Sep 2007 11:24:43 +0000
Subject: [PATCH 3/5] CCID 4: Enforce a minimum sending rate of 10 ms
Message-Id: <20070920112443.GB26233@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Tommi Saviranta <wnd@iki.fi>

---
diff -Nrup a/net/dccp/ccids/ccid4.c b/net/dccp/ccids/ccid4.c
--- a/net/dccp/ccids/ccid4.c	2007-09-20 13:32:42.000000000 +0300
+++ b/net/dccp/ccids/ccid4.c	2007-09-20 13:50:52.000000000 +0300
@@ -100,8 +100,11 @@ static inline u64 rfc3390_initial_rate(s
 static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
-					     hctx->ccid4hctx_x);
+	/* TFRC-SP enforces a minimum interval of 10 milliseconds */
+	hctx->ccid4hctx_t_ipi +		max_t(u32, scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
+					hctx->ccid4hctx_x),
+		      10000);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid4hctx_delta = min_t(u32, hctx->ccid4hctx_t_ipi / 2,
