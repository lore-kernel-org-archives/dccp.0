From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:25 +0000
Subject: [PATCH 5/8] [TFRC]: Loss interval code needs the macros/inlines that were moved
Message-Id: <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This moves the inlines (which were previously declared as macros) back into packet_history.h since
the loss detection code needs to be able to read entries from the RX history in order to create the
relevant loss entries: it needs at least tfrc_rx_hist_loss_prev() and tfrc_rx_hist_last_rcv(), which
in turn require the definition of the other inlines (macros).

Additionally, inn one case the use of inlines instead of a macro broke the algorithm: rx_hist_swap()
(introduced in next patch) needs to be able to swap the history entries; when using an inline returning
a pointer instead, one gets compilation errors such as:

  distcc[24516] ERROR: compile /root/.ccache/packet_his.tmp.aspire.home.net.24512.i on _tiptop failed
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c: In function '__one_after_loss':
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:266: error: lvalue required as unary '&' operand
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:267: error: lvalue required as unary '&' operand
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c: In function '__two_after_loss':
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:298: error: lvalue required as unary '&' operand
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:299: error: lvalue required as unary '&' operand
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:336: error: lvalue required as unary '&' operand
  /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:337: error: lvalue required as unary '&' operand
  make[4]: *** [net/dccp/ccids/lib/packet_history.o] Error 1
  make[3]: *** [net/dccp/ccids/lib] Error 2
  make[2]: *** [net/dccp/ccids] Error 2
  make[1]: *** [net/dccp/] Error 2
  make: *** [sub-make] Error 2

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   37 +----------------------------------
 net/dccp/ccids/lib/packet_history.h |   32 ++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+), 36 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 6256bec..428636e 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -151,41 +151,6 @@ void __exit tfrc_rx_packet_history_exit(void)
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
@@ -196,7 +161,7 @@ int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
 		return 1;
 
 	for (i = 1; i <= h->loss_count; i++)
-		if (tfrc_rx_hist_entry(h, i)->tfrchrx_seqno = seq)
+		if (TFRC_RX_HIST_ENTRY(h, i)->tfrchrx_seqno = seq)
 			return 1;
 
 	return 0;
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 3dfd182..6ea25cd 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -84,6 +84,38 @@ struct tfrc_rx_hist {
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
+ * This has to be a macro since rx_hist_swap needs to be able to swap entries.
+ */
+#define TFRC_RX_HIST_ENTRY(h, n)	((h)->ring[tfrc_rx_hist_index(h, n)])
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
 
