From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:03:45 +0000
Subject: [PATCH 20/22] [DCCP] ccid3: Reorder packet history header file
Message-Id: <20061210030344.GV17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

No code change at all.

To make the header file easier to read, the following ordering is established
among the declarations:
	* hist_new
	* hist_delete
	* hist_entry_new
	* hist_head
	* hist_find_entry
	* hist_add_entry
	* hist_entry_delete
	* hist_purge

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/lib/packet_history.h |  127 ++++++++++++++++++-----------------
 1 files changed, 67 insertions(+), 60 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 4198185..1f960c1 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -49,6 +49,9 @@ #define TFRC_RECV_NUM_LATE_LOSS	 3
 #define TFRC_WIN_COUNT_PER_RTT	 4
 #define TFRC_WIN_COUNT_LIMIT	16
 
+/*
+ * 	Transmitter History data structures and declarations
+ */
 struct dccp_tx_hist_entry {
 	struct list_head dccphtx_node;
 	u64		 dccphtx_seqno:48,
@@ -57,34 +60,16 @@ struct dccp_tx_hist_entry {
 	struct timeval	 dccphtx_tstamp;
 };
 
-struct dccp_rx_hist_entry {
-	struct list_head dccphrx_node;
-	u64		 dccphrx_seqno:48,
-			 dccphrx_ccval:4,
-			 dccphrx_type:4;
-	u32		 dccphrx_ndp; /* In fact it is from 8 to 24 bits */
-	struct timeval	 dccphrx_tstamp;
-};
-
 struct dccp_tx_hist {
 	struct kmem_cache *dccptxh_slab;
 };
 
 extern struct dccp_tx_hist *dccp_tx_hist_new(const char *name);
-extern void dccp_tx_hist_delete(struct dccp_tx_hist *hist);
-
-struct dccp_rx_hist {
-	struct kmem_cache *dccprxh_slab;
-};
-
-extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
-extern void dccp_rx_hist_delete(struct dccp_rx_hist *hist);
-extern struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list);
+extern void 		    dccp_tx_hist_delete(struct dccp_tx_hist *hist);
 
 static inline struct dccp_tx_hist_entry *
-		dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
-				       const gfp_t prio)
+			dccp_tx_hist_entry_new(struct dccp_tx_hist *hist,
+					       const gfp_t prio)
 {
 	struct dccp_tx_hist_entry *entry = kmem_cache_alloc(hist->dccptxh_slab,
 							    prio);
@@ -95,18 +80,20 @@ static inline struct dccp_tx_hist_entry 
 	return entry;
 }
 
-static inline void dccp_tx_hist_entry_delete(struct dccp_tx_hist *hist,
-					     struct dccp_tx_hist_entry *entry)
+static inline struct dccp_tx_hist_entry *
+			dccp_tx_hist_head(struct list_head *list)
 {
-	if (entry != NULL)
-		kmem_cache_free(hist->dccptxh_slab, entry);
+	struct dccp_tx_hist_entry *head = NULL;
+
+	if (!list_empty(list))
+		head = list_entry(list->next, struct dccp_tx_hist_entry,
+				  dccphtx_node);
+	return head;
 }
 
 extern struct dccp_tx_hist_entry *
 			dccp_tx_hist_find_entry(const struct list_head *list,
 						const u64 seq);
-extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
-   u8 *ccval);
 
 static inline void dccp_tx_hist_add_entry(struct list_head *list,
 					  struct dccp_tx_hist_entry *entry)
@@ -114,30 +101,45 @@ static inline void dccp_tx_hist_add_entr
 	list_add(&entry->dccphtx_node, list);
 }
 
+static inline void dccp_tx_hist_entry_delete(struct dccp_tx_hist *hist,
+					     struct dccp_tx_hist_entry *entry)
+{
+	if (entry != NULL)
+		kmem_cache_free(hist->dccptxh_slab, entry);
+}
+
+extern void dccp_tx_hist_purge(struct dccp_tx_hist *hist,
+			       struct list_head *list);
+
 extern void dccp_tx_hist_purge_older(struct dccp_tx_hist *hist,
 				     struct list_head *list,
 				     struct dccp_tx_hist_entry *next);
 
