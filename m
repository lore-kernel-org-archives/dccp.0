From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 12:41:55 +0000
Subject: [PATCH 4/6]: History allocation / deallocation routines
Message-Id: <200706111341.55914@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: History allocation / deallocation routines

Within the set, this patch is concerned with allocation/de-allocation of list entries:
  * adding information is transparent to the calling module;
  * de-allocation will be transparent, hence dccp_tx_hist_purge_older removed here;
  * allocation and cleanup are taken care of internally.
	
Note on locking:
----------------
  Since the CCID3 module functions can be called both from user context (e.g. dccp_sendmsg)
  and from softirq context (receive handler, dccp_write_xmit_timer), all read/write locks will
  disable software interrupts as well. Time-intensive operations (e.g. full list traversal)
  are therefore avoided when under lock.
  All `dangerous' (i.e. not protected by lock) functions have the usual prefix of `__'.  

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   16 ++---------
 net/dccp/ccids/lib/packet_history.c |   51 ++++++++++++++++++++++++------------
 net/dccp/ccids/lib/packet_history.h |   41 ++++------------------------
 3 files changed, 44 insertions(+), 64 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -79,47 +79,18 @@ struct tfrc_tx_hist_head {
 	struct kmem_cache	*cache;
 };
 
-static inline struct dccp_tx_hist_entry *
-			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
-					       const gfp_t prio)
+static inline void tfrc_tx_hist_init(struct tfrc_tx_hist_head *head,
+				     struct kmem_cache *cache)
 {
-	return kmem_cache_alloc(hist->dccptxh_slab, prio);
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
+	head->first = NULL;
+	head->cache = cache;
 }
 
 extern struct dccp_tx_hist_entry *
 			dccp_tx_hist_find_entry(const struct list_head *list,
 						const u64 seq);
-
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
+extern int  tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno);
+extern void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head);
 
 /*
  * 	Receiver History data structures and declarations
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -90,31 +90,50 @@ struct dccp_tx_hist_entry *
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_find_entry);
 
-void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
+int tfrc_tx_hist_add(struct tfrc_tx_hist_head *head, u64 seqno)
 {
-	struct dccp_tx_hist_entry *entry, *next;
+	struct tfrc_tx_hist *new = kmem_cache_alloc(head->cache, gfp_any());
 
-	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
-		list_del_init(&entry->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, entry);
-	}
+	if (new = NULL)
+		return -ENOBUFS;
+
+	new->seqno = seqno;
+	new->stamp = ktime_get_real();
+
+	write_lock_bh(&tfrc_tx_hist_lock);
+	new->next = head->first;
+	head->first = new;
+	write_unlock_bh(&tfrc_tx_hist_lock);
+
+	return 0;
 }
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_add);
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
+static void __tfrc_tx_hist_remove_tail(struct tfrc_tx_hist *ptr,
+				       struct kmem_cache *cache)
+ {
+	struct tfrc_tx_hist *old;
 
-void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
-			      struct list_head *list,
-			      struct dccp_tx_hist_entry *packet)
+	while (ptr != NULL) {
+		old = ptr;
+		ptr = ptr->next;
+		kmem_cache_free(cache, old);
+	}
+}
+
+void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head)
 {
-	struct dccp_tx_hist_entry *next;
+	struct tfrc_tx_hist *free_this;
 
-	list_for_each_entry_safe_continue(packet, next, list, dccphtx_node) {
-		list_del_init(&packet->dccphtx_node);
-		dccp_tx_hist_entry_delete(hist, packet);
-	}
+	write_lock_bh(&tfrc_tx_hist_lock);
+	free_this = head->first;
+	head->first = NULL;
+	write_unlock_bh(&tfrc_tx_hist_lock);
+
+	__tfrc_tx_hist_remove_tail(free_this, head->cache);
 }
+EXPORT_SYMBOL_GPL(tfrc_tx_hist_cleanup);
 
-EXPORT_SYMBOL_GPL(dccp_tx_hist_purge_older);
 
 /*
  * 	Receiver History Routines
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -394,23 +394,13 @@ static void ccid3_hc_tx_packet_sent(stru
 				    unsigned int len)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct timeval now;
-	struct dccp_tx_hist_entry *packet;
 
 	BUG_ON(hctx = NULL);
 
 	ccid3_hc_tx_update_s(hctx, len);
 
-	packet = dccp_tx_hist_entry_new(ccid3_tx_hist, GFP_ATOMIC);
-	if (unlikely(packet = NULL)) {
+	if (tfrc_tx_hist_add(&hctx->ccid3hctx_hist, dccp_sk(sk)->dccps_gss))
 		DCCP_CRIT("packet history - out of memory!");
-		return;
-	}
-
-	dccp_timestamp(sk, &now);
-	packet->dccphtx_tstamp = now;
-	packet->dccphtx_seqno  = dccp_sk(sk)->dccps_gss;
-	dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, packet);
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -611,7 +601,7 @@ static int ccid3_hc_tx_init(struct ccid 
 	hctx->ccid3hctx_s     = 0;
 	hctx->ccid3hctx_rtt   = 0;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
-	INIT_LIST_HEAD(&hctx->ccid3hctx_hist);
+	tfrc_tx_hist_init(&hctx->ccid3hctx_hist, ccid3_tx_hist);
 
 	hctx->ccid3hctx_no_feedback_timer.function  				ccid3_hc_tx_no_feedback_timer;
@@ -631,7 +621,7 @@ static void ccid3_hc_tx_exit(struct sock
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
 	/* Empty packet history */
-	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
+	tfrc_tx_hist_cleanup(&hctx->ccid3hctx_hist);
 }
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
