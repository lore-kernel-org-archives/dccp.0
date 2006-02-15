From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 15 Feb 2006 18:22:45 +0000
Subject: [RFC] CCID infrastructure improvements
Message-Id: <39e6f6c70602151022v2d63a9d3nf88c0db59bfa36e9@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_9900_19507798.1140027765246"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_9900_19507798.1140027765246
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi Ian, Andrea,

       Can somebody please poke holes in the attached patch? It moves
more code out of the
CCIDs into the CCID infrastructure, simplifying some stuff.

       With this rework ccid_operations becomes the struct proto
counterpart in ccid land (struct sock has a "operations" pointer to
struct proto).

       I saw the need for this when working on Andrea's ccid feature
negotiation patch, that I'm
now reworking to take advantage of the attached patch.

- Arnaldo

------=_Part_9900_19507798.1140027765246
Content-Type: text/x-patch; name=ccid_operations.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
X-Attachment-Id: f_ejpz0yks
Content-Disposition: attachment; filename="ccid_operations.patch"

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index a70d1a2..bdd756c 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -478,8 +478,6 @@ struct dccp_sock {
 	__u32				dccps_mss_cache;
 	struct dccp_options		dccps_options;
 	struct dccp_ackvec		*dccps_hc_rx_ackvec;
-	void				*dccps_hc_rx_ccid_private;
-	void				*dccps_hc_tx_ccid_private;
 	struct ccid			*dccps_hc_rx_ccid;
 	struct ccid			*dccps_hc_tx_ccid;
 	struct dccp_options_received	dccps_options_received;
diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index 06b191a..49dea2a 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -13,7 +13,7 @@
 
 #include "ccid.h"
 
-static struct ccid *ccids[CCID_MAX];
+static struct ccid_operations *ccids[CCID_MAX];
 #if defined(CONFIG_SMP) || defined(CONFIG_PREEMPT)
 static atomic_t ccids_lockct = ATOMIC_INIT(0);
 static DEFINE_SPINLOCK(ccids_lock);
@@ -55,40 +55,103 @@ static inline void ccids_read_unlock(voi
 #define ccids_read_unlock() do { } while(0)
 #endif
 
-int ccid_register(struct ccid *ccid)
+static kmem_cache_t *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
 {
-	int err;
+	kmem_cache_t *slab;
+	char slab_name_fmt[32], *slab_name;
+	va_list args;
+
+	va_start(args, fmt);
+	vsnprintf(slab_name_fmt, sizeof(slab_name_fmt), fmt, args);
+	va_end(args);
+
+	slab_name = kstrdup(slab_name_fmt, GFP_KERNEL);
+	if (slab_name == NULL)
+		return NULL;
+	slab = kmem_cache_create(slab_name, sizeof(struct ccid) + obj_size, 0,
+				 SLAB_HWCACHE_ALIGN, NULL, NULL);
+	if (slab == NULL)
+		kfree(slab_name);
+	return slab;
+}
+
+static void ccid_kmem_cache_destroy(kmem_cache_t *slab)
+{
+	if (slab != NULL) {
+		const char *name = kmem_cache_name(slab);
+		
+		kmem_cache_destroy(slab);
+		kfree(name);
+	}
+}
+
+int ccid_register(struct ccid_operations *ccid_ops)
+{
+	int err = -ENOBUFS;
+
+	ccid_ops->ccid_hc_rx_slab =
+			ccid_kmem_cache_create(ccid_ops->ccid_hc_rx_obj_size,
+					       "%s_hc_rx_sock",
+					       ccid_ops->ccid_name);
+	if (ccid_ops->ccid_hc_rx_slab == NULL)
+		goto out;
+
+	ccid_ops->ccid_hc_tx_slab =
+			ccid_kmem_cache_create(ccid_ops->ccid_hc_tx_obj_size,
+					       "%s_hc_tx_sock",
+					       ccid_ops->ccid_name);
+	if (ccid_ops->ccid_hc_tx_slab == NULL)
+		goto out_free_rx_slab;
 
 	ccids_write_lock();
 	err = -EEXIST;
-	if (ccids[ccid->ccid_id] == NULL) {
-		ccids[ccid->ccid_id] = ccid;
+	if (ccids[ccid_ops->ccid_id] == NULL) {
+		ccids[ccid_ops->ccid_id] = ccid_ops;
 		err = 0;
 	}
 	ccids_write_unlock();
-	if (err == 0)
-		pr_info("CCID: Registered CCID %d (%s)\n",
-			ccid->ccid_id, ccid->ccid_name);
+	if (err != 0)
+		goto out_free_tx_slab;
+
+	pr_info("CCID: Registered CCID %d (%s)\n",
+		ccid_ops->ccid_id, ccid_ops->ccid_name);
+out:
 	return err;
+out_free_tx_slab:
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
+	ccid_ops->ccid_hc_tx_slab = NULL;
+	goto out;
+out_free_rx_slab:
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
+	ccid_ops->ccid_hc_rx_slab = NULL;
+	goto out;
 }
 
 EXPORT_SYMBOL_GPL(ccid_register);
 
-int ccid_unregister(struct ccid *ccid)
+int ccid_unregister(struct ccid_operations *ccid_ops)
 {
 	ccids_write_lock();
-	ccids[ccid->ccid_id] = NULL;
+	ccids[ccid_ops->ccid_id] = NULL;
 	ccids_write_unlock();
+
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
+	ccid_ops->ccid_hc_tx_slab = NULL;
+	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
+	ccid_ops->ccid_hc_rx_slab = NULL;
+
 	pr_info("CCID: Unregistered CCID %d (%s)\n",
-		ccid->ccid_id, ccid->ccid_name);
+		ccid_ops->ccid_id, ccid_ops->ccid_name);
 	return 0;
 }
 
 EXPORT_SYMBOL_GPL(ccid_unregister);
 
-struct ccid *ccid_init(unsigned char id, struct sock *sk)
+static struct ccid *ccid_new(unsigned char id, struct sock *sk,
+			     int rx, gfp_t gfp)
 {
-	struct ccid *ccid;
+	struct ccid_operations *ccid_ops;
+	struct ccid *ccid = NULL;
 
 #ifdef CONFIG_KMOD
 	if (ccids[id] == NULL)
@@ -96,41 +159,92 @@ struct ccid *ccid_init(unsigned char id,
 #endif
 	ccids_read_lock();
 
-	ccid = ccids[id];
-	if (ccid == NULL)
-		goto out;
+	ccid_ops = ccids[id];
+	if (ccid_ops == NULL)
+		goto out_unlock;
+
+	if (!try_module_get(ccid_ops->ccid_owner))
+		goto out_unlock;
 
-	if (!try_module_get(ccid->ccid_owner))
-		goto out_err;
+	ccids_read_unlock();
 
-	if (ccid->ccid_init != NULL && ccid->ccid_init(sk) != 0)
+	ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
+				     ccid_ops->ccid_hc_tx_slab, gfp);
+	if (ccid == NULL)
 		goto out_module_put;
+	ccid->ccid_ops = ccid_ops;
+	if (rx) {
+		memset(ccid + 1, 0, ccid_ops->ccid_hc_rx_obj_size);
+		if (ccid->ccid_ops->ccid_hc_rx_init != NULL &&
+		    ccid->ccid_ops->ccid_hc_rx_init(ccid, sk) != 0)
+			goto out_free_ccid;
+	} else {
+		memset(ccid + 1, 0, ccid_ops->ccid_hc_tx_obj_size);
+		if (ccid->ccid_ops->ccid_hc_tx_init != NULL &&
+		    ccid->ccid_ops->ccid_hc_tx_init(ccid, sk) != 0)
+			goto out_free_ccid;
+	}
 out:
-	ccids_read_unlock();
 	return ccid;
-out_module_put:
-	module_put(ccid->ccid_owner);
-out_err:
+out_unlock:
+	ccids_read_unlock();
+	goto out;
+out_free_ccid:
+	kmem_cache_free(rx ? ccid_ops->ccid_hc_rx_slab :
+			ccid_ops->ccid_hc_tx_slab, ccid);
 	ccid = NULL;
+out_module_put:
+	module_put(ccid_ops->ccid_owner);
 	goto out;
 }
 
-EXPORT_SYMBOL_GPL(ccid_init);
+struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk, gfp_t gfp)
+{
+	return ccid_new(id, sk, 1, gfp);
+}
+
+EXPORT_SYMBOL_GPL(ccid_hc_rx_new);
+
+struct ccid *ccid_hc_tx_new(unsigned char id,struct sock *sk,  gfp_t gfp)
+{
+	return ccid_new(id, sk, 0, gfp);
+}
+
+EXPORT_SYMBOL_GPL(ccid_hc_tx_new);
 
-void ccid_exit(struct ccid *ccid, struct sock *sk)
+static void ccid_delete(struct ccid *ccid, struct sock *sk, int rx)
 {
+	struct ccid_operations *ccid_ops;
+
 	if (ccid == NULL)
 		return;
 
+	ccid_ops = ccid->ccid_ops;
+	if (rx) {
+		if (ccid_ops->ccid_hc_rx_exit != NULL)
+			ccid_ops->ccid_hc_rx_exit(sk);
+		kmem_cache_free(ccid_ops->ccid_hc_rx_slab,  ccid);
+	} else {
+		if (ccid_ops->ccid_hc_tx_exit != NULL)
+			ccid_ops->ccid_hc_tx_exit(sk);
+		kmem_cache_free(ccid_ops->ccid_hc_tx_slab,  ccid);
+	}
 	ccids_read_lock();
+	if (ccids[ccid_ops->ccid_id] != NULL)
+		module_put(ccid_ops->ccid_owner);
+	ccids_read_unlock();
+}
 
-	if (ccids[ccid->ccid_id] != NULL) {
-		if (ccid->ccid_exit != NULL)
-			ccid->ccid_exit(sk);
-		module_put(ccid->ccid_owner);
-	}
+void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk)
+{
+	return ccid_delete(ccid, sk, 1);
+}
 
