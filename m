From: Brian Haley <brian.haley@hp.com>
Date: Sat, 14 Jun 2008 01:55:35 +0000
Subject: [PATCH]: change proto destroy method to return void
Message-Id: <48532517.3070205@hp.com>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="------------050505070203090903080609"
List-Id: <dccp.vger.kernel.org>
To: dccp@vger.kernel.org

This is a multi-part message in MIME format.
--------------050505070203090903080609
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change struct proto destroy function pointer to return void.  Noticed by 
Al Viro.

Compile tested only.

-Brian

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

--------------050505070203090903080609
Content-Type: text/x-patch;
 name="proto_destroy.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="proto_destroy.patch"

diff --git a/include/net/sock.h b/include/net/sock.h
index dc42b44..0a80961 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -524,7 +524,7 @@ struct proto {
 	int			(*ioctl)(struct sock *sk, int cmd,
 					 unsigned long arg);
 	int			(*init)(struct sock *sk);
-	int			(*destroy)(struct sock *sk);
+	void			(*destroy)(struct sock *sk);
 	void			(*shutdown)(struct sock *sk, int how);
 	int			(*setsockopt)(struct sock *sk, int level, 
 					int optname, char __user *optval,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 07005eb..db8aaad 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1368,7 +1368,7 @@ extern void tcp_proc_unregister(struct net *net, struct tcp_seq_afinfo *afinfo);
 extern struct request_sock_ops tcp_request_sock_ops;
 extern struct request_sock_ops tcp6_request_sock_ops;
 
-extern int tcp_v4_destroy_sock(struct sock *sk);
+extern void tcp_v4_destroy_sock(struct sock *sk);
 
 extern int tcp_v4_gso_send_check(struct sk_buff *skb);
 extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features);
diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 112934a..876b6f2 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -53,7 +53,7 @@ extern int			datagram_send_ctl(struct net *net,
  */
 extern struct inet_connection_sock_af_ops ipv4_specific;
 
-extern int inet6_destroy_sock(struct sock *sk);
+extern void inet6_destroy_sock(struct sock *sk);
 
 #endif
 
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f44d492..1b2cea2 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -262,7 +262,7 @@ extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
 				const struct dccp_hdr *dh, const unsigned len);
 
 extern int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized);
-extern int dccp_destroy_sock(struct sock *sk);
+extern void dccp_destroy_sock(struct sock *sk);
 
 extern void		dccp_close(struct sock *sk, long timeout);
 extern struct sk_buff	*dccp_make_response(struct sock *sk,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9b1129b..7de8878 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -1092,10 +1092,10 @@ static int dccp_v6_init_sock(struct sock *sk)
 	return err;
 }
 
-static int dccp_v6_destroy_sock(struct sock *sk)
+static void dccp_v6_destroy_sock(struct sock *sk)
 {
 	dccp_destroy_sock(sk);
-	return inet6_destroy_sock(sk);
+	inet6_destroy_sock(sk);
 }
 
 static struct timewait_sock_ops dccp6_timewait_sock_ops = {
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 9dfe247..a0b5600 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -237,7 +237,7 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized)
 
 EXPORT_SYMBOL_GPL(dccp_init_sock);
 
-int dccp_destroy_sock(struct sock *sk)
+void dccp_destroy_sock(struct sock *sk)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_minisock *dmsk = dccp_msk(sk);
@@ -268,8 +268,6 @@ int dccp_destroy_sock(struct sock *sk)
 
 	/* clean up feature negotiation state */
 	dccp_feat_clean(dmsk);
-
-	return 0;
 }
 
 EXPORT_SYMBOL_GPL(dccp_destroy_sock);
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 1d0c97c..36035a0 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -606,12 +606,11 @@ static void raw_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
-static int raw_destroy(struct sock *sk)
+static void raw_destroy(struct sock *sk)
 {
 	lock_sock(sk);
 	ip_flush_pending_frames(sk);
 	release_sock(sk);
-	return 0;
 }
 
 /* This gets rid of all the nasties in af_inet. -DaveM */
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9088d70..70d6181 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1775,7 +1775,7 @@ static int tcp_v4_init_sock(struct sock *sk)
 	return 0;
 }
 
-int tcp_v4_destroy_sock(struct sock *sk)
+void tcp_v4_destroy_sock(struct sock *sk)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 
@@ -1827,8 +1827,6 @@ int tcp_v4_destroy_sock(struct sock *sk)
 	}
 
 	atomic_dec(&tcp_sockets_allocated);
-
-	return 0;
 }
 
 EXPORT_SYMBOL(tcp_v4_destroy_sock);
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 355e6d6..eba790d 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -1253,12 +1253,11 @@ int udp_rcv(struct sk_buff *skb)
 	return __udp4_lib_rcv(skb, udp_hash, IPPROTO_UDP);
 }
 
