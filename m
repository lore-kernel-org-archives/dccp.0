From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 20 Dec 2008 08:08:13 +0000
Subject: [RFC] [Patch 2/4] dccp: Lockless use of CCID blocks
Message-Id: <20081220080813.GC3853@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp: Lockless use of CCIDs

This updates the implementation to use only a single array whose size
equals the number of configured CCIDs instead of 255.

Since the CCIDs are fixed array elements, synchronization is no longer
needed.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccid.h |   10 ---
 net/dccp/ccid.c |  166 +++++++++++---------------------------------------------
 net/dccp/feat.c |    2 
 3 files changed, 38 insertions(+), 140 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -19,14 +19,12 @@
 #include <linux/list.h>
 #include <linux/module.h>
 
-#define CCID_MAX 255
-
 struct tcp_info;
 
 /**
  *  struct ccid_operations  -  Interface to Congestion-Control Infrastructure
  *
- *  @ccid_id: numerical CCID ID (up to %CCID_MAX, cf. table 5 in RFC 4340, 10.)
+ *  @ccid_id: numerical CCID ID (cf. table 5 in RFC 4340, 10.)
  *  @ccid_ccmps: the CCMPS including network/transport headers (0 when disabled)
  *  @ccid_name: alphabetical identifier string for @ccid_id
  *  @ccid_hc_{r,t}x_slab: memory pool for the receiver/sender half-connection
@@ -93,9 +91,6 @@ extern struct ccid_operations ccid2_ops;
 extern struct ccid_operations ccid3_ops;
 #endif
 
-extern int ccid_register(struct ccid_operations *ccid_ops);
-extern int ccid_unregister(struct ccid_operations *ccid_ops);
-
 extern int ccids_register_builtins(void);
 
 struct ccid {
@@ -113,8 +108,7 @@ extern int  ccid_get_builtin_ccids(u8 **
 extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
 					  char __user *, int __user *);
 
-extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
-			     gfp_t gfp);
+extern struct ccid *ccid_new(const u8 id, struct sock *sk, bool rx);
 
 static inline int ccid_get_current_rx_ccid(struct dccp_sock *dp)
 {
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -13,8 +13,8 @@
 
 #include "ccid.h"
 
-static struct ccid_operations *builtin_ccids_ops[] = {
-	&ccid2_ops,		/* CCID2 is supported by default */
+static struct ccid_operations *ccids[] = {
+	&ccid2_ops,	/* CCID-2 is supported by default */
 #ifdef CONFIG_IP_DCCP_CCID3
 	&ccid3_ops,
 #endif
@@ -27,49 +27,6 @@ static u8 builtin_ccids[] = {
 #endif
 };
 
-static struct ccid_operations *ccids[CCID_MAX];
-#if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
-static atomic_t ccids_lockct = ATOMIC_INIT(0);
-static DEFINE_SPINLOCK(ccids_lock);
-
-/*
- * The strategy is: modifications ccids vector are short, do not sleep and
- * veeery rare, but read access should be free of any exclusive locks.
- */
-static void ccids_write_lock(void)
-{
-	spin_lock(&ccids_lock);
-	while (atomic_read(&ccids_lockct) != 0) {
-		spin_unlock(&ccids_lock);
-		yield();
-		spin_lock(&ccids_lock);
-	}
-}
-
-static inline void ccids_write_unlock(void)
-{
-	spin_unlock(&ccids_lock);
-}
-
-static inline void ccids_read_lock(void)
-{
-	atomic_inc(&ccids_lockct);
-	smp_mb__after_atomic_inc();
-	spin_unlock_wait(&ccids_lock);
-}
-
-static inline void ccids_read_unlock(void)
-{
-	atomic_dec(&ccids_lockct);
-}
-
-#else
-#define ccids_write_lock() do { } while(0)
-#define ccids_write_unlock() do { } while(0)
-#define ccids_read_lock() do { } while(0)
-#define ccids_read_unlock() do { } while(0)
-#endif
-
 static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
 {
 	struct kmem_cache *slab;
@@ -141,56 +98,33 @@ int ccid_getsockopt_builtin_ccids(struct
 	return 0;
 }
 
-int ccid_register(struct ccid_operations *ccid_ops)
+static int ccid_register(struct ccid_operations *ccid_ops)
 {
-	int err = -ENOBUFS;
-
 	ccid_ops->ccid_hc_rx_slab  			ccid_kmem_cache_create(ccid_ops->ccid_hc_rx_obj_size,
 					       "ccid%u_hc_rx_sock",
 					       ccid_ops->ccid_id);
 	if (ccid_ops->ccid_hc_rx_slab = NULL)
-		goto out;
+		return -ENOBUFS;
 
 	ccid_ops->ccid_hc_tx_slab  			ccid_kmem_cache_create(ccid_ops->ccid_hc_tx_obj_size,
 					       "ccid%u_hc_tx_sock",
 					       ccid_ops->ccid_id);
-	if (ccid_ops->ccid_hc_tx_slab = NULL)
-		goto out_free_rx_slab;
 
-	ccids_write_lock();
-	err = -EEXIST;
-	if (ccids[ccid_ops->ccid_id] = NULL) {
-		ccids[ccid_ops->ccid_id] = ccid_ops;
-		err = 0;
+	if (ccid_ops->ccid_hc_tx_slab = NULL) {
+		ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
+		ccid_ops->ccid_hc_rx_slab = NULL;
+		return -ENOBUFS;
 	}
-	ccids_write_unlock();
-	if (err != 0)
-		goto out_free_tx_slab;
 
 	pr_info("CCID: Registered CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
-out:
-	return err;
-out_free_tx_slab:
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
-	ccid_ops->ccid_hc_tx_slab = NULL;
-	goto out;
-out_free_rx_slab:
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
-	ccid_ops->ccid_hc_rx_slab = NULL;
-	goto out;
+	return 0;
 }
 
-EXPORT_SYMBOL_GPL(ccid_register);
-
-int ccid_unregister(struct ccid_operations *ccid_ops)
+static int ccid_unregister(struct ccid_operations *ccid_ops)
 {
-	ccids_write_lock();
-	ccids[ccid_ops->ccid_id] = NULL;
-	ccids_write_unlock();
-
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
 	ccid_ops->ccid_hc_tx_slab = NULL;
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
@@ -201,14 +135,12 @@ int ccid_unregister(struct ccid_operatio
 	return 0;
 }
 
-EXPORT_SYMBOL_GPL(ccid_unregister);
-
 int ccids_register_builtins(void)
 {
 	int i, err;
 
-	for (i = 0; i < ARRAY_SIZE(builtin_ccids_ops); i++) {
-		err = ccid_register(builtin_ccids_ops[i]);
+	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
+		err = ccid_register(ccids[i]);
 		if (err)
 			goto unwind_registrations;
 	}
@@ -217,15 +149,31 @@ int ccids_register_builtins(void)
 
 unwind_registrations:
 	while(--i >= 0)
-		ccid_unregister(builtin_ccids_ops[i]);
+		ccid_unregister(ccids[i]);
 	return err;
 }
 
-static struct ccid *__ccid_new(struct ccid_operations *ccid_ops, struct sock *sk,
-			       int rx, gfp_t gfp)
+
+static struct ccid_operations *ccid_find_by_id(const u8 id)
 {
-	struct ccid *ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
-						  ccid_ops->ccid_hc_tx_slab, gfp);
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ccids); i++)
+		if (ccids[i]->ccid_id = id)
+			return ccids[i];
+	return NULL;
+}
+
+struct ccid *ccid_new(const u8 id, struct sock *sk, bool rx)
+{
+	struct ccid_operations *ccid_ops = ccid_find_by_id(id);
+	struct ccid *ccid;
+
+	if (ccid_ops = NULL)
+		return NULL;
+
+	ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
+				     ccid_ops->ccid_hc_tx_slab, gfp_any());
 	if (ccid = NULL)
 		return NULL;
 
@@ -241,58 +189,14 @@ static struct ccid *__ccid_new(struct cc
 		    ccid->ccid_ops->ccid_hc_tx_init(ccid, sk) != 0)
 			goto out_free_ccid;
 	}
+
 	return ccid;
+
 out_free_ccid:
 	kmem_cache_free(rx ? ccid_ops->ccid_hc_rx_slab :
 			     ccid_ops->ccid_hc_tx_slab, ccid);
 	return NULL;
 }
