From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 12:42:02 +0000
Subject: [PATCH 5/6]: Add history query/lookup function
Message-Id: <200706111342.02233@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Add history query/lookup function

This completes the basic TX history functions that are implemented by this
patch set, by adding a lock-protected lookup function to look up the send
time of a particular sent packet.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   44 ++++++++++++++++++++++--------------
 net/dccp/ccids/lib/packet_history.h |    4 ---
 2 files changed, 29 insertions(+), 19 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -86,10 +86,8 @@ static inline void tfrc_tx_hist_init(str
 	head->cache = cache;
 }
 
-extern struct dccp_tx_hist_entry *
-			dccp_tx_hist_find_entry(const struct list_head *list,
-						const u64 seq);
 extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno);
+extern int  tfrc_tx_hist_when(ktime_t *, struct tfrc_tx_hist_head *, u64);
 extern void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head);
 
 /*
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -74,22 +74,6 @@ void tfrc_tx_cache_cleanup(struct kmem_c
 }
 EXPORT_SYMBOL_GPL(tfrc_tx_cache_cleanup);
 
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
@@ -121,6 +105,34 @@ static void __tfrc_tx_hist_remove_tail(s
 	}
 }
 
+/**
+ *  tfrc_tx_hist_when  -  Retrieve send time of past packet
+ *  @stamp: send time to look up (returns value result)
+ *  @head:  TX history to search in
+ *  @ackno: ACK number which indicates the sent packet's sequence number
+ *  If successful, it garbage-collects older (irrelevant) entries and returns 1.
+ */
+int tfrc_tx_hist_when(ktime_t *stamp, struct tfrc_tx_hist_head *head, u64 ackno)
+{
+	struct tfrc_tx_hist *cur, *tail = NULL;
+
+	write_lock_bh(&tfrc_tx_hist_lock);
+	for (cur = head->first; cur != NULL; cur = cur->next)
+		if (cur->seqno = ackno) {
+			*stamp = cur->stamp;
+			tail = cur->next;
+			cur->next = NULL;
+			break;
+		}
+	write_unlock_bh(&tfrc_tx_hist_lock);
+
+	if (tail)
+		__tfrc_tx_hist_remove_tail(tail, head->cache);
+
+	return (cur != NULL);
+}
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_when);
+
 void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head)
 {
 	struct tfrc_tx_hist *free_this;
