From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 17 Dec 2008 21:46:08 +0000
Subject: [RFCv2][PATCH] static builtin CCIDs was  Re: [PATCH 2/5] dccp:
Message-Id: <20081217214608.GC14518@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Sorry if it gets duplicated, I'm having some mail problems :-\

Em Wed, Dec 17, 2008 at 04:42:28PM -0200, Arnaldo Carvalho de Melo escreveu:
> Em Wed, Dec 17, 2008 at 04:30:41PM -0200, Arnaldo Carvalho de Melo escreveu:
> > Em Wed, Dec 17, 2008 at 04:20:38PM -0200, Arnaldo Carvalho de Melo escreveu:
> > > > IOW we're back to my suggestion on looking at
> > > > tcp_set_congestion_control(). :-)
> > > 
> > > I tried to test this using ttcp over loopback but the tree seems broken
> > > somehow, with or without this patch I'm getting:
> > > 
> > > Could not activate 0 at /home/acme/git/net-next-2.6/net/dccp/feat.c:1176
> > > 
> > > I tried doing a quick chase on this one but failed miserably, Gerrit,
> > > any ideas?
> > 
> > Well, without the patch the problem was that dccp_ccid2 was not being
> > autoloaded, as soon as I manually loaded it, ttcp worked. Now to see
> > why...
> 
> Autoloading mess indeed... what probably is happening is that I start
> the server, that will not try to load the modules it advertises right
> away, but instead wait to do that when the connection completes, but
> then...
> 
> OK, back to my patch to check why it finds ccids[2] as NULL when it
> shouldn't...

Ok, now it survives basic testing, i.e.:

[root@mica ~]# ~acme/ttcp -l256 -cacme -t localhost
ttcp-t: buflen%6, nbuf 48, align384/+0, portP01  dccp(inet)  ->
localhost
ttcp-t: socket
ttcp-r: accept from mica.ghostprotocols.net
ttcp-t: connect
ttcp-t: 524288 bytes in 0.02 real seconds = 23517.52 KB/sec +++
ttcp-t: 2048 I/O calls, msec/call = 0.01, calls/sec = 94070.09
ttcp-t: 0.0user 0.0sys 0:00real 50% 0i+0d 0maxrss 0+1pf 0+2048csw
ttcp-r: 524288 bytes in 0.02 real seconds = 23164.28 KB/sec +++
ttcp-r: 2049 I/O calls, msec/call = 0.01, calls/sec = 92702.35
ttcp-r: 0.0user 0.0sys 0:00real 0% 0i+0d 0maxrss 0+1pf 2049+0csw
[1]+  Done                    ~acme/ttcp -l256 -cacme -r
[root@mica ~]# 

The problem was that I was not selecting IP_DCCP_ACKVEC, that is needed
by CCID2, with that CCID2 always loads, this option makes no sense and
is thus removed.

So, if nobody sees any problem, please apply.

Build CCID2, because the RFC requires it to be always available, and
CCID3 too as it is the most interesting one for VoIP, etc, together with
the main, layer 3 agnostic, DCCP core code, so that we have a faster
connection path by eliminating the need to always go thru the CCID
registration lock. But keep it there, so that we can experiment with
newer CCIDs without having to rebuild/reboot the whole kernel.

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 7aa2a7a..ad6dffd 100644
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
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index f4f8793..ac6ede3 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -1,6 +1,9 @@
 obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
-dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
+dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o \
+	  ackvec.o ccids/ccid2.o
+
+dccp-$(CONFIG_IP_DCCP_CCID3) += ccids/ccid3.o
 
 dccp_ipv4-y := ipv4.o
 
@@ -8,8 +11,6 @@ dccp_ipv4-y := ipv4.o
 obj-$(subst y,$(CONFIG_IP_DCCP),$(CONFIG_IPV6)) += dccp_ipv6.o
 dccp_ipv6-y := ipv6.o
 
-dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
-
 obj-$(CONFIG_INET_DCCP_DIAG) += dccp_diag.o
 obj-$(CONFIG_NET_DCCPPROBE) += dccp_probe.o
 
diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
index 4ccee03..45f95e5 100644
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -84,7 +84,6 @@ struct dccp_ackvec_record {
 struct sock;
 struct sk_buff;
 
-#ifdef CONFIG_IP_DCCP_ACKVEC
 extern int dccp_ackvec_init(void);
 extern void dccp_ackvec_exit(void);
 
@@ -106,52 +105,4 @@ static inline int dccp_ackvec_pending(const struct dccp_ackvec *av)
 {
 	return av->av_vec_len;
 }
-#else /* CONFIG_IP_DCCP_ACKVEC */
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
diff --git a/net/dccp/ccid.c b/net/dccp/ccid.c
index bcc643f..87991ec 100644
--- a/net/dccp/ccid.c
+++ b/net/dccp/ccid.c
@@ -13,9 +13,21 @@
 
 #include "ccid.h"
 
+extern struct ccid_operations ccid2_ops;
+#ifdef CONFIG_IP_DCCP_CCID3
+extern struct ccid_operations ccid3_ops;
+#endif
+
+static struct ccid_operations *builtin_ccids_ops[] = {
+	&ccid2_ops,		/* CCID2 is supported by default */
+#ifdef CONFIG_IP_DCCP_CCID3
+	&ccid3_ops,
+#endif
+};
+
 static u8 builtin_ccids[] = {
 	DCCPC_CCID2,		/* CCID2 is supported by default */
-#if defined(CONFIG_IP_DCCP_CCID3) || defined(CONFIG_IP_DCCP_CCID3_MODULE)
+#ifdef CONFIG_IP_DCCP_CCID3
 	DCCPC_CCID3,
 #endif
 };
@@ -196,11 +208,71 @@ int ccid_unregister(struct ccid_operations *ccid_ops)
 
 EXPORT_SYMBOL_GPL(ccid_unregister);
 
+int ccids_register_builtins(void)
+{
+	int i, err;
+
+	for (i = 0; i < ARRAY_SIZE(builtin_ccids_ops); i++) {
+		err = ccid_register(builtin_ccids_ops[i]);
+		if (err)
+			goto unwind_registrations;
+	}
+		
+	return 0;
+
+unwind_registrations:
+	while(--i >= 0)
+		ccid_unregister(builtin_ccids_ops[i]);
+	return err;
+}
+
+static struct ccid *__ccid_new(struct ccid_operations *ccid_ops, struct sock *sk,
+			       int rx, gfp_t gfp)
+{
+	struct ccid *ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
+						  ccid_ops->ccid_hc_tx_slab, gfp);
+	if (ccid = NULL)
+		return NULL;
+
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
+	return ccid;
+out_free_ccid:
+	kmem_cache_free(rx ? ccid_ops->ccid_hc_rx_slab :
+			     ccid_ops->ccid_hc_tx_slab, ccid);
+	return NULL;
+}
+
+static bool is_builtin_ccid(unsigned char id)
+{
+	int i;
+	for (i = 0; i < ARRAY_SIZE(builtin_ccids); i++)
+		if (id = builtin_ccids[i])
+			return true;
+	return false;
+}
+
 struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
 {
 	struct ccid_operations *ccid_ops;
 	struct ccid *ccid = NULL;
 
+	if (is_builtin_ccid(id)) {
+		ccid_ops = ccids[id];
+		BUG_ON(ccid_ops = NULL);
+		return __ccid_new(ccid_ops, sk, rx, gfp);
+	}
+
 	ccids_read_lock();
 #ifdef CONFIG_MODULES
 	if (ccids[id] = NULL) {
@@ -221,31 +293,14 @@ struct ccid *ccid_new(unsigned char id, struct sock *sk, int rx, gfp_t gfp)
 
 	ccids_read_unlock();
 
-	ccid = kmem_cache_alloc(rx ? ccid_ops->ccid_hc_rx_slab :
-				     ccid_ops->ccid_hc_tx_slab, gfp);
+	ccid = __ccid_new(ccid_ops, sk, rx, gfp);
 	if (ccid = NULL)
 		goto out_module_put;
-	ccid->ccid_ops = ccid_ops;
-	if (rx) {
-		memset(ccid + 1, 0, ccid_ops->ccid_hc_rx_obj_size);
-		if (ccid->ccid_ops->ccid_hc_rx_init != NULL &&
-		    ccid->ccid_ops->ccid_hc_rx_init(ccid, sk) != 0)
-			goto out_free_ccid;
-	} else {
-		memset(ccid + 1, 0, ccid_ops->ccid_hc_tx_obj_size);
-		if (ccid->ccid_ops->ccid_hc_tx_init != NULL &&
-		    ccid->ccid_ops->ccid_hc_tx_init(ccid, sk) != 0)
-			goto out_free_ccid;
-	}
 out:
 	return ccid;
 out_unlock:
 	ccids_read_unlock();
 	goto out;
-out_free_ccid:
-	kmem_cache_free(rx ? ccid_ops->ccid_hc_rx_slab :
-			ccid_ops->ccid_hc_tx_slab, ccid);
-	ccid = NULL;
 out_module_put:
 	module_put(ccid_ops->ccid_owner);
 	goto out;
diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index 18f6942..192d25d 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -93,6 +93,8 @@ struct ccid_operations {
 extern int ccid_register(struct ccid_operations *ccid_ops);
 extern int ccid_unregister(struct ccid_operations *ccid_ops);
 
+extern int ccids_register_builtins(void);
+
 struct ccid {
 	struct ccid_operations *ccid_ops;
 	char		       ccid_priv[0];
diff --git a/net/dccp/ccids/Kconfig b/net/dccp/ccids/Kconfig
index 1227594..3698965 100644
--- a/net/dccp/ccids/Kconfig
+++ b/net/dccp/ccids/Kconfig
@@ -1,43 +1,21 @@
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
 	  bool "CCID2 debugging messages"
-	  depends on IP_DCCP_CCID2
+	  depends on IP_DCCP
 	  ---help---
 	    Enable CCID2-specific debugging messages.
 
-	    When compiling CCID2 as a module, this debugging output can
+	    When compiling DCCP as a module, this debugging output can
 	    additionally be toggled by setting the ccid2_debug module
 	    parameter to 0 or 1.
 
 	    If in doubt, say N.
 
 config IP_DCCP_CCID3
-	tristate "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
-	def_tristate IP_DCCP
+	bool "CCID3 (TCP-Friendly) (EXPERIMENTAL)"
+	def_bool y if (IP_DCCP = y || IP_DCCP = m)
 	select IP_DCCP_TFRC_LIB
 	---help---
 	  CCID 3 denotes TCP-Friendly Rate Control (TFRC), an equation-based
@@ -59,10 +37,7 @@ config IP_DCCP_CCID3
 	  This text was extracted from RFC 4340 (sec. 10.2),
 	  http://www.ietf.org/rfc/rfc4340.txt
 	  
-	  To compile this CCID as a module, choose M here: the module will be
-	  called dccp_ccid3.
-
-	  If in doubt, say M.
+	  If in doubt, say N.
 
 config IP_DCCP_CCID3_DEBUG
 	  bool "CCID3 debugging messages"
diff --git a/net/dccp/ccids/Makefile b/net/dccp/ccids/Makefile
index 438f20b..cdaefff 100644
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
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index c9ea19a..f4d2108 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -768,7 +768,7 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 }
 
-static struct ccid_operations ccid2 = {
+struct ccid_operations ccid2_ops = {
 	.ccid_id		= DCCPC_CCID2,
 	.ccid_name		= "TCP-like",
 	.ccid_owner		= THIS_MODULE,
@@ -784,22 +784,5 @@ static struct ccid_operations ccid2 = {
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 module_param(ccid2_debug, bool, 0644);
-MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
+MODULE_PARM_DESC(ccid2_debug, "Enable CCID2 debug messages");
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
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 3b8bd7c..62de014 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -940,7 +940,7 @@ static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 	return 0;
 }
 
-static struct ccid_operations ccid3 = {
+struct ccid_operations ccid3_ops = {
 	.ccid_id		   = DCCPC_CCID3,
 	.ccid_name		   = "TCP-Friendly Rate Control",
 	.ccid_owner		   = THIS_MODULE,
@@ -964,23 +964,5 @@ static struct ccid_operations ccid3 = {
 
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 module_param(ccid3_debug, bool, 0644);
-MODULE_PARM_DESC(ccid3_debug, "Enable debug messages");
+MODULE_PARM_DESC(ccid3_debug, "Enable CCID3 debug messages");
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
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 0bc4c9a..f2230fc 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -432,10 +432,8 @@ static inline int dccp_ack_pending(const struct sock *sk)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
 	return dp->dccps_timestamp_echo != 0 ||
-#ifdef CONFIG_IP_DCCP_ACKVEC
 	       (dp->dccps_hc_rx_ackvec != NULL &&
 		dccp_ackvec_pending(dp->dccps_hc_rx_ackvec)) ||
-#endif
 	       inet_csk_ack_scheduled(sk);
 }
 
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index d5c2bac..c704b74 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1117,9 +1117,15 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out_ackvec_exit;
 
+	rc = ccids_register_builtins();
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

----- End forwarded message -----
