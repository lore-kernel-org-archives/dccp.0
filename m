From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:41:09 +0000
Subject: [PATCH 06/10] [DCCP] loss_interval: Move ccid3_hc_rx_update_li to
Message-Id: <20070616034109.GL24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Renaming it to dccp_li_update_li.

Also based on previous work by Ian McDonald.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c             |  179 ++----------------------------------
 net/dccp/ccids/lib/loss_interval.c |  160 ++++++++++++++++++++++++++++++++
 net/dccp/ccids/lib/loss_interval.h |    7 ++
 3 files changed, 176 insertions(+), 170 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 52a71a9..9d2e2c1 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -819,167 +819,6 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-/* calculate first loss interval
- *
- * returns estimated loss interval in usecs */
-
-static u32 ccid3_hc_rx_calc_first_li(struct sock *sk,
-				     struct list_head *hist_list,
-				     struct timeval *last_feedback,
-				     u16 s, u32 bytes_recv,
-				     u32 previous_x_recv)
-{
-	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
-	u32 x_recv, p;
-	suseconds_t rtt, delta;
-	struct timeval tstamp = { 0, 0 };
-	int interval = 0;
-	int win_count = 0;
-	int step = 0;
-	u64 fval;
-
-	list_for_each_entry_safe(entry, next, hist_list, dccphrx_node) {
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
-	/*
-	 * Determine the length of the first loss interval via inverse lookup.
-	 * Assume that X_recv can be computed by the throughput equation
-	 *		    s
-	 *	X_recv = --------
-	 *		 R * fval
-	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
-	 */
-	if (rtt = 0) {			/* would result in divide-by-zero */
-		DCCP_WARN("RTT=0\n");
-		return ~0;
-	}
-
-	dccp_timestamp(sk, &tstamp);
-	delta = timeval_delta(&tstamp, last_feedback);
-	DCCP_BUG_ON(delta <= 0);
-
-	x_recv = scaled_div32(bytes_recv, delta);
-	if (x_recv = 0) {		/* would also trigger divide-by-zero */
-		DCCP_WARN("X_recv=0\n");
-		if (previous_x_recv = 0) {
-			DCCP_BUG("stored value of X_recv is zero");
-			return ~0;
-		}
-		x_recv = previous_x_recv;
-	}
-
-	fval = scaled_div(s, rtt);
-	fval = scaled_div32(fval, x_recv);
-	p = tfrc_calc_x_reverse_lookup(fval);
-
-	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
-		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
-
-	if (p = 0)
-		return ~0;
-	else
-		return 1000000 / p;
-}
-
-static void ccid3_hc_rx_update_li(struct sock *sk,
-				  struct dccp_li_hist *li_hist,
-				  struct list_head *li_hist_list,
-				  struct list_head *hist_list,
-				  struct timeval *last_feedback,
-				  u16 s, u32 bytes_recv,
-				  u32 previous_x_recv,
-				  u64 seq_loss, u8 win_loss)
-{
-	struct dccp_li_hist_entry *head;
-	u64 seq_temp;
-
-	if (list_empty(li_hist_list)) {
-		if (!dccp_li_hist_interval_new(li_hist, li_hist_list,
-					       seq_loss, win_loss))
-			return;
-
-		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
-				  dccplih_node);
-		head->dccplih_interval -				ccid3_hc_rx_calc_first_li(sk, hist_list,
-							  last_feedback, s,
-							  bytes_recv,
-							  previous_x_recv);
-	} else {
-		struct dccp_li_hist_entry *entry;
-		struct list_head *tail;
-
-		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
-				  dccplih_node);
-		/* FIXME win count check removed as was wrong */
-		/* should make this check with receive history */
-		/* and compare there as per section 10.2 of RFC4342 */
-
-		/* new loss event detected */
-		/* calculate last interval length */
-		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(li_hist, GFP_ATOMIC);
-
-		if (entry = NULL) {
-			DCCP_BUG("out of memory - can not allocate entry");
-			return;
-		}
-
-		list_add(&entry->dccplih_node, li_hist_list);
-
-		tail = li_hist_list->prev;
-		list_del(tail);
-		kmem_cache_free(li_hist->dccplih_slab, tail);
-
-		/* Create the newest interval */
-		entry->dccplih_seqno = seq_loss;
-		entry->dccplih_interval = seq_temp;
-		entry->dccplih_win_count = win_loss;
-	}
-}
-
 static int ccid3_hc_rx_detect_loss(struct sock *sk,
 				    struct dccp_rx_hist_entry *packet)
 {
@@ -1005,15 +844,15 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk, ccid3_li_hist,
-				      &hcrx->ccid3hcrx_li_hist,
-				      &hcrx->ccid3hcrx_hist,
-				      &hcrx->ccid3hcrx_tstamp_last_feedback,
-				      hcrx->ccid3hcrx_s,
-				      hcrx->ccid3hcrx_bytes_recv,
-				      hcrx->ccid3hcrx_x_recv,
-				      hcrx->ccid3hcrx_seqno_nonloss,
-				      hcrx->ccid3hcrx_ccval_nonloss);
+		dccp_li_update_li(sk, ccid3_li_hist,
+				  &hcrx->ccid3hcrx_li_hist,
+				  &hcrx->ccid3hcrx_hist,
+				  &hcrx->ccid3hcrx_tstamp_last_feedback,
+				  hcrx->ccid3hcrx_s,
+				  hcrx->ccid3hcrx_bytes_recv,
+				  hcrx->ccid3hcrx_x_recv,
+				  hcrx->ccid3hcrx_seqno_nonloss,
+				  hcrx->ccid3hcrx_ccval_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 3829afc..ee59fde 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -15,6 +15,8 @@
 #include <net/sock.h>
 #include "../../dccp.h"
 #include "loss_interval.h"
+#include "packet_history.h"
+#include "tfrc.h"
 
 struct dccp_li_hist *dccp_li_hist_new(const char *name)
 {
@@ -141,3 +143,161 @@ int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
+
+/* calculate first loss interval
+ *
+ * returns estimated loss interval in usecs */
+static u32 dccp_li_calc_first_li(struct sock *sk,
+				 struct list_head *hist_list,
+				 struct timeval *last_feedback,
+				 u16 s, u32 bytes_recv,
+				 u32 previous_x_recv)
+{
+	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
+	u32 x_recv, p;
+	suseconds_t rtt, delta;
+	struct timeval tstamp = { 0, 0 };
+	int interval = 0;
+	int win_count = 0;
+	int step = 0;
+	u64 fval;
+
+	list_for_each_entry_safe(entry, next, hist_list, dccphrx_node) {
+		if (dccp_rx_hist_entry_data_packet(entry)) {
+			tail = entry;
+
+			switch (step) {
+			case 0:
+				tstamp	  = entry->dccphrx_tstamp;
+				win_count = entry->dccphrx_ccval;
+				step = 1;
+				break;
+			case 1:
+				interval = win_count - entry->dccphrx_ccval;
+				if (interval < 0)
+					interval += TFRC_WIN_COUNT_LIMIT;
+				if (interval > 4)
+					goto found;
+				break;
+			}
+		}
+	}
+
+	if (unlikely(step = 0)) {
+		DCCP_WARN("%s(%p), packet history has no data packets!\n",
+			  dccp_role(sk), sk);
+		return ~0;
+	}
+
+	if (unlikely(interval = 0)) {
+		DCCP_WARN("%s(%p), Could not find a win_count interval > 0."
+			  "Defaulting to 1\n", dccp_role(sk), sk);
+		interval = 1;
+	}
+found:
+	if (!tail) {
+		DCCP_CRIT("tail is null\n");
+		return ~0;
+	}
+
+	delta = timeval_delta(&tstamp, &tail->dccphrx_tstamp);
+	DCCP_BUG_ON(delta < 0);
+
+	rtt = delta * 4 / interval;
+	dccp_pr_debug("%s(%p), approximated RTT to %dus\n",
+		      dccp_role(sk), sk, (int)rtt);
+
+	/*
+	 * Determine the length of the first loss interval via inverse lookup.
+	 * Assume that X_recv can be computed by the throughput equation
+	 *		    s
+	 *	X_recv = --------
+	 *		 R * fval
+	 * Find some p such that f(p) = fval; return 1/p [RFC 3448, 6.3.1].
+	 */
+	if (rtt = 0) {			/* would result in divide-by-zero */
+		DCCP_WARN("RTT=0\n");
+		return ~0;
+	}
+
+	dccp_timestamp(sk, &tstamp);
+	delta = timeval_delta(&tstamp, last_feedback);
+	DCCP_BUG_ON(delta <= 0);
+
+	x_recv = scaled_div32(bytes_recv, delta);
+	if (x_recv = 0) {		/* would also trigger divide-by-zero */
+		DCCP_WARN("X_recv=0\n");
+		if (previous_x_recv = 0) {
+			DCCP_BUG("stored value of X_recv is zero");
+			return ~0;
+		}
+		x_recv = previous_x_recv;
+	}
+
+	fval = scaled_div(s, rtt);
+	fval = scaled_div32(fval, x_recv);
+	p = tfrc_calc_x_reverse_lookup(fval);
+
+	dccp_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
+		      "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
+
+	if (p = 0)
+		return ~0;
+	else
+		return 1000000 / p;
+}
+
+void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
+		       struct list_head *li_hist_list,
+		       struct list_head *hist_list,
+		       struct timeval *last_feedback, u16 s, u32 bytes_recv,
+                       u32 previous_x_recv, u64 seq_loss, u8 win_loss)
+{
+	struct dccp_li_hist_entry *head;
+	u64 seq_temp;
+
+	if (list_empty(li_hist_list)) {
+		if (!dccp_li_hist_interval_new(li_hist, li_hist_list,
+					       seq_loss, win_loss))
+			return;
+
+		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
+				  dccplih_node);
+		head->dccplih_interval = dccp_li_calc_first_li(sk, hist_list,
+							       last_feedback,
+							       s, bytes_recv,
+							       previous_x_recv);
+	} else {
+		struct dccp_li_hist_entry *entry;
+		struct list_head *tail;
+
+		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
+				  dccplih_node);
+		/* FIXME win count check removed as was wrong */
+		/* should make this check with receive history */
+		/* and compare there as per section 10.2 of RFC4342 */
+
+		/* new loss event detected */
+		/* calculate last interval length */
+		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
+		entry = dccp_li_hist_entry_new(li_hist, GFP_ATOMIC);
+
+		if (entry = NULL) {
+			DCCP_BUG("out of memory - can not allocate entry");
+			return;
+		}
+
+		list_add(&entry->dccplih_node, li_hist_list);
+
+		tail = li_hist_list->prev;
+		list_del(tail);
+		kmem_cache_free(li_hist->dccplih_slab, tail);
+
+		/* Create the newest interval */
+		entry->dccplih_seqno = seq_loss;
+		entry->dccplih_interval = seq_temp;
+		entry->dccplih_win_count = win_loss;
+	}
+}
+
+EXPORT_SYMBOL_GPL(dccp_li_update_li);
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 1e48fe3..17f173a 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -54,4 +54,11 @@ extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
 extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
    struct list_head *list, const u64 seq_loss, const u8 win_loss);
+
+extern void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
+			      struct list_head *li_hist_list,
+			      struct list_head *hist_list,
+			      struct timeval *last_feedback, u16 s,
+			      u32 bytes_recv, u32 previous_x_recv,
+			      u64 seq_loss, u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
-- 
1.5.0.6

