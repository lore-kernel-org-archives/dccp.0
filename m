From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Mar 2006 21:22:17 +0000
Subject: [PATCH 6/9] [NET]: Identation & other cleanups related to compat_[gs]etsockopt cset
Message-Id: <1142025737272-git-send-email-acme@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

No code changes, just tidying up, in some cases moving EXPORT_SYMBOLs to
just after the function exported, etc.

Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

---

 net/core/sock.c            |   20 +++---
 net/dccp/ipv4.c            |   72 +++++++++++------------
 net/dccp/ipv6.c            |  138 ++++++++++++++++++++++----------------------
 net/dccp/proto.c           |    9 ++-
 net/ipv4/af_inet.c         |  120 +++++++++++++++++++-------------------
 net/ipv4/ip_sockglue.c     |   35 +++++------
 net/ipv4/raw.c             |   46 +++++++--------
 net/ipv4/tcp.c             |   16 +++--
 net/ipv4/tcp_ipv4.c        |   34 +++++------
 net/ipv4/udp.c             |   48 +++++++--------
 net/ipv6/af_inet6.c        |  120 +++++++++++++++++++-------------------
 net/ipv6/ipv6_sockglue.c   |   40 ++++++-------
 net/ipv6/ipv6_syms.c       |    4 -
 net/ipv6/raw.c             |   94 ++++++++++++++----------------
 net/ipv6/tcp_ipv6.c        |   64 ++++++++++----------
 net/ipv6/udp.c             |   48 ++++++++-------
 net/netfilter/nf_sockopt.c |    2 -
 net/sctp/ipv6.c            |   92 +++++++++++++++--------------
 net/sctp/protocol.c        |   94 +++++++++++++++---------------
 19 files changed, 540 insertions(+), 556 deletions(-)

96d51c8c2816c58290a8379ba383eb8d520ab0b4
diff --git a/net/core/sock.c b/net/core/sock.c
index bdbe6aa..e1c1a36 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1397,14 +1397,14 @@ int sock_common_getsockopt(struct socket
 EXPORT_SYMBOL(sock_common_getsockopt);
 
 #ifdef CONFIG_COMPAT
-int compat_sock_common_getsockopt(struct socket *sock, int level,
-		int optname, char __user *optval, int __user *optlen)
+int compat_sock_common_getsockopt(struct socket *sock, int level, int optname,
+				  char __user *optval, int __user *optlen)
 {
 	struct sock *sk = sock->sk;
 
-	if (sk->sk_prot->compat_setsockopt)
-		return sk->sk_prot->compat_getsockopt(sk, level,
-			optname, optval, optlen);
+	if (sk->sk_prot->compat_setsockopt != NULL)
+		return sk->sk_prot->compat_getsockopt(sk, level, optname,
+						      optval, optlen);
 	return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);
 }
 EXPORT_SYMBOL(compat_sock_common_getsockopt);
