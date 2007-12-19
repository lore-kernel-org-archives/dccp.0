From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:46 +0000
Subject: [PATCH 05/14] [ACKVEC]: Smaller allocation/deallocation routines
Message-Id: <1198074355-18842-6-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch removes redundant bits, implementing the same functionality with less code.

The details are:
  * The INIT_LIST_HEAD in dccp_ackvec_record_new was redundant, since the list pointers
    were later overwritten when the node was added via list_add().

  * dccp_ackvec_record_new() was called only in one instance in the entire ackvec code.

  * The calls to list_del_init() before calling dccp_ackvec_record_delete() were redundant,
    since subsequently the entire element was freed anyway.

  * Similarly, since all calls to dccp_ackvec_record_delete() were preceded to a call to
    list_del_init(), the WARN_ON test would never evaluate to true.

  * Also, since all calls to dccp_ackvec_record_delete() were made from within list_for
    each_entry_safe(), the test for avr = NULL was redundant.

  * The list_empty() test in ackvec_free was redundant, since the same condition is
    embedded in the loop condition of the subsequent list_for_each_entry_safe().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |   78 +++++++++++++++++++----------------------------------
 1 files changed, 28 insertions(+), 50 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -24,24 +24,34 @@
 static struct kmem_cache *dccp_ackvec_slab;
 static struct kmem_cache *dccp_ackvec_record_slab;
 
-static struct dccp_ackvec_record *dccp_ackvec_record_new(void)
+struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 {
-	struct dccp_ackvec_record *avr -			kmem_cache_alloc(dccp_ackvec_record_slab, GFP_ATOMIC);
+	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
+
+	if (av != NULL) {
+		av->av_buf_head	 = DCCPAV_MAX_ACKVEC_LEN - 1;
+		av->av_vec_len	 = 0;
+		memset(av->av_buf_nonce, 0, sizeof(av->av_buf_nonce));
+		INIT_LIST_HEAD(&av->av_records);
+	}
+	return av;
+}
 
-	if (avr != NULL)
-		INIT_LIST_HEAD(&avr->avr_node);
+static void dccp_ackvec_purge_records(struct dccp_ackvec *av)
+{
+	struct dccp_ackvec_record *cur, *next;
 
-	return avr;
+	list_for_each_entry_safe(cur, next, &av->av_records, avr_node)
+		kmem_cache_free(dccp_ackvec_record_slab, cur);
+	INIT_LIST_HEAD(&av->av_records);
 }
 
-static void dccp_ackvec_record_delete(struct dccp_ackvec_record *avr)
+void dccp_ackvec_free(struct dccp_ackvec *av)
 {
-	if (unlikely(avr = NULL))
-		return;
-	/* Check if deleting a linked record */
-	WARN_ON(!list_empty(&avr->avr_node));
-	kmem_cache_free(dccp_ackvec_record_slab, avr);
+	if (likely(av != NULL)) {
+		dccp_ackvec_purge_records(av);
+		kmem_cache_free(dccp_ackvec_slab, av);
+	}
 }
 
 static void dccp_ackvec_insert_avr(struct dccp_ackvec *av,
@@ -85,7 +95,7 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 		return -1;
 	}
 
-	avr = dccp_ackvec_record_new();
+	avr = kmem_cache_alloc(dccp_ackvec_record_slab, GFP_ATOMIC);
 	if (avr = NULL)
 		return -1;
 
@@ -147,37 +157,6 @@ int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
 	return 0;
 }
 
-struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
-{
-	struct dccp_ackvec *av = kmem_cache_alloc(dccp_ackvec_slab, priority);
-
-	if (av != NULL) {
-		av->av_buf_head	 = DCCPAV_MAX_ACKVEC_LEN - 1;
-		av->av_vec_len	 = 0;
-		memset(av->av_buf_nonce, 0, sizeof(av->av_buf_nonce));
-		INIT_LIST_HEAD(&av->av_records);
-	}
-
-	return av;
-}
-
-void dccp_ackvec_free(struct dccp_ackvec *av)
-{
-	if (unlikely(av = NULL))
-		return;
-
-	if (!list_empty(&av->av_records)) {
-		struct dccp_ackvec_record *avr, *next;
-
-		list_for_each_entry_safe(avr, next, &av->av_records, avr_node) {
-			list_del_init(&avr->avr_node);
-			dccp_ackvec_record_delete(avr);
-		}
-	}
-
-	kmem_cache_free(dccp_ackvec_slab, av);
-}
-
 /*
  * If several packets are missing, the HC-Receiver may prefer to enter multiple
  * bytes with run length 0, rather than a single byte with a larger run length;
@@ -321,8 +300,8 @@ static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
 
 	/* free records */
 	list_for_each_entry_safe_from(avr, next, &av->av_records, avr_node) {
-		list_del_init(&avr->avr_node);
-		dccp_ackvec_record_delete(avr);
+		list_del(&avr->avr_node);
+		kmem_cache_free(dccp_ackvec_record_slab, avr);
 	}
 }
 
@@ -431,10 +410,9 @@ int __init dccp_ackvec_init(void)
 	if (dccp_ackvec_slab = NULL)
 		goto out_err;
 
-	dccp_ackvec_record_slab -			kmem_cache_create("dccp_ackvec_record",
-					  sizeof(struct dccp_ackvec_record),
-					  0, SLAB_HWCACHE_ALIGN, NULL);
+	dccp_ackvec_record_slab = kmem_cache_create("dccp_ackvec_record",
+					     sizeof(struct dccp_ackvec_record),
+					     0, SLAB_HWCACHE_ALIGN, NULL);
 	if (dccp_ackvec_record_slab = NULL)
 		goto out_destroy_slab;
 
-- 
1.5.3.GIT

