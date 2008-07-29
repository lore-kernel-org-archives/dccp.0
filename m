From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 14:06:12 +0000
Subject: [PATCH 5/6] dccp ccid-3: Preventing Oscillations
Message-Id: <1217340373-12620-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements (RFC 3448, 4.5), which performs congestion avoidance by reducing
the transmit rate as the queueing delay (measured in terms of long-term RTT
changes) increases.

Oscillation can be turned on/off via a module option (do_osc_prev) and via sysfs
(using mode 0644). The default is off.

Overflow analysis:
------------------
 * oscillation prevention is done after update_x(), so that t_ipi <= 64000;
 * hence the multiplication "t_ipi * sqrt(R_sample)" needs 64 bits;
 * done using u64 for sqrt_sample and explicit typecast of t_ipi;
 * the divisor, R_sqmean, is non-zero because oscillation prevention is first
   called when receiving the second feedback packet, and tfrc_scaled_rtt() > 0.

A detailed discussion of the algorithm (with plots) is on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3/sender_notes/oscillation_prevention/

Under the following conditions the algorithm will have negative side effects:
 * when allowing to decrease t_ipi (leads to a large RTT) and
 * when using it during slow-start.
Both uses are therefore disabled.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c    |   40 ++++++++++++++++++++++++++++++++++++++++
 net/dccp/ccids/ccid3.h    |    6 ++++--
 net/dccp/ccids/lib/tfrc.h |   15 +++++++++++++++
 3 files changed, 59 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -48,6 +48,21 @@ static inline u32 scaled_div32(u64 a, u64 b)
 }
 
 /**
+ * tfrc_scaled_sqrt  -  Compute scaled integer sqrt(x) for 0 < x < 2^22-1
+ * Uses scaling to improve accuracy of the integer approximation of sqrt(). The
+ * scaling factor of 2^10 limits the maximum @sample to 4e6; this is okay for
+ * clamped RTT samples (dccp_sample_rtt).
+ * Should best be used for expressions of type sqrt(x)/sqrt(y), since then the
+ * scaling factor is neutralised. For this purpose, it avoids returning zero.
+ */
+static inline u16 tfrc_scaled_sqrt(const u32 sample)
+{
+	const unsigned long non_zero_sample = sample ? : 1;
+
+	return int_sqrt(non_zero_sample << 10);
+}
+
+/**
  * tfrc_ewma  -  Exponentially weighted moving average
  * @weight: Weight to be used as damping factor, in units of 1/10
  */
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -47,8 +47,8 @@
 /* Two seconds as per RFC 3448 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
-/* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
-#define TFRC_T_MBI		   64
+/* Maximum backoff interval t_mbi (RFC 3448, 4.3) */
+#define TFRC_T_MBI		   (64 * USEC_PER_SEC)
 
 /*
  * The t_delta parameter (RFC 3448, 4.6): delays of less than %USEC_PER_MSEC are
@@ -76,6 +76,7 @@ enum ccid3_options {
  * @x_recv - Receive rate    in 64 * bytes per second
  * @x_calc - Calculated rate in bytes per second
  * @rtt - Estimate of current round trip time in usecs
+ * @r_sqmean - Estimate of long-term RTT (RFC 3448, 4.5)
  * @p - Current loss event rate (0-1) scaled by 1000000
  * @s - Packet size in bytes
  * @t_rto - Nofeedback Timer setting in usecs
@@ -94,6 +95,7 @@ struct ccid3_hc_tx_sock {
 	u64				x_recv;
 	u32				x_calc;
 	u32				rtt;
+	u16				r_sqmean;
 	u32				p;
 	u32				t_rto;
 	u32				t_ipi;
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,6 +49,8 @@ static int ccid3_debug;
 /*
  *	Transmitter Half-Connection Routines
  */
+/* Oscillation Prevention/Reduction: recommended by rfc3448bis, on by default */
+static int do_osc_prev = true;
 
 /*
  * Compute the initial sending rate X_init in the manner of RFC 3390:
@@ -296,6 +298,9 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		hctx->s = ccid3_hc_tx_measure_packet_size(sk, skb->len);
 		ccid3_update_send_interval(hctx);
 
+		/* Seed value for Oscillation Prevention (sec. 4.5) */
+		hctx->r_sqmean = tfrc_scaled_sqrt(hctx->rtt);
+
 	} else {
 		delay = ktime_us_delta(hctx->t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
@@ -400,6 +405,38 @@ done_computing_x:
 			       hctx->s, hctx->p, hctx->x_calc,
 			       (unsigned)(hctx->x_recv >> 6),
 			       (unsigned)(hctx->x >> 6));
+	/*
+	 * Oscillation Reduction (RFC 3448, 4.5) - modifying t_ipi according to
+	 * RTT changes, multiplying by X/X_inst = sqrt(R_sample)/R_sqmean. This
+	 * can be useful if few connections share a link, avoiding that buffer
+	 * fill levels (RTT) oscillate as a result of frequent adjustments to X.
+	 * A useful presentation with background information is in
+	 *    Joerg Widmer, "Equation-Based Congestion Control",
+	 *    MSc Thesis, University of Mannheim, Germany, 2000
+	 * (sec. 3.6.4), who calls this ISM ("Inter-packet Space Modulation").
+	 */
+	if (do_osc_prev) {
+		r_sample = tfrc_scaled_sqrt(r_sample);
+		/*
+		 * The modulation can work in both ways: increase/decrease t_ipi
+		 * according to long-term increases/decreases of the RTT. The
+		 * former is a useful measure, since it works against queue
+		 * build-up. The latter temporarily increases the sending rate,
+		 * so that buffers fill up more quickly. This in turn causes
+		 * the RTT to increase, so that either later reduction becomes
+		 * necessary or the RTT stays at a very high level. Decreasing
+		 * t_ipi is therefore not supported.
+		 * Furthermore, during the initial slow-start phase the RTT
+		 * naturally increases, where using the algorithm would cause
+		 * delays. Hence it is disabled during the initial slow-start.
+		 */
+		if (r_sample > hctx->r_sqmean && hctx->p > 0)
+			hctx->t_ipi = div_u64((u64)hctx->t_ipi * (u64)r_sample,
+					      hctx->r_sqmean);
+		hctx->t_ipi = min_t(u32, hctx->t_ipi, TFRC_T_MBI);
+		/* update R_sqmean _after_ computing the modulation factor */
+		hctx->r_sqmean = tfrc_ewma(hctx->r_sqmean, r_sample, 9);
+	}
 
 	/* unschedule no feedback timer */
 	sk_stop_timer(sk, &hctx->no_feedback_timer);
@@ -749,6 +786,9 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_getsockopt	   = ccid3_hc_tx_getsockopt,
 };
 
+module_param(do_osc_prev, bool, 0644);
+MODULE_PARM_DESC(do_osc_prev, "Use Oscillation Prevention (RFC 3448, 4.5)");
+
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 module_param(ccid3_debug, bool, 0444);
 MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
