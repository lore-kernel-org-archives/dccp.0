From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:23 +0000
Subject: [PATCH 14/22] net/ipv4: factor out MCAST_MSFILTER getsockopt helpers
Message-Id: <20200717062331.691152-15-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Factor out one helper each for getting the native and compat
version of the MCAST_MSFILTER option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/ipv4/ip_sockglue.c | 131 ++++++++++++++++++++++-------------------
 1 file changed, 70 insertions(+), 61 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 95f4248c6fc5ed..70d32c9476a2e3 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1468,6 +1468,74 @@ static bool getsockopt_needs_rtnl(int optname)
 	return false;
 }
 
+static int ip_get_mcast_msfilter(struct sock *sk, void __user *optval,
+		int __user *optlen, int len)
+{
+	const int size0 = offsetof(struct group_filter, gf_slist);
+	struct group_filter __user *p = optval;
+	struct group_filter gsf;
+	int num;
+	int err;
+
+	if (len < size0)
+		return -EINVAL;
+	if (copy_from_user(&gsf, p, size0))
+		return -EFAULT;
+
+	num = gsf.gf_numsrc;
+	err = ip_mc_gsfget(sk, &gsf, p->gf_slist);
+	if (err)
+		return err;
+	if (gsf.gf_numsrc < num)
+		num = gsf.gf_numsrc;
+	if (put_user(GROUP_FILTER_SIZE(num), optlen) ||
+	    copy_to_user(p, &gsf, size0))
+		return -EFAULT;
+	return 0;
+}
+
+#ifdef CONFIG_COMPAT
+static int compat_ip_get_mcast_msfilter(struct sock *sk, void __user *optval,
+		int __user *optlen)
+{
+	const int size0 = offsetof(struct compat_group_filter, gf_slist);
+	struct compat_group_filter __user *p = optval;
+	struct compat_group_filter gf32;
+	struct group_filter gf;
+	int len, err;
+	int num;
+
+	if (get_user(len, optlen))
+		return -EFAULT;
+	if (len < size0)
+		return -EINVAL;
+
+	if (copy_from_user(&gf32, p, size0))
+		return -EFAULT;
+
+	gf.gf_interface = gf32.gf_interface;
+	gf.gf_fmode = gf32.gf_fmode;
+	num = gf.gf_numsrc = gf32.gf_numsrc;
+	gf.gf_group = gf32.gf_group;
+
+	rtnl_lock();
+	lock_sock(sk);
+	err = ip_mc_gsfget(sk, &gf, p->gf_slist);
+	release_sock(sk);
+	rtnl_unlock();
+	if (err)
+		return err;
+	if (gf.gf_numsrc < num)
+		num = gf.gf_numsrc;
+	len = GROUP_FILTER_SIZE(num) - (sizeof(gf) - sizeof(gf32));
+	if (put_user(len, optlen) ||
+	    put_user(gf.gf_fmode, &p->gf_fmode) ||
+	    put_user(gf.gf_numsrc, &p->gf_numsrc))
+		return -EFAULT;
+	return 0;
+}
+#endif
+
 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 			    char __user *optval, int __user *optlen, unsigned int flags)
 {
@@ -1626,31 +1694,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		goto out;
 	}
 	case MCAST_MSFILTER:
-	{
-		struct group_filter __user *p = (void __user *)optval;
-		struct group_filter gsf;
-		const int size0 = offsetof(struct group_filter, gf_slist);
-		int num;
-
-		if (len < size0) {
-			err = -EINVAL;
-			goto out;
-		}
-		if (copy_from_user(&gsf, p, size0)) {
-			err = -EFAULT;
-			goto out;
-		}
-		num = gsf.gf_numsrc;
-		err = ip_mc_gsfget(sk, &gsf, p->gf_slist);
-		if (err)
-			goto out;
-		if (gsf.gf_numsrc < num)
-			num = gsf.gf_numsrc;
-		if (put_user(GROUP_FILTER_SIZE(num), optlen) ||
-		    copy_to_user(p, &gsf, size0))
-			err = -EFAULT;
+		err = ip_get_mcast_msfilter(sk, optval, optlen, len);
 		goto out;
-	}
 	case IP_MULTICAST_ALL:
 		val = inet->mc_all;
 		break;
@@ -1762,45 +1807,9 @@ int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 	int err;
 
 	if (optname = MCAST_MSFILTER) {
-		const int size0 = offsetof(struct compat_group_filter, gf_slist);
-		struct compat_group_filter __user *p = (void __user *)optval;
-		struct compat_group_filter gf32;
-		struct group_filter gf;
-		int ulen, err;
-		int num;
-
 		if (level != SOL_IP)
 			return -EOPNOTSUPP;
-
-		if (get_user(ulen, optlen))
-			return -EFAULT;
-
-		if (ulen < size0)
-			return -EINVAL;
-
-		if (copy_from_user(&gf32, p, size0))
-			return -EFAULT;
-
-		gf.gf_interface = gf32.gf_interface;
-		gf.gf_fmode = gf32.gf_fmode;
-		num = gf.gf_numsrc = gf32.gf_numsrc;
-		gf.gf_group = gf32.gf_group;
-
-		rtnl_lock();
-		lock_sock(sk);
-		err = ip_mc_gsfget(sk, &gf, p->gf_slist);
-		release_sock(sk);
-		rtnl_unlock();
-		if (err)
-			return err;
-		if (gf.gf_numsrc < num)
-			num = gf.gf_numsrc;
-		ulen = GROUP_FILTER_SIZE(num) - (sizeof(gf) - sizeof(gf32));
-		if (put_user(ulen, optlen) ||
-		    put_user(gf.gf_fmode, &p->gf_fmode) ||
-		    put_user(gf.gf_numsrc, &p->gf_numsrc))
-			return -EFAULT;
-		return 0;
+		return compat_ip_get_mcast_msfilter(sk, optval, optlen);
 	}
 
 	err = do_ip_getsockopt(sk, level, optname, optval, optlen,
-- 
2.27.0
