From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:17 +0000
Subject: [PATCH 1/9]: New receiver history data structure
Message-Id: <200706151531.17593@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: New receiver history data structure

This provides a generic RX history unit for TFRC based protocols.

The data structure is heavily optimised to reduce the overhead to the
smallest possible minimum.

A full list implementation is in fact not needed: both for RTT estimation
and for loss detection, only a minimum of 4 entries is needed. The overhead
of allocating and later garbage-collecting further entries is not justified,
and it introduces a memory and processing bottleneck.

The present design is lightweight and object-oriented:
 * only the minimum number of entries is used;
 * circular array of pointers:
   - faster swapping of entries for sorting,
   - the indexed-array semantics matches the requirments of loss detection
     (3 consecutive packets) and RTT estimation (also consecutive packets)
     much more naturally than a doubly-linked list;
 * one and the same structure is used both for RTT sampling and for
   loss detection, reducing memory demands;
 * generic definition, can later be reused for small-packet variant of
   CCID 3 etc.

This patch lays the foundation in terms of the main data structure with some rudimentary
routines for basic access. Further patches will fill in the details with regard to CCID3.

Details of the algorithm are documented and illustrated in section 3 of
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h              |    2 
 net/dccp/ccids/lib/packet_history.h |  121 +++++++++++++++++++++++++++++++++---
 2 files changed, 113 insertions(+), 10 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -158,7 +158,7 @@ struct ccid3_hc_rx_sock {
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
 	ktime_t				ccid3hcrx_last_feedback;
-	struct list_head		ccid3hcrx_hist;
+	struct tfrc_rx_hist		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_pinv;
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -42,8 +42,8 @@
 #include <linux/time.h>
 #include "tfrc.h"
 
-/* Number of later packets received before one is considered lost */
-#define TFRC_RECV_NUM_LATE_LOSS	 3
+/* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
+#define NDUPACK 3
 
 #define TFRC_WIN_COUNT_PER_RTT	 4
 #define TFRC_WIN_COUNT_LIMIT	16
@@ -92,13 +92,20 @@ extern void tfrc_tx_hist_cleanup(struct 
 /*
  * 	Receiver History data structures and declarations
  */
-struct dccp_rx_hist_entry {
-	struct list_head dccphrx_node;
-	u64		 dccphrx_seqno:48,
-			 dccphrx_ccval:4,
-			 dccphrx_type:4;
-	u32		 dccphrx_ndp; /* In fact it is from 8 to 24 bits */
-	struct timeval	 dccphrx_tstamp;
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
 };
 
 struct dccp_rx_hist {
@@ -108,6 +115,102 @@ struct dccp_rx_hist {
 extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
 extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
 
+/**
+ *   tfrc_rx_hist  -  RX history structure for TFRC-based protocols
+ *
+ *   @ring:		Packet history for RTT sampling and loss detection
+ *   @loss_count:	Number of entries in circular history
+ *   @loss_start:	Movable index (for loss detection)
+ *   @rtt_sample_prev:  Used during RTT sampling, points to candidate entry
+ *   @lock:		Serialize concurrent access
+ */
+struct tfrc_rx_hist {
+	struct tfrc_rx_hist_entry	*ring[NDUPACK + 1];
+	u8				loss_count:2,
+					loss_start:2;
+#define rtt_sample_prev			loss_start
+	spinlock_t			lock;
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
 static inline struct dccp_rx_hist_entry *
 			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
 					       const struct sock *sk,
