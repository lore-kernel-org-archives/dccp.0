From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sat, 25 Feb 2006 21:16:12 +0000
Subject: [PATCH 3/3] [DCCP] ipv6: Add missing ipv6 control socket
Message-Id: <11409021721724-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

I guess I forgot to add it, nah, now it just works:

18:04:33.274066 IP6 ::1.1476 > ::1.5001: request (service=3D0)
18:04:33.334482 IP6 ::1.5001 > ::1.1476: reset (code=BAd_service_code)

Ditched IP_DCCP_UNLOAD_HACK, as now we would have to do it for both IPv6 and
IPv4, so I'll come up with another way for freeing the control sockets in
upcoming changesets.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/dccp/Kconfig       |    9 -------
 net/dccp/ccids/ccid3.c |    9 -------
 net/dccp/dccp.h        |    4 +--
 net/dccp/ipv4.c        |   65 +++++++++++++++++++++-----------------------=
----
 net/dccp/ipv6.c        |   44 ++++++++++++++++++++++++++++++--
 net/dccp/proto.c       |    6 +---
 6 files changed, 72 insertions(+), 65 deletions(-)

3e8d786e99c8e5abd88177763e7121341bb05d05
diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
index 24a6981..7e096ba 100644
--- a/net/dccp/Kconfig
+++ b/net/dccp/Kconfig
@@ -40,15 +40,6 @@ config IP_DCCP_DEBUG
=20
 	  Just say N.
=20
-config IP_DCCP_UNLOAD_HACK
-	depends on IP_DCCP=3Dm && IP_DCCP_CCID3=3Dm
-	bool "DCCP control sock unload hack"
-	---help---
-	  Enable this to be able to unload the dccp module when the it
-	  has only one refcount held, the control sock one. Just execute
-	  "rmmod dccp_ccid3 dccp"
-
-	  Just say N.
 endmenu
