From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Sat, 19 May 2007 05:14:58 +0000
Subject: [PATCH 3/7] DCCP: Simplify dccp_li_hist_entry_new
Message-Id: <200705191714.58867.ian.mcdonald@jandi.co.nz>
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
index 8360f56..1efdf5c 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -22,10 +22,9 @@
 static struct dccp_li_hist *dccp_li_hist;
 
 static inline struct dccp_li_hist_entry *
-		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
-				       const gfp_t prio)
+		dccp_li_hist_entry_new(void)
 {
-	return kmem_cache_alloc(hist->dccplih_slab, prio);
+	return kmem_cache_alloc(dccp_li_hist->dccplih_slab, GFP_ATOMIC);
 }
 
 static struct dccp_li_hist *dccp_li_hist_new(const char *name)
@@ -133,7 +132,7 @@ static int dccp_li_hist_interval_new(struct dccp_li_hist 
*hist,
 	int i;
 
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new();
 		if (entry = NULL) {
 			dccp_li_hist_purge(list);
 			DCCP_BUG("loss interval list entry is NULL");
@@ -276,7 +275,7 @@ void dccp_li_update_li(struct sock *sk, u64 seq_loss, u8 
win_loss)
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(dccp_li_hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new();
 
 		if (entry = NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
