From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:26 +0000
Subject: [PATCH 6/8] [PATCH v2] [TFRC]: Ringbuffer to track loss interval history
Message-Id: <11971083882049-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

A ringbuffer-based implementation of loss interval history is easier to
maintain, allocate, and update.

Details:
 * access to the Loss Interval Records via macro wrappers (with safety checks);
 * simplified, on-demand allocation of entries (no extra memory consumption on
   lossless links); cache allocation is local to the module / exported as service;
 * provision of RFC-compliant algorithm to re-compute average loss interval;
 * provision of comprehensive, new loss detection algorithm
 	- support for all cases of loss, including re-ordered/duplicate packets;
 	- waiting for NDUPACK=3 packets to fill the hole;
	- updating loss records when a late-arriving packet fills a hole.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/lib/loss_interval.c  |  158 ++++++++++++++++++++++++++-
 net/dccp/ccids/lib/loss_interval.h  |   58 ++++++++++-
 net/dccp/ccids/lib/packet_history.c |  201 +++++++++++++++++++++++++++++++++++
 net/dccp/ccids/lib/packet_history.h |   11 ++-
 net/dccp/ccids/lib/tfrc.h           |    3 +
 5 files changed, 421 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index c0a933a..b0e59fb 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -1,6 +1,7 @@
 /*
  *  net/dccp/ccids/lib/loss_interval.c
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
@@ -10,12 +11,7 @@
  *  the Free Software Foundation; either version 2 of the License, or
  *  (at your option) any later version.
  */
-
-#include <linux/module.h>
 #include <net/sock.h>
-#include "../../dccp.h"
-#include "loss_interval.h"
-#include "packet_history.h"
 #include "tfrc.h"
 
 #define DCCP_LI_HIST_IVAL_F_LENGTH  8
@@ -27,6 +23,51 @@ struct dccp_li_hist_entry {
 	u32		 dccplih_interval;
 };
 
+static struct kmem_cache  *tfrc_lh_slab  __read_mostly;
+/* Loss Interval weights from [RFC 3448, 5.4], scaled by 10 */
+static const int tfrc_lh_weights[NINTERVAL] = { 10, 10, 10, 10, 8, 6, 4, 2 };
+
+/*
+ * Access macros: These require that at least one entry is present in lh,
+ * and implement array semantics (0 is first, n-1 is the last of n entries).
+ */
+#define __lih_index(lh, n)	LIH_INDEX((lh)->counter - (n) - 1)
+#define __lih_entry(lh, n)	(lh)->ring[__lih_index(lh, n)]
+#define __curr_entry(lh)	(lh)->ring[LIH_INDEX((lh)->counter - 1)]
+#define __next_entry(lh)	(lh)->ring[LIH_INDEX((lh)->counter)]
+
+/* given i with 0 <= i <= k, return I_i as per the rfc3448bis notation */
+static inline u32 tfrc_lh_get_interval(struct tfrc_loss_hist *lh, u8 i)
+{
+	BUG_ON(i >= lh->counter);
+	return __lih_entry(lh, i)->li_length;
+}
+
+static inline struct tfrc_loss_interval *tfrc_lh_peek(struct tfrc_loss_hist *lh)
+{
+	return lh->counter ? __curr_entry(lh) : NULL;
+}
+
+/*
+ *	On-demand allocation and de-allocation of entries
+ */
+static struct tfrc_loss_interval *tfrc_lh_demand_next(struct tfrc_loss_hist *lh)
+{
+	if (__next_entry(lh) = NULL)
+		__next_entry(lh) = kmem_cache_alloc(tfrc_lh_slab, GFP_ATOMIC);
+
+	return __next_entry(lh);
+}
+
+void tfrc_lh_cleanup(struct tfrc_loss_hist *lh)
+{
+	if (tfrc_lh_is_initialised(lh))
+		for (lh->counter = 0; lh->counter < LIH_SIZE; lh->counter++)
+			if (__next_entry(lh) != NULL)
+				kmem_cache_free(tfrc_lh_slab, __next_entry(lh));
+}
+EXPORT_SYMBOL_GPL(tfrc_lh_cleanup);
+
 static struct kmem_cache *dccp_li_cachep __read_mostly;
 
 static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
