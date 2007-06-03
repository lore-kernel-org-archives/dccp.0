From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sun, 03 Jun 2007 23:53:30 +0000
Subject: [PATCH 3/3] DCCP: Refactor dccp_li_hist_interval_new
Message-Id: <200706041153.31101.ian.mcdonald@jandi.co.nz>
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
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 8e13f42..ba4c535 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -92,8 +92,7 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-static int dccp_li_hist_interval_new(struct list_head *list,
-				     const u64 seq_loss, const u8 win_loss)
+static int dccp_li_hist_interval_new(struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry;
 	int i;
@@ -109,8 +108,6 @@ static int dccp_li_hist_interval_new(struct list_head 
*list,
 		list_add(&entry->dccplih_node, list);
 	}
 
-	entry->dccplih_seqno     = seq_loss;
-	entry->dccplih_win_count = win_loss;
 	return 1;
 }
 
@@ -227,8 +224,7 @@ void dccp_li_update_li(struct sock *sk,
 	u64 seq_temp;
 
 	if (list_empty(li_hist_list)) {
-		if (!dccp_li_hist_interval_new(li_hist_list, seq_loss,
-					       win_loss))
+		if (!dccp_li_hist_interval_new(li_hist_list))
 			return;
 
 		head = list_entry(li_hist_list->next, struct dccp_li_hist_entry,
@@ -237,6 +233,8 @@ void dccp_li_update_li(struct sock *sk,
 							       last_feedback,
 							       s, bytes_recv,
 							       previous_x_recv);
+		head->dccplih_seqno = seq_loss;
+		head->dccplih_win_count = win_loss;
 	} else {
 		struct dccp_li_hist_entry *entry;
 		struct list_head *tail;
