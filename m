From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 15 Jun 2007 14:31:37 +0000
Subject: [PATCH 4/9]: New RX History Step 3 - Track highest seqno
Message-Id: <200706151531.37190@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 3 - Track highest seqno

The receiver needs to track the highest sequence number (and corresponding
CCVal / timestamp) received so far.

This is done here, the patch updates the `non_loss' entry of the CCID 3 RX
history with the details of the currently received packet.

It uses the new ktime_t interface.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    3 ++
 net/dccp/ccids/lib/packet_history.h |   38 ++++++++++++++++--------------------
 2 files changed, 20 insertions(+), 21 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1022,6 +1022,9 @@ static void ccid3_hc_rx_packet_recv(stru
 		return;
 	}
 
+	/* Update highest received sequence number so far */
+	tfrc_rx_hist_update(&hcrx->ccid3hcrx_hist, skb, opt_recv->dccpor_ndp);
+
 	/* Dealing with packet loss */
 	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
 		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -204,32 +204,28 @@ static inline void tfrc_rx_hist_swap(str
 	*b = tmp;
 }
 
-extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
-extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
-
-static inline struct dccp_rx_hist_entry *
-			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
-					       const struct sock *sk,
-					       const u32 ndp,
-					       const struct sk_buff *skb,
-					       const gfp_t prio)
+static inline void tfrc_rx_hist_entry_from_skb(struct tfrc_rx_hist_entry *new,
+					        struct sk_buff *skb, u32 ndp)
 {
-	struct dccp_rx_hist_entry *entry = kmem_cache_alloc(hist->dccprxh_slab,
-							    prio);
-
-	if (entry != NULL) {
-		const struct dccp_hdr *dh = dccp_hdr(skb);
+	const struct dccp_hdr *dh = dccp_hdr(skb);
 
-		entry->dccphrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-		entry->dccphrx_ccval = dh->dccph_ccval;
-		entry->dccphrx_type  = dh->dccph_type;
-		entry->dccphrx_ndp   = ndp;
-		dccp_timestamp(sk, &entry->dccphrx_tstamp);
-	}
+	new->seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+	new->ccval = dh->dccph_ccval;
+	new->ptype = dh->dccph_type;
+	new->ndp   = ndp;
+	new->stamp = ktime_get_real();
+}
 
-	return entry;
+/* commit packet details of skb to history (record highest received seqno) */
+static inline void tfrc_rx_hist_update(struct tfrc_rx_hist *h,
+				       struct sk_buff *skb, u32 ndp)
+{
+	tfrc_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
+extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
+extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
+
 static inline struct dccp_rx_hist_entry *
 			dccp_rx_hist_head(struct list_head *list)
 {
