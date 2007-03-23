From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 23 Mar 2007 03:03:25 +0000
Subject: [PATCH 4/9] DCCP: Simplify dccp_li_hist_entry_new
Message-Id: <200703231503.25645.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
References: <200703221606.41557.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200703221606.41557.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This simplifies dccp_li_hist_entry_new.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 587fbab..5640905 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -22,10 +22,9 @@
 static struct dccp_li_hist *ccid3_li_hist;
 
 static inline struct dccp_li_hist_entry *
-		dccp_li_hist_entry_new(struct dccp_li_hist *hist,
-				       const gfp_t prio)
+		dccp_li_hist_entry_new(void)
 {
-	return kmem_cache_alloc(hist->dccplih_slab, prio);
+	return kmem_cache_alloc(ccid3_li_hist->dccplih_slab, GFP_ATOMIC);
 }
 
 static struct dccp_li_hist *dccp_li_hist_new(const char *name)
@@ -133,7 +132,7 @@ static int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 	int i;
 
 	for (i = 0; i < DCCP_LI_HIST_IVAL_F_LENGTH; i++) {
-		entry = dccp_li_hist_entry_new(hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new();
 		if (entry = NULL) {
 			dccp_li_hist_purge(list);
 			DCCP_BUG("loss interval list entry is NULL");
@@ -278,7 +277,7 @@ void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
 		/* new loss event detected */
 		/* calculate last interval length */
 		seq_temp = dccp_delta_seqno(head->dccplih_seqno, seq_loss);
-		entry = dccp_li_hist_entry_new(ccid3_li_hist, GFP_ATOMIC);
+		entry = dccp_li_hist_entry_new();
 
 		if (entry = NULL) {
 			DCCP_BUG("out of memory - can not allocate entry");