-extern void dccp_tx_hist_purge(struct dccp_tx_hist *hist,
-			       struct list_head *list);
+/*
+ * 	Receiver History data structures and declarations
+ */
+struct dccp_rx_hist_entry {
+	struct list_head dccphrx_node;
+	u64		 dccphrx_seqno:48,
+			 dccphrx_ccval:4,
+			 dccphrx_type:4;
+	u32		 dccphrx_ndp; /* In fact it is from 8 to 24 bits */
+	struct timeval	 dccphrx_tstamp;
+};
 
-static inline struct dccp_tx_hist_entry *
-		dccp_tx_hist_head(struct list_head *list)
-{
-	struct dccp_tx_hist_entry *head = NULL;
+struct dccp_rx_hist {
+	struct kmem_cache *dccprxh_slab;
+};
 
-	if (!list_empty(list))
-		head = list_entry(list->next, struct dccp_tx_hist_entry,
-				  dccphtx_node);
-	return head;
-}
+extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
+extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
 
 static inline struct dccp_rx_hist_entry *
-		     dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
-				     	    const struct sock *sk, 
-				     	    const u32 ndp, 
-					    const struct sk_buff *skb,
-					    const gfp_t prio)
+			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
+					       const struct sock *sk,
+				     	       const u32 ndp,
+					       const struct sk_buff *skb,
+					       const gfp_t prio)
 {
 	struct dccp_rx_hist_entry *entry = kmem_cache_alloc(hist->dccprxh_slab,
 							    prio);
@@ -155,18 +157,8 @@ static inline struct dccp_rx_hist_entry 
 	return entry;
 }
 
-static inline void dccp_rx_hist_entry_delete(struct dccp_rx_hist *hist,
-					     struct dccp_rx_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccprxh_slab, entry);
-}
-
-extern void dccp_rx_hist_purge(struct dccp_rx_hist *hist,
-			       struct list_head *list);
-
 static inline struct dccp_rx_hist_entry *
-		dccp_rx_hist_head(struct list_head *list)
+			dccp_rx_hist_head(struct list_head *list)
 {
 	struct dccp_rx_hist_entry *head = NULL;
 
@@ -176,6 +168,27 @@ static inline struct dccp_rx_hist_entry 
 	return head;
 }
 
+extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
+   				   u8 *ccval);
+extern struct dccp_rx_hist_entry *
+		dccp_rx_hist_find_data_packet(const struct list_head *list);
+
+extern void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
+				    struct list_head *rx_list,
+				    struct list_head *li_list,
+				    struct dccp_rx_hist_entry *packet,
+				    u64 nonloss_seqno);
+
+static inline void dccp_rx_hist_entry_delete(struct dccp_rx_hist *hist,
+					     struct dccp_rx_hist_entry *entry)
+{
+	if (entry != NULL)
+		kmem_cache_free(hist->dccprxh_slab, entry);
+}
+
+extern void dccp_rx_hist_purge(struct dccp_rx_hist *hist,
+			       struct list_head *list);
+
 static inline int
 	dccp_rx_hist_entry_data_packet(const struct dccp_rx_hist_entry *entry)
 {
@@ -183,12 +196,6 @@ static inline int
 	       entry->dccphrx_type = DCCP_PKT_DATAACK;
 }
 
-extern void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
-				   struct list_head *rx_list,
-				   struct list_head *li_list,
-				   struct dccp_rx_hist_entry *packet,
-				   u64 nonloss_seqno);
-
 extern u64 dccp_rx_hist_detect_loss(struct list_head *rx_list,
 				    struct list_head *li_list, u8 *win_loss);
 
-- 
1.4.2.1.g3d5c

