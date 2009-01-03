From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Jan 2009 07:30:47 +0000
Subject: [PATCH 1/3] dccp: Lockless integration of CCID congestion-control plugins
Message-Id: <1230967849-9456-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Based on Arnaldo's earlier patch, this patch integrates the standardised
CCID congestion control plugins (CCID-2 and CCID-3) of DCCP with dccp.ko:

 * enables a faster connection path by eliminating the need to always go 
   through the CCID registration lock;

 * updates the implementation to use only a single array whose size equals
   the number of configured CCIDs instead of the maximum (256);

 * since the CCIDs are now fixed array elements, synchronization is no
   longer needed, simplifying use and implementation.

CCID-2 is suggested as minimum for a basic DCCP implementation (RFC 4340, 10);
CCID-3 is a standards-track CCID supported by RFC 4342 and RFC 5348.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/Kconfig        |    4 -
 net/dccp/Makefile       |    9 ++
 net/dccp/ackvec.h       |    4 -
 net/dccp/ccid.c         |  156 ++++++++++++++++++++++++++++++------------------
 net/dccp/ccid.h         |   11 ++-
 net/dccp/ccids/Kconfig  |   70 ++++++---------------
 net/dccp/ccids/Makefile |    8 --
 net/dccp/ccids/ccid2.c  |   22 ------
 net/dccp/ccids/ccid3.c  |   23 -------
 net/dccp/dccp.h         |    2 
 net/dccp/proto.c        |    7 ++
 11 files changed, 148 insertions(+), 168 deletions(-)

--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -1,80 +1,52 @@
 menu "DCCP CCIDs Configuration (EXPERIMENTAL)"
 	depends on EXPERIMENTAL
 
-config IP_DCCP_CCID2
-	tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
-	def_tristate IP_DCCP
-	select IP_DCCP_ACKVEC
-	---help---
-	  CCID 2, TCP-like Congestion Control, denotes Additive Increase,
-	  Multiplicative Decrease (AIMD) congestion control with behavior
-	  modelled directly on TCP, including congestion window, slow start,
-	  timeouts, and so forth [RFC 2581].  CCID 2 achieves maximum
-	  bandwidth over the long term, consistent with the use of end-to-end
-	  congestion control, but halves its congestion window in response to
-	  each congestion event.  This leads to the abrupt rate changes
-	  typical of TCP.  Applications should use CCID 2 if they prefer
-	  maximum bandwidth utilization to steadiness of rate.  This is often
-	  the case for applications that are not playing their data directly
-	  to the user.  For example, a hypothetical application that
-	  transferred files over DCCP, using application-level retransmissions
-	  for lost packets, would prefer CCID 2 to CCID 3.  On-line games may
-	  also prefer CCID 2.  See RFC 4341 for further details.
-
-	  CCID2 is the default CCID used by DCCP.
-
 config IP_DCCP_CCID2_DEBUG
-	  bool "CCID2 debugging messages"
-	  depends on IP_DCCP_CCID2
-	  ---help---
-	    Enable CCID2-specific debugging messages.
+	bool "CCID-2 debugging messages"
+	---help---
+	  Enable CCID-2 specific debugging messages.
 
-	    When compiling CCID2 as a module, this debugging output can
-	    additionally be toggled by setting the ccid2_debug module
-	    parameter to 0 or 1.
+	  The debugging output can additionally be toggled by setting the
+	  ccid2_debug parameter to 0 or 1.
 
-	    If in doubt, say N.
+	  If in doubt, say N.
 
 config IP_DCCP_CCID3
-	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
-	def_tristate IP_DCCP
+	bool "CCID-3 (TCP-Friendly) (EXPERIMENTAL)"
+	def_bool y if (IP_DCCP = y || IP_DCCP = m)
 	select IP_DCCP_TFRC_LIB
 	---help---
-	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
+	  CCID-3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
 	  rate-controlled congestion control mechanism.  TFRC is designed to
 	  be reasonably fair when competing for bandwidth with TCP-like flows,
 	  where a flow is "reasonably fair" if its sending rate is generally
 	  within a factor of two of the sending rate of a TCP flow under the
 	  same conditions.  However, TFRC has a much lower variation of
-	  throughput over time compared with TCP, which makes CCID 3 more
-	  suitable than CCID 2 for applications such streaming media where a
+	  throughput over time compared with TCP, which makes CCID-3 more
+	  suitable than CCID-2 for applications such streaming media where a
 	  relatively smooth sending rate is of importance.
 
