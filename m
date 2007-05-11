From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 11 May 2007 01:02:30 +0000
Subject: [PATCH 1/1] DCCP: Delete unused function
Message-Id: <200705111302.30706.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes dccp_li_hist_entry_delete as it's not used anywhere.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.h 
b/net/dccp/ccids/lib/loss_interval.h
index 1e48fe3..c295947 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -40,13 +40,6 @@ static inline struct dccp_li_hist_entry *
 	return kmem_cache_alloc(hist->dccplih_slab, prio);
 }
 
-static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
-					     struct dccp_li_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccplih_slab, entry);
-}
-
 extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
 			       struct list_head *list);
 
