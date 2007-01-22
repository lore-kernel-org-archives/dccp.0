From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 22 Jan 2007 04:12:26 +0000
Subject: [PATCH 3/3] DCCP: Fix up t_nom handling
Message-Id: <200701221712.26715.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Calculate t_nom as per RFC3448 section 4.6. We have been making it too
complicated previously.

We calculate inital t_ipi as rtt calculated during sessions setup.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 1ebb4da..80caf6a 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -82,12 +82,10 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
 
 /*
  * Recalculate scheduled nominal send time t_nom, inter-packet interval
- * t_ipi, and delta value. Should be called after each change to X.
+ * t_ipi, and delta value. Should be called after each packet sent.
  */
-static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
+static void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 {
-	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
 	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
 					   hctx->ccid3hctx_x >> 6);
@@ -118,8 +116,6 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
  *       fine-grained resolution of sending rates. This requires scaling by 2^6
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
  *
- * If X has changed, we also update the scheduled send time t_now,
- * the inter-packet interval t_ipi, and the delta value.
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
@@ -145,13 +141,10 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 		hctx->ccid3hctx_t_ld = *now;
 	}
 
-	if (hctx->ccid3hctx_x != old_x) {
+	if (hctx->ccid3hctx_x != old_x)
 		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
 			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
 			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
-
-		ccid3_update_send_time(hctx);
-	}
 }
 
 /*
@@ -337,13 +330,14 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
 		hctx->ccid3hctx_x <<= 6;
 
-		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
-		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
+		hctx->ccid3hctx_t_ipi = hctx->ccid3hctx_rtt;
 		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
 		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
 
 		/* Set t_0 for initial packet */
 		hctx->ccid3hctx_t_nom = now;
+		timeval_add_usecs(&hctx->ccid3hctx_t_nom,
+		   hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
@@ -361,6 +355,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			return delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, &now);
+		ccid3_update_send_time(hctx);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
@@ -371,9 +366,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	dp->dccps_hc_tx_insert_options = 1;
 	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
 
-	/* set the nominal send time for the next following packet */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	return 0;
 }
 
@@ -486,8 +478,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
-			ccid3_update_send_time(hctx);
-
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
 				       sk, hctx->ccid3hctx_s,
