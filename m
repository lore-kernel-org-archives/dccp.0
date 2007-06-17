From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 11:23:21 +0000
Subject: [PATCH 1/1]: Revert code shifts
Message-Id: <200706171223.21566@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Revert code shifts

This reverts those recent changes in the CCID3 codebase
that overlap 100% with code I have developed independently.

All functions and each line in this code set is either
rewritten or removed in my patch set, so this patch
reflects all the code overlap, nothing more.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |  175 +++++++++++++++++++++++++--
 net/dccp/ccids/lib/loss_interval.c |  238 ++++++-------------------------------
 net/dccp/ccids/lib/loss_interval.h |   42 +++++-
 3 files changed, 242 insertions(+), 213 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,6 +49,7 @@ static int ccid3_debug;
 
 static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
+static struct dccp_li_hist *ccid3_li_hist;
 
 /*
  *	Transmitter Half-Connection Routines
@@ -811,6 +812,154 @@ static int ccid3_hc_rx_insert_options(st
 	return 0;
 }
 
+/* calculate first loss interval
+ *
+ * returns estimated loss interval in usecs */
+
+static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
+{
+	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
+	u32 x_recv, p;
+	suseconds_t rtt, delta;
+	struct timeval tstamp = { 0, };
+	int interval = 0;
+	int win_count = 0;
+	int step = 0;
+	u64 fval;
+
+	list_for_each_entry_safe(entry, next, &hcrx->ccid3hcrx_hist,
+				 dccphrx_node) {
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
+	ccid3_pr_debug("%s(%p), approximated RTT to %dus\n",
+		       dccp_role(sk), sk, (int)rtt);
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
+	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
+	DCCP_BUG_ON(delta <= 0);
+
+	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	if (x_recv = 0) {		/* would also trigger divide-by-zero */
+		DCCP_WARN("X_recv=0\n");
+		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+			DCCP_BUG("stored value of X_recv is zero");
+			return ~0;
+		}
+	}
+
+	fval = scaled_div(hcrx->ccid3hcrx_s, rtt);
+	fval = scaled_div32(fval, x_recv);
+	p = tfrc_calc_x_reverse_lookup(fval);
+
+	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
+		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
+
+	if (p = 0)
+		return ~0;
+	else
+		return 1000000 / p;
+}
+
+static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
+{
+	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct dccp_li_hist_entry *head;
+	u64 seq_temp;
+
+	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
+		if (!dccp_li_hist_interval_new(ccid3_li_hist,
+		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
+			return;
+
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
+		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+	} else {
+		struct dccp_li_hist_entry *entry;
+		struct list_head *tail;
+
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
+		/* FIXME win count check removed as was wrong */
+		/* should make this check with receive history */
+		/* and compare there as per section 10.2 of RFC4342 */
+
+		/* new loss event detected */
+		/* calculate last interval length */
+		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
+		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
+
+		if (entry = NULL) {
+			DCCP_BUG("out of memory - can not allocate entry");
+			return;
+		}
+
+		list_add(&entry->dccplih_node, &hcrx->ccid3hcrx_li_hist);
+
+		tail = hcrx->ccid3hcrx_li_hist.prev;
+		list_del(tail);
+		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
+
+		/* Create the newest interval */
+		entry->dccplih_seqno = seq_loss;
+		entry->dccplih_interval = seq_temp;
+		entry->dccplih_win_count = win_loss;
+	}
+}
+
 static int ccid3_hc_rx_detect_loss(struct sock *sk,
 				    struct dccp_rx_hist_entry *packet)
 {
@@ -836,15 +985,8 @@ static int ccid3_hc_rx_detect_loss(struc
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		dccp_li_update_li(sk,
-				  &hcrx->ccid3hcrx_li_hist,
-				  &hcrx->ccid3hcrx_hist,
-				  &hcrx->ccid3hcrx_tstamp_last_feedback,
-				  hcrx->ccid3hcrx_s,
-				  hcrx->ccid3hcrx_bytes_recv,
-				  hcrx->ccid3hcrx_x_recv,
-				  hcrx->ccid3hcrx_seqno_nonloss,
-				  hcrx->ccid3hcrx_ccval_nonloss);
+		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
+		   hcrx->ccid3hcrx_ccval_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
@@ -1003,7 +1145,7 @@ static void ccid3_hc_rx_exit(struct sock
 	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
-	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
+	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1087,12 +1229,19 @@ static __init int ccid3_module_init(void
 	if (ccid3_tx_hist = NULL)
 		goto out_free_rx;
 
+	ccid3_li_hist = dccp_li_hist_new("ccid3");
+	if (ccid3_li_hist = NULL)
+		goto out_free_tx;
+
 	rc = ccid_register(&ccid3);
 	if (rc != 0)
-		goto out_free_tx;
+		goto out_free_loss_interval_history;
 out:
 	return rc;
 
+out_free_loss_interval_history:
+	dccp_li_hist_delete(ccid3_li_hist);
+	ccid3_li_hist = NULL;
 out_free_tx:
 	dccp_tx_hist_delete(ccid3_tx_hist);
 	ccid3_tx_hist = NULL;
@@ -1115,6 +1264,10 @@ static __exit void ccid3_module_exit(voi
 		dccp_rx_hist_delete(ccid3_rx_hist);
 		ccid3_rx_hist = NULL;
 	}
+	if (ccid3_li_hist != NULL) {
+		dccp_li_hist_delete(ccid3_li_hist);
+		ccid3_li_hist = NULL;
+	}
 }
 module_exit(ccid3_module_exit);
 
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -15,38 +15,58 @@
 #include <net/sock.h>
 #include "../../dccp.h"
 #include "loss_interval.h"
-#include "packet_history.h"
-#include "tfrc.h"
 
-#define DCCP_LI_HIST_IVAL_F_LENGTH  8
+struct dccp_li_hist *dccp_li_hist_new(const char *name)
+{
+	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
+	static const char dccp_li_hist_mask[] = "li_hist_%s";
+	char *slab_name;
 
-struct dccp_li_hist_entry {
-	struct list_head dccplih_node;
-	u64		 dccplih_seqno:48,
-			 dccplih_win_count:4;
-	u32		 dccplih_interval;
-};
+	if (hist = NULL)
+		goto out;
 
-struct kmem_cache *dccp_li_cachep __read_mostly;
+	slab_name = kmalloc(strlen(name) + sizeof(dccp_li_hist_mask) - 1,
+			    GFP_ATOMIC);
+	if (slab_name = NULL)
+		goto out_free_hist;
 
-static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
-{
-	return kmem_cache_alloc(dccp_li_cachep, prio);
+	sprintf(slab_name, dccp_li_hist_mask, name);
+	hist->dccplih_slab = kmem_cache_create(slab_name,
+					     sizeof(struct dccp_li_hist_entry),
+					       0, SLAB_HWCACHE_ALIGN,
+					       NULL, NULL);
+	if (hist->dccplih_slab = NULL)
+		goto out_free_slab_name;
+out:
+	return hist;
+out_free_slab_name:
+	kfree(slab_name);
+out_free_hist:
+	kfree(hist);
+	hist = NULL;
+	goto out;
 }
 
-static inline void dccp_li_hist_entry_delete(struct dccp_li_hist_entry *entry)
+EXPORT_SYMBOL_GPL(dccp_li_hist_new);
+
+void dccp_li_hist_delete(struct dccp_li_hist *hist)
 {
-	if (entry != NULL)
-		kmem_cache_free(dccp_li_cachep, entry);
+	const char* name = kmem_cache_name(hist->dccplih_slab);
+
+	kmem_cache_destroy(hist->dccplih_slab);
+	kfree(name);
+	kfree(hist);
 }
 
-void dccp_li_hist_purge(struct list_head *list)
+EXPORT_SYMBOL_GPL(dccp_li_hist_delete);
+
+void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(dccp_li_cachep, entry);
+		kmem_cache_free(hist->dccplih_slab, entry);
 	}
 }
 
@@ -98,16 +118,16 @@ u32 dccp_li_hist_calc_i_mean(struct list
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-static int dccp_li_hist_interval_new(struct list_head *list,
-				     const u64 seq_loss, const u8 win_loss)
+int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
+   struct list_head *list, const u64 seq_loss, const u8 win_loss)
 {
 	struct dccp_li_hist_entry *entry;
 	int i;
 
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
 		if (entry = NULL) {
-			dccp_li_hist_purge(list);
+			dccp_li_hist_purge(hist, list);
 			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
@@ -120,176 +140,4 @@ static int dccp_li_hist_interval_new(str
 	return 1;
 }
 
-/* calculate first loss interval
- *
- * returns estimated loss interval in usecs */
-static u32 dccp_li_calc_first_li(struct sock *sk,
-				 struct list_head *hist_list,
-				 struct timeval *last_feedback,
-				 u16 s, u32 bytes_recv,
-				 u32 previous_x_recv)
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
-	dccp_pr_debug("%s(%p), approximated RTT to %dus\n",
-		      dccp_role(sk), sk, (int)rtt);
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
-	dccp_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
-		      "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
-
-	if (p = 0)
-		return ~0;
-	else
-		return 1000000 / p;
-}
-
-void dccp_li_update_li(struct sock *sk,
-		       struct list_head *li_hist_list,
-		       struct list_head *hist_list,
-		       struct timeval *last_feedback, u16 s, u32 bytes_recv,
-                       u32 previous_x_recv, u64 seq_loss, u8 win_loss)
-{
-	struct dccp_li_hist_entry *head;
-	u64 seq_temp;
-
-	if (list_empty(li_hist_list)) {
-		if (!dccp_li_hist_interval_new(li_hist_list, seq_loss,
-					       win_loss))
-			return;
-
-		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
-				  dccplih_node);
-		head->dccplih_interval = dccp_li_calc_first_li(sk, hist_list,
-							       last_feedback,
-							       s, bytes_recv,
-							       previous_x_recv);
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
-		entry = dccp_li_hist_entry_new(GFP_ATOMIC);
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
-		kmem_cache_free(dccp_li_cachep, tail);
-
-		/* Create the newest interval */
-		entry->dccplih_seqno = seq_loss;
-		entry->dccplih_interval = seq_temp;
-		entry->dccplih_win_count = win_loss;
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_li_update_li);
-
-static __init int dccp_li_init(void)
-{
-	dccp_li_cachep = kmem_cache_create("dccp_li_hist",
-					   sizeof(struct dccp_li_hist_entry),
-					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
-	return dccp_li_cachep = NULL ? -ENOBUFS : 0;
-}
-
-static __exit void dccp_li_exit(void)
-{
-	kmem_cache_destroy(dccp_li_cachep);
-}
-
-module_init(dccp_li_init);
-module_exit(dccp_li_exit);
+EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -14,16 +14,44 @@
  */
 
 #include <linux/list.h>
+#include <linux/slab.h>
 #include <linux/time.h>
 
-extern void dccp_li_hist_purge(struct list_head *list);
+#define DCCP_LI_HIST_IVAL_F_LENGTH  8
+
+struct dccp_li_hist {
+	struct kmem_cache *dccplih_slab;
+};
+
+extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
+extern void dccp_li_hist_delete(struct dccp_li_hist *hist);
+
+struct dccp_li_hist_entry {
+	struct list_head dccplih_node;
+	u64		 dccplih_seqno:48,
+			 dccplih_win_count:4;
+	u32		 dccplih_interval;
+};
+
+static inline struct dccp_li_hist_entry *
+		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
+				       const gfp_t prio)
+{
+	return kmem_cache_alloc(hist->dccplih_slab, prio);
+}
+
+static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
+					     struct dccp_li_hist_entry *entry)
+{
+	if (entry != NULL)
+		kmem_cache_free(hist->dccplih_slab, entry);
+}
+
+extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
+			       struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-extern void dccp_li_update_li(struct sock *sk,
-			      struct list_head *li_hist_list,
-			      struct list_head *hist_list,
-			      struct timeval *last_feedback, u16 s,
-			      u32 bytes_recv, u32 previous_x_recv,
-			      u64 seq_loss, u8 win_loss);
+extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
+   struct list_head *list, const u64 seq_loss, const u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