=20
 endmenu
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 47660ca..2b82f96 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -1207,15 +1207,6 @@ module_init(ccid3_module_init);
=20
 static __exit void ccid3_module_exit(void)
 {
-#ifdef CONFIG_IP_DCCP_UNLOAD_HACK
-	/*
-	 * Hack to use while developing, so that we get rid of the control
-	 * sock, that is what keeps a refcount on dccp.ko -acme
-	 */
-	extern void dccp_ctl_sock_exit(void);
-
-	dccp_ctl_sock_exit();
-#endif
 	ccid_unregister(&ccid3);
=20
 	if (ccid3_tx_hist !=3D NULL) {
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 6fcc9d4..d57d213 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -177,7 +177,7 @@ extern int dccp_rcv_state_process(struct
 extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				const struct dccp_hdr *dh, const unsigned len);
=20
-extern int dccp_init_sock(struct sock *sk);
+extern int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized=
);
 extern int dccp_destroy_sock(struct sock *sk);
=20
 extern void		dccp_close(struct sock *sk, long timeout);
@@ -337,8 +337,6 @@ extern void dccp_insert_option(struct so
 			       unsigned char option,
 			       const void *value, unsigned char len);
=20
-extern struct socket *dccp_ctl_socket;
-
 extern void dccp_timestamp(const struct sock *sk, struct timeval *tv);
=20
 static inline suseconds_t timeval_usecs(const struct timeval *tv)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 3fe958e..f53bce5 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -32,6 +32,13 @@
 #include "dccp.h"
 #include "feat.h"
=20
+/*
+ * This is the global socket data structure used for responding to
+ * the Out-of-the-blue (OOTB) packets. A control sock will be created
+ * for this socket at the initialization time.
+ */
+static struct socket *dccp_v4_ctl_socket;
+
 static int dccp_v4_get_port(struct sock *sk, const unsigned short snum)
 {
 	return inet_csk_get_port(&dccp_hashinfo, sk, snum,
@@ -226,11 +233,11 @@ static void dccp_v4_ctl_send_ack(struct=20
 	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
 			 DCCP_SKB_CB(rxskb)->dccpd_seq);
=20
-	bh_lock_sock(dccp_ctl_socket->sk);
-	err =3D ip_build_and_send_pkt(skb, dccp_ctl_socket->sk,
+	bh_lock_sock(dccp_v4_ctl_socket->sk);
+	err =3D ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
 				    rxskb->nh.iph->daddr,
 				    rxskb->nh.iph->saddr, NULL);
-	bh_unlock_sock(dccp_ctl_socket->sk);
+	bh_unlock_sock(dccp_v4_ctl_socket->sk);
=20
 	if (err =3D NET_XMIT_CN || err =3D 0) {
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
@@ -704,7 +711,7 @@ static void dccp_v4_ctl_send_reset(struc
 	if (((struct rtable *)rxskb->dst)->rt_type !=3D RTN_LOCAL)
 		return;
=20
-	dst =3D dccp_v4_route_skb(dccp_ctl_socket->sk, rxskb);
+	dst =3D dccp_v4_route_skb(dccp_v4_ctl_socket->sk, rxskb);
 	if (dst =3D NULL)
 		return;
=20
@@ -741,11 +748,11 @@ static void dccp_v4_ctl_send_reset(struc
 	dh->dccph_checksum =3D dccp_v4_checksum(skb, rxskb->nh.iph->saddr,
 					      rxskb->nh.iph->daddr);
=20
-	bh_lock_sock(dccp_ctl_socket->sk);
-	err =3D ip_build_and_send_pkt(skb, dccp_ctl_socket->sk,
+	bh_lock_sock(dccp_v4_ctl_socket->sk);
+	err =3D ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
 				    rxskb->nh.iph->daddr,
 				    rxskb->nh.iph->saddr, NULL);
-	bh_unlock_sock(dccp_ctl_socket->sk);
+	bh_unlock_sock(dccp_v4_ctl_socket->sk);
=20
 	if (err =3D NET_XMIT_CN || err =3D 0) {
 		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
@@ -997,10 +1004,15 @@ static struct inet_connection_sock_af_op
=20
 static int dccp_v4_init_sock(struct sock *sk)
 {
-	const int err =3D dccp_init_sock(sk);
+	static __u8 dccp_v4_ctl_sock_initialized;
+	int err =3D dccp_init_sock(sk, dccp_v4_ctl_sock_initialized);
=20
-	if (err =3D 0)
+	if (err =3D 0) {
+		if (unlikely(!dccp_v4_ctl_sock_initialized))
+			dccp_v4_ctl_sock_initialized =3D 1;
 		inet_csk(sk)->icsk_af_ops =3D &dccp_ipv4_af_ops;
+	}
+
 	return err;
 }
=20
@@ -1087,48 +1099,29 @@ static struct inet_protosw dccp_v4_proto
 	.flags		=3D INET_PROTOSW_ICSK,
 };
=20
-/*
- * This is the global socket data structure used for responding to
- * the Out-of-the-blue (OOTB) packets. A control sock will be created
- * for this socket at the initialization time.
- */
-struct socket *dccp_ctl_socket;
-
-static char dccp_ctl_socket_err_msg[] __initdata +static char dccp_v4_ctl_=
socket_err_msg[] __initdata  	KERN_ERR "DCCP: Failed to create the control =
socket.\n";
=20
-static int __init dccp_ctl_sock_init(void)
+static int __init dccp_v4_ctl_sock_init(void)
 {
 	int rc =3D sock_create_kern(PF_INET, SOCK_DCCP, IPPROTO_DCCP,
-				  &dccp_ctl_socket);
+				  &dccp_v4_ctl_socket);
 	if (rc < 0)
-		printk(dccp_ctl_socket_err_msg);
+		printk(dccp_v4_ctl_socket_err_msg);
 	else {
-		dccp_ctl_socket->sk->sk_allocation =3D GFP_ATOMIC;
-		inet_sk(dccp_ctl_socket->sk)->uc_ttl =3D -1;
+		dccp_v4_ctl_socket->sk->sk_allocation =3D GFP_ATOMIC;
+		inet_sk(dccp_v4_ctl_socket->sk)->uc_ttl =3D -1;
=20
 		/* Unhash it so that IP input processing does not even
 		 * see it, we do not wish this socket to see incoming
 		 * packets.
 		 */
-		dccp_ctl_socket->sk->sk_prot->unhash(dccp_ctl_socket->sk);
+		dccp_v4_ctl_socket->sk->sk_prot->unhash(dccp_v4_ctl_socket->sk);
 	}
=20
 	return rc;
 }
=20
-#ifdef CONFIG_IP_DCCP_UNLOAD_HACK
-void dccp_ctl_sock_exit(void)
-{
-	if (dccp_ctl_socket !=3D NULL) {
-		sock_release(dccp_ctl_socket);
-		dccp_ctl_socket =3D NULL;
-	}
-}
-
-EXPORT_SYMBOL_GPL(dccp_ctl_sock_exit);
-#endif
-
 static int __init dccp_v4_init(void)
 {
 	int err =3D proto_register(&dccp_v4_prot, 1);
@@ -1142,7 +1135,7 @@ static int __init dccp_v4_init(void)
=20
 	inet_register_protosw(&dccp_v4_protosw);
=20
-	err =3D dccp_ctl_sock_init();
+	err =3D dccp_v4_ctl_sock_init();
 	if (err)
 		goto out_unregister_protosw;
 out:
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 904967b..3c9f083 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -33,6 +33,9 @@
 #include "dccp.h"
 #include "ipv6.h"
=20
+/* Socket used for sending RSTs and ACKs */
+static struct socket *dccp_v6_ctl_socket;
+
 static void dccp_v6_ctl_send_reset(struct sk_buff *skb);
 static void dccp_v6_reqsk_send_ack(struct sk_buff *skb,
 				   struct request_sock *req);
@@ -568,7 +571,7 @@ static void dccp_v6_ctl_send_reset(struc
 	/* sk =3D NULL, but it is safe for now. RST socket required. */
 	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
 		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >=3D 0) {
-			ip6_xmit(NULL, skb, &fl, NULL, 0);
+			ip6_xmit(dccp_v6_ctl_socket->sk, skb, &fl, NULL, 0);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
 			return;
@@ -623,7 +626,7 @@ static void dccp_v6_ctl_send_ack(struct=20
=20
 	if (!ip6_dst_lookup(NULL, &skb->dst, &fl)) {
 		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >=3D 0) {
-			ip6_xmit(NULL, skb, &fl, NULL, 0);
+			ip6_xmit(dccp_v6_ctl_socket->sk, skb, &fl, NULL, 0);
 			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
 			return;
 		}
@@ -1146,10 +1149,14 @@ static struct inet_connection_sock_af_op
  */
 static int dccp_v6_init_sock(struct sock *sk)
 {
-	int err =3D dccp_init_sock(sk);
+	static __u8 dccp_v6_ctl_sock_initialized;
+	int err =3D dccp_init_sock(sk, dccp_v6_ctl_sock_initialized);
=20
-	if (err =3D 0)
+	if (err =3D 0) {
+		if (unlikely(!dccp_v6_ctl_sock_initialized))
+			dccp_v6_ctl_sock_initialized =3D 1;
 		inet_csk(sk)->icsk_af_ops =3D &dccp_ipv6_af_ops;
+	}
=20
 	return err;
 }
@@ -1222,6 +1229,29 @@ static struct inet_protosw dccp_v6_proto
 	.flags		=3D INET_PROTOSW_ICSK,
 };
=20
+static char dccp_v6_ctl_socket_err_msg[] __initdata +	KERN_ERR "DCCP: Fail=
ed to create the control socket.\n";
+
+static int __init dccp_v6_ctl_sock_init(void)
+{
+	int rc =3D sock_create_kern(PF_INET6, SOCK_DCCP, IPPROTO_DCCP,
+				  &dccp_v6_ctl_socket);
+	if (rc < 0)
+		printk(dccp_v6_ctl_socket_err_msg);
+	else {
+		dccp_v6_ctl_socket->sk->sk_allocation =3D GFP_ATOMIC;
+		inet_sk(dccp_v6_ctl_socket->sk)->uc_ttl =3D -1;
+
+		/* Unhash it so that IP input processing does not even
+		 * see it, we do not wish this socket to see incoming
+		 * packets.
+		 */
+		dccp_v6_ctl_socket->sk->sk_prot->unhash(dccp_v6_ctl_socket->sk);
+	}
+
+	return rc;
+}
+
 static int __init dccp_v6_init(void)
 {
 	int err =3D proto_register(&dccp_v6_prot, 1);
@@ -1234,8 +1264,14 @@ static int __init dccp_v6_init(void)
 		goto out_unregister_proto;
=20
 	inet6_register_protosw(&dccp_v6_protosw);
+
+	if (dccp_v6_ctl_sock_init() !=3D 0)
+		goto out_unregister_protosw;
 out:
 	return err;
+out_unregister_protosw:
+	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
+	inet6_unregister_protosw(&dccp_v6_protosw);
 out_unregister_proto:
 	proto_unregister(&dccp_v6_prot);
 	goto out;
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index c735433..9e97ce6 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -163,11 +163,10 @@ void dccp_unhash(struct sock *sk)
=20
 EXPORT_SYMBOL_GPL(dccp_unhash);
=20
-int dccp_init_sock(struct sock *sk)
+int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 {
 	struct dccp_sock *dp =3D dccp_sk(sk);
 	struct inet_connection_sock *icsk =3D inet_csk(sk);
-	static int dccp_ctl_socket_init =3D 1;
=20
 	dccp_options_init(&dp->dccps_options);
 	do_gettimeofday(&dp->dccps_epoch);
@@ -179,7 +178,7 @@ int dccp_init_sock(struct sock *sk)
 	 * lets leave it here, later the real solution is to do this in a
 	 * setsockopt(CCIDs-I-want/accept). -acme
 	 */
-	if (likely(!dccp_ctl_socket_init)) {
+	if (likely(ctl_sock_initialized)) {
 		int rc =3D dccp_feat_init(sk);
=20
 		if (rc)
@@ -211,7 +210,6 @@ int dccp_init_sock(struct sock *sk)
 		/* control socket doesn't need feat nego */
 		INIT_LIST_HEAD(&dp->dccps_options.dccpo_pending);
 		INIT_LIST_HEAD(&dp->dccps_options.dccpo_conf);
-		dccp_ctl_socket_init =3D 0;
 	}=09
=20
 	dccp_init_xmit_timers(sk);
--=20
1.2.2.gd27d