-	  CCID 3 is further described in RFC 4342,
+	  CCID-3 is further described in RFC 4342,
 	  http://www.ietf.org/rfc/rfc4342.txt
 
 	  The TFRC congestion control algorithms were initially described in
-	  RFC 3448.
+	  RFC 5448.
 
 	  This text was extracted from RFC 4340 (sec. 10.2),
 	  http://www.ietf.org/rfc/rfc4340.txt
-	  
-	  To compile this CCID as a module, choose M here: the module will be
-	  called dccp_ccid3.
 
-	  If in doubt, say M.
+	  If in doubt, say N.
 
 config IP_DCCP_CCID3_DEBUG
-	  bool "CCID3 debugging messages"
-	  depends on IP_DCCP_CCID3
-	  ---help---
-	    Enable CCID3-specific debugging messages.
+	bool "CCID-3 debugging messages"
+	depends on IP_DCCP_CCID3
+	---help---
+	  Enable CCID-3 specific debugging messages.
 
-	    When compiling CCID3 as a module, this debugging output can
-	    additionally be toggled by setting the ccid3_debug module
-	    parameter to 0 or 1.
+	  The debugging output can additionally be toggled by setting the
+	  ccid3_debug parameter to 0 or 1.
 
-	    If in doubt, say N.
+	  If in doubt, say N.
 
 config IP_DCCP_CCID3_RTO
 	  int "Use higher bound for nofeedback timer"
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -1,7 +1,6 @@
 menuconfig IP_DCCP
 	tristate "The DCCP Protocol (EXPERIMENTAL)"
 	depends on INET && EXPERIMENTAL
-	select IP_DCCP_CCID2
 	---help---
 	  Datagram Congestion Control Protocol (RFC 4340)
 
@@ -25,9 +24,6 @@ config INET_DCCP_DIAG
 	def_tristate y if (IP_DCCP = y && INET_DIAG = y)
 	def_tristate m
 
-config IP_DCCP_ACKVEC
-	bool
-
 source "net/dccp/ccids/Kconfig"
 
 menu "DCCP Kernel Hacking"
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -2,14 +2,19 @@ obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv
 
 dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
 
+#
+# CCID algorithms to be used by dccp.ko
+#
+# CCID-2 is default (RFC 4340, p. 77) and has Ack Vectors as dependency
+dccp-y += ccids/ccid2.o ackvec.o
+dccp-$(CONFIG_IP_DCCP_CCID3)	+= ccids/ccid3.o
+
 dccp_ipv4-y := ipv4.o
 
 # build dccp_ipv6 as module whenever either IPv6 or DCCP is a module
 obj-$(subst y,$(CONFIG_IP_DCCP),$(CONFIG_IPV6)) += dccp_ipv6.o
 dccp_ipv6-y := ipv6.o
 
-dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
-
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
--- a/net/dccp/ccids/Makefile
+++ b/net/dccp/ccids/Makefile
@@ -1,9 +1 @@
-obj-$(CONFIG_IP_DCCP_CCID3) += dccp_ccid3.o
-
-dccp_ccid3-y := ccid3.o
-
-obj-$(CONFIG_IP_DCCP_CCID2) += dccp_ccid2.o
-
-dccp_ccid2-y := ccid2.o
-
 obj-y += lib/
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -29,7 +29,6 @@ struct tcp_info;
  *  @ccid_id: numerical CCID ID (up to %CCID_MAX, cf. table 5 in RFC 4340, 10.)
  *  @ccid_ccmps: the CCMPS including network/transport headers (0 when disabled)
  *  @ccid_name: alphabetical identifier string for @ccid_id
- *  @ccid_owner: module which implements/owns this CCID
  *  @ccid_hc_{r,t}x_slab: memory pool for the receiver/sender half-connection
  *  @ccid_hc_{r,t}x_obj_size: size of the receiver/sender half-connection socket
  *
@@ -48,7 +47,6 @@ struct ccid_operations {
 	unsigned char		ccid_id;
 	__u32			ccid_ccmps;
 	const char		*ccid_name;
-	struct module		*ccid_owner;
 	struct kmem_cache	*ccid_hc_rx_slab,
 				*ccid_hc_tx_slab;
 	__u32			ccid_hc_rx_obj_size,
@@ -90,8 +88,13 @@ struct ccid_operations {
 						 int __user *optlen);
 };
 
