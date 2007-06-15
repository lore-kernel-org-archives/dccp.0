From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:42 +0000
Subject: [PATCH 5/9]: New RX History Step 4 - Receiver RTT sampling (part 1 of 3)
Message-Id: <200706151531.43004@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: New RX History Step 4 - Receiver RTT sampling (part 1 of 3)

The CCID 3 receiver needs an RTT estimate, for instance to compute the initial
loss interval (RFC 3448, 6.3.1). 

A function to realise this is provided by this patch. 

It uses a much-optimised variant of the algorithm from [RFC 4342, 8.1];
relying on timestamps and CCVal counters.  If RTT estimation fails (e.g. due
to early loss), the fall-back value from [RFC 4340, 3.4] is used.
For algorithm details see section 5 of 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/


Note: The complete realisation requires two more steps --
      (a) a utility function to identify data packets       [next patch] and
      (b) the integration of this TFRC-function into  CCID3 [next+1 patch].
     
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   67 +++---------------------------------
 net/dccp/ccids/lib/packet_history.c |   42 ++++++++++++++++++++++
 net/dccp/ccids/lib/packet_history.h |    4 +-
 3 files changed, 52 insertions(+), 61 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -268,6 +268,48 @@ void tfrc_rx_hist_cleanup(struct tfrc_rx
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
 
+/**
+ * tfrc_rx_sample_rtt  -  Sample RTT from timestamp / CCVal
+ * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
+ * to compute a sample with given data - calling function should check this.
+ */
+u32 tfrc_rx_sample_rtt(struct tfrc_rx_hist *h, struct sk_buff *skb)
+{
+	u32 sample = 0,
+	    delta_v = SUB16(dccp_hdr(skb)->dccph_ccval, rtt_last_s(h)->ccval);
+
+	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
+
+		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
+			sample = ktime_delta(rtt_prev_s(h)->stamp,
+					     rtt_last_s(h)->stamp);
+			sample *= 4 / SUB16(rtt_prev_s(h)->ccval,
+					    rtt_last_s(h)->ccval);
+		} else if (delta_v < 1) {
+			h->rtt_sample_prev = 1;
+			goto keep_ref_for_next_time;
+		}
+
+	} else if (delta_v = 4) {     /* optimal match */
+		sample = ktime_to_us(net_timedelta(rtt_last_s(h)->stamp));
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
+
+	return sample;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_sample_rtt);
+
 /* Module initialisation and cleanup routines */
 int __init packet_history_init(void)
 {
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -739,61 +739,11 @@ static int ccid3_hc_rx_insert_options(st
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
-				interval = win_count - entry->dccphrx_ccval;
-				if (interval < 0)
-					interval += TFRC_WIN_COUNT_LIMIT;
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
@@ -802,9 +752,9 @@ found:
 	 *		 R * fval
 	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
 	 */
-	if (rtt = 0) {			/* would result in divide-by-zero */
-		DCCP_WARN("RTT=0\n");
-		return ~0;
+	if (hcrx->ccid3hcrx_rtt = 0) {
+		DCCP_WARN("No RTT estimate available, using fallback RTT\n");
+		hcrx->ccid3hcrx_rtt = DCCP_FALLBACK_RTT;
 	}
 /* XXX this also has a forward dependency, which is resolved in the patch
  *     that does receiver RTT sampling. The problem with the code below is
@@ -824,17 +774,14 @@ found:
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
+	return p = 0? ~0U : scaled_div(1, p);
 }
 
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -46,7 +46,8 @@
 #define NDUPACK 3
 
 #define TFRC_WIN_COUNT_PER_RTT	 4
-#define TFRC_WIN_COUNT_LIMIT	16
+/* Subtraction a-b modulo-16, respects circular wrap-around */
+#define SUB16(a,b)		(((a) + 16 - (b)) & 0xF)
 
 /*
  * 	Transmitter History data structures and declarations
@@ -223,6 +224,7 @@ static inline void tfrc_rx_hist_update(s
 	tfrc_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
+extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
 
