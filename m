From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 17 Jun 2007 12:51:32 +0000
Subject: [PATCH 1/9]: Ringbuffer to track loss interval history
Message-Id: <200706171351.32800@strip-the-willow>
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
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid3_packet_reception/

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.h             |    4 +-
 net/dccp/ccids/lib/loss_interval.h |   53 ++++++++++++++++++++++++++++++-------
 2 files changed, 46 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -17,22 +17,57 @@
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
 static inline struct dccp_li_hist_entry *
 		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
 				       const gfp_t prio)
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -142,7 +142,7 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
  *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history, exported by TFRC module
- *  @ccid3hcrx_li_hist  -  Loss Interval History
+ *  @ccid3hcrx_li_hist  -  Loss Interval database, exported by TFRC module
  *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  */
@@ -156,7 +156,7 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_bytes_recv;
 	ktime_t				ccid3hcrx_last_feedback;
 	struct tfrc_rx_hist		ccid3hcrx_hist;
-	struct list_head		ccid3hcrx_li_hist;
+	struct tfrc_loss_hist		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_pinv;
 };
