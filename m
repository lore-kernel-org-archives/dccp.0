From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:03:55 +0000
Subject: [PATCH 21/22] [DCCP] ccid3: Reorder packet history source file
Message-Id: <20061210030354.GW17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

No code change at all.

This reorders the source file to follow the same order as the corresponding
header file.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/lib/packet_history.c |  219 ++++++++++++++++++-----------------
 1 files changed, 112 insertions(+), 107 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index b876c9c..2e8ef42 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -36,9 +36,100 @@
 
 #include <linux/module.h>
 #include <linux/string.h>
-
 #include "packet_history.h"
 
+/*
+ * 	Transmitter History Routines
+ */
+struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
+{
+	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
+	static const char dccp_tx_hist_mask[] = "tx_hist_%s";
+	char *slab_name;
+
+	if (hist = NULL)
+		goto out;
+
+	slab_name = kmalloc(strlen(name) + sizeof(dccp_tx_hist_mask) - 1,
+			    GFP_ATOMIC);
+	if (slab_name = NULL)
+		goto out_free_hist;
+
+	sprintf(slab_name, dccp_tx_hist_mask, name);
+	hist->dccptxh_slab = kmem_cache_create(slab_name,
+					     sizeof(struct dccp_tx_hist_entry),
+					       0, SLAB_HWCACHE_ALIGN,
+					       NULL, NULL);
+	if (hist->dccptxh_slab = NULL)
+		goto out_free_slab_name;
+out:
+	return hist;
+out_free_slab_name:
+	kfree(slab_name);
+out_free_hist:
+	kfree(hist);
+	hist = NULL;
+	goto out;
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_new);
+
+void dccp_tx_hist_delete(struct dccp_tx_hist *hist)
+{
+	const char* name = kmem_cache_name(hist->dccptxh_slab);
+
+	kmem_cache_destroy(hist->dccptxh_slab);
+	kfree(name);
+	kfree(hist);
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_delete);
+
+struct dccp_tx_hist_entry *
+	dccp_tx_hist_find_entry(const struct list_head *list, const u64 seq)
+{
+	struct dccp_tx_hist_entry *packet = NULL, *entry;
+
+	list_for_each_entry(entry, list, dccphtx_node)
+		if (entry->dccphtx_seqno = seq) {
+			packet = entry;
+			break;
+		}
+
+	return packet;
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
+
+void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
+{
+	struct dccp_tx_hist_entry *entry, *next;
+
+	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
+		list_del_init(&entry->dccphtx_node);
+		dccp_tx_hist_entry_delete(hist, entry);
+	}
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
+
+void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
+			      struct list_head *list,
+			      struct dccp_tx_hist_entry *packet)
+{
+	struct dccp_tx_hist_entry *next;
+
+	list_for_each_entry_safe_continue(packet, next, list, dccphtx_node) {
+		list_del_init(&packet->dccphtx_node);
+		dccp_tx_hist_entry_delete(hist, packet);
+	}
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_purge_older);
+
+/*
+ * 	Receiver History Routines
+ */
 struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
 {
 	struct dccp_rx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
@@ -83,18 +174,24 @@ void dccp_rx_hist_delete(struct dccp_rx_
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_delete);
 
-void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
+int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
+			    u8 *ccval)
 {
-	struct dccp_rx_hist_entry *entry, *next;
+	struct dccp_rx_hist_entry *packet = NULL, *entry;
 
-	list_for_each_entry_safe(entry, next, list, dccphrx_node) {
-		list_del_init(&entry->dccphrx_node);
-		kmem_cache_free(hist->dccprxh_slab, entry);
-	}
-}
+	list_for_each_entry(entry, list, dccphrx_node)
+		if (entry->dccphrx_seqno = seq) {
+			packet = entry;
+			break;
+		}
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
+	if (packet)
+		*ccval = packet->dccphrx_ccval;
 
+	return packet != NULL;
+}
+
+EXPORT_SYMBOL_GPL(dccp_rx_hist_find_entry);
 struct dccp_rx_hist_entry *
 		dccp_rx_hist_find_data_packet(const struct list_head *list)
 {
@@ -184,110 +281,18 @@ void dccp_rx_hist_add_packet(struct dccp
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
 
-struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
-{
-	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
-	static const char dccp_tx_hist_mask[] = "tx_hist_%s";
-	char *slab_name;
-
-	if (hist = NULL)
-		goto out;
-
-	slab_name = kmalloc(strlen(name) + sizeof(dccp_tx_hist_mask) - 1,
-			    GFP_ATOMIC);
-	if (slab_name = NULL)
-		goto out_free_hist;
-
-	sprintf(slab_name, dccp_tx_hist_mask, name);
-	hist->dccptxh_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_tx_hist_entry),
-					       0, SLAB_HWCACHE_ALIGN,
-					       NULL, NULL);
-	if (hist->dccptxh_slab = NULL)
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
-EXPORT_SYMBOL_GPL(dccp_tx_hist_new);
-
-void dccp_tx_hist_delete(struct dccp_tx_hist *hist)
-{
-	const char* name = kmem_cache_name(hist->dccptxh_slab);
-
-	kmem_cache_destroy(hist->dccptxh_slab);
-	kfree(name);
-	kfree(hist);
-}
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_delete);
-
-struct dccp_tx_hist_entry *
-	dccp_tx_hist_find_entry(const struct list_head *list, const u64 seq)
-{
-	struct dccp_tx_hist_entry *packet = NULL, *entry;
-
-	list_for_each_entry(entry, list, dccphtx_node)
-		if (entry->dccphtx_seqno = seq) {
-			packet = entry;
-			break;
-		}
-
-	return packet;
-}
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
-
-int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
-   u8 *ccval)
-{
-	struct dccp_rx_hist_entry *packet = NULL, *entry;
-
-	list_for_each_entry(entry, list, dccphrx_node)
-		if (entry->dccphrx_seqno = seq) {
-			packet = entry;
-			break;
-		}
-
-	if (packet)
-		*ccval = packet->dccphrx_ccval;
-
-	return packet != NULL;
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_find_entry);
-
-void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-			      struct list_head *list,
-			      struct dccp_tx_hist_entry *packet)
+void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
 {
-	struct dccp_tx_hist_entry *next;
+	struct dccp_rx_hist_entry *entry, *next;
 
-	list_for_each_entry_safe_continue(packet, next, list, dccphtx_node) {
-		list_del_init(&packet->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, packet);
+	list_for_each_entry_safe(entry, next, list, dccphrx_node) {
+		list_del_init(&entry->dccphrx_node);
+		kmem_cache_free(hist->dccprxh_slab, entry);
 	}
 }
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge_older);
-
-void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
-{
-	struct dccp_tx_hist_entry *entry, *next;
-
-	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
-		list_del_init(&entry->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, entry);
-	}
-}
+EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
 
 MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
 	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
-- 
1.4.2.1.g3d5c

