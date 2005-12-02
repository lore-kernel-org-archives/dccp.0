From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Fri, 02 Dec 2005 01:10:38 +0000
Subject: [PATCH 2/6][IPV6]: Generalise tcp_v6_search_req & tcp_v6_synq_add
Message-Id: <39e6f6c70512011710s7735f071h6120f3f68a66fb7e@mail.gmail.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="----=_Part_37526_5983957.1133485838174"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

------=_Part_37526_5983957.1133485838174
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi David,

     Please consider pulling from:

master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.16.git

Best Regards,

- Arnaldo

------=_Part_37526_5983957.1133485838174
Content-Type: text/x-patch; name=2.patch; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="2.patch"

tree a2ad2e96371e91a977875fbda686a242ce41072e
parent a94cc4a7611fe08452945b4c74258ef2c3c8bee9
author Arnaldo Carvalho de Melo <acme@mandriva.com> 1133468875 -0200
committer Arnaldo Carvalho de Melo <acme@mandriva.com> 1133468875 -0200

[IPV6]: Generalise tcp_v6_search_req & tcp_v6_synq_add

More work is needed tho to introduce inet6_request_sock from
tcp6_request_sock, in the same layout considerations as ipv6_pinfo in
inet_sock, next changeset will do that.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 include/net/inet6_connection_sock.h |   31 +++++++++++
 include/net/request_sock.h          |    2 
 net/ipv6/Makefile                   |    3 -
 net/ipv6/inet6_connection_sock.c    |   96 ++++++++++++++++++++++++++++++++++++
 net/ipv6/tcp_ipv6.c                 |   78 ++---------------------------
 5 files changed, 137 insertions(+), 73 deletions(-)

------------------------------------------------------------------------------

