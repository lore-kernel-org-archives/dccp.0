From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 06 Dec 2007 21:02:51 +0000
Subject: [PATCH 4/7] [TFRC]: Make the rx history slab be global
Message-Id: <1196974974-31531-5-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-5-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-5-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is in preparation for merging the new rx history code written by Gerrit Renker.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid3.c              |   35 ++-----------
 net/dccp/ccids/lib/packet_history.c |   95 ++++++++++++++++++-----------------
 net/dccp/ccids/lib/packet_history.h |   43 ++--------------
 3 files changed, 60 insertions(+), 113 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 5dea690..07920bb 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -49,8 +49,6 @@ static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)
 #endif
 
-static struct dccp_rx_hist *ccid3_rx_hist;
-
 /*
  *	Transmitter Half-Connection Routines
  */
@@ -807,9 +805,9 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 	}
 
 detect_out:
-	dccp_rx_hist_add_packet(ccid3_rx_hist, &hcrx->ccid3hcrx_hist,
-		   &hcrx->ccid3hcrx_li_hist, packet,
-		   hcrx->ccid3hcrx_seqno_nonloss);
+	dccp_rx_hist_add_packet(&hcrx->ccid3hcrx_hist,
+				&hcrx->ccid3hcrx_li_hist, packet,
+				hcrx->ccid3hcrx_seqno_nonloss);
 	return loss;
 }
 
@@ -852,8 +850,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, opt_recv->dccpor_ndp,
-					skb, GFP_ATOMIC);
+	packet = dccp_rx_hist_entry_new(opt_recv->dccpor_ndp, skb, GFP_ATOMIC);
 	if (unlikely(packet = NULL)) {
 		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
 			  "to history, consider it lost!\n", dccp_role(sk), sk);
@@ -936,7 +933,7 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	/* Empty packet history */
-	dccp_rx_hist_purge(ccid3_rx_hist, &hcrx->ccid3hcrx_hist);
+	dccp_rx_hist_purge(&hcrx->ccid3hcrx_hist);
 
 	/* Empty loss interval history */
 	dccp_li_hist_purge(&hcrx->ccid3hcrx_li_hist);
@@ -1013,33 +1010,13 @@ MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
 
 static __init int ccid3_module_init(void)
 {
-	int rc = -ENOBUFS;
-
-	ccid3_rx_hist = dccp_rx_hist_new("ccid3");
-	if (ccid3_rx_hist = NULL)
-		goto out;
-
-	rc = ccid_register(&ccid3);
-	if (rc != 0)
-		goto out_free_rx;
-out:
-	return rc;
-
-out_free_rx:
-	dccp_rx_hist_delete(ccid3_rx_hist);
-	ccid3_rx_hist = NULL;
-	goto out;
+	return ccid_register(&ccid3);
 }
 module_init(ccid3_module_init);
 
 static __exit void ccid3_module_exit(void)
 {
 	ccid_unregister(&ccid3);
-
-	if (ccid3_rx_hist != NULL) {
-		dccp_rx_hist_delete(ccid3_rx_hist);
-		ccid3_rx_hist = NULL;
-	}
 }
 module_exit(ccid3_module_exit);
 
diff --git a/net/dccp/ccids/lib/packet_history.c b/net/dccp/ccids/lib/packet_history.c
index b628714..e1ab853 100644
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -114,48 +114,33 @@ EXPORT_SYMBOL_GPL(tfrc_tx_hist_rtt);
 /*
  * 	Receiver History Routines
  */
