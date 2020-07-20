From: Christoph Hellwig <hch@lst.de>
Date: Mon, 20 Jul 2020 12:47:29 +0000
Subject: [PATCH 16/24] net/ipv6: switch ip6_mroute_setsockopt to sockptr_t
Message-Id: <20200720124737.118617-17-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/mroute6.h  |  8 ++++----
 net/ipv6/ip6mr.c         | 17 +++++++++--------
 net/ipv6/ipv6_sockglue.c |  3 ++-
 3 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/include/linux/mroute6.h b/include/linux/mroute6.h
index c4a45859f586d4..bc351a85ce9b9c 100644
--- a/include/linux/mroute6.h
+++ b/include/linux/mroute6.h
@@ -8,6 +8,7 @@
 #include <net/net_namespace.h>
 #include <uapi/linux/mroute6.h>
 #include <linux/mroute_base.h>
+#include <linux/sockptr.h>
 #include <net/fib_rules.h>
 
 #ifdef CONFIG_IPV6_MROUTE
@@ -25,7 +26,7 @@ static inline int ip6_mroute_opt(int opt)
 struct sock;
 
 #ifdef CONFIG_IPV6_MROUTE
-extern int ip6_mroute_setsockopt(struct sock *, int, char __user *, unsigned int);
+extern int ip6_mroute_setsockopt(struct sock *, int, sockptr_t, unsigned int);
 extern int ip6_mroute_getsockopt(struct sock *, int, char __user *, int __user *);
 extern int ip6_mr_input(struct sk_buff *skb);
 extern int ip6mr_ioctl(struct sock *sk, int cmd, void __user *arg);
@@ -33,9 +34,8 @@ extern int ip6mr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *ar
 extern int ip6_mr_init(void);
 extern void ip6_mr_cleanup(void);
 #else
-static inline
-int ip6_mroute_setsockopt(struct sock *sock,
-			  int optname, char __user *optval, unsigned int optlen)
+static inline int ip6_mroute_setsockopt(struct sock *sock, int optname,
+		sockptr_t optval, unsigned int optlen)
 {
 	return -ENOPROTOOPT;
 }
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 1f4d20e97c07f9..06b0d2c329b94b 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1629,7 +1629,8 @@ EXPORT_SYMBOL(mroute6_is_socket);
  *	MOSPF/PIM router set up we can clean this up.
  */
 
-int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
+int ip6_mroute_setsockopt(struct sock *sk, int optname, sockptr_t optval,
+			  unsigned int optlen)
 {
 	int ret, parent = 0;
 	struct mif6ctl vif;
@@ -1665,7 +1666,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	case MRT6_ADD_MIF:
 		if (optlen < sizeof(vif))
 			return -EINVAL;
-		if (copy_from_user(&vif, optval, sizeof(vif)))
+		if (copy_from_sockptr(&vif, optval, sizeof(vif)))
 			return -EFAULT;
 		if (vif.mif6c_mifi >= MAXMIFS)
 			return -ENFILE;
@@ -1678,7 +1679,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	case MRT6_DEL_MIF:
 		if (optlen < sizeof(mifi_t))
 			return -EINVAL;
-		if (copy_from_user(&mifi, optval, sizeof(mifi_t)))
+		if (copy_from_sockptr(&mifi, optval, sizeof(mifi_t)))
 			return -EFAULT;
 		rtnl_lock();
 		ret = mif6_delete(mrt, mifi, 0, NULL);
@@ -1697,7 +1698,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 	case MRT6_DEL_MFC_PROXY:
 		if (optlen < sizeof(mfc))
 			return -EINVAL;
-		if (copy_from_user(&mfc, optval, sizeof(mfc)))
+		if (copy_from_sockptr(&mfc, optval, sizeof(mfc)))
 			return -EFAULT;
 		if (parent = 0)
 			parent = mfc.mf6cc_parent;
@@ -1718,7 +1719,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 
 		if (optlen != sizeof(flags))
 			return -EINVAL;
-		if (get_user(flags, (int __user *)optval))
+		if (copy_from_sockptr(&flags, optval, sizeof(flags)))
 			return -EFAULT;
 		rtnl_lock();
 		mroute_clean_tables(mrt, flags);
@@ -1735,7 +1736,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 
 		if (optlen != sizeof(v))
 			return -EINVAL;
-		if (get_user(v, (int __user *)optval))
+		if (copy_from_sockptr(&v, optval, sizeof(v)))
 			return -EFAULT;
 		mrt->mroute_do_assert = v;
 		return 0;
@@ -1748,7 +1749,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 
 		if (optlen != sizeof(v))
 			return -EINVAL;
-		if (get_user(v, (int __user *)optval))
+		if (copy_from_sockptr(&v, optval, sizeof(v)))
 			return -EFAULT;
 		v = !!v;
 		rtnl_lock();
@@ -1769,7 +1770,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 
 		if (optlen != sizeof(u32))
 			return -EINVAL;
-		if (get_user(v, (u32 __user *)optval))
+		if (copy_from_sockptr(&v, optval, sizeof(v)))
 			return -EFAULT;
 		/* "pim6reg%u" should not exceed 16 bytes (IFNAMSIZ) */
 		if (v != RT_TABLE_DEFAULT && v >= 100000000)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 85892b35cff7b3..119dfaf5f4bb26 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -337,7 +337,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	valbool = (val != 0);
 
 	if (ip6_mroute_opt(optname))
-		return ip6_mroute_setsockopt(sk, optname, optval, optlen);
+		return ip6_mroute_setsockopt(sk, optname, USER_SOCKPTR(optval),
+					     optlen);
 
 	if (needs_rtnl)
 		rtnl_lock();
-- 
2.27.0
