From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:34:03 +0000
Subject: [PATCH 11/43]: New RX History Step 4 - Receiver RTT sampling
Message-Id: <200704051634.03461@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 4 - Receiver RTT sampling

The CCID 3 receiver needs an RTT estimate only once, to compute the initial
loss interval (RFC 3448, 6.3.1). A function to realise this is provided by
this patch. It uses a much-optimised variant of the algorithm presented in 
RFC 4342, 8.1, relying on timestamps and CCVal counters.  If RTT estimation fails
(e.g. due to early loss), the fall-back value from [RFC 4340, 3.4] is used.


 	  A l g o r i t h m   D e t a i l s  [not necessarily commit msg]
	  ---------------------------------------------------------------

 The RTT sampling algorithm requires up to three history entries:
 
  (1) last = hist[0] is always used as the point of reference against which either 
      the current packet or a previously suitable candidate packet (see below) is
      evaluated with regard to the difference of CCVal values;
 
  (2) hist[1] is used as `dummy' entry when the difference between current and `last'
      CCVal is 0, and when no previous candidate packet has been recorded;
 
  (3) prev = hist[2] is used to store a suitable candidate which is such that its CCVal
      difference D to the last = hist[0] packet is in the range 1..3 (and thus sub-optimal).
 
 All three cases are controlled by a single variable, `prev_sample', which is initialised to 0.
 The variable, an alias for loss_start, is also used in determining where the current packet's
 details are to be stored (for the purpose of tracking the highest received sequence number).
 The details of the current packet are always stored in the entry 
  
    last_rcv  =  hist[(loss_start + loss_count) & NUMDUPACK]
 
 which, since loss_count = 0 during RTT sampling and since prev_sample < 3, simplifies to 
 
    last_rcv  =  hist[prev_sample]  =  hist[loss_start]
 
 Hence setting prev_sample to a non-0 value avoids overwriting the `last' entry (hist[0]) with
 the details of the current packet. In addition, a prev_sample of 2 indicates that a previously
 suitable candidate entry has been recorded for possible later use.
 
 See also section 5 of http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   68 +++---------------------------------
 net/dccp/ccids/lib/packet_history.c |   47 ++++++++++++++++++++++++
 net/dccp/ccids/lib/packet_history.h |    1 
 3 files changed, 55 insertions(+), 61 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -221,6 +221,7 @@ static inline void tfrc_rx_hist_update(s
 	dccp_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
+extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
 
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -351,6 +351,53 @@ void tfrc_rx_hist_cleanup(struct tfrc_rx
 
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
 
+/**
+ * tfrc_rx_sample_rtt  -  Sample RTT from timestamp / CCVal
+ * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
+ * to compute a sample with given data - calling function should check this.
+ */
+u32 tfrc_rx_sample_rtt(struct tfrc_rx_hist *h, struct sk_buff *skb)
+{
+	u8  ref = rtt_last_s(h)->dccphrx_ccval;
+	u32 delta_v = SUB16(dccp_hdr(skb)->dccph_ccval, ref);
+	u32 sample = 0;
+
+	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
+
+		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
+
+			sample = timeval_delta(&rtt_prev_s(h)->dccphrx_tstamp,
+					       &rtt_last_s(h)->dccphrx_tstamp)
+			       *  4 / SUB16(rtt_prev_s(h)->dccphrx_ccval, ref);
+
+		} else if (delta_v < 1) {
+			h->rtt_sample_prev = 1;
+			goto keep_ref_for_next_time;
+		}
+
+	} else if (delta_v = 4) {     /* optimal match */
+		struct timeval t_recv;
+
+		skb_get_timestamp(skb, &t_recv);
+		sample = timeval_delta(&t_recv, &rtt_last_s(h)->dccphrx_tstamp);
+
+	} else	{		       /* suboptimal match */
+		h->rtt_sample_prev = 2;
+		goto keep_ref_for_next_time;
+	}
+
+	if (unlikely(sample > DCCP_SANE_RTT_MAX)) {
+		DCCP_WARN("RTT sample %u too large, using max\n", sample);
+		sample = DCCP_SANE_RTT_MAX;
+	}
+
+	h->rtt_sample_prev = 0;	       /* use current entry as next reference */
+keep_ref_for_next_time:
+	return sample;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_rx_sample_rtt);
+
 /* Module initialisation and cleanup routines */
 int __init packet_history_init(void)
 {
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -820,60 +820,11 @@ static int ccid3_hc_rx_insert_options(st
 static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
-	suseconds_t rtt, delta;
-	struct timeval tstamp = { 0, };
-	int interval = 0;
-	int win_count = 0;
-	int step = 0;
+	suseconds_t delta;
+	struct timeval tstamp;
 	u64 fval;
 
-#if 0		/* XXX resolved in subsequent patch */
-	list_for_each_entry_safe(entry, next, &hcrx->ccid3hcrx_hist,
-				 dccphrx_node) {
-		if (dccp_rx_hist_entry_data_packet(entry)) {
-			tail = entry;
-
-			switch (step) {
-			case 0:
-				tstamp	  = entry->dccphrx_tstamp;
-				win_count = entry->dccphrx_ccval;
-				step = 1;
-				break;
-			case 1:
-				interval = SUB16(win_count, entry->dccphrx_ccval);
-				if (interval > 4)
-					goto found;
-				break;
-			}
-		}
-	}
-
-	if (unlikely(step = 0)) {
-		DCCP_WARN("%s(%p), packet history has no data packets!\n",
-			  dccp_role(sk), sk);
-		return ~0;
-	}
-
-	if (unlikely(interval = 0)) {
-		DCCP_WARN("%s(%p), Could not find a win_count interval > 0."
-			  "Defaulting to 1\n", dccp_role(sk), sk);
-		interval = 1;
-	}
-found:
-	if (!tail) {
-		DCCP_CRIT("tail is null\n");
-		return ~0;
-	}
-
-	delta = timeval_delta(&tstamp, &tail->dccphrx_tstamp);
-	DCCP_BUG_ON(delta < 0);
-
-	rtt = delta * 4 / interval;
-	ccid3_pr_debug("%s(%p), approximated RTT to %dus\n",
-		       dccp_role(sk), sk, (int)rtt);
-
 	/*
 	 * Determine the length of the first loss interval via inverse lookup.
 	 * Assume that X_recv can be computed by the throughput equation
@@ -882,9 +833,9 @@ found:
 	 *		 R * fval
 	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
 	 */
-	if (rtt = 0) {			/* would result in divide-by-zero */
-		DCCP_WARN("RTT=0\n");
-		return ~0;
+	if (hcrx->ccid3hcrx_rtt = 0) {
+		DCCP_WARN("No RTT estimate available, using 0.2sec fallback\n");
+		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
 	}
 
 	do_gettimeofday(&tstamp);
@@ -900,19 +851,14 @@ found:
 		}
 	}
 
-	fval = scaled_div(hcrx->ccid3hcrx_s, rtt);
+	fval = scaled_div(hcrx->ccid3hcrx_s, hcrx->ccid3hcrx_rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
 	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
 		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
 
-	if (p = 0)
-		return ~0;
-	else
-		return 1000000 / p;
-#endif
-	return ~0;
+	return (p = 0)? ~0U : scaled_div(1, p);
 }
 
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
