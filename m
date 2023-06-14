From: Breno Leitao <leitao@debian.org>
Date: Wed, 14 Jun 2023 11:07:56 +0000
Subject: [RFC PATCH v2 3/4] net: add uring_cmd callback to TCP
Message-Id: <20230614110757.3689731-4-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the implementation of uring_cmd for the TCP protocol. It
basically encompasses SOCKET_URING_OP_SIOCOUTQ and
SOCKET_URING_OP_SIOCINQ, which calls tcp_ioctl().

tcp_ioctl() has other CMDs, such as SIOCATMARK and SIOCOUTQNSD, but they
are not implemented, because they are TCP specific, and not available on
UDP and RAW sockets.

Signed-off-by: Breno Leitao <leitao@debian.org>
---
 include/net/tcp.h   |  2 ++
 net/ipv4/tcp.c      | 21 +++++++++++++++++++++
 net/ipv4/tcp_ipv4.c |  1 +
 3 files changed, 24 insertions(+)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 2a7289916d42..1100b0c9df98 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -340,6 +340,8 @@ void tcp_wfree(struct sk_buff *skb);
 void tcp_write_timer_handler(struct sock *sk);
 void tcp_delack_timer_handler(struct sock *sk);
 int tcp_ioctl(struct sock *sk, int cmd, int *karg);
+int tcp_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags);
 int tcp_rcv_state_process(struct sock *sk, struct sk_buff *skb);
 void tcp_rcv_established(struct sock *sk, struct sk_buff *skb);
 void tcp_rcv_space_adjust(struct sock *sk);
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 2cb01880755a..8bf9a41d2a67 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -279,6 +279,7 @@
 #include <linux/uaccess.h>
 #include <asm/ioctls.h>
 #include <net/busy_poll.h>
+#include <linux/io_uring.h>
 
 /* Track pending CMSGs. */
 enum {
@@ -599,6 +600,26 @@ __poll_t tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 }
 EXPORT_SYMBOL(tcp_poll);
 
+int tcp_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags)
+{
+	int ret;
+
+	switch (cmd->sqe->cmd_op) {
+	case SOCKET_URING_OP_SIOCINQ:
+		if (tcp_ioctl(sk, SIOCINQ, &ret))
+			return -EFAULT;
+		return ret;
+	case SOCKET_URING_OP_SIOCOUTQ:
+		if (tcp_ioctl(sk, SIOCOUTQ, &ret))
+			return -EFAULT;
+		return ret;
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+EXPORT_SYMBOL_GPL(tcp_uring_cmd);
+
 int tcp_ioctl(struct sock *sk, int cmd, int *karg)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 84a5d557dc1a..dd93a862d195 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -3107,6 +3107,7 @@ struct proto tcp_prot = {
 	.disconnect		= tcp_disconnect,
 	.accept			= inet_csk_accept,
 	.ioctl			= tcp_ioctl,
+	.uring_cmd		= tcp_uring_cmd,
 	.init			= tcp_v4_init_sock,
 	.destroy		= tcp_v4_destroy_sock,
 	.shutdown		= tcp_shutdown,
-- 
2.34.1
