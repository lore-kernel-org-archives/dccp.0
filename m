From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:31 +0000
Subject: [PATCH 3/9]: New RX History Step 2 - Initialisation and cleanup
Message-Id: <200706151531.31616@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: New RX History Step 2 - Initialisation and cleanup

This adds initialisation and cleanup wrappers for the RX history.

It further makes the allocation of dccp_rx_hist entries local to
packet_history.c, as a service exported by the dccp_tfrc_lib module.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   26 ++--------
 net/dccp/ccids/lib/packet_history.c |   86 +++++++++++++++---------------------
 net/dccp/ccids/lib/packet_history.h |   13 +----
 net/dccp/ccids/lib/tfrc_module.c    |    7 ++
 4 files changed, 53 insertions(+), 79 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_module.c
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -5,15 +5,20 @@
 #include <linux/moduleparam.h>
 #include "tfrc.h"
 
+/* Initialisation / Clean-up routines */
+extern int  packet_history_init(void);
+extern void packet_history_cleanup(void);
+
 static int __init tfrc_module_init(void)
 {
-	int rc = 0;
+	int rc = packet_history_init();
 
 	return rc;
 }
 
 static void __exit tfrc_module_exit(void)
 {
+	packet_history_cleanup();
 }
 
 module_init(tfrc_module_init);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -48,7 +48,6 @@ static int ccid3_debug;
 #endif
 
 DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
-static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
 /*
@@ -1051,11 +1050,12 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	ccid3_pr_debug("entry\n");
 
-	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
+	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
+		return 1;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	hcrx->ccid3hcrx_s   = 0;
-	hcrx->ccid3hcrx_rtt = 0;
+	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
+	hcrx->ccid3hcrx_s     = 0;
+	hcrx->ccid3hcrx_rtt   = 0;
 	return 0;
 }
 
@@ -1065,8 +1065,7 @@ static void ccid3_hc_rx_exit(struct sock
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	/* Empty packet history */
-	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
+	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
 	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
@@ -1143,12 +1142,8 @@ static __init int ccid3_module_init(void
 {
 	int rc = -ENOBUFS;
 
-	ccid3_rx_hist = dccp_rx_hist_new("ccid3");
-	if (ccid3_rx_hist = NULL)
-		goto out;
-
 	if (tfrc_tx_cache_init(&ccid3_tx_hist, "ccid3"))
-		goto out_free_rx;
+		goto out;
 
 	ccid3_li_hist = dccp_li_hist_new("ccid3");
 	if (ccid3_li_hist = NULL)
@@ -1165,9 +1160,6 @@ out_free_loss_interval_history:
 	ccid3_li_hist = NULL;
 out_free_tx:
 	tfrc_tx_cache_cleanup(ccid3_tx_hist);
-out_free_rx:
-	dccp_rx_hist_delete(ccid3_rx_hist);
-	ccid3_rx_hist = NULL;
 	goto out;
 }
 module_init(ccid3_module_init);
@@ -1179,10 +1171,6 @@ static __exit void ccid3_module_exit(voi
 	if (ccid3_tx_hist != NULL)
 		tfrc_tx_cache_cleanup(ccid3_tx_hist);
 
-	if (ccid3_rx_hist != NULL) {
-		dccp_rx_hist_delete(ccid3_rx_hist);
-		ccid3_rx_hist = NULL;
-	}
 	if (ccid3_li_hist != NULL) {
 		dccp_li_hist_delete(ccid3_li_hist);
 		ccid3_li_hist = NULL;
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -149,49 +149,7 @@ EXPORT_SYMBOL_GPL(tfrc_tx_hist_cleanup);
 /*
  * 	Receiver History Routines
  */
-struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
-{
-	struct dccp_rx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
-	static const char dccp_rx_hist_mask[] = "rx_hist_%s";
-	char *slab_name;
-
-	if (hist = NULL)
-		goto out;
-
-	slab_name = kmalloc(strlen(name) + sizeof(dccp_rx_hist_mask) - 1,
-			    GFP_ATOMIC);
-	if (slab_name = NULL)
-		goto out_free_hist;
-
-	sprintf(slab_name, dccp_rx_hist_mask, name);
-	hist->dccprxh_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_rx_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL, NULL);
-	if (hist->dccprxh_slab = NULL)
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
-EXPORT_SYMBOL_GPL(dccp_rx_hist_new);
-
-void dccp_rx_hist_delete(struct dccp_rx_hist *hist)
-{
-	const char* name = kmem_cache_name(hist->dccprxh_slab);
-
-	kmem_cache_destroy(hist->dccprxh_slab);
-	kfree(name);
-	kfree(hist);
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_delete);
+static struct kmem_cache *tfrcxh;
 
 int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 			    u8 *ccval)
@@ -284,14 +242,44 @@ void dccp_rx_hist_add_packet(struct dccp
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
 
-void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
+int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
 {
-	struct dccp_rx_hist_entry *entry, *next;
+	int i;
 
-	list_for_each_entry_safe(entry, next, list, dccphrx_node) {
-		list_del_init(&entry->dccphrx_node);
-		kmem_cache_free(hist->dccprxh_slab, entry);
+	for (i = 0; i <= NDUPACK; i++) {
+		h->ring[i] = kmem_cache_alloc(tfrcxh, GFP_ATOMIC);
+		if (h->ring[i] = NULL)
+			return 1;
 	}
+	spin_lock_init(&h->lock);
+	h->loss_count = 0;
+	h->loss_start = 0;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);
+
+void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	for (i=0; i <= NDUPACK; i++)
+		if (h->ring[i] != NULL)
+			kmem_cache_free(tfrcxh, h->ring[i]);
 }
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
+/* Module initialisation and cleanup routines */
+int __init packet_history_init(void)
+{
+	tfrcxh = kmem_cache_create("tfrc_rx_hist",
+				   sizeof(struct tfrc_rx_hist_entry),
+				   0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+
+	return tfrcxh = NULL ? -ENOBUFS : 0;
+}
+
+void __exit packet_history_cleanup(void)
+{
+	if (tfrcxh != NULL)
+		kmem_cache_destroy(tfrcxh);
+}
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -108,13 +108,6 @@ struct tfrc_rx_hist_entry {
 	ktime_t		stamp;
 };
 
-struct dccp_rx_hist {
-	struct kmem_cache *dccprxh_slab;
-};
-
-extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
-extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
-
 /**
  *   tfrc_rx_hist  -  RX history structure for TFRC-based protocols
  *
@@ -211,6 +204,9 @@ static inline void tfrc_rx_hist_swap(str
 	*b = tmp;
 }
 
+extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
+extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
+
 static inline struct dccp_rx_hist_entry *
 			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
 					       const struct sock *sk,
@@ -261,9 +257,6 @@ static inline void dccp_rx_hist_entry_de
 		kmem_cache_free(hist->dccprxh_slab, entry);
 }
 
-extern void dccp_rx_hist_purge(struct dccp_rx_hist *hist,
-			       struct list_head *list);
-
 static inline int
 	dccp_rx_hist_entry_data_packet(const struct dccp_rx_hist_entry *entry)
 {