-struct dccp_rx_hist *dccp_rx_hist_new(const char *name)
+static struct kmem_cache *tfrc_rx_hist_slab;
+
+struct dccp_rx_hist_entry *dccp_rx_hist_entry_new(const u32 ndp,
+						  const struct sk_buff *skb,
+						  const gfp_t prio)
 {
-	struct dccp_rx_hist *hist = kmalloc(sizeof(*hist), GFP_ATOMIC);
-	static const char dccp_rx_hist_mask[] = "rx_hist_%s";
-	char *slab_name;
-
-	if (hist = NULL)
-		goto out;
-
-	slab_name = kmalloc(strlen(name) + sizeof(dccp_rx_hist_mask) - 1,
-			    GFP_ATOMIC);
-	if (slab_name = NULL)
-		goto out_free_hist;
-
-	sprintf(slab_name, dccp_rx_hist_mask, name);
-	hist->dccprxh_slab = kmem_cache_create(slab_name,
-					     sizeof(struct dccp_rx_hist_entry),
-					     0, SLAB_HWCACHE_ALIGN, NULL);
-	if (hist->dccprxh_slab = NULL)
-		goto out_free_slab_name;
-out:
-	return hist;
-out_free_slab_name:
-	kfree(slab_name);
-out_free_hist:
-	kfree(hist);
-	hist = NULL;
-	goto out;
-}
+	struct dccp_rx_hist_entry *entry = kmem_cache_alloc(tfrc_rx_hist_slab,
+							    prio);
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_new);
+	if (entry != NULL) {
+		const struct dccp_hdr *dh = dccp_hdr(skb);
 
-void dccp_rx_hist_delete(struct dccp_rx_hist *hist)
-{
-	const char* name = kmem_cache_name(hist->dccprxh_slab);
+		entry->dccphrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
+		entry->dccphrx_ccval = dh->dccph_ccval;
+		entry->dccphrx_type  = dh->dccph_type;
+		entry->dccphrx_ndp   = ndp;
+		entry->dccphrx_tstamp = ktime_get_real();
+	}
 
-	kmem_cache_destroy(hist->dccprxh_slab);
-	kfree(name);
-	kfree(hist);
+	return entry;
 }
+EXPORT_SYMBOL_GPL(dccp_rx_hist_entry_new);
 
-EXPORT_SYMBOL_GPL(dccp_rx_hist_delete);
+static inline void dccp_rx_hist_entry_delete(struct dccp_rx_hist_entry *entry)
+{
+	kmem_cache_free(tfrc_rx_hist_slab, entry);
+}
 
 int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 			    u8 *ccval)
@@ -192,11 +177,10 @@ struct dccp_rx_hist_entry *
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_find_data_packet);
 
-void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
-			    struct list_head *rx_list,
-			    struct list_head *li_list,
-			    struct dccp_rx_hist_entry *packet,
-			    u64 nonloss_seqno)
+void dccp_rx_hist_add_packet(struct list_head *rx_list,
+			     struct list_head *li_list,
+			     struct dccp_rx_hist_entry *packet,
+			     u64 nonloss_seqno)
 {
 	struct dccp_rx_hist_entry *entry, *next;
 	u8 num_later = 0;
@@ -211,7 +195,7 @@ void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 				if (after48(nonloss_seqno,
 				   entry->dccphrx_seqno)) {
 					list_del_init(&entry->dccphrx_node);
-					dccp_rx_hist_entry_delete(hist, entry);
+					dccp_rx_hist_entry_delete(entry);
 				}
 			} else if (dccp_rx_hist_entry_data_packet(entry))
 				--num_later;
@@ -253,7 +237,7 @@ void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 					break;
 				case 3:
 					list_del_init(&entry->dccphrx_node);
-					dccp_rx_hist_entry_delete(hist, entry);
+					dccp_rx_hist_entry_delete(entry);
 					break;
 				}
 			} else if (dccp_rx_hist_entry_data_packet(entry))
@@ -264,13 +248,13 @@ void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_add_packet);
 
-void dccp_rx_hist_purge(struct dccp_rx_hist *hist, struct list_head *list)
+void dccp_rx_hist_purge(struct list_head *list)
 {
 	struct dccp_rx_hist_entry *entry, *next;
 
 	list_for_each_entry_safe(entry, next, list, dccphrx_node) {
 		list_del_init(&entry->dccphrx_node);
-		kmem_cache_free(hist->dccprxh_slab, entry);
+		dccp_rx_hist_entry_delete(entry);
 	}
 }
 
