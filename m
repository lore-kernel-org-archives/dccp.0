From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Jul 2008 14:51:49 +0000
Subject: [PATCH 3/4] dccp ccid-3: Fix a loss detection bug
Message-Id: <1215874310-10534-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This fixes a bug in the logic of the TFRC loss detection:
 * new_loss_indicated() should not be called while a loss is pending;
 * but the code allows this;
 * thus, for two subsequent gaps in the sequence space, when loss_count
   has not yet reached NDUPACK=3, the loss_count is falsely reduced to 1.

To avoid further and similar problems, all loss handling and loss detection is
now done inside tfrc_rx_hist_handle_loss(), using an appropriate routine to
track new losses.

Further changes:
----------------
 * added a reminder that no RX history operations should be performed when
   rx_handle_loss() has identified a (new) loss, since the function takes
   care of packet reordering during loss detection;
 * made tfrc_rx_hist_loss_pending() bool (thanks to an earlier suggestion
   by Arnaldo);
 * removed unused functions.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   12 +++++-------
 net/dccp/ccids/lib/packet_history.c |   24 ++++++++++++++++++++----
 net/dccp/ccids/lib/packet_history.h |   24 ++----------------------
 3 files changed, 27 insertions(+), 33 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -825,18 +825,16 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/*
-	 * Handle pending losses and otherwise check for new loss
+	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_rx_hist_loss_pending(&hcrx->ccid3hcrx_hist) &&
-	    tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist,
-				&hcrx->ccid3hcrx_li_hist,
-				skb, ndp, ccid3_first_li, sk) ) {
+	if (tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist, &hcrx->ccid3hcrx_li_hist,
+				skb, ndp, ccid3_first_li, sk)) {
 		do_feedback = CCID3_FBACK_PARAM_CHANGE;
 		goto done_receiving;
 	}
 
-	if (tfrc_rx_hist_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
-		goto update_records;
+	if (tfrc_rx_hist_loss_pending(&hcrx->ccid3hcrx_hist))
+		return; /* done receiving */
 
 	/*
 	 * Handle data packets: RTT sampling and monitoring p
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -206,10 +206,21 @@ static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const u8 a, const u8 b)
  *
  * In the descriptions, `Si' refers to the sequence number of entry number i,
  * whose NDP count is `Ni' (lower case is used for variables).
- * Note: All __after_loss functions expect that a test against duplicates has
- *       been performed already: the seqno of the skb must not be less than the
- *       seqno of loss_prev; and it must not equal that of any valid hist_entry.
+ * Note: All __xxx_loss functions expect that a test against duplicates has been
+ *       performed already: the seqno of the skb must not be less than the seqno
+ *       of loss_prev; and it must not equal that of any valid history entry.
  */
+static void __do_track_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u64 n1)
+{
+	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
+	    s1 = DCCP_SKB_CB(skb)->dccpd_seq;
+
+	if (!dccp_loss_free(s0, s1, n1)) {	/* gap between S0 and S1 */
+		h->loss_count = 1;
+		tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 1), skb, n1);
+	}
+}
+
 static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2)
 {
 	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
@@ -353,6 +364,9 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
  *  Chooses action according to pending loss, updates LI database when a new
  *  loss was detected, and does required post-processing. Returns 1 when caller
  *  should send feedback, 0 otherwise.
+ *  Since it also takes care of reordering during loss detection and updates the
+ *  records accordingly, the caller should not perform any more RX history
+ *  operations when loss_count is greater than 0 after calling this function.
  */
 int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 			struct tfrc_loss_hist *lh,
@@ -361,7 +375,9 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 {
 	int is_new_loss = 0;
 
-	if (h->loss_count = 1) {
+	if (h->loss_count = 0) {
+		__do_track_loss(h, skb, ndp);
+	} else if (h->loss_count = 1) {
 		__one_after_loss(h, skb, ndp);
 	} else if (h->loss_count != 2) {
 		DCCP_BUG("invalid loss_count %d", h->loss_count);
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -118,30 +118,10 @@ static inline struct tfrc_rx_hist_entry *
 	return h->ring[h->loss_start];
 }
 
-/* initialise loss detection and disable RTT sampling */
-static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
-{
-	h->loss_count = 1;
-}
-
 /* indicate whether previously a packet was detected missing */
-static inline int tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
-{
-	return h->loss_count;
-}
-
-/* any data packets missing between last reception and skb ? */
-static inline int tfrc_rx_hist_new_loss_indicated(struct tfrc_rx_hist *h,
-						  const struct sk_buff *skb,
-						  u32 ndp)
+static inline bool tfrc_rx_hist_loss_pending(const struct tfrc_rx_hist *h)
 {
-	int delta = dccp_delta_seqno(tfrc_rx_hist_last_rcv(h)->tfrchrx_seqno,
-				     DCCP_SKB_CB(skb)->dccpd_seq);
-
-	if (delta > 1 && ndp < delta)
-		tfrc_rx_hist_loss_indicated(h);
-
-	return tfrc_rx_hist_loss_pending(h);
+	return h->loss_count > 0;
 }
 
 extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
