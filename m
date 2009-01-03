From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Jan 2009 07:30:48 +0000
Subject: [PATCH 2/3] dccp: Clean up ccid.c after integration of CCID plugins
Message-Id: <1230967849-9456-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch cleans up after integrating the CCID modules and, in addition,

 * moves the if/else cases from ccid_delete() into ccid_hc_{tx,rx}_delete();
 * removes the 'gfp' argument to ccid_new() - since it is always gfp_any().

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.h |   49 -------------------
 net/dccp/ccid.c   |  136 ++++--------------------------------------------------
 net/dccp/ccid.h   |    3 -
 net/dccp/feat.c   |    2 
 4 files changed, 14 insertions(+), 176 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -84,7 +84,6 @@ struct dccp_ackvec_record {
 struct sock;
 struct sk_buff;
 
-#ifndef ___OLD_INTERFACE_TO_BE_REMOVED___
 extern int dccp_ackvec_init(void);
 extern void dccp_ackvec_exit(void);
 
@@ -106,52 +105,4 @@ static inline int dccp_ackvec_pending(co
 {
 	return av->av_vec_len;
 }
-#else /* ___OLD_INTERFACE_TO_BE_REMOVED___ */
-static inline int dccp_ackvec_init(void)
-{
-	return 0;
-}
-
-static inline void dccp_ackvec_exit(void)
-{
-}
-
-static inline struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
-{
-	return NULL;
-}
-
-static inline void dccp_ackvec_free(struct dccp_ackvec *av)
-{
-}
-
-static inline int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
-				  const u64 ackno, const u8 state)
-{
-	return -1;
-}
-
-static inline void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av,
-					       struct sock *sk, const u64 ackno)
-{
-}
-
-static inline int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
-				    const u64 *ackno, const u8 opt,
-				    const u8 *value, const u8 len)
-{
-	return -1;
-}
-
-static inline int dccp_insert_option_ackvec(const struct sock *sk,
-					    const struct sk_buff *skb)
-{
-	return -1;
-}
-
-static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
-{
-	return 0;
-}
-#endif /* CONFIG_IP_DCCP_ACKVEC */
 #endif /* _ACKVEC_H */
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -76,58 +76,6 @@ int ccid_getsockopt_builtin_ccids(struct
 	return err;
 }
 
-#ifdef ___OLD_INTERFACE_TO_BE_REMOVED___
-static u8 builtin_ccids[] = {
-	DCCPC_CCID2,		/* CCID2 is supported by default */
-#if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
-	DCCPC_CCID3,
-#endif
-};
-
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
-#endif /* ___OLD_INTERFACE_TO_BE_REMOVED___ */
-
 static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
 {
 	struct kmem_cache *slab;
@@ -158,49 +106,6 @@ static void ccid_kmem_cache_destroy(stru
 	}
 }
 
-#ifdef ___OLD_INTERFACE_TO_BE_REMOVED___
-/* check that up to @array_len members in @ccid_array are supported */
-bool ccid_support_check(u8 const *ccid_array, u8 array_len)
-{
-	u8 i, j, found;
-
-	for (i = 0, found = 0; i < array_len; i++, found = 0) {
-		for (j = 0; !found && j < ARRAY_SIZE(builtin_ccids); j++)
-			found = (ccid_array[i] = builtin_ccids[j]);
-		if (!found)
-			return false;
-	}
-	return true;
-}
-
-/**
- * ccid_get_builtin_ccids  -  Provide copy of `builtin' CCID array
- * @ccid_array: pointer to copy into
- * @array_len: value to return length into
- * This function allocates memory - caller must see that it is freed after use.
- */
-int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len)
-{
-	*ccid_array = kmemdup(builtin_ccids, sizeof(builtin_ccids), gfp_any());
-	if (*ccid_array = NULL)
-		return -ENOBUFS;
-	*array_len = ARRAY_SIZE(builtin_ccids);
-	return 0;
-}
-
-int ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
-				    char __user *optval, int __user *optlen)
-{
-	if (len < sizeof(builtin_ccids))
-		return -EINVAL;
-
-	if (put_user(sizeof(builtin_ccids), optlen) ||
-	    copy_to_user(optval, builtin_ccids, sizeof(builtin_ccids)))
-		return -EFAULT;
-	return 0;
-}
-#endif /* ___OLD_INTERFACE_TO_BE_REMOVED___ */
-
 static int ccid_activate(struct ccid_operations *ccid_ops)
 {
 	int err = -ENOBUFS;
@@ -241,7 +146,7 @@ static void ccid_deactivate(struct ccid_
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
 }
 
-struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
+struct ccid *ccid_new(const u8 id, struct sock *sk, bool rx)
 {
 	struct ccid_operations *ccid_ops = ccid_by_number(id);
 	struct ccid *ccid = NULL;
@@ -250,7 +155,7 @@ struct ccid *ccid_new(unsigned char id, 
 		goto out;
 
 	ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
-				     ccid_ops->ccid_hc_tx_slab, gfp);
+				     ccid_ops->ccid_hc_tx_slab, gfp_any());
 	if (ccid = NULL)
 		goto out;
 	ccid->ccid_ops = ccid_ops;
@@ -274,41 +179,24 @@ out_free_ccid:
 	goto out;
 }
 
-EXPORT_SYMBOL_GPL(ccid_new);
-
-static void ccid_delete(struct ccid *ccid, struct sock *sk, int rx)
-{
-	struct ccid_operations *ccid_ops;
-
-	if (ccid = NULL)
-		return;
-
-	ccid_ops = ccid->ccid_ops;
-	if (rx) {
-		if (ccid_ops->ccid_hc_rx_exit != NULL)
-			ccid_ops->ccid_hc_rx_exit(sk);
-		kmem_cache_free(ccid_ops->ccid_hc_rx_slab,  ccid);
-	} else {
-		if (ccid_ops->ccid_hc_tx_exit != NULL)
-			ccid_ops->ccid_hc_tx_exit(sk);
-		kmem_cache_free(ccid_ops->ccid_hc_tx_slab,  ccid);
-	}
-}
-
 void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk)
 {
-	ccid_delete(ccid, sk, 1);
+	if (ccid != NULL) {
+		if (ccid->ccid_ops->ccid_hc_rx_exit != NULL)
+			ccid->ccid_ops->ccid_hc_rx_exit(sk);
+		kmem_cache_free(ccid->ccid_ops->ccid_hc_rx_slab, ccid);
+	}
 }
 
-EXPORT_SYMBOL_GPL(ccid_hc_rx_delete);
-
 void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk)
 {
-	ccid_delete(ccid, sk, 0);
+	if (ccid != NULL) {
+		if (ccid->ccid_ops->ccid_hc_tx_exit != NULL)
+			ccid->ccid_ops->ccid_hc_tx_exit(sk);
+		kmem_cache_free(ccid->ccid_ops->ccid_hc_tx_slab, ccid);
+	}
 }
 
-EXPORT_SYMBOL_GPL(ccid_hc_tx_delete);
-
 int __init ccid_initialize_builtins(void)
 {
 	int i, err;
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -111,8 +111,7 @@ extern int  ccid_get_builtin_ccids(u8 **
 extern int  ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
 					  char __user *, int __user *);
 
-extern struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx,
-			     gfp_t gfp);
+extern struct ccid *ccid_new(const u8 id, struct sock *sk, bool rx);
 
 static inline int ccid_get_current_rx_ccid(struct dccp_sock *dp)
 {
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
