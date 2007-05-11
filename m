From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 11 May 2007 10:36:35 +0000
Subject: [PATCH 1/5] DCCP: Shift ccid3_li_hist
Message-Id: <200705112236.36406.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This shifts ccid3_li_hist.

We temporarily export the symbol but remove this in later patch.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 31f50fa..a532249 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,7 +49,6 @@ static int ccid3_debug;
 
 static struct dccp_tx_hist *ccid3_tx_hist;
 static struct dccp_rx_hist *ccid3_rx_hist;
-static struct dccp_li_hist *ccid3_li_hist;
 
 /*
  *	Transmitter Half-Connection Routines
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index 3829afc..f21e1a9 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -16,6 +16,9 @@
 #include "../../dccp.h"
 #include "loss_interval.h"
 
+struct dccp_li_hist *ccid3_li_hist;
+EXPORT_SYMBOL_GPL(ccid3_li_hist);
+
 struct dccp_li_hist *dccp_li_hist_new(const char *name)
 {
 	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
diff --git a/net/dccp/ccids/lib/loss_interval.h 
b/net/dccp/ccids/lib/loss_interval.h
index c295947..4186a55 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -47,4 +47,6 @@ extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 
 extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
    struct list_head *list, const u64 seq_loss, const u8 win_loss);
+
+extern struct dccp_li_hist *ccid3_li_hist;
 #endif /* _DCCP_LI_HIST_ */
