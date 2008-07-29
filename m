From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:50 +0000
Subject: [PATCH 5/7] dccp tfrc: Increase number of RTT samples
Message-Id: <1217325952-12337-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This improves the receiver RTT sampling algorithm so that it tries harder to get
as many RTT samples as possible, using several optimisations.

Applicability and background
----------------------------
The algorithm uses timestamps and differences of the CCval window counter to
guess the RTT, using concepts presented in RFC 4340, 8.1.

There exist 4 cases for the CCVal difference:
 * = 0: less than RTT/4 passed since last packet -- unusable sample;
 *  > 4: (much) more than 1 RTT has passed since last packet -- also unusable;
 * = 4: "perfect" sample (exactly one RTT has passed since last packet);
 * 1..3: sub-optimal sample (between RTT/4 and 3*RTT/4 has passed).

In the last case the algorithm so far tried to optimise by storing away the
candidate and then re-trying next time. This had the following problems:
 * a large number of samples is needed to smooth out the given inaccuracies;
 * the sender may not be sending enough packets to warrant a "next time";
 * hence it is better to use suboptimal samples whenever possible.
As a consequence, the algorithm now stores away the current sample only if the
difference is 0.

A realistic example to illustrate the failure of the (previous) algorithm is MP3
streaming, where packets are sent at a rate of less than one packet per RTT.
Which means that suitable samples may be absent for a very long time.

The effectiveness of using suboptimal samples (with a delta between 1 and 4) was
confirmed by instrumenting the algorithm with counters. The results of two 20
second test runs were:
 * With the old algorithm and a total of 38442 function calls, only 394 of these
   calls resulted in usable RTT samples (about 1%), 378 out of these were
   "perfect" samples, and 28013 (unused) samples had a delta of 1..3.
 * With the new algorithm and a total of 37057 function calls, 1702 usable RTT
   samples were retrieved (about 4.6%), 5 out of these were "perfect" samples.
This means an almost five-fold increase in the number of samples.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   83 ++++++++++-------------------------
 1 files changed, 24 insertions(+), 59 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -428,31 +428,16 @@ int tfrc_rx_hist_init(struct tfrc_rx_hist *h, struct sock *sk)
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);
 
 /**
- * tfrc_rx_hist_rtt_last_s - reference entry to compute RTT samples against
- */
-static inline struct tfrc_rx_hist_entry *
-			tfrc_rx_hist_rtt_last_s(const struct tfrc_rx_hist *h)
-{
-	return h->ring[0];
-}
-
-/**
- * tfrc_rx_hist_rtt_prev_s: previously suitable (wrt rtt_last_s) RTT-sampling entry
- */
-static inline struct tfrc_rx_hist_entry *
-			tfrc_rx_hist_rtt_prev_s(const struct tfrc_rx_hist *h)
-{
-	return h->ring[h->rtt_sample_prev];
-}
-
-/**
  * tfrc_rx_hist_sample_rtt  -  Sample RTT from timestamp / CCVal
- * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
- * to compute a sample with given data - calling function should check this.
+ * Based on ideas presented in RFC 4342, 8.1. This function expects that no loss
+ * is pending and uses the following history entries (via rtt_sample_prev):
+ * - h->ring[0]  contains the most recent history entry prior to @skb;
+ * - h->ring[1]  is an unused `dummy' entry when the current difference is 0;
  */
 void tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
 {
-	u32 sample = 0, delta_v;
+	struct tfrc_rx_hist_entry *last = h->ring[0];
+	u32 sample, delta_v;
 
 	/*
 	 * When not to sample:
@@ -466,47 +451,27 @@ void tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
 	    tfrc_rx_hist_loss_pending(h))
 		return;
 
-	delta_v = SUB16(dccp_hdr(skb)->dccph_ccval,
-			tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
-
-	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
-		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
-			sample = SUB16(tfrc_rx_hist_rtt_prev_s(h)->tfrchrx_ccval,
-				       tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
-			if (sample)
-				sample = 4 / sample *
-				         ktime_us_delta(tfrc_rx_hist_rtt_prev_s(h)->tfrchrx_tstamp,
-							tfrc_rx_hist_rtt_last_s(h)->tfrchrx_tstamp);
-			else    /*
-				 * FIXME: This condition is in principle not
-				 * possible but occurs when CCID is used for
-				 * two-way data traffic. I have tried to trace
-				 * it, but the cause does not seem to be here.
-				 */
-				DCCP_BUG("please report to dccp@vger.kernel.org"
-					 " => prev = %u, last = %u",
-					 tfrc_rx_hist_rtt_prev_s(h)->tfrchrx_ccval,
-					 tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
-		} else if (delta_v < 1) {
-			h->rtt_sample_prev = 1;
-			goto keep_ref_for_next_time;
-		}
-
-	} else if (delta_v = 4) /* optimal match */
-		sample = ktime_to_us(net_timedelta(tfrc_rx_hist_rtt_last_s(h)->tfrchrx_tstamp));
-	else {			 /* suboptimal match */
-		h->rtt_sample_prev = 2;
-		goto keep_ref_for_next_time;
-	}
+	h->rtt_sample_prev = 0;		/* reset previous candidate */
 
-	if (unlikely(sample > DCCP_SANE_RTT_MAX)) {
-		DCCP_WARN("RTT sample %u too large, using max\n", sample);
-		sample = DCCP_SANE_RTT_MAX;
+	delta_v = SUB16(dccp_hdr(skb)->dccph_ccval, last->tfrchrx_ccval);
+	if (delta_v = 0) {		/* less than RTT/4 difference */
+		h->rtt_sample_prev = 1;
+		return;
 	}
+	sample = dccp_sane_rtt(ktime_to_us(net_timedelta(last->tfrchrx_tstamp)));
 
-	h->rtt_sample_prev = 0;	       /* use current entry as next reference */
-keep_ref_for_next_time:
+	if (delta_v <= 4)		/* between RTT/4 and RTT */
+		sample *= 4 / delta_v;
+	else if (!(sample < h->rtt_estimate && sample > h->rtt_estimate/2))
+		/*
+		* Optimisation: CCVal difference is greater than 1 RTT, yet the
+		* sample is less than the local RTT estimate; which means that
+		* the RTT estimate is too high.
+		* To avoid noise, it is not done if the sample is below RTT/2.
+		*/
+		return;
 
-	h->rtt_estimate = tfrc_ewma(h->rtt_estimate, sample, 9);
+	/* Use a lower weight than usual to increase responsiveness */
+	h->rtt_estimate = tfrc_ewma(h->rtt_estimate, sample, 5);
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_sample_rtt);
