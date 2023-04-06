From: Breno Leitao <leitao@debian.org>
Date: Thu, 06 Apr 2023 14:43:30 +0000
Subject: [RFC PATCH 4/4] net: add uring_cmd callback to raw "protocol"
Message-Id: <20230406144330.1932798-5-leitao@debian.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is the implementation of uring_cmd for the raw "protocol". It
basically encompasses SOCKET_URING_OP_SIOCOUTQ and
SOCKET_URING_OP_SIOCINQ, which is similar to the SIOCOUTQ and SIOCINQ
ioctls.

The return value is exactly the same as the regular ioctl (raw_ioctl()).

Signed-off-by: Breno Leitao <leitao@debian.org>
---
 include/net/raw.h |  3 +++
 net/ipv4/raw.c    | 25 +++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/net/raw.h b/include/net/raw.h
index 2c004c20ed99..ba7a96dce16b 100644
--- a/include/net/raw.h
+++ b/include/net/raw.h
@@ -99,4 +99,7 @@ static inline bool raw_sk_bound_dev_eq(struct net *net, int bound_dev_if,
 #endif
 }
 
+int raw_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags);
+
 #endif	/* _RAW_H */
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 94df935ee0c5..3db828bc1224 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -75,6 +75,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/compat.h>
 #include <linux/uio.h>
+#include <linux/io_uring.h>
 
 struct raw_frag_vec {
 	struct msghdr *msg;
@@ -857,6 +858,29 @@ static int raw_getsockopt(struct sock *sk, int level, int optname,
 	return do_raw_getsockopt(sk, level, optname, optval, optlen);
 }
 
+int raw_uring_cmd(struct sock *sk, struct io_uring_cmd *cmd,
+		  unsigned int issue_flags)
+{
+	switch (cmd->sqe->cmd_op) {
+	case SOCKET_URING_OP_SIOCOUTQ:
+		return sk_wmem_alloc_get(sk);
+	case SOCKET_URING_OP_SIOCINQ: {
+		struct sk_buff *skb;
+		int amount = 0;
+
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb)
+			amount = skb->len;
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return amount;
+	}
+	default:
+		return -ENOIOCTLCMD;
+	}
+}
+EXPORT_SYMBOL_GPL(raw_uring_cmd);
+
 static int raw_ioctl(struct sock *sk, int cmd, unsigned long arg)
 {
 	switch (cmd) {
@@ -925,6 +949,7 @@ struct proto raw_prot = {
 	.connect	   = ip4_datagram_connect,
 	.disconnect	   = __udp_disconnect,
 	.ioctl		   = raw_ioctl,
+	.uring_cmd	   = raw_uring_cmd,
 	.init		   = raw_sk_init,
 	.setsockopt	   = raw_setsockopt,
 	.getsockopt	   = raw_getsockopt,
-- 
2.34.1
