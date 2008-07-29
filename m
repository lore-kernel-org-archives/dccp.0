From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 10:05:52 +0000
Subject: [PATCH 7/7] dccp ccid-3: Update the RX history records in one place
Message-Id: <1217325952-12337-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch is a requirement for enabling ECN support later on. With that change
in mind, the following preparations are done:
 * lets tfrc_rx_congestion_event() always update the RX history records, since
   this routine needs to be called for each non-duplicate packet anyway;
 * renamed handle_loss() into congestion_event() since it returns true when a
   congestion event happens (it will eventually also take care of ECN packets);
 * changed all involved boolean-type functions to a return type of `bool'.

Updating the RX history records is now only necessary for the packets received
up to sending the first feedback.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   37 ++++++++++------------------------
 net/dccp/ccids/lib/loss_interval.c  |   10 ++++----
 net/dccp/ccids/lib/loss_interval.h  |    2 +-
 net/dccp/ccids/lib/packet_history.c |   37 +++++++++++++++++------------------
 net/dccp/ccids/lib/packet_history.h |   10 ++++----
 5 files changed, 40 insertions(+), 56 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -186,11 +186,11 @@ extern void tfrc_rx_hist_add_packet(struct tfrc_rx_hist *h,
 extern int tfrc_rx_hist_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb);
 
 struct tfrc_loss_hist;
-extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
-				struct tfrc_loss_hist *lh,
-				struct sk_buff *skb, const u64 ndp,
-				u32 (*first_li)(struct sock *sk),
-				struct sock *sk);
+extern bool tfrc_rx_congestion_event(struct tfrc_rx_hist *h,
+				     struct tfrc_loss_hist *lh,
+				     struct sk_buff *skb, const u64 ndp,
+				     u32 (*first_li)(struct sock *sk),
+				     struct sock *sk);
 extern void tfrc_rx_hist_sample_rtt(struct tfrc_rx_hist *h,
 				    const struct sk_buff *skb);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *h, struct sock *sk);
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -192,10 +192,8 @@ static void __do_track_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u64 n1)
 	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
 	    s1 = DCCP_SKB_CB(skb)->dccpd_seq;
 
-	if (!dccp_loss_free(s0, s1, n1)) {	/* gap between S0 and S1 */
+	if (!dccp_loss_free(s0, s1, n1))	/* gap between S0 and S1 */
 		h->loss_count = 1;
-		tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 1), skb, n1);
-	}
 }
 
 static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2)
@@ -328,13 +326,13 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
 }
 
 /**
- *  tfrc_rx_handle_loss  -  Loss detection and further processing
- *  @h:		    The non-empty RX history object
- *  @lh:	    Loss Intervals database to update
- *  @skb:	    Currently received packet
- *  @ndp:	    The NDP count belonging to @skb
- *  @calc_first_li: Caller-dependent computation of first loss interval in @lh
- *  @sk:	    Used by @calc_first_li (see tfrc_lh_interval_add)
+ *  tfrc_rx_congestion_event  -  Loss detection and further processing
+ *  @h:		The non-empty RX history object
+ *  @lh:	Loss Intervals database to update
+ *  @skb:	Currently received packet
+ *  @ndp:	The NDP count belonging to @skb
+ *  @first_li:	Caller-dependent computation of first loss interval in @lh
+ *  @sk:	Used by @calc_first_li (see tfrc_lh_interval_add)
  *  Chooses action according to pending loss, updates LI database when a new
  *  loss was detected, and does required post-processing. Returns 1 when caller
  *  should send feedback, 0 otherwise.
@@ -342,12 +340,12 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
  *  records accordingly, the caller should not perform any more RX history
  *  operations when loss_count is greater than 0 after calling this function.
  */
-int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
-			struct tfrc_loss_hist *lh,
-			struct sk_buff *skb, const u64 ndp,
-			u32 (*calc_first_li)(struct sock *), struct sock *sk)
+bool tfrc_rx_congestion_event(struct tfrc_rx_hist *h,
+			      struct tfrc_loss_hist *lh,
+			      struct sk_buff *skb, const u64 ndp,
+			      u32 (*first_li)(struct sock *), struct sock *sk)
 {
-	int is_new_loss = 0;
+	bool new_event = false;
 
 	if (tfrc_rx_hist_duplicate(h, skb))
 		return 0;
@@ -355,6 +353,7 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 	if (h->loss_count = 0) {
 		__do_track_loss(h, skb, ndp);
 		tfrc_rx_hist_sample_rtt(h, skb);
+		tfrc_rx_hist_add_packet(h, skb, ndp);
 	} else if (h->loss_count = 1) {
 		__one_after_loss(h, skb, ndp);
 	} else if (h->loss_count != 2) {
@@ -363,7 +362,7 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 		/*
 		 * Update Loss Interval database and recycle RX records
 		 */
-		is_new_loss = tfrc_lh_interval_add(lh, h, calc_first_li, sk);
+		new_event = tfrc_lh_interval_add(lh, h, first_li, sk);
 		__three_after_loss(h);
 	}
 
@@ -378,12 +377,12 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 	}
 
 	/* RFC 3448, 6.1: update I_0, whose growth implies p <= p_prev */
-	if (!is_new_loss)
+	if (!new_event)
 		tfrc_lh_update_i_mean(lh, skb);
 
-	return is_new_loss;
+	return new_event;
 }
-EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
+EXPORT_SYMBOL_GPL(tfrc_rx_congestion_event);
 
 /* Compute the sending rate X_recv measured between feedback intervals */
 u32 tfrc_rx_hist_x_recv(struct tfrc_rx_hist *h, const u32 last_x_recv)
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -67,7 +67,7 @@ static inline u8 tfrc_lh_length(struct tfrc_loss_hist *lh)
 
 struct tfrc_rx_hist;
 
-extern int  tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
+extern bool tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
 				 u32 (*first_li)(struct sock *), struct sock *);
 extern void tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
 extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -140,18 +140,18 @@ static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
  * @sk:		   Used by @calc_first_li in caller-specific way (subtyping)
  * Updates I_mean and returns 1 if a new interval has in fact been added to @lh.
  */
-int tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
-			 u32 (*calc_first_li)(struct sock *), struct sock *sk)
+bool tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
+			  u32 (*calc_first_li)(struct sock *), struct sock *sk)
 {
 	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh), *new;
 
 	if (cur != NULL && !tfrc_lh_is_new_loss(cur, tfrc_rx_hist_loss_prev(rh)))
-		return 0;
+		return false;
 
 	new = tfrc_lh_demand_next(lh);
 	if (unlikely(new = NULL)) {
 		DCCP_CRIT("Cannot allocate/add loss record.");
-		return 0;
+		return false;
 	}
 
 	new->li_seqno	  = tfrc_rx_hist_loss_prev(rh)->tfrchrx_seqno;
@@ -169,7 +169,7 @@ int tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
 
 		tfrc_lh_calc_i_mean(lh);
 	}
-	return 1;
+	return true;
 }
 EXPORT_SYMBOL_GPL(tfrc_lh_interval_add);
 
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -657,41 +657,26 @@ failed:
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	enum ccid3_fback_type do_feedback = CCID3_FBACK_NONE;
 	const u64 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
 	const bool is_data_packet = dccp_data_packet(skb);
 
 	/*
 	 * Perform loss detection and handle pending losses
 	 */
-	if (tfrc_rx_handle_loss(&hcrx->hist, &hcrx->li_hist,
-				skb, ndp, ccid3_first_li, sk)) {
-		do_feedback = CCID3_FBACK_PARAM_CHANGE;
-		goto done_receiving;
-	}
-
-	if (unlikely(hcrx->feedback = CCID3_FBACK_NONE)) {
-		if (is_data_packet)
-			do_feedback = CCID3_FBACK_INITIAL;
-		goto update_records;
-	}
-
-	if (tfrc_rx_hist_loss_pending(&hcrx->hist))
-		return; /* done receiving */
-
+	if (tfrc_rx_congestion_event(&hcrx->hist, &hcrx->li_hist,
+				     skb, ndp, ccid3_first_li, sk))
+		ccid3_hc_rx_send_feedback(sk, skb, CCID3_FBACK_PARAM_CHANGE);
+	/*
+	 * Feedback for first non-empty data packet (RFC 3448, 6.3)
+	 */
+	else if (unlikely(hcrx->feedback = CCID3_FBACK_NONE && is_data_packet))
+		ccid3_hc_rx_send_feedback(sk, skb, CCID3_FBACK_INITIAL);
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
-	if (is_data_packet &&
-	    SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
-		do_feedback = CCID3_FBACK_PERIODIC;
-
-update_records:
-	tfrc_rx_hist_add_packet(&hcrx->hist, skb, ndp);
-
-done_receiving:
-	if (do_feedback)
-		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
+	else if (!tfrc_rx_hist_loss_pending(&hcrx->hist) && is_data_packet &&
+		 SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->last_counter) > 3)
+		ccid3_hc_rx_send_feedback(sk, skb, CCID3_FBACK_PERIODIC);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