-extern int ccid_register(struct ccid_operations *ccid_ops);
-extern int ccid_unregister(struct ccid_operations *ccid_ops);
+extern struct ccid_operations ccid2_ops;
+#ifdef CONFIG_IP_DCCP_CCID3
+extern struct ccid_operations ccid3_ops;
+#endif
+
+extern int  ccid_initialize_builtins(void);
+extern void ccid_cleanup_builtins(void);
 
 struct ccid {
 	struct ccid_operations *ccid_ops;
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -13,6 +13,70 @@
 
 #include "ccid.h"
 
+static struct ccid_operations *ccids[] = {
+	&ccid2_ops,
+#ifdef CONFIG_IP_DCCP_CCID3
+	&ccid3_ops,
+#endif
+};
+
+static struct ccid_operations *ccid_by_number(const u8 id)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ccids); i++)
+		if (ccids[i]->ccid_id = id)
+			return ccids[i];
+	return NULL;
+}
+
+/* check that up to @array_len members in @ccid_array are supported */
+bool ccid_support_check(u8 const *ccid_array, u8 array_len)
+{
+	while (array_len > 0)
+		if (ccid_by_number(ccid_array[--array_len]) = NULL)
+			return false;
+	return true;
+}
+
+/**
+ * ccid_get_builtin_ccids  -  Populate a list of built-in CCIDs
+ * @ccid_array: pointer to copy into
+ * @array_len: value to return length into
+ * This function allocates memory - caller must see that it is freed after use.
+ */
+int ccid_get_builtin_ccids(u8 **ccid_array, u8 *array_len)
+{
+	*ccid_array = kmalloc(ARRAY_SIZE(ccids), gfp_any());
+	if (*ccid_array = NULL)
+		return -ENOBUFS;
+
+	for (*array_len = 0; *array_len < ARRAY_SIZE(ccids); *array_len += 1)
+		(*ccid_array)[*array_len] = ccids[*array_len]->ccid_id;
+	return 0;
+}
+
+int ccid_getsockopt_builtin_ccids(struct sock *sk, int len,
+				  char __user *optval, int __user *optlen)
+{
+	u8 *ccid_array, array_len;
+	int err = 0;
+
+	if (len < ARRAY_SIZE(ccids))
+		return -EINVAL;
+
+	if (ccid_get_builtin_ccids(&ccid_array, &array_len))
+		return -ENOBUFS;
+
+	if (put_user(array_len, optlen) ||
+	    copy_to_user(optval, ccid_array, array_len))
+		err = -EFAULT;
+
+	kfree(ccid_array);
+	return err;
+}
+
+#ifdef ___OLD_INTERFACE_TO_BE_REMOVED___
 static u8 builtin_ccids[] = {
 	DCCPC_CCID2,		/* CCID2 is supported by default */
 #if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
@@ -62,6 +126,7 @@ static inline void ccids_read_unlock(voi
 #define ccids_read_lock() do { } while(0)
 #define ccids_read_unlock() do { } while(0)
 #endif
+#endif /* ___OLD_INTERFACE_TO_BE_REMOVED___ */
 
 static struct kmem_cache *ccid_kmem_cache_create(int obj_size, const char *fmt,...)
 {
@@ -93,6 +158,7 @@ static void ccid_kmem_cache_destroy(stru
 	}
 }
 
+#ifdef ___OLD_INTERFACE_TO_BE_REMOVED___
 /* check that up to @array_len members in @ccid_array are supported */
 bool ccid_support_check(u8 const *ccid_array, u8 array_len)
 {
@@ -133,8 +199,9 @@ int ccid_getsockopt_builtin_ccids(struct
 		return -EFAULT;
 	return 0;
 }
+#endif /* ___OLD_INTERFACE_TO_BE_REMOVED___ */
 
-int ccid_register(struct ccid_operations *ccid_ops)
+static int ccid_activate(struct ccid_operations *ccid_ops)
 {
 	int err = -ENOBUFS;
 
@@ -152,79 +219,40 @@ int ccid_register(struct ccid_operations
 	if (ccid_ops->ccid_hc_tx_slab = NULL)
 		goto out_free_rx_slab;
 
-	ccids_write_lock();
-	err = -EEXIST;
-	if (ccids[ccid_ops->ccid_id] = NULL) {
-		ccids[ccid_ops->ccid_id] = ccid_ops;
-		err = 0;
-	}
-	ccids_write_unlock();
-	if (err != 0)
-		goto out_free_tx_slab;
-
-	pr_info("CCID: Registered CCID %d (%s)\n",
+	pr_info("CCID: Activated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
+	err = 0;
 out:
 	return err;
-out_free_tx_slab:
-	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
-	ccid_ops->ccid_hc_tx_slab = NULL;
-	goto out;
 out_free_rx_slab:
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
 	ccid_ops->ccid_hc_rx_slab = NULL;
 	goto out;
 }
 
-EXPORT_SYMBOL_GPL(ccid_register);
-
-int ccid_unregister(struct ccid_operations *ccid_ops)
+static void ccid_deactivate(struct ccid_operations *ccid_ops)
 {
-	ccids_write_lock();
-	ccids[ccid_ops->ccid_id] = NULL;
-	ccids_write_unlock();
-
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_tx_slab);
 	ccid_ops->ccid_hc_tx_slab = NULL;
 	ccid_kmem_cache_destroy(ccid_ops->ccid_hc_rx_slab);
 	ccid_ops->ccid_hc_rx_slab = NULL;
 
-	pr_info("CCID: Unregistered CCID %d (%s)\n",
+	pr_info("CCID: Deactivated CCID %d (%s)\n",
 		ccid_ops->ccid_id, ccid_ops->ccid_name);
-	return 0;
 }
 
-EXPORT_SYMBOL_GPL(ccid_unregister);
-
 struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
 {
-	struct ccid_operations *ccid_ops;
+	struct ccid_operations *ccid_ops = ccid_by_number(id);
 	struct ccid *ccid = NULL;
 
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
 	if (ccid_ops = NULL)
-		goto out_unlock;
-
-	if (!try_module_get(ccid_ops->ccid_owner))
-		goto out_unlock;
-
-	ccids_read_unlock();
+		goto out;
 
 	ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
 				     ccid_ops->ccid_hc_tx_slab, gfp);
 	if (ccid = NULL)
-		goto out_module_put;
+		goto out;
 	ccid->ccid_ops = ccid_ops;
 	if (rx) {
 		memset(ccid + 1, 0, ccid_ops->ccid_hc_rx_obj_size);
@@ -239,15 +267,10 @@ struct ccid *ccid_new(unsigned char id, 
 	}
 out:
 	return ccid;
-out_unlock:
-	ccids_read_unlock();
-	goto out;
 out_free_ccid:
 	kmem_cache_free(rx ? ccid_ops->ccid_hc_rx_slab :
 			ccid_ops->ccid_hc_tx_slab, ccid);
 	ccid = NULL;
-out_module_put:
-	module_put(ccid_ops->ccid_owner);
 	goto out;
 }
 
@@ -270,10 +293,6 @@ static void ccid_delete(struct ccid *cci
 			ccid_ops->ccid_hc_tx_exit(sk);
 		kmem_cache_free(ccid_ops->ccid_hc_tx_slab,  ccid);
 	}
-	ccids_read_lock();
-	if (ccids[ccid_ops->ccid_id] != NULL)
-		module_put(ccid_ops->ccid_owner);
-	ccids_read_unlock();
 }
 
 void ccid_hc_rx_delete(struct ccid *ccid, struct sock *sk)
@@ -289,3 +308,28 @@ void ccid_hc_tx_delete(struct ccid *ccid
 }
 
 EXPORT_SYMBOL_GPL(ccid_hc_tx_delete);
+
+int __init ccid_initialize_builtins(void)
+{
+	int i, err;
+
+	for (i = 0; i < ARRAY_SIZE(ccids); i++) {
+		err = ccid_activate(ccids[i]);
+		if (err)
+			goto unwind_registrations;
+	}
+	return 0;
+
+unwind_registrations:
+	while(--i >= 0)
+		ccid_deactivate(ccids[i]);
+	return err;
+}
+
+void ccid_cleanup_builtins(void)
+{
+	int i;
+
+	for (i = 0; i < ARRAY_SIZE(ccids); i++)
+		ccid_deactivate(ccids[i]);
+}
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1118,9 +1118,15 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out_ackvec_exit;
 
+	rc = ccid_initialize_builtins();
+	if (rc)
+		goto out_sysctl_exit;
+
 	dccp_timestamping_init();
 out:
 	return rc;
+out_sysctl_exit:
+	dccp_sysctl_exit();
 out_ackvec_exit:
 	dccp_ackvec_exit();
 out_free_dccp_mib:
@@ -1143,6 +1149,7 @@ out_free_percpu:
 
 static void __exit dccp_fini(void)
 {
+	ccid_cleanup_builtins();
 	dccp_mib_exit();
 	free_pages((unsigned long)dccp_hashinfo.bhash,
 		   get_order(dccp_hashinfo.bhash_size *
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -940,10 +940,9 @@ static int ccid3_hc_rx_getsockopt(struct
 	return 0;
 }
 
-static struct ccid_operations ccid3 = {
+struct ccid_operations ccid3_ops = {
 	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "TCP-Friendly Rate Control",
-	.ccid_owner		   = THIS_MODULE,
 	.ccid_hc_tx_obj_size	   = sizeof(struct ccid3_hc_tx_sock),
 	.ccid_hc_tx_init	   = ccid3_hc_tx_init,
 	.ccid_hc_tx_exit	   = ccid3_hc_tx_exit,
@@ -964,23 +963,5 @@ static struct ccid_operations ccid3 = {
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 module_param(ccid3_debug, bool, 0644);
-MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
+MODULE_PARM_DESC(ccid3_debug, "Enable CCID-3 debug messages");
 #endif
-
-static __init int ccid3_module_init(void)
-{
-	return ccid_register(&ccid3);
-}
-module_init(ccid3_module_init);
-
-static __exit void ccid3_module_exit(void)
-{
-	ccid_unregister(&ccid3);
-}
-module_exit(ccid3_module_exit);
-
-MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
-	      "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
-MODULE_DESCRIPTION("DCCP TFRC CCID3 CCID");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("net-dccp-ccid-3");
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -768,10 +768,9 @@ static void ccid2_hc_rx_packet_recv(stru
 	}
 }
 
-static struct ccid_operations ccid2 = {
+struct ccid_operations ccid2_ops = {
 	.ccid_id		= DCCPC_CCID2,
 	.ccid_name		= "TCP-like",
-	.ccid_owner		= THIS_MODULE,
 	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
 	.ccid_hc_tx_init	= ccid2_hc_tx_init,
 	.ccid_hc_tx_exit	= ccid2_hc_tx_exit,
@@ -784,22 +783,5 @@ static struct ccid_operations ccid2 = {
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 module_param(ccid2_debug, bool, 0644);
-MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
+MODULE_PARM_DESC(ccid2_debug, "Enable CCID-2 debug messages");
 #endif
-
-static __init int ccid2_module_init(void)
-{
-	return ccid_register(&ccid2);
-}
-module_init(ccid2_module_init);
-
-static __exit void ccid2_module_exit(void)
-{
-	ccid_unregister(&ccid2);
-}
-module_exit(ccid2_module_exit);
-
-MODULE_AUTHOR("Andrea Bittau <a.bittau@cs.ucl.ac.uk>");
-MODULE_DESCRIPTION("DCCP TCP-Like (CCID2) CCID");
-MODULE_LICENSE("GPL");
-MODULE_ALIAS("net-dccp-ccid-2");
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -432,10 +432,8 @@ static inline int dccp_ack_pending(const
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
 	return dp->dccps_timestamp_echo != 0 ||
-#ifdef CONFIG_IP_DCCP_ACKVEC
 	       (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
-#endif
 	       inet_csk_ack_scheduled(sk);
 }
 
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -84,7 +84,7 @@ struct dccp_ackvec_record {
 struct sock;
 struct sk_buff;
 
-#ifdef CONFIG_IP_DCCP_ACKVEC
+#ifndef ___OLD_INTERFACE_TO_BE_REMOVED___
 extern int dccp_ackvec_init(void);
 extern void dccp_ackvec_exit(void);
 
@@ -106,7 +106,7 @@ static inline int dccp_ackvec_pending(co
 {
 	return av->av_vec_len;
 }
-#else /* CONFIG_IP_DCCP_ACKVEC */
+#else /* ___OLD_INTERFACE_TO_BE_REMOVED___ */
 static inline int dccp_ackvec_init(void)
 {
 	return 0;
