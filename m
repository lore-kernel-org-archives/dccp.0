From: Breno Leitao <leitao@debian.org>
Date: Thu, 06 Apr 2023 14:43:27 +0000
Subject: [RFC PATCH 1/4] net: wire up support for file_operations->uring_cmd()
Message-Id: <20230406144330.1932798-2-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Create the initial plumbing to call protocol specific uring_cmd
callbacks. These are io_uring specific callbacks that implement
ioctl-like operation types, such as SIOCINQ, SIOCOUTQ and others.

In order to achieve this, create uring_cmd callback placeholders in
file_ops, proto and proto_ops structures.

Create also the functions that does the plumbing from io_uring_cmd() up
to sk_proto->uring_cmd(). If the callback is not implemented,
-EOPNOTSUPP is returned.

That way, the io_uring issue path calls file_operations->uring_cmd
(sock_uring_cmd()).  This function calls proto_ops->uring_cmd
(sock_common_uring_cmd()). sock_common_uring_cmd() is responsible for
calling protocol specific (struct proto_ops) uring_cmd callback
(sock_common_uring_cmd()). sock_common_uring_cmd() then calls the proto
specific (struct proto) uring_cmd function, which are implemented in the
upcoming patch.

By the end, uring_cmd() function has access to  'struct io_uring_cmd'
which points to the whole SQE, and any field could be accessed from the
function pointer.

Signed-off-by: Breno Leitao <leitao@debian.org>
---
 include/linux/net.h  |  2 ++
 include/net/sock.h   |  6 ++++++
 net/core/sock.c      | 17 +++++++++++++++--
 net/dccp/ipv4.c      |  1 +
 net/ipv4/af_inet.c   |  3 +++
 net/l2tp/l2tp_ip.c   |  1 +
 net/mptcp/protocol.c |  1 +
 net/sctp/protocol.c  |  1 +
 net/socket.c         | 13 +++++++++++++
 9 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/net.h b/include/linux/net.h