diff --git a/include/net/inet6_connection_sock.h b/include/net/inet6_connection_sock.h
new file mode 100644
index 0000000..aa30ebd
--- /dev/null
+++ b/include/net/inet6_connection_sock.h
@@ -0,0 +1,31 @@
+/*
+ * NET		Generic infrastructure for INET6 connection oriented protocols.
+ *
+ * Authors:	Many people, see the TCPv6 sources
+ *
+ * 		From code originally in TCPv6
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ */
+#ifndef _INET6_CONNECTION_SOCK_H
+#define _INET6_CONNECTION_SOCK_H
+
+#include <linux/types.h>
+
+struct sock;
+struct request_sock;
+
+extern struct request_sock *inet6_csk_search_req(const struct sock *sk,
+						 struct request_sock ***prevp,
+						 const __u16 rport,
+						 const struct in6_addr *raddr,
+						 const struct in6_addr *laddr,
+						 const int iif);
+
+extern void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
+					   struct request_sock *req,
+					   const unsigned long timeout);
+#endif /* _INET6_CONNECTION_SOCK_H */
diff --git a/include/net/request_sock.h b/include/net/request_sock.h
index b52cc52..11641c9 100644
--- a/include/net/request_sock.h
+++ b/include/net/request_sock.h
@@ -244,7 +244,7 @@ static inline int reqsk_queue_is_full(co
 
 static inline void reqsk_queue_hash_req(struct request_sock_queue *queue,
 					u32 hash, struct request_sock *req,
-					unsigned timeout)
+					unsigned long timeout)
 {
 	struct listen_sock *lopt = queue->listen_opt;
 
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 6460eec..9601fd7 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -8,7 +8,8 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_ou
 		route.o ip6_fib.o ipv6_sockglue.o ndisc.o udp.o raw.o \
 		protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o sysctl_net_ipv6.o datagram.o proc.o \
-		ip6_flowlabel.o ipv6_syms.o netfilter.o
+		ip6_flowlabel.o ipv6_syms.o netfilter.o \
+		inet6_connection_sock.o
 
 ipv6-$(CONFIG_XFRM) += xfrm6_policy.o xfrm6_state.o xfrm6_input.o \
 	xfrm6_output.o
diff --git a/net/ipv6/inet6_connection_sock.c b/net/ipv6/inet6_connection_sock.c
new file mode 100644
index 0000000..04ff443
--- /dev/null
+++ b/net/ipv6/inet6_connection_sock.c
@@ -0,0 +1,96 @@
+/*
+ * INET        An implementation of the TCP/IP protocol suite for the LINUX
+ *             operating system.  INET is implemented using the  BSD Socket
+ *             interface as the means of communication with the user level.
+ *
+ *             Support for INET6 connection oriented protocols.
+ *
+ * Authors:    See the TCPv6 sources
+ *
+ *             This program is free software; you can redistribute it and/or
+ *             modify it under the terms of the GNU General Public License
+ *             as published by the Free Software Foundation; either version
+ *             2 of the License, or(at your option) any later version.
+ */
+
+#include <linux/config.h>
+#include <linux/module.h>
+#include <linux/in6.h>
+#include <linux/ipv6.h>
+#include <linux/jhash.h>
+
+#include <net/addrconf.h>
+#include <net/inet_connection_sock.h>
+#include <net/sock.h>
+
+/*
+ * request_sock (formerly open request) hash tables.
+ */
+static u32 inet6_synq_hash(const struct in6_addr *raddr, const u16 rport,
+			   const u32 rnd, const u16 synq_hsize)
+{
+	u32 a = raddr->s6_addr32[0];
+	u32 b = raddr->s6_addr32[1];
+	u32 c = raddr->s6_addr32[2];
+
+	a += JHASH_GOLDEN_RATIO;
+	b += JHASH_GOLDEN_RATIO;
+	c += rnd;
+	__jhash_mix(a, b, c);
+
+	a += raddr->s6_addr32[3];
+	b += (u32)rport;
+	__jhash_mix(a, b, c);
+
+	return c & (synq_hsize - 1);
+}
+
+struct request_sock *inet6_csk_search_req(const struct sock *sk,
+					  struct request_sock ***prevp,
+					  const __u16 rport,
+					  const struct in6_addr *raddr,
+					  const struct in6_addr *laddr,
+					  const int iif)
+{
+	const struct inet_connection_sock *icsk = inet_csk(sk);
+	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
+	struct request_sock *req, **prev;
+
+	for (prev = &lopt->syn_table[inet6_synq_hash(raddr, rport,
+						     lopt->hash_rnd,
+						     lopt->nr_table_entries)];
+	     (req = *prev) != NULL;
+	     prev = &req->dl_next) {
+		const struct tcp6_request_sock *treq = tcp6_rsk(req);
+
+		if (inet_rsk(req)->rmt_port == rport &&
+		    req->rsk_ops->family == AF_INET6 &&
+		    ipv6_addr_equal(&treq->rmt_addr, raddr) &&
+		    ipv6_addr_equal(&treq->loc_addr, laddr) &&
+		    (!treq->iif || treq->iif == iif)) {
+			BUG_TRAP(req->sk == NULL);
+			*prevp = prev;
+			return req;
+		}
+	}
+
+	return NULL;
+}
+
+EXPORT_SYMBOL_GPL(inet6_csk_search_req);
+
+void inet6_csk_reqsk_queue_hash_add(struct sock *sk,
+				    struct request_sock *req,
+				    const unsigned long timeout)
+{
+	struct inet_connection_sock *icsk = inet_csk(sk);
+	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
+	const u32 h = inet6_synq_hash(&tcp6_rsk(req)->rmt_addr,
+				      inet_rsk(req)->rmt_port,
+				      lopt->hash_rnd, lopt->nr_table_entries);
+
+	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, timeout);
+	inet_csk_reqsk_queue_added(sk, timeout);
+}
+
+EXPORT_SYMBOL_GPL(inet6_csk_reqsk_queue_hash_add);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 1a20b93..3fc9448 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -48,6 +48,7 @@
 #include <net/tcp.h>
 #include <net/ndisc.h>
 #include <net/inet6_hashtables.h>
+#include <net/inet6_connection_sock.h>
 #include <net/ipv6.h>
 #include <net/transp_v6.h>
 #include <net/addrconf.h>
@@ -118,60 +119,6 @@ static void tcp_v6_hash(struct sock *sk)
 	}
 }
 
