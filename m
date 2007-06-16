From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:41:41 +0000
Subject: [PATCH 08/10] loss_interval: Make dccp_li_hist_entry_{new,delete}
Message-Id: <20070616034141.GN24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Not used outside the loss_interval code anymore.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/loss_interval.c |   14 ++++++++++++++
 net/dccp/ccids/lib/loss_interval.h |   14 --------------
 2 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 8ac68c6..28eac9b 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -62,6 +62,20 @@ void dccp_li_hist_delete(struct dccp_li_hist *hist)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_delete);
 
+static inline struct dccp_li_hist_entry *
+		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
+				       const gfp_t prio)
+{
+	return kmem_cache_alloc(hist->dccplih_slab, prio);
+}
+
+static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
+					     struct dccp_li_hist_entry *entry)
+{
+	if (entry != NULL)
+		kmem_cache_free(hist->dccplih_slab, entry);
+}
+
 void dccp_li_hist_purge(struct dccp_li_hist *hist, struct list_head *list)
 {
 	struct dccp_li_hist_entry *entry, *next;
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 653328d..8d3c9bf 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -33,20 +33,6 @@ struct dccp_li_hist_entry {
 	u32		 dccplih_interval;
 };
 
-static inline struct dccp_li_hist_entry *
-		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
-				       const gfp_t prio)
-{
-	return kmem_cache_alloc(hist->dccplih_slab, prio);
-}
-
-static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
-					     struct dccp_li_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccplih_slab, entry);
-}
-
 extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
 			       struct list_head *list);
 
-- 
1.5.0.6

