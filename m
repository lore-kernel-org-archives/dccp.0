From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:52:22 +0000
Subject: [PATCH 4/9]: Recompute average loss interval
Message-Id: <200706171352.22988@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Recompute average loss interval

This patch:
 * adds routines for recomputing I_mean/p as required by TFRC;
 * places the average, I_mean, into the loss_hist structure;
 * supports continued detection of new loss intervals.

The second point is in keeping with the objective: loss history management
and computing the relevant data is a service exported by the module. Hence the
module should have exclusive access to the average I_mean which it maintains.

Furthermore, any new packet is monitored against wrap-around of the window
counter with respect to the current loss interval. 
As described in RFC 4342, 10.2, this test is required in order to accurately
determine whether two losses belong to different loss intervals.

Finally, the weights have been re-adjusted to use the format suggested in
[RFC 3448, 5.4]: using the ones of section 8 reduces accuracy ('smoothness');
this could be reverted if people think that there is a gain in using mostly
multiples of two (not too sure there is).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h             |    2 
 net/dccp/ccids/lib/loss_interval.c |   87 +++++++++++++++++++++----------------
 net/dccp/ccids/lib/loss_interval.h |    5 +-
 3 files changed, 55 insertions(+), 39 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -44,10 +44,12 @@ struct tfrc_loss_interval {
  *  tfrc_loss_hist  -  Loss record database
  *  @ring:	Circular queue managed in LIFO manner
  *  @counter:	Current count of entries (can be more than %LIH_SIZE)
+ *  @i_mean:	Current Average Loss Interval [RFC 3448, 5.4]
  */
 struct tfrc_loss_hist {
 	struct tfrc_loss_interval	*ring[LIH_SIZE];
 	u8				counter;
+	u32				i_mean;
 };
 
 static inline void tfrc_lh_init(struct tfrc_loss_hist *lh)
@@ -65,8 +67,7 @@ static inline u8 tfrc_lh_length(struct t
 	return min(lh->counter, (u8)LIH_SIZE);
 }
 
+extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
 extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
 
-extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
-
 #endif /* _DCCP_LI_HIST_ */
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -158,7 +158,7 @@ struct ccid3_hc_rx_sock {
 	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct tfrc_loss_hist		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
-	u32				ccid3hcrx_pinv;
+#define ccid3hcrx_pinv			ccid3hcrx_li_hist.i_mean
 };
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -17,6 +17,8 @@
 #include "loss_interval.h"
 
 static struct kmem_cache  *tfrc_lh_slab;
+/* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
+static const int tfrc_lh_weights[NINTERVAL] = { 10, 10, 10, 10, 8, 6, 4, 2 };
 
 /*
  * Access macros: These require that at least one entry is present in lh,
@@ -59,51 +61,64 @@ void tfrc_lh_cleanup(struct tfrc_loss_hi
 }
 EXPORT_SYMBOL_GPL(tfrc_lh_cleanup);
 
-/* Weights used to calculate loss event rate */
-/*
- * These are integers as per section 8 of RFC3448. We can then divide by 4 *
- * when we use it.
- */
-static const int dccp_li_hist_w[DCCP_LI_HIST_IVAL_F_LENGTH] = {
-	4, 4, 4, 4, 3, 2, 1, 1,
-};
-
-u32 dccp_li_hist_calc_i_mean(struct list_head *list)
-{
-	struct dccp_li_hist_entry *li_entry, *li_next;
-	int i = 0;
-	u32 i_tot;
-	u32 i_tot0 = 0;
-	u32 i_tot1 = 0;
-	u32 w_tot  = 0;
-
-	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
-		if (li_entry->dccplih_interval != ~0U) {
-			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
-			w_tot  += dccp_li_hist_w[i];
-			if (i != 0)
-				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
-		}
+static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
+{
+	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
+	int i, k = tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
 
+	for (i=0; i <= k; i++) {
+		i_i = tfrc_lh_get_interval(lh, i);
 
-		if (++i > DCCP_LI_HIST_IVAL_F_LENGTH)
-			break;
+		if (i < k) {
+			i_tot0 += i_i * tfrc_lh_weights[i];
+			w_tot  += tfrc_lh_weights[i];
+		}
+		if (i > 0)
+			i_tot1 += i_i * tfrc_lh_weights[i-1];
 	}
 
-	if (i != DCCP_LI_HIST_IVAL_F_LENGTH)
+	BUG_ON(w_tot = 0);
+	lh->i_mean = max(i_tot0, i_tot1) / w_tot;
+}
+
+/**
+ * tfrc_lh_update_i_mean  -  Update the `open' loss interval I_0
+ * For recomputing p: returns `true' if p > p_prev  <=>  1/p < 1/p_prev
+ */
+u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
+{
+	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh);
+	u32 old_i_mean = lh->i_mean;
+	s64 length;
+
+	if (cur = NULL)			/* not initialised */
 		return 0;
 
-	i_tot = max(i_tot0, i_tot1);
+	length = dccp_delta_seqno(cur->li_seqno, DCCP_SKB_CB(skb)->dccpd_seq);
 
-	if (!w_tot) {
-		DCCP_WARN("w_tot = 0\n");
-		return 1;
-	}
+	if (length - cur->li_length <= 0)	/* duplicate or reordered */
+		return 0;
 
-	return i_tot / w_tot;
-}
+	if (SUB16(dccp_hdr(skb)->dccph_ccval, cur->li_ccval) > 4)
+		/*
+		 * Implements RFC 4342, 10.2:
+		 * If a packet S (skb) exists whose seqno comes `after' the one
+		 * starting the current loss interval (cur) and if the modulo-16
+		 * distance from C(cur) to C(S) is greater than 4, consider all
+		 * subsequent packets as belonging to a new loss interval. This
+		 * test is necessary since CCVal may wrap between intervals.
+		 */
+		cur->li_is_closed = 1;
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
+	if (tfrc_lh_length(lh) = 1)		/* due to RFC 3448, 6.3.1 */
+		return 0;
+
+	cur->li_length = length;
+	tfrc_lh_calc_i_mean(lh);
+
+	return (lh->i_mean < old_i_mean);
+}
+EXPORT_SYMBOL_GPL(tfrc_lh_update_i_mean);
 
 int __init li_init(void)
 {
