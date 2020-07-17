From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:27 +0000
Subject: [PATCH 18/22] net/ipv6: factor out MCAST_MSFILTER getsockopt helpers
Message-Id: <20200717062331.691152-19-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Factor out one helper each for getting the native and compat
version of the MCAST_MSFILTER option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/ipv6/ipv6_sockglue.c | 139 +++++++++++++++++++++------------------
 1 file changed, 74 insertions(+), 65 deletions(-)

diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 6adfbdcb7979bd..ef5656f876ac05 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1071,6 +1071,77 @@ static int ipv6_getsockopt_sticky(struct sock *sk, struct ipv6_txoptions *opt,
 	return len;
 }
 
+static int ipv6_get_msfilter(struct sock *sk, void __user *optval,
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
+	if (gsf.gf_group.ss_family != AF_INET6)
+		return -EADDRNOTAVAIL;
+	num = gsf.gf_numsrc;
+	lock_sock(sk);
+	err = ip6_mc_msfget(sk, &gsf, p->gf_slist);
+	if (!err) {
+		if (num > gsf.gf_numsrc)
+			num = gsf.gf_numsrc;
+		if (put_user(GROUP_FILTER_SIZE(num), optlen) ||
+		    copy_to_user(p, &gsf, size0))
+			err = -EFAULT;
+	}
+	release_sock(sk);
+	return err;
+}
+
+#ifdef CONFIG_COMPAT
+static int compat_ipv6_get_msfilter(struct sock *sk, void __user *optval,
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
+	gf.gf_interface = gf32.gf_interface;
+	gf.gf_fmode = gf32.gf_fmode;
+	num = gf.gf_numsrc = gf32.gf_numsrc;
+	gf.gf_group = gf32.gf_group;
+
+	if (gf.gf_group.ss_family != AF_INET6)
+		return -EADDRNOTAVAIL;
+
+	lock_sock(sk);
+	err = ip6_mc_msfget(sk, &gf, p->gf_slist);
+	release_sock(sk);
+	if (err)
+		return err;
+	if (num > gf.gf_numsrc)
+		num = gf.gf_numsrc;
+	len = GROUP_FILTER_SIZE(num) - (sizeof(gf)-sizeof(gf32));
+	if (put_user(len, optlen) ||
+	    put_user(gf.gf_fmode, &p->gf_fmode) ||
+	    put_user(gf.gf_numsrc, &p->gf_numsrc))
+		return -EFAULT;
+	return 0;
+}
+#endif
+
 static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, int __user *optlen, unsigned int flags)
 {
@@ -1094,33 +1165,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		val = sk->sk_family;
 		break;
 	case MCAST_MSFILTER:
-	{
-		struct group_filter __user *p = (void __user *)optval;
-		struct group_filter gsf;
-		const int size0 = offsetof(struct group_filter, gf_slist);
-		int num;
-		int err;
-
-		if (len < size0)
-			return -EINVAL;
-		if (copy_from_user(&gsf, p, size0))
-			return -EFAULT;
-		if (gsf.gf_group.ss_family != AF_INET6)
-			return -EADDRNOTAVAIL;
-		num = gsf.gf_numsrc;
-		lock_sock(sk);
-		err = ip6_mc_msfget(sk, &gsf, p->gf_slist);
-		if (!err) {
-			if (num > gsf.gf_numsrc)
-				num = gsf.gf_numsrc;
-			if (put_user(GROUP_FILTER_SIZE(num), optlen) ||
-			    copy_to_user(p, &gsf, size0))
-				err = -EFAULT;
-		}
-		release_sock(sk);
-		return err;
-	}
-
+		return ipv6_get_msfilter(sk, optval, optlen, len);
 	case IPV6_2292PKTOPTIONS:
 	{
 		struct msghdr msg;
@@ -1481,44 +1526,8 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 	if (level != SOL_IPV6)
 		return -ENOPROTOOPT;
 
-	if (optname = MCAST_MSFILTER) {
-		const int size0 = offsetof(struct compat_group_filter, gf_slist);
-		struct compat_group_filter __user *p = (void __user *)optval;
-		struct compat_group_filter gf32;
-		struct group_filter gf;
-		int ulen, err;
-		int num;
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
-		if (gf.gf_group.ss_family != AF_INET6)
-			return -EADDRNOTAVAIL;
-		lock_sock(sk);
-		err = ip6_mc_msfget(sk, &gf, p->gf_slist);
-		release_sock(sk);
-		if (err)
-			return err;
-		if (num > gf.gf_numsrc)
-			num = gf.gf_numsrc;
-		ulen = GROUP_FILTER_SIZE(num) - (sizeof(gf)-sizeof(gf32));
-		if (put_user(ulen, optlen) ||
-		    put_user(gf.gf_fmode, &p->gf_fmode) ||
-		    put_user(gf.gf_numsrc, &p->gf_numsrc))
-			return -EFAULT;
-		return 0;
-	}
+	if (optname = MCAST_MSFILTER)
+		return compat_ipv6_get_msfilter(sk, optval, optlen);
 
 	err = do_ipv6_getsockopt(sk, level, optname, optval, optlen,
 				 MSG_CMSG_COMPAT);
-- 
2.27.0
