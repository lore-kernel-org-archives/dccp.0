From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 12 Dec 2007 16:36:51 +0000
Subject: [PATCH 5/7] [TFRC]: CCID3 (and CCID4) needs to access these inlines
Message-Id: <1197477413-1456-6-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

This moves two inlines back to packet_history.h: these are not private
to packet_history.c, but are needed by CCID3/4 to detect whether a new
loss is indicated, or whether a loss is already pending.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/packet_history.c |   26 --------------------------
 net/dccp/ccids/lib/packet_history.h |   35 +++++++++++++++++++++++++++++++----
 2 files changed, 31 insertions(+), 30 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 5b10a1e..20af1a6 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -191,32 +191,6 @@ int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_duplicate);
 
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
 static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
 {
 	const u8 idx_a = tfrc_rx_hist_index(h, a),
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 24edd8d..c7eeda4 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -118,16 +118,43 @@ static inline struct tfrc_rx_hist_entry *
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
+						  const struct sk_buff *skb,
+						  u32 ndp)
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
-extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
+extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
+				struct tfrc_loss_hist *lh,
 				struct sk_buff *skb, u32 ndp,
-				u32 (*first_li)(struct sock *), struct sock *);
+				u32 (*first_li)(struct sock *sk),
+				struct sock *sk);
 extern u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
 				   const struct sk_buff *skb);
 extern int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h);
-- 
1.5.3.4

