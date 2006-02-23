From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 23 Feb 2006 22:12:58 +0000
Subject: [PATCH 7/7] [DCCP]: Move the IPv4 specific bits from proto.c to ipv4.c
Message-Id: <11407327783141-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

With this patch in place we can break down the complexity by better
compartmentalizing the code that is common to ipv6 and ipv4.

Now we have these modules:
Module                  Size  Used by
dccp_diag               1344  0
inet_diag               9448  1 dccp_diag
dccp_ccid3             15856  0
dccp_tfrc_lib          12320  1 dccp_ccid3
dccp_ccid2              5764  0
dccp_ipv4              16996  2
dccp                   48208  4 dccp_diag,dccp_ccid3,dccp_ccid2,dccp_ipv4

dccp_ipv6 still requires dccp_ipv4 due to dccp_ipv6_mapped, that is the next
target to work on the "hey, ipv4 is legacy, I only want ipv6 dude!" direction.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/Makefile  |    7 +--
 net/dccp/dccp.h    |    6 --
 net/dccp/ipv4.c    |  140 ++++++++++++++++++++++++++++++++++++++++++++++++++--
 net/dccp/options.c |    2 +
 net/dccp/output.c  |    2 +
 net/dccp/proto.c   |  132 ++-----------------------------------------------
 6 files changed, 148 insertions(+), 141 deletions(-)

63d1742ba27197d1678bd5cc05cfa8a1fde3c6d4
diff --git a/net/dccp/Makefile b/net/dccp/Makefile
index 7af0569..7696e21 100644
--- a/net/dccp/Makefile
+++ b/net/dccp/Makefile
@@ -2,10 +2,11 @@ obj-$(CONFIG_IPV6) += dccp_ipv6.o
 
 dccp_ipv6-y := ipv6.o
 
-obj-$(CONFIG_IP_DCCP) += dccp.o
+obj-$(CONFIG_IP_DCCP) += dccp.o dccp_ipv4.o
 
-dccp-y := ccid.o feat.o input.o ipv4.o minisocks.o options.o output.o proto.o \
-	  timer.o
+dccp-y := ccid.o feat.o input.o minisocks.o options.o output.o proto.o timer.o
+
+dccp_ipv4-y := ipv4.o
 
 dccp-$(CONFIG_IP_DCCP_ACKVEC) += ackvec.o
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index b6ea4cc..46aa481 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -59,8 +59,6 @@ extern void dccp_time_wait(struct sock *
 
 #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
 
-extern struct proto dccp_prot;
-
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
@@ -209,10 +207,6 @@ extern struct sock *dccp_create_openreq_
 
 extern int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb);
 
