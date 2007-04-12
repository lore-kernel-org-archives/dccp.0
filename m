From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:16:29 +0000
Subject: [PATCH 17/29] Locking for packet history TX list
Message-Id: <20070412211629.GR21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Currently the packet history lists are accessed asynchronously from different
contexts, but without any locking protection. This can lead to race conditions,
corruption and facilitates unpredictable behaviour.

In particular, this patch

 1) adds a R/W spinlock to protect the list against concurrent access;
 2) makes dccp_tx_hist_add_entry local to packet_history.c
     - locking should only be visible in the source file, but not the header file.

(NB - there are at the moment no pure readers for this list, so in principle a
 normal spinlock could alternatively be used).

                          D e t a i l s
                          -------------
 The question is whether to disable softirqs.

 (1) dccp_tx_hist_get_send_time is called in the following, simplified manner:

    ccid3_hc_tx_packet_recv  <-  dccp_v{4,6}_do_rcv  <-  dccp_v{4,6}_rcv
                                                     <-  release_sock

     dccp_v{4,6}_do_recv is called as backlog handler for dccp_v{4,6}_rcv, which
     means softirq context (via dccp_v{4,6}_rcv -> sk_receive_skb). The second
     alternative (release_sock) is in user context.

 (2) dccp_tx_hist_purge is only called in ccid3_hc_tx_exit, in this manner:

     ccid3_hc_tx_exit <- ccid_delete <- ccid_hc_tx_delete <- dccp_feat_update_ccid
                                                          <- dccp_create_openreq_child
                                                          <- dccp_init_sock
                                                          <- dccp_destroy_sock

     Since dccp_tx_hist_purge is called at the end of an old or a new connection,
     disabling softirqs is not strictly necessary.

 (3) dccp_tx_hist_add_entry is called in mixed contexts:
     ccid3_hc_tx_packet_sent <- dccp_write_xmit <- dccp_write_xmit_timer [Softirq]
                                                <- dccp_send_close       [User Context]
                                                <- dccp_sendmsg          [User Context]

     Since the previous patch disables softirqs generally when ccid_hc_tx_packet_sent is
     called, disabling softirqs here is also not strictly necessary.

Due to the different context in (1) and so as not to make too many assumptions, I think
that the safest thing to do is to disable softirqs in all three cases. This prevents
strange problems should the code change somewhat in the future.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/lib/packet_history.c |   17 +++++++++++++++++
 net/dccp/ccids/lib/packet_history.h |    6 +-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index d149b19..a5dc450 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -41,6 +41,8 @@
 /*
  * 	Transmitter History Routines
  */
+DEFINE_RWLOCK(dccp_tx_hist_lock);
+
 struct dccp_tx_hist *dccp_tx_hist_new(const char *name)
 {
 	struct dccp_tx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
@@ -101,6 +103,7 @@ int dccp_tx_hist_get_send_time(struct dccp_tx_hist *hist,
 	struct dccp_tx_hist_entry *entry;
 	int found = 0;
 
+	write_lock_bh(&dccp_tx_hist_lock);
 	list_for_each_entry(entry, list, dccphtx_node)
 		if (entry->dccphtx_seqno = seq) {
 			found = 1;
@@ -110,24 +113,38 @@ int dccp_tx_hist_get_send_time(struct dccp_tx_hist *hist,
 
 	if (found)
 		dccp_tx_hist_purge_older(hist, list, entry);
+	write_unlock_bh(&dccp_tx_hist_lock);
 
 	return found;
 }
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_get_send_time);
 
+void dccp_tx_hist_add_entry(struct list_head *list,
+			    struct dccp_tx_hist_entry *entry)
+{
+	write_lock_bh(&dccp_tx_hist_lock);
+	list_add(&entry->dccphtx_node, list);
+	write_unlock_bh(&dccp_tx_hist_lock);
+}
+
+EXPORT_SYMBOL_GPL(dccp_tx_hist_add_entry);
+
 void dccp_tx_hist_purge(struct dccp_tx_hist *hist, struct list_head *list)
 {
 	struct dccp_tx_hist_entry *entry, *next;
 
+	write_lock_bh(&dccp_tx_hist_lock);
 	list_for_each_entry_safe(entry, next, list, dccphtx_node) {
 		list_del_init(&entry->dccphtx_node);
 		dccp_tx_hist_entry_delete(hist, entry);
 	}
+	write_unlock_bh(&dccp_tx_hist_lock);
 }
 
 EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
 
+/* XXX careful, this one is not lock-protected */
 void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
 			      struct list_head *list,
 			      struct dccp_tx_hist_entry *packet)
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index da81709..402ac90 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -83,11 +83,7 @@ static inline struct dccp_tx_hist_entry *
 extern int dccp_tx_hist_get_send_time(struct dccp_tx_hist *, struct list_head *,
 				      u64 seq, struct timeval *t_send);
 
-static inline void dccp_tx_hist_add_entry(struct list_head *list,
-					  struct dccp_tx_hist_entry *entry)
-{
-	list_add(&entry->dccphtx_node, list);
-}
+extern void dccp_tx_hist_add_entry(struct list_head *, struct dccp_tx_hist_entry *);
 
 static inline void dccp_tx_hist_entry_delete(struct dccp_tx_hist *hist,
 					     struct dccp_tx_hist_entry *entry)
-- 
1.5.0.6

