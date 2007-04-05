From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:34:35 +0000
Subject: [PATCH 15/43]: New RX History Step 7  -   Remove old infrastructure
Message-Id: <200704051634.35402@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 7  -   Remove old infrastructure

This removes the older RX history infrastructure based on doubly-linked lists.
Keeping both infrastructures would lead to confusion.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |  117 ------------------------------------
 net/dccp/ccids/lib/packet_history.h |   71 ---------------------
 2 files changed, 188 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -206,123 +206,6 @@ static void dccp_rx_hist_delete(struct d
 	kfree(hist);
 }
 
-int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
-			    u8 *ccval)
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
-struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list)
-{
-	struct dccp_rx_hist_entry *entry, *packet = NULL;
-
-	list_for_each_entry(entry, list, dccphrx_node)
-		if (entry->dccphrx_type = DCCP_PKT_DATA ||
-		    entry->dccphrx_type = DCCP_PKT_DATAACK) {
-			packet = entry;
-			break;
-		}
-
-	return packet;
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_find_data_packet);
-
-void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
-			    struct list_head *rx_list,
-			    struct list_head *li_list,
-			    struct dccp_rx_hist_entry *packet,
-			    u64 nonloss_seqno)
-{
-	struct dccp_rx_hist_entry *entry, *next;
-	u8 num_later = 0;
-
-	list_add(&packet->dccphrx_node, rx_list);
-
-	num_later = TFRC_RECV_NUM_LATE_LOSS + 1;
-
-	if (!list_empty(li_list)) {
-		list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
-			if (num_later = 0) {
-				if (after48(nonloss_seqno,
-				   entry->dccphrx_seqno)) {
-					list_del_init(&entry->dccphrx_node);
-					dccp_rx_hist_entry_delete(hist, entry);
-				}
-			} else if (dccp_rx_hist_entry_data_packet(entry))
-				--num_later;
-		}
-	} else {
-		int step = 0;
-		u8 win_count = 0; /* Not needed, but lets shut up gcc */
-		int tmp;
-		/*
-		 * We have no loss interval history so we need at least one
-		 * rtt:s of data packets to approximate rtt.
-		 */
-		list_for_each_entry_safe(entry, next, rx_list, dccphrx_node) {
-			if (num_later = 0) {
-				switch (step) {
-				case 0:
-					step = 1;
-					/* OK, find next data packet */
-					num_later = 1;
-					break;
-				case 1:
-					step = 2;
-					/* OK, find next data packet */
-					num_later = 1;
-					win_count = entry->dccphrx_ccval;
-					break;
-				case 2:
-					tmp = SUB16(win_count, entry->dccphrx_ccval);
-					if (tmp > TFRC_WIN_COUNT_PER_RTT + 1) {
-						/*
-						 * We have found a packet older
-						 * than one rtt remove the rest
-						 */
-						step = 3;
-					} else /* OK, find next data packet */
-						num_later = 1;
-					break;
-				case 3:
-					list_del_init(&entry->dccphrx_node);
-					dccp_rx_hist_entry_delete(hist, entry);
-					break;
-				}
-			} else if (dccp_rx_hist_entry_data_packet(entry))
-				--num_later;
-		}
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
-
-void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
-{
-	struct dccp_rx_hist_entry *entry, *next;
-
-	list_for_each_entry_safe(entry, next, list, dccphrx_node) {
-		list_del_init(&entry->dccphrx_node);
-		kmem_cache_free(hist->dccprxh_slab, entry);
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
-
 int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
 {
 	int i;
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -42,13 +42,9 @@
 #include <linux/time.h>
 #include "tfrc.h"
 
-/* Number of later packets received before one is considered lost */
-#define TFRC_RECV_NUM_LATE_LOSS	 3
-
 /* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
 #define NDUPACK 3
 
-#define TFRC_WIN_COUNT_PER_RTT	 4
 /* Subtraction a-b modulo-16, respects circular wrap-around */
 #define SUB16(a,b)		(((a) + 16 - (b)) & 0xF)
 
@@ -94,7 +90,6 @@ extern void dccp_tx_hist_purge(struct dc
  * 	Receiver History data structures and declarations
  */
 struct dccp_rx_hist_entry {
-	struct list_head dccphrx_node;
 	u64		 dccphrx_seqno:48,
 			 dccphrx_ccval:4,
 			 dccphrx_type:4;
@@ -226,70 +221,4 @@ extern u32  tfrc_rx_sample_rtt(struct tf
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
 
-/* Older history management functions */
-static inline struct dccp_rx_hist_entry *
-			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
-					       const struct sock *sk,
-					       const u32 ndp,
-					       const struct sk_buff *skb,
-					       const gfp_t prio)
-{
-	struct dccp_rx_hist_entry *entry = kmem_cache_alloc(hist->dccprxh_slab,
-							    prio);
-
-	if (entry != NULL) {
-		const struct dccp_hdr *dh = dccp_hdr(skb);
-
-		entry->dccphrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-		entry->dccphrx_ccval = dh->dccph_ccval;
-		entry->dccphrx_type  = dh->dccph_type;
-		entry->dccphrx_ndp   = ndp;
-		skb_get_timestamp(skb, &entry->dccphrx_tstamp);
-	}
-
-	return entry;
-}
-
-static inline struct dccp_rx_hist_entry *
-			dccp_rx_hist_head(struct list_head *list)
-{
-	struct dccp_rx_hist_entry *head = NULL;
-
-	if (!list_empty(list))
-		head = list_entry(list->next, struct dccp_rx_hist_entry,
-				  dccphrx_node);
-	return head;
-}
-
-extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
-				   u8 *ccval);
-extern struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list);
-
-extern void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
-				    struct list_head *rx_list,
-				    struct list_head *li_list,
-				    struct dccp_rx_hist_entry *packet,
-				    u64 nonloss_seqno);
-
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
-static inline int
-	dccp_rx_hist_entry_data_packet(const struct dccp_rx_hist_entry *entry)
-{
-	return entry->dccphrx_type = DCCP_PKT_DATA ||
-	       entry->dccphrx_type = DCCP_PKT_DATAACK;
-}
-
-extern u64 dccp_rx_hist_detect_loss(struct list_head *rx_list,
-				    struct list_head *li_list, u8 *win_loss);
-
 #endif /* _DCCP_PKT_HIST_ */
