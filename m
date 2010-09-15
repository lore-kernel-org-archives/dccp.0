From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Sep 2010 12:10:21 +0000
Subject: [PATCH 1/3] dccp ccid-3: A lower bound for the inter-packet scheduling algorithm
Message-Id: <1284552623-16283-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a subtle bug in the calculation of the inter-packet gap and shows
that t_delta, as it is currently used, is not needed.

The algorithm from RFC 5348, 8.3 below continually computes a send time t_nom,
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

Problem:
--------
Rescheduling requires a conversion into milliseconds (sk_reset_timer()). The
highest jiffy resolution with HZ00 is 1 millisecond, so using a higher
granularity does not make much sense here.

As a consequence, values of t_distance < 1000 are truncated to 0. This issue
has so far been resolved by using instead

  if (t_distance >= t_delta + 1000)
	reschedule after (t_distance / 1000) milliseconds;

This is unnecessarily large, a lower bound is t_delta' = max(t_delta, 1000).
And it implies a further simplification:

 a) when HZ >= 500, then t_delta <= t_gran/2 = 10^6/(2*HZ) <= 1000, so that
    t_delta' = MAX(1000, t_delta) = 1000 (constant value);

 b) when HZ < 500, then t_delta = 1/2*MIN(rtt, t_ipi, t_gran) <= t_gran/2,
    so that 1000 <= t_delta' <= t_gran/2.

The maximum error of using a constant t_delta in (b) is less than half a jiffy.

Fix:
----
The patch replaces t_delta with a constant, whose value depends on CONFIG_HZ,
changing the above algorithm to:

  if (t_distance >= t_delta')
	reschedule after (t_distance / 1000) milliseconds;

where t_delta' = 10^6/(2*HZ) if HZ < 500, and t_delta' = 1000 otherwise.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h |   18 +++++++++++++-----
 net/dccp/ccids/ccid3.c |   19 ++++++++-----------
 2 files changed, 21 insertions(+), 16 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -45,12 +45,22 @@
 /* Two seconds as per RFC 5348, 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
-/* In usecs - half the scheduling granularity as per RFC3448 4.6 */
-#define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
-
 /* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
 #define TFRC_T_MBI		   64
 
+/*
+ * The t_delta parameter (RFC 5348, 8.3): delays of less than %USEC_PER_MSEC are
+ * rounded down to 0, since sk_reset_timer() here uses millisecond granularity.
+ * Hence we can use a constant t_delta = %USEC_PER_MSEC when HZ >= 500. A coarse
+ * resolution of HZ < 500 means that the error is below one timer tick (t_gran)
+ * when using the constant t_delta  =  t_gran / 2  =  %USEC_PER_SEC / (2 * HZ).
+ */
+#if (HZ >= 500)
+# define TFRC_T_DELTA		   USEC_PER_MSEC
+#else
+# define TFRC_T_DELTA		   (USEC_PER_SEC / (2 * HZ))
+#endif
+
 enum ccid3_options {
 	TFRC_OPT_LOSS_EVENT_RATE = 192,
 	TFRC_OPT_LOSS_INTERVALS	 = 193,
@@ -90,7 +100,6 @@ enum ccid3_hc_tx_states {
  * @tx_no_feedback_timer: Handle to no feedback timer
  * @tx_t_ld:		  Time last doubled during slow start
  * @tx_t_nom:		  Nominal send time of next packet
- * @tx_delta:		  Send timer delta (RFC 3448, 4.6) in usecs
  * @tx_hist:		  Packet history
  * @tx_options_received:  Parsed set of retrieved options
  */
@@ -109,7 +118,6 @@ struct ccid3_hc_tx_sock {
 	struct timer_list		tx_no_feedback_timer;
 	ktime_t				tx_t_ld;
 	ktime_t				tx_t_nom;
-	u32				tx_delta;
 	struct tfrc_tx_hist_entry	*tx_hist;
 	struct ccid3_options_received	tx_options_received;
 };
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -91,19 +91,16 @@ static inline u64 rfc3390_initial_rate(struct sock *sk)
 	return scaled_div(w_init << 6, hc->tx_rtt);
 }
 
-/*
- * Recalculate t_ipi and delta (should be called whenever X changes)
+/**
+ * ccid3_update_send_interval  -  Calculate new t_ipi = s / X_inst
+ * This respects the granularity of X_inst (64 * bytes/second).
  */
 static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hc)
 {
-	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
 	hc->tx_t_ipi = scaled_div32(((u64)hc->tx_s) << 6, hc->tx_x);
 
-	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
-	hc->tx_delta = min_t(u32, hc->tx_t_ipi / 2, TFRC_OPSYS_HALF_TIME_GRAN);
-
-	ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n", hc->tx_t_ipi,
-		       hc->tx_delta, hc->tx_s, (unsigned)(hc->tx_x >> 6));
+	ccid3_pr_debug("t_ipi=%u, s=%u, X=%u\n", hc->tx_t_ipi,
+		       hc->tx_s, (unsigned)(hc->tx_x >> 6));
 }
 
 static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hc, ktime_t now)
@@ -332,15 +329,15 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		delay = ktime_us_delta(hc->tx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
-		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
+		 *	Scheduling of packet transmissions (RFC 5348, 8.3)
 		 *
 		 * if (t_now > t_nom - delta)
 		 *       // send the packet now
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (s64)hc->tx_delta >= 1000)
-			return (u32)delay / 1000L;
+		if (delay >= TFRC_T_DELTA)
+			return (u32)delay / USEC_PER_MSEC;
 
 		ccid3_hc_tx_update_win_count(hc, now);
 		break;
