From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:52:10 +0000
Subject: [PATCH 3/9]: Cache allocation of entries
Message-Id: <200706171352.11045@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Cache allocation of entries

This updates and simplifies the allocation of kmem_cache entries with regard
to the new structure. 

Main changes:
 1. On-demand allocation: no memory consumption when running over loss-free links.
 2. Since cache allocation is local to the module, the cache constructor/destructor
    have been integrated into the module initialisation/cleanup routines.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |   25 +--------
 net/dccp/ccids/lib/loss_interval.c |   93 +++++++++----------------------------
 net/dccp/ccids/lib/loss_interval.h |   22 --------
 net/dccp/ccids/lib/tfrc_module.c   |    8 ++-
 4 files changed, 36 insertions(+), 112 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_module.c
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -6,12 +6,17 @@
 #include "tfrc.h"
 
 /* Initialisation / Clean-up routines */
+extern int  li_init(void);
+extern void li_cleanup(void);
 extern int  packet_history_init(void);
 extern void packet_history_cleanup(void);
 
 static int __init tfrc_module_init(void)
 {
-	int rc = packet_history_init();
+	int rc = li_init();
+
+	if (rc = 0)
+		rc = packet_history_init();
 
 	return rc;
 }
@@ -19,6 +24,7 @@ static int __init tfrc_module_init(void)
 static void __exit tfrc_module_exit(void)
 {
 	packet_history_cleanup();
+	li_cleanup();
 }
 
 module_init(tfrc_module_init);
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -40,9 +40,6 @@ struct tfrc_loss_interval {
 	u32		 li_length;
 };
 
-extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
-extern void dccp_li_hist_delete(struct dccp_li_hist *hist);
-
 /**
  *  tfrc_loss_hist  -  Loss record database
  *  @ring:	Circular queue managed in LIFO manner
@@ -68,25 +65,8 @@ static inline u8 tfrc_lh_length(struct t
 	return min(lh->counter, (u8)LIH_SIZE);
 }
 
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
+extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-   struct list_head *list, const u64 seq_loss, const u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -16,6 +16,8 @@
 #include "../../dccp.h"
 #include "loss_interval.h"
 
+static struct kmem_cache  *tfrc_lh_slab;
+
 /*
  * Access macros: These require that at least one entry is present in lh,
  * and implement array semantics (0 is first, n-1 is the last of n entries).
@@ -37,61 +39,25 @@ static inline struct tfrc_loss_interval 
 	return lh->counter ? __curr_entry(lh) : NULL;
 }
 
-struct dccp_li_hist *dccp_li_hist_new(const char *name)
+/*
+ *	On-demand allocation and de-allocation of entries
+ */
+static struct tfrc_loss_interval *tfrc_lh_demand_next(struct tfrc_loss_hist *lh)
 {
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
+	if (__next_entry(lh) = NULL)
+		__next_entry(lh) = kmem_cache_alloc(tfrc_lh_slab, GFP_ATOMIC);
 
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
+	return __next_entry(lh);
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_new);
-
-void dccp_li_hist_delete(struct dccp_li_hist *hist)
+void tfrc_lh_cleanup(struct tfrc_loss_hist *lh)
 {
-	const char* name = kmem_cache_name(hist->dccplih_slab);
-
-	kmem_cache_destroy(hist->dccplih_slab);
-	kfree(name);
-	kfree(hist);
+	if (tfrc_lh_is_initialised(lh))
+		for (lh->counter = 0; lh->counter < LIH_SIZE; lh->counter++)
+			if (__next_entry(lh) != NULL)
+				kmem_cache_free(tfrc_lh_slab, __next_entry(lh));
 }
-
-EXPORT_SYMBOL_GPL(dccp_li_hist_delete);
-
-void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
-{
-	struct dccp_li_hist_entry *entry, *next;
-
-	list_for_each_entry_safe(entry, next, list, dccplih_node) {
-		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(hist->dccplih_slab, entry);
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_li_hist_purge);
+EXPORT_SYMBOL_GPL(tfrc_lh_cleanup);
 
 /* Weights used to calculate loss event rate */
 /*
@@ -139,26 +105,17 @@ u32 dccp_li_hist_calc_i_mean(struct list
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-   struct list_head *list, const u64 seq_loss, const u8 win_loss)
+int __init li_init(void)
 {
-	struct dccp_li_hist_entry *entry;
-	int i;
+	tfrc_lh_slab = kmem_cache_create("tfrc_loss_history",
+					 sizeof(struct tfrc_loss_interval),
+					 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
 
-	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
-		if (entry = NULL) {
-			dccp_li_hist_purge(hist, list);
-			DCCP_BUG("loss interval list entry is NULL");
-			return 0;
-		}
-		entry->dccplih_interval = ~0;
-		list_add(&entry->dccplih_node, list);
-	}
-
-	entry->dccplih_seqno     = seq_loss;
-	entry->dccplih_win_count = win_loss;
-	return 1;
+	return tfrc_lh_slab = NULL? -ENOBUFS : 0;
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
+void __exit li_cleanup(void)
+{
+	if (tfrc_lh_slab != NULL)
+		kmem_cache_destroy(tfrc_lh_slab);
+}
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -48,7 +48,6 @@ static int ccid3_debug;
 #endif
 
 DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
-static struct dccp_li_hist *ccid3_li_hist;
 
 /*
  *	Transmitter Half-Connection Routines
@@ -908,7 +907,7 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
 		return 1;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	hcrx->ccid3hcrx_s     = 0;
 	hcrx->ccid3hcrx_rtt   = 0;
@@ -922,9 +921,7 @@ static void ccid3_hc_rx_exit(struct sock
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
-
-	/* Empty loss interval history */
-	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
+	tfrc_lh_cleanup(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1001,22 +998,11 @@ static __init int ccid3_module_init(void
 	if (tfrc_tx_cache_init(&ccid3_tx_hist, "ccid3"))
 		goto out;
 
-	ccid3_li_hist = dccp_li_hist_new("ccid3");
-	if (ccid3_li_hist = NULL)
-		goto out_free_tx;
-
 	rc = ccid_register(&ccid3);
 	if (rc != 0)
-		goto out_free_loss_interval_history;
+		tfrc_tx_cache_cleanup(ccid3_tx_hist);
 out:
 	return rc;
-
-out_free_loss_interval_history:
-	dccp_li_hist_delete(ccid3_li_hist);
-	ccid3_li_hist = NULL;
-out_free_tx:
-	tfrc_tx_cache_cleanup(ccid3_tx_hist);
-	goto out;
 }
 module_init(ccid3_module_init);
 
@@ -1026,11 +1012,6 @@ static __exit void ccid3_module_exit(voi
 
 	if (ccid3_tx_hist != NULL)
 		tfrc_tx_cache_cleanup(ccid3_tx_hist);
-
-	if (ccid3_li_hist != NULL) {
-		dccp_li_hist_delete(ccid3_li_hist);
-		ccid3_li_hist = NULL;
-	}
 }
 module_exit(ccid3_module_exit);
 
