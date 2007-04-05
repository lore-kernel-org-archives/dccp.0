From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:33:46 +0000
Subject: [PATCH 8/43]: New RX History Step 2 - Initialisation and cleanup
Message-Id: <200704051633.46816@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: New RX History Step 2 - Initialisation and cleanup

This adds initialisation and cleanup wrappers for the RX history.

It further makes the allocation of dccp_rx_hist entries local to
packet_history.c, as a service exported by the tfrc module.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   26 ++++--------------
 net/dccp/ccids/lib/packet_history.c |   51 +++++++++++++++++++++++++++++++-----
 net/dccp/ccids/lib/packet_history.h |    5 +--
 net/dccp/ccids/lib/tfrc_module.c    |    7 ++++
 4 files changed, 60 insertions(+), 29 deletions(-)

--- a/net/dccp/ccids/lib/tfrc_module.c
+++ b/net/dccp/ccids/lib/tfrc_module.c
@@ -5,15 +5,20 @@
 #include <linux/moduleparam.h>
 #include "tfrc.h"
 
+/* Initialisation / Clean-up routines */
+extern int  packet_history_init(void);
+extern void packet_history_cleanup(void);
+
 static int __init tfrc_module_init(void)
 {
-	int rc = 0;
+	int rc = packet_history_init();
 
 	return rc;
 }
 
 static void __exit tfrc_module_exit(void)
 {
+	packet_history_cleanup();
 }
 
 module_init(tfrc_module_init);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -46,7 +46,6 @@ static int ccid3_debug;
 #endif
 
 static struct dccp_tx_hist *ccid3_tx_hist;
-static struct dccp_rx_hist *ccid3_rx_hist;
 static struct dccp_li_hist *ccid3_li_hist;
 
 /*
@@ -1116,13 +1115,14 @@ static int ccid3_hc_rx_init(struct ccid 
 
 	ccid3_pr_debug("entry\n");
 
-	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
-	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
+	if (tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist))
+		return 1;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
 	do_gettimeofday(&hcrx->ccid3hcrx_tstamp_last_ack);
 	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
-	hcrx->ccid3hcrx_s   = 0;
-	hcrx->ccid3hcrx_rtt = 0;
+	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
+	hcrx->ccid3hcrx_s     = 0;
+	hcrx->ccid3hcrx_rtt   = 0;
 	return 0;
 }
 
@@ -1134,8 +1134,7 @@ static void ccid3_hc_rx_exit(struct sock
 
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
-	/* Empty packet history */
-	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
+	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
 	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
@@ -1219,13 +1218,9 @@ static __init int ccid3_module_init(void
 {
 	int rc = -ENOBUFS;
 
-	ccid3_rx_hist = dccp_rx_hist_new("ccid3");
-	if (ccid3_rx_hist = NULL)
-		goto out;
-
 	ccid3_tx_hist = dccp_tx_hist_new("ccid3");
 	if (ccid3_tx_hist = NULL)
-		goto out_free_rx;
+		goto out;
 
 	ccid3_li_hist = dccp_li_hist_new("ccid3");
 	if (ccid3_li_hist = NULL)
@@ -1243,9 +1238,6 @@ out_free_loss_interval_history:
 out_free_tx:
 	dccp_tx_hist_delete(ccid3_tx_hist);
 	ccid3_tx_hist = NULL;
-out_free_rx:
-	dccp_rx_hist_delete(ccid3_rx_hist);
-	ccid3_rx_hist = NULL;
 	goto out;
 }
 module_init(ccid3_module_init);
@@ -1258,10 +1250,6 @@ static __exit void ccid3_module_exit(voi
 		dccp_tx_hist_delete(ccid3_tx_hist);
 		ccid3_tx_hist = NULL;
 	}
-	if (ccid3_rx_hist != NULL) {
-		dccp_rx_hist_delete(ccid3_rx_hist);
-		ccid3_rx_hist = NULL;
-	}
 	if (ccid3_li_hist != NULL) {
 		dccp_li_hist_delete(ccid3_li_hist);
 		ccid3_li_hist = NULL;
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -164,7 +164,9 @@ EXPORT_SYMBOL_GPL(dccp_tx_hist_purge);
 /*
  * 	Receiver History Routines
  */
-struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
+static struct dccp_rx_hist *tfrcxh;
+
+static struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
 {
 	struct dccp_rx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
 	static const char dccp_rx_hist_mask[] = "rx_hist_%s";
@@ -195,9 +197,7 @@ out_free_hist:
 	goto out;
 }
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_new);
-
-void dccp_rx_hist_delete(struct dccp_rx_hist *hist)
+static void dccp_rx_hist_delete(struct dccp_rx_hist *hist)
 {
 	const char* name = kmem_cache_name(hist->dccprxh_slab);
 
@@ -206,8 +206,6 @@ void dccp_rx_hist_delete(struct dccp_rx_
 	kfree(hist);
 }
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_delete);
-
 int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 			    u8 *ccval)
 {
@@ -324,3 +322,44 @@ void dccp_rx_hist_purge(struct dccp_rx_h
 }
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_purge);
+
+int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	for (i = 0; i <= NDUPACK; i++) {
+		h->ring[i] = kmem_cache_alloc(tfrcxh->dccprxh_slab, GFP_ATOMIC);
+		if (h->ring[i] = NULL)
+			return 1;
+	}
+	spin_lock_init(&h->lock);
+	h->loss_count = 0;
+	h->loss_start = 0;
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);
+
+void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	for (i=0; i <= NDUPACK; i++)
+		if (h->ring[i] != NULL)
+			kmem_cache_free(tfrcxh->dccprxh_slab, h->ring[i]);
+}
+
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
+
+/* Module initialisation and cleanup routines */
+int __init packet_history_init(void)
+{
+	tfrcxh = dccp_rx_hist_new("tfrc");
+	return tfrcxh = NULL ? -ENOBUFS : 0;
+}
+
+void __exit packet_history_cleanup(void)
+{
+	if (tfrcxh != NULL)
+		dccp_rx_hist_delete(tfrcxh);
+}
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -106,9 +106,6 @@ struct dccp_rx_hist {
 	struct kmem_cache *dccprxh_slab;
 };
 
-extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
-extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
-
 /**
  *   tfrc_rx_hist  -  RX history structure for TFRC-based protocols
  *
@@ -205,6 +202,8 @@ static inline void tfrc_rx_hist_swap(str
 	*b = tmp;
 }
 
+extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
+extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
 
 /* Older history management functions */
 static inline struct dccp_rx_hist_entry *
