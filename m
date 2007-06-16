From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:41:52 +0000
Subject: [PATCH 09/10] loss_interval: Nuke dccp_li_hist
Message-Id: <20070616034152.GO24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

It had just a slab cache, so, for the sake of simplicity just make
dccp_trfc_lib module init routine create the slab cache, no need for users of
the lib to create a private loss_interval object.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c             |   18 +------
 net/dccp/ccids/lib/loss_interval.c |   92 ++++++++++++------------------------
 net/dccp/ccids/lib/loss_interval.h |   12 +----
 3 files changed, 36 insertions(+), 86 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 9d2e2c1..407f10c 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,7 +49,6 @@ static int ccid3_debug;
 
 static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
-static struct dccp_li_hist *ccid3_li_hist;
 
 /*
  *	Transmitter Half-Connection Routines
@@ -844,7 +843,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		dccp_li_update_li(sk, ccid3_li_hist,
+		dccp_li_update_li(sk,
 				  &hcrx->ccid3hcrx_li_hist,
 				  &hcrx->ccid3hcrx_hist,
 				  &hcrx->ccid3hcrx_tstamp_last_feedback,
@@ -1011,7 +1010,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
-	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
+	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1095,19 +1094,12 @@ static __init int ccid3_module_init(void)
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
@@ -1130,10 +1122,6 @@ static __exit void ccid3_module_exit(void)
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
index 28eac9b..e6b1f0c 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -18,71 +18,26 @@
 #include "packet_history.h"
 #include "tfrc.h"
 
-struct dccp_li_hist *dccp_li_hist_new(const char *name)
-{
-	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
-	static const char dccp_li_hist_mask[] = "li_hist_%s";
-	char *slab_name;
-
-	if (hist = NULL)
-		goto out;
-
-	slab_name = kmalloc(strlen(name) + sizeof(dccp_li_hist_mask) - 1,
-			    GFP_ATOMIC);
-	if (slab_name = NULL)
-		goto out_free_hist;
-
-	sprintf(slab_name, dccp_li_hist_mask, name);
-	hist->dccplih_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_li_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL, NULL);
-	if (hist->dccplih_slab = NULL)
-		goto out_free_slab_name;
-out:
-	return hist;
-out_free_slab_name:
-	kfree(slab_name);
-out_free_hist:
-	kfree(hist);
-	hist = NULL;
-	goto out;
-}
-
-EXPORT_SYMBOL_GPL(dccp_li_hist_new);
-
-void dccp_li_hist_delete(struct dccp_li_hist *hist)
-{
-	const char* name = kmem_cache_name(hist->dccplih_slab);
-
-	kmem_cache_destroy(hist->dccplih_slab);
-	kfree(name);
-	kfree(hist);
-}
-
-EXPORT_SYMBOL_GPL(dccp_li_hist_delete);
+struct kmem_cache *dccp_li_cachep __read_mostly;
 
-static inline struct dccp_li_hist_entry *
-		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
-				       const gfp_t prio)
+static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
 {
-	return kmem_cache_alloc(hist->dccplih_slab, prio);
+	return kmem_cache_alloc(dccp_li_cachep, prio);
 }
 
-static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
-					     struct dccp_li_hist_entry *entry)
+static inline void dccp_li_hist_entry_delete(struct dccp_li_hist_entry *entry)
 {
 	if (entry != NULL)
-		kmem_cache_free(hist->dccplih_slab, entry);
+		kmem_cache_free(dccp_li_cachep, entry);
 }
 
-void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
+void dccp_li_hist_purge(struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(hist->dccplih_slab, entry);
+		kmem_cache_free(dccp_li_cachep, entry);
 	}
 }
 
@@ -134,17 +89,16 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-static int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-				     struct list_head *list,
+static int dccp_li_hist_interval_new(struct list_head *list,
 				     const u64 seq_loss, const u8 win_loss)
 {
 	struct dccp_li_hist_entry *entry;
 	int i;
 
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new(GFP_ATOMIC);
 		if (entry = NULL) {
-			dccp_li_hist_purge(hist, list);
+			dccp_li_hist_purge(list);
 			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
@@ -260,7 +214,7 @@ found:
 		return 1000000 / p;
 }
 
-void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
+void dccp_li_update_li(struct sock *sk,
 		       struct list_head *li_hist_list,
 		       struct list_head *hist_list,
 		       struct timeval *last_feedback, u16 s, u32 bytes_recv,
@@ -270,8 +224,8 @@ void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
 	u64 seq_temp;
 
 	if (list_empty(li_hist_list)) {
-		if (!dccp_li_hist_interval_new(li_hist, li_hist_list,
-					       seq_loss, win_loss))
+		if (!dccp_li_hist_interval_new(li_hist_list, seq_loss,
+					       win_loss))
 			return;
 
 		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
@@ -293,7 +247,7 @@ void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(li_hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new(GFP_ATOMIC);
 
 		if (entry = NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
@@ -304,7 +258,7 @@ void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
 
 		tail = li_hist_list->prev;
 		list_del(tail);
-		kmem_cache_free(li_hist->dccplih_slab, tail);
+		kmem_cache_free(dccp_li_cachep, tail);
 
 		/* Create the newest interval */
 		entry->dccplih_seqno = seq_loss;
@@ -314,3 +268,19 @@ void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_update_li);
+
+static __init int dccp_li_init(void)
+{
+	dccp_li_cachep = kmem_cache_create("dccp_li_hist",
+					   sizeof(struct dccp_li_hist_entry),
+					   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+	return dccp_li_cachep = NULL ? -ENOBUFS : 0;
+}
+
+static __exit void dccp_li_exit(void)
+{
+	kmem_cache_destroy(dccp_li_cachep);
+}
+
+module_init(dccp_li_init);
+module_exit(dccp_li_exit);
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 8d3c9bf..f35c111 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -19,13 +19,6 @@
 
 #define DCCP_LI_HIST_IVAL_F_LENGTH  8
 
-struct dccp_li_hist {
-	struct kmem_cache *dccplih_slab;
-};
-
-extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
-extern void dccp_li_hist_delete(struct dccp_li_hist *hist);
-
 struct dccp_li_hist_entry {
 	struct list_head dccplih_node;
 	u64		 dccplih_seqno:48,
@@ -33,12 +26,11 @@ struct dccp_li_hist_entry {
 	u32		 dccplih_interval;
 };
 
-extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
-			       struct list_head *list);
+extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-extern void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
+extern void dccp_li_update_li(struct sock *sk,
 			      struct list_head *li_hist_list,
 			      struct list_head *hist_list,
 			      struct timeval *last_feedback, u16 s,
-- 
1.5.0.6

