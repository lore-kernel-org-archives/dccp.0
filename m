From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sun, 09 Aug 2009 19:48:43 +0000
Subject: dccp-test-tree [PATCH 6/10] Extend the loss interval code to support ECN events
Message-Id: <1249847327-6792-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates the TFRC loss intervals code, which so far could only support
lost packets, to also handle the case of ECN-marked-CE packets:
 * the begin and length of the loss interval are different;
 * there are combinations of loss + ECN-marked-CE which the code does not
   currently consider (it is not worth the complexity), comments have been
   added to point this out.

Further changes:
----------------
The implementation of the "is the loss interval already closed?" check as per
RFC 4342, 10.2 has been improved to test the condition more efficiently.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/loss_interval.c |   76 ++++++++++++++++++++++++++++--------
 1 files changed, 59 insertions(+), 17 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -124,12 +124,12 @@ void tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *skb)
 	tfrc_lh_calc_i_mean(lh);
 }
 
-/* Determine if `new_loss' does begin a new loss interval [RFC 4342, 10.2] */
-static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
-				     struct tfrc_rx_hist_entry *new_loss)
+/* RFC 4342, 10.2: test for the existence of packet with sequence number S */
+static bool tfrc_lh_closed_check(struct tfrc_loss_interval *cur, const u8 ccval)
 {
-	return	dccp_delta_seqno(cur->li_seqno, new_loss->tfrchrx_seqno) > 0 &&
-		(cur->li_is_closed || SUB16(new_loss->tfrchrx_ccval, cur->li_ccval) > 4);
+	if (SUB16(ccval, cur->li_ccval) > 4)
+		cur->li_is_closed = true;
+	return cur->li_is_closed;
 }
 
 /** tfrc_lh_interval_add  -  Insert new record into the Loss Interval database
@@ -142,27 +142,69 @@ static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
 bool tfrc_lh_interval_add(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
 			  u32 (*calc_first_li)(struct sock *), struct sock *sk)
 {
-	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh), *new;
+	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh);
+	struct tfrc_rx_hist_entry *cong_evt;
+	u64 cong_evt_seqno;
+
+	/*
+	 * Determine if the new event is caused by a lost or ECN-marked packet.
+	 * Both events can coincide (e.g. if the third packet after a loss is
+	 * marked as CE). We avoid the complexity caused by such mixed cases:
+	 *   1) if the cause is a lost packet, we do not check whether it is
+	 *      also an ECN-marked packet (not necessary);
+	 *   2) calling this routine with a loss_count of 0..NDUPACK-1 implies
+	 *      that the cause is an ECN-marked-CE packet.
+	 *      FIXME: if in this case the loss_count is not 0, loss tracking is
+	 *      reset. This is a complex corner case (see packet_history.c) and
+	 *      hence currently not supported.
+	 */
+	if (rh->loss_count = TFRC_NDUPACK) {
+		/*
+		 * The sequence number of the first packet known to be lost is
+		 * the successor of the last packet received before the gap.
+		 */
+		cong_evt = tfrc_rx_hist_loss_prev(rh);
+		cong_evt_seqno = ADD48(cong_evt->tfrchrx_seqno, 1);
+	} else {
+		/*
+		 * ECN-marked packet. Since ECN-marks are reported as soon as a
+		 * packet is delivered, it is stored in the last-received entry.
+		 */
+		cong_evt = tfrc_rx_hist_last_rcv(rh);
+		cong_evt_seqno = cong_evt->tfrchrx_seqno;
+	}
 
-	if (cur != NULL && !tfrc_lh_is_new_loss(cur, tfrc_rx_hist_loss_prev(rh)))
-		return false;
+	/* Test if this event starts a new loss interval */
+	if (cur != NULL) {
+		s64 len = dccp_delta_seqno(cur->li_seqno, cong_evt_seqno);
+		if (len <= 0)
+			return false;
+
+		if (!tfrc_lh_closed_check(cur, cong_evt->tfrchrx_ccval))
+			return false;
 
-	new = tfrc_lh_demand_next(lh);
-	if (unlikely(new = NULL)) {
+		/* RFC 5348, 5.3: length between subsequent intervals */
+		cur->li_length = len;
+	}
+
+	/* Make the new interval the current one */
+	cur = tfrc_lh_demand_next(lh);
+	if (unlikely(cur = NULL)) {
 		DCCP_CRIT("Cannot allocate/add loss record.");
 		return false;
 	}
 
-	new->li_seqno	  = tfrc_rx_hist_loss_prev(rh)->tfrchrx_seqno;
-	new->li_ccval	  = tfrc_rx_hist_loss_prev(rh)->tfrchrx_ccval;
-	new->li_is_closed = 0;
+	cur->li_seqno	  = cong_evt_seqno;
+	cur->li_ccval	  = cong_evt->tfrchrx_ccval;
+	cur->li_is_closed = false;
 
 	if (++lh->counter = 1)
-		lh->i_mean = new->li_length = (*calc_first_li)(sk);
+		lh->i_mean = cur->li_length = (*calc_first_li)(sk);
 	else {
-		cur->li_length = dccp_delta_seqno(cur->li_seqno, new->li_seqno);
-		new->li_length = dccp_delta_seqno(new->li_seqno,
-				  tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;
+		/* RFC 5348, 5.3: length of the open loss interval I_0 */
+		cur->li_length = dccp_delta_seqno(cur->li_seqno,
+				 tfrc_rx_hist_last_rcv(rh)->tfrchrx_seqno) + 1;
+
 		if (lh->counter > (2*LIH_SIZE))
 			lh->counter -= LIH_SIZE;
 
-- 
1.6.0.rc2

