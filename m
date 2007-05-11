From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 11 May 2007 10:41:56 +0000
Subject: [PATCH 5/5] DCCP: Rename functions and variables
Message-Id: <200705112241.56541.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Renaming functions and variables now we've shifted them.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 2ef3bb4..c6c90d6 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -844,7 +844,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
+		dccp_li_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
 		   hcrx->ccid3hcrx_ccval_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 0ea3f81..0b106e8 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -19,7 +19,7 @@
 #include "loss_interval.h"
 #include "tfrc.h"
 
-static struct dccp_li_hist *ccid3_li_hist;
+static struct dccp_li_hist *dccp_li_hist;
 
 static inline struct dccp_li_hist_entry *
 		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
@@ -74,7 +74,7 @@ void dccp_li_hist_purge(struct list_head *list)
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, entry);
+		kmem_cache_free(dccp_li_hist->dccplih_slab, entry);
 	}
 }
 
@@ -152,7 +152,7 @@ static int dccp_li_hist_interval_new(struct dccp_li_hist 
*hist,
  *
  * returns estimated loss interval in usecs */
 
-static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
+static u32 dccp_li_calc_first_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
@@ -249,20 +249,20 @@ found:
 		return 1000000 / p;
 }
 
-void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
+void dccp_li_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		if (!dccp_li_hist_interval_new(ccid3_li_hist,
+		if (!dccp_li_hist_interval_new(dccp_li_hist,
 		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
 			return;
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
 		   struct dccp_li_hist_entry, dccplih_node);
-		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+		head->dccplih_interval = dccp_li_calc_first_li(sk);
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
@@ -276,7 +276,7 @@ void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, 
u8 win_loss)
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new(dccp_li_hist, GFP_ATOMIC);
 
 		if (entry = NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
@@ -287,7 +287,7 @@ void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, 
u8 win_loss)
 
 		tail = hcrx->ccid3hcrx_li_hist.prev;
 		list_del(tail);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
+		kmem_cache_free(dccp_li_hist->dccplih_slab, tail);
 
 		/* Create the newest interval */
 		entry->dccplih_seqno = seq_loss;
@@ -296,20 +296,20 @@ void ccid3_hc_rx_update_li(struct sock *sk, u64 
seq_loss, u8 win_loss)
 	}
 }
 
-EXPORT_SYMBOL(ccid3_hc_rx_update_li);
+EXPORT_SYMBOL(dccp_li_update_li);
 
 static __init int li_module_init(void)
 {
-	ccid3_li_hist = dccp_li_hist_new("ccid3");
-	return ccid3_li_hist = NULL ? -ENOBUFS : 0;
+	dccp_li_hist = dccp_li_hist_new("ccid3");
+	return dccp_li_hist = NULL ? -ENOBUFS : 0;
 }
 module_init(li_module_init);
 
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
diff --git a/net/dccp/ccids/lib/loss_interval.h 
b/net/dccp/ccids/lib/loss_interval.h
index 7fca7e1..1407736 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -34,5 +34,5 @@ extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-extern void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 
win_loss);
+extern void dccp_li_update_li(struct sock *sk, u64 seq_loss, u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
