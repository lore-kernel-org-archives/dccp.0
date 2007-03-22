From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 22 Mar 2007 04:09:14 +0000
Subject: [PATCH 7/9] DCCP: Rename functions
Message-Id: <200703221609.15035.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This renames functions and a variable after the moves.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index af6e7d6..bf7eb1d 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -844,7 +844,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk);
+		dccp_li_update_li(sk);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 9825a8a..9e7fbed 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -19,11 +19,11 @@
 #include "packet_history.h"
 #include "tfrc.h"
 
-static struct dccp_li_hist *ccid3_li_hist;
+static struct dccp_li_hist *dccp_li_hist;
 
 static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(void)
 {
-	return kmem_cache_alloc(ccid3_li_hist->dccplih_slab, GFP_ATOMIC);
+	return kmem_cache_alloc(dccp_li_hist->dccplih_slab, GFP_ATOMIC);
 }
 
 static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
@@ -81,7 +81,7 @@ void dccp_li_hist_purge(struct list_head *list)
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, entry);
+		kmem_cache_free(dccp_li_hist->dccplih_slab, entry);
 	}
 }
 
@@ -159,7 +159,7 @@ static int dccp_li_hist_interval_new(struct list_head *list,
  *
  * returns estimated loss interval in usecs */
 
-static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
+static u32 dccp_li_calc_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
@@ -256,7 +256,7 @@ found:
 		return 1000000 / p;
 }
 
-void ccid3_hc_rx_update_li(struct sock *sk)
+void dccp_li_update_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
@@ -271,7 +271,7 @@ void ccid3_hc_rx_update_li(struct sock *sk)
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
 		   struct dccp_li_hist_entry, dccplih_node);
-		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+		head->dccplih_interval = dccp_li_calc_first_li(sk);
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
@@ -296,7 +296,7 @@ void ccid3_hc_rx_update_li(struct sock *sk)
 
 		tail = hcrx->ccid3hcrx_li_hist.prev;
 		list_del(tail);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
+		kmem_cache_free(dccp_li_hist->dccplih_slab, tail);
 
 		/* Create the newest interval */
 		entry->dccplih_seqno = seq_nonloss;
@@ -304,14 +304,14 @@ void ccid3_hc_rx_update_li(struct sock *sk)
 		entry->dccplih_win_count = win_nonloss;
 	}
 }
-EXPORT_SYMBOL_GPL(ccid3_hc_rx_update_li);
+EXPORT_SYMBOL_GPL(dccp_li_update_li);
 
 static __init int li_module_init(void)
 {
 	int rc = -ENOBUFS;
 
-	ccid3_li_hist = dccp_li_hist_new("ccid3");
-	if (ccid3_li_hist = NULL)
+	dccp_li_hist = dccp_li_hist_new("ccid3");
+	if (dccp_li_hist = NULL)
 		return rc;
 	else
 		return 0;
@@ -320,9 +320,9 @@ module_init(li_module_init);
 
 static __exit void li_module_exit(void)
 {
-	if (ccid3_li_hist != NULL) {
-		dccp_li_hist_delete(ccid3_li_hist);
-		ccid3_li_hist = NULL;
+	if (dccp_li_hist != NULL) {
+		dccp_li_hist_delete(dccp_li_hist);
+		dccp_li_hist = NULL;
 	}
 }
 module_exit(li_module_exit);
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 757c45c..cecfe3e 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -34,5 +34,5 @@ extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-void ccid3_hc_rx_update_li(struct sock *sk);
+void dccp_li_update_li(struct sock *sk);
 #endif /* _DCCP_LI_HIST_ */