-	ccids_read_unlock();
+EXPORT_SYMBOL_GPL(ccid_hc_rx_delete);
+
+void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk)
+{
+	return ccid_delete(ccid, sk, 0);
 }
 
-EXPORT_SYMBOL_GPL(ccid_exit);
+EXPORT_SYMBOL_GPL(ccid_hc_tx_delete);
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index de681c6..cfc67df 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -23,14 +23,16 @@
 
 struct tcp_info;
 
-struct ccid {
+struct ccid_operations {
 	unsigned char	ccid_id;
 	const char	*ccid_name;
 	struct module	*ccid_owner;
-	int		(*ccid_init)(struct sock *sk);
-	void		(*ccid_exit)(struct sock *sk);
-	int		(*ccid_hc_rx_init)(struct sock *sk);
-	int		(*ccid_hc_tx_init)(struct sock *sk);
+	kmem_cache_t	*ccid_hc_rx_slab;
+	__u32		ccid_hc_rx_obj_size;
+	kmem_cache_t	*ccid_hc_tx_slab;
+	__u32		ccid_hc_tx_obj_size;
+	int		(*ccid_hc_rx_init)(struct ccid *ccid, struct sock *sk);
+	int		(*ccid_hc_tx_init)(struct ccid *ccid, struct sock *sk);
 	void		(*ccid_hc_rx_exit)(struct sock *sk);
 	void		(*ccid_hc_tx_exit)(struct sock *sk);
 	void		(*ccid_hc_rx_packet_recv)(struct sock *sk,
@@ -67,75 +69,60 @@ struct ccid {
 						 int __user *optlen);
 };
 
-extern int	   ccid_register(struct ccid *ccid);
-extern int	   ccid_unregister(struct ccid *ccid);
+extern int ccid_register(struct ccid_operations *ccid_ops);
+extern int ccid_unregister(struct ccid_operations *ccid_ops);
 
-extern struct ccid *ccid_init(unsigned char id, struct sock *sk);
-extern void	   ccid_exit(struct ccid *ccid, struct sock *sk);
+struct ccid {
+	struct ccid_operations *ccid_ops;
+	char		       ccid_priv[0];
+};
 
-static inline void __ccid_get(struct ccid *ccid)
+static inline void *ccid_priv(const struct ccid *ccid)
 {
-	__module_get(ccid->ccid_owner);
+	return (void *)ccid->ccid_priv;
 }
 
-static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
-					 struct sk_buff *skb, int len)
-{
-	int rc = 0;
-	if (ccid->ccid_hc_tx_send_packet != NULL)
-		rc = ccid->ccid_hc_tx_send_packet(sk, skb, len);
-	return rc;
-}
+extern struct ccid *ccid_hc_rx_new(unsigned char id, struct sock *sk,
+				   gfp_t gfp);
+extern struct ccid *ccid_hc_tx_new(unsigned char id, struct sock *sk,
+				   gfp_t gfp);
 
-static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
-					  int more, int len)
-{
-	if (ccid->ccid_hc_tx_packet_sent != NULL)
-		ccid->ccid_hc_tx_packet_sent(sk, more, len);
-}
+extern void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk);
+extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
-static inline int ccid_hc_rx_init(struct ccid *ccid, struct sock *sk)
+static inline void __ccid_get(struct ccid *ccid)
 {
-	int rc = 0;
-	if (ccid->ccid_hc_rx_init != NULL)
-		rc = ccid->ccid_hc_rx_init(sk);
-	return rc;
+	__module_get(ccid->ccid_ops->ccid_owner);
 }
 
