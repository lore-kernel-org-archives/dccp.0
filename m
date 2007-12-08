From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:22 +0000
Subject: [PATCH 2/8] [TFRC]: Put RX/TX initialisation into tfrc.c
Message-Id: <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This separates RX/TX initialisation and puts all packet history / loss intervals
initialisation into tfrc.c.
The organisation is uniform: slab declaration -> {rx,tx}_init() -> {rx,tx}_exit()

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   68 ++++++++++++++++------------------
 net/dccp/ccids/lib/tfrc.c           |   31 ++++++++++++----
 2 files changed, 55 insertions(+), 44 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 54cd23e..af0db71 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -57,6 +57,22 @@ struct tfrc_tx_hist_entry {
  */
 static struct kmem_cache *tfrc_tx_hist_slab;
 
+int __init tfrc_tx_packet_history_init(void)
+{
+	tfrc_tx_hist_slab = kmem_cache_create("tfrc_tx_hist",
+					      sizeof(struct tfrc_tx_hist_entry),
+					      0, SLAB_HWCACHE_ALIGN, NULL);
+	return tfrc_tx_hist_slab = NULL ? -ENOBUFS : 0;
+}
+
+void __exit tfrc_tx_packet_history_exit(void)
+{
+	if (tfrc_tx_hist_slab != NULL) {
+		kmem_cache_destroy(tfrc_tx_hist_slab);
+		tfrc_tx_hist_slab = NULL;
+	}
+}
+
 static struct tfrc_tx_hist_entry *
 	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
 {
@@ -119,6 +135,22 @@ EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
  */
 static struct kmem_cache *tfrc_rx_hist_slab;
 
+int __init tfrc_rx_packet_history_init(void)
+{
+	tfrc_rx_hist_slab = kmem_cache_create("tfrc_rxh_cache",
+					      sizeof(struct tfrc_rx_hist_entry),
+					      0, SLAB_HWCACHE_ALIGN, NULL);
+	return tfrc_rx_hist_slab = NULL ? -ENOBUFS : 0;
+}
+
+void __exit tfrc_rx_packet_history_exit(void)
+{
+	if (tfrc_rx_hist_slab != NULL) {
+		kmem_cache_destroy(tfrc_rx_hist_slab);
+		tfrc_rx_hist_slab = NULL;
+	}
+}
+
 /**
  * tfrc_rx_hist_index - index to reach n-th entry after loss_start
  */
@@ -321,39 +353,3 @@ keep_ref_for_next_time:
 	return sample;
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_sample_rtt);
-
-__init int packet_history_init(void)
-{
-	tfrc_tx_hist_slab = kmem_cache_create("tfrc_tx_hist",
-					      sizeof(struct tfrc_tx_hist_entry), 0,
-					      SLAB_HWCACHE_ALIGN, NULL);
-	if (tfrc_tx_hist_slab = NULL)
-		goto out_err;
-
-	tfrc_rx_hist_slab = kmem_cache_create("tfrc_rx_hist",
-					      sizeof(struct tfrc_rx_hist_entry), 0,
-					      SLAB_HWCACHE_ALIGN, NULL);
-	if (tfrc_rx_hist_slab = NULL)
-		goto out_free_tx;
-
-	return 0;
-
-out_free_tx:
-	kmem_cache_destroy(tfrc_tx_hist_slab);
-	tfrc_tx_hist_slab = NULL;
-out_err:
-	return -ENOBUFS;
-}
-
-void packet_history_exit(void)
-{
-	if (tfrc_tx_hist_slab != NULL) {
-		kmem_cache_destroy(tfrc_tx_hist_slab);
-		tfrc_tx_hist_slab = NULL;
-	}
-
-	if (tfrc_rx_hist_slab != NULL) {
-		kmem_cache_destroy(tfrc_rx_hist_slab);
-		tfrc_rx_hist_slab = NULL;
-	}
-}
diff --git a/net/dccp/ccids/lib/tfrc.c b/net/dccp/ccids/lib/tfrc.c
index 3a7a183..20763fa 100644
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -14,27 +14,42 @@ module_param(tfrc_debug, bool, 0444);
 MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
 #endif
 
+extern int  tfrc_tx_packet_history_init(void);
+extern void tfrc_tx_packet_history_exit(void);
+extern int  tfrc_rx_packet_history_init(void);
+extern void tfrc_rx_packet_history_exit(void);
+
 extern int  dccp_li_init(void);
 extern void dccp_li_exit(void);
-extern int packet_history_init(void);
-extern void packet_history_exit(void);
 
 static int __init tfrc_module_init(void)
 {
 	int rc = dccp_li_init();
 
-	if (rc = 0) {
-		rc = packet_history_init();
-		if (rc != 0)
-			dccp_li_exit();
-	}
+	if (rc)
+		goto out;
+
+	rc = tfrc_tx_packet_history_init();
+	if (rc)
+		goto out_free_loss_intervals;
 
+	rc = tfrc_rx_packet_history_init();
+	if (rc)
+		goto out_free_tx_history;
+	return 0;
+
+out_free_tx_history:
+	tfrc_tx_packet_history_exit();
+out_free_loss_intervals:
+	dccp_li_exit();
+out:
 	return rc;
 }
 
 static void __exit tfrc_module_exit(void)
 {
-	packet_history_exit();
+	tfrc_rx_packet_history_exit();
+	tfrc_tx_packet_history_exit();
 	dccp_li_exit();
 }
 
