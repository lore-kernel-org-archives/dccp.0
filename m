From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:24 +0000
Subject: [PATCH 4/8] [TFRC]: Need separate entry_from_skb routine
Message-Id: <1197108388630-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This again separates tfrc_rx_hist_packet() from tfrc_rx_hist_entry_from_skb(), which
was the format used in the original patch submission. The reason for this is the
requirement -- used by the subsequent patches -- to be able to insert a newly arrived
skb in arbitrary places within the ringbuffer history.

The add_packet() function is only a special case of this usage: it inserts always
at the front, and thus updates the highest-received sequence number. That has been
the main reason why it was originally called tfrc_rx_hist_update() --  the old name
reflected better what the function did.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index 4d37396..6256bec 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -168,21 +168,6 @@ static inline struct tfrc_rx_hist_entry *
 	return h->ring[tfrc_rx_hist_index(h, h->loss_count)];
 }
 
-void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
-			     const struct sk_buff *skb,
-			     const u32 ndp)
-{
-	struct tfrc_rx_hist_entry *entry = tfrc_rx_hist_last_rcv(h);
-	const struct dccp_hdr *dh = dccp_hdr(skb);
-
-	entry->tfrchrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-	entry->tfrchrx_ccval = dh->dccph_ccval;
-	entry->tfrchrx_type  = dh->dccph_type;
-	entry->tfrchrx_ndp   = ndp;
-	entry->tfrchrx_tstamp = ktime_get_real();
-}
-EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
-
 /**
  * tfrc_rx_hist_entry - return the n-th history entry after loss_start
  */
@@ -218,6 +203,26 @@ int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_duplicate);
 
+static void tfrc_rx_hist_entry_from_skb(struct tfrc_rx_hist_entry *entry,
+					const struct sk_buff *skb, u32 ndp)
+{
+	const struct dccp_hdr *dh = dccp_hdr(skb);
+
+	entry->tfrchrx_seqno  = DCCP_SKB_CB(skb)->dccpd_seq;
+	entry->tfrchrx_ccval  = dh->dccph_ccval;
+	entry->tfrchrx_type   = dh->dccph_type;
+	entry->tfrchrx_ndp    = ndp;
+	entry->tfrchrx_tstamp = ktime_get_real();
+}
+
+/* commit packet details of skb to history (record highest received seqno) */
+void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
+			     const struct sk_buff *skb, u32 ndp)
+{
+	tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_last_rcv(h), skb, ndp);
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_add_packet);
+
 /* initialise loss detection and disable RTT sampling */
 static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
 {
