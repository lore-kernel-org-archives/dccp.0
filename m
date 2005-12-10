From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sat, 10 Dec 2005 19:27:21 +0000
Subject: [PATCH 1/6][IPV6]: Generalise some functions
Message-Id: <39e6f6c70512101127m1c0f29f4n62c0086d4aa9e0b6@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_22555_15782914.1134242841408"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_22555_15782914.1134242841408
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

    Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Later today I'll try and continue sending the rest of the changesets
finishing this phase, getting my initial DCCPv6 implementation in the tree.

Best Regards,

- Arnaldo

------=_Part_22555_15782914.1134242841408
Content-Type: text/x-patch; name=1.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="1.patch"

tree b0c2bc5b39feb3c74900f31e394915945931564f
parent b2bd594ae1ae20d0163870a965a0ef7526b072c4
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1134227699 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1134227699 -0200

[IPV6]: Generalise some functions

Using sk->sk_protocol instead of IPPROTO_TCP.

Will be used by DCCPv6 in the next changesets.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/linux/ipv6.h                |    2 
 include/net/inet6_connection_sock.h |   13 ++-
 net/ipv6/af_inet6.c                 |   52 ++++++++++++
 net/ipv6/inet6_connection_sock.c    |  103 ++++++++++++++++++++++++
 net/ipv6/tcp_ipv6.c                 |  153 ------------------------------------
 5 files changed, 173 insertions(+), 150 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 7d3e86d..69a0dec 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -297,6 +297,8 @@ struct tcp6_sock {
 	struct ipv6_pinfo inet6;
 };
 
+extern int inet6_sk_rebuild_header(struct sock *sk);
+
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 static inline struct ipv6_pinfo * inet6_sk(const struct sock *__sk)
 {
diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
index aa30ebd..b33b438 100644
--- a/include/net/inet6_connection_sock.h
+++ b/include/net/inet6_connection_sock.h
@@ -15,8 +15,15 @@
 
 #include <linux/types.h>
 
-struct sock;
+struct in6_addr;
+struct inet_bind_bucket;
 struct request_sock;
+struct sk_buff;
+struct sock;
+struct sockaddr;
+
+extern int inet6_csk_bind_conflict(const struct sock *sk,
+				   const struct inet_bind_bucket *tb);
 
 extern struct request_sock *inet6_csk_search_req(const struct sock *sk,
 						 struct request_sock ***prevp,
@@ -28,4 +35,8 @@ extern struct request_sock *inet6_csk_se
 extern void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
 					   struct request_sock *req,
 					   const unsigned long timeout);
+
+extern void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr *uaddr);
+
+extern int inet6_csk_xmit(struct sk_buff *skb, int ipfragok);
 #endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index d954638..fd040e9 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -609,6 +609,58 @@ inet6_unregister_protosw(struct inet_pro
 	}
 }
 
