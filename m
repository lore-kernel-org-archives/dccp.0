From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 06:09:08 +0000
Subject: [PATCH 26/26] net: optimize the sockptr_t for unified kernel/user address spaces
Message-Id: <20200723060908.50081-27-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

For architectures like x86 and arm64 we don't need the separate bit to
indicate that a pointer is a kernel pointer as the address spaces are
unified.  That way the sockptr_t can be reduced to a union of two
pointers, which leads to nicer calling conventions.

The only caveat is that we need to check that users don't pass in kernel
address and thus gain access to kernel memory.  Thus the USER_SOCKPTR
helper is replaced with a init_user_sockptr function that does this check
and returns an error if it fails.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/sockptr.h     | 32 ++++++++++++++++++++++++++++++--
 net/ipv4/bpfilter/sockopt.c | 14 ++++++++------
 net/socket.c                |  6 +++++-
 3 files changed, 43 insertions(+), 9 deletions(-)

diff --git a/include/linux/sockptr.h b/include/linux/sockptr.h
index 700856e13ea0c4..7d5cdb2b30b5f0 100644
--- a/include/linux/sockptr.h
+++ b/include/linux/sockptr.h
@@ -8,9 +8,34 @@
 #ifndef _LINUX_SOCKPTR_H
 #define _LINUX_SOCKPTR_H
 
+#include <linux/compiler.h>
 #include <linux/slab.h>
 #include <linux/uaccess.h>
 
+#ifdef CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE
+typedef union {
+	void		*kernel;
+	void __user	*user;
+} sockptr_t;
+
+static inline bool sockptr_is_kernel(sockptr_t sockptr)
+{
+	return (unsigned long)sockptr.kernel >= TASK_SIZE;
+}
+
+static inline sockptr_t KERNEL_SOCKPTR(void *p)
+{
+	return (sockptr_t) { .kernel = p };
+}
+
+static inline int __must_check init_user_sockptr(sockptr_t *sp, void __user *p)
+{
+	if ((unsigned long)p >= TASK_SIZE)
+		return -EFAULT;
+	sp->user = p;
+	return 0;
+}
+#else /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
 typedef struct {
 	union {
 		void		*kernel;
@@ -29,10 +54,13 @@ static inline sockptr_t KERNEL_SOCKPTR(void *p)
 	return (sockptr_t) { .kernel = p, .is_kernel = true };
 }
 
-static inline sockptr_t USER_SOCKPTR(void __user *p)
+static inline int __must_check init_user_sockptr(sockptr_t *sp, void __user *p)
 {
-	return (sockptr_t) { .user = p };
+	sp->user = p;
+	sp->is_kernel = false;
+	return 0;
 }
+#endif /* CONFIG_ARCH_HAS_NON_OVERLAPPING_ADDRESS_SPACE */
 
 static inline bool sockptr_is_null(sockptr_t sockptr)
 {
diff --git a/net/ipv4/bpfilter/sockopt.c b/net/ipv4/bpfilter/sockopt.c
index 1b34cb9a7708ec..94f18d2352d007 100644
--- a/net/ipv4/bpfilter/sockopt.c
+++ b/net/ipv4/bpfilter/sockopt.c
@@ -57,16 +57,18 @@ int bpfilter_ip_set_sockopt(struct sock *sk, int optname, sockptr_t optval,
 	return bpfilter_mbox_request(sk, optname, optval, optlen, true);
 }
 
-int bpfilter_ip_get_sockopt(struct sock *sk, int optname, char __user *optval,
-			    int __user *optlen)
+int bpfilter_ip_get_sockopt(struct sock *sk, int optname,
+			    char __user *user_optval, int __user *optlen)
 {
-	int len;
+	sockptr_t optval;
+	int err, len;
 
 	if (get_user(len, optlen))
 		return -EFAULT;
-
-	return bpfilter_mbox_request(sk, optname, USER_SOCKPTR(optval), len,
-				     false);
+	err = init_user_sockptr(&optval, user_optval);
+	if (err)
+		return err;
+	return bpfilter_mbox_request(sk, optname, optval, len, false);
 }
 
 static int __init bpfilter_sockopt_init(void)
diff --git a/net/socket.c b/net/socket.c
index e44b8ac47f6f46..94ca4547cd7c53 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -2097,7 +2097,7 @@ static bool sock_use_custom_sol_socket(const struct socket *sock)
 int __sys_setsockopt(int fd, int level, int optname, char __user *user_optval,
 		int optlen)
 {
-	sockptr_t optval = USER_SOCKPTR(user_optval);
+	sockptr_t optval;
 	char *kernel_optval = NULL;
 	int err, fput_needed;
 	struct socket *sock;
@@ -2105,6 +2105,10 @@ int __sys_setsockopt(int fd, int level, int optname, char __user *user_optval,
 	if (optlen < 0)
 		return -EINVAL;
 
+	err = init_user_sockptr(&optval, user_optval);
+	if (err)
+		return err;
+
 	sock = sockfd_lookup_light(fd, &err, &fput_needed);
 	if (!sock)
 		return err;
-- 
2.27.0
