From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 04 Jun 2007 03:22:34 +0000
Subject: [PATCH 1/1] DCCP: Use dccp_li_hist_entry_delete
Message-Id: <200706041522.34731.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_li_hist_entry_delete is currently unused.

Let's use it. Based on comments by Arnaldo.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 83b5504..15c1d59 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -46,7 +46,7 @@ void dccp_li_hist_purge(struct list_head *list)
 
 	list_for_each_entry_safe(entry, next, list, dccplih_node) {
 		list_del_init(&entry->dccplih_node);
-		kmem_cache_free(dccp_li_cachep, entry);
+		dccp_li_hist_entry_delete(entry);
 	}
 }
 
@@ -267,7 +267,7 @@ void dccp_li_update_li(struct sock *sk,
 
 		tail = li_hist_list->prev;
 		list_del(tail);
-		kmem_cache_free(dccp_li_cachep, tail);
+		dccp_li_hist_entry_delete((struct dccp_li_hist_entry *)tail);
 
 		/* Create the newest interval */
 		entry->dccplih_seqno = seq_loss;
