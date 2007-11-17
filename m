From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:33 +0000
Subject: [PATCH 06/16] [TFRC]: Remove old (doubly-linked list) TX history
Message-Id: <11952917831088-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/lib/packet_history.c |   85 -----------------------------------
 net/dccp/ccids/lib/packet_history.h |   62 -------------------------
 2 files changed, 0 insertions(+), 147 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 5651de4..1955f13 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -73,66 +73,6 @@ void tfrc_tx_cache_cleanup(struct kmem_cache *cache)
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_cache_cleanup);
 
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
-					       NULL);
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
 int tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno)
 {
 	struct tfrc_tx_hist *new = kmem_cache_alloc(head->cache, gfp_any());
@@ -196,31 +136,6 @@ int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_when);
 
-void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
-{
-	struct dccp_tx_hist_entry *entry, *next;
-
-	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
-		list_del_init(&entry->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, entry);
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
-
-void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-			      struct list_head *list,
-			      struct dccp_tx_hist_entry *packet)
-{
-	struct dccp_tx_hist_entry *next;
-
-	list_for_each_entry_safe_continue(packet, next, list, dccphtx_node) {
-		list_del_init(&packet->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, packet);
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge_older);
 
 /*
  * 	Receiver History Routines
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index bb253f1..3c39bc3 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -56,21 +56,6 @@
 extern int  tfrc_tx_cache_init(struct kmem_cache **cache, const char *name);
 extern void tfrc_tx_cache_cleanup(struct kmem_cache *cache);
 
-struct dccp_tx_hist_entry {
-	struct list_head dccphtx_node;
-	u64		 dccphtx_seqno:48,
-			 dccphtx_sent:1;
-	u32		 dccphtx_rtt;
-	ktime_t		 dccphtx_tstamp;
-};
-
-struct dccp_tx_hist {
-	struct kmem_cache *dccptxh_slab;
-};
-
-extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
-extern void 		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
-
 /**
  *  tfrc_tx_hist  -  Simple singly-linked TX history list
  *  @next:  next oldest entry (LIFO order)
@@ -100,57 +85,10 @@ static inline void tfrc_tx_hist_init(struct tfrc_tx_hist_head *head,
 	head->cache = cache;
 }
 
-static inline struct dccp_tx_hist_entry *
-			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
-					       const gfp_t prio)
-{
-	struct dccp_tx_hist_entry *entry = kmem_cache_alloc(hist->dccptxh_slab,
-							    prio);
-
-	if (entry != NULL)
-		entry->dccphtx_sent = 0;
-
-	return entry;
-}
-
-static inline struct dccp_tx_hist_entry *
-			dccp_tx_hist_head(struct list_head *list)
-{
-	struct dccp_tx_hist_entry *head = NULL;
-
-	if (!list_empty(list))
-		head = list_entry(list->next, struct dccp_tx_hist_entry,
-				  dccphtx_node);
-	return head;
-}
-
-extern struct dccp_tx_hist_entry *
-			dccp_tx_hist_find_entry(const struct list_head *list,
-						const u64 seq);
 extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno);
 extern int  tfrc_tx_hist_when(ktime_t *, struct tfrc_tx_hist_head *, u64);
 extern void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head);
 
-static inline void dccp_tx_hist_add_entry(struct list_head *list,
-					  struct dccp_tx_hist_entry *entry)
-{
-	list_add(&entry->dccphtx_node, list);
-}
-
-static inline void dccp_tx_hist_entry_delete(struct dccp_tx_hist *hist,
-					     struct dccp_tx_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccptxh_slab, entry);
-}
-
-extern void dccp_tx_hist_purge(struct dccp_tx_hist *hist,
-			       struct list_head *list);
-
-extern void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-				     struct list_head *list,
-				     struct dccp_tx_hist_entry *next);
-
 /*
  * 	Receiver History data structures and declarations
  */
-- 
1.5.2.2.238.g7cbf2f2-dirty

