From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 28 Jul 2008 18:14:02 +0000
Subject: [PATCH 6/7] dccp tfrc: Return type of update_i_mean is void
Message-Id: <1217268843-19667-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This changes the return type of tfrc_lh_update_i_mean() to void, since that
function returns always `false'. This is due to

 	len = dccp_delta_seqno(cur->li_seqno, DCCP_SKB_CB(skb)->dccpd_seq) + 1;

 	if (len - (s64)cur->li_length <= 0)	/* duplicate or reordered */
		return 0;

which means that update_i_mean can only increase the length of the open loss
interval I_0, and hence the value of I_tot0 (RFC 3448, 5.4). Consequently the
test `i_mean < old_i_mean' at the end of the function always evaluates to false.

There is no known way by which a loss interval can suddenly become shorter,
therefore the return type of the function is changed to void. (That is, under
the given circumstances step (3) in RFC 3448, 6.1 will not occur.)

Further changes:
----------------
 * the function is now called from tfrc_rx_handle_loss, which is equivalent
   to the previous way of calling from rx_packet_recv (it was called whenever
   there was no new or pending loss, now  it is also updated when there is
   a pending loss - this increases the accuracy a bit);
 * added a FIXME to possibly consider NDP counting as per RFC 4342 (this is
   not implemented yet).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |    8 --------
 net/dccp/ccids/lib/loss_interval.c  |   20 +++++++++++---------
 net/dccp/ccids/lib/loss_interval.h  |    2 +-
 net/dccp/ccids/lib/packet_history.c |    5 +++++
 4 files changed, 17 insertions(+), 18 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -69,7 +69,7 @@ struct tfrc_rx_hist;
 
 extern int  tfrc_lh_interval_add(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
 				 u32 (*first_li)(struct sock *), struct sock *);
-extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
+extern void tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
 extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
 
 #endif /* _DCCP_LI_HIST_ */
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -84,21 +84,26 @@ static void tfrc_lh_calc_i_mean(struct tfrc_loss_hist *lh)
 
 /**
  * tfrc_lh_update_i_mean  -  Update the `open' loss interval I_0
- * For recomputing p: returns `true' if p > p_prev  <=>  1/p < 1/p_prev
+ * This updates I_mean as the sequence numbers increase. As a consequence, the
+ * open loss interval I_0 increases, hence p = W_tot/max(I_tot0, I_tot1)
+ * decreases, and thus there is no need to send renewed feedback.
  */
-u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
+void tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
 {
 	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh);
-	u32 old_i_mean = lh->i_mean;
 	s64 len;
 
 	if (cur = NULL)			/* not initialised */
-		return 0;
+		return;
+
+	/* FIXME: should probably also count non-data packets (RFC 4342, 6.1) */
+	if (!dccp_data_packet(skb))
+		return;
 
 	len = dccp_delta_seqno(cur->li_seqno, DCCP_SKB_CB(skb)->dccpd_seq) + 1;
 
 	if (len - (s64)cur->li_length <= 0)	/* duplicate or reordered */
-		return 0;
+		return;
 
 	if (SUB16(dccp_hdr(skb)->dccph_ccval, cur->li_ccval) > 4)
 		/*
@@ -112,14 +117,11 @@ u8 tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
 		cur->li_is_closed = 1;
 
 	if (tfrc_lh_length(lh) = 1)		/* due to RFC 3448, 6.3.1 */
-		return 0;
+		return;
 
 	cur->li_length = len;
 	tfrc_lh_calc_i_mean(lh);
-
-	return (lh->i_mean < old_i_mean);
 }
-EXPORT_SYMBOL_GPL(tfrc_lh_update_i_mean);
 
 /* Determine if `new_loss' does begin a new loss interval [RFC 4342, 10.2] */
 static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -767,15 +767,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (sample != 0)
 			hcrx->rtt = tfrc_ewma(hcrx->rtt, sample, 9);
-
-	} else if (tfrc_lh_update_i_mean(&hcrx->li_hist, skb)) {
-		/*
-		 * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
-		 * has decreased (resp. p has increased), send feedback now.
-		 */
-		do_feedback = CCID3_FBACK_PARAM_CHANGE;
 	}
-
 	/*
 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
 	 */
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -351,6 +351,11 @@ int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
 		is_new_loss = tfrc_lh_interval_add(lh, h, calc_first_li, sk);
 		__three_after_loss(h);
 	}
+
+	/* RFC 3448, 6.1: update I_0, whose growth implies p <= p_prev */
+	if (!is_new_loss)
+		tfrc_lh_update_i_mean(lh, skb);
+
 	return is_new_loss;
 }
 EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