@@ -98,6 +139,65 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
+static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
+{
+	u32 i_i, i_tot0 = 0, i_tot1 = 0, w_tot = 0;
+	int i, k = tfrc_lh_length(lh) - 1; /* k is as in rfc3448bis, 5.4 */
+
+	for (i=0; i <= k; i++) {
+		i_i = tfrc_lh_get_interval(lh, i);
+
+		if (i < k) {
+			i_tot0 += i_i * tfrc_lh_weights[i];
+			w_tot  += tfrc_lh_weights[i];
+		}
+		if (i > 0)
+			i_tot1 += i_i * tfrc_lh_weights[i-1];
+	}
+
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
+		return 0;
+
+	length = dccp_delta_seqno(cur->li_seqno, DCCP_SKB_CB(skb)->dccpd_seq);
+
+	if (length - cur->li_length <= 0)	/* duplicate or reordered */
+		return 0;
+
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
+
+	if (tfrc_lh_length(lh) = 1)		/* due to RFC 3448, 6.3.1 */
+		return 0;
+
+	cur->li_length = length;
+	tfrc_lh_calc_i_mean(lh);
+
+	return (lh->i_mean < old_i_mean);
+}
+EXPORT_SYMBOL_GPL(tfrc_lh_update_i_mean);
+
 static int dccp_li_hist_interval_new(struct list_head *list,
 				     const u64 seq_loss, const u8 win_loss)
 {
@@ -284,6 +384,54 @@ void dccp_li_update_li(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(dccp_li_update_li);
 
+/* Determine if `new_loss' does begin a new loss interval [RFC 4342, 10.2] */
+static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
+				     struct tfrc_rx_hist_entry *new_loss)
+{
+	return	dccp_delta_seqno(cur->li_seqno, new_loss->tfrchrx_seqno) > 0 &&
+		(cur->li_is_closed || SUB16(new_loss->tfrchrx_ccval, cur->li_ccval) > 4);
+}
+
+/** tfrc_lh_interval_add  -  Insert new record into the Loss Interval database
+ * @lh:		   Loss Interval database
+ * @rh:		   Receive history containing a fresh loss event
+ * @calc_first_li: Caller-dependent routine to compute length of first interval
+ * @sk:		   Used by @calc_first_li in caller-specific way (subtyping)
+ * Updates I_mean and returns 1 if a new interval has in fact been added to @lh.
+ */
+int tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
+			 u32 (*calc_first_li)(struct sock *), struct sock *sk)
+{
+	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh), *new;
+
+	if (cur != NULL && !tfrc_lh_is_new_loss(cur, tfrc_rx_hist_loss_prev(rh)))
+		return 0;
+
+	new = tfrc_lh_demand_next(lh);
+	if (unlikely(new = NULL)) {
+		DCCP_CRIT("Cannot allocate/add loss record.");
+		return 0;
+	}
+
+	new->li_seqno	  = tfrc_rx_hist_loss_prev(rh)->tfrchrx_seqno;
+	new->li_ccval	  = tfrc_rx_hist_loss_prev(rh)->tfrchrx_ccval;
+	new->li_is_closed = 0;
+
+	if (++lh->counter = 1)
+		lh->i_mean = new->li_length = (*calc_first_li)(sk);
+	else {
+		cur->li_length = dccp_delta_seqno(cur->li_seqno, new->li_seqno);
+		new->li_length = dccp_delta_seqno(new->li_seqno,
+				  tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno);
+		if (lh->counter > (2*LIH_SIZE))
+			lh->counter -= LIH_SIZE;
+
+		tfrc_lh_calc_i_mean(lh);
+	}
+	return 1;
+}
+EXPORT_SYMBOL_GPL(tfrc_lh_interval_add);
+
 int __init dccp_li_init(void)
 {
 	dccp_li_cachep = kmem_cache_create("dccp_li_hist",
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 27bee92..16d37fb 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -3,6 +3,7 @@
 /*
  *  net/dccp/ccids/lib/loss_interval.h
  *
+ *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
  *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
@@ -12,11 +13,66 @@
  *  Software Foundation; either version 2 of the License, or (at your option)
  *  any later version.
  */
-
 #include <linux/ktime.h>
 #include <linux/list.h>
+#include <linux/slab.h>
+
+/*
+ * Number of loss intervals (RFC 4342, 8.6.1). The history size is one more than
+ * NINTERVAL, since the `open' interval I_0 is always stored as the first entry.
+ * LIH_INDEX is used to implement LIFO semantics on the array.
+ */
+#define NINTERVAL	8
+#define LIH_SIZE	(NINTERVAL + 1)
+#define LIH_INDEX(ctr)	(LIH_SIZE - 1 - ((ctr) % LIH_SIZE))
+
+/**
+ *  tfrc_loss_interval  -  Loss history record for TFRC-based protocols
+ *  @li_seqno:		Highest received seqno before the start of loss
+ *  @li_ccval:		The CCVal belonging to @li_seqno
+ *  @li_is_closed:	Whether @li_seqno is older than 1 RTT
+ *  @li_length:		Loss interval sequence length
+ */
+struct tfrc_loss_interval {
+	u64		 li_seqno:48,
+			 li_ccval:4,
+			 li_is_closed:1;
+	u32		 li_length;
+};
+
+/**
+ *  tfrc_loss_hist  -  Loss record database
+ *  @ring:	Circular queue managed in LIFO manner
+ *  @counter:	Current count of entries (can be more than %LIH_SIZE)
+ *  @i_mean:	Current Average Loss Interval [RFC 3448, 5.4]
+ */
+struct tfrc_loss_hist {
+	struct tfrc_loss_interval	*ring[LIH_SIZE];
+	u8				counter;
+	u32				i_mean;
+};
+
+static inline void tfrc_lh_init(struct tfrc_loss_hist *lh)
+{
+	memset(lh, 0, sizeof(struct tfrc_loss_hist));
+}
+
+static inline u8 tfrc_lh_is_initialised(struct tfrc_loss_hist *lh)
+{
+	return lh->counter > 0;
+}
+
+static inline u8 tfrc_lh_length(struct tfrc_loss_hist *lh)
+{
+	return min(lh->counter, (u8)LIH_SIZE);
+}
 
 extern void dccp_li_hist_purge(struct list_head *list);
+struct tfrc_rx_hist;
+extern int  tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
+				 u32 (*first_li)(struct sock *), struct sock *);
+extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
+extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 428636e..a421032 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -214,6 +214,207 @@ int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_new_loss_indicated);
 
