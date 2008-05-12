From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 May 2008 07:48:03 +0000
Subject: [PATCH 1/2] [RFT] [CCID-3]: Bug fix for the inter-packet scheduling algorithm
Message-Id: <1210578484-12571-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a subtle bug in the calculation of the inter-packet gap and shows
that t_delta, as it is currently used, is not needed. And hence replaced.

The algorithm from RFC 3448, 4.6 below continually computes a send time t_nom,
which is initialised with the current time t_now; t_gran = 1E6 / HZ specifies
the scheduling granularity, s the packet size, and X the sending rate:

  t_distance = t_nom - t_now;		// in microseconds
  t_delta    = min(t_ipi, t_gran) / 2;	// `delta' parameter in microseconds

  if (t_distance >= t_delta) {
	reschedule after (t_distance / 1000) milliseconds;
  } else {
  	t_ipi  = s / X;			// inter-packet interval in usec
	t_nom += t_ipi;			// compute the next send time
	send packet now;
  }


1) Description of the bug
-------------------------
Rescheduling requires a conversion into milliseconds, due to this call chain:

 * ccid3_hc_tx_send_packet() returns a timeout in milliseconds,
 * this value is converted by msecs_to_jiffies() in dccp_write_xmit(),
 * and finally used as jiffy-expires-value for sk_reset_timer().

The highest jiffy resolution with HZ00 is 1 millisecond, so using a higher
granularity does not seem to make much sense here.

As a consequence, values of t_distance < 1000 are truncated to 0. This issue
has so far been resolved by using instead

  if (t_distance >= t_delta + 1000)
	reschedule after (t_distance / 1000) milliseconds;

The bug is in artificially inflating t_delta to t_delta' = t_delta + 1000. This
is unnecessarily large, a more adequate value is t_delta' = max(t_delta, 1000).


2) Consequences of using the corrected t_delta'
-----------------------------------------------
Since t_delta <= t_gran/2 = 10^6/(2*HZ), we have t_delta <= 1000 as long as
HZ >= 500. This means that t_delta' = max(1000, t_delta) is constant at 1000.

On the other hand, when using a coarse HZ value of HZ < 500, we have three
sub-cases that can all be reduced to using another constant of t_gran/2.

 (a) The first case arises when t_ipi > t_gran. Here t_delta' is the constant
     t_delta' = max(1000, t_gran/2) = t_gran/2.

 (b) If t_ipi <= 2000 < t_gran = 10^6/HZ usec, then t_delta = t_ipi/2 <= 1000,
     so that t_delta' = max(1000, t_delta) = 1000 < t_gran/2.

 (c) If 2000 < t_ipi <= t_gran, we have t_delta' = max(t_delta, 1000) = t_ipi/2.

In the second and third cases we have delay values less than t_gran/2, which is
in the order of less than or equal to half a jiffy.

How these are treated depends on how fractions of a jiffy are handled: they
are either always rounded down to 0, or always rounded up to 1 jiffy (assuming
non-zero values). In both cases the error is on average in the order of 50%.

Thus we are not increasing the error when in the second/third case we replace
a value less than t_gran/2 with 0, by setting t_delta' to the constant t_gran/2.


3) Summary
----------
Fixing (1) and considering (2), the patch replaces t_delta with a constant,
whose value depends on CONFIG_HZ, changing the above algorithm to:

  if (t_distance >= t_delta')
	reschedule after (t_distance / 1000) milliseconds;

where t_delta' = 10^6/(2*HZ) if HZ < 500, and t_delta' = 1000 otherwise.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |   19 ++++++++++++++-----
 net/dccp/ccids/ccid3.c |   17 +++++++----------
 2 files changed, 21 insertions(+), 15 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -47,12 +47,23 @@
 /* Two seconds as per RFC 3448 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
-/* In usecs - half the scheduling granularity as per RFC3448 4.6 */
-#define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
-
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_T_MBI		   64
 
+/*
+ * The t_delta parameter (RFC 3448, 4.6): delays of less than %USEC_PER_MSEC are
+ * rounded down to 0, since sk_reset_timer() here uses millisecond granularity.
+ * Hence we can use a constant t_delta = %USEC_PER_MSEC when HZ >= 500. A coarse
+ * resolution of HZ < 500 means that the error is below one timer tick (t_gran)
+ * when using the constant t_delta  =  t_gran / 2  =  %USEC_PER_SEC / (2 * HZ).
+ */
+#if (HZ >= 500)
+# define TFRC_T_DELTA		   USEC_PER_MSEC
+#else
+# define TFRC_T_DELTA		   USEC_PER_SEC / (2 * HZ)
+# warning Coarse CONFIG_HZ resolution -- higher value recommended for CCID-3.
+#endif
+
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
@@ -83,7 +94,6 @@ enum ccid3_hc_tx_states {
  * @no_feedback_timer - Handle to no feedback timer
  * @t_ld - Time last doubled during slow start
  * @t_nom - Nominal send time of next packet
- * @delta - Send timer delta (RFC 3448, 4.6) in usecs
  * @hist - Packet history
  */
 struct ccid3_hc_tx_sock {
@@ -101,7 +111,6 @@ struct ccid3_hc_tx_sock {
 	struct timer_list		no_feedback_timer;
 	ktime_t				t_ld;
 	ktime_t				t_nom;
-	u32				delta;
 	struct tfrc_tx_hist_entry	*hist;
 };
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -90,19 +90,16 @@ static inline u64 rfc3390_initial_rate(struct sock *sk)
 	return scaled_div(w_init << 6, hctx->rtt);
 }
 
-/*
- * Recalculate t_ipi and delta (should be called whenever X changes)
+/**
+ * ccid3_update_send_interval  -  Calculate new t_ipi = s / X_inst
+ * This respects the granularity of X_inst (64 * bytes/second).
  */
 static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
-	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
 	hctx->t_ipi = scaled_div32(((u64)hctx->s) << 6, hctx->x);
 
-	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hctx->delta = min_t(u32, hctx->t_ipi / 2, TFRC_OPSYS_HALF_TIME_GRAN);
-
-	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n", hctx->t_ipi,
-		       hctx->delta, hctx->s, (unsigned)(hctx->x >> 6));
+	ccid3_pr_debug("t_ipi=%u, s=%u, X=%u\n", hctx->t_ipi,
+		       hctx->s, (unsigned)(hctx->x >> 6));
 }
 
 static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
@@ -336,8 +333,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hctx->delta >= 1000)
-			return (u32)delay / 1000L;
+		if (delay >= TFRC_T_DELTA)
+			return (u32)delay / USEC_PER_MSEC;
 
 		ccid3_hc_tx_update_win_count(hctx, now);
 	}


The University of Aberdeen is a charity registered in Scotland, No SC013683.

