From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sun, 03 Jun 2007 23:51:33 +0000
Subject: [PATCH 2/3] DCCP: Simplify dccp_li_hist_entry_new
Message-Id: <200706041151.34183.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This simplifies dccp_li_hist_entry_new.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index fd9c6d9..8e13f42 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -29,9 +29,9 @@ struct dccp_li_hist_entry {
 
 struct kmem_cache *dccp_li_cachep __read_mostly;
 
-static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t 
prio)
+static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(void)
 {
-	return kmem_cache_alloc(dccp_li_cachep, prio);
+	return kmem_cache_alloc(dccp_li_cachep, GFP_ATOMIC);
 }
 
 void dccp_li_hist_purge(struct list_head *list)
@@ -99,7 +99,7 @@ static int dccp_li_hist_interval_new(struct list_head *list,
 	int i;
 
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new();
 		if (entry = NULL) {
 			dccp_li_hist_purge(list);
 			DCCP_BUG("loss interval list entry is NULL");
@@ -250,7 +250,7 @@ void dccp_li_update_li(struct sock *sk,
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new();
 
 		if (entry = NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