@@ -281,8 +265,22 @@ __init int packet_history_init(void)
 	tfrc_tx_hist_slab = kmem_cache_create("tfrc_tx_hist",
 					      sizeof(struct tfrc_tx_hist_entry), 0,
 					      SLAB_HWCACHE_ALIGN, NULL);
+	if (tfrc_tx_hist_slab = NULL)
+		goto out_err;
 
-	return tfrc_tx_hist_slab = NULL ? -ENOBUFS : 0;
+	tfrc_rx_hist_slab = kmem_cache_create("tfrc_rx_hist",
+					      sizeof(struct dccp_rx_hist_entry), 0,
+					      SLAB_HWCACHE_ALIGN, NULL);
+	if (tfrc_rx_hist_slab = NULL)
+		goto out_free_tx;
+
+	return 0;
+
+out_free_tx:
+	kmem_cache_destroy(tfrc_tx_hist_slab);
+	tfrc_tx_hist_slab = NULL;
+out_err:
+	return -ENOBUFS;
 }
 
 void packet_history_exit(void)
@@ -291,4 +289,9 @@ void packet_history_exit(void)
 		kmem_cache_destroy(tfrc_tx_hist_slab);
 		tfrc_tx_hist_slab = NULL;
 	}
+
+	if (tfrc_rx_hist_slab != NULL) {
+		kmem_cache_destroy(tfrc_rx_hist_slab);
+		tfrc_rx_hist_slab = NULL;
+	}
 }
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 9a2642e..34b180b 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -66,34 +66,10 @@ struct dccp_rx_hist_entry {
 	ktime_t		 dccphrx_tstamp;
 };
 
-struct dccp_rx_hist {
-	struct kmem_cache *dccprxh_slab;
-};
-
-extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
-extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
-
-static inline struct dccp_rx_hist_entry *
-			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
-					       const u32 ndp,
+extern struct dccp_rx_hist_entry *
+			dccp_rx_hist_entry_new(const u32 ndp,
 					       const struct sk_buff *skb,
-					       const gfp_t prio)
-{
-	struct dccp_rx_hist_entry *entry = kmem_cache_alloc(hist->dccprxh_slab,
-							    prio);
-
-	if (entry != NULL) {
-		const struct dccp_hdr *dh = dccp_hdr(skb);
-
-		entry->dccphrx_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
-		entry->dccphrx_ccval = dh->dccph_ccval;
-		entry->dccphrx_type  = dh->dccph_type;
-		entry->dccphrx_ndp   = ndp;
-		entry->dccphrx_tstamp = ktime_get_real();
-	}
-
-	return entry;
-}
+					       const gfp_t prio);
 
 static inline struct dccp_rx_hist_entry *
 			dccp_rx_hist_head(struct list_head *list)
@@ -111,21 +87,12 @@ extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 extern struct dccp_rx_hist_entry *
 		dccp_rx_hist_find_data_packet(const struct list_head *list);
 
-extern void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
-				    struct list_head *rx_list,
+extern void dccp_rx_hist_add_packet(struct list_head *rx_list,
 				    struct list_head *li_list,
 				    struct dccp_rx_hist_entry *packet,
 				    u64 nonloss_seqno);
 
-static inline void dccp_rx_hist_entry_delete(struct dccp_rx_hist *hist,
-					     struct dccp_rx_hist_entry *entry)
-{
-	if (entry != NULL)
-		kmem_cache_free(hist->dccprxh_slab, entry);
-}
-
-extern void dccp_rx_hist_purge(struct dccp_rx_hist *hist,
-			       struct list_head *list);
+extern void dccp_rx_hist_purge(struct list_head *list);
 
 static inline int
 	dccp_rx_hist_entry_data_packet(const struct dccp_rx_hist_entry *entry)
-- 
1.5.3.4