-static inline int ccid_hc_tx_init(struct ccid *ccid, struct sock *sk)
+static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
+					 struct sk_buff *skb, int len)
 {
 	int rc = 0;
-	if (ccid->ccid_hc_tx_init != NULL)
-		rc = ccid->ccid_hc_tx_init(sk);
+	if (ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
+		rc = ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb, len);
 	return rc;
 }
 
-static inline void ccid_hc_rx_exit(struct ccid *ccid, struct sock *sk)
-{
-	if (ccid != NULL && ccid->ccid_hc_rx_exit != NULL &&
-	    dccp_sk(sk)->dccps_hc_rx_ccid_private != NULL)
-		ccid->ccid_hc_rx_exit(sk);
-}
-
-static inline void ccid_hc_tx_exit(struct ccid *ccid, struct sock *sk)
+static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
+					  int more, int len)
 {
-	if (ccid != NULL && ccid->ccid_hc_tx_exit != NULL &&
-	    dccp_sk(sk)->dccps_hc_tx_ccid_private != NULL)
-		ccid->ccid_hc_tx_exit(sk);
+	if (ccid->ccid_ops->ccid_hc_tx_packet_sent != NULL)
+		ccid->ccid_ops->ccid_hc_tx_packet_sent(sk, more, len);
 }
