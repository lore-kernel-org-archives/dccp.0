From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:24 +0000
Subject: [PATCH 15/22] net/ipv4: factor out MCAST_MSFILTER setsockopt helpers
Message-Id: <20200717062331.691152-16-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Factor out one helper each for setting the native and compat
version of the MCAST_MSFILTER option.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 net/ipv4/ip_sockglue.c | 162 ++++++++++++++++++++++-------------------
 1 file changed, 86 insertions(+), 76 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 70d32c9476a2e3..b587dee006f882 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -722,6 +722,90 @@ static int do_mcast_group_source(struct sock *sk, int optname,
 	return ip_mc_source(add, omode, sk, &mreqs, greqs->gsr_interface);
 }
 
+static int ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
+		int optlen)
+{
+	struct group_filter *gsf = NULL;
+	int err;
+
+	if (optlen < GROUP_FILTER_SIZE(0))
+		return -EINVAL;
+	if (optlen > sysctl_optmem_max)
+		return -ENOBUFS;
+
+	gsf = memdup_user(optval, optlen);
+	if (IS_ERR(gsf))
+		return PTR_ERR(gsf);
+
+	/* numsrc >= (4G-140)/128 overflow in 32 bits */
+	err = -ENOBUFS;
+	if (gsf->gf_numsrc >= 0x1ffffff ||
+	    gsf->gf_numsrc > sock_net(sk)->ipv4.sysctl_igmp_max_msf)
+		goto out_free_gsf;
+
+	err = -EINVAL;
+	if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen)
+		goto out_free_gsf;
+
+	err = set_mcast_msfilter(sk, gsf->gf_interface, gsf->gf_numsrc,
+				 gsf->gf_fmode, &gsf->gf_group, gsf->gf_slist);
+out_free_gsf:
+	kfree(gsf);
+	return err;
+}
+
+#ifdef CONFIG_COMPAT
+static int compat_ip_set_mcast_msfilter(struct sock *sk, void __user *optval,
+		int optlen)
+{
+	const int size0 = offsetof(struct compat_group_filter, gf_slist);
+	struct compat_group_filter *gf32;
+	unsigned int n;
+	void *p;
+	int err;
+
+	if (optlen < size0)
+		return -EINVAL;
+	if (optlen > sysctl_optmem_max - 4)
+		return -ENOBUFS;
+
+	p = kmalloc(optlen + 4, GFP_KERNEL);
+	if (!p)
+		return -ENOMEM;
+	gf32 = p + 4; /* we want ->gf_group and ->gf_slist aligned */
+
+	err = -EFAULT;
+	if (copy_from_user(gf32, optval, optlen))
+		goto out_free_gsf;
+
+	/* numsrc >= (4G-140)/128 overflow in 32 bits */
+	n = gf32->gf_numsrc;
+	err = -ENOBUFS;
+	if (n >= 0x1ffffff)
+		goto out_free_gsf;
+
+	err = -EINVAL;
+	if (offsetof(struct compat_group_filter, gf_slist[n]) > optlen)
+		goto out_free_gsf;
+
+	rtnl_lock();
+	lock_sock(sk);
+
+	/* numsrc >= (4G-140)/128 overflow in 32 bits */
+	err = -ENOBUFS;
+	if (n > sock_net(sk)->ipv4.sysctl_igmp_max_msf)
+		goto out_unlock;
+	err = set_mcast_msfilter(sk, gf32->gf_interface, n, gf32->gf_fmode,
+				 &gf32->gf_group, gf32->gf_slist);
+out_unlock:
+	release_sock(sk);
+	rtnl_unlock();
+out_free_gsf:
+	kfree(p);
+	return err;
+}
+#endif
+
 static int do_ip_setsockopt(struct sock *sk, int level,
 			    int optname, char __user *optval, unsigned int optlen)
 {
@@ -1167,37 +1251,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		break;
 	}
 	case MCAST_MSFILTER:
-	{
-		struct group_filter *gsf = NULL;
-
-		if (optlen < GROUP_FILTER_SIZE(0))
-			goto e_inval;
-		if (optlen > sysctl_optmem_max) {
-			err = -ENOBUFS;
-			break;
-		}
-		gsf = memdup_user(optval, optlen);
-		if (IS_ERR(gsf)) {
-			err = PTR_ERR(gsf);
-			break;
-		}
-		/* numsrc >= (4G-140)/128 overflow in 32 bits */
-		if (gsf->gf_numsrc >= 0x1ffffff ||
-		    gsf->gf_numsrc > net->ipv4.sysctl_igmp_max_msf) {
-			err = -ENOBUFS;
-			goto mc_msf_out;
-		}
-		if (GROUP_FILTER_SIZE(gsf->gf_numsrc) > optlen) {
-			err = -EINVAL;
-			goto mc_msf_out;
-		}
-		err = set_mcast_msfilter(sk, gsf->gf_interface,
-					 gsf->gf_numsrc, gsf->gf_fmode,
-					 &gsf->gf_group, gsf->gf_slist);
-mc_msf_out:
-		kfree(gsf);
+		err = ip_set_mcast_msfilter(sk, optval, optlen);
 		break;
-	}
 	case IP_MULTICAST_ALL:
 		if (optlen < 1)
 			goto e_inval;
@@ -1391,52 +1446,7 @@ int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 		return err;
 	}
 	case MCAST_MSFILTER:
-	{
-		const int size0 = offsetof(struct compat_group_filter, gf_slist);
-		struct compat_group_filter *gf32;
-		unsigned int n;
-		void *p;
-
-		if (optlen < size0)
-			return -EINVAL;
-		if (optlen > sysctl_optmem_max - 4)
-			return -ENOBUFS;
-
-		p = kmalloc(optlen + 4, GFP_KERNEL);
-		if (!p)
-			return -ENOMEM;
-		gf32 = p + 4; /* we want ->gf_group and ->gf_slist aligned */
-		if (copy_from_user(gf32, optval, optlen)) {
-			err = -EFAULT;
-			goto mc_msf_out;
-		}
-
-		n = gf32->gf_numsrc;
-		/* numsrc >= (4G-140)/128 overflow in 32 bits */
-		if (n >= 0x1ffffff) {
-			err = -ENOBUFS;
-			goto mc_msf_out;
-		}
-		if (offsetof(struct compat_group_filter, gf_slist[n]) > optlen) {
-			err = -EINVAL;
-			goto mc_msf_out;
-		}
-
-		rtnl_lock();
-		lock_sock(sk);
-		/* numsrc >= (4G-140)/128 overflow in 32 bits */
-		if (n > sock_net(sk)->ipv4.sysctl_igmp_max_msf)
-			err = -ENOBUFS;
-		else
-			err = set_mcast_msfilter(sk, gf32->gf_interface,
-						 n, gf32->gf_fmode,
-						 &gf32->gf_group, gf32->gf_slist);
-		release_sock(sk);
-		rtnl_unlock();
-mc_msf_out:
-		kfree(p);
-		return err;
-	}
+		return compat_ip_set_mcast_msfilter(sk, optval, optlen);
 	}
 
 	err = do_ip_setsockopt(sk, level, optname, optval, optlen);
-- 
2.27.0
