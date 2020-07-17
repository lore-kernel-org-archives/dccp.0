From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:21 +0000
Subject: [PATCH 12/22] netfilter: remove the compat argument to xt_copy_counters_from_user
Message-Id: <20200717062331.691152-13-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Lift the in_compat_syscall() from the callers instead.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/netfilter/x_tables.h | 2 +-
 net/ipv4/netfilter/arp_tables.c    | 3 +--
 net/ipv4/netfilter/ip_tables.c     | 3 +--
 net/ipv6/netfilter/ip6_tables.c    | 3 +--
 net/netfilter/x_tables.c           | 9 ++++-----
 5 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 5da88451853b28..b8b943ee7b8b66 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -302,7 +302,7 @@ int xt_data_to_user(void __user *dst, const void *src,
 		    int usersize, int size, int aligned_size);
 
 void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
-				 struct xt_counters_info *info, bool compat);
+				 struct xt_counters_info *info);
 struct xt_counters *xt_counters_alloc(unsigned int counters);
 
 struct xt_table *xt_register_table(struct net *net,
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index 15807fb4a65f3e..2c8a4dad39d748 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1008,8 +1008,7 @@ static int do_add_counters(struct net *net, const void __user *user,
 	struct arpt_entry *iter;
 	unsigned int addend;
 
-	paddc = xt_copy_counters_from_user(user, len, &tmp,
-					   in_compat_syscall());
+	paddc = xt_copy_counters_from_user(user, len, &tmp);
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index fbfad38f397949..161901dd1cae7f 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -1163,8 +1163,7 @@ do_add_counters(struct net *net, const void __user *user,
 	struct ipt_entry *iter;
 	unsigned int addend;
 
-	paddc = xt_copy_counters_from_user(user, len, &tmp,
-					   in_compat_syscall());
+	paddc = xt_copy_counters_from_user(user, len, &tmp);
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 96c48e91e6c7f7..fd1f8f93123188 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -1179,8 +1179,7 @@ do_add_counters(struct net *net, const void __user *user, unsigned int len)
 	struct ip6t_entry *iter;
 	unsigned int addend;
 
-	paddc = xt_copy_counters_from_user(user, len, &tmp,
-					   in_compat_syscall());
+	paddc = xt_copy_counters_from_user(user, len, &tmp);
 	if (IS_ERR(paddc))
 		return PTR_ERR(paddc);
 	t = xt_find_table_lock(net, AF_INET6, tmp.name);
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 99a468be4a59fb..32bab45af7e415 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -1033,15 +1033,14 @@ EXPORT_SYMBOL_GPL(xt_check_target);
  * @user: src pointer to userspace memory
  * @len: alleged size of userspace memory
  * @info: where to store the xt_counters_info metadata
- * @compat: true if we setsockopt call is done by 32bit task on 64bit kernel
  *
  * Copies counter meta data from @user and stores it in @info.
  *
  * vmallocs memory to hold the counters, then copies the counter data
  * from @user to the new memory and returns a pointer to it.
  *
- * If @compat is true, @info gets converted automatically to the 64bit
- * representation.
+ * If called from a compat syscall, @info gets converted automatically to the
+ * 64bit representation.
  *
  * The metadata associated with the counters is stored in @info.
  *
@@ -1049,13 +1048,13 @@ EXPORT_SYMBOL_GPL(xt_check_target);
  * If IS_ERR is false, caller has to vfree the pointer.
  */
 void *xt_copy_counters_from_user(const void __user *user, unsigned int len,
-				 struct xt_counters_info *info, bool compat)
+				 struct xt_counters_info *info)
 {
 	void *mem;
 	u64 size;
 
 #ifdef CONFIG_COMPAT
-	if (compat) {
+	if (in_compat_syscall()) {
 		/* structures only differ in size due to alignment */
 		struct compat_xt_counters_info compat_tmp;
 
-- 
2.27.0
