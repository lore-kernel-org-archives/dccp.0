From: Breno Leitao <leitao@debian.org>
Date: Wed, 14 Jun 2023 11:07:57 +0000
Subject: [RFC PATCH v2 4/4] net: add uring_cmd callback to raw "protocol"
Message-Id: <20230614110757.3689731-5-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the implementation of uring_cmd for the raw "protocol". It
basically encompasses SOCKET_URING_OP_SIOCOUTQ and
SOCKET_URING_OP_SIOCINQ, which call raw_ioctl with SIOCOUTQ and SIOCINQ.

These two commands (SIOCOUTQ and SIOCINQ), are the only two commands
that are handled by raw_ioctl().

Signed-off-by: Breno Leitao <leitao@debian.org>
---
 include/net/raw.h |  3 +++
 net/ipv4/raw.c    | 23 +++++++++++++++++++++++
 2 files changed, 26 insertions(+)

diff --git a/include/net/raw.h b/include/net/raw.h
index 32a61481a253..5d5ec63274a8 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -96,4 +96,7 @@ static inline bool raw_sk_bound_dev_eq(struct net *net, int bound_dev_if,
 #endif
 }
 
+int raw_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags);
+
 #endif	/* _RAW_H */
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 7782ff5e6539..31c3f9c41354 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -75,6 +75,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/compat.h>
 #include <linux/uio.h>
+#include <linux/io_uring.h>
 
 struct raw_frag_vec {
 	struct msghdr *msg;
@@ -885,6 +886,27 @@ static int raw_ioctl(struct sock *sk, int cmd, int *karg)
 	}
 }
 
+int raw_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags)
+{
+	int ret;
+
+	switch (cmd->sqe->cmd_op) {
+	case SOCKET_URING_OP_SIOCINQ: {
+		if (raw_ioctl(sk, SIOCINQ, &ret))
+			return -EFAULT;
+		return ret;
+	}
+	case SOCKET_URING_OP_SIOCOUTQ:
+		if (raw_ioctl(sk, SIOCOUTQ, &ret))
+			return -EFAULT;
+		return ret;
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+EXPORT_SYMBOL_GPL(raw_uring_cmd);
+
 #ifdef CONFIG_COMPAT
 static int compat_raw_ioctl(struct sock *sk, unsigned int cmd, unsigned long arg)
 {
@@ -924,6 +946,7 @@ struct proto raw_prot = {
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = __udp_disconnect,
 	.ioctl		   = raw_ioctl,
+	.uring_cmd	   = raw_uring_cmd,
 	.init		   = raw_sk_init,
 	.setsockopt	   = raw_setsockopt,
 	.getsockopt	   = raw_getsockopt,
-- 
2.34.1