-/*
- * Open request hash tables.
- */
-
-static u32 tcp_v6_synq_hash(const struct in6_addr *raddr, const u16 rport, const u32 rnd)
-{
-	u32 a, b, c;
-
-	a = raddr->s6_addr32[0];
-	b = raddr->s6_addr32[1];
-	c = raddr->s6_addr32[2];
-
-	a += JHASH_GOLDEN_RATIO;
-	b += JHASH_GOLDEN_RATIO;
-	c += rnd;
-	__jhash_mix(a, b, c);
-
-	a += raddr->s6_addr32[3];
-	b += (u32) rport;
-	__jhash_mix(a, b, c);
-
-	return c & (TCP_SYNQ_HSIZE - 1);
-}
-
-static struct request_sock *tcp_v6_search_req(const struct sock *sk,
-					      struct request_sock ***prevp,
-					      __u16 rport,
-					      struct in6_addr *raddr,
-					      struct in6_addr *laddr,
-					      int iif)
-{
-	const struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	struct request_sock *req, **prev;  
-
-	for (prev = &lopt->syn_table[tcp_v6_synq_hash(raddr, rport, lopt->hash_rnd)];
-	     (req = *prev) != NULL;
-	     prev = &req->dl_next) {
-		const struct tcp6_request_sock *treq = tcp6_rsk(req);
-
-		if (inet_rsk(req)->rmt_port == rport &&
-		    req->rsk_ops->family == AF_INET6 &&
-		    ipv6_addr_equal(&treq->rmt_addr, raddr) &&
-		    ipv6_addr_equal(&treq->loc_addr, laddr) &&
-		    (!treq->iif || treq->iif == iif)) {
-			BUG_TRAP(req->sk == NULL);
-			*prevp = prev;
-			return req;
-		}
-	}
-
-	return NULL;
-}
-
 static __inline__ u16 tcp_v6_check(struct tcphdr *th, int len,
 				   struct in6_addr *saddr, 
 				   struct in6_addr *daddr, 
@@ -662,8 +609,8 @@ static void tcp_v6_err(struct sk_buff *s
 		if (sock_owned_by_user(sk))
 			goto out;
 
-		req = tcp_v6_search_req(sk, &prev, th->dest, &hdr->daddr,
-					&hdr->saddr, inet6_iif(skb));
+		req = inet6_csk_search_req(sk, &prev, th->dest, &hdr->daddr,
+					   &hdr->saddr, inet6_iif(skb));
 		if (!req)
 			goto out;
 
@@ -979,8 +926,9 @@ static struct sock *tcp_v6_hnd_req(struc
 	struct sock *nsk;
 
 	/* Find possible connection requests. */
-	req = tcp_v6_search_req(sk, &prev, th->source, &skb->nh.ipv6h->saddr,
-				&skb->nh.ipv6h->daddr, inet6_iif(skb));
+	req = inet6_csk_search_req(sk, &prev, th->source,
+				   &skb->nh.ipv6h->saddr,
+				   &skb->nh.ipv6h->daddr, inet6_iif(skb));
 	if (req)
 		return tcp_check_req(sk, skb, req, prev);
 
@@ -1004,17 +952,6 @@ static struct sock *tcp_v6_hnd_req(struc
 	return sk;
 }
 
-static void tcp_v6_synq_add(struct sock *sk, struct request_sock *req)
-{
-	struct inet_connection_sock *icsk = inet_csk(sk);
-	struct listen_sock *lopt = icsk->icsk_accept_queue.listen_opt;
-	const u32 h = tcp_v6_synq_hash(&tcp6_rsk(req)->rmt_addr, inet_rsk(req)->rmt_port, lopt->hash_rnd);
-
-	reqsk_queue_hash_req(&icsk->icsk_accept_queue, h, req, TCP_TIMEOUT_INIT);
-	inet_csk_reqsk_queue_added(sk, TCP_TIMEOUT_INIT);
-}
-
-
 /* FIXME: this is substantially similar to the ipv4 code.
  * Can some kind of merge be done? -- erics
  */
@@ -1084,8 +1021,7 @@ static int tcp_v6_conn_request(struct so
 	if (tcp_v6_send_synack(sk, req, NULL))
 		goto drop;
 
-	tcp_v6_synq_add(sk, req);
-
+	inet6_csk_reqsk_queue_hash_add(sk, req, TCP_TIMEOUT_INIT);
 	return 0;
 
 drop:

------=_Part_37526_5983957.1133485838174--
