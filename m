From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 06 Sep 2007 03:08:07 +0000
Subject: [PATCH 6/6] DCCP: Implement faster restart
Message-Id: <200709061508.07985.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
References: <200708291138.39630.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291138.39630.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements TFRC faster restart as per:
draft-ietf-dccp-tfrc-faster-restart-03.txt

and with changes from:
http://www3.ietf.org/proceedings/07jul/slides/dccp-6.pdf

Most notably we don't do pings.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index ea9e1f9..9b31a20 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -121,6 +121,29 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
 }
 
 /**
+ * ccid3_hc_tx_fr_loss - indicate if loss for faster restart
+ *
+ * According to draft-ietf-dccp-tfrc-faster-restart-03.txt section 3.2
+ * we can say there is a loss if loss rate has increased in last two
+ * feedback packets
+ *
+ */
+
+static bool ccid3_hc_tx_fr_loss(const struct ccid3_hc_tx_sock *hctx)
+{
+	if (hctx->ccid3hctx_p_prev1 > hctx->ccid3hctx_p_prev2)
+		return true;
+
+	if (hctx->ccid3hctx_p > hctx->ccid3hctx_p_prev2)
+		return true;
+
+	if (hctx->ccid3hctx_p > hctx->ccid3hctx_p_prev1)
+		return true;
+
+	return false;
+}
+
+/**
  * ccid3_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
  * This function tracks draft rfc3448bis, check there for latest details.
@@ -130,13 +153,13 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
  *
  */
-static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
-
+static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp, bool nofeedback)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
 	ktime_t now = stamp? *stamp : ktime_get_real();
+	u64 x_fast_max;
 
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
@@ -149,14 +172,37 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
 	}
 
-	if (hctx->ccid3hctx_p > 0) {
+	if (ccid3_hc_tx_faster_restart_on(hctx) && !nofeedback)
+		if (hctx->ccid3hctx_p > 0) {
+			x_fast_max = hctx->ccid3hctx_x_active_recv;
+			/* FIXME We should interpolate here but this is under
+			 * discussion as looking to reduce thresholds from
+			 * 10/30 minutes to 1/3 minutes IAM */
+			if (!ccid3_hc_tx_fr_loss(hctx) &&
+			  (hctx->ccid3hctx_x_recv > x_fast_max)) {
+				x_fast_max = hctx->ccid3hctx_x_recv;
+				hctx->ccid3hctx_x_active_recv = x_fast_max;
+				hctx->ccid3hctx_t_active_recv = now;
+			} else if (ccid3_hc_tx_fr_loss(hctx) &&
+			  (hctx->ccid3hctx_x_recv < x_fast_max)) {
+				x_fast_max = hctx->ccid3hctx_x_recv / 2;
+				hctx->ccid3hctx_x_active_recv = x_fast_max;
+				hctx->ccid3hctx_t_active_recv = now;
+			}
+			if (min_rate < x_fast_max)
+				min_rate = min(2*min_rate, x_fast_max);
+			/* We double again for faster rate */
+			/* FIXME - draft refers to X_recv_set but base
+			 * implementation doesn't use this so we stay
+			 * consistent with this IAM */
+		}
 
+	if (hctx->ccid3hctx_p > 0) {
 		hctx->ccid3hctx_x = min(((__u64)hctx->ccid3hctx_x_calc) << 6,
 					min_rate);
 		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								TFRC_T_MBI);
-
 	} else if (ktime_us_delta(now, hctx->ccid3hctx_t_ld)
 				- (s64)hctx->ccid3hctx_rtt >= 0) {
 
@@ -220,6 +266,9 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
+	/* FIXME Section 4.2 of Faster restart should really
+	 * be implemented in here IAM */
+
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
 		/* Try again later. */
@@ -268,7 +317,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
 			hctx->ccid3hctx_x_recv <<= 4;
 		}
-		ccid3_hc_tx_update_x(sk, NULL);
+		ccid3_hc_tx_update_x(sk, NULL, true);
 	}
 	ccid3_pr_debug("Reduced X to %llu/64 bytes/sec\n",
 			(unsigned long long)hctx->ccid3hctx_x);
@@ -324,6 +373,13 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 
 		hctx->ccid3hctx_s = skb->len;
 
+		hctx->ccid3hctx_p_prev2 = 0;
+		hctx->ccid3hctx_p_prev1 = 0;
+		hctx->ccid3hctx_p = 0;
+		hctx->ccid3hctx_t_active_recv = now;
+		hctx->ccid3hctx_x_active_recv = 0;
+		/* we initialise above for faster restart */
+
 		/*
 		 * Use initial RTT sample when available: recommended by erratum
 		 * to RFC 4342. This implements the initialisation procedure of
@@ -423,6 +479,8 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
 	pinv = opt_recv->ccid3or_loss_event_rate;
+	hctx->ccid3hctx_p_prev2 = hctx->ccid3hctx_p_prev1;
+	hctx->ccid3hctx_p_prev1 = hctx->ccid3hctx_p;
 	hctx->ccid3hctx_p = (pinv = ~0U || pinv = 0)? 0 : scaled_div(1, pinv);
 
 	/*
@@ -462,7 +520,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
 						     hctx->ccid3hctx_rtt,
 						     hctx->ccid3hctx_p);
-	ccid3_hc_tx_update_x(sk, &now);
+	ccid3_hc_tx_update_x(sk, &now, false);
 
 done_computing_x:
 	ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, p=%u, X_calc=%u, "