-int udp_destroy_sock(struct sock *sk)
+void udp_destroy_sock(struct sock *sk)
 {
 	lock_sock(sk);
 	udp_flush_pending_frames(sk);
 	release_sock(sk);
-	return 0;
 }
 
 /*
diff --git a/net/ipv4/udp_impl.h b/net/ipv4/udp_impl.h
index 7288bf7..2e9bad2 100644
--- a/net/ipv4/udp_impl.h
+++ b/net/ipv4/udp_impl.h
@@ -26,7 +26,7 @@ extern int	udp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
 extern int	udp_sendpage(struct sock *sk, struct page *page, int offset,
 			     size_t size, int flags);
 extern int	udp_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
-extern int	udp_destroy_sock(struct sock *sk);
+extern void	udp_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
 extern int	udp4_seq_show(struct seq_file *seq, void *v);
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 350457c..3ce8d2f 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -371,7 +371,7 @@ int inet6_release(struct socket *sock)
 
 EXPORT_SYMBOL(inet6_release);
 
-int inet6_destroy_sock(struct sock *sk)
+void inet6_destroy_sock(struct sock *sk)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *skb;
@@ -389,8 +389,6 @@ int inet6_destroy_sock(struct sock *sk)
 
 	if ((opt = xchg(&np->opt, NULL)) != NULL)
 		sock_kfree_s(sk, opt, opt->tot_len);
-
-	return 0;
 }
 
 EXPORT_SYMBOL_GPL(inet6_destroy_sock);
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index e03c189..5f9285d 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -1162,12 +1162,11 @@ static void rawv6_close(struct sock *sk, long timeout)
 	sk_common_release(sk);
 }
 
-static int raw6_destroy(struct sock *sk)
+static void raw6_destroy(struct sock *sk)
 {
 	lock_sock(sk);
 	ip6_flush_pending_frames(sk);
 	release_sock(sk);
-	return 0;
 }
 
 static int rawv6_init_sk(struct sock *sk)
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 3fe736b..766d1c9 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1873,7 +1873,7 @@ static int tcp_v6_init_sock(struct sock *sk)
 	return 0;
 }
 
-static int tcp_v6_destroy_sock(struct sock *sk)
+static void tcp_v6_destroy_sock(struct sock *sk)
 {
 #ifdef CONFIG_TCP_MD5SIG
 	/* Clean up the MD5 key list */
@@ -1881,7 +1881,7 @@ static int tcp_v6_destroy_sock(struct sock *sk)
 		tcp_v6_clear_md5_list(sk);
 #endif
 	tcp_v4_destroy_sock(sk);
-	return inet6_destroy_sock(sk);
+	inet6_destroy_sock(sk);
 }
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index e0693ff..09687f7 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -879,15 +879,13 @@ do_confirm:
 	goto out;
 }
 
-int udpv6_destroy_sock(struct sock *sk)
+void udpv6_destroy_sock(struct sock *sk)
 {
 	lock_sock(sk);
 	udp_v6_flush_pending_frames(sk);
 	release_sock(sk);
 
 	inet6_destroy_sock(sk);
-
-	return 0;
 }
 
 /*
diff --git a/net/ipv6/udp_impl.h b/net/ipv6/udp_impl.h
index 321b81a..92dd7da 100644
--- a/net/ipv6/udp_impl.h
+++ b/net/ipv6/udp_impl.h
@@ -29,7 +29,7 @@ extern int	udpv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 			      struct msghdr *msg, size_t len,
 			      int noblock, int flags, int *addr_len);
 extern int	udpv6_queue_rcv_skb(struct sock * sk, struct sk_buff *skb);
-extern int	udpv6_destroy_sock(struct sock *sk);
+extern void	udpv6_destroy_sock(struct sock *sk);
 
 #ifdef CONFIG_PROC_FS
 extern int	udp6_seq_show(struct seq_file *seq, void *v);
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 253e5ea..f98650c 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -3588,7 +3588,7 @@ SCTP_STATIC int sctp_init_sock(struct sock *sk)
 }
 
 /* Cleanup any SCTP per socket resources.  */
-SCTP_STATIC int sctp_destroy_sock(struct sock *sk)
+SCTP_STATIC void sctp_destroy_sock(struct sock *sk)
 {
 	struct sctp_endpoint *ep;
 
@@ -3598,7 +3598,6 @@ SCTP_STATIC int sctp_destroy_sock(struct sock *sk)
 	ep = sctp_sk(sk)->ep;
 	sctp_endpoint_free(ep);
 	atomic_dec(&sctp_sockets_allocated);
-	return 0;
 }
 
 /* API 4.1.7 shutdown() - TCP Style Syntax

--------------050505070203090903080609--
