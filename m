From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:26 +0000
Subject: [PATCH 13/24] net/ipv4: switch ip_mroute_setsockopt to sockptr_t
Message-Id: <20200720124737.118617-14-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/mroute.h |  5 +++--
 net/ipv4/ip_sockglue.c |  3 ++-
 net/ipv4/ipmr.c        | 14 +++++++-------
 3 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 9a36fad9e068f6..6cbbfe94348cee 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -8,6 +8,7 @@
 #include <net/fib_notifier.h>
 #include <uapi/linux/mroute.h>
 #include <linux/mroute_base.h>
+#include <linux/sockptr.h>
 
 #ifdef CONFIG_IP_MROUTE
 static inline int ip_mroute_opt(int opt)
@@ -15,7 +16,7 @@ static inline int ip_mroute_opt(int opt)
 	return opt >= MRT_BASE && opt <= MRT_MAX;
 }
 
-int ip_mroute_setsockopt(struct sock *, int, char __user *, unsigned int);
+int ip_mroute_setsockopt(struct sock *, int, sockptr_t, unsigned int);
 int ip_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 int ipmr_ioctl(struct sock *sk, int cmd, void __user *arg);
 int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
@@ -23,7 +24,7 @@ int ip_mr_init(void);
 bool ipmr_rule_default(const struct fib_rule *rule);
 #else
 static inline int ip_mroute_setsockopt(struct sock *sock, int optname,
-				       char __user *optval, unsigned int optlen)
+				       sockptr_t optval, unsigned int optlen)
 {
 	return -ENOPROTOOPT;
 }
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 36f746e01741f6..ac495b0cff8ffb 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -925,7 +925,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 	if (optname = IP_ROUTER_ALERT)
 		return ip_ra_control(sk, val ? 1 : 0, NULL);
 	if (ip_mroute_opt(optname))
-		return ip_mroute_setsockopt(sk, optname, optval, optlen);
+		return ip_mroute_setsockopt(sk, optname, USER_SOCKPTR(optval),
+					    optlen);
 
 	err = 0;
 	if (needs_rtnl)
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 678639c01e4882..cdf3a40f9ff5fc 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1341,7 +1341,7 @@ static void mrtsock_destruct(struct sock *sk)
  * MOSPF/PIM router set up we can clean this up.
  */
 
-int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
+int ip_mroute_setsockopt(struct sock *sk, int optname, sockptr_t optval,
 			 unsigned int optlen)
 {
 	struct net *net = sock_net(sk);
@@ -1413,7 +1413,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (copy_from_user(&vif, optval, sizeof(vif))) {
+		if (copy_from_sockptr(&vif, optval, sizeof(vif))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1441,7 +1441,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (copy_from_user(&mfc, optval, sizeof(mfc))) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1459,7 +1459,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)optval)) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1471,7 +1471,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)optval)) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1486,7 +1486,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(val, (int __user *)optval)) {
+		if (copy_from_sockptr(&val, optval, sizeof(val))) {
 			ret = -EFAULT;
 			break;
 		}
@@ -1508,7 +1508,7 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval,
 			ret = -EINVAL;
 			break;
 		}
-		if (get_user(uval, (u32 __user *)optval)) {
+		if (copy_from_sockptr(&uval, optval, sizeof(uval))) {
 			ret = -EFAULT;
 			break;
 		}
-- 
2.27.0