-
+ 
 static inline void ccid_hc_rx_packet_recv(struct ccid *ccid, struct sock *sk,
 					  struct sk_buff *skb)
 {
-	if (ccid->ccid_hc_rx_packet_recv != NULL)
-		ccid->ccid_hc_rx_packet_recv(sk, skb);
+	if (ccid->ccid_ops->ccid_hc_rx_packet_recv != NULL)
+		ccid->ccid_ops->ccid_hc_rx_packet_recv(sk, skb);
 }
 
 static inline void ccid_hc_tx_packet_recv(struct ccid *ccid, struct sock *sk,
 					  struct sk_buff *skb)
 {
-	if (ccid->ccid_hc_tx_packet_recv != NULL)
-		ccid->ccid_hc_tx_packet_recv(sk, skb);
+	if (ccid->ccid_ops->ccid_hc_tx_packet_recv != NULL)
+		ccid->ccid_ops->ccid_hc_tx_packet_recv(sk, skb);
 }
 
 static inline int ccid_hc_tx_parse_options(struct ccid *ccid, struct sock *sk,
@@ -144,8 +131,8 @@ static inline int ccid_hc_tx_parse_optio
 					   unsigned char* value)
 {
 	int rc = 0;
-	if (ccid->ccid_hc_tx_parse_options != NULL)
-		rc = ccid->ccid_hc_tx_parse_options(sk, option, len, idx,
+	if (ccid->ccid_ops->ccid_hc_tx_parse_options != NULL)
+		rc = ccid->ccid_ops->ccid_hc_tx_parse_options(sk, option, len, idx,
 						    value);
 	return rc;
 }
@@ -156,37 +143,37 @@ static inline int ccid_hc_rx_parse_optio
 					   unsigned char* value)
 {
 	int rc = 0;
-	if (ccid->ccid_hc_rx_parse_options != NULL)
-		rc = ccid->ccid_hc_rx_parse_options(sk, option, len, idx, value);
+	if (ccid->ccid_ops->ccid_hc_rx_parse_options != NULL)
+		rc = ccid->ccid_ops->ccid_hc_rx_parse_options(sk, option, len, idx, value);
 	return rc;
 }
 
 static inline void ccid_hc_tx_insert_options(struct ccid *ccid, struct sock *sk,
 					     struct sk_buff *skb)
 {
-	if (ccid->ccid_hc_tx_insert_options != NULL)
-		ccid->ccid_hc_tx_insert_options(sk, skb);
+	if (ccid->ccid_ops->ccid_hc_tx_insert_options != NULL)
+		ccid->ccid_ops->ccid_hc_tx_insert_options(sk, skb);
 }
 
 static inline void ccid_hc_rx_insert_options(struct ccid *ccid, struct sock *sk,
 					     struct sk_buff *skb)
 {
-	if (ccid->ccid_hc_rx_insert_options != NULL)
-		ccid->ccid_hc_rx_insert_options(sk, skb);
+	if (ccid->ccid_ops->ccid_hc_rx_insert_options != NULL)
+		ccid->ccid_ops->ccid_hc_rx_insert_options(sk, skb);
 }
 
 static inline void ccid_hc_rx_get_info(struct ccid *ccid, struct sock *sk,
 				       struct tcp_info *info)
 {
-	if (ccid->ccid_hc_rx_get_info != NULL)
-		ccid->ccid_hc_rx_get_info(sk, info);
+	if (ccid->ccid_ops->ccid_hc_rx_get_info != NULL)
+		ccid->ccid_ops->ccid_hc_rx_get_info(sk, info);
 }
 
 static inline void ccid_hc_tx_get_info(struct ccid *ccid, struct sock *sk,
 				       struct tcp_info *info)
 {
-	if (ccid->ccid_hc_tx_get_info != NULL)
-		ccid->ccid_hc_tx_get_info(sk, info);
+	if (ccid->ccid_ops->ccid_hc_tx_get_info != NULL)
+		ccid->ccid_ops->ccid_hc_tx_get_info(sk, info);
 }
 
 static inline int ccid_hc_rx_getsockopt(struct ccid *ccid, struct sock *sk,
@@ -194,8 +181,8 @@ static inline int ccid_hc_rx_getsockopt(
 					u32 __user *optval, int __user *optlen)
 {
 	int rc = -ENOPROTOOPT;
-	if (ccid->ccid_hc_rx_getsockopt != NULL)
-		rc = ccid->ccid_hc_rx_getsockopt(sk, optname, len,
+	if (ccid->ccid_ops->ccid_hc_rx_getsockopt != NULL)
+		rc = ccid->ccid_ops->ccid_hc_rx_getsockopt(sk, optname, len,
 						 optval, optlen);
 	return rc;
 }
@@ -205,8 +192,8 @@ static inline int ccid_hc_tx_getsockopt(
 					u32 __user *optval, int __user *optlen)
 {
 	int rc = -ENOPROTOOPT;
-	if (ccid->ccid_hc_tx_getsockopt != NULL)
-		rc = ccid->ccid_hc_tx_getsockopt(sk, optname, len,
+	if (ccid->ccid_ops->ccid_hc_tx_getsockopt != NULL)
+		rc = ccid->ccid_ops->ccid_hc_tx_getsockopt(sk, optname, len,
 						 optval, optlen);
 	return rc;
 }
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 6d4cb43..8f964dc 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -54,12 +54,12 @@ static const int ccid2_seq_len = 128;
 
 static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
 {
-	return dccp_sk(sk)->dccps_hc_tx_ccid_private;
+	return ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
 }
 
 static inline struct ccid2_hc_rx_sock *ccid2_hc_rx_sk(const struct sock *sk)
 {
-	return dccp_sk(sk)->dccps_hc_rx_ccid_private;
+	return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
 }
 
 #ifdef CCID2_DEBUG
@@ -707,19 +707,12 @@ static void ccid2_hc_tx_packet_recv(stru
 	ccid2_hc_tx_check_sanity(hctx);
 }
 
-static int ccid2_hc_tx_init(struct sock *sk)
+static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
-        struct ccid2_hc_tx_sock *hctx;
+        struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
 	int seqcount = ccid2_seq_len;
 	int i;
 
-        dp->dccps_hc_tx_ccid_private = kzalloc(sizeof(*hctx), gfp_any());
-        if (dp->dccps_hc_tx_ccid_private == NULL)
-                return -ENOMEM;
-
-        hctx = ccid2_hc_tx_sk(sk);
-
 	/* XXX init variables with proper values */
 	hctx->ccid2hctx_cwnd	  = 1;
 	hctx->ccid2hctx_ssthresh  = 10;
@@ -728,11 +721,9 @@ static int ccid2_hc_tx_init(struct sock 
 	/* XXX init ~ to window size... */
 	hctx->ccid2hctx_seqbuf = kmalloc(sizeof(*hctx->ccid2hctx_seqbuf) *
 					 seqcount, gfp_any());
-	if (hctx->ccid2hctx_seqbuf == NULL) {
-		kfree(dp->dccps_hc_tx_ccid_private);
-		dp->dccps_hc_tx_ccid_private = NULL;
+	if (hctx->ccid2hctx_seqbuf == NULL)
 		return -ENOMEM;
-	}
+
 	for (i = 0; i < (seqcount - 1); i++) {
 		hctx->ccid2hctx_seqbuf[i].ccid2s_next = 
 					&hctx->ccid2hctx_seqbuf[i + 1];
@@ -763,15 +754,11 @@ static int ccid2_hc_tx_init(struct sock 
 
 static void ccid2_hc_tx_exit(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
         struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
 	ccid2_hc_tx_kill_rto_timer(sk);
-
 	kfree(hctx->ccid2hctx_seqbuf);
-
-	kfree(dp->dccps_hc_tx_ccid_private);
-	dp->dccps_hc_tx_ccid_private = NULL;
+	hctx->ccid2hctx_seqbuf = NULL;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -791,33 +778,17 @@ static void ccid2_hc_rx_packet_recv(stru
 	}
 }
 
-static int ccid2_hc_rx_init(struct sock *sk)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-        dp->dccps_hc_rx_ccid_private = kzalloc(sizeof(struct ccid2_hc_rx_sock),
-					       gfp_any());
-        return dp->dccps_hc_rx_ccid_private == NULL ? -ENOMEM : 0;
-}
-
-static void ccid2_hc_rx_exit(struct sock *sk)
-{
-	struct dccp_sock *dp = dccp_sk(sk);
-
-	kfree(dp->dccps_hc_rx_ccid_private);
-	dp->dccps_hc_rx_ccid_private = NULL;
-}
-
-static struct ccid ccid2 = {
+static struct ccid_operations ccid2 = {
 	.ccid_id		= 2,
 	.ccid_name		= "ccid2",
 	.ccid_owner		= THIS_MODULE,
+	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
 	.ccid_hc_tx_init	= ccid2_hc_tx_init,
 	.ccid_hc_tx_exit	= ccid2_hc_tx_exit,
 	.ccid_hc_tx_send_packet	= ccid2_hc_tx_send_packet,
 	.ccid_hc_tx_packet_sent	= ccid2_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	= ccid2_hc_tx_packet_recv,
-	.ccid_hc_rx_init	= ccid2_hc_rx_init,
-	.ccid_hc_rx_exit	= ccid2_hc_rx_exit,
+	.ccid_hc_rx_obj_size	= sizeof(struct ccid2_hc_rx_sock),
 	.ccid_hc_rx_packet_recv	= ccid2_hc_rx_packet_recv,
 };
 
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 165fc40..a357c15 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -647,17 +647,10 @@ static int ccid3_hc_tx_parse_options(str
 	return rc;
 }
 
-static int ccid3_hc_tx_init(struct sock *sk)
+static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid3_hc_tx_sock *hctx;
-
-	dp->dccps_hc_tx_ccid_private = kmalloc(sizeof(*hctx), gfp_any());
-	if (dp->dccps_hc_tx_ccid_private == NULL)
-		return -ENOMEM;
-
-	hctx = ccid3_hc_tx_sk(sk);
-	memset(hctx, 0, sizeof(*hctx));
+	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
 
 	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
 	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
@@ -680,7 +673,6 @@ static int ccid3_hc_tx_init(struct sock 
 
 static void ccid3_hc_tx_exit(struct sock *sk)
 {
-	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
 	BUG_ON(hctx == NULL);
@@ -690,9 +682,6 @@ static void ccid3_hc_tx_exit(struct sock
 
 	/* Empty packet history */
 	dccp_tx_hist_purge(ccid3_tx_hist, &hctx->ccid3hctx_hist);
-
-	kfree(dp->dccps_hc_tx_ccid_private);
-	dp->dccps_hc_tx_ccid_private = NULL;
 }
 
 /*
@@ -1035,20 +1024,13 @@ static void ccid3_hc_rx_packet_recv(stru
 	}
 }
 
-static int ccid3_hc_rx_init(struct sock *sk)
+static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid3_hc_rx_sock *hcrx;
+	struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);
 
 	ccid3_pr_debug("%s, sk=%p\n", dccp_role(sk), sk);
 
-	dp->dccps_hc_rx_ccid_private = kmalloc(sizeof(*hcrx), gfp_any());
-	if (dp->dccps_hc_rx_ccid_private == NULL)
-		return -ENOMEM;
-
-	hcrx = ccid3_hc_rx_sk(sk);
-	memset(hcrx, 0, sizeof(*hcrx));
-
 	if (dp->dccps_packet_size >= TFRC_MIN_PACKET_SIZE &&
 	    dp->dccps_packet_size <= TFRC_MAX_PACKET_SIZE)
 		hcrx->ccid3hcrx_s = dp->dccps_packet_size;
@@ -1067,7 +1049,6 @@ static int ccid3_hc_rx_init(struct sock 
 static void ccid3_hc_rx_exit(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_sock *dp = dccp_sk(sk);
 
 	BUG_ON(hcrx == NULL);
 
@@ -1078,9 +1059,6 @@ static void ccid3_hc_rx_exit(struct sock
 
 	/* Empty loss interval history */
 	dccp_li_hist_purge(ccid3_li_hist, &hcrx->ccid3hcrx_li_hist);
-
-	kfree(dp->dccps_hc_rx_ccid_private);
-	dp->dccps_hc_rx_ccid_private = NULL;
 }
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
@@ -1166,10 +1144,11 @@ static int ccid3_hc_tx_getsockopt(struct
 	return 0;
 }
 
-static struct ccid ccid3 = {
+static struct ccid_operations ccid3 = {
 	.ccid_id		   = 3,
 	.ccid_name		   = "ccid3",
 	.ccid_owner		   = THIS_MODULE,
+	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
 	.ccid_hc_tx_exit	   = ccid3_hc_tx_exit,
 	.ccid_hc_tx_send_packet	   = ccid3_hc_tx_send_packet,
@@ -1177,6 +1156,7 @@ static struct ccid ccid3 = {
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
 	.ccid_hc_tx_insert_options = ccid3_hc_tx_insert_options,
 	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
+	.ccid_hc_rx_obj_size	   = sizeof(struct ccid3_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid3_hc_rx_exit,
 	.ccid_hc_rx_insert_options = ccid3_hc_rx_insert_options,
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 0bde458..f1db3d6 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -135,12 +135,12 @@ struct ccid3_hc_rx_sock {
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
 {
-    return dccp_sk(sk)->dccps_hc_tx_ccid_private;
+    return ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
 }
 
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
 {
-    return dccp_sk(sk)->dccps_hc_rx_ccid_private;
+    return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
 }
 
 #endif /* _DCCP_CCID3_H_ */
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 4b6d43d..67691a0 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -324,14 +324,6 @@ static int dccp_rcv_request_sent_state_p
 		dccp_set_seqno(&dp->dccps_swl,
 			       max48(dp->dccps_swl, dp->dccps_isr));
 
-		if (ccid_hc_rx_init(dp->dccps_hc_rx_ccid, sk) != 0 ||
-		    ccid_hc_tx_init(dp->dccps_hc_tx_ccid, sk) != 0) {
-			ccid_hc_rx_exit(dp->dccps_hc_rx_ccid, sk);
-			ccid_hc_tx_exit(dp->dccps_hc_tx_ccid, sk);
-			/* FIXME: send appropriate RESET code */
-			goto out_invalid_packet;
-		}
-
 		dccp_sync_mss(sk, icsk->icsk_pmtu_cookie);
 
 		/*
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 14adcf9..266b6b2 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -1058,14 +1058,16 @@ int dccp_v4_init_sock(struct sock *sk)
 			if (dp->dccps_hc_rx_ackvec == NULL)
 				return -ENOMEM;
 		}
-		dp->dccps_hc_rx_ccid = ccid_init(dp->dccps_options.dccpo_rx_ccid,
-						 sk);
-		dp->dccps_hc_tx_ccid = ccid_init(dp->dccps_options.dccpo_tx_ccid,
-						 sk);
-	    	if (dp->dccps_hc_rx_ccid == NULL ||
-		    dp->dccps_hc_tx_ccid == NULL) {
-			ccid_exit(dp->dccps_hc_rx_ccid, sk);
-			ccid_exit(dp->dccps_hc_tx_ccid, sk);
+		dp->dccps_hc_rx_ccid =
+				ccid_hc_rx_new(dp->dccps_options.dccpo_rx_ccid,
+					       sk, GFP_KERNEL);
+		dp->dccps_hc_tx_ccid =
+				ccid_hc_tx_new(dp->dccps_options.dccpo_tx_ccid,
+					       sk, GFP_KERNEL);
+	    	if (unlikely(dp->dccps_hc_rx_ccid == NULL ||
+			     dp->dccps_hc_tx_ccid == NULL)) {
+			ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+			ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
 			if (dp->dccps_options.dccpo_send_ack_vector) {
 				dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 				dp->dccps_hc_rx_ackvec = NULL;
@@ -1120,14 +1122,12 @@ int dccp_v4_destroy_sock(struct sock *sk
 	kfree(dp->dccps_service_list);
 	dp->dccps_service_list = NULL;
 
-	ccid_hc_rx_exit(dp->dccps_hc_rx_ccid, sk);
-	ccid_hc_tx_exit(dp->dccps_hc_tx_ccid, sk);
 	if (dp->dccps_options.dccpo_send_ack_vector) {
 		dccp_ackvec_free(dp->dccps_hc_rx_ackvec);
 		dp->dccps_hc_rx_ackvec = NULL;
 	}
-	ccid_exit(dp->dccps_hc_rx_ccid, sk);
-	ccid_exit(dp->dccps_hc_tx_ccid, sk);
+	ccid_hc_rx_delete(dp->dccps_hc_rx_ccid, sk);
+	ccid_hc_tx_delete(dp->dccps_hc_tx_ccid, sk);
 	dp->dccps_hc_rx_ccid = dp->dccps_hc_tx_ccid = NULL;
 
 	/* clean up feature negotiation state */
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 9e1de59..ded63d1 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -131,13 +131,17 @@ struct sock *dccp_create_openreq_child(s
 				goto out_free;
 		}
 
-		if (unlikely(ccid_hc_rx_init(newdp->dccps_hc_rx_ccid,
-					     newsk) != 0 ||
-			     ccid_hc_tx_init(newdp->dccps_hc_tx_ccid,
-				     	     newsk) != 0)) {
+		newdp->dccps_hc_rx_ccid =
+			    ccid_hc_rx_new(newdp->dccps_options.dccpo_rx_ccid,
+					   newsk, GFP_ATOMIC);
+		newdp->dccps_hc_tx_ccid =
+			    ccid_hc_tx_new(newdp->dccps_options.dccpo_tx_ccid,
+					   newsk, GFP_ATOMIC);
+		if (unlikely(newdp->dccps_hc_rx_ccid == NULL ||
+			     newdp->dccps_hc_tx_ccid == NULL)) {
 			dccp_ackvec_free(newdp->dccps_hc_rx_ackvec);
-			ccid_hc_rx_exit(newdp->dccps_hc_rx_ccid, newsk);
-			ccid_hc_tx_exit(newdp->dccps_hc_tx_ccid, newsk);
+			ccid_hc_rx_delete(newdp->dccps_hc_rx_ccid, newsk);
+			ccid_hc_tx_delete(newdp->dccps_hc_tx_ccid, newsk);
 out_free:
 			/* It is still raw copy of parent, so invalidate
 			 * destructor and make plain sk_free() */

------=_Part_9900_19507798.1140027765246--
