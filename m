From: Breno Leitao <leitao@debian.org>
Date: Wed, 14 Jun 2023 11:07:55 +0000
Subject: [RFC PATCH v2 2/4] net: add uring_cmd callback to UDP
Message-Id: <20230614110757.3689731-3-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the implementation of uring_cmd for the UDP protocol. It
basically encompasses SOCKET_URING_OP_SIOCOUTQ and
SOCKET_URING_OP_SIOCINQ, which is the io_uring representation for
SIOCOUTQ and SIOCINQ.

SIOCINQ and SIOCOUTQ are the only two CMDs handled by udp_ioctl().

Signed-off-by: Breno Leitao <leitao@debian.org>
---
 include/net/udp.h        |  2 ++
 include/uapi/linux/net.h |  5 +++++
 net/ipv4/udp.c           | 22 ++++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/include/net/udp.h b/include/net/udp.h
index 10d94a42117b..046ca7231d27 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -285,6 +285,8 @@ int udp_cmsg_send(struct sock *sk, struct msghdr *msg, u16 *gso_size);
 void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
 int udp_rcv(struct sk_buff *skb);
 int udp_ioctl(struct sock *sk, int cmd, int *karg);
+int udp_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags);
 int udp_init_sock(struct sock *sk);
 int udp_pre_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 int __udp_disconnect(struct sock *sk, int flags);
diff --git a/include/uapi/linux/net.h b/include/uapi/linux/net.h
index 4dabec6bd957..dd8e7ced7d24 100644
--- a/include/uapi/linux/net.h
+++ b/include/uapi/linux/net.h
@@ -55,4 +55,9 @@ typedef enum {
 
 #define __SO_ACCEPTCON	(1 << 16)	/* performed a listen		*/
 
+enum {
+	SOCKET_URING_OP_SIOCINQ		= 0,
+	SOCKET_URING_OP_SIOCOUTQ,
+};
+
 #endif /* _UAPI_LINUX_NET_H */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6a09757f287b..5e06b6de1c08 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -113,6 +113,7 @@
 #include <net/sock_reuseport.h>
 #include <net/addrconf.h>
 #include <net/udp_tunnel.h>
+#include <linux/io_uring.h>
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6_stubs.h>
 #endif
@@ -1687,6 +1688,26 @@ static int first_packet_length(struct sock *sk)
 	return res;
 }
 
+int udp_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags)
+{
+	int ret;
+
+	switch (cmd->sqe->cmd_op) {
+	case SOCKET_URING_OP_SIOCINQ:
+		if (udp_ioctl(sk, SIOCINQ, &ret))
+			return -EFAULT;
+		return ret;
+	case SOCKET_URING_OP_SIOCOUTQ:
+		if (udp_ioctl(sk, SIOCOUTQ, &ret))
+			return -EFAULT;
+		return ret;
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+EXPORT_SYMBOL_GPL(udp_uring_cmd);
+
 /*
  *	IOCTL requests applicable to the UDP protocol
  */
@@ -2925,6 +2946,7 @@ struct proto udp_prot = {
 	.connect		= ip4_datagram_connect,
 	.disconnect		= udp_disconnect,
 	.ioctl			= udp_ioctl,
+	.uring_cmd		= udp_uring_cmd,
 	.init			= udp_init_sock,
 	.destroy		= udp_destroy_sock,
 	.setsockopt		= udp_setsockopt,
-- 
2.34.1
