From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:33:52 +0000
Subject: [PATCH 9/43]: New RX History Step 3 - Track highest seqno
Message-Id: <200704051633.52248@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 3 - Track highest seqno

The receiver needs to track the highest sequence number (and corresponding
CCVal / timestamp) received so far.

This is implemented with this patch, which updates the `non_loss' entry of
the CCID 3 RX history with the details of the currently received packet.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    3 +++
 net/dccp/ccids/lib/packet_history.h |   19 +++++++++++++++++++
 2 files changed, 22 insertions(+)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1107,6 +1107,9 @@ static void ccid3_hc_rx_packet_recv(stru
 
 	if (ccid3_hc_rx_update_p(hcrx))
 		ccid3_hc_rx_send_feedback(sk, skb);
+
+	/* Update highest received sequence number so far */
+	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, opt_recv->dccpor_ndp);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -202,6 +202,25 @@ static inline void tfrc_rx_hist_swap(str
 	*b = tmp;
 }
 
+static inline void dccp_rx_hist_entry_from_skb(struct dccp_rx_hist_entry *new,
+					       struct sk_buff *skb, u32 ndp)
+{
+	const struct dccp_hdr *dh = dccp_hdr(skb);
+
+	new->dccphrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+	new->dccphrx_ccval = dh->dccph_ccval;
+	new->dccphrx_type  = dh->dccph_type;
+	new->dccphrx_ndp   = ndp;
+	skb_get_timestamp(skb, &new->dccphrx_tstamp);
+}
+
+/* commit packet details of skb to history (record highest received seqno) */
+static inline void tfrc_rx_hist_update(struct tfrc_rx_hist *h,
+				       struct sk_buff *skb, u32 ndp)
+{
+	dccp_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
+}
+
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
 
