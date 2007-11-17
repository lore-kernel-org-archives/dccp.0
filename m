From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 17 Nov 2007 09:29:37 +0000
Subject: [PATCH 10/16] [TFRC]: Remove old RX history interface
Message-Id: <11952917841853-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/lib/loss_interval.c  |    9 ++
 net/dccp/ccids/lib/packet_history.c |  162 -----------------------------------
 net/dccp/ccids/lib/packet_history.h |   84 ------------------
 3 files changed, 9 insertions(+), 246 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index e8a9d09..cd8d668 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -129,6 +129,12 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 				 u16 s, u32 bytes_recv,
 				 u32 previous_x_recv)
 {
+	/*
+	 * XXX This function still relies on the old RX interface and thus can not be
+	 * kept. But it can also not be removed since the loss interval code calls it.
+	 * Since it will be replaced anyway, comment it out for this moment.
+	 */
+#ifdef __THIS_IS_RESOLVED_IN_NEXT_PATCH__
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
@@ -220,6 +226,9 @@ found:
 		return ~0;
 	else
 		return 1000000 / p;
+#else
+	return ~0;
+#endif
 }
 
 void dccp_li_update_li(struct sock *sk,
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 5650f06..4ba9072 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -138,156 +138,6 @@ EXPORT_SYMBOL_GPL(tfrc_tx_hist_when);
 /*
  * 	Receiver History Routines
  */
-struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
-{
-	struct dccp_rx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
-	static const char dccp_rx_hist_mask[] = "rx_hist_%s";
-	char *slab_name;
-
-	if (hist = NULL)
-		goto out;
-
-	slab_name = kmalloc(strlen(name) + sizeof(dccp_rx_hist_mask) - 1,
-			    GFP_ATOMIC);
-	if (slab_name = NULL)
-		goto out_free_hist;
-
-	sprintf(slab_name, dccp_rx_hist_mask, name);
-	hist->dccprxh_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_rx_hist_entry),
-					     0, SLAB_HWCACHE_ALIGN, NULL);
-	if (hist->dccprxh_slab = NULL)
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
-EXPORT_SYMBOL_GPL(dccp_rx_hist_new);
-
-void dccp_rx_hist_delete(struct dccp_rx_hist *hist)
-{
-	const char* name = kmem_cache_name(hist->dccprxh_slab);
-
-	kmem_cache_destroy(hist->dccprxh_slab);
-	kfree(name);
-	kfree(hist);
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_delete);
-
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
-					tmp = win_count - entry->dccphrx_ccval;
-					if (tmp < 0)
-						tmp += TFRC_WIN_COUNT_LIMIT;
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
 static struct kmem_cache *tfrcxh;
 
 int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
@@ -315,18 +165,6 @@ void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *h)
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
 
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
 /**
  * tfrc_rx_sample_rtt  -  Sample RTT from timestamp / CCVal
  * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index b19cb40..8088b03 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -39,13 +39,9 @@
 #include <linux/slab.h>
 #include "tfrc.h"
 
-/* Number of later packets received before one is considered lost */
-#define TFRC_RECV_NUM_LATE_LOSS	 3
 /* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
 #define NDUPACK 3
 
-#define TFRC_WIN_COUNT_PER_RTT	 4
-#define TFRC_WIN_COUNT_LIMIT	16
 /* Subtraction a-b modulo-16, respects circular wrap-around */
 #define SUB16(a,b)		(((a) + 16 - (b)) & 0xF)
 
@@ -93,15 +89,6 @@ extern void tfrc_tx_hist_cleanup(struct tfrc_tx_hist_head *head);
 /*
  * 	Receiver History data structures and declarations
  */
-struct dccp_rx_hist_entry {
-	struct list_head dccphrx_node;
-	u64		 dccphrx_seqno:48,
-			 dccphrx_ccval:4,
-			 dccphrx_type:4;
-	u32		 dccphrx_ndp; /* In fact it is from 8 to 24 bits */
-	ktime_t		 dccphrx_tstamp;
-};
-
 
 /**
  *   tfrc_rx_hist_entry  -  Store information about a single received packet
@@ -118,13 +105,6 @@ struct tfrc_rx_hist_entry {
 	ktime_t		stamp;
 };
 
-struct dccp_rx_hist {
-	struct kmem_cache *dccprxh_slab;
-};
-
-extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
-extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
-
 /**
  *   tfrc_rx_hist  -  RX history structure for TFRC-based protocols
  *
@@ -242,68 +222,4 @@ extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
 
-static inline struct dccp_rx_hist_entry *
-			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
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
-		entry->dccphrx_tstamp = ktime_get_real();
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
-- 
1.5.2.2.238.g7cbf2f2-dirty

