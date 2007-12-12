From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 12 Dec 2007 16:36:48 +0000
Subject: [PATCH 2/7] [TFRC]: Loss interval code needs the macros/inlines that were moved
Message-Id: <1197477413-1456-3-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This moves the inlines (which were previously declared as macros) back into
packet_history.h since the loss detection code needs to be able to read entries
from the RX history in order to create the relevant loss entries: it needs at
least tfrc_rx_hist_loss_prev() and tfrc_rx_hist_last_rcv(), which in turn
require the definition of the other inlines (macros).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/packet_history.c |   35 -----------------------------------
 net/dccp/ccids/lib/packet_history.h |   35 +++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 727b17d..dd2cf2d 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -151,23 +151,6 @@ void tfrc_rx_packet_history_exit(void)
 	}
 }
 
-/**
- * tfrc_rx_hist_index - index to reach n-th entry after loss_start
- */
-static inline u8 tfrc_rx_hist_index(const struct tfrc_rx_hist *h, const u8 n)
-{
-	return (h->loss_start + n) & TFRC_NDUPACK;
-}
-
-/**
- * tfrc_rx_hist_last_rcv - entry with highest-received-seqno so far
- */
-static inline struct tfrc_rx_hist_entry *
-			tfrc_rx_hist_last_rcv(const struct tfrc_rx_hist *h)
-{
-	return h->ring[tfrc_rx_hist_index(h, h->loss_count)];
-}
-
 void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 			     const struct sk_buff *skb,
 			     const u32 ndp)
@@ -183,24 +166,6 @@ void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
-/**
- * tfrc_rx_hist_entry - return the n-th history entry after loss_start
- */
-static inline struct tfrc_rx_hist_entry *
-		tfrc_rx_hist_entry(const struct tfrc_rx_hist *h, const u8 n)
-{
-	return h->ring[tfrc_rx_hist_index(h, n)];
-}
-
-/**
- * tfrc_rx_hist_loss_prev - entry with highest-received-seqno before loss was detected
- */
-static inline struct tfrc_rx_hist_entry *
-			tfrc_rx_hist_loss_prev(const struct tfrc_rx_hist *h)
-{
-	return h->ring[h->loss_start];
-}
-
 /* has the packet contained in skb been seen before? */
 int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
 {
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 3dfd182..e58b0fc 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -84,6 +84,41 @@ struct tfrc_rx_hist {
 #define rtt_sample_prev		  loss_start
 };
 
+/**
+ * tfrc_rx_hist_index - index to reach n-th entry after loss_start
+ */
+static inline u8 tfrc_rx_hist_index(const struct tfrc_rx_hist *h, const u8 n)
+{
+	return (h->loss_start + n) & TFRC_NDUPACK;
+}
+
+/**
+ * tfrc_rx_hist_last_rcv - entry with highest-received-seqno so far
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_last_rcv(const struct tfrc_rx_hist *h)
+{
+	return h->ring[tfrc_rx_hist_index(h, h->loss_count)];
+}
+
+/**
+ * tfrc_rx_hist_entry - return the n-th history entry after loss_start
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_entry(const struct tfrc_rx_hist *h, const u8 n)
+{
+	return h->ring[tfrc_rx_hist_index(h, n)];
+}
+
+/**
+ * tfrc_rx_hist_loss_prev - entry with highest-received-seqno before loss was detected
+ */
+static inline struct tfrc_rx_hist_entry *
+			tfrc_rx_hist_loss_prev(const struct tfrc_rx_hist *h)
+{
+	return h->ring[h->loss_start];
+}
+
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 				    const struct sk_buff *skb, const u32 ndp);
 
-- 
1.5.3.4

