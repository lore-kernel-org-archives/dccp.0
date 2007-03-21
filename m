From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:45:36 +0000
Subject: [PATCH 18/25]: Reduce time spent while write-lock is held
Message-Id: <200703211845.36548@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Reduce time spent while write-lock is held

This minimizes the time during which the `write_lock' is held: by using a
temporary list_head and re-adjusting the pointers of the old list accordingly.
The clean-up operation can then safely be done outside the lock, since the
newly created list is then `homeless'.

 1. For dccp_tx_hist_purge, this is conveniently done by using list_replace_init,

 2. the case for dccp_tx_hist_purge_older is analogous and, in the absence of a
    matching library function, done manually;

 3. the `dangerous' function dccp_tx_hist_purge_older has been removed by 
    merging its functionality into dccp_tx_hist_get_send_time.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   47 +++++++++++++++++++-----------------
 net/dccp/ccids/lib/packet_history.h |    4 ---
 2 files changed, 25 insertions(+), 26 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -87,6 +87,16 @@ void dccp_tx_hist_delete(struct dccp_tx_
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_delete);
 
+static void __dccp_tx_hist_wipe(struct list_head *head, struct kmem_cache *slab)
+{
+	struct dccp_tx_hist_entry *entry, *next;
+
+	list_for_each_entry_safe(entry, next, head, dccphtx_node) {
+		list_del(&entry->dccphtx_node);
+		kmem_cache_free(slab, entry);
+	}
+}
+
 /**
  *  dccp_tx_hist_get_send_time  -  Retrieve timestamp of sent packet
  *
@@ -101,6 +111,7 @@ int dccp_tx_hist_get_send_time(struct dc
 			       struct timeval *t_send)
 {
 	struct dccp_tx_hist_entry *entry;
+	struct list_head free_this;
 	int found = 0;
 
 	write_lock_bh(&dccp_tx_hist_lock);
@@ -108,12 +119,20 @@ int dccp_tx_hist_get_send_time(struct dc
 		if (entry->dccphtx_seqno = seq) {
 			found = 1;
 			*t_send = entry->dccphtx_tstamp;
+			/* forget/free all entries older than this one */
+			free_this.next		= entry->dccphtx_node.next;
+			free_this.next->prev	= &free_this;
+			free_this.prev		= list->prev;
+			free_this.prev->next	= &free_this;
+
+			entry->dccphtx_node.next = list;
+			list->prev		 = &entry->dccphtx_node;
 			break;
 		}
+	write_unlock_bh(&dccp_tx_hist_lock);
 
 	if (found)
-		dccp_tx_hist_purge_older(hist, list, entry);
-	write_unlock_bh(&dccp_tx_hist_lock);
+		__dccp_tx_hist_wipe(&free_this, hist->dccptxh_slab);
 
 	return found;
 }
@@ -132,32 +151,16 @@ EXPORT_SYMBOL_GPL(dccp_tx_hist_add_entry
 
 void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
 {
-	struct dccp_tx_hist_entry *entry, *next;
+	struct list_head free_this;
 
 	write_lock_bh(&dccp_tx_hist_lock);
-	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
-		list_del_init(&entry->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, entry);
-	}
+	list_replace_init(list, &free_this);
 	write_unlock_bh(&dccp_tx_hist_lock);
-}
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
-
-/* XXX careful, this one is not lock-protected */
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
+	__dccp_tx_hist_wipe(&free_this, hist->dccptxh_slab);
 }
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge_older);
+EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
 
 /*
  * 	Receiver History Routines
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -95,10 +95,6 @@ static inline void dccp_tx_hist_entry_de
 extern void dccp_tx_hist_purge(struct dccp_tx_hist *hist,
 			       struct list_head *list);
 
-extern void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-				     struct list_head *list,
-				     struct dccp_tx_hist_entry *next);
-
 /*
  * 	Receiver History data structures and declarations
  */
