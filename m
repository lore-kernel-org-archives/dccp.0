From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 02 Oct 2007 10:25:05 +0000
Subject: [Announce]: Test tree updated to match coding conventions
Message-Id: <200710021125.05932@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Following Arnaldos suggestion and after re-reading Documentation/CodingStyle
I went through all the test tree patches, with the following changes (diff at end of message):
 
  * handling of `?' operator
  * when one if/else statement is in braces, the other branches also should use braces
  * added references to which draft version (rev00) of rfc3448bis is used, as promised earlier

Ian, I think you will be pleased to see that one ugly use of `?' in ccid3.c has gone, and I have
now reverted to the statement you originally suggested. 
I also updated your Faster-Restart patches in the repository to match the changes below, so that
the patches now apply again.


--- b/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -136,7 +136,7 @@
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	__u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
 	const  __u64 old_x = hctx->ccid3hctx_x;
-	ktime_t now = stamp? *stamp : ktime_get_real();
+	ktime_t now = stamp ? *stamp : ktime_get_real();
 
 	/*
 	 * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
@@ -236,7 +236,7 @@
 		goto out;
 
 	/*
-	 * Determine new allowed sending rate X as per draft rfc3448bis, 4.4
+	 * Determine new allowed sending rate X as per draft rfc3448bis-00, 4.4
 	 */
 	if (hctx->ccid3hctx_t_rto = 0 ||	/* no feedback received yet */
 	    hctx->ccid3hctx_p = 0       ) {
@@ -421,9 +421,12 @@
 	hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
 	hctx->ccid3hctx_x_recv <<= 6;
 
-	/* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
+	/* Update loss event rate (which is scaled by 1e6) */
 	pinv = opt_recv->ccid3or_loss_event_rate;
-	hctx->ccid3hctx_p = (pinv = ~0U || pinv = 0)? 0 : scaled_div(1, pinv);
+	if (pinv = ~0U || pinv = 0)	       /* see RFC 4342, 8.5   */
+		hctx->ccid3hctx_p = 0;
+	else				       /* can not exceed 100% */
+		hctx->ccid3hctx_p = scaled_div(1, pinv);
 
 	/*
 	 * Calculate new RTT sample and update moving average
@@ -433,7 +436,7 @@
 	hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
 	/*
-	 *	Update allowed sending rate X as per draft rfc3448bis, 4.2/4.3
+	 *	Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
 	 */
 	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
 
@@ -777,7 +780,7 @@
 	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
-	return p = 0? ~0U : scaled_div(1, p);
+	return p = 0 ? ~0U : scaled_div(1, p);
 }
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -913,7 +916,7 @@
 		val = &rx_info;
 		rx_info.tfrcrx_x_recv	= hcrx->ccid3hcrx_x_recv;
 		rx_info.tfrcrx_rtt	= hcrx->ccid3hcrx_rtt;
-		rx_info.tfrcrx_p	= hcrx->ccid3hcrx_pinv = 0? ~0U
+		rx_info.tfrcrx_p	= hcrx->ccid3hcrx_pinv = 0 ? ~0U
 					: scaled_div(1, hcrx->ccid3hcrx_pinv);
 		break;
 	default:
--- b/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -195,8 +195,9 @@
 			} else if (len = 4) {
 				opt_val = get_unaligned((u32 *)value);
 				elapsed_time = ntohl(opt_val);
-			} else
+			} else {
 				goto out_invalid_option;
+			}
 
 			if (elapsed_time > opt_recv->dccpor_elapsed_time)
 				opt_recv->dccpor_elapsed_time = elapsed_time;
--- b/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -101,7 +101,7 @@
 	[DCCP_RESET_CODE_MANDATORY_ERROR]    = EOPNOTSUPP,
 	};
 
-	return code <= DCCP_RESET_CODE_AGGRESSION_PENALTY? error_code[code] : 0;
+	return code > DCCP_RESET_CODE_AGGRESSION_PENALTY ? 0 : error_code[code];
 }
 
 static void dccp_rcv_reset(struct sock *sk, struct sk_buff *skb)
--- b/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -172,7 +172,7 @@
 					 sizeof(struct tfrc_loss_interval),
 					 0, SLAB_HWCACHE_ALIGN, NULL);
 
-	return tfrc_lh_slab = NULL? -ENOBUFS : 0;
+	return tfrc_lh_slab = NULL ? -ENOBUFS : 0;
 }
 
 void __exit li_cleanup(void)
--- b/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -55,7 +55,7 @@
  */
 static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
 {
-	return avg? (weight * avg + (10 - weight) * newval) / 10 : newval;
+	return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
 }
 
 extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
--- b/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -345,11 +345,11 @@
 {
 	int is_new_loss = 0;
 
-	if (h->loss_count = 1)
+	if (h->loss_count = 1) {
 		__one_after_loss(h, skb, ndp);
-	else if (h->loss_count != 2)
+	} else if (h->loss_count != 2) {
 		DCCP_BUG("invalid loss_count %d", h->loss_count);
-	else if (__two_after_loss(h, skb, ndp)) {
+	} else if (__two_after_loss(h, skb, ndp)) {
 		/*
 		 * Update Loss Interval database and recycle RX records
 		 */
@@ -386,7 +386,7 @@
 				 * it, but the cause does not seem to be here.
 				 */
 				DCCP_BUG("please report to dccp@vger.kernel.org"
-					 " - prev = %u, last =  %u",
+					 " => prev = %u, last = %u",
 					 rtt_prev_s(h)->ccval,
 					 rtt_last_s(h)->ccval);
 		} else if (delta_v < 1) {
@@ -421,7 +421,7 @@
 				   sizeof(struct tfrc_rx_hist_entry),
 				   0, SLAB_HWCACHE_ALIGN, NULL);
 
-	return tfrcxh = NULL? -ENOBUFS : 0;
+	return tfrcxh = NULL ? -ENOBUFS : 0;
 }
 
 void __exit packet_history_cleanup(void)
--- b/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -171,7 +171,7 @@
 static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, u32 val)
 {
 	/* XXX do we need to change ack ratio? */
-	hctx->ccid2hctx_cwnd = val? : 1;
+	hctx->ccid2hctx_cwnd = val ? : 1;
 	ccid2_pr_debug("changed cwnd to %u\n", hctx->ccid2hctx_cwnd);
 }
 
