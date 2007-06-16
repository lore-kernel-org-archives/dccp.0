From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:40:41 +0000
Subject: [PATCH 04/10] Remove accesses to ccid3_hc_rx_sock in
Message-Id: <20070616034041.GJ24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a preparatory patch for moving these loss interval functions from
net/dccp/ccids/ccid3.c to net/dccp/ccids/lib/loss_interval.c.

Based on a patch by Ian McDonald.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   62 +++++++++++++++++++++++++++++++----------------
 1 files changed, 41 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 9686a8d..fb500d3 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -823,9 +823,12 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
  *
  * returns estimated loss interval in usecs */
 
-static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
+static u32 ccid3_hc_rx_calc_first_li(struct sock *sk,
+				     struct list_head *hist_list,
+				     struct timeval *last_feedback,
+				     u16 s, u32 bytes_recv,
+				     u32 previous_x_recv)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
@@ -835,8 +838,7 @@ static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
 	int step = 0;
 	u64 fval;
 
-	list_for_each_entry_safe(entry, next, &hcrx->ccid3hcrx_hist,
-				 dccphrx_node) {
+	list_for_each_entry_safe(entry, next, hist_list, dccphrx_node) {
 		if (dccp_rx_hist_entry_data_packet(entry)) {
 			tail = entry;
 
@@ -895,19 +897,20 @@ found:
 	}
 
 	dccp_timestamp(sk, &tstamp);
-	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
+	delta = timeval_delta(&tstamp, last_feedback);
 	DCCP_BUG_ON(delta <= 0);
 
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	x_recv = scaled_div32(bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
-		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
+		if (previous_x_recv = 0) {
 			DCCP_BUG("stored value of X_recv is zero");
 			return ~0;
 		}
+		x_recv = previous_x_recv;
 	}
 
-	fval = scaled_div(hcrx->ccid3hcrx_s, rtt);
+	fval = scaled_div(s, rtt);
 	fval = scaled_div32(fval, x_recv);
 	p = tfrc_calc_x_reverse_lookup(fval);
 
@@ -920,26 +923,36 @@ found:
 		return 1000000 / p;
 }
 
-static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
+static void ccid3_hc_rx_update_li(struct sock *sk,
+				  struct list_head *li_hist_list,
+				  struct list_head *hist_list,
+				  struct timeval *last_feedback,
+				  u16 s, u32 bytes_recv,
+				  u32 previous_x_recv,
+				  u64 seq_loss, u8 win_loss)
 {
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
 
-	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
+	if (list_empty(li_hist_list)) {
 		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
+					       li_hist_list, seq_loss,
+					       win_loss))
 			return;
 
-		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
-		   struct dccp_li_hist_entry, dccplih_node);
-		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
+		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
+				  dccplih_node);
+		head->dccplih_interval +				ccid3_hc_rx_calc_first_li(sk, hist_list,
+							  last_feedback, s,
+							  bytes_recv,
+							  previous_x_recv);
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
 
-		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
-		   struct dccp_li_hist_entry, dccplih_node);
+		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
+				  dccplih_node);
 		/* FIXME win count check removed as was wrong */
 		/* should make this check with receive history */
 		/* and compare there as per section 10.2 of RFC4342 */
@@ -954,9 +967,9 @@ static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 			return;
 		}
 
-		list_add(&entry->dccplih_node, &hcrx->ccid3hcrx_li_hist);
+		list_add(&entry->dccplih_node, li_hist_list);
 
-		tail = hcrx->ccid3hcrx_li_hist.prev;
+		tail = li_hist_list->prev;
 		list_del(tail);
 		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
 
@@ -992,8 +1005,15 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
-		   hcrx->ccid3hcrx_ccval_nonloss);
+		ccid3_hc_rx_update_li(sk,
+				      &hcrx->ccid3hcrx_li_hist,
+				      &hcrx->ccid3hcrx_hist,
+				      &hcrx->ccid3hcrx_tstamp_last_feedback,
+				      hcrx->ccid3hcrx_s,
+				      hcrx->ccid3hcrx_bytes_recv,
+				      hcrx->ccid3hcrx_x_recv,
+				      hcrx->ccid3hcrx_seqno_nonloss,
+				      hcrx->ccid3hcrx_ccval_nonloss);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-- 
1.5.0.6

