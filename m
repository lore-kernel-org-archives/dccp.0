From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:35:06 +0000
Subject: [PATCH 20/43]: Insert and update routines for the Loss Interval Database
Message-Id: <200704051635.06788@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[TFRC]: Insert and update routines for the Loss Interval Database

This provides an `insert' function for the Loss Interval database. It only inserts
when a loss is new, i.e. either 
 * no loss record has been allocated before (uninitialised) or
 * the most recent loss is in a different RTT than the last one.

For this purpose, the test from  [RFC 4342, 10.2] is used.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c             |   49 -------------------------------------
 net/dccp/ccids/lib/loss_interval.c |   49 +++++++++++++++++++++++++++++++++++++
 net/dccp/ccids/lib/loss_interval.h |    2 +
 3 files changed, 51 insertions(+), 49 deletions(-)

--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -67,6 +67,8 @@ static inline u8 tfrc_lh_length(struct t
 	return min(lh->counter, (u8)LIH_SIZE);
 }
 
+extern int  tfrc_lh_interval_new(struct tfrc_loss_hist *, struct tfrc_rx_hist *,
+				 u32 (*first_li)(struct sock *), struct sock *);
 extern u8   tfrc_lh_update_i_mean(struct tfrc_loss_hist *lh, struct sk_buff *);
 extern void tfrc_lh_cleanup(struct tfrc_loss_hist *lh);
 
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -122,6 +122,55 @@ u8 tfrc_lh_update_i_mean(struct tfrc_los
 
 EXPORT_SYMBOL_GPL(tfrc_lh_update_i_mean);
 
+/* Determine if `new_loss' does begin a new loss interval [RFC 4342, 10.2] */
+static inline u8 tfrc_lh_is_new_loss(struct tfrc_loss_interval *cur,
+				     struct dccp_rx_hist_entry *new_loss)
+{
+	return	dccp_delta_seqno(cur->li_seqno, new_loss->dccphrx_seqno) > 0 &&
+		(cur->li_is_closed ||
+		 SUB16(new_loss->dccphrx_ccval, cur->li_ccval) > 4);
+}
+
+/** tfrc_lh_interval_new  -  Insert new record into the Loss Interval database
+ * @lh:		   Loss Interval database
+ * @rh:		   Receive history containing a fresh loss event
+ * @calc_first_li: Caller-dependent routine to compute length of first interval
+ * Updates I_mean and returns 1 if a new interval has in fact been added to @lh.
+ */
+int tfrc_lh_interval_new(struct tfrc_loss_hist *lh, struct tfrc_rx_hist *rh,
+			 u32 (*calc_first_li)(struct sock *), struct sock *sk)
+{
+	struct tfrc_loss_interval *cur = tfrc_lh_peek(lh), *new;
+
+	if (cur != NULL && !tfrc_lh_is_new_loss(cur, loss_prev(rh)))
+		return 0;
+
+	new = tfrc_lh_demand_next(lh);
+	if (unlikely(new = NULL)) {
+		DCCP_CRIT("Cannot allocate/add loss record.");
+		return 0;
+	}
+
+	new->li_seqno	  = loss_prev(rh)->dccphrx_seqno;
+	new->li_ccval	  = loss_prev(rh)->dccphrx_ccval;
+	new->li_is_closed = 0;
+
+	if (++lh->counter = 1)
+		lh->i_mean = new->li_length = (*calc_first_li)(sk);
+	else {
+		cur->li_length = dccp_delta_seqno(cur->li_seqno, new->li_seqno);
+		new->li_length = dccp_delta_seqno(new->li_seqno,
+						  last_rcv(rh)->dccphrx_seqno);
+		if (lh->counter > (2*LIH_SIZE))
+			lh->counter -= LIH_SIZE;
+
+		tfrc_lh_calc_i_mean(lh);
+	}
+	return 1;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_lh_interval_new);
+
 int __init li_init(void)
 {
 	tfrc_lh_slab = kmem_cache_create("tfrc_loss_history",
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -860,55 +860,6 @@ static u32 ccid3_hc_rx_calc_first_li(str
 	return (p = 0)? ~0U : scaled_div(1, p);
 }
 
-static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
-{
-#if 0 /* XXX subsequent patch */
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_li_hist_entry *head;
-	u64 seq_temp;
-
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
-			return;
-
-		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
-		   struct dccp_li_hist_entry, dccplih_node);
-		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
-	} else {
-		struct dccp_li_hist_entry *entry;
-		struct list_head *tail;
-
-		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
-		   struct dccp_li_hist_entry, dccplih_node);
-		/* FIXME win count check removed as was wrong */
-		/* should make this check with receive history */
-		/* and compare there as per section 10.2 of RFC4342 */
-
-		/* new loss event detected */
-		/* calculate last interval length */
-		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
-
-		if (entry = NULL) {
-			DCCP_BUG("out of memory - can not allocate entry");
-			return;
-		}
-
-		list_add(&entry->dccplih_node, &hcrx->ccid3hcrx_li_hist);
-
-		tail = hcrx->ccid3hcrx_li_hist.prev;
-		list_del(tail);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
-
-		/* Create the newest interval */
-		entry->dccplih_seqno = seq_loss;
-		entry->dccplih_interval = seq_temp;
-		entry->dccplih_win_count = win_loss;
-	}
-#endif
-}
-
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
