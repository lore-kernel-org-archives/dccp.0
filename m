From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:34:41 +0000
Subject: [PATCH 16/43]: Ringbuffer to track loss interval history
Message-Id: <200704051634.41814@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Ringbuffer to track loss interval history

A ringbuffer-based implementation of loss interval history is easier to
maintain, allocate, and update.

This patch provides the basic data structures for a ringbuffer-based loss
interval history, from which the principles of the implementation are
already visible.

The patch compiles standalone, as functions tackled by subsequent patches
have been commented out for the moment, this will be done step-by-step by
the subsequent remaining patches.

Detailed documentation is in section 6 of 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |    2 +
 net/dccp/ccids/lib/loss_interval.c |   17 +++++++++--
 net/dccp/ccids/lib/loss_interval.h |   55 ++++++++++++++++++++++++++++++-------
 3 files changed, 62 insertions(+), 12 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -18,6 +18,8 @@
 
 struct dccp_li_hist *dccp_li_hist_new(const char *name)
 {
+#if 0	/* XXX also subsequent patch */
+	return NULL;
 	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
 	static const char dccp_li_hist_mask[] = "li_hist_%s";
 	char *slab_name;
@@ -45,21 +47,25 @@ out_free_hist:
 	kfree(hist);
 	hist = NULL;
 	goto out;
+#endif
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_new);
 
 void dccp_li_hist_delete(struct dccp_li_hist *hist)
 {
+#if 0 /* XXX next patch */
 	const char* name = kmem_cache_name(hist->dccplih_slab);
 
 	kmem_cache_destroy(hist->dccplih_slab);
 	kfree(name);
 	kfree(hist);
+#endif
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_delete);
 
+#if 0 /* XXX subsequent patch */
 void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
@@ -69,6 +75,7 @@ void dccp_li_hist_purge(struct dccp_li_h
 		kmem_cache_free(hist->dccplih_slab, entry);
 	}
 }
+#endif
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_purge);
 
@@ -77,12 +84,13 @@ EXPORT_SYMBOL_GPL(dccp_li_hist_purge);
  * These are integers as per section 8 of RFC3448. We can then divide by 4 *
  * when we use it.
  */
-static const int dccp_li_hist_w[DCCP_LI_HIST_IVAL_F_LENGTH] = {
-	4, 4, 4, 4, 3, 2, 1, 1,
-};
+static const int tfrc_lh_weights[NINTERVAL] = { 4, 4, 4, 4, 3, 2, 1, 1 };
 
 u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 {
+#ifndef DONE_WITH_TRANSITION /* XXX subsequent patch */
+	return 0;
+#else
 	struct dccp_li_hist_entry *li_entry, *li_next;
 	int i = 0;
 	u32 i_tot;
@@ -114,10 +122,12 @@ u32 dccp_li_hist_calc_i_mean(struct list
 	}
 
 	return i_tot / w_tot;
+#endif
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
+/* XXX next patch
 int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
    struct list_head *list, const u64 seq_loss, const u8 win_loss)
 {
@@ -141,3 +151,4 @@ int dccp_li_hist_interval_new(struct dcc
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
+*/
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -861,6 +861,7 @@ static u32 ccid3_hc_rx_calc_first_li(str
 
 static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 {
+#if 0 /* XXX subsequent patch */
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
@@ -904,6 +905,7 @@ static void ccid3_hc_rx_update_li(struct
 		entry->dccplih_interval = seq_temp;
 		entry->dccplih_win_count = win_loss;
 	}
+#endif
 }
 
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -17,28 +17,65 @@
 #include <linux/slab.h>
 #include <linux/time.h>
 
-#define DCCP_LI_HIST_IVAL_F_LENGTH  8
-
-struct dccp_li_hist {
-	struct kmem_cache *dccplih_slab;
+/*
+ * Number of loss intervals (RFC 4342, 8.6.1). The history size is one more than
+ * NINTERVAL, since the `open' interval I_0 is always stored as the first entry.
+ * LIH_INDEX is used to implement LIFO semantics on the array.
+ */
+#define NINTERVAL	8
+#define LIH_SIZE	(NINTERVAL + 1)
+#define LIH_INDEX(ctr)	(LIH_SIZE - 1 - ((ctr) % LIH_SIZE))
+
+/**
+ *  tfrc_loss_interval  -  Loss history record for TFRC-based protocols
+ *  @li_seqno:		Highest received seqno before the start of loss
+ *  @li_ccval:		The CCVal belonging to @li_seqno
+ *  @li_is_closed:	Whether @li_seqno is older than 1 RTT
+ *  @li_length:		Loss interval sequence length
+ */
+struct tfrc_loss_interval {
+	u64		 li_seqno:48,
+			 li_ccval:4,
+			 li_is_closed:1;
+	u32		 li_length;
 };
 
 extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
 extern void dccp_li_hist_delete(struct dccp_li_hist *hist);
 
-struct dccp_li_hist_entry {
-	struct list_head dccplih_node;
-	u64		 dccplih_seqno:48,
-			 dccplih_win_count:4;
-	u32		 dccplih_interval;
+/**
+ *  tfrc_loss_hist  -  Loss record database
+ *  @ring:	Circular queue managed in LIFO manner
+ *  @counter:	Current count of entries (can be more than %LIH_SIZE)
+ */
+struct tfrc_loss_hist {
+	struct tfrc_loss_interval	*ring[LIH_SIZE];
+	u8				counter;
 };
 
+static inline void tfrc_lh_init(struct tfrc_loss_hist *lh)
+{
+	memset(lh, 0, sizeof(struct tfrc_loss_hist));
+}
+
+static inline u8 tfrc_lh_is_initialised(struct tfrc_loss_hist *lh)
+{
+	return lh->counter > 0;
+}
+
+static inline u8 tfrc_lh_length(struct tfrc_loss_hist *lh)
+{
+	return min(lh->counter, (u8)LIH_SIZE);
+}
+
+#if 0 /*XXX next patch */
 static inline struct dccp_li_hist_entry *
 		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
 				       const gfp_t prio)
 {
 	return kmem_cache_alloc(hist->dccplih_slab, prio);
 }
+#endif
 
 static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
 					     struct dccp_li_hist_entry *entry)
