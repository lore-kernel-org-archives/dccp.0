From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:42:04 +0000
Subject: [PATCH 10/10] loss_interval: make struct dccp_li_hist_entry private
Message-Id: <20070616034204.GP24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

net/dccp/ccids/lib/loss_interval.c is the only place where this struct is used.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/loss_interval.c |    9 +++++++++
 net/dccp/ccids/lib/loss_interval.h |   10 ----------
 2 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index e6b1f0c..01c1edb 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -18,6 +18,15 @@
 #include "packet_history.h"
 #include "tfrc.h"
 
+#define DCCP_LI_HIST_IVAL_F_LENGTH  8
+
+struct dccp_li_hist_entry {
+	struct list_head dccplih_node;
+	u64		 dccplih_seqno:48,
+			 dccplih_win_count:4;
+	u32		 dccplih_interval;
+};
+
 struct kmem_cache *dccp_li_cachep __read_mostly;
 
 static inline struct dccp_li_hist_entry *dccp_li_hist_entry_new(const gfp_t prio)
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index f35c111..906c806 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -14,18 +14,8 @@
  */
 
 #include <linux/list.h>
-#include <linux/slab.h>
 #include <linux/time.h>
 
-#define DCCP_LI_HIST_IVAL_F_LENGTH  8
-
-struct dccp_li_hist_entry {
-	struct list_head dccplih_node;
-	u64		 dccplih_seqno:48,
-			 dccplih_win_count:4;
-	u32		 dccplih_interval;
-};
-
 extern void dccp_li_hist_purge(struct list_head *list);
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
-- 
1.5.0.6

