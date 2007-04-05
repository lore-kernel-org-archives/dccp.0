From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:35:18 +0000
Subject: [PATCH 22/43]: Integrate RX history loss detection with loss interval update
Message-Id: <200704051635.18471@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Integrate RX history loss detection with loss interval update

This adds the missing link between

 * TFRC loss detection as provided by the RX history code and
 * Loss Intervals update whenever a new loss is detected.

Handling is conform to the TFRC semantics and conveniently transparent
to the caller: only the function tfrc_rx_handle_loss() need be called.

A test module is available on request which shows that the transfer from
RX history loss event into a newly created loss interval entry works.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   22 ++++++++++++++--------
 net/dccp/ccids/lib/packet_history.h |    4 +++-
 2 files changed, 17 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -216,7 +216,9 @@ static inline void tfrc_rx_hist_update(s
 	dccp_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
-extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct sk_buff *, u32);
+extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct tfrc_loss_hist *,
+				struct sk_buff *skb, u32 ndp,
+				u32 (*first_li)(struct sock *), struct sock *);
 extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -385,13 +385,19 @@ static void __three_after_loss(struct tf
 
 /**
  *  tfrc_rx_handle_loss  -  Loss detection and further processing
- *  @h:	      The non-empty history object
- *  @skb:     Currently received packet
- *  @ndp:     The NDP count belonging to skb
- *  Returns 1 when caller should send feedback, 0 otherwise.
+ *  @h:             The non-empty RX history object
+ *  @lh:            Loss Intervals database to update
+ *  @skb:           Currently received packet
+ *  @ndp:           The NDP count belonging to @skb
+ *  @calc_first_li: Caller-dependent computation of first loss interval in @lh
+ *  Chooses action according to pending loss, updates LI database when a new
+ *  loss was detected, and does required post-processing. Returns 1 when caller
+ *  should send feedback, 0 otherwise.
  */
 int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
-			struct sk_buff *skb, u32 ndp)
+			struct tfrc_loss_hist *lh,
+			struct sk_buff *skb, u32 ndp,
+			u32 (*calc_first_li)(struct sock *), struct sock *sk)
 {
 	int is_new_loss = 0;
 
@@ -401,9 +407,9 @@ int tfrc_rx_handle_loss(struct tfrc_rx_h
 		DCCP_BUG("invalid loss_count %d", h->loss_count);
 	else if (__two_after_loss(h, skb, ndp)) {
 		/*
-		 * XXX part of subsequent patch
-		is_new_loss = update_li(li_hist, loss_prev(h));
-		*/
+		 * Update Loss Interval database and recycle RX records
+		 */
+		is_new_loss = tfrc_lh_interval_new(lh, h, calc_first_li, sk);
 		__three_after_loss(h);
 	}
 	return is_new_loss;
