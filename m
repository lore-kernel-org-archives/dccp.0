From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:27 +0000
Subject: [PATCH 7/8] [TFRC]: CCID3 (and CCID4) needs to access these inlines
Message-Id: <11971083881748-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This moves two inlines back to packet_history.h: these are not private
to packet_history.c, but are needed by CCID3/4 to detect whether a new
loss is indicated, or whether a loss is already pending.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   26 --------------------------
 net/dccp/ccids/lib/packet_history.h |   28 ++++++++++++++++++++++++++--
 2 files changed, 26 insertions(+), 28 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index a421032..760631e 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -188,32 +188,6 @@ void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
 
-/* initialise loss detection and disable RTT sampling */
-static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
-{
-	h->loss_count = 1;
-}
-
-/* indicate whether previously a packet was detected missing */
-static inline int tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
-{
-	return h->loss_count;
-}
-
-/* any data packets missing between last reception and skb ? */
-int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
-				    const struct sk_buff *skb, u32 ndp)
-{
-	int delta = dccp_delta_seqno(tfrc_rx_hist_last_rcv(h)->tfrchrx_seqno,
-				     DCCP_SKB_CB(skb)->dccpd_seq);
-
-	if (delta > 1 && ndp < delta)
-		tfrc_rx_hist_loss_indicated(h);
-
-	return tfrc_rx_hist_loss_pending(h);
-}
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_new_loss_indicated);
-
 static void tfrc_rx_hist_swap(struct tfrc_rx_hist_entry **a,
 			      struct tfrc_rx_hist_entry **b)
 {
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 6df9582..cb3220f 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -115,12 +115,36 @@ static inline struct tfrc_rx_hist_entry *
 	return h->ring[h->loss_start];
 }
 
+/* initialise loss detection and disable RTT sampling */
+static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
+{
+	h->loss_count = 1;
+}
+
+/* indicate whether previously a packet was detected missing */
+static inline int tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
+{
+	return h->loss_count;
+}
+
+/* any data packets missing between last reception and skb ? */
+static inline int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
+						  const struct sk_buff *skb, u32 ndp)
+{
+	int delta = dccp_delta_seqno(tfrc_rx_hist_last_rcv(h)->tfrchrx_seqno,
+				     DCCP_SKB_CB(skb)->dccpd_seq);
+
+	if (delta > 1 && ndp < delta)
+		tfrc_rx_hist_loss_indicated(h);
+
+	return tfrc_rx_hist_loss_pending(h);
+}
+
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 				    const struct sk_buff *skb, const u32 ndp);
 
 extern int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
-extern int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
-					   const struct sk_buff *skb, u32 ndp);
+
 struct tfrc_loss_hist;
 extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
 				struct sk_buff *skb, u32 ndp,
