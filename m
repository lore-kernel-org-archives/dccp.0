From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 21 Dec 2006 20:24:33 +0000
Subject: [PATCH 1/1] DCCP: Reorganise loss interval code
Message-Id: <200612220924.34663.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is shifting around loss interval code to places it makes more sense.

No change in logic at all. A couple of functions/variables have been
renamed though.

Applies on top of my previous patches. (So I have to convince Gerrit of the
merits of them first!)

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index cfc0296..06de416 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1,7 +1,7 @@
 /*
  *  net/dccp/ccids/ccid3.c
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *
  *  An implementation of the DCCP protocol
@@ -42,8 +42,6 @@
 
 static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
-static struct dccp_li_hist *ccid3_li_hist;
-
 /*
  *	Transmitter Half-Connection Routines
  */
@@ -835,174 +833,6 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-/* calculate first loss interval
- *
- * returns estimated loss interval in usecs */
-
-static u32 ccid3_hc_rx_calc_first_li(struct sock *sk, struct sk_buff *skb)
-{
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
-	u32 x_recv, p;
-	suseconds_t rtt, delta;
-	struct timeval tstamp = { 0, };
-	int interval = 0;
-	int win_count = 0;
-	int step = 0;
-	u64 fval;
-
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
-	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
-	DCCP_BUG_ON(delta <= 0);
-
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
-	if (x_recv = 0) {		/* would also trigger divide-by-zero */
-		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
-			DCCP_BUG("stored value of X_recv is zero");
-			return ~0;
-		}
-	}
-
-	fval = scaled_div(hcrx->ccid3hcrx_s, rtt);
-	fval = scaled_div32(fval, x_recv);
-	p = tfrc_calc_x_reverse_lookup(fval);
-
-	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
-		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
-
-	if (p = 0) {
-		DCCP_WARN("p=0, fval = %llu\n", fval);
-		return ~0;
-	} else {
-		u32 new_interval = 1000000 / p;
-		u64 recalc_interval;
-
-		if (new_interval < 150)
-			recalc_interval = new_interval + 1;
-		else
-			recalc_interval = (new_interval *
-			(DCCP_RECALC_LOSS_FACTOR+1)) / DCCP_RECALC_LOSS_FACTOR;
-		hcrx->ccid3hcrx_seq_recalc_loss = dccp_hdr_seq(skb);
-		add48(&hcrx->ccid3hcrx_seq_recalc_loss, recalc_interval);
-		ccid3_pr_debug("%s(%p), interval=%u, recalc_interval=%llu, "
-		   "seqno=%llu recalc_loss=%llu\n", dccp_role(sk), sk,
-		   new_interval, recalc_interval, dccp_hdr_seq(skb),
-		   hcrx->ccid3hcrx_seq_recalc_loss);
-
-		return new_interval;
-	}
-}
-
-static void ccid3_hc_rx_update_li(struct sock *sk, struct sk_buff *skb,
-                                  u64 seq_loss, u8 win_loss)
-{
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_li_hist_entry *head;
-	u64 seq_temp;
-
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
-			return;
-
-		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
-		   struct dccp_li_hist_entry, dccplih_node);
-		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk, skb);
-	} else {
-		struct dccp_li_hist_entry *entry;
-		struct list_head *tail;
-
-		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
-		   struct dccp_li_hist_entry, dccplih_node);
-		/* FIXME win count check removed as was wrong */
-		/* should make this check with receive history */
-		/* and compare there as per section 10.2 of RFC4342 */
-
-		/* new loss event detected */
-		/* calculate last interval length */
-		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
-
-		if (entry = NULL) {
-			DCCP_BUG("out of memory - can not allocate entry");
-			return;
-		}
-
-		list_add(&entry->dccplih_node, &hcrx->ccid3hcrx_li_hist);
-
-		tail = hcrx->ccid3hcrx_li_hist.prev;
-		list_del(tail);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
-
-		/* Create the newest interval */
-		entry->dccplih_seqno = seq_loss;
-		entry->dccplih_interval = seq_temp;
-		entry->dccplih_win_count = win_loss;
-		ccid3_pr_debug("adding node seqno=%llu, interval=%u\n",
-		   (u64)entry->dccplih_seqno, entry->dccplih_interval);
-	}
-}
-
 static int ccid3_hc_rx_detect_loss(struct sock *sk, struct sk_buff *skb,
                                     struct dccp_rx_hist_entry *packet)
 {
@@ -1028,7 +858,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk, struct sk_buff *skb,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk, skb, hcrx->ccid3hcrx_seqno_nonloss,
+		dccp_li_update_li(sk, skb, hcrx->ccid3hcrx_seqno_nonloss,
 		   hcrx->ccid3hcrx_ccval_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
@@ -1212,7 +1042,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
-	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
+	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1298,19 +1128,12 @@ static __init int ccid3_module_init(void)
 	if (ccid3_tx_hist = NULL)
 		goto out_free_rx;
 
-	ccid3_li_hist = dccp_li_hist_new("ccid3");
-	if (ccid3_li_hist = NULL)
-		goto out_free_tx;
-
 	rc = ccid_register(&ccid3);
 	if (rc != 0)
-		goto out_free_loss_interval_history;
+		goto out_free_tx;
 out:
 	return rc;
 
-out_free_loss_interval_history:
-	dccp_li_hist_delete(ccid3_li_hist);
-	ccid3_li_hist = NULL;
 out_free_tx:
 	dccp_tx_hist_delete(ccid3_tx_hist);
 	ccid3_tx_hist = NULL;
@@ -1333,10 +1156,6 @@ static __exit void ccid3_module_exit(void)
 		dccp_rx_hist_delete(ccid3_rx_hist);
 		ccid3_rx_hist = NULL;
 	}
-	if (ccid3_li_hist != NULL) {
-		dccp_li_hist_delete(ccid3_li_hist);
-		ccid3_li_hist = NULL;
-	}
 }
 module_exit(ccid3_module_exit);
 
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index cd03ae0..e298588 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -1,7 +1,7 @@
 /*
  *  net/dccp/ccids/lib/loss_interval.c
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
  *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
@@ -16,8 +16,19 @@
 #include "../../dccp.h"
 #include "../ccid3.h"
 #include "loss_interval.h"
+#include "packet_history.h"
+#include "tfrc.h"
 
-struct dccp_li_hist *dccp_li_hist_new(const char *name)
+static struct dccp_li_hist *dccp_li_hist;
+
+static inline struct dccp_li_hist_entry *
+		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
+				       const gfp_t prio)
+{
+	return kmem_cache_alloc(hist->dccplih_slab, prio);
+}
+
+static struct dccp_li_hist *dccp_li_hist_new(const char *name)
 {
 	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
 	static const char dccp_li_hist_mask[] = "li_hist_%s";
@@ -48,9 +59,7 @@ out_free_hist:
 	goto out;
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_new);
-
-void dccp_li_hist_delete(struct dccp_li_hist *hist)
+static void dccp_li_hist_delete(struct dccp_li_hist *hist)
 {
 	const char* name = kmem_cache_name(hist->dccplih_slab);
 
@@ -59,15 +68,13 @@ void dccp_li_hist_delete(struct dccp_li_hist *hist)
 	kfree(hist);
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_delete);
-
-void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
+void dccp_li_hist_purge(struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(hist->dccplih_slab, entry);
+		kmem_cache_free(dccp_li_hist->dccplih_slab, entry);
 	}
 }
 
@@ -197,7 +204,7 @@ u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx, struct sk_buff *skb)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
+static int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
    struct list_head *list, const u64 seq_loss, const u8 win_loss)
 {
 	struct dccp_li_hist_entry *entry;
@@ -206,7 +213,7 @@ int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
 		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
 		if (entry = NULL) {
-			dccp_li_hist_purge(hist, list);
+			dccp_li_hist_purge(list);
 			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
@@ -219,4 +226,193 @@ int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 	return 1;
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
+/* calculate first loss interval
+ *
+ * returns estimated loss interval in usecs */
+
+static u32 dccp_li_calc_first_li(struct sock *sk, struct sk_buff *skb)
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
+	dccp_pr_debug("%s(%p), approximated RTT to %dus\n",
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
+	dccp_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
+		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
+
+	if (p = 0) {
+		DCCP_WARN("p=0, fval = %llu\n", fval);
+		return ~0;
+	} else {
+		u32 new_interval = 1000000 / p;
+		u64 recalc_interval;
+
+		if (new_interval < 150)
+			recalc_interval = new_interval + 1;
+		else
+			recalc_interval = (new_interval *
+			(DCCP_RECALC_LOSS_FACTOR+1)) / DCCP_RECALC_LOSS_FACTOR;
+		hcrx->ccid3hcrx_seq_recalc_loss = dccp_hdr_seq(skb);
+		add48(&hcrx->ccid3hcrx_seq_recalc_loss, recalc_interval);
+		dccp_pr_debug("%s(%p), interval=%u, recalc_interval=%llu, "
+		   "seqno=%llu recalc_loss=%llu\n", dccp_role(sk), sk,
+		   new_interval, recalc_interval, dccp_hdr_seq(skb),
+		   hcrx->ccid3hcrx_seq_recalc_loss);
+
+		return new_interval;
+	}
+}
+
+void dccp_li_update_li(struct sock *sk, struct sk_buff *skb,
+                                  u64 seq_loss, u8 win_loss)
+{
+	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	struct dccp_li_hist_entry *head;
+	u64 seq_temp;
+
+	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
+		if (!dccp_li_hist_interval_new(dccp_li_hist,
+		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
+			return;
+
+		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
+		   struct dccp_li_hist_entry, dccplih_node);
+		head->dccplih_interval = dccp_li_calc_first_li(sk, skb);
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
+		entry = dccp_li_hist_entry_new(dccp_li_hist, GFP_ATOMIC);
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
+		kmem_cache_free(dccp_li_hist->dccplih_slab, tail);
+
+		/* Create the newest interval */
+		entry->dccplih_seqno = seq_loss;
+		entry->dccplih_interval = seq_temp;
+		entry->dccplih_win_count = win_loss;
+		dccp_pr_debug("adding node seqno=%llu, interval=%u\n",
+		   (u64)entry->dccplih_seqno, entry->dccplih_interval);
+	}
+}
+
+EXPORT_SYMBOL_GPL(dccp_li_update_li);
+
+static __init int li_module_init(void)
+{
+	int rc = -ENOBUFS;
+
+	dccp_li_hist = dccp_li_hist_new("dccp_li");
+	if (dccp_li_hist = NULL)
+		return rc;
+	else
+		return 0;
+}
+module_init(li_module_init);
+
+static __exit void li_module_exit(void)
+{
+	if (dccp_li_hist != NULL) {
+		dccp_li_hist_delete(dccp_li_hist);
+		dccp_li_hist = NULL;
+	}
+}
+module_exit(li_module_exit);
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 6fed81b..98bd085 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -3,8 +3,8 @@
 /*
  *  net/dccp/ccids/lib/loss_interval.h
  *
- *  Copyright (c) 2005 The University of Waikato, Hamilton, New Zealand.
- *  Copyright (c) 2005 Ian McDonald <ian.mcdonald@jandi.co.nz>
+ *  Copyright (c) 2005-6 The University of Waikato, Hamilton, New Zealand.
+ *  Copyright (c) 2005-6 Ian McDonald <ian.mcdonald@jandi.co.nz>
  *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
  *
  *  This program is free software; you can redistribute it and/or modify it
@@ -23,9 +23,6 @@ struct dccp_li_hist {
 	struct kmem_cache *dccplih_slab;
 };
 
-extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
-extern void dccp_li_hist_delete(struct dccp_li_hist *hist);
-
 struct dccp_li_hist_entry {
 	struct list_head dccplih_node;
 	u64		 dccplih_seqno:48,
@@ -33,26 +30,11 @@ struct dccp_li_hist_entry {
 	u32		 dccplih_interval;
 };
 
-static inline struct dccp_li_hist_entry *
-		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
-				       const gfp_t prio)
-{
-	return kmem_cache_alloc(hist->dccplih_slab, prio);
-}
-
-static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
-					     struct dccp_li_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccplih_slab, entry);
-}
-
-extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
-			       struct list_head *list);
+extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx,
    struct sk_buff *skb);
 
-extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-   struct list_head *list, const u64 seq_loss, const u8 win_loss);
+extern void dccp_li_update_li(struct sock *sk, struct sk_buff *skb,
+                                  u64 seq_loss, u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
