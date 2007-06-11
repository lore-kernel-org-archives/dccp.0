From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 12:41:49 +0000
Subject: [PATCH 3/6]: Migrate to new naming scheme, using macro to declare cache
Message-Id: <200706111341.49697@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Migrate to new naming scheme, using macro to declare cache

This patch
	* begins migration to consistent naming scheme of this changeset
	  -> all functions of the TFRC module begin with `tfrc_';
	* simplifies cache allocation using a macro (details below);
	* simplifies allocation from cache by using gfp_any();
	* renames routines into cache_init()/cache_cleanup() to show
	  what they do;
	* is justified by having almost twice as many deletions as insertions.

Details:
	The TFRC module exports a cache-allocation service which can be used to
	set up transmitter histories. The present solution to declare this uses a
	wrapper around struct kmem_cache. Confusingly, the wrapper was called `_hist',
	but it is in reality a cache. Replaced by a macro to serve the same purpose.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   15 +++++--------
 net/dccp/ccids/lib/packet_history.c |   41 ++++++++++++------------------------
 net/dccp/ccids/lib/packet_history.h |    6 +++--
 3 files changed, 24 insertions(+), 38 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -52,8 +52,10 @@
 /*
  * 	Transmitter History data structures and declarations
  */
-extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
-extern void		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
+#define DECLARE_TFRC_TX_CACHE(name)	static struct kmem_cache *(name);
+
+extern int  tfrc_tx_cache_init(struct kmem_cache **cache, const char *name);
+extern void tfrc_tx_cache_cleanup(struct kmem_cache *cache);
 
 /**
  *  tfrc_tx_hist  -  Simple singly-linked TX history list
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -43,49 +43,36 @@
  */
 DEFINE_RWLOCK(tfrc_tx_hist_lock);
 
-struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
+int tfrc_tx_cache_init(struct kmem_cache **cache, const char *name)
 {
-	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
 	static const char dccp_tx_hist_mask[] = "tx_hist_%s";
 	char *slab_name;
 
-	if (hist = NULL)
-		goto out;
-
 	slab_name = kmalloc(strlen(name) + sizeof(dccp_tx_hist_mask) - 1,
 			    GFP_ATOMIC);
 	if (slab_name = NULL)
-		goto out_free_hist;
+		goto fail;
 
 	sprintf(slab_name, dccp_tx_hist_mask, name);
-	hist->dccptxh_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_tx_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL, NULL);
-	if (hist->dccptxh_slab = NULL)
-		goto out_free_slab_name;
-out:
-	return hist;
-out_free_slab_name:
+	*cache = kmem_cache_create(slab_name, sizeof(struct tfrc_tx_hist), 0,
+					      SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (*cache != NULL)
+		return 0;
+
 	kfree(slab_name);
-out_free_hist:
-	kfree(hist);
-	hist = NULL;
-	goto out;
+fail:
+	return -ENOBUFS;
 }
+EXPORT_SYMBOL_GPL(tfrc_tx_cache_init);
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_new);
-
-void dccp_tx_hist_delete(struct dccp_tx_hist *hist)
+void tfrc_tx_cache_cleanup(struct kmem_cache *cache)
 {
-	const char* name = kmem_cache_name(hist->dccptxh_slab);
+	const char* name = kmem_cache_name(cache);
 
-	kmem_cache_destroy(hist->dccptxh_slab);
+	kmem_cache_destroy(cache);
 	kfree(name);
-	kfree(hist);
 }
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_delete);
+EXPORT_SYMBOL_GPL(tfrc_tx_cache_cleanup);
 
 struct dccp_tx_hist_entry *
 	dccp_tx_hist_find_entry(const struct list_head *list, const u64 seq)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -47,7 +47,7 @@ static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)
 #endif
 
-static struct dccp_tx_hist *ccid3_tx_hist;
+DECLARE_TFRC_TX_CACHE(ccid3_tx_hist);
 static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
@@ -1202,8 +1202,7 @@ static __init int ccid3_module_init(void
 	if (ccid3_rx_hist = NULL)
 		goto out;
 
-	ccid3_tx_hist = dccp_tx_hist_new("ccid3");
-	if (ccid3_tx_hist = NULL)
+	if (tfrc_tx_cache_init(&ccid3_tx_hist, "ccid3"))
 		goto out_free_rx;
 
 	ccid3_li_hist = dccp_li_hist_new("ccid3");
@@ -1220,8 +1219,7 @@ out_free_loss_interval_history:
 	dccp_li_hist_delete(ccid3_li_hist);
 	ccid3_li_hist = NULL;
 out_free_tx:
-	dccp_tx_hist_delete(ccid3_tx_hist);
-	ccid3_tx_hist = NULL;
+	tfrc_tx_cache_cleanup(ccid3_tx_hist);
 out_free_rx:
 	dccp_rx_hist_delete(ccid3_rx_hist);
 	ccid3_rx_hist = NULL;
@@ -1233,10 +1231,9 @@ static __exit void ccid3_module_exit(voi
 {
 	ccid_unregister(&ccid3);
 
-	if (ccid3_tx_hist != NULL) {
-		dccp_tx_hist_delete(ccid3_tx_hist);
-		ccid3_tx_hist = NULL;
-	}
+	if (ccid3_tx_hist != NULL)
+		tfrc_tx_cache_cleanup(ccid3_tx_hist);
+
 	if (ccid3_rx_hist != NULL) {
 		dccp_rx_hist_delete(ccid3_rx_hist);
 		ccid3_rx_hist = NULL;
