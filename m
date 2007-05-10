From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Thu, 10 May 2007 03:43:27 +0000
Subject: [PATCH 3/3] DCCP: Tidy up dccp_li_hist_purge
Message-Id: <200705101543.27880.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch removes a parameter from dccp_li_hist_purge and can therefore
also remove an EXPORT_SYMBOL_GPL we introduced in a previous patch.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 682a438..2ef3bb4 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1004,7 +1004,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
-	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
+	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index d067d4a..587fbab 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -19,8 +19,7 @@
 #include "packet_history.h"
 #include "tfrc.h"
 
-struct dccp_li_hist *ccid3_li_hist;
-EXPORT_SYMBOL_GPL(ccid3_li_hist);
+static struct dccp_li_hist *ccid3_li_hist;
 
 static inline struct dccp_li_hist_entry *
 		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
@@ -69,13 +68,13 @@ static void dccp_li_hist_delete(struct dccp_li_hist *hist)
 	kfree(hist);
 }
 
-void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
+void dccp_li_hist_purge(struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(hist->dccplih_slab, entry);
+		kmem_cache_free(ccid3_li_hist->dccplih_slab, entry);
 	}
 }
 
@@ -136,7 +135,7 @@ static int dccp_li_hist_interval_new(struct dccp_li_hist 
*hist,
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
 		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
 		if (entry = NULL) {
-			dccp_li_hist_purge(hist, list);
+			dccp_li_hist_purge(list);
 			DCCP_BUG("loss interval list entry is NULL");
 			return 0;
 		}
diff --git a/net/dccp/ccids/lib/loss_interval.h 
b/net/dccp/ccids/lib/loss_interval.h
index 98daec0..ead0b58 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -30,12 +30,9 @@ struct dccp_li_hist_entry {
 	u32		 dccplih_interval;
 };
 
-extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
-			       struct list_head *list);
+extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
 void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss);
-
-extern struct dccp_li_hist *ccid3_li_hist;
 #endif /* _DCCP_LI_HIST_ */