index b73ad8e3c212..efcc47a57069 100644
--- a/include/linux/net.h
+++ b/include/linux/net.h
@@ -182,6 +182,8 @@ struct proto_ops {
 	int	 	(*compat_ioctl) (struct socket *sock, unsigned int cmd,
 				      unsigned long arg);
 #endif
+	int		(*uring_cmd)(struct socket *sock, struct io_uring_cmd *cmd,
+				     unsigned int issue_flags);
 	int		(*gettstamp) (struct socket *sock, void __user *userstamp,
 				      bool timeval, bool time32);
 	int		(*listen)    (struct socket *sock, int len);
diff --git a/include/net/sock.h b/include/net/sock.h
index 573f2bf7e0de..57437a1e041c 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -111,6 +111,7 @@ typedef struct {
 struct sock;
 struct proto;
 struct net;
+struct io_uring_cmd;
 
 typedef __u32 __bitwise __portpair;
 typedef __u64 __bitwise __addrpair;
@@ -1247,6 +1248,9 @@ struct proto {
 
 	int			(*ioctl)(struct sock *sk, int cmd,
 					 unsigned long arg);
+	int			(*uring_cmd)(struct sock *sk,
+					     struct io_uring_cmd *cmd,
+					     unsigned int issue_flags);
 	int			(*init)(struct sock *sk);
 	void			(*destroy)(struct sock *sk);
 	void			(*shutdown)(struct sock *sk, int how);
@@ -1921,6 +1925,8 @@ int sock_common_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
 			int flags);
 int sock_common_setsockopt(struct socket *sock, int level, int optname,
 			   sockptr_t optval, unsigned int optlen);
+int sock_common_uring_cmd(struct socket *sock, struct io_uring_cmd *cmd,
+			  unsigned int issue_flags);
 
 void sk_common_release(struct sock *sk);
 
diff --git a/net/core/sock.c b/net/core/sock.c
index c25888795390..1bf5e4d4ba29 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -3669,6 +3669,18 @@ int sock_common_setsockopt(struct socket *sock, int level, int optname,
 }
 EXPORT_SYMBOL(sock_common_setsockopt);
 
+int sock_common_uring_cmd(struct socket *sock, struct io_uring_cmd *cmd,
+			  unsigned int issue_flags)
+{
+	struct sock *sk = sock->sk;
+
+	if (!sk->sk_prot || !sk->sk_prot->uring_cmd)
+		return -EOPNOTSUPP;
+
+	return sk->sk_prot->uring_cmd(sk, cmd, issue_flags);
+}
+EXPORT_SYMBOL(sock_common_uring_cmd);
+
 void sk_common_release(struct sock *sk)
 {
 	if (sk->sk_prot->destroy)
@@ -4009,7 +4021,7 @@ static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
 {
 
 	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
-			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
+			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
 		   proto->name,
 		   proto->obj_size,
 		   sock_prot_inuse_get(seq_file_net(seq), proto),
@@ -4023,6 +4035,7 @@ static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
 		   proto_method_implemented(proto->disconnect),
 		   proto_method_implemented(proto->accept),
 		   proto_method_implemented(proto->ioctl),
+		   proto_method_implemented(proto->uring_cmd),
 		   proto_method_implemented(proto->init),
 		   proto_method_implemented(proto->destroy),
 		   proto_method_implemented(proto->shutdown),
@@ -4051,7 +4064,7 @@ static int proto_seq_show(struct seq_file *seq, void *v)
 			   "maxhdr",
 			   "slab",
 			   "module",
-			   "cl co di ac io in de sh ss gs se re sp bi br ha uh gp em\n");
+			   "cl co di ac io ur in de sh ss gs se re sp bi br ha uh gp em\n");
 	else
 		proto_seq_printf(seq, list_entry(v, struct proto, node));
 	return 0;
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index b780827f5e0a..47047ad05e65 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -999,6 +999,7 @@ static const struct proto_ops inet_dccp_ops = {
 	/* FIXME: work on tcp_poll to rename it to inet_csk_poll */
 	.poll		   = dccp_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	/* FIXME: work on inet_listen to rename it to sock_common_listen */
 	.listen		   = inet_dccp_listen,
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 8db6747f892f..1c54c3b59f2e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1036,6 +1036,7 @@ const struct proto_ops inet_stream_ops = {
 	.getname	   = inet_getname,
 	.poll		   = tcp_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	.listen		   = inet_listen,
 	.shutdown	   = inet_shutdown,
@@ -1071,6 +1072,7 @@ const struct proto_ops inet_dgram_ops = {
 	.getname	   = inet_getname,
 	.poll		   = udp_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
@@ -1103,6 +1105,7 @@ static const struct proto_ops inet_sockraw_ops = {
 	.getname	   = inet_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
diff --git a/net/l2tp/l2tp_ip.c b/net/l2tp/l2tp_ip.c
index 4db5a554bdbd..cdfaaada0695 100644
--- a/net/l2tp/l2tp_ip.c
+++ b/net/l2tp/l2tp_ip.c
@@ -617,6 +617,7 @@ static const struct proto_ops l2tp_ip_ops = {
 	.getname	   = l2tp_ip_getname,
 	.poll		   = datagram_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	.listen		   = sock_no_listen,
 	.shutdown	   = inet_shutdown,
diff --git a/net/mptcp/protocol.c b/net/mptcp/protocol.c
index 3ad9c46202fc..b8182eab5ebf 100644
--- a/net/mptcp/protocol.c
+++ b/net/mptcp/protocol.c
@@ -3808,6 +3808,7 @@ static const struct proto_ops mptcp_stream_ops = {
 	.getname	   = inet_getname,
 	.poll		   = mptcp_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	.listen		   = mptcp_listen,
 	.shutdown	   = inet_shutdown,
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index c365df24ad33..b1aaf644076f 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1127,6 +1127,7 @@ static const struct proto_ops inet_seqpacket_ops = {
 	.getname	   = inet_getname,	/* Semantics are different.  */
 	.poll		   = sctp_poll,
 	.ioctl		   = inet_ioctl,
+	.uring_cmd	   = sock_common_uring_cmd,
 	.gettstamp	   = sock_gettstamp,
 	.listen		   = sctp_inet_listen,
 	.shutdown	   = inet_shutdown,	/* Looks harmless.  */
diff --git a/net/socket.c b/net/socket.c
index 9c92c0e6c4da..c683110c1523 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -87,6 +87,7 @@
 #include <linux/xattr.h>
 #include <linux/nospec.h>
 #include <linux/indirect_call_wrapper.h>
+#include <linux/io_uring.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -116,6 +117,7 @@ unsigned int sysctl_net_busy_poll __read_mostly;
 static ssize_t sock_read_iter(struct kiocb *iocb, struct iov_iter *to);
 static ssize_t sock_write_iter(struct kiocb *iocb, struct iov_iter *from);
 static int sock_mmap(struct file *file, struct vm_area_struct *vma);
+static int sock_uring_cmd(struct io_uring_cmd *cmd, unsigned int issue_flags);
 
 static int sock_close(struct inode *inode, struct file *file);
 static __poll_t sock_poll(struct file *file,
@@ -159,6 +161,7 @@ static const struct file_operations socket_file_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = compat_sock_ioctl,
 #endif
+	.uring_cmd =	sock_uring_cmd,
 	.mmap =		sock_mmap,
 	.release =	sock_close,
 	.fasync =	sock_fasync,
@@ -1319,6 +1322,16 @@ static long sock_ioctl(struct file *file, unsigned cmd, unsigned long arg)
 	return err;
 }
 
+static int sock_uring_cmd(struct io_uring_cmd *cmd, unsigned int issue_flags)
+{
+	struct socket *sock = cmd->file->private_data;
+
+	if (!sock->ops || !sock->ops->uring_cmd)
+		return -EOPNOTSUPP;
+
+	return sock->ops->uring_cmd(sock, cmd, issue_flags);
+}
+
 /**
  *	sock_create_lite - creates a socket
  *	@family: protocol family (AF_INET, ...)
-- 
2.34.1