+int inet6_sk_rebuild_header(struct sock *sk)
+{
+	int err;
+	struct dst_entry *dst;
+	struct ipv6_pinfo *np = inet6_sk(sk);
+
+	dst = __sk_dst_check(sk, np->dst_cookie);
+
+	if (dst == NULL) {
+		struct inet_sock *inet = inet_sk(sk);
+		struct in6_addr *final_p = NULL, final;
+		struct flowi fl;
+
+		memset(&fl, 0, sizeof(fl));
+		fl.proto = sk->sk_protocol;
+		ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
+		fl.fl6_flowlabel = np->flow_label;
+		fl.oif = sk->sk_bound_dev_if;
+		fl.fl_ip_dport = inet->dport;
+		fl.fl_ip_sport = inet->sport;
+
+		if (np->opt && np->opt->srcrt) {
+			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
+			ipv6_addr_copy(&final, &fl.fl6_dst);
+			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+			final_p = &final;
+		}
+
+		err = ip6_dst_lookup(sk, &dst, &fl);
+		if (err) {
+			sk->sk_route_caps = 0;
+			return err;
+		}
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			sk->sk_err_soft = -err;
+			return err;
+		}
+
+		ip6_dst_store(sk, dst, NULL);
+		sk->sk_route_caps = dst->dev->features &
+			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+	}
+
+	return 0;
+}
+
+EXPORT_SYMBOL_GPL(inet6_sk_rebuild_header);
+
 int
 snmp6_mib_init(void *ptr[2], size_t mibsize, size_t mibalign)
 {
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
index fe874ee..792f90f 100644
--- a/net/ipv6/inet6_connection_sock.c
+++ b/net/ipv6/inet6_connection_sock.c
@@ -21,8 +21,34 @@
 
 #include <net/addrconf.h>
 #include <net/inet_connection_sock.h>
+#include <net/inet_ecn.h>
+#include <net/inet_hashtables.h>
+#include <net/ip6_route.h>
 #include <net/sock.h>
 
+int inet6_csk_bind_conflict(const struct sock *sk,
+			    const struct inet_bind_bucket *tb)
+{
+	const struct sock *sk2;
+	const struct hlist_node *node;
+
+	/* We must walk the whole port owner list in this case. -DaveM */
+	sk_for_each_bound(sk2, node, &tb->owners) {
+		if (sk != sk2 &&
+		    (!sk->sk_bound_dev_if ||
+		     !sk2->sk_bound_dev_if ||
+		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
+		    (!sk->sk_reuse || !sk2->sk_reuse ||
+		     sk2->sk_state == TCP_LISTEN) &&
+		     ipv6_rcv_saddr_equal(sk, sk2))
+			break;
+	}
+
+	return node != NULL;
+}
+
+EXPORT_SYMBOL_GPL(inet6_csk_bind_conflict);
+
 /*
  * request_sock (formerly open request) hash tables.
  */
@@ -94,3 +120,80 @@ void inet6_csk_reqsk_queue_hash_add(stru
 }
 
 EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
+
+void inet6_csk_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
+{
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
+
+	sin6->sin6_family = AF_INET6;
+	ipv6_addr_copy(&sin6->sin6_addr, &np->daddr);
+	sin6->sin6_port	= inet_sk(sk)->dport;
+	/* We do not store received flowlabel for TCP */
+	sin6->sin6_flowinfo = 0;
+	sin6->sin6_scope_id = 0;
+	if (sk->sk_bound_dev_if &&
+	    ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
+		sin6->sin6_scope_id = sk->sk_bound_dev_if;
+}
+
+EXPORT_SYMBOL_GPL(inet6_csk_addr2sockaddr);
+
+int inet6_csk_xmit(struct sk_buff *skb, int ipfragok)
+{
+	struct sock *sk = skb->sk;
+	struct inet_sock *inet = inet_sk(sk);
+	struct ipv6_pinfo *np = inet6_sk(sk);
+	struct flowi fl;
+	struct dst_entry *dst;
+	struct in6_addr *final_p = NULL, final;
+
+	memset(&fl, 0, sizeof(fl));
+	fl.proto = sk->sk_protocol;
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
+	fl.fl6_flowlabel = np->flow_label;
+	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
+	fl.oif = sk->sk_bound_dev_if;
+	fl.fl_ip_sport = inet->sport;
+	fl.fl_ip_dport = inet->dport;
+
+	if (np->opt && np->opt->srcrt) {
+		struct rt0_hdr *rt0 = (struct rt0_hdr *)np->opt->srcrt;
+		ipv6_addr_copy(&final, &fl.fl6_dst);
+		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
+		final_p = &final;
+	}
+
+	dst = __sk_dst_check(sk, np->dst_cookie);
+
+	if (dst == NULL) {
+		int err = ip6_dst_lookup(sk, &dst, &fl);
+
+		if (err) {
+			sk->sk_err_soft = -err;
+			return err;
+		}
+
+		if (final_p)
+			ipv6_addr_copy(&fl.fl6_dst, final_p);
+
+		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
+			sk->sk_route_caps = 0;
+			return err;
+		}
+
+		ip6_dst_store(sk, dst, NULL);
+		sk->sk_route_caps = dst->dev->features &
+			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
+	}
+
+	skb->dst = dst_clone(dst);
+
+	/* Restore final destination back after routing done */
+	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
+
+	return ip6_xmit(sk, skb, &fl, np->opt, 0);
+}
+
+EXPORT_SYMBOL_GPL(inet6_csk_xmit);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index e6919bf..2783956 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -72,32 +72,10 @@ static void	tcp_v6_send_check(struct soc
 				  struct sk_buff *skb);
 
 static int	tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb);
-static int	tcp_v6_xmit(struct sk_buff *skb, int ipfragok);
 
 static struct inet_connection_sock_af_ops ipv6_mapped;
 static struct inet_connection_sock_af_ops ipv6_specific;
 
-int inet6_csk_bind_conflict(const struct sock *sk,
-			    const struct inet_bind_bucket *tb)
-{
-	const struct sock *sk2;
-	const struct hlist_node *node;
-
-	/* We must walk the whole port owner list in this case. -DaveM */
-	sk_for_each_bound(sk2, node, &tb->owners) {
-		if (sk != sk2 &&
-		    (!sk->sk_bound_dev_if ||
-		     !sk2->sk_bound_dev_if ||
-		     sk->sk_bound_dev_if == sk2->sk_bound_dev_if) &&
-		    (!sk->sk_reuse || !sk2->sk_reuse ||
-		     sk2->sk_state == TCP_LISTEN) &&
-		     ipv6_rcv_saddr_equal(sk, sk2))
-			break;
-	}
-
-	return node != NULL;
-}
-
 static int tcp_v6_get_port(struct sock *sk, unsigned short snum)
 {
 	return inet_csk_get_port(&tcp_hashinfo, sk, snum,
@@ -1501,129 +1479,6 @@ do_time_wait:
 	goto discard_it;
 }
 
-static int tcp_v6_rebuild_header(struct sock *sk)
-{
-	int err;
-	struct dst_entry *dst;
-	struct ipv6_pinfo *np = inet6_sk(sk);
-
-	dst = __sk_dst_check(sk, np->dst_cookie);
-
-	if (dst == NULL) {
-		struct inet_sock *inet = inet_sk(sk);
-		struct in6_addr *final_p = NULL, final;
-		struct flowi fl;
-
-		memset(&fl, 0, sizeof(fl));
-		fl.proto = IPPROTO_TCP;
-		ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-		ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-		fl.fl6_flowlabel = np->flow_label;
-		fl.oif = sk->sk_bound_dev_if;
-		fl.fl_ip_dport = inet->dport;
-		fl.fl_ip_sport = inet->sport;
-
-		if (np->opt && np->opt->srcrt) {
-			struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-			ipv6_addr_copy(&final, &fl.fl6_dst);
-			ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-			final_p = &final;
-		}
-
-		err = ip6_dst_lookup(sk, &dst, &fl);
-		if (err) {
-			sk->sk_route_caps = 0;
-			return err;
-		}
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
-			sk->sk_err_soft = -err;
-			return err;
-		}
-
-		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
-	}
-
-	return 0;
-}
-
-static int tcp_v6_xmit(struct sk_buff *skb, int ipfragok)
-{
-	struct sock *sk = skb->sk;
-	struct inet_sock *inet = inet_sk(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct flowi fl;
-	struct dst_entry *dst;
-	struct in6_addr *final_p = NULL, final;
-
-	memset(&fl, 0, sizeof(fl));
-	fl.proto = IPPROTO_TCP;
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-	ipv6_addr_copy(&fl.fl6_src, &np->saddr);
-	fl.fl6_flowlabel = np->flow_label;
-	IP6_ECN_flow_xmit(sk, fl.fl6_flowlabel);
-	fl.oif = sk->sk_bound_dev_if;
-	fl.fl_ip_sport = inet->sport;
-	fl.fl_ip_dport = inet->dport;
-
-	if (np->opt && np->opt->srcrt) {
-		struct rt0_hdr *rt0 = (struct rt0_hdr *) np->opt->srcrt;
-		ipv6_addr_copy(&final, &fl.fl6_dst);
-		ipv6_addr_copy(&fl.fl6_dst, rt0->addr);
-		final_p = &final;
-	}
-
-	dst = __sk_dst_check(sk, np->dst_cookie);
-
-	if (dst == NULL) {
-		int err = ip6_dst_lookup(sk, &dst, &fl);
-
-		if (err) {
-			sk->sk_err_soft = -err;
-			return err;
-		}
-
-		if (final_p)
-			ipv6_addr_copy(&fl.fl6_dst, final_p);
-
-		if ((err = xfrm_lookup(&dst, &fl, sk, 0)) < 0) {
-			sk->sk_route_caps = 0;
-			return err;
-		}
-
-		ip6_dst_store(sk, dst, NULL);
-		sk->sk_route_caps = dst->dev->features &
-			~(NETIF_F_IP_CSUM | NETIF_F_TSO);
-	}
-
-	skb->dst = dst_clone(dst);
-
-	/* Restore final destination back after routing done */
-	ipv6_addr_copy(&fl.fl6_dst, &np->daddr);
-
-	return ip6_xmit(sk, skb, &fl, np->opt, 0);
-}
-
-static void v6_addr2sockaddr(struct sock *sk, struct sockaddr * uaddr)
-{
-	struct ipv6_pinfo *np = inet6_sk(sk);
-	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *) uaddr;
-
-	sin6->sin6_family = AF_INET6;
-	ipv6_addr_copy(&sin6->sin6_addr, &np->daddr);
-	sin6->sin6_port	= inet_sk(sk)->dport;
-	/* We do not store received flowlabel for TCP */
-	sin6->sin6_flowinfo = 0;
-	sin6->sin6_scope_id = 0;
-	if (sk->sk_bound_dev_if &&
-	    ipv6_addr_type(&sin6->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		sin6->sin6_scope_id = sk->sk_bound_dev_if;
-}
-
 static int tcp_v6_remember_stamp(struct sock *sk)
 {
 	/* Alas, not yet... */
@@ -1631,9 +1486,9 @@ static int tcp_v6_remember_stamp(struct 
 }
 
 static struct inet_connection_sock_af_ops ipv6_specific = {
-	.queue_xmit	=	tcp_v6_xmit,
+	.queue_xmit	=	inet6_csk_xmit,
 	.send_check	=	tcp_v6_send_check,
-	.rebuild_header	=	tcp_v6_rebuild_header,
+	.rebuild_header	=	inet6_sk_rebuild_header,
 	.conn_request	=	tcp_v6_conn_request,
 	.syn_recv_sock	=	tcp_v6_syn_recv_sock,
 	.remember_stamp	=	tcp_v6_remember_stamp,
@@ -1641,7 +1496,7 @@ static struct inet_connection_sock_af_op
 
 	.setsockopt	=	ipv6_setsockopt,
 	.getsockopt	=	ipv6_getsockopt,
-	.addr2sockaddr	=	v6_addr2sockaddr,
+	.addr2sockaddr	=	inet6_csk_addr2sockaddr,
 	.sockaddr_len	=	sizeof(struct sockaddr_in6)
 };
 
@@ -1660,7 +1515,7 @@ static struct inet_connection_sock_af_op
 
 	.setsockopt	=	ipv6_setsockopt,
 	.getsockopt	=	ipv6_getsockopt,
-	.addr2sockaddr	=	v6_addr2sockaddr,
+	.addr2sockaddr	=	inet6_csk_addr2sockaddr,
 	.sockaddr_len	=	sizeof(struct sockaddr_in6)
 };
 


------=_Part_22555_15782914.1134242841408--
