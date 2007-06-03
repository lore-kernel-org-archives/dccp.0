From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sun, 03 Jun 2007 23:49:44 +0000
Subject: [PATCH 1/3] DCCP: Remove dccp_li_hist_entry_delete
Message-Id: <200706041149.45174.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes dccp_li_hist_entry_delete as it's not used anywhere.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 83b5504..fd9c6d9 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -34,12 +34,6 @@ static inline struct dccp_li_hist_entry 
*dccp_li_hist_entry_new(const gfp_t prio
 	return kmem_cache_alloc(dccp_li_cachep, prio);
 }
 
-static inline void dccp_li_hist_entry_delete(struct dccp_li_hist_entry 
*entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(dccp_li_cachep, entry);
-}
-
 void dccp_li_hist_purge(struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
