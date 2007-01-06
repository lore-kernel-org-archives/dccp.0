From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 06 Jan 2007 22:59:37 +0000
Subject: [PATCH 1/1] DCCP: Fix up t_nom
Message-Id: <200701071159.38430.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

We are calculating t_nom in the past we have made it far too complicated
and not matching the RFC.

As part of this the code becomes much simpler (always good) and we save
some memory as we don't need to store t_ipi. This fixes the fallout from
removing that - e.g. timers which shouldn't be using t_ipi anyway!

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/include/linux/tfrc.h b/include/linux/tfrc.h
index 8a8462b..1741417 100644
--- a/include/linux/tfrc.h
+++ b/include/linux/tfrc.h
@@ -36,7 +36,6 @@ struct tfrc_rx_info {
  * 	@tfrctx_rtt:	(moving average) estimate of RTT (4.3)
  * 	@tfrctx_p:	current loss event rate (5.4)
  * 	@tfrctx_rto:	estimate of RTO, equals 4*RTT (4.3)
- * 	@tfrctx_ipi:	inter-packet interval (4.6)
  *
  *  Note: X and X_recv are both maintained in units of 64 * bytes/second. This
  *        enables a finer resolution of sending rates and avoids problems with
@@ -49,7 +48,6 @@ struct tfrc_tx_info {
 	__u32 tfrctx_rtt;
 	__u32 tfrctx_p;
 	__u32 tfrctx_rto;
-	__u32 tfrctx_ipi;
 };
 
 #endif /* _LINUX_TFRC_H_ */
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 1ebb4da..a5034b5 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -81,26 +81,24 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
 }
 
 /*
- * Recalculate scheduled nominal send time t_nom, inter-packet interval
- * t_ipi, and delta value. Should be called after each change to X.
+ * Recalculate scheduled nominal send time t_nom and delta value. Should be
+ * called after each packet sent.
  */
-static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
+static void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
 {
-	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+	u32 t_ipi;
 
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
-					   hctx->ccid3hctx_x >> 6);
+	t_ipi = scaled_div(hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
 
 	/* Update nominal send time with regard to the new t_ipi */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+	timeval_add_usecs(&hctx->ccid3hctx_t_nom, t_ipi);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
-					   TFRC_OPSYS_HALF_TIME_GRAN);
+	hctx->ccid3hctx_delta = min_t(u32, t_ipi/2, TFRC_OPSYS_HALF_TIME_GRAN);
 
 	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%llu\n",
-		       hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
+		       t_ipi, hctx->ccid3hctx_delta,
 		       hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
 
 }
@@ -117,9 +115,6 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
  * Note: X and X_recv are both stored in units of 64 * bytes/second, to support
  *       fine-grained resolution of sending rates. This requires scaling by 2^6
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
- *
- * If X has changed, we also update the scheduled send time t_now,
- * the inter-packet interval t_ipi, and the delta value.
  */
 static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 
@@ -145,13 +140,10 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
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
@@ -227,7 +219,6 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
 		t_nfb = TFRC_INITIAL_TIMEOUT;
-		ccid3_update_send_time(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
 		/*
@@ -275,11 +266,10 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 			ccid3_hc_tx_update_x(sk, &now);
 		}
 		/*
-		 * Schedule no feedback timer to expire in
-		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
+		 * Schedule no feedback timer to expire in t_RTO
 		 * See comments in packet_recv() regarding the value of t_RTO.
 		 */
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = hctx->ccid3hctx_t_rto;
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		DCCP_BUG("%s(%p) - Illegal state NO_SENT", dccp_role(sk), sk);
@@ -337,13 +327,13 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		hctx->ccid3hctx_x = hctx->ccid3hctx_s;
 		hctx->ccid3hctx_x <<= 6;
 
-		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
-		hctx->ccid3hctx_t_ipi = USEC_PER_SEC;
 		/* Initial delta: minimum of 0.5 sec and t_gran/2 */
 		hctx->ccid3hctx_delta = TFRC_OPSYS_HALF_TIME_GRAN;
 
 		/* Set t_0 for initial packet */
+		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
 		hctx->ccid3hctx_t_nom = now;
+		timeval_add_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
@@ -361,6 +351,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			return delay / 1000L;
 
 		ccid3_hc_tx_update_win_count(hctx, &now);
+		ccid3_update_send_time(hctx);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
@@ -371,9 +362,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	dp->dccps_hc_tx_insert_options = 1;
 	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
 
-	/* set the nominal send time for the next following packet */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
 	return 0;
 }
 
@@ -486,6 +474,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
 			hctx->ccid3hctx_t_ld = now;
 
+			timeval_sub_usecs(&hctx->ccid3hctx_t_nom, USEC_PER_SEC);
 			ccid3_update_send_time(hctx);
 
 			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
@@ -539,11 +528,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		hctx->ccid3hctx_t_rto = max_t(u32, 4 * hctx->ccid3hctx_rtt,
 						   CONFIG_IP_DCCP_CCID3_RTO *
 						   (USEC_PER_SEC/1000));
-		/*
-		 * Schedule no feedback timer to expire in
-		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
-		 */
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+		t_nfb = hctx->ccid3hctx_t_rto;
 
 		ccid3_pr_debug("%s(%p), Scheduled no feedback timer to "
 			       "expire in %lu jiffies (%luus)\n",
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 885d835..5b855f3 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -92,7 +92,6 @@ enum ccid3_hc_tx_states {
  * @ccid3hctx_p - Current loss event rate (0-1) scaled by 1000000
  * @ccid3hctx_s - Packet size in bytes
  * @ccid3hctx_t_rto - Nofeedback Timer setting in usecs
- * @ccid3hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
  * @ccid3hctx_state - Sender state, one of %ccid3_hc_tx_states
  * @ccid3hctx_last_win_count - Last window counter sent
  * @ccid3hctx_t_last_win_count - Timestamp of earliest packet
@@ -113,7 +112,6 @@ struct ccid3_hc_tx_sock {
 #define ccid3hctx_rtt			ccid3hctx_tfrc.tfrctx_rtt
 #define ccid3hctx_p			ccid3hctx_tfrc.tfrctx_p
 #define ccid3hctx_t_rto			ccid3hctx_tfrc.tfrctx_rto
-#define ccid3hctx_t_ipi			ccid3hctx_tfrc.tfrctx_ipi
 	u16				ccid3hctx_s;
 	enum ccid3_hc_tx_states		ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
diff --git a/net/dccp/probe.c b/net/dccp/probe.c
index f81e37d..9966f03 100644
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -90,11 +90,11 @@ static int jdccp_sendmsg(struct kiocb *iocb, struct sock *sk,
 	if (port = 0 || ntohs(inet->dport) = port ||
 	    ntohs(inet->sport) = port) {
 		if (hctx)
-			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d %d\n",
+			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d %d %d %d\n",
 			   NIPQUAD(inet->saddr), ntohs(inet->sport),
 			   NIPQUAD(inet->daddr), ntohs(inet->dport), size,
 			   hctx->ccid3hctx_s, hctx->ccid3hctx_rtt,
-			   hctx->ccid3hctx_p, hctx->ccid3hctx_t_ipi);
+			   hctx->ccid3hctx_p);
 		else
 			printl("%d.%d.%d.%d:%u %d.%d.%d.%d:%u %d\n",
 			   NIPQUAD(inet->saddr), ntohs(inet->sport),
