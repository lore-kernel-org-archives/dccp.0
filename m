From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Wed, 20 Dec 2006 02:47:04 +0000
Subject: [PATCH 3/5]: DCCP Add to debugging
Message-Id: <200612201547.04753.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds some more debugging.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a74f905..0aae302 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -80,6 +80,8 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
  */
 static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 {
+	ccid3_pr_debug("t_ipi was %u\n", hctx->ccid3hctx_t_ipi);
+
 	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
 
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
@@ -92,6 +94,11 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
+
+	ccid3_pr_debug("t_ipi now %u, delta=%u, s=%u, x=%llu\n",
+	   hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta, hctx->ccid3hctx_s,
+	   hctx->ccid3hctx_x >> 6);
+
 }
 /*
  * Update X by
@@ -116,6 +123,8 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	const  __u64 old_x = hctx->ccid3hctx_x;
 
+	ccid3_pr_debug("x was %llu\n", hctx->ccid3hctx_x);
+
 	if (hctx->ccid3hctx_p > 0) {
 
 		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
@@ -134,8 +143,12 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x)
+	if (hctx->ccid3hctx_x != old_x) {
+		ccid3_pr_debug("x now %llu, x_calc is %u, x_recv is %llu\n",
+		   hctx->ccid3hctx_x, hctx->ccid3hctx_x_calc,
+		   hctx->ccid3hctx_x_recv);
 		ccid3_update_send_time(hctx);
+	}
 }
 
 /*
@@ -332,6 +345,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
