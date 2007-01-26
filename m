From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 26 Jan 2007 03:27:27 +0000
Subject: [PATCH 1/2] DCCP: Refactor li_hist code
Message-Id: <200701261627.28760.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_li_hist_interval_new doesn't need the last two parameters as the logic
doesn't belong there and makes dccp_li_update_li more confusing as to where
the structure values come from.

And of course it never hurts to reduce stack usage.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 5026802..0de594e 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -227,8 +227,7 @@ u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx, struct sk_buff *skb)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-static int dccp_li_hist_interval_new(struct list_head *list,
-   const u64 seq_nonloss, const u8 win_nonloss)
+static int dccp_li_hist_interval_new(struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry;
 	int i;
@@ -244,8 +243,6 @@ static int dccp_li_hist_interval_new(struct list_head *list,
 		list_add(&entry->dccplih_node, list);
 	}
 
-	entry->dccplih_seqno     = seq_nonloss;
-	entry->dccplih_win_count = win_nonloss;
 	return 1;
 }
 
@@ -385,13 +382,14 @@ void dccp_li_update_li(struct sock *sk, struct sk_buff *skb)
 	u8 win_nonloss = hcrx->ccid3hcrx_ccval_nonloss;
 
 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		if (!dccp_li_hist_interval_new(&hcrx->ccid3hcrx_li_hist,
-		   seq_nonloss, win_nonloss))
+		if (!dccp_li_hist_interval_new(&hcrx->ccid3hcrx_li_hist))
 			return;
 
 		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
 		   struct dccp_li_hist_entry, dccplih_node);
 		head->dccplih_interval = dccp_li_calc_first_li(sk, skb);
+		head->dccplih_seqno     = seq_nonloss;
+		head->dccplih_win_count = win_nonloss;
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
