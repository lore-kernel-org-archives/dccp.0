From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 23 Mar 2007 03:05:22 +0000
Subject: [PATCH 6/9] DCCP: simplify dccp_li_hist_interval_new
Message-Id: <200703231505.22984.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
References: <200703221608.23696.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200703221608.23696.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This simplifies dccp_li_hist_interval_new. Also removes an unneeded
EXPORT_SYMBOL_GPL. Rename variables to reflect use and also fix one
incorrect type.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index e2d6a60..6c5a7a9 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -125,8 +125,8 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-static int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-   struct list_head *list, const u64 seq_loss, const u8 win_loss)
+static int dccp_li_hist_interval_new(struct list_head *list,
+   const u64 seq_nonloss, const u8 win_nonloss)
 {
 	struct dccp_li_hist_entry *entry;
 	int i;
@@ -142,13 +142,11 @@ static int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 		list_add(&entry->dccplih_node, list);
 	}
 
-	entry->dccplih_seqno     = seq_loss;
-	entry->dccplih_win_count = win_loss;
+	entry->dccplih_seqno     = seq_nonloss;
+	entry->dccplih_win_count = win_nonloss;
 	return 1;
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
-
 /* calculate first loss interval
  *
  * returns estimated loss interval in usecs */
@@ -256,11 +254,11 @@ void ccid3_hc_rx_update_li(struct sock *sk)
 	struct dccp_li_hist_entry *head;
 	u64 seq_temp;
 	u64 seq_nonloss = hcrx->ccid3hcrx_seqno_nonloss;
-	u64 win_nonloss = hcrx->ccid3hcrx_ccval_nonloss;
+	u8 win_nonloss = hcrx->ccid3hcrx_ccval_nonloss;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		if (!dccp_li_hist_interval_new(ccid3_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_nonloss, win_nonloss))
+		if (!dccp_li_hist_interval_new(&hcrx->ccid3hcrx_li_hist,
+		   seq_nonloss, win_nonloss))
 			return;
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
