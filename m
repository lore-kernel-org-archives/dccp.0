From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Wed, 20 Dec 2006 02:48:12 +0000
Subject: [PATCH 4/5]: DCCP Fix t_nom
Message-Id: <200612201548.12544.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When we recalculate t_nom and t_ipi we should check that t_nom is not
before the current time. If it is then we should set t_nom to current time.

Found this by observing flood of packets when t_ipi decreases.

Also uninline the function as it is big and gcc should decide when to
inline anyway.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 0aae302..1ae4f52 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -78,9 +78,14 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
  * Recalculate scheduled nominal send time t_nom, inter-packet interval
  * t_ipi, and delta value. Should be called after each change to X.
  */
-static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
+static void ccid3_update_send_time(struct sock *sk)
 {
+	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct timeval now;
+	suseconds_t delay;
+
 	ccid3_pr_debug("t_ipi was %u\n", hctx->ccid3hctx_t_ipi);
+	dccp_timestamp(sk, &now);
 
 	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
 
@@ -94,11 +99,18 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
 					   TFRC_OPSYS_HALF_TIME_GRAN);
+					   
+	/* we want to check if before current time so we don't send a flood
+	 * of packets */
+	delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+	if (delay < 0) {
+		hctx->ccid3hctx_t_nom = now;
+		ccid3_pr_debug("reset t_nom\n");
+	}
 
 	ccid3_pr_debug("t_ipi now %u, delta=%u, s=%u, x=%llu\n",
 	   hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta, hctx->ccid3hctx_s,
 	   hctx->ccid3hctx_x >> 6);
-
 }
 /*
  * Update X by
@@ -147,7 +159,7 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 		ccid3_pr_debug("x now %llu, x_calc is %u, x_recv is %llu\n",
 		   hctx->ccid3hctx_x, hctx->ccid3hctx_x_calc,
 		   hctx->ccid3hctx_x_recv);
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_time(sk);
 	}
 }
 
@@ -224,7 +236,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_time(sk);
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
@@ -483,7 +495,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
-			ccid3_update_send_time(hctx);
+			ccid3_update_send_time(sk);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