-extern void dccp_v4_err(struct sk_buff *skb, u32);
-
-extern int dccp_v4_rcv(struct sk_buff *skb);
-
 extern struct sock *dccp_v4_request_recv_sock(struct sock *sk,
 					      struct sk_buff *skb,
 					      struct request_sock *req,
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a7332f0..033c3ab 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -18,8 +18,10 @@
 #include <linux/random.h>
 
 #include <net/icmp.h>
+#include <net/inet_common.h>
 #include <net/inet_hashtables.h>
 #include <net/inet_sock.h>
+#include <net/protocol.h>
 #include <net/sock.h>
 #include <net/timewait_sock.h>
 #include <net/tcp_states.h>
@@ -285,7 +287,7 @@ out:
  * check at all. A more general error queue to queue errors for later handling
  * is probably better.
  */
-void dccp_v4_err(struct sk_buff *skb, u32 info)
+static void dccp_v4_err(struct sk_buff *skb, u32 info)
 {
 	const struct iphdr *iph = (struct iphdr *)skb->data;
 	const struct dccp_hdr *dh = (struct dccp_hdr *)(skb->data +
@@ -639,6 +641,8 @@ int dccp_v4_checksum(const struct sk_buf
 				 IPPROTO_DCCP, tmp);
 }
 
+EXPORT_SYMBOL_GPL(dccp_v4_checksum);
+
 static int dccp_v4_verify_checksum(struct sk_buff *skb,
 				   const __be32 saddr, const __be32 daddr)
 {
@@ -871,7 +875,7 @@ int dccp_invalid_packet(struct sk_buff *
 EXPORT_SYMBOL_GPL(dccp_invalid_packet);
 
 /* this is called when real data arrives */
-int dccp_v4_rcv(struct sk_buff *skb)
+static int dccp_v4_rcv(struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh;
 	struct sock *sk;
@@ -978,7 +982,7 @@ do_time_wait:
 	goto no_dccp_socket;
 }
 
-struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
+static struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
 	.queue_xmit	= ip_queue_xmit,
 	.send_check	= dccp_v4_send_check,
 	.rebuild_header	= inet_sk_rebuild_header,
@@ -1018,7 +1022,7 @@ static struct timewait_sock_ops dccp_tim
 	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
 };
 
-struct proto dccp_prot = {
+struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
 	.close			= dccp_close,
@@ -1044,4 +1048,130 @@ struct proto dccp_prot = {
 	.twsk_prot		= &dccp_timewait_sock_ops,
 };
 
-EXPORT_SYMBOL_GPL(dccp_prot);
+static struct net_protocol dccp_v4_protocol = {
+	.handler	= dccp_v4_rcv,
+	.err_handler	= dccp_v4_err,
+	.no_policy	= 1,
+};
+
+static const struct proto_ops inet_dccp_ops = {
+	.family		= PF_INET,
+	.owner		= THIS_MODULE,
+	.release	= inet_release,
+	.bind		= inet_bind,
+	.connect	= inet_stream_connect,
+	.socketpair	= sock_no_socketpair,
+	.accept		= inet_accept,
+	.getname	= inet_getname,
+	/* FIXME: work on tcp_poll to rename it to inet_csk_poll */
+	.poll		= dccp_poll,
+	.ioctl		= inet_ioctl,
+	/* FIXME: work on inet_listen to rename it to sock_common_listen */
+	.listen		= inet_dccp_listen,
+	.shutdown	= inet_shutdown,
+	.setsockopt	= sock_common_setsockopt,
+	.getsockopt	= sock_common_getsockopt,
+	.sendmsg	= inet_sendmsg,
+	.recvmsg	= sock_common_recvmsg,
+	.mmap		= sock_no_mmap,
+	.sendpage	= sock_no_sendpage,
+};
+
+static struct inet_protosw dccp_v4_protosw = {
+	.type		= SOCK_DCCP,
+	.protocol	= IPPROTO_DCCP,
+	.prot		= &dccp_v4_prot,
+	.ops		= &inet_dccp_ops,
+	.capability	= -1,
+	.no_check	= 0,
+	.flags		= INET_PROTOSW_ICSK,
+};
+
+/*
+ * This is the global socket data structure used for responding to
+ * the Out-of-the-blue (OOTB) packets. A control sock will be created
+ * for this socket at the initialization time.
+ */
+struct socket *dccp_ctl_socket;
+
+static char dccp_ctl_socket_err_msg[] __initdata +	KERN_ERR "DCCP: Failed to create the control socket.\n";
+
+static int __init dccp_ctl_sock_init(void)
+{
+	int rc = sock_create_kern(PF_INET, SOCK_DCCP, IPPROTO_DCCP,
+				  &dccp_ctl_socket);
+	if (rc < 0)
+		printk(dccp_ctl_socket_err_msg);
+	else {
+		dccp_ctl_socket->sk->sk_allocation = GFP_ATOMIC;
+		inet_sk(dccp_ctl_socket->sk)->uc_ttl = -1;
+
+		/* Unhash it so that IP input processing does not even
+		 * see it, we do not wish this socket to see incoming
+		 * packets.
+		 */
+		dccp_ctl_socket->sk->sk_prot->unhash(dccp_ctl_socket->sk);
+	}
+
+	return rc;
+}
+
+#ifdef CONFIG_IP_DCCP_UNLOAD_HACK
+void dccp_ctl_sock_exit(void)
+{
+	if (dccp_ctl_socket != NULL) {
+		sock_release(dccp_ctl_socket);
+		dccp_ctl_socket = NULL;
+	}
+}
+
+EXPORT_SYMBOL_GPL(dccp_ctl_sock_exit);
+#endif
+
+static int __init dccp_v4_init(void)
+{
+	int err = proto_register(&dccp_v4_prot, 1);
+
+	if (err != 0)
+		goto out;
+
+	err = inet_add_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
+	if (err != 0)
+		goto out_proto_unregister;
+
+	inet_register_protosw(&dccp_v4_protosw);
+
+	err = dccp_ctl_sock_init();
+	if (err)
+		goto out_unregister_protosw;
+out:
+	return err;
+out_unregister_protosw:
+	inet_unregister_protosw(&dccp_v4_protosw);
+	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
+out_proto_unregister:
+	proto_unregister(&dccp_v4_prot);
+	goto out;
+}
+
+static void __exit dccp_v4_exit(void)
+{
+	inet_unregister_protosw(&dccp_v4_protosw);
+	inet_del_protocol(&dccp_v4_protocol, IPPROTO_DCCP);
+	proto_unregister(&dccp_v4_prot);
+}
+
+module_init(dccp_v4_init);
+module_exit(dccp_v4_exit);
+
+/*
+ * __stringify doesn't likes enums, so use SOCK_DCCP (6) and IPPROTO_DCCP (33)
+ * values directly, Also cover the case where the protocol is not specified,
+ * i.e. net-pf-PF_INET-proto-0-type-SOCK_DCCP
+ */
+MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-33-type-6");
+MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-0-type-6");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@mandriva.com>");
+MODULE_DESCRIPTION("DCCP - Datagram Congestion Controlled Protocol");
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 3ecd319..79d228e 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -258,6 +258,8 @@ out_invalid_option:
 	return -1;
 }
 
+EXPORT_SYMBOL_GPL(dccp_parse_options);
+
 static void dccp_encode_value_var(const u32 value, unsigned char *to,
 				  const unsigned int len)
 {
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 6bd21e3..8c83aa5 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -526,6 +526,8 @@ void dccp_send_sync(struct sock *sk, con
 	dccp_transmit_skb(sk, skb);
 }
 
+EXPORT_SYMBOL_GPL(dccp_send_sync);
+
 /*
  * Send a DCCP_PKT_CLOSE/CLOSEREQ. The caller locks the socket for us. This
  * cannot be allowed to fail queueing a DCCP_PKT_CLOSE/CLOSEREQ frame under
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index c048d5b..d110cdb 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -23,9 +23,7 @@
 #include <linux/random.h>
 #include <net/checksum.h>
 
-#include <net/inet_common.h>
 #include <net/inet_sock.h>
-#include <net/protocol.h>
 #include <net/sock.h>
 #include <net/xfrm.h>
 
@@ -55,12 +53,6 @@ struct inet_hashinfo __cacheline_aligned
 
 EXPORT_SYMBOL_GPL(dccp_hashinfo);
 
-static struct net_protocol dccp_protocol = {
-	.handler	= dccp_v4_rcv,
-	.err_handler	= dccp_v4_err,
-	.no_policy	= 1,
-};
-
 const char *dccp_packet_name(const int type)
 {
 	static const char *dccp_packet_names[] = {
@@ -856,83 +848,6 @@ void dccp_shutdown(struct sock *sk, int 
 
 EXPORT_SYMBOL_GPL(dccp_shutdown);
 
-static const struct proto_ops inet_dccp_ops = {
-	.family		= PF_INET,
-	.owner		= THIS_MODULE,
-	.release	= inet_release,
-	.bind		= inet_bind,
-	.connect	= inet_stream_connect,
-	.socketpair	= sock_no_socketpair,
-	.accept		= inet_accept,
-	.getname	= inet_getname,
-	/* FIXME: work on tcp_poll to rename it to inet_csk_poll */
-	.poll		= dccp_poll,
-	.ioctl		= inet_ioctl,
-	/* FIXME: work on inet_listen to rename it to sock_common_listen */
-	.listen		= inet_dccp_listen,
-	.shutdown	= inet_shutdown,
-	.setsockopt	= sock_common_setsockopt,
-	.getsockopt	= sock_common_getsockopt,
-	.sendmsg	= inet_sendmsg,
-	.recvmsg	= sock_common_recvmsg,
-	.mmap		= sock_no_mmap,
-	.sendpage	= sock_no_sendpage,
-};
-
-extern struct net_proto_family inet_family_ops;
-
-static struct inet_protosw dccp_v4_protosw = {
-	.type		= SOCK_DCCP,
-	.protocol	= IPPROTO_DCCP,
-	.prot		= &dccp_prot,
-	.ops		= &inet_dccp_ops,
-	.capability	= -1,
-	.no_check	= 0,
-	.flags		= INET_PROTOSW_ICSK,
-};
-
-/*
- * This is the global socket data structure used for responding to
- * the Out-of-the-blue (OOTB) packets. A control sock will be created
- * for this socket at the initialization time.
- */
-struct socket *dccp_ctl_socket;
-
-static char dccp_ctl_socket_err_msg[] __initdata -	KERN_ERR "DCCP: Failed to create the control socket.\n";
-
-static int __init dccp_ctl_sock_init(void)
-{
-	int rc = sock_create_kern(PF_INET, SOCK_DCCP, IPPROTO_DCCP,
-				  &dccp_ctl_socket);
-	if (rc < 0)
-		printk(dccp_ctl_socket_err_msg);
-	else {
-		dccp_ctl_socket->sk->sk_allocation = GFP_ATOMIC;
-		inet_sk(dccp_ctl_socket->sk)->uc_ttl = -1;
-
-		/* Unhash it so that IP input processing does not even
-		 * see it, we do not wish this socket to see incoming
-		 * packets.
-		 */
-		dccp_ctl_socket->sk->sk_prot->unhash(dccp_ctl_socket->sk);
-	}
-
-	return rc;
-}
-
-#ifdef CONFIG_IP_DCCP_UNLOAD_HACK
-void dccp_ctl_sock_exit(void)
-{
-	if (dccp_ctl_socket != NULL) {
-		sock_release(dccp_ctl_socket);
-		dccp_ctl_socket = NULL;
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_ctl_sock_exit);
-#endif
-
 static int __init dccp_mib_init(void)
 {
 	int rc = -ENOMEM;
@@ -955,7 +870,7 @@ out_free_one:
 
 }
 
-static int dccp_mib_exit(void)
+static void dccp_mib_exit(void)
 {
 	free_percpu(dccp_statistics[0]);
 	free_percpu(dccp_statistics[1]);
@@ -978,18 +893,14 @@ static int __init dccp_init(void)
 {
 	unsigned long goal;
 	int ehash_order, bhash_order, i;
-	int rc = proto_register(&dccp_prot, 1);
+	int rc = -ENOBUFS;
 
-	if (rc)
-		goto out;
-
-	rc = -ENOBUFS;
 	dccp_hashinfo.bind_bucket_cachep  		kmem_cache_create("dccp_bind_bucket",
 				  sizeof(struct inet_bind_bucket), 0,
 				  SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!dccp_hashinfo.bind_bucket_cachep)
-		goto out_proto_unregister;
+		goto out;
 
 	/*
 	 * Size and allocate the main established and bind bucket
@@ -1055,33 +966,18 @@ static int __init dccp_init(void)
 	if (rc)
 		goto out_free_dccp_bhash;
 
-	rc = -EAGAIN;
-	if (inet_add_protocol(&dccp_protocol, IPPROTO_DCCP))
-		goto out_free_dccp_v4_mibs;
-
-	inet_register_protosw(&dccp_v4_protosw);
-
 	rc = dccp_ackvec_init();
 	if (rc)
-		goto out_unregister_protosw;
+		goto out_free_dccp_mib;
 
 	rc = dccp_sysctl_init();
 	if (rc)
 		goto out_ackvec_exit;
-
-	rc = dccp_ctl_sock_init();
-	if (rc)
-		goto out_sysctl_exit;
 out:
 	return rc;
-out_sysctl_exit:
-	dccp_sysctl_exit();
 out_ackvec_exit:
 	dccp_ackvec_exit();
-out_unregister_protosw:
-	inet_unregister_protosw(&dccp_v4_protosw);
-	inet_del_protocol(&dccp_protocol, IPPROTO_DCCP);
-out_free_dccp_v4_mibs:
+out_free_dccp_mib:
 	dccp_mib_exit();
 out_free_dccp_bhash:
 	free_pages((unsigned long)dccp_hashinfo.bhash, bhash_order);
@@ -1092,21 +988,11 @@ out_free_dccp_ehash:
 out_free_bind_bucket_cachep:
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
 	dccp_hashinfo.bind_bucket_cachep = NULL;
-out_proto_unregister:
-	proto_unregister(&dccp_prot);
 	goto out;
 }
 
-static const char dccp_del_proto_err_msg[] __exitdata -	KERN_ERR "can't remove dccp net_protocol\n";
-
 static void __exit dccp_fini(void)
 {
-	inet_unregister_protosw(&dccp_v4_protosw);
-
-	if (inet_del_protocol(&dccp_protocol, IPPROTO_DCCP) < 0)
-		printk(dccp_del_proto_err_msg);
-
 	dccp_mib_exit();
 	free_pages((unsigned long)dccp_hashinfo.bhash,
 		   get_order(dccp_hashinfo.bhash_size *
@@ -1115,7 +1001,6 @@ static void __exit dccp_fini(void)
 		   get_order(dccp_hashinfo.ehash_size *
 			     sizeof(struct inet_ehash_bucket)));
 	kmem_cache_destroy(dccp_hashinfo.bind_bucket_cachep);
-	proto_unregister(&dccp_prot);
 	dccp_ackvec_exit();
 	dccp_sysctl_exit();
 }
@@ -1123,13 +1008,6 @@ static void __exit dccp_fini(void)
 module_init(dccp_init);
 module_exit(dccp_fini);
 
-/*
- * __stringify doesn't likes enums, so use SOCK_DCCP (6) and IPPROTO_DCCP (33)
- * values directly, Also cover the case where the protocol is not specified,
- * i.e. net-pf-PF_INET-proto-0-type-SOCK_DCCP
- */
-MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-33-type-6");
-MODULE_ALIAS("net-pf-" __stringify(PF_INET) "-proto-0-type-6");
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Arnaldo Carvalho de Melo <acme@conectiva.com.br>");
 MODULE_DESCRIPTION("DCCP - Datagram Congestion Controlled Protocol");
-- 
1.2.2.gd27d


