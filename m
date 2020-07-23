From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 06:08:53 +0000
Subject: [PATCH 11/26] netfilter: switch xt_copy_counters to sockptr_t
Message-Id: <20200723060908.50081-12-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/netfilter/x_tables.h |  4 ++--
 net/ipv4/netfilter/arp_tables.c    |  7 +++----
 net/ipv4/netfilter/ip_tables.c     |  7 +++----
 net/ipv6/netfilter/ip6_tables.c    |  6 +++---
 net/netfilter/x_tables.c           | 20 ++++++++++----------
 5 files changed, 21 insertions(+), 23 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index b8b943ee7b8b66..5deb099d156dcb 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -301,8 +301,8 @@ int xt_target_to_user(const struct xt_entry_target *t,
 int xt_data_to_user(void __user *dst, const void *src,
 		    int usersize, int size, int aligned_size);
 
-void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
-				 struct xt_counters_info *info);
+void *xt_copy_counters(sockptr_t arg, unsigned int len,
+		       struct xt_counters_info *info);
 struct xt_counters *xt_counters_alloc(unsigned int counters);
 
 struct xt_table *xt_register_table(struct net *net,
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 2c8a4dad39d748..6d24b686c7f00a 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -996,8 +996,7 @@ static int do_replace(struct net *net, const void __user *user,
 	return ret;
 }
 
-static int do_add_counters(struct net *net, const void __user *user,
-			   unsigned int len)
+static int do_add_counters(struct net *net, sockptr_t arg, unsigned int len)
 {
 	unsigned int i;
 	struct xt_counters_info tmp;
@@ -1008,7 +1007,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 	struct arpt_entry *iter;
 	unsigned int addend;
 
-	paddc = xt_copy_counters_from_user(user, len, &tmp);
+	paddc = xt_copy_counters(arg, len, &tmp);
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 
@@ -1420,7 +1419,7 @@ static int do_arpt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned
 		break;
 
 	case ARPT_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sock_net(sk), user, len);
+		ret = do_add_counters(sock_net(sk), USER_SOCKPTR(user), len);
 		break;
 
 	default:
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index 161901dd1cae7f..4697d09c98dc3e 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1151,8 +1151,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 }
 
 static int
-do_add_counters(struct net *net, const void __user *user,
-		unsigned int len)
+do_add_counters(struct net *net, sockptr_t arg, unsigned int len)
 {
 	unsigned int i;
 	struct xt_counters_info tmp;
@@ -1163,7 +1162,7 @@ do_add_counters(struct net *net, const void __user *user,
 	struct ipt_entry *iter;
 	unsigned int addend;
 
-	paddc = xt_copy_counters_from_user(user, len, &tmp);
+	paddc = xt_copy_counters(arg, len, &tmp);
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 
@@ -1629,7 +1628,7 @@ do_ipt_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		break;
 
 	case IPT_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sock_net(sk), user, len);
+		ret = do_add_counters(sock_net(sk), USER_SOCKPTR(user), len);
 		break;
 
 	default:
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index fd1f8f93123188..a787aba30e2db7 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1168,7 +1168,7 @@ do_replace(struct net *net, const void __user *user, unsigned int len)
 }
 
 static int
-do_add_counters(struct net *net, const void __user *user, unsigned int len)
+do_add_counters(struct net *net, sockptr_t arg, unsigned int len)
 {
 	unsigned int i;
 	struct xt_counters_info tmp;
@@ -1179,7 +1179,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len)
 	struct ip6t_entry *iter;
 	unsigned int addend;
 
-	paddc = xt_copy_counters_from_user(user, len, &tmp);
+	paddc = xt_copy_counters(arg, len, &tmp);
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 	t = xt_find_table_lock(net, AF_INET6, tmp.name);
@@ -1637,7 +1637,7 @@ do_ip6t_set_ctl(struct sock *sk, int cmd, void __user *user, unsigned int len)
 		break;
 
 	case IP6T_SO_SET_ADD_COUNTERS:
-		ret = do_add_counters(sock_net(sk), user, len);
+		ret = do_add_counters(sock_net(sk), USER_SOCKPTR(user), len);
 		break;
 
 	default:
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 32bab45af7e415..b97eb4b538fd4e 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1028,9 +1028,9 @@ int xt_check_target(struct xt_tgchk_param *par,
 EXPORT_SYMBOL_GPL(xt_check_target);
 
 /**
- * xt_copy_counters_from_user - copy counters and metadata from userspace
+ * xt_copy_counters - copy counters and metadata from a sockptr_t
  *
- * @user: src pointer to userspace memory
+ * @arg: src sockptr
  * @len: alleged size of userspace memory
  * @info: where to store the xt_counters_info metadata
  *
@@ -1047,8 +1047,8 @@ EXPORT_SYMBOL_GPL(xt_check_target);
  * Return: returns pointer that caller has to test via IS_ERR().
  * If IS_ERR is false, caller has to vfree the pointer.
  */
-void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
-				 struct xt_counters_info *info)
+void *xt_copy_counters(sockptr_t arg, unsigned int len,
+		       struct xt_counters_info *info)
 {
 	void *mem;
 	u64 size;
@@ -1062,12 +1062,12 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
 			return ERR_PTR(-EINVAL);
 
 		len -= sizeof(compat_tmp);
-		if (copy_from_user(&compat_tmp, user, sizeof(compat_tmp)) != 0)
+		if (copy_from_sockptr(&compat_tmp, arg, sizeof(compat_tmp)) != 0)
 			return ERR_PTR(-EFAULT);
 
 		memcpy(info->name, compat_tmp.name, sizeof(info->name) - 1);
 		info->num_counters = compat_tmp.num_counters;
-		user += sizeof(compat_tmp);
+		sockptr_advance(arg, sizeof(compat_tmp));
 	} else
 #endif
 	{
@@ -1075,10 +1075,10 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
 			return ERR_PTR(-EINVAL);
 
 		len -= sizeof(*info);
-		if (copy_from_user(info, user, sizeof(*info)) != 0)
+		if (copy_from_sockptr(info, arg, sizeof(*info)) != 0)
 			return ERR_PTR(-EFAULT);
 
-		user += sizeof(*info);
+		sockptr_advance(arg, sizeof(*info));
 	}
 	info->name[sizeof(info->name) - 1] = '\0';
 
@@ -1092,13 +1092,13 @@ void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
 	if (!mem)
 		return ERR_PTR(-ENOMEM);
 
-	if (copy_from_user(mem, user, len) = 0)
+	if (copy_from_sockptr(mem, arg, len) = 0)
 		return mem;
 
 	vfree(mem);
 	return ERR_PTR(-EFAULT);
 }
-EXPORT_SYMBOL_GPL(xt_copy_counters_from_user);
+EXPORT_SYMBOL_GPL(xt_copy_counters);
 
 #ifdef CONFIG_COMPAT
 int xt_compat_target_offset(const struct xt_target *target)
-- 
2.27.0
