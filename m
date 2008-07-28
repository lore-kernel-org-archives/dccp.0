From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:13:57 +0000
Subject: [PATCH 1/7] dccp ccid-3: Runtime verification of timer resolution
Message-Id: <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This prevents module loading when the timer resolution is too low
(e.g. when using jiffies as a clocksource or when disabling high
resolution timers on sparc64).

Rationale:
----------
The DCCP base time resolution is 10 microseconds (RFC 4340, 13.1...3). Using a
timer with a lower resolution than that was found to trigger the following bug
warnings/problems on high-speed networks (e.g. local loopback):

 * small RTT samples are rounded down to 0
  (in some cases, even negative RTT samples occurred);
 * the CCID-3 feedback timer complains that the feedback interval is 0,
   since the coarse-grained resolution rounds RTT-wise intervals down.

The following syslog messages were observed with a low resolution:
  11:24:00 kernel: BUG: delta (0) <= 0 at ccid3_hc_rx_send_feedback()
  11:26:12 kernel: BUG: delta (0) <= 0 at ccid3_hc_rx_send_feedback()
  11:26:30 kernel: dccp_sample_rtt: unusable RTT sample 0, using min
  11:26:30 last message repeated 5 times

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   13 +++++++++++++
 net/dccp/dccp.h        |    5 ++++-
 net/dccp/timer.c       |    3 +--
 3 files changed, 18 insertions(+), 3 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -86,10 +86,13 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
  */
 #define DCCP_RTO_MAX ((unsigned)(64 * HZ))
 
+/* DCCP base time resolution - 10 microseconds (RFC 4340, 13.1 ... 13.3) */
+#define DCCP_TIME_RESOLUTION	10
+
 /*
  * RTT sampling: sanity bounds and fallback RTT value from RFC 4340, section 3.4
  */
-#define DCCP_SANE_RTT_MIN	100
+#define DCCP_SANE_RTT_MIN	(10 * DCCP_TIME_RESOLUTION)
 #define DCCP_FALLBACK_RTT	(USEC_PER_SEC / 5)
 #define DCCP_SANE_RTT_MAX	(3 * USEC_PER_SEC)
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -869,6 +869,19 @@ MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 
 static __init int ccid3_module_init(void)
 {
+	struct timespec tp;
+
+	/*
+	 * Without a fine-grained clock resolution, RTTs/X_recv are not sampled
+	 * correctly and feedback is sent either too early or too late.
+	 */
+	hrtimer_get_res(CLOCK_MONOTONIC, &tp);
+	if (tp.tv_sec || tp.tv_nsec > DCCP_TIME_RESOLUTION * NSEC_PER_USEC) {
+		printk(KERN_ERR "%s: Timer too coarse (%ld usec), need %u-usec"
+		       " resolution - check your clocksource.\n", __func__,
+		       tp.tv_nsec/NSEC_PER_USEC, DCCP_TIME_RESOLUTION);
+		return -ESOCKTNOSUPPORT;
+	}
 	return ccid_register(&ccid3);
 }
 module_init(ccid3_module_init);
--- a/net/dccp/timer.c
+++ b/net/dccp/timer.c
@@ -281,8 +281,7 @@ u32 dccp_timestamp(void)
 {
 	s64 delta = ktime_us_delta(ktime_get_real(), dccp_timestamp_seed);
 
-	do_div(delta, 10);
-	return delta;
+	return div_u64(delta, DCCP_TIME_RESOLUTION);
 }
 EXPORT_SYMBOL_GPL(dccp_timestamp);
 
