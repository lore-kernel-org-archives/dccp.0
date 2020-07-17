From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:20 +0000
Subject: [PATCH 11/22] netfilter: remove the compat_{get,set} methods
Message-Id: <20200717062331.691152-12-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

All instances handle compat sockopts via in_compat_syscall() now, so
remove the compat_{get,set} methods as well as the
compat_nf_{get,set}sockopt wrappers.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/netfilter.h  | 14 -------------
 net/ipv4/ip_sockglue.c     |  5 ++---
 net/ipv6/ipv6_sockglue.c   |  5 ++---
 net/netfilter/nf_sockopt.c | 42 --------------------------------------
 4 files changed, 4 insertions(+), 62 deletions(-)

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index eb312e7ca36ee5..711b4d4486f042 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -164,17 +164,9 @@ struct nf_sockopt_ops {
 	int set_optmin;
 	int set_optmax;
 	int (*set)(struct sock *sk, int optval, void __user *user, unsigned int len);
-#ifdef CONFIG_COMPAT
-	int (*compat_set)(struct sock *sk, int optval,
-			void __user *user, unsigned int len);
-#endif
 	int get_optmin;
 	int get_optmax;
 	int (*get)(struct sock *sk, int optval, void __user *user, int *len);
-#ifdef CONFIG_COMPAT
-	int (*compat_get)(struct sock *sk, int optval,
-			void __user *user, int *len);
-#endif
 	/* Use the module struct to lock set/get code in place */
 	struct module *owner;
 };
@@ -350,12 +342,6 @@ int nf_setsockopt(struct sock *sk, u_int8_t pf, int optval, char __user *opt,
 		  unsigned int len);
 int nf_getsockopt(struct sock *sk, u_int8_t pf, int optval, char __user *opt,
 		  int *len);
-#ifdef CONFIG_COMPAT
-int compat_nf_setsockopt(struct sock *sk, u_int8_t pf, int optval,
-		char __user *opt, unsigned int len);
-int compat_nf_getsockopt(struct sock *sk, u_int8_t pf, int optval,
-		char __user *opt, int *len);
-#endif
 
 struct flowi;
 struct nf_queue_entry;
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 84ec3703c90916..95f4248c6fc5ed 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1446,8 +1446,7 @@ int compat_ip_setsockopt(struct sock *sk, int level, int optname,
 			optname != IP_IPSEC_POLICY &&
 			optname != IP_XFRM_POLICY &&
 			!ip_mroute_opt(optname))
-		err = compat_nf_setsockopt(sk, PF_INET, optname, optval,
-					   optlen);
+		err = nf_setsockopt(sk, PF_INET, optname, optval, optlen);
 #endif
 	return err;
 }
@@ -1821,7 +1820,7 @@ int compat_ip_getsockopt(struct sock *sk, int level, int optname,
 		if (get_user(len, optlen))
 			return -EFAULT;
 
-		err = compat_nf_getsockopt(sk, PF_INET, optname, optval, &len);
+		err = nf_getsockopt(sk, PF_INET, optname, optval, &len);
 		if (err >= 0)
 			err = put_user(len, optlen);
 		return err;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 6ab44ec2c369da..6adfbdcb7979bd 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -1030,8 +1030,7 @@ int compat_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	/* we need to exclude all possible ENOPROTOOPTs except default case */
 	if (err = -ENOPROTOOPT && optname != IPV6_IPSEC_POLICY &&
 	    optname != IPV6_XFRM_POLICY)
-		err = compat_nf_setsockopt(sk, PF_INET6, optname, optval,
-					   optlen);
+		err = nf_setsockopt(sk, PF_INET6, optname, optval, optlen);
 #endif
 	return err;
 }
@@ -1531,7 +1530,7 @@ int compat_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		if (get_user(len, optlen))
 			return -EFAULT;
 
-		err = compat_nf_getsockopt(sk, PF_INET6, optname, optval, &len);
+		err = nf_getsockopt(sk, PF_INET6, optname, optval, &len);
 		if (err >= 0)
 			err = put_user(len, optlen);
 	}
diff --git a/net/netfilter/nf_sockopt.c b/net/netfilter/nf_sockopt.c
index 46cb3786e0ec5c..02870993d335c9 100644
--- a/net/netfilter/nf_sockopt.c
+++ b/net/netfilter/nf_sockopt.c
@@ -122,45 +122,3 @@ int nf_getsockopt(struct sock *sk, u_int8_t pf, int val, char __user *opt,
 	return nf_sockopt(sk, pf, val, opt, len, 1);
 }
 EXPORT_SYMBOL(nf_getsockopt);
-
-#ifdef CONFIG_COMPAT
-static int compat_nf_sockopt(struct sock *sk, u_int8_t pf, int val,
-			     char __user *opt, int *len, int get)
-{
-	struct nf_sockopt_ops *ops;
-	int ret;
-
-	ops = nf_sockopt_find(sk, pf, val, get);
-	if (IS_ERR(ops))
-		return PTR_ERR(ops);
-
-	if (get) {
-		if (ops->compat_get)
-			ret = ops->compat_get(sk, val, opt, len);
-		else
-			ret = ops->get(sk, val, opt, len);
-	} else {
-		if (ops->compat_set)
-			ret = ops->compat_set(sk, val, opt, *len);
-		else
-			ret = ops->set(sk, val, opt, *len);
-	}
-
-	module_put(ops->owner);
-	return ret;
-}
-
-int compat_nf_setsockopt(struct sock *sk, u_int8_t pf,
-		int val, char __user *opt, unsigned int len)
-{
-	return compat_nf_sockopt(sk, pf, val, opt, &len, 0);
-}
-EXPORT_SYMBOL(compat_nf_setsockopt);
-
-int compat_nf_getsockopt(struct sock *sk, u_int8_t pf,
-		int val, char __user *opt, int *len)
-{
-	return compat_nf_sockopt(sk, pf, val, opt, len, 1);
-}
-EXPORT_SYMBOL(compat_nf_getsockopt);
-#endif
-- 
2.27.0