+static void tfrc_rx_hist_swap(struct tfrc_rx_hist_entry **a,
+			      struct tfrc_rx_hist_entry **b)
+{
+	struct tfrc_rx_hist_entry *tmp = *a;
+
+	*a = *b;
+	*b = tmp;
+}
+
+/*
+ * Private helper functions for loss detection.
+ *
+ * In the descriptions, `Si' refers to the sequence number of entry number i,
+ * whose NDP count is `Ni' (lower case is used for variables).
+ * Note: All __after_loss functions expect that a test against duplicates has
+ *       been performed already: the seqno of the skb must not be less than the
+ *       seqno of loss_prev; and it must not equal that of any valid hist_entry.
+ */
+static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2)
+{
+	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
+	    s1 = TFRC_RX_HIST_ENTRY(h, 1)->tfrchrx_seqno,
+	    s2 = DCCP_SKB_CB(skb)->dccpd_seq;
+	int n1 = TFRC_RX_HIST_ENTRY(h, 1)->tfrchrx_ndp,
+	   d12 = dccp_delta_seqno(s1, s2), d2;
+
+	if (d12 > 0) {			/* S1  <  S2 */
+		h->loss_count = 2;
+		tfrc_rx_hist_entry_from_skb(TFRC_RX_HIST_ENTRY(h, 2), skb, n2);
+		return;
+	}
+
+	/* S0  <  S2  <  S1 */
+	d2 = dccp_delta_seqno(s0, s2);
+
+	if (d2 = 1 || n2 >= d2) {	/* S2 is direct successor of S0 */
+		int d21 = -d12;
+
+		if (d21 = 1 || n1 >= d21) {
+			/* hole is filled: S0, S2, and S1 are consecutive */
+			h->loss_count = 0;
+			h->loss_start = tfrc_rx_hist_index(h, 1);
+		} else
+			/* gap between S2 and S1: just update loss_prev */
+			tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_loss_prev(h), skb, n2);
+
+	} else {			/* hole between S0 and S2 */
+		/*
+		 * Reorder history to insert S2 between S0 and s1
+		 */
+		tfrc_rx_hist_swap(&TFRC_RX_HIST_ENTRY(h, 0), &TFRC_RX_HIST_ENTRY(h, 3));
+		h->loss_start = tfrc_rx_hist_index(h, 3);
+		tfrc_rx_hist_entry_from_skb(TFRC_RX_HIST_ENTRY(h, 1), skb, n2);
+		h->loss_count = 2;
+	}
+}
+
+/* return 1 if a new loss event has been identified */
+static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
+{
+	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
+	    s1 = TFRC_RX_HIST_ENTRY(h, 1)->tfrchrx_seqno,
+	    s2 = TFRC_RX_HIST_ENTRY(h, 2)->tfrchrx_seqno,
+	    s3 = DCCP_SKB_CB(skb)->dccpd_seq;
+	int n1 = TFRC_RX_HIST_ENTRY(h, 1)->tfrchrx_ndp,
+	   d23 = dccp_delta_seqno(s2, s3), d13, d3, d31;
+
+	if (d23 > 0) {			/* S2  <  S3 */
+		h->loss_count = 3;
+		tfrc_rx_hist_entry_from_skb(TFRC_RX_HIST_ENTRY(h, 3), skb, n3);
+		return 1;
+	}
+
+	/* S3  <  S2 */
+	d13 = dccp_delta_seqno(s1, s3);
+
+	if (d13 > 0) {
+		/*
+		 * The sequence number order is S1, S3, S2
+		 * Reorder history to insert entry between S1 and S2
+		 */
+		tfrc_rx_hist_swap(&TFRC_RX_HIST_ENTRY(h, 2), &TFRC_RX_HIST_ENTRY(h, 3));
+		tfrc_rx_hist_entry_from_skb(TFRC_RX_HIST_ENTRY(h, 2), skb, n3);
+		h->loss_count = 3;
+		return 1;
+	}
+
+	/* S0  <  S3  <  S1 */
+	d31 = -d13;
+	d3  = dccp_delta_seqno(s0, s3);
+
+	if (d3 = 1 || n3 >= d3) {	/* S3 is a successor of S0 */
+
+		if (d31 = 1 || n1 >= d31) {
+			/* hole between S0 and S1 filled by S3 */
+			int  d2 = dccp_delta_seqno(s1, s2),
+			     n2 = TFRC_RX_HIST_ENTRY(h, 2)->tfrchrx_ndp;
+
+			if (d2 = 1 || n2 >= d2) {
+				/* entire hole filled by S0, S3, S1, S2 */
+				h->loss_start = tfrc_rx_hist_index(h, 2);
+				h->loss_count = 0;
+			} else {
+				/* gap remains between S1 and S2 */
+				h->loss_start = tfrc_rx_hist_index(h, 1);
+				h->loss_count = 1;
+			}
+
+		} else /* gap exists between S3 and S1, loss_count stays at 2 */
+			tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_loss_prev(h), skb, n3);
+
+		return 0;
+	}
+
+	/*
+	 * The remaining case: S3 is not a successor of S0.
+	 * Sequence order is S0, S3, S1, S2; reorder to insert between S0 and S1
+	 */
+	tfrc_rx_hist_swap(&TFRC_RX_HIST_ENTRY(h, 0), &TFRC_RX_HIST_ENTRY(h, 3));
+	h->loss_start = tfrc_rx_hist_index(h, 3);
+	tfrc_rx_hist_entry_from_skb(TFRC_RX_HIST_ENTRY(h, 1), skb, n3);
+	h->loss_count = 3;
+
+	return 1;
+}
+
+/* return the signed modulo-2^48 sequence number distance from entry e1 to e2 */
+static s64 tfrc_rx_hist_delta_seqno(struct tfrc_rx_hist *h, u8 e1, u8 e2)
+{
+	DCCP_BUG_ON(e1 > h->loss_count || e2 > h->loss_count);
+
+	return dccp_delta_seqno(TFRC_RX_HIST_ENTRY(h, e1)->tfrchrx_seqno,
+				TFRC_RX_HIST_ENTRY(h, e2)->tfrchrx_seqno);
+}
+
+/* recycle RX history records to continue loss detection if necessary */
+static void __three_after_loss(struct tfrc_rx_hist *h)
+{
+	/*
+	 * The distance between S0 and S1 is always greater than 1 and the NDP
+	 * count of S1 is smaller than this distance. Otherwise there would
+	 * have been no loss. Hence it is only necessary to see whether there
+	 * are further missing data packets between S1/S2 and S2/S3.
+	 */
+	int d2 = tfrc_rx_hist_delta_seqno(h, 1, 2),
+	    d3 = tfrc_rx_hist_delta_seqno(h, 2, 3),
+	    n2 = TFRC_RX_HIST_ENTRY(h, 2)->tfrchrx_ndp,
+	    n3 = TFRC_RX_HIST_ENTRY(h, 3)->tfrchrx_ndp;
+
+	if (d2 = 1 || n2 >= d2) {	/* S2 is successor to S1 */
+
+		if (d3 = 1 || n3 >= d3) {
+			/* S3 is successor of S2: entire hole is filled */
+			h->loss_start = tfrc_rx_hist_index(h, 3);
+			h->loss_count = 0;
+		} else {
+			/* gap between S2 and S3 */
+			h->loss_start = tfrc_rx_hist_index(h, 2);
+			h->loss_count = 1;
+		}
+
+	} else {			/* gap between S1 and S2 */
+		h->loss_start = tfrc_rx_hist_index(h, 1);
+		h->loss_count = 2;
+	}
+}
+
+/**
+ *  tfrc_rx_handle_loss  -  Loss detection and further processing
+ *  @h:		    The non-empty RX history object
+ *  @lh:	    Loss Intervals database to update
+ *  @skb:	    Currently received packet
+ *  @ndp:	    The NDP count belonging to @skb
+ *  @calc_first_li: Caller-dependent computation of first loss interval in @lh
+ *  @sk:	    Used by @calc_first_li (see tfrc_lh_interval_add)
+ *  Chooses action according to pending loss, updates LI database when a new
+ *  loss was detected, and does required post-processing. Returns 1 when caller
+ *  should send feedback, 0 otherwise.
+ */
+int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
+			struct tfrc_loss_hist *lh,
+			struct sk_buff *skb, u32 ndp,
+			u32 (*calc_first_li)(struct sock *), struct sock *sk)
+{
+	int is_new_loss = 0;
+
+	if (h->loss_count = 1) {
+		__one_after_loss(h, skb, ndp);
+	} else if (h->loss_count != 2) {
+		DCCP_BUG("invalid loss_count %d", h->loss_count);
+	} else if (__two_after_loss(h, skb, ndp)) {
+		/*
+		 * Update Loss Interval database and recycle RX records
+		 */
+		is_new_loss = tfrc_lh_interval_add(lh, h, calc_first_li, sk);
+		__three_after_loss(h);
+	}
+	return is_new_loss;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
+
 int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
 {
 	int i;
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 6ea25cd..6df9582 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -36,10 +36,9 @@
 #ifndef _DCCP_PKT_HIST_
 #define _DCCP_PKT_HIST_
 
-#include <linux/ktime.h>
-#include <linux/types.h>
-
-struct sk_buff;
+#include <linux/list.h>
+#include <linux/slab.h>
+#include "tfrc.h"
 
 struct tfrc_tx_hist_entry;
 
@@ -122,6 +121,10 @@ extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 extern int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
 extern int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
 					   const struct sk_buff *skb, u32 ndp);
+struct tfrc_loss_hist;
+extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
+				struct sk_buff *skb, u32 ndp,
+				u32 (*first_li)(struct sock *), struct sock *);
 extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
 				   const struct sk_buff *skb);
 extern int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h);
diff --git a/net/dccp/ccids/lib/tfrc.h b/net/dccp/ccids/lib/tfrc.h
index ab8848c..1fb1187 100644
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -17,6 +17,9 @@
 #include <linux/types.h>
 #include <asm/div64.h>
 #include "../../dccp.h"
+/* internal includes that this module exports: */
+#include "loss_interval.h"
+#include "packet_history.h"
 
 #ifdef CONFIG_IP_DCCP_TFRC_DEBUG
 extern int tfrc_debug;
