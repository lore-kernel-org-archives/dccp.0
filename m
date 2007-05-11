From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Fri, 11 May 2007 10:37:54 +0000
Subject: [PATCH 2/5] DCCP: Shift initialisation code
Message-Id: <200705112237.54638.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This creates li_module_init and li_module_exit and shifts equivalent code
out of ccid3.c.

Also shifts dccp_li_hist_new as part of this and makes it static.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index a532249..d818f09 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1236,19 +1236,12 @@ static __init int ccid3_module_init(void)
 	if (ccid3_tx_hist = NULL)
 		goto out_free_rx;
 
-	ccid3_li_hist = dccp_li_hist_new("ccid3");
-	if (ccid3_li_hist = NULL)
-		goto out_free_tx;
-
 	rc = ccid_register(&ccid3);
 	if (rc != 0)
-		goto out_free_loss_interval_history;
+		goto out_free_tx;
 out:
 	return rc;
 
-out_free_loss_interval_history:
-	dccp_li_hist_delete(ccid3_li_hist);
-	ccid3_li_hist = NULL;
 out_free_tx:
 	dccp_tx_hist_delete(ccid3_tx_hist);
 	ccid3_tx_hist = NULL;
@@ -1271,10 +1264,6 @@ static __exit void ccid3_module_exit(void)
 		dccp_rx_hist_delete(ccid3_rx_hist);
 		ccid3_rx_hist = NULL;
 	}
-	if (ccid3_li_hist != NULL) {
-		dccp_li_hist_delete(ccid3_li_hist);
-		ccid3_li_hist = NULL;
-	}
 }
 module_exit(ccid3_module_exit);
 
diff --git a/net/dccp/ccids/lib/loss_interval.c 
b/net/dccp/ccids/lib/loss_interval.c
index f21e1a9..5b2c7c1 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -19,7 +19,7 @@
 struct dccp_li_hist *ccid3_li_hist;
 EXPORT_SYMBOL_GPL(ccid3_li_hist);
 
-struct dccp_li_hist *dccp_li_hist_new(const char *name)
+static struct dccp_li_hist *dccp_li_hist_new(const char *name)
 {
 	struct dccp_li_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
 	static const char dccp_li_hist_mask[] = "li_hist_%s";
@@ -50,8 +50,6 @@ out_free_hist:
 	goto out;
 }
 
-EXPORT_SYMBOL_GPL(dccp_li_hist_new);
-
 void dccp_li_hist_delete(struct dccp_li_hist *hist)
 {
 	const char* name = kmem_cache_name(hist->dccplih_slab);
@@ -144,3 +142,19 @@ int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
 }
 
 EXPORT_SYMBOL_GPL(dccp_li_hist_interval_new);
+
+static __init int li_module_init(void)
+{
+	ccid3_li_hist = dccp_li_hist_new("ccid3");
+	return ccid3_li_hist = NULL ? -ENOBUFS : 0;
+}
+module_init(li_module_init);
+
+static __exit void li_module_exit(void)
+{
+	if (ccid3_li_hist != NULL) {
+		dccp_li_hist_delete(ccid3_li_hist);
+		ccid3_li_hist = NULL;
+	}
+}
+module_exit(li_module_exit);
diff --git a/net/dccp/ccids/lib/loss_interval.h 
b/net/dccp/ccids/lib/loss_interval.h
index 4186a55..90f23b4 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -23,7 +23,6 @@ struct dccp_li_hist {
 	struct kmem_cache *dccplih_slab;
 };
 
-extern struct dccp_li_hist *dccp_li_hist_new(const char *name);
 extern void dccp_li_hist_delete(struct dccp_li_hist *hist);
 
 struct dccp_li_hist_entry {