@@ -1440,14 +1440,14 @@ int sock_common_setsockopt(struct socket
 EXPORT_SYMBOL(sock_common_setsockopt);
 
 #ifdef CONFIG_COMPAT
-int compat_sock_common_setsockopt(struct socket *sock,
-		int level, int optname, char __user *optval, int optlen)
+int compat_sock_common_setsockopt(struct socket *sock, int level, int optname,
+				  char __user *optval, int optlen)
 {
 	struct sock *sk = sock->sk;
 
-	if (sk->sk_prot->compat_setsockopt)
-		return sk->sk_prot->compat_setsockopt(sk, level,
-			optname, optval, optlen);
+	if (sk->sk_prot->compat_setsockopt != NULL)
+		return sk->sk_prot->compat_setsockopt(sk, level, optname,
+						      optval, optlen);
 	return sk->sk_prot->setsockopt(sk, level, optname, optval, optlen);
 }
 EXPORT_SYMBOL(compat_sock_common_setsockopt);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 8a33c84..2904799 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -986,20 +986,20 @@ do_time_wait:
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv4_af_ops = {
-	.queue_xmit	= ip_queue_xmit,
-	.send_check	= dccp_v4_send_check,
-	.rebuild_header	= inet_sk_rebuild_header,
-	.conn_request	= dccp_v4_conn_request,
-	.syn_recv_sock	= dccp_v4_request_recv_sock,
-	.net_header_len	= sizeof(struct iphdr),
-	.setsockopt	= ip_setsockopt,
-	.getsockopt	= ip_getsockopt,
+	.queue_xmit	   = ip_queue_xmit,
+	.send_check	   = dccp_v4_send_check,
+	.rebuild_header	   = inet_sk_rebuild_header,
+	.conn_request	   = dccp_v4_conn_request,
+	.syn_recv_sock	   = dccp_v4_request_recv_sock,
+	.net_header_len	   = sizeof(struct iphdr),
+	.setsockopt	   = ip_setsockopt,
+	.getsockopt	   = ip_getsockopt,
+	.addr2sockaddr	   = inet_csk_addr2sockaddr,
+	.sockaddr_len	   = sizeof(struct sockaddr_in),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_ip_setsockopt,
-	.compat_getsockopt	= compat_ip_getsockopt,
+	.compat_setsockopt = compat_ip_setsockopt,
+	.compat_getsockopt = compat_ip_getsockopt,
 #endif
-	.addr2sockaddr	= inet_csk_addr2sockaddr,
-	.sockaddr_len	= sizeof(struct sockaddr_in),
 };
 
 static int dccp_v4_init_sock(struct sock *sk)
@@ -1044,10 +1044,6 @@ static struct proto dccp_v4_prot = {
 	.init			= dccp_v4_init_sock,
 	.setsockopt		= dccp_setsockopt,
 	.getsockopt		= dccp_getsockopt,
-#ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_dccp_setsockopt,
-	.compat_getsockopt	= compat_dccp_getsockopt,
-#endif
 	.sendmsg		= dccp_sendmsg,
 	.recvmsg		= dccp_recvmsg,
 	.backlog_rcv		= dccp_v4_do_rcv,
@@ -1062,6 +1058,10 @@ static struct proto dccp_v4_prot = {
 	.obj_size		= sizeof(struct dccp_sock),
 	.rsk_prot		= &dccp_request_sock_ops,
 	.twsk_prot		= &dccp_timewait_sock_ops,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt	= compat_dccp_setsockopt,
+	.compat_getsockopt	= compat_dccp_getsockopt,
+#endif
 };
 
 static struct net_protocol dccp_v4_protocol = {
@@ -1071,30 +1071,30 @@ static struct net_protocol dccp_v4_proto
 };
 
 static const struct proto_ops inet_dccp_ops = {
-	.family		= PF_INET,
-	.owner		= THIS_MODULE,
-	.release	= inet_release,
-	.bind		= inet_bind,
-	.connect	= inet_stream_connect,
-	.socketpair	= sock_no_socketpair,
-	.accept		= inet_accept,
-	.getname	= inet_getname,
+	.family		   = PF_INET,
+	.owner		   = THIS_MODULE,
+	.release	   = inet_release,
+	.bind		   = inet_bind,
+	.connect	   = inet_stream_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = inet_accept,
+	.getname	   = inet_getname,
 	/* FIXME: work on tcp_poll to rename it to inet_csk_poll */
-	.poll		= dccp_poll,
-	.ioctl		= inet_ioctl,
+	.poll		   = dccp_poll,
+	.ioctl		   = inet_ioctl,
 	/* FIXME: work on inet_listen to rename it to sock_common_listen */
-	.listen		= inet_dccp_listen,
-	.shutdown	= inet_shutdown,
-	.setsockopt	= sock_common_setsockopt,
-	.getsockopt	= sock_common_getsockopt,
+	.listen		   = inet_dccp_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg	= inet_sendmsg,
-	.recvmsg	= sock_common_recvmsg,
-	.mmap		= sock_no_mmap,
-	.sendpage	= sock_no_sendpage,
 };
 
 static struct inet_protosw dccp_v4_protosw = {
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 89106c7..65e2ab0 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1106,40 +1106,40 @@ do_time_wait:
 }
 
 static struct inet_connection_sock_af_ops dccp_ipv6_af_ops = {
-	.queue_xmit	= inet6_csk_xmit,
-	.send_check	= dccp_v6_send_check,
-	.rebuild_header	= inet6_sk_rebuild_header,
-	.conn_request	= dccp_v6_conn_request,
-	.syn_recv_sock	= dccp_v6_request_recv_sock,
-	.net_header_len	= sizeof(struct ipv6hdr),
-	.setsockopt	= ipv6_setsockopt,
-	.getsockopt	= ipv6_getsockopt,
+	.queue_xmit	   = inet6_csk_xmit,
+	.send_check	   = dccp_v6_send_check,
+	.rebuild_header	   = inet6_sk_rebuild_header,
+	.conn_request	   = dccp_v6_conn_request,
+	.syn_recv_sock	   = dccp_v6_request_recv_sock,
+	.net_header_len	   = sizeof(struct ipv6hdr),
+	.setsockopt	   = ipv6_setsockopt,
+	.getsockopt	   = ipv6_getsockopt,
+	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
+	.sockaddr_len	   = sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_ipv6_setsockopt,
-	.compat_getsockopt	= compat_ipv6_getsockopt,
+	.compat_setsockopt = compat_ipv6_setsockopt,
+	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
-	.addr2sockaddr	= inet6_csk_addr2sockaddr,
-	.sockaddr_len	= sizeof(struct sockaddr_in6)
 };
 
 /*
  *	DCCP over IPv4 via INET6 API
  */
 static struct inet_connection_sock_af_ops dccp_ipv6_mapped = {
-	.queue_xmit	= ip_queue_xmit,
-	.send_check	= dccp_v4_send_check,
-	.rebuild_header	= inet_sk_rebuild_header,
-	.conn_request	= dccp_v6_conn_request,
-	.syn_recv_sock	= dccp_v6_request_recv_sock,
-	.net_header_len	= sizeof(struct iphdr),
-	.setsockopt	= ipv6_setsockopt,
-	.getsockopt	= ipv6_getsockopt,
+	.queue_xmit	   = ip_queue_xmit,
+	.send_check	   = dccp_v4_send_check,
+	.rebuild_header	   = inet_sk_rebuild_header,
+	.conn_request	   = dccp_v6_conn_request,
+	.syn_recv_sock	   = dccp_v6_request_recv_sock,
+	.net_header_len	   = sizeof(struct iphdr),
+	.setsockopt	   = ipv6_setsockopt,
+	.getsockopt	   = ipv6_getsockopt,
+	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
+	.sockaddr_len	   = sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_ipv6_setsockopt,
-	.compat_getsockopt	= compat_ipv6_getsockopt,
+	.compat_setsockopt = compat_ipv6_setsockopt,
+	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
-	.addr2sockaddr	= inet6_csk_addr2sockaddr,
-	.sockaddr_len	= sizeof(struct sockaddr_in6)
 };
 
 /* NOTE: A lot of things set to zero explicitly by call to
@@ -1166,33 +1166,33 @@ static int dccp_v6_destroy_sock(struct s
 }
 
 static struct proto dccp_v6_prot = {
-	.name		= "DCCPv6",
-	.owner		= THIS_MODULE,
-	.close		= dccp_close,
-	.connect	= dccp_v6_connect,
-	.disconnect	= dccp_disconnect,
-	.ioctl		= dccp_ioctl,
-	.init		= dccp_v6_init_sock,
-	.setsockopt	= dccp_setsockopt,
-	.getsockopt	= dccp_getsockopt,
+	.name		   = "DCCPv6",
+	.owner		   = THIS_MODULE,
+	.close		   = dccp_close,
+	.connect	   = dccp_v6_connect,
+	.disconnect	   = dccp_disconnect,
+	.ioctl		   = dccp_ioctl,
+	.init		   = dccp_v6_init_sock,
+	.setsockopt	   = dccp_setsockopt,
+	.getsockopt	   = dccp_getsockopt,
+	.sendmsg	   = dccp_sendmsg,
+	.recvmsg	   = dccp_recvmsg,
+	.backlog_rcv	   = dccp_v6_do_rcv,
+	.hash		   = dccp_v6_hash,
+	.unhash		   = dccp_unhash,
+	.accept		   = inet_csk_accept,
+	.get_port	   = dccp_v6_get_port,
+	.shutdown	   = dccp_shutdown,
+	.destroy	   = dccp_v6_destroy_sock,
+	.orphan_count	   = &dccp_orphan_count,
+	.max_header	   = MAX_DCCP_HEADER,
+	.obj_size	   = sizeof(struct dccp6_sock),
+	.rsk_prot	   = &dccp6_request_sock_ops,
+	.twsk_prot	   = &dccp6_timewait_sock_ops,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_dccp_setsockopt,
-	.compat_getsockopt	= compat_dccp_getsockopt,
+	.compat_setsockopt = compat_dccp_setsockopt,
+	.compat_getsockopt = compat_dccp_getsockopt,
 #endif
-	.sendmsg	= dccp_sendmsg,
-	.recvmsg	= dccp_recvmsg,
-	.backlog_rcv	= dccp_v6_do_rcv,
-	.hash		= dccp_v6_hash,
-	.unhash		= dccp_unhash,
-	.accept		= inet_csk_accept,
-	.get_port	= dccp_v6_get_port,
-	.shutdown	= dccp_shutdown,
-	.destroy	= dccp_v6_destroy_sock,
-	.orphan_count	= &dccp_orphan_count,
-	.max_header	= MAX_DCCP_HEADER,
-	.obj_size	= sizeof(struct dccp6_sock),
-	.rsk_prot	= &dccp6_request_sock_ops,
-	.twsk_prot	= &dccp6_timewait_sock_ops,
 };
 
 static struct inet6_protocol dccp_v6_protocol = {
@@ -1202,28 +1202,28 @@ static struct inet6_protocol dccp_v6_pro
 };
 
 static struct proto_ops inet6_dccp_ops = {
-	.family		= PF_INET6,
-	.owner		= THIS_MODULE,
-	.release	= inet6_release,
-	.bind		= inet6_bind,
-	.connect	= inet_stream_connect,
-	.socketpair	= sock_no_socketpair,
-	.accept		= inet_accept,
-	.getname	= inet6_getname,
-	.poll		= dccp_poll,
-	.ioctl		= inet6_ioctl,
-	.listen		= inet_dccp_listen,
-	.shutdown	= inet_shutdown,
-	.setsockopt	= sock_common_setsockopt,
-	.getsockopt	= sock_common_getsockopt,
+	.family		   = PF_INET6,
+	.owner		   = THIS_MODULE,
+	.release	   = inet6_release,
+	.bind		   = inet6_bind,
+	.connect	   = inet_stream_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = inet_accept,
+	.getname	   = inet6_getname,
+	.poll		   = dccp_poll,
+	.ioctl		   = inet6_ioctl,
+	.listen		   = inet_dccp_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg	= inet_sendmsg,
-	.recvmsg	= sock_common_recvmsg,
-	.mmap		= sock_no_mmap,
-	.sendpage	= sock_no_sendpage,
 };
 
 static struct inet_protosw dccp_v6_protosw = {
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 3e9b710..3292837 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -516,18 +516,19 @@ int dccp_setsockopt(struct sock *sk, int
 							     optlen);
 	return do_dccp_setsockopt(sk, level, optname, optval, optlen);
 }
+
 EXPORT_SYMBOL_GPL(dccp_setsockopt);
 
 #ifdef CONFIG_COMPAT
 int compat_dccp_setsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int optlen)
+			   char __user *optval, int optlen)
 {
 	if (level != SOL_DCCP)
 		return inet_csk_compat_setsockopt(sk, level, optname,
 						  optval, optlen);
-
 	return do_dccp_setsockopt(sk, level, optname, optval, optlen);
 }
+
 EXPORT_SYMBOL_GPL(compat_dccp_setsockopt);
 #endif
 
@@ -609,17 +610,19 @@ int dccp_getsockopt(struct sock *sk, int
 							     optlen);
 	return do_dccp_getsockopt(sk, level, optname, optval, optlen);
 }
+
 EXPORT_SYMBOL_GPL(dccp_getsockopt);
 
 #ifdef CONFIG_COMPAT
 int compat_dccp_getsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user *optlen)
+			   char __user *optval, int __user *optlen)
 {
 	if (level != SOL_DCCP)
 		return inet_csk_compat_getsockopt(sk, level, optname,
 						  optval, optlen);
 	return do_dccp_getsockopt(sk, level, optname, optval, optlen);
 }
+
 EXPORT_SYMBOL_GPL(compat_dccp_getsockopt);
 #endif
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 454e523..dc206f1 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -788,53 +788,53 @@ int inet_ioctl(struct socket *sock, unsi
 }
 
 const struct proto_ops inet_stream_ops = {
-	.family =	PF_INET,
-	.owner =	THIS_MODULE,
-	.release =	inet_release,
-	.bind =		inet_bind,
-	.connect =	inet_stream_connect,
-	.socketpair =	sock_no_socketpair,
-	.accept =	inet_accept,
-	.getname =	inet_getname,
-	.poll =		tcp_poll,
-	.ioctl =	inet_ioctl,
-	.listen =	inet_listen,
-	.shutdown =	inet_shutdown,
-	.setsockopt =	sock_common_setsockopt,
-	.getsockopt =	sock_common_getsockopt,
+	.family		   = PF_INET,
+	.owner		   = THIS_MODULE,
+	.release	   = inet_release,
+	.bind		   = inet_bind,
+	.connect	   = inet_stream_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = inet_accept,
+	.getname	   = inet_getname,
+	.poll		   = tcp_poll,
+	.ioctl		   = inet_ioctl,
+	.listen		   = inet_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = tcp_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg =	inet_sendmsg,
-	.recvmsg =	sock_common_recvmsg,
-	.mmap =		sock_no_mmap,
-	.sendpage =	tcp_sendpage
 };
 
 const struct proto_ops inet_dgram_ops = {
-	.family =	PF_INET,
-	.owner =	THIS_MODULE,
-	.release =	inet_release,
-	.bind =		inet_bind,
-	.connect =	inet_dgram_connect,
-	.socketpair =	sock_no_socketpair,
-	.accept =	sock_no_accept,
-	.getname =	inet_getname,
-	.poll =		udp_poll,
-	.ioctl =	inet_ioctl,
-	.listen =	sock_no_listen,
-	.shutdown =	inet_shutdown,
-	.setsockopt =	sock_common_setsockopt,
-	.getsockopt =	sock_common_getsockopt,
+	.family		   = PF_INET,
+	.owner		   = THIS_MODULE,
+	.release	   = inet_release,
+	.bind		   = inet_bind,
+	.connect	   = inet_dgram_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = inet_getname,
+	.poll		   = udp_poll,
+	.ioctl		   = inet_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg =	inet_sendmsg,
-	.recvmsg =	sock_common_recvmsg,
-	.mmap =		sock_no_mmap,
-	.sendpage =	inet_sendpage,
 };
 
 /*
@@ -842,28 +842,28 @@ const struct proto_ops inet_dgram_ops = 
  * udp_poll
  */
 static const struct proto_ops inet_sockraw_ops = {
-	.family =	PF_INET,
-	.owner =	THIS_MODULE,
-	.release =	inet_release,
-	.bind =		inet_bind,
-	.connect =	inet_dgram_connect,
-	.socketpair =	sock_no_socketpair,
-	.accept =	sock_no_accept,
-	.getname =	inet_getname,
-	.poll =		datagram_poll,
-	.ioctl =	inet_ioctl,
-	.listen =	sock_no_listen,
-	.shutdown =	inet_shutdown,
-	.setsockopt =	sock_common_setsockopt,
-	.getsockopt =	sock_common_getsockopt,
+	.family		   = PF_INET,
+	.owner		   = THIS_MODULE,
+	.release	   = inet_release,
+	.bind		   = inet_bind,
+	.connect	   = inet_dgram_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = inet_getname,
+	.poll		   = datagram_poll,
+	.ioctl		   = inet_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = inet_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg =	inet_sendmsg,
-	.recvmsg =	sock_common_recvmsg,
-	.mmap =		sock_no_mmap,
-	.sendpage =	inet_sendpage,
 };
 
 static struct net_proto_family inet_family_ops = {
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 49ff1cd..12e0bf1 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -910,8 +910,8 @@ int ip_setsockopt(struct sock *sk, int l
 }
 
 #ifdef CONFIG_COMPAT
-int compat_ip_setsockopt(struct sock *sk, int level,
-		int optname, char __user *optval, int optlen)
+int compat_ip_setsockopt(struct sock *sk, int level, int optname,
+			 char __user *optval, int optlen)
 {
 	int err;
 
@@ -922,19 +922,21 @@ int compat_ip_setsockopt(struct sock *sk
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err = -ENOPROTOOPT && optname != IP_HDRINCL &&
-		optname != IP_IPSEC_POLICY && optname != IP_XFRM_POLICY
+	    optname != IP_IPSEC_POLICY && optname != IP_XFRM_POLICY
 #ifdef CONFIG_IP_MROUTE
-		&& (optname < MRT_BASE || optname > (MRT_BASE + 10))
+	    && (optname < MRT_BASE || optname > (MRT_BASE + 10))
 #endif
 	   ) {
 		lock_sock(sk);
-		err = compat_nf_setsockopt(sk, PF_INET,
-				optname, optval, optlen);
+		err = compat_nf_setsockopt(sk, PF_INET, optname,
+					   optval, optlen);
 		release_sock(sk);
 	}
 #endif
 	return err;
 }
+
+EXPORT_SYMBOL(compat_ip_setsockopt);
 #endif
 
 /*
@@ -1180,27 +1182,24 @@ int ip_getsockopt(struct sock *sk, int l
 }
 
 #ifdef CONFIG_COMPAT
-int compat_ip_getsockopt(struct sock *sk, int level,
-		int optname, char __user *optval, int __user *optlen)
+int compat_ip_getsockopt(struct sock *sk, int level, int optname,
+			 char __user *optval, int __user *optlen)
 {
-	int err;
-
-	err = do_ip_getsockopt(sk, level, optname, optval, optlen);
+	int err = do_ip_getsockopt(sk, level, optname, optval, optlen);
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err = -ENOPROTOOPT && optname != IP_PKTOPTIONS
 #ifdef CONFIG_IP_MROUTE
-		&& (optname < MRT_BASE || optname > MRT_BASE+10)
+	    && (optname < MRT_BASE || optname > MRT_BASE+10)
 #endif
 	   ) {
 	   	int len;
 
-		if(get_user(len,optlen))
+		if (get_user(len, optlen))
 			return -EFAULT;
 
 		lock_sock(sk);
-		err = compat_nf_getsockopt(sk, PF_INET,
-				optname, optval, &len);
+		err = compat_nf_getsockopt(sk, PF_INET, optname, optval, &len);
 		release_sock(sk);
 		if (err >= 0)
 			err = put_user(len, optlen);
@@ -1209,13 +1208,11 @@ int compat_ip_getsockopt(struct sock *sk
 #endif
 	return err;
 }
+
+EXPORT_SYMBOL(compat_ip_getsockopt);
 #endif
 
 EXPORT_SYMBOL(ip_cmsg_recv);
 
 EXPORT_SYMBOL(ip_getsockopt);
 EXPORT_SYMBOL(ip_setsockopt);
-#ifdef CONFIG_COMPAT
-EXPORT_SYMBOL(compat_ip_getsockopt);
-EXPORT_SYMBOL(compat_ip_setsockopt);
-#endif
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index f1b02b3..fc25624 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -682,11 +682,10 @@ static int raw_setsockopt(struct sock *s
 
 #ifdef CONFIG_COMPAT
 static int compat_raw_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
+				 char __user *optval, int optlen)
 {
 	if (level != SOL_RAW)
-		return compat_ip_setsockopt(sk, level,
-				optname, optval, optlen);
+		return compat_ip_setsockopt(sk, level, optname, optval, optlen);
 	return do_raw_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -713,11 +712,10 @@ static int raw_getsockopt(struct sock *s
 
 #ifdef CONFIG_COMPAT
 static int compat_raw_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+				 char __user *optval, int __user *optlen)
 {
 	if (level != SOL_RAW)
-		return compat_ip_getsockopt(sk, level,
-				optname, optval, optlen);
+		return compat_ip_getsockopt(sk, level, optname, optval, optlen);
 	return do_raw_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -751,26 +749,26 @@ static int raw_ioctl(struct sock *sk, in
 }
 
 struct proto raw_prot = {
-	.name =		"RAW",
-	.owner =	THIS_MODULE,
-	.close =	raw_close,
-	.connect =	ip4_datagram_connect,
-	.disconnect =	udp_disconnect,
-	.ioctl =	raw_ioctl,
-	.init =		raw_init,
-	.setsockopt =	raw_setsockopt,
-	.getsockopt =	raw_getsockopt,
+	.name		   = "RAW",
+	.owner		   = THIS_MODULE,
+	.close		   = raw_close,
+	.connect	   = ip4_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = raw_ioctl,
+	.init		   = raw_init,
+	.setsockopt	   = raw_setsockopt,
+	.getsockopt	   = raw_getsockopt,
+	.sendmsg	   = raw_sendmsg,
+	.recvmsg	   = raw_recvmsg,
+	.bind		   = raw_bind,
+	.backlog_rcv	   = raw_rcv_skb,
+	.hash		   = raw_v4_hash,
+	.unhash		   = raw_v4_unhash,
+	.obj_size	   = sizeof(struct raw_sock),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt =	compat_raw_setsockopt,
-	.compat_getsockopt =	compat_raw_getsockopt,
+	.compat_setsockopt = compat_raw_setsockopt,
+	.compat_getsockopt = compat_raw_getsockopt,
 #endif
-	.sendmsg =	raw_sendmsg,
-	.recvmsg =	raw_recvmsg,
-	.bind =		raw_bind,
-	.backlog_rcv =	raw_rcv_skb,
-	.hash =		raw_v4_hash,
-	.unhash =	raw_v4_unhash,
-	.obj_size =	sizeof(struct raw_sock),
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 89da253..4b0272c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1879,14 +1879,16 @@ int tcp_setsockopt(struct sock *sk, int 
 }
 
 #ifdef CONFIG_COMPAT
-int compat_tcp_setsockopt(struct sock *sk, int level,
-		int optname, char __user *optval, int optlen)
+int compat_tcp_setsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, int optlen)
 {
 	if (level != SOL_TCP)
 		return inet_csk_compat_setsockopt(sk, level, optname,
 						  optval, optlen);
 	return do_tcp_setsockopt(sk, level, optname, optval, optlen);
 }
+
+EXPORT_SYMBOL(compat_tcp_setsockopt);
 #endif
 
 /* Return information about state of tcp endpoint in API format. */
@@ -2051,14 +2053,16 @@ int tcp_getsockopt(struct sock *sk, int 
 }
 
 #ifdef CONFIG_COMPAT
-int compat_tcp_getsockopt(struct sock *sk, int level,
-		int optname, char __user *optval, int __user *optlen)
+int compat_tcp_getsockopt(struct sock *sk, int level, int optname,
+			  char __user *optval, int __user *optlen)
 {
 	if (level != SOL_TCP)
 		return inet_csk_compat_getsockopt(sk, level, optname,
 						  optval, optlen);
 	return do_tcp_getsockopt(sk, level, optname, optval, optlen);
 }
+
+EXPORT_SYMBOL(compat_tcp_getsockopt);
 #endif
 
 extern void __skb_cb_too_small_for_tcp(int, int);
@@ -2177,7 +2181,3 @@ EXPORT_SYMBOL(tcp_sendpage);
 EXPORT_SYMBOL(tcp_setsockopt);
 EXPORT_SYMBOL(tcp_shutdown);
 EXPORT_SYMBOL(tcp_statistics);
-#ifdef CONFIG_COMPAT
-EXPORT_SYMBOL(compat_tcp_setsockopt);
-EXPORT_SYMBOL(compat_tcp_getsockopt);
-#endif
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 249ef6c..9e85c04 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1217,21 +1217,21 @@ int tcp_v4_tw_remember_stamp(struct inet
 }
 
 struct inet_connection_sock_af_ops ipv4_specific = {
-	.queue_xmit	=	ip_queue_xmit,
-	.send_check	=	tcp_v4_send_check,
-	.rebuild_header	=	inet_sk_rebuild_header,
-	.conn_request	=	tcp_v4_conn_request,
-	.syn_recv_sock	=	tcp_v4_syn_recv_sock,
-	.remember_stamp	=	tcp_v4_remember_stamp,
-	.net_header_len	=	sizeof(struct iphdr),
-	.setsockopt	=	ip_setsockopt,
-	.getsockopt	=	ip_getsockopt,
+	.queue_xmit	   = ip_queue_xmit,
+	.send_check	   = tcp_v4_send_check,
+	.rebuild_header	   = inet_sk_rebuild_header,
+	.conn_request	   = tcp_v4_conn_request,
+	.syn_recv_sock	   = tcp_v4_syn_recv_sock,
+	.remember_stamp	   = tcp_v4_remember_stamp,
+	.net_header_len	   = sizeof(struct iphdr),
+	.setsockopt	   = ip_setsockopt,
+	.getsockopt	   = ip_getsockopt,
+	.addr2sockaddr	   = inet_csk_addr2sockaddr,
+	.sockaddr_len	   = sizeof(struct sockaddr_in),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt =	compat_ip_setsockopt,
-	.compat_getsockopt =	compat_ip_getsockopt,
+	.compat_setsockopt = compat_ip_setsockopt,
+	.compat_getsockopt = compat_ip_getsockopt,
 #endif
-	.addr2sockaddr	=	inet_csk_addr2sockaddr,
-	.sockaddr_len	=	sizeof(struct sockaddr_in),
 };
 
 /* NOTE: A lot of things set to zero explicitly by call to
@@ -1812,10 +1812,6 @@ struct proto tcp_prot = {
 	.shutdown		= tcp_shutdown,
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
-#ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_tcp_setsockopt,
-	.compat_getsockopt	= compat_tcp_getsockopt,
-#endif
 	.sendmsg		= tcp_sendmsg,
 	.recvmsg		= tcp_recvmsg,
 	.backlog_rcv		= tcp_v4_do_rcv,
@@ -1834,6 +1830,10 @@ struct proto tcp_prot = {
 	.obj_size		= sizeof(struct tcp_sock),
 	.twsk_prot		= &tcp_timewait_sock_ops,
 	.rsk_prot		= &tcp_request_sock_ops,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt	= compat_tcp_setsockopt,
+	.compat_getsockopt	= compat_tcp_getsockopt,
+#endif
 };
 
 void __init tcp_v4_init(struct net_proto_family *ops)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 0b0721b..3f93292 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1263,11 +1263,10 @@ static int udp_setsockopt(struct sock *s
 
 #ifdef CONFIG_COMPAT
 static int compat_udp_setsockopt(struct sock *sk, int level, int optname,
-		char __user *optval, int optlen)
+				 char __user *optval, int optlen)
 {
 	if (level != SOL_UDP)
-		return compat_ip_setsockopt(sk, level,
-				optname, optval, optlen);
+		return compat_ip_setsockopt(sk, level, optname, optval, optlen);
 	return do_udp_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -1316,11 +1315,10 @@ static int udp_getsockopt(struct sock *s
 
 #ifdef CONFIG_COMPAT
 static int compat_udp_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+				 char __user *optval, int __user *optlen)
 {
 	if (level != SOL_UDP)
-		return compat_ip_getsockopt(sk, level,
-				optname, optval, optlen);
+		return compat_ip_getsockopt(sk, level, optname, optval, optlen);
 	return do_udp_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -1372,27 +1370,27 @@ unsigned int udp_poll(struct file *file,
 }
 
 struct proto udp_prot = {
- 	.name =		"UDP",
-	.owner =	THIS_MODULE,
-	.close =	udp_close,
-	.connect =	ip4_datagram_connect,
-	.disconnect =	udp_disconnect,
-	.ioctl =	udp_ioctl,
-	.destroy =	udp_destroy_sock,
-	.setsockopt =	udp_setsockopt,
-	.getsockopt =	udp_getsockopt,
+ 	.name		   = "UDP",
+	.owner		   = THIS_MODULE,
+	.close		   = udp_close,
+	.connect	   = ip4_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = udp_ioctl,
+	.destroy	   = udp_destroy_sock,
+	.setsockopt	   = udp_setsockopt,
+	.getsockopt	   = udp_getsockopt,
+	.sendmsg	   = udp_sendmsg,
+	.recvmsg	   = udp_recvmsg,
+	.sendpage	   = udp_sendpage,
+	.backlog_rcv	   = udp_queue_rcv_skb,
+	.hash		   = udp_v4_hash,
+	.unhash		   = udp_v4_unhash,
+	.get_port	   = udp_v4_get_port,
+	.obj_size	   = sizeof(struct udp_sock),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt =	compat_udp_setsockopt,
-	.compat_getsockopt =	compat_udp_getsockopt,
+	.compat_setsockopt = compat_udp_setsockopt,
+	.compat_getsockopt = compat_udp_getsockopt,
 #endif
-	.sendmsg =	udp_sendmsg,
-	.recvmsg =	udp_recvmsg,
-	.sendpage =	udp_sendpage,
-	.backlog_rcv =	udp_queue_rcv_skb,
-	.hash =		udp_v4_hash,
-	.unhash =	udp_v4_unhash,
-	.get_port =	udp_v4_get_port,
-	.obj_size =	sizeof(struct udp_sock),
 };
 
 /* ------------------------------------------------------------------------ */
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 97844c4..bc8d196 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -456,53 +456,53 @@ int inet6_ioctl(struct socket *sock, uns
 }
 
 const struct proto_ops inet6_stream_ops = {
-	.family =	PF_INET6,
-	.owner =	THIS_MODULE,
-	.release =	inet6_release,
-	.bind =		inet6_bind,
-	.connect =	inet_stream_connect,		/* ok		*/
-	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
-	.accept =	inet_accept,			/* ok		*/
-	.getname =	inet6_getname, 
-	.poll =		tcp_poll,			/* ok		*/
-	.ioctl =	inet6_ioctl,			/* must change  */
-	.listen =	inet_listen,			/* ok		*/
-	.shutdown =	inet_shutdown,			/* ok		*/
-	.setsockopt =	sock_common_setsockopt,		/* ok		*/
-	.getsockopt =	sock_common_getsockopt,		/* ok		*/
+	.family		   = PF_INET6,
+	.owner		   = THIS_MODULE,
+	.release	   = inet6_release,
+	.bind		   = inet6_bind,
+	.connect	   = inet_stream_connect,	/* ok		*/
+	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
+	.accept		   = inet_accept,		/* ok		*/
+	.getname	   = inet6_getname, 
+	.poll		   = tcp_poll,			/* ok		*/
+	.ioctl		   = inet6_ioctl,		/* must change  */
+	.listen		   = inet_listen,		/* ok		*/
+	.shutdown	   = inet_shutdown,		/* ok		*/
+	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
+	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
+	.sendmsg	   = inet_sendmsg,		/* ok		*/
+	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = tcp_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg =	inet_sendmsg,			/* ok		*/
-	.recvmsg =	sock_common_recvmsg,		/* ok		*/
-	.mmap =		sock_no_mmap,
-	.sendpage =	tcp_sendpage
 };
 
 const struct proto_ops inet6_dgram_ops = {
-	.family =	PF_INET6,
-	.owner =	THIS_MODULE,
-	.release =	inet6_release,
-	.bind =		inet6_bind,
-	.connect =	inet_dgram_connect,		/* ok		*/
-	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
-	.accept =	sock_no_accept,			/* a do nothing	*/
-	.getname =	inet6_getname, 
-	.poll =		udp_poll,			/* ok		*/
-	.ioctl =	inet6_ioctl,			/* must change  */
-	.listen =	sock_no_listen,			/* ok		*/
-	.shutdown =	inet_shutdown,			/* ok		*/
-	.setsockopt =	sock_common_setsockopt,		/* ok		*/
-	.getsockopt =	sock_common_getsockopt,		/* ok		*/
+	.family		   = PF_INET6,
+	.owner		   = THIS_MODULE,
+	.release	   = inet6_release,
+	.bind		   = inet6_bind,
+	.connect	   = inet_dgram_connect,	/* ok		*/
+	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
+	.accept		   = sock_no_accept,		/* a do nothing	*/
+	.getname	   = inet6_getname, 
+	.poll		   = udp_poll,			/* ok		*/
+	.ioctl		   = inet6_ioctl,		/* must change  */
+	.listen		   = sock_no_listen,		/* ok		*/
+	.shutdown	   = inet_shutdown,		/* ok		*/
+	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
+	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
+	.sendmsg	   = inet_sendmsg,		/* ok		*/
+	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg =	inet_sendmsg,			/* ok		*/
-	.recvmsg =	sock_common_recvmsg,		/* ok		*/
-	.mmap =		sock_no_mmap,
-	.sendpage =	sock_no_sendpage,
 };
 
 static struct net_proto_family inet6_family_ops = {
@@ -513,28 +513,28 @@ static struct net_proto_family inet6_fam
 
 /* Same as inet6_dgram_ops, sans udp_poll.  */
 static const struct proto_ops inet6_sockraw_ops = {
-	.family =	PF_INET6,
-	.owner =	THIS_MODULE,
-	.release =	inet6_release,
-	.bind =		inet6_bind,
-	.connect =	inet_dgram_connect,		/* ok		*/
-	.socketpair =	sock_no_socketpair,		/* a do nothing	*/
-	.accept =	sock_no_accept,			/* a do nothing	*/
-	.getname =	inet6_getname, 
-	.poll =		datagram_poll,			/* ok		*/
-	.ioctl =	inet6_ioctl,			/* must change  */
-	.listen =	sock_no_listen,			/* ok		*/
-	.shutdown =	inet_shutdown,			/* ok		*/
-	.setsockopt =	sock_common_setsockopt,		/* ok		*/
-	.getsockopt =	sock_common_getsockopt,		/* ok		*/
+	.family		   = PF_INET6,
+	.owner		   = THIS_MODULE,
+	.release	   = inet6_release,
+	.bind		   = inet6_bind,
+	.connect	   = inet_dgram_connect,	/* ok		*/
+	.socketpair	   = sock_no_socketpair,	/* a do nothing	*/
+	.accept		   = sock_no_accept,		/* a do nothing	*/
+	.getname	   = inet6_getname, 
+	.poll		   = datagram_poll,		/* ok		*/
+	.ioctl		   = inet6_ioctl,		/* must change  */
+	.listen		   = sock_no_listen,		/* ok		*/
+	.shutdown	   = inet_shutdown,		/* ok		*/
+	.setsockopt	   = sock_common_setsockopt,	/* ok		*/
+	.getsockopt	   = sock_common_getsockopt,	/* ok		*/
+	.sendmsg	   = inet_sendmsg,		/* ok		*/
+	.recvmsg	   = sock_common_recvmsg,	/* ok		*/
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg =	inet_sendmsg,			/* ok		*/
-	.recvmsg =	sock_common_recvmsg,		/* ok		*/
-	.mmap =		sock_no_mmap,
-	.sendpage =	sock_no_sendpage,
 };
 
 static struct inet_protosw rawv6_protosw = {
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 988eac5..602feec 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -645,17 +645,15 @@ int ipv6_setsockopt(struct sock *sk, int
 
 #ifdef CONFIG_COMPAT
 int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int optlen)
+			   char __user *optval, int optlen)
 {
 	int err;
 
 	if (level = SOL_IP && sk->sk_type != SOCK_RAW) {
-		if (udp_prot.compat_setsockopt)
-			return udp_prot.compat_setsockopt(sk, level,
-					optname, optval, optlen);
-		else
-			return udp_prot.setsockopt(sk, level,
-					optname, optval, optlen);
+		if (udp_prot.compat_setsockopt != NULL)
+			return udp_prot.compat_setsockopt(sk, level, optname,
+							  optval, optlen);
+		return udp_prot.setsockopt(sk, level, optname, optval, optlen);
 	}
 
 	if (level != SOL_IPV6)
@@ -665,15 +663,17 @@ int compat_ipv6_setsockopt(struct sock *
 #ifdef CONFIG_NETFILTER
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err = -ENOPROTOOPT && optname != IPV6_IPSEC_POLICY &&
-			optname != IPV6_XFRM_POLICY) {
+	    optname != IPV6_XFRM_POLICY) {
 		lock_sock(sk);
-		err = compat_nf_setsockopt(sk, PF_INET6, optname, optval,
-				optlen);
+		err = compat_nf_setsockopt(sk, PF_INET6, optname,
+					   optval, optlen);
 		release_sock(sk);
 	}
 #endif
 	return err;
 }
+
+EXPORT_SYMBOL(compat_ipv6_setsockopt);
 #endif
 
 static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_opt_hdr *hdr,
@@ -927,20 +927,18 @@ int ipv6_getsockopt(struct sock *sk, int
 
 #ifdef CONFIG_COMPAT
 int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
-		    char __user *optval, int __user *optlen)
+			   char __user *optval, int __user *optlen)
 {
 	int err;
 
 	if (level = SOL_IP && sk->sk_type != SOCK_RAW) {
-		if (udp_prot.compat_getsockopt)
-			return udp_prot.compat_getsockopt(sk, level,
-					optname, optval, optlen);
-		else
-			return udp_prot.getsockopt(sk, level,
-					optname, optval, optlen);
+		if (udp_prot.compat_getsockopt != NULL)
+			return udp_prot.compat_getsockopt(sk, level, optname,
+							  optval, optlen);
+		return udp_prot.getsockopt(sk, level, optname, optval, optlen);
 	}
 
-	if(level != SOL_IPV6)
+	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen);
@@ -954,8 +952,8 @@ int compat_ipv6_getsockopt(struct sock *
 			return -EFAULT;
 
 		lock_sock(sk);
-		err = compat_nf_getsockopt(sk, PF_INET6, optname, optval,
-				&len);
+		err = compat_nf_getsockopt(sk, PF_INET6,
+					   optname, optval, &len);
 		release_sock(sk);
 		if (err >= 0)
 			err = put_user(len, optlen);
@@ -963,6 +961,8 @@ int compat_ipv6_getsockopt(struct sock *
 #endif
 	return err;
 }
+
+EXPORT_SYMBOL(compat_ipv6_getsockopt);
 #endif
 
 void __init ipv6_packet_init(void)
diff --git a/net/ipv6/ipv6_syms.c b/net/ipv6/ipv6_syms.c
index 61419e1..1648278 100644
--- a/net/ipv6/ipv6_syms.c
+++ b/net/ipv6/ipv6_syms.c
@@ -18,10 +18,6 @@ EXPORT_SYMBOL(ip6_route_output);
 EXPORT_SYMBOL(addrconf_lock);
 EXPORT_SYMBOL(ipv6_setsockopt);
 EXPORT_SYMBOL(ipv6_getsockopt);
-#ifdef CONFIG_COMPAT
-EXPORT_SYMBOL(compat_ipv6_setsockopt);
-EXPORT_SYMBOL(compat_ipv6_getsockopt);
-#endif
 EXPORT_SYMBOL(inet6_register_protosw);
 EXPORT_SYMBOL(inet6_unregister_protosw);
 EXPORT_SYMBOL(inet6_add_protocol);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 8de5a8e..0f63078 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -913,23 +913,21 @@ static int rawv6_setsockopt(struct sock 
 
 #ifdef CONFIG_COMPAT
 static int compat_rawv6_setsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int optlen)
+				   char __user *optval, int optlen)
 {
-	switch(level) {
-		case SOL_RAW:
+	switch (level) {
+	case SOL_RAW:
+		break;
+	case SOL_ICMPV6:
+		if (inet_sk(sk)->num != IPPROTO_ICMPV6)
+			return -EOPNOTSUPP;
+		return rawv6_seticmpfilter(sk, level, optname, optval, optlen);
+	case SOL_IPV6:
+		if (optname = IPV6_CHECKSUM)
 			break;
-
-		case SOL_ICMPV6:
-			if (inet_sk(sk)->num != IPPROTO_ICMPV6)
-				return -EOPNOTSUPP;
-			return rawv6_seticmpfilter(sk, level, optname, optval,
-						   optlen);
-		case SOL_IPV6:
-			if (optname = IPV6_CHECKSUM)
-				break;
-		default:
-			return compat_ipv6_setsockopt(sk, level,
-					optname, optval, optlen);
+	default:
+		return compat_ipv6_setsockopt(sk, level, optname,
+					      optval, optlen);
 	};
 	return do_rawv6_setsockopt(sk, level, optname, optval, optlen);
 }
@@ -989,23 +987,21 @@ static int rawv6_getsockopt(struct sock 
 
 #ifdef CONFIG_COMPAT
 static int compat_rawv6_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+				   char __user *optval, int __user *optlen)
 {
-	switch(level) {
-		case SOL_RAW:
+	switch (level) {
+	case SOL_RAW:
+		break;
+	case SOL_ICMPV6:
+		if (inet_sk(sk)->num != IPPROTO_ICMPV6)
+			return -EOPNOTSUPP;
+		return rawv6_geticmpfilter(sk, level, optname, optval, optlen);
+	case SOL_IPV6:
+		if (optname = IPV6_CHECKSUM)
 			break;
-
-		case SOL_ICMPV6:
-			if (inet_sk(sk)->num != IPPROTO_ICMPV6)
-				return -EOPNOTSUPP;
-			return rawv6_geticmpfilter(sk, level, optname, optval,
-						   optlen);
-		case SOL_IPV6:
-			if (optname = IPV6_CHECKSUM)
-				break;
-		default:
-			return compat_ipv6_getsockopt(sk, level,
-					optname, optval, optlen);
+	default:
+		return compat_ipv6_getsockopt(sk, level, optname,
+					      optval, optlen);
 	};
 	return do_rawv6_getsockopt(sk, level, optname, optval, optlen);
 }
@@ -1056,27 +1052,27 @@ static int rawv6_init_sk(struct sock *sk
 }
 
 struct proto rawv6_prot = {
-	.name =		"RAWv6",
-	.owner =	THIS_MODULE,
-	.close =	rawv6_close,
-	.connect =	ip6_datagram_connect,
-	.disconnect =	udp_disconnect,
-	.ioctl =	rawv6_ioctl,
-	.init =		rawv6_init_sk,
-	.destroy =	inet6_destroy_sock,
-	.setsockopt =	rawv6_setsockopt,
-	.getsockopt =	rawv6_getsockopt,
+	.name		   = "RAWv6",
+	.owner		   = THIS_MODULE,
+	.close		   = rawv6_close,
+	.connect	   = ip6_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = rawv6_ioctl,
+	.init		   = rawv6_init_sk,
+	.destroy	   = inet6_destroy_sock,
+	.setsockopt	   = rawv6_setsockopt,
+	.getsockopt	   = rawv6_getsockopt,
+	.sendmsg	   = rawv6_sendmsg,
+	.recvmsg	   = rawv6_recvmsg,
+	.bind		   = rawv6_bind,
+	.backlog_rcv	   = rawv6_rcv_skb,
+	.hash		   = raw_v6_hash,
+	.unhash		   = raw_v6_unhash,
+	.obj_size	   = sizeof(struct raw6_sock),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt =	compat_rawv6_setsockopt,
-	.compat_getsockopt =	compat_rawv6_getsockopt,
+	.compat_setsockopt = compat_rawv6_setsockopt,
+	.compat_getsockopt = compat_rawv6_getsockopt,
 #endif
-	.sendmsg =	rawv6_sendmsg,
-	.recvmsg =	rawv6_recvmsg,
-	.bind =		rawv6_bind,
-	.backlog_rcv =	rawv6_rcv_skb,
-	.hash =		raw_v6_hash,
-	.unhash =	raw_v6_unhash,
-	.obj_size =	sizeof(struct raw6_sock),
 };
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 2f8975e..301eee7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1298,22 +1298,21 @@ static int tcp_v6_remember_stamp(struct 
 }
 
 static struct inet_connection_sock_af_ops ipv6_specific = {
-	.queue_xmit	=	inet6_csk_xmit,
-	.send_check	=	tcp_v6_send_check,
-	.rebuild_header	=	inet6_sk_rebuild_header,
-	.conn_request	=	tcp_v6_conn_request,
-	.syn_recv_sock	=	tcp_v6_syn_recv_sock,
-	.remember_stamp	=	tcp_v6_remember_stamp,
-	.net_header_len	=	sizeof(struct ipv6hdr),
-
-	.setsockopt	=	ipv6_setsockopt,
-	.getsockopt	=	ipv6_getsockopt,
+	.queue_xmit	   = inet6_csk_xmit,
+	.send_check	   = tcp_v6_send_check,
+	.rebuild_header	   = inet6_sk_rebuild_header,
+	.conn_request	   = tcp_v6_conn_request,
+	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
+	.remember_stamp	   = tcp_v6_remember_stamp,
+	.net_header_len	   = sizeof(struct ipv6hdr),
+	.setsockopt	   = ipv6_setsockopt,
+	.getsockopt	   = ipv6_getsockopt,
+	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
+	.sockaddr_len	   = sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_ipv6_setsockopt,
-	.compat_getsockopt	= compat_ipv6_getsockopt,
+	.compat_setsockopt = compat_ipv6_setsockopt,
+	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
-	.addr2sockaddr	=	inet6_csk_addr2sockaddr,
-	.sockaddr_len	=	sizeof(struct sockaddr_in6)
 };
 
 /*
@@ -1321,26 +1320,23 @@ static struct inet_connection_sock_af_op
  */
 
 static struct inet_connection_sock_af_ops ipv6_mapped = {
-	.queue_xmit	=	ip_queue_xmit,
-	.send_check	=	tcp_v4_send_check,
-	.rebuild_header	=	inet_sk_rebuild_header,
-	.conn_request	=	tcp_v6_conn_request,
-	.syn_recv_sock	=	tcp_v6_syn_recv_sock,
-	.remember_stamp	=	tcp_v4_remember_stamp,
-	.net_header_len	=	sizeof(struct iphdr),
-
-	.setsockopt	=	ipv6_setsockopt,
-	.getsockopt	=	ipv6_getsockopt,
+	.queue_xmit	   = ip_queue_xmit,
+	.send_check	   = tcp_v4_send_check,
+	.rebuild_header	   = inet_sk_rebuild_header,
+	.conn_request	   = tcp_v6_conn_request,
+	.syn_recv_sock	   = tcp_v6_syn_recv_sock,
+	.remember_stamp	   = tcp_v4_remember_stamp,
+	.net_header_len	   = sizeof(struct iphdr),
+	.setsockopt	   = ipv6_setsockopt,
+	.getsockopt	   = ipv6_getsockopt,
+	.addr2sockaddr	   = inet6_csk_addr2sockaddr,
+	.sockaddr_len	   = sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_ipv6_setsockopt,
-	.compat_getsockopt	= compat_ipv6_getsockopt,
+	.compat_setsockopt = compat_ipv6_setsockopt,
+	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
-	.addr2sockaddr	=	inet6_csk_addr2sockaddr,
-	.sockaddr_len	=	sizeof(struct sockaddr_in6)
 };
 
-
-
 /* NOTE: A lot of things set to zero explicitly by call to
  *       sk_alloc() so need not be done here.
  */
@@ -1574,10 +1570,6 @@ struct proto tcpv6_prot = {
 	.shutdown		= tcp_shutdown,
 	.setsockopt		= tcp_setsockopt,
 	.getsockopt		= tcp_getsockopt,
-#ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_tcp_setsockopt,
-	.compat_getsockopt	= compat_tcp_getsockopt,
-#endif
 	.sendmsg		= tcp_sendmsg,
 	.recvmsg		= tcp_recvmsg,
 	.backlog_rcv		= tcp_v6_do_rcv,
@@ -1596,6 +1588,10 @@ struct proto tcpv6_prot = {
 	.obj_size		= sizeof(struct tcp6_sock),
 	.twsk_prot		= &tcp6_timewait_sock_ops,
 	.rsk_prot		= &tcp6_request_sock_ops,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt	= compat_tcp_setsockopt,
+	.compat_getsockopt	= compat_tcp_getsockopt,
+#endif
 };
 
 static struct inet6_protocol tcpv6_protocol = {
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 538ada0..8d3432a 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -934,11 +934,11 @@ static int udpv6_setsockopt(struct sock 
 
 #ifdef CONFIG_COMPAT
 static int compat_udpv6_setsockopt(struct sock *sk, int level, int optname,
-		char __user *optval, int optlen)
+				   char __user *optval, int optlen)
 {
 	if (level != SOL_UDP)
-		return compat_ipv6_setsockopt(sk, level,
-				optname, optval, optlen);
+		return compat_ipv6_setsockopt(sk, level, optname,
+					      optval, optlen);
 	return do_udpv6_setsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -987,11 +987,11 @@ static int udpv6_getsockopt(struct sock 
 
 #ifdef CONFIG_COMPAT
 static int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
-			  char __user *optval, int __user *optlen)
+				   char __user *optval, int __user *optlen)
 {
 	if (level != SOL_UDP)
-		return compat_ipv6_getsockopt(sk, level,
-				optname, optval, optlen);
+		return compat_ipv6_getsockopt(sk, level, optname,
+					      optval, optlen);
 	return do_udpv6_getsockopt(sk, level, optname, optval, optlen);
 }
 #endif
@@ -1069,26 +1069,26 @@ void udp6_proc_exit(void) {
 /* ------------------------------------------------------------------------ */
 
 struct proto udpv6_prot = {
-	.name =		"UDPv6",
-	.owner =	THIS_MODULE,
-	.close =	udpv6_close,
-	.connect =	ip6_datagram_connect,
-	.disconnect =	udp_disconnect,
-	.ioctl =	udp_ioctl,
-	.destroy =	udpv6_destroy_sock,
-	.setsockopt =	udpv6_setsockopt,
-	.getsockopt =	udpv6_getsockopt,
+	.name		   = "UDPv6",
+	.owner		   = THIS_MODULE,
+	.close		   = udpv6_close,
+	.connect	   = ip6_datagram_connect,
+	.disconnect	   = udp_disconnect,
+	.ioctl		   = udp_ioctl,
+	.destroy	   = udpv6_destroy_sock,
+	.setsockopt	   = udpv6_setsockopt,
+	.getsockopt	   = udpv6_getsockopt,
+	.sendmsg	   = udpv6_sendmsg,
+	.recvmsg	   = udpv6_recvmsg,
+	.backlog_rcv	   = udpv6_queue_rcv_skb,
+	.hash		   = udp_v6_hash,
+	.unhash		   = udp_v6_unhash,
+	.get_port	   = udp_v6_get_port,
+	.obj_size	   = sizeof(struct udp6_sock),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt =	compat_udpv6_setsockopt,
-	.compat_getsockopt =	compat_udpv6_getsockopt,
+	.compat_setsockopt = compat_udpv6_setsockopt,
+	.compat_getsockopt = compat_udpv6_getsockopt,
 #endif
-	.sendmsg =	udpv6_sendmsg,
-	.recvmsg =	udpv6_recvmsg,
-	.backlog_rcv =	udpv6_queue_rcv_skb,
-	.hash =		udp_v6_hash,
-	.unhash =	udp_v6_unhash,
-	.get_port =	udp_v6_get_port,
-	.obj_size =	sizeof(struct udp6_sock),
 };
 
 static struct inet_protosw udpv6_protosw = {
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index da1cd48..0a63d7d 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -133,7 +133,7 @@ EXPORT_SYMBOL(nf_getsockopt);
 
 #ifdef CONFIG_COMPAT
 static int compat_nf_sockopt(struct sock *sk, int pf, int val,
-		      char __user *opt, int *len, int get)
+			     char __user *opt, int *len, int get)
 {
 	struct list_head *i;
 	struct nf_sockopt_ops *ops;
diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index bbee14d..c20d282 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -861,27 +861,27 @@ static int sctp_inet6_supported_addrs(co
 }
 
 static const struct proto_ops inet6_seqpacket_ops = {
-	.family     = PF_INET6,
-	.owner      = THIS_MODULE,
-	.release    = inet6_release,
-	.bind       = inet6_bind,
-	.connect    = inet_dgram_connect,
-	.socketpair = sock_no_socketpair,
-	.accept     = inet_accept,
-	.getname    = inet6_getname,
-	.poll       = sctp_poll,
-	.ioctl      = inet6_ioctl,
-	.listen     = sctp_inet_listen,
-	.shutdown   = inet_shutdown,
-	.setsockopt = sock_common_setsockopt,
-	.getsockopt = sock_common_getsockopt,
+	.family		   = PF_INET6,
+	.owner		   = THIS_MODULE,
+	.release	   = inet6_release,
+	.bind		   = inet6_bind,
+	.connect	   = inet_dgram_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = inet_accept,
+	.getname	   = inet6_getname,
+	.poll		   = sctp_poll,
+	.ioctl		   = inet6_ioctl,
+	.listen		   = sctp_inet_listen,
+	.shutdown	   = inet_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_sock_common_setsockopt,
-	.compat_getsockopt	= compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg    = inet_sendmsg,
-	.recvmsg    = sock_common_recvmsg,
-	.mmap       = sock_no_mmap,
 };
 
 static struct inet_protosw sctpv6_seqpacket_protosw = {
@@ -915,35 +915,35 @@ static struct inet6_protocol sctpv6_prot
 };
 
 static struct sctp_af sctp_ipv6_specific = {
-	.sctp_xmit       = sctp_v6_xmit,
-	.setsockopt      = ipv6_setsockopt,
-	.getsockopt      = ipv6_getsockopt,
+	.sa_family	   = AF_INET6,
+	.sctp_xmit	   = sctp_v6_xmit,
+	.setsockopt	   = ipv6_setsockopt,
+	.getsockopt	   = ipv6_getsockopt,
+	.get_dst	   = sctp_v6_get_dst,
+	.get_saddr	   = sctp_v6_get_saddr,
+	.copy_addrlist	   = sctp_v6_copy_addrlist,
+	.from_skb	   = sctp_v6_from_skb,
+	.from_sk	   = sctp_v6_from_sk,
+	.to_sk_saddr	   = sctp_v6_to_sk_saddr,
+	.to_sk_daddr	   = sctp_v6_to_sk_daddr,
+	.from_addr_param   = sctp_v6_from_addr_param,
+	.to_addr_param	   = sctp_v6_to_addr_param,
+	.dst_saddr	   = sctp_v6_dst_saddr,
+	.cmp_addr	   = sctp_v6_cmp_addr,
+	.scope		   = sctp_v6_scope,
+	.addr_valid	   = sctp_v6_addr_valid,
+	.inaddr_any	   = sctp_v6_inaddr_any,
+	.is_any		   = sctp_v6_is_any,
+	.available	   = sctp_v6_available,
+	.skb_iif	   = sctp_v6_skb_iif,
+	.is_ce		   = sctp_v6_is_ce,
+	.seq_dump_addr	   = sctp_v6_seq_dump_addr,
+	.net_header_len	   = sizeof(struct ipv6hdr),
+	.sockaddr_len	   = sizeof(struct sockaddr_in6),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt	= compat_ipv6_setsockopt,
-	.compat_getsockopt	= compat_ipv6_getsockopt,
+	.compat_setsockopt = compat_ipv6_setsockopt,
+	.compat_getsockopt = compat_ipv6_getsockopt,
 #endif
-	.get_dst	 = sctp_v6_get_dst,
-	.get_saddr	 = sctp_v6_get_saddr,
-	.copy_addrlist   = sctp_v6_copy_addrlist,
-	.from_skb        = sctp_v6_from_skb,
-	.from_sk         = sctp_v6_from_sk,
-	.to_sk_saddr     = sctp_v6_to_sk_saddr,
-	.to_sk_daddr     = sctp_v6_to_sk_daddr,
-	.from_addr_param = sctp_v6_from_addr_param,
-	.to_addr_param   = sctp_v6_to_addr_param,
-	.dst_saddr       = sctp_v6_dst_saddr,
-	.cmp_addr        = sctp_v6_cmp_addr,
-	.scope           = sctp_v6_scope,
-	.addr_valid      = sctp_v6_addr_valid,
-	.inaddr_any      = sctp_v6_inaddr_any,
-	.is_any          = sctp_v6_is_any,
-	.available       = sctp_v6_available,
-	.skb_iif         = sctp_v6_skb_iif,
-	.is_ce           = sctp_v6_is_ce,
-	.seq_dump_addr   = sctp_v6_seq_dump_addr,
-	.net_header_len  = sizeof(struct ipv6hdr),
-	.sockaddr_len    = sizeof(struct sockaddr_in6),
-	.sa_family       = AF_INET6,
 };
 
 static struct sctp_pf sctp_pf_inet6_specific = {
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d90f549..e66988e 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -831,28 +831,28 @@ static struct notifier_block sctp_inetad
 
 /* Socket operations.  */
 static const struct proto_ops inet_seqpacket_ops = {
-	.family      = PF_INET,
-	.owner       = THIS_MODULE,
-	.release     = inet_release,       /* Needs to be wrapped... */
-	.bind        = inet_bind,
-	.connect     = inet_dgram_connect,
-	.socketpair  = sock_no_socketpair,
-	.accept      = inet_accept,
-	.getname     = inet_getname,      /* Semantics are different.  */
-	.poll        = sctp_poll,
-	.ioctl       = inet_ioctl,
-	.listen      = sctp_inet_listen,
-	.shutdown    = inet_shutdown,     /* Looks harmless.  */
-	.setsockopt  = sock_common_setsockopt,   /* IP_SOL IP_OPTION is a problem. */
-	.getsockopt  = sock_common_getsockopt,
+	.family		   = PF_INET,
+	.owner		   = THIS_MODULE,
+	.release	   = inet_release,	/* Needs to be wrapped... */
+	.bind		   = inet_bind,
+	.connect	   = inet_dgram_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = inet_accept,
+	.getname	   = inet_getname,	/* Semantics are different.  */
+	.poll		   = sctp_poll,
+	.ioctl		   = inet_ioctl,
+	.listen		   = sctp_inet_listen,
+	.shutdown	   = inet_shutdown,	/* Looks harmless.  */
+	.setsockopt	   = sock_common_setsockopt, /* IP_SOL IP_OPTION is a problem */
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = inet_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt  = compat_sock_common_setsockopt,
-	.compat_getsockopt  = compat_sock_common_getsockopt,
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
 #endif
-	.sendmsg     = inet_sendmsg,
-	.recvmsg     = sock_common_recvmsg,
-	.mmap        = sock_no_mmap,
-	.sendpage    = sock_no_sendpage,
 };
 
 /* Registration with AF_INET family.  */
@@ -884,35 +884,35 @@ static struct net_protocol sctp_protocol
 
 /* IPv4 address related functions.  */
 static struct sctp_af sctp_ipv4_specific = {
-	.sctp_xmit      = sctp_v4_xmit,
-	.setsockopt     = ip_setsockopt,
-	.getsockopt     = ip_getsockopt,
+	.sa_family	   = AF_INET,
+	.sctp_xmit	   = sctp_v4_xmit,
+	.setsockopt	   = ip_setsockopt,
+	.getsockopt	   = ip_getsockopt,
+	.get_dst	   = sctp_v4_get_dst,
+	.get_saddr	   = sctp_v4_get_saddr,
+	.copy_addrlist	   = sctp_v4_copy_addrlist,
+	.from_skb	   = sctp_v4_from_skb,
+	.from_sk	   = sctp_v4_from_sk,
+	.to_sk_saddr	   = sctp_v4_to_sk_saddr,
+	.to_sk_daddr	   = sctp_v4_to_sk_daddr,
+	.from_addr_param   = sctp_v4_from_addr_param,
+	.to_addr_param	   = sctp_v4_to_addr_param,	
+	.dst_saddr	   = sctp_v4_dst_saddr,
+	.cmp_addr	   = sctp_v4_cmp_addr,
+	.addr_valid	   = sctp_v4_addr_valid,
+	.inaddr_any	   = sctp_v4_inaddr_any,
+	.is_any		   = sctp_v4_is_any,
+	.available	   = sctp_v4_available,
+	.scope		   = sctp_v4_scope,
+	.skb_iif	   = sctp_v4_skb_iif,
+	.is_ce		   = sctp_v4_is_ce,
+	.seq_dump_addr	   = sctp_v4_seq_dump_addr,
+	.net_header_len	   = sizeof(struct iphdr),
+	.sockaddr_len	   = sizeof(struct sockaddr_in),
 #ifdef CONFIG_COMPAT
-	.compat_setsockopt     = compat_ip_setsockopt,
-	.compat_getsockopt     = compat_ip_getsockopt,
+	.compat_setsockopt = compat_ip_setsockopt,
+	.compat_getsockopt = compat_ip_getsockopt,
 #endif
-	.get_dst	= sctp_v4_get_dst,
-	.get_saddr	= sctp_v4_get_saddr,
-	.copy_addrlist  = sctp_v4_copy_addrlist,
-	.from_skb       = sctp_v4_from_skb,
-	.from_sk        = sctp_v4_from_sk,
-	.to_sk_saddr    = sctp_v4_to_sk_saddr,
-	.to_sk_daddr    = sctp_v4_to_sk_daddr,
-	.from_addr_param= sctp_v4_from_addr_param,
-	.to_addr_param  = sctp_v4_to_addr_param,	
-	.dst_saddr      = sctp_v4_dst_saddr,
-	.cmp_addr       = sctp_v4_cmp_addr,
-	.addr_valid     = sctp_v4_addr_valid,
-	.inaddr_any     = sctp_v4_inaddr_any,
-	.is_any         = sctp_v4_is_any,
-	.available      = sctp_v4_available,
-	.scope          = sctp_v4_scope,
-	.skb_iif        = sctp_v4_skb_iif,
-	.is_ce          = sctp_v4_is_ce,
-	.seq_dump_addr  = sctp_v4_seq_dump_addr,
-	.net_header_len = sizeof(struct iphdr),
-	.sockaddr_len   = sizeof(struct sockaddr_in),
-	.sa_family      = AF_INET,
 };
 
 struct sctp_pf *sctp_get_pf_specific(sa_family_t family) {
-- 
1.2.2.gd27d


