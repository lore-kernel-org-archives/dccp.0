From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 03:41:27 +0000
Subject: [PATCH 07/10] loss_interval: unexport dccp_li_hist_interval_new
Message-Id: <20070616034127.GM24488@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Now its only used inside the loss_interval code.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/lib/loss_interval.c |    7 +++----
 net/dccp/ccids/lib/loss_interval.h |    3 ---
 2 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index ee59fde..8ac68c6 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -120,8 +120,9 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
 
-int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-   struct list_head *list, const u64 seq_loss, const u8 win_loss)
+static int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
+				     struct list_head *list,
+				     const u64 seq_loss, const u8 win_loss)
 {
 	struct dccp_li_hist_entry *entry;
 	int i;
@@ -142,8 +143,6 @@ int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 	return 1;
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
-
 /* calculate first loss interval
  *
  * returns estimated loss interval in usecs */
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 17f173a..653328d 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -52,9 +52,6 @@ extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
 
 extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
-extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
-   struct list_head *list, const u64 seq_loss, const u8 win_loss);
-
 extern void dccp_li_update_li(struct sock *sk, struct dccp_li_hist *li_hist,
 			      struct list_head *li_hist_list,
 			      struct list_head *hist_list,
-- 
1.5.0.6

