From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 19 May 2007 05:18:34 +0000
Subject: [PATCH 5/7] DCCP: Simplify dccp_li_hist_interval_new
Message-Id: <200705191718.34999.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This simplifies dccp_li_hist_interval_new by removing one unused parameter.
We also rename variables to reflect use.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 1879da5..fd3d15f 100644
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
@@ -142,8 +142,8 @@ static int dccp_li_hist_interval_new(struct dccp_li_hist 
*hist,
 		list_add(&entry->dccplih_node, list);
 	}
 
-	entry->dccplih_seqno     = seq_loss;
-	entry->dccplih_win_count = win_loss;
+	entry->dccplih_seqno     = seq_nonloss;
+	entry->dccplih_win_count = win_nonloss;
 	return 1;
 }
 
@@ -257,8 +257,8 @@ void dccp_li_update_li(struct sock *sk)
 	u8 win_nonloss = hcrx->ccid3hcrx_ccval_nonloss;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		if (!dccp_li_hist_interval_new(dccp_li_hist,
-		   &hcrx->ccid3hcrx_li_hist, seq_nonloss, win_nonloss))
+		if (!dccp_li_hist_interval_new(&hcrx->ccid3hcrx_li_hist,
+		   seq_nonloss, win_nonloss))
 			return;
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
