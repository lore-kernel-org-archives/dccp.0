From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 28 Dec 2006 04:08:38 +0000
Subject: [PATCH 4/4] DCCP: Recalculate t_nom on change of t_ipi
Message-Id: <200612281708.38935.ian.mcdonald@jandi.co.nz>
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

Modified this from last iteration by only recalculate if t_ipi drops to
save expensive operations on time.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index e93bae5..ea22d08 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -84,8 +84,12 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
  * Recalculate scheduled nominal send time t_nom, inter-packet interval
  * t_ipi, and delta value. Should be called after each change to X.
  */
-static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
+static void ccid3_update_send_time(struct sock *sk)
 {
+	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	suseconds_t delay;
+	u32 old_t_ipi = hctx->ccid3hctx_t_ipi;
+
 	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
 
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
@@ -103,6 +107,18 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 	               hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
 		       hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
 
+	if (old_t_ipi > hctx->ccid3hctx_t_ipi) {
+		struct timeval now;
+		dccp_timestamp(sk, &now);
+
+		/* we want to check if before current time so we don't send a
+		 * flood of packets */
+		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		if (delay < 0) {
+			hctx->ccid3hctx_t_nom = now;
+			ccid3_pr_debug("reset t_nom\n");
+		}
+	}
 }
 /*
  * Update X by
@@ -149,7 +165,7 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
 		               "X_recv=%llu\n", old_x, hctx->ccid3hctx_x,
 			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv);
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_time(sk);
 	}
 }
 
@@ -226,7 +242,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
-		ccid3_update_send_time(hctx);
+		ccid3_update_send_time(sk);
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
@@ -485,7 +501,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
-			ccid3_update_send_time(hctx);
+			ccid3_update_send_time(sk);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
 				       "R_sample=%dus, X=%u\n", dccp_role(sk),
