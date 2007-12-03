From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Dec 2007 11:28:36 +0000
Subject: [PATCH 2/6] [TFRC]: New RX history implementation
Message-Id: <11966813201749-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides a new, self-contained and generic RX history service for TFRC
based protocols.

Details:
 * new data structure, initialisation and cleanup routines;
 * allocation of dccp_rx_hist entries local to packet_history.c,
   as a service exported by the dccp_tfrc_lib module.
 * interface to automatically track highest-received seqno;
 * receiver-based RTT estimation (needed for instance by RFC 3448, 6.3.1);
 * a generic function to test for `data packets' as per  RFC 4340, sec. 7.7.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
 net/dccp/ccids/lib/packet_history.c |  120 ++++++++++++++++++++++++++---
 net/dccp/ccids/lib/packet_history.h |  143 ++++++++++++++++++++++++++++++++++-
 net/dccp/ccids/lib/tfrc_module.c    |   27 ++++++-
 net/dccp/dccp.h                     |   12 +++
 4 files changed, 281 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index ebcb6c0..2f9e0a0 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -34,7 +34,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
 #include <linux/string.h>
 #include "packet_history.h"
 
@@ -55,6 +54,22 @@ struct tfrc_tx_hist_entry {
  */
 static struct kmem_cache *tfrc_tx_hist;
 
+int __init tx_packet_history_init(void)
+{
+	tfrc_tx_hist = kmem_cache_create("tfrc_tx_hist",
+					 sizeof(struct tfrc_tx_hist_entry), 0,
+					 SLAB_HWCACHE_ALIGN, NULL);
+	return tfrc_tx_hist = NULL ? -ENOBUFS : 0;
+}
+
+void tx_packet_history_cleanup(void)
+{
+	if (tfrc_tx_hist != NULL) {
+		kmem_cache_destroy(tfrc_tx_hist);
+		tfrc_tx_hist = NULL;
+	}
+}
+
 static struct tfrc_tx_hist_entry *
 	tfrc_tx_hist_find_entry(struct tfrc_tx_hist_entry *head, u64 seqno)
 {
@@ -264,6 +279,49 @@ void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
 
+static struct kmem_cache *tfrc_rxh_cache;
+
+int __init rx_packet_history_init(void)
+{
+	tfrc_rxh_cache = kmem_cache_create("tfrc_rxh_cache",
+					   sizeof(struct tfrc_rx_hist_entry),
+					   0, SLAB_HWCACHE_ALIGN, NULL);
+	return tfrc_rxh_cache = NULL ? -ENOBUFS : 0;
+}
+
+void rx_packet_history_cleanup(void)
+{
+	if (tfrc_rxh_cache != NULL) {
+		kmem_cache_destroy(tfrc_rxh_cache);
+		tfrc_rxh_cache = NULL;
+	}
+}
+
+int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	for (i = 0; i <= NDUPACK; i++) {
+		h->ring[i] = kmem_cache_alloc(tfrc_rxh_cache, GFP_ATOMIC);
+		if (h->ring[i] = NULL)
+			return 1;
+	}
+	h->loss_count = 0;
+	h->loss_start = 0;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);
+
+void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	for (i=0; i <= NDUPACK; i++)
+		if (h->ring[i] != NULL)
+			kmem_cache_free(tfrc_rxh_cache, h->ring[i]);
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
+
 void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
 {
 	struct dccp_rx_hist_entry *entry, *next;
@@ -276,18 +334,56 @@ void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
 
-int __init packet_history_init(void)
+/**
+ * tfrc_rx_sample_rtt  -  Sample RTT from timestamp / CCVal
+ * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
+ * to compute a sample with given data - calling function should check this.
+ */
+u32 tfrc_rx_sample_rtt(struct tfrc_rx_hist *h, struct sk_buff *skb)
 {
-	tfrc_tx_hist = kmem_cache_create("tfrc_tx_hist",
-					 sizeof(struct tfrc_tx_hist_entry), 0,
-					 SLAB_HWCACHE_ALIGN, NULL);
-	return tfrc_tx_hist = NULL ? -ENOBUFS : 0;
-}
+	u32 sample = 0,
+	    delta_v = SUB16(dccp_hdr(skb)->dccph_ccval, rtt_last_s(h)->ccval);
+
+	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
+
+		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
+			sample = SUB16(rtt_prev_s(h)->ccval,
+				       rtt_last_s(h)->ccval);
+			if (sample)
+				sample = 4 / sample
+				       * ktime_us_delta(rtt_prev_s(h)->stamp,
+							rtt_last_s(h)->stamp);
+			else    /*
+				 * FIXME: This condition is in principle not
+				 * possible but occurs when CCID is used for
+				 * two-way data traffic. I have tried to trace
+				 * it, but the cause does not seem to be here.
+				 */
+				DCCP_BUG("please report to dccp@vger.kernel.org"
+					 " => prev = %u, last = %u",
+					 rtt_prev_s(h)->ccval,
+					 rtt_last_s(h)->ccval);
+		} else if (delta_v < 1) {
+			h->rtt_sample_prev = 1;
+			goto keep_ref_for_next_time;
+		}
 
-void __exit packet_history_exit(void)
-{
-	if (tfrc_tx_hist != NULL) {
-		kmem_cache_destroy(tfrc_tx_hist);
-		tfrc_tx_hist = NULL;
+	} else if (delta_v = 4) {     /* optimal match */
+		sample = ktime_to_us(net_timedelta(rtt_last_s(h)->stamp));
+
+	} else	{		       /* suboptimal match */
+		h->rtt_sample_prev = 2;
+		goto keep_ref_for_next_time;
+	}
+
+	if (unlikely(sample > DCCP_SANE_RTT_MAX)) {
+		DCCP_WARN("RTT sample %u too large, using max\n", sample);
+		sample = DCCP_SANE_RTT_MAX;
 	}
+
+	h->rtt_sample_prev = 0;	       /* use current entry as next reference */
+keep_ref_for_next_time:
+
+	return sample;
 }
+EXPORT_SYMBOL_GPL(tfrc_rx_sample_rtt);
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 9a2642e..dd4ca63 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -1,3 +1,5 @@
+#ifndef _DCCP_PKT_HIST_
+#define _DCCP_PKT_HIST_
 /*
  *  Packet RX/TX history data structures and routines for TFRC-based protocols.
  *
@@ -32,10 +34,6 @@
  *  along with this program; if not, write to the Free Software
  *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
  */
-
-#ifndef _DCCP_PKT_HIST_
-#define _DCCP_PKT_HIST_
-
 #include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/slab.h>
@@ -43,9 +41,13 @@
 
 /* Number of later packets received before one is considered lost */
 #define TFRC_RECV_NUM_LATE_LOSS	 3
+/* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
+#define NDUPACK 3
 
 #define TFRC_WIN_COUNT_PER_RTT	 4
 #define TFRC_WIN_COUNT_LIMIT	16
+/* Subtraction a-b modulo-16, respects circular wrap-around */
+#define SUB16(a,b)		(((a) + 16 - (b)) & 0xF)
 
 struct tfrc_tx_hist_entry;
 
@@ -66,6 +68,22 @@ struct dccp_rx_hist_entry {
 	ktime_t		 dccphrx_tstamp;
 };
 
+
+/**
+ *   tfrc_rx_hist_entry  -  Store information about a single received packet
+ *   @seqno:	DCCP packet sequence number
+ *   @ccval:	window counter value of packet (RFC 4342, 8.1)
+ *   @ndp:	the NDP count (if any) of the packet
+ *   @stamp:	actual receive time of packet
+ */
+struct tfrc_rx_hist_entry {
+	u64		seqno:48,
+			ccval:4,
+			ptype:4;
+	u32		ndp;
+	ktime_t		stamp;
+};
+
 struct dccp_rx_hist {
 	struct kmem_cache *dccprxh_slab;
 };
@@ -73,6 +91,123 @@ struct dccp_rx_hist {
 extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
 extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
 
+/**
+ *   tfrc_rx_hist  -  RX history structure for TFRC-based protocols
+ *
+ *   @ring:		Packet history for RTT sampling and loss detection
+ *   @loss_count:	Number of entries in circular history
+ *   @loss_start:	Movable index (for loss detection)
+ *   @rtt_sample_prev:  Used during RTT sampling, points to candidate entry
+ */
+struct tfrc_rx_hist {
+	struct tfrc_rx_hist_entry	*ring[NDUPACK + 1];
+	u8				loss_count:2,
+					loss_start:2;
+#define rtt_sample_prev			loss_start
+};
+
+/*
+ * Macros for loss detection.
+ * @loss_prev:  entry with highest-received-seqno before loss was detected
+ * @hist_index: index to reach n-th entry after loss_start
+ * @hist_entry: return the n-th history entry  after loss_start
+ * @last_rcv:   entry with highest-received-seqno so far
+ */
+#define loss_prev(h)		(h)->ring[(h)->loss_start]
+#define hist_index(h, n)	(((h)->loss_start + (n)) & NDUPACK)
+#define hist_entry(h, n)	(h)->ring[hist_index(h, n)]
+#define last_rcv(h)		(h)->ring[hist_index(h, (h)->loss_count)]
+
+/*
+ * Macros to access history entries for RTT sampling.
+ * @rtt_last_s: reference entry to compute RTT samples against
+ * @rtt_prev_s: previously suitable (wrt rtt_last_s) RTT-sampling entry
+ */
+#define rtt_last_s(h)		(h)->ring[0]
+#define rtt_prev_s(h)		(h)->ring[(h)->rtt_sample_prev]
+
+/* initialise loss detection and disable RTT sampling */
+static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
+{
+	h->loss_count = 1;
+}
+
+/* indicate whether previously a packet was detected missing */
+static inline int tfrc_rx_loss_pending(struct tfrc_rx_hist *h)
+{
+	return h->loss_count;
+}
+
+/* any data packets missing between last reception and skb ? */
+static inline int tfrc_rx_new_loss_indicated(struct tfrc_rx_hist *h,
+					     struct sk_buff *skb, u32 ndp)
+{
+	int delta = dccp_delta_seqno(last_rcv(h)->seqno,
+				     DCCP_SKB_CB(skb)->dccpd_seq);
+
+	if (delta > 1 && ndp < delta)
+		tfrc_rx_hist_loss_indicated(h);
+
+	return tfrc_rx_loss_pending(h);
+}
+
+/* has the packet contained in skb been seen before ? */
+static inline int tfrc_rx_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
+{
+	const u64 seq = DCCP_SKB_CB(skb)->dccpd_seq;
+	int i;
+
+	if (dccp_delta_seqno(loss_prev(h)->seqno, seq) <= 0)
+		return 1;
+
+	for (i = 1; i <= h->loss_count; i++)
+		if (hist_entry(h, i)->seqno = seq)
+			return 1;
+
+	return 0;
+}
+
+/* return the signed modulo-2^48 sequence number distance from entry e1 to e2 */
+static inline s64 tfrc_rx_hist_delta_seqno(struct tfrc_rx_hist *h, u8 e1, u8 e2)
+{
+	DCCP_BUG_ON(e1 > h->loss_count || e2 > h->loss_count);
+
+	return dccp_delta_seqno(hist_entry(h, e1)->seqno,
+				hist_entry(h, e2)->seqno);
+}
+
+static inline void tfrc_rx_hist_swap(struct tfrc_rx_hist_entry **a,
+				     struct tfrc_rx_hist_entry **b)
+{
+	struct tfrc_rx_hist_entry *tmp = *a;
+
+	*a = *b;
+	*b = tmp;
+}
+
+static inline void tfrc_rx_hist_entry_from_skb(struct tfrc_rx_hist_entry *new,
+					        struct sk_buff *skb, u32 ndp)
+{
+	const struct dccp_hdr *dh = dccp_hdr(skb);
+
+	new->seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+	new->ccval = dh->dccph_ccval;
+	new->ptype = dh->dccph_type;
+	new->ndp   = ndp;
+	new->stamp = ktime_get_real();
+}
+
+/* commit packet details of skb to history (record highest received seqno) */
+static inline void tfrc_rx_hist_update(struct tfrc_rx_hist *h,
+				       struct sk_buff *skb, u32 ndp)
+{
+	tfrc_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
+}
+
+extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
+extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
+extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
+
 static inline struct dccp_rx_hist_entry *
 			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
 					       const u32 ndp,
diff --git a/net/dccp/ccids/lib/tfrc_module.c b/net/dccp/ccids/lib/tfrc_module.c
index 7e0dfa0..c02b70c 100644
--- a/net/dccp/ccids/lib/tfrc_module.c
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -8,8 +8,10 @@
 #include "tfrc.h"
 
 /* Initialisation / Clean-up routines */
-extern int  packet_history_init(void);
-extern void packet_history_exit(void);
+extern int  tx_packet_history_init(void);
+extern int  rx_packet_history_init(void);
+extern void tx_packet_history_cleanup(void);
+extern void rx_packet_history_cleanup(void);
 
 extern int  dccp_li_init(void);
 extern void dccp_li_exit(void);
@@ -24,17 +26,32 @@ static int __init tfrc_module_init(void)
 {
 	int rc = dccp_li_init();
 
-	if (rc = 0)
-		rc = packet_history_init();
+	if (rc)
+		goto out;
 
+	rc = tx_packet_history_init();
+	if (rc)
+		goto out_free_loss_intervals;
+
+	rc = rx_packet_history_init();
+	if (rc)
+		goto out_free_tx_history;
+	return 0;
+
+out_free_tx_history:
+	tx_packet_history_cleanup();
+out_free_loss_intervals:
+	dccp_li_exit();
+out:
 	return rc;
 }
 module_init(tfrc_module_init);
 
 static void __exit tfrc_module_exit(void)
 {
-	packet_history_exit();
 	dccp_li_exit();
+	tx_packet_history_cleanup();
+	rx_packet_history_cleanup();
 }
 module_exit(tfrc_module_exit);
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index ee97950..f4a5ea1 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -334,6 +334,7 @@ struct dccp_skb_cb {
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
 
+/* RFC 4340, sec. 7.7 */
 static inline int dccp_non_data_packet(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
@@ -346,6 +347,17 @@ static inline int dccp_non_data_packet(const struct sk_buff *skb)
 	       type = DCCP_PKT_SYNCACK;
 }
 
+/* RFC 4340, sec. 7.7 */
+static inline int dccp_data_packet(const struct sk_buff *skb)
+{
+	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
+
+	return type = DCCP_PKT_DATA	 ||
+	       type = DCCP_PKT_DATAACK  ||
+	       type = DCCP_PKT_REQUEST  ||
+	       type = DCCP_PKT_RESPONSE;
+}
+
 static inline int dccp_packet_without_ack(const struct sk_buff *skb)
 {
 	const __u8 type = DCCP_SKB_CB(skb)->dccpd_type;
-- 
