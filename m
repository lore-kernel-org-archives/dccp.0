From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 23 Mar 2007 03:04:22 +0000
Subject: [PATCH 5/9] DCCP: Simplify update_li
Message-Id: <200703231504.22346.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch simplifies ccid3_hc_rx_update_li. We rename variables also to
more accurately reflect what they are.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 5db5387..af6e7d6 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -844,8 +844,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
 		loss = 1;
-		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
-		   hcrx->ccid3hcrx_ccval_nonloss);
+		ccid3_hc_rx_update_li(sk);
 		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
 		dccp_inc_seqno(&tmp_seqno);
 		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 5640905..e2d6a60 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -250,15 +250,17 @@ found:
 		return 1000000 / p;
 }
 
-void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
+void ccid3_hc_rx_update_li(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
+	u64 seq_nonloss = hcrx->ccid3hcrx_seqno_nonloss;
+	u64 win_nonloss = hcrx->ccid3hcrx_ccval_nonloss;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
 		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_loss, win_loss))
+		   &hcrx->ccid3hcrx_li_hist, seq_nonloss, win_nonloss))
 			return;
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
@@ -276,7 +278,7 @@ void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 
 		/* new loss event detected */
 		/* calculate last interval length */
-		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
+		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_nonloss);
 		entry = dccp_li_hist_entry_new();
 
 		if (entry = NULL) {
@@ -291,9 +293,9 @@ void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 		kmem_cache_free(ccid3_li_hist->dccplih_slab, tail);
 
 		/* Create the newest interval */
-		entry->dccplih_seqno = seq_loss;
+		entry->dccplih_seqno = seq_nonloss;
 		entry->dccplih_interval = seq_temp;
-		entry->dccplih_win_count = win_loss;
+		entry->dccplih_win_count = win_nonloss;
 	}
 }
 
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index ead0b58..757c45c 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -34,5 +34,5 @@ extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss);
+void ccid3_hc_rx_update_li(struct sock *sk);
 #endif /* _DCCP_LI_HIST_ */