-
-static bool is_builtin_ccid(unsigned char id)
-{
-	int i;
-	for (i = 0; i < ARRAY_SIZE(builtin_ccids); i++)
-		if (id = builtin_ccids[i])
-			return true;
-	return false;
-}
-
-struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
-{
-	struct ccid_operations *ccid_ops;
-	struct ccid *ccid = NULL;
-
-	if (is_builtin_ccid(id)) {
-		ccid_ops = ccids[id];
-		BUG_ON(ccid_ops = NULL);
-		return __ccid_new(ccid_ops, sk, rx, gfp);
-	}
-
-	ccids_read_lock();
-#ifdef CONFIG_MODULES
-	if (ccids[id] = NULL) {
-		/* We only try to load if in process context */
-		ccids_read_unlock();
-		if (gfp & GFP_ATOMIC)
-			goto out;
-		request_module("net-dccp-ccid-%d", id);
-		ccids_read_lock();
-	}
-#endif
-	ccid_ops = ccids[id];
-	if (ccid_ops = NULL)
-		goto out_unlock;
-
-	ccids_read_unlock();
-
-	ccid = __ccid_new(ccid_ops, sk, rx, gfp);
-out:
-	return ccid;
-out_unlock:
-	ccids_read_unlock();
-	goto out;
-}
-
 EXPORT_SYMBOL_GPL(ccid_new);
 
 static void ccid_delete(struct ccid *ccid, struct sock *sk, int rx)
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -34,7 +34,7 @@
 static int dccp_hdlr_ccid(struct sock *sk, u64 ccid, bool rx)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid *new_ccid = ccid_new(ccid, sk, rx, gfp_any());
+	struct ccid *new_ccid = ccid_new(ccid, sk, rx);
 
 	if (new_ccid = NULL)
 		return -ENOMEM;
