From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:21 +0000
Subject: [PATCH 08/24] net/xfrm: switch xfrm_user_policy to sockptr_t
Message-Id: <20200720124737.118617-9-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/net/xfrm.h       | 8 +++++---
 net/ipv4/ip_sockglue.c   | 3 ++-
 net/ipv6/ipv6_sockglue.c | 3 ++-
 net/xfrm/xfrm_state.c    | 6 +++---
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index f9e1fda82ddfc0..5e81868b574a73 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -15,6 +15,7 @@
 #include <linux/audit.h>
 #include <linux/slab.h>
 #include <linux/refcount.h>
+#include <linux/sockptr.h>
 
 #include <net/sock.h>
 #include <net/dst.h>
@@ -1609,10 +1610,11 @@ int xfrm6_find_1stfragopt(struct xfrm_state *x, struct sk_buff *skb,
 void xfrm6_local_rxpmtu(struct sk_buff *skb, u32 mtu);
 int xfrm4_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
 int xfrm6_udp_encap_rcv(struct sock *sk, struct sk_buff *skb);
-int xfrm_user_policy(struct sock *sk, int optname,
-		     u8 __user *optval, int optlen);
+int xfrm_user_policy(struct sock *sk, int optname, sockptr_t optval,
+		     int optlen);
 #else
-static inline int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
+static inline int xfrm_user_policy(struct sock *sk, int optname,
+				   sockptr_t optval, int optlen)
 {
  	return -ENOPROTOOPT;
 }
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index a5ea02d7a183eb..da933f99b5d517 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1322,7 +1322,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		err = -EPERM;
 		if (!ns_capable(sock_net(sk)->user_ns, CAP_NET_ADMIN))
 			break;
-		err = xfrm_user_policy(sk, optname, optval, optlen);
+		err = xfrm_user_policy(sk, optname, USER_SOCKPTR(optval),
+				       optlen);
 		break;
 
 	case IP_TRANSPARENT:
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index add8f791229945..56a74707c61741 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -935,7 +935,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		retv = -EPERM;
 		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
 			break;
-		retv = xfrm_user_policy(sk, optname, optval, optlen);
+		retv = xfrm_user_policy(sk, optname, USER_SOCKPTR(optval),
+					optlen);
 		break;
 
 	case IPV6_ADDR_PREFERENCES:
diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 8be2d926acc21d..69520ad3d83bfb 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -2264,7 +2264,7 @@ static bool km_is_alive(const struct km_event *c)
 	return is_alive;
 }
 
-int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen)
+int xfrm_user_policy(struct sock *sk, int optname, sockptr_t optval, int optlen)
 {
 	int err;
 	u8 *data;
@@ -2274,7 +2274,7 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 	if (in_compat_syscall())
 		return -EOPNOTSUPP;
 
-	if (!optval && !optlen) {
+	if (sockptr_is_null(optval) && !optlen) {
 		xfrm_sk_policy_insert(sk, XFRM_POLICY_IN, NULL);
 		xfrm_sk_policy_insert(sk, XFRM_POLICY_OUT, NULL);
 		__sk_dst_reset(sk);
@@ -2284,7 +2284,7 @@ int xfrm_user_policy(struct sock *sk, int optname, u8 __user *optval, int optlen
 	if (optlen <= 0 || optlen > PAGE_SIZE)
 		return -EMSGSIZE;
 
-	data = memdup_user(optval, optlen);
+	data = memdup_sockptr(optval, optlen);
 	if (IS_ERR(data))
 		return PTR_ERR(data);
 
-- 
2.27.0
