From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 08 Dec 2007 10:06:21 +0000
Subject: [PATCH 1/8] [TFRC]: Whitespace cleanups
Message-Id: <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Just some tidy-ups to keep git/quilt happy. Also moved up the
comment "Receiver routines" above the first occurrence of RX
history routines.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   16 ++++++++--------
 net/dccp/ccids/lib/loss_interval.c  |    2 +-
 net/dccp/ccids/lib/packet_history.c |   12 ++++++------
 3 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index faacffa..a5246f7 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -780,7 +780,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 */
 		}
 		goto update_records;
- 	}
+	}
 
 	if (tfrc_rx_hist_duplicate(&hcrx->ccid3hcrx_hist, skb))
 		return; /* done receiving */
@@ -792,7 +792,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		 */
 		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, payload, 9);
 		hcrx->ccid3hcrx_bytes_recv += payload;
- 	}
+	}
 
 	/*
 	 * Handle pending losses and otherwise check for new loss
@@ -808,11 +808,11 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
 		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
- 		/*
- 		 * Empty loss history: no loss so far, hence p stays 0.
- 		 * Sample RTT values, since an RTT estimate is required for the
- 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
- 		 */
+		/*
+		 * Empty loss history: no loss so far, hence p stays 0.
+		 * Sample RTT values, since an RTT estimate is required for the
+		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
+		 */
 		if (sample != 0)
 			hcrx->ccid3hcrx_rtt = tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
 	}
@@ -823,7 +823,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
 		do_feedback = CCID3_FBACK_PERIODIC;
 
-update_records:	
+update_records:
 	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist, skb, ndp);
 
 	if (do_feedback)
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 7e0714a..c0a933a 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -131,7 +131,7 @@ static u32 dccp_li_calc_first_li(struct sock *sk,
 {
 /*
  * FIXME:
- * Will be rewritten in the upcoming new loss intervals code. 
+ * Will be rewritten in the upcoming new loss intervals code.
  * Has to be commented ou because it relies on the old rx history
  * data structures
  */
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index e197389..54cd23e 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -114,6 +114,11 @@ u32 tfrc_tx_hist_rtt(struct tfrc_tx_hist_entry *head, const u64 seqno,
 EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
 
 
+/*
+ * 	Receiver History Routines
+ */
+static struct kmem_cache *tfrc_rx_hist_slab;
+
 /**
  * tfrc_rx_hist_index - index to reach n-th entry after loss_start
  */
@@ -131,11 +136,6 @@ static inline struct tfrc_rx_hist_entry *
 	return h->ring[tfrc_rx_hist_index(h, h->loss_count)];
 }
 
-/*
- * 	Receiver History Routines
- */
-static struct kmem_cache *tfrc_rx_hist_slab;
-
 void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 			     const struct sk_buff *skb,
 			     const u32 ndp)
@@ -278,7 +278,7 @@ u32 tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h, const struct sk_buff *skb)
 {
 	u32 sample = 0,
 	    delta_v = SUB16(dccp_hdr(skb)->dccph_ccval,
-	    		    tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
+			    tfrc_rx_hist_rtt_last_s(h)->tfrchrx_ccval);
 
 	if (delta_v < 1 || delta_v > 4) {	/* unsuitable CCVal delta */
 		if (h->rtt_sample_prev = 2) {	/* previous candidate stored */
