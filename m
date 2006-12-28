From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 04:06:25 +0000
Subject: [PATCH 2/4] DCCP: Add more debugging
Message-Id: <200612281706.25874.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This adds some more debugging. Altered to take into account Gerrit's
comments.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 4401ab4..f1f9ebb 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -98,6 +98,11 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
+
+	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, x=%llu\n",
+	               hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
+		       hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
+
 }
 /*
  * Update X by
@@ -140,8 +145,12 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x)
+	if (hctx->ccid3hctx_x != old_x) {
+		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
+		               "X_recv=%llu\n", old_x, hctx->ccid3hctx_x,
+			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv);
 		ccid3_update_send_time(hctx);
+	}
 }
 
 /*
@@ -338,6 +347,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
 		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
 		 *
