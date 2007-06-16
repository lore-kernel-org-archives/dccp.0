From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:40:54 +0000
Subject: [PATCH 05/10] [CCID3]: Pass ccid3_li_hist to ccid3_hc_rx_update_li
Message-Id: <20070616034054.GK24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Now ccid3_hc_rx_update_li is ready to be moved to
net/dccp/ccids/lib/loss_interval, it uses the same interface as the other
functions there.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index fb500d3..52a71a9 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -924,6 +924,7 @@ found:
 }
 
 static void ccid3_hc_rx_update_li(struct sock *sk,
+				  struct dccp_li_hist *li_hist,
 				  struct list_head *li_hist_list,
 				  struct list_head *hist_list,
 				  struct timeval *last_feedback,
@@ -935,9 +936,8 @@ static void ccid3_hc_rx_update_li(struct sock *sk,
 	u64 seq_temp;
 
 	if (list_empty(li_hist_list)) {
-		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-					       li_hist_list, seq_loss,
-					       win_loss))
+		if (!dccp_li_hist_interval_new(li_hist, li_hist_list,
+					       seq_loss, win_loss))
 			return;
 
 		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
@@ -960,7 +960,7 @@ static void ccid3_hc_rx_update_li(struct sock *sk,
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new(li_hist, GFP_ATOMIC);
 
 		if (entry = NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
@@ -971,7 +971,7 @@ static void ccid3_hc_rx_update_li(struct sock *sk,
 
 		tail = li_hist_list->prev;
 		list_del(tail);
-		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
+		kmem_cache_free(li_hist->dccplih_slab, tail);
 
 		/* Create the newest interval */
 		entry->dccplih_seqno = seq_loss;
@@ -1005,7 +1005,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk,
+		ccid3_hc_rx_update_li(sk, ccid3_li_hist,
 				      &hcrx->ccid3hcrx_li_hist,
 				      &hcrx->ccid3hcrx_hist,
 				      &hcrx->ccid3hcrx_tstamp_last_feedback,
-- 
1.5.0.6

