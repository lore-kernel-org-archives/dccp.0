From: Christoph Hellwig <hch@lst.de>
Date: Fri, 17 Jul 2020 06:23:13 +0000
Subject: [PATCH 04/22] net: simplify cBPF setsockopt compat handling
Message-Id: <20200717062331.691152-5-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Add a helper that copies either a native or compat bpf_fprog from
userspace after verifying the length, and remove the compat setsockopt
handlers that now aren't required.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/filter.h |  4 ++--
 include/net/compat.h   |  1 -
 net/compat.c           | 45 +-----------------------------------------
 net/core/filter.c      | 23 +++++++++++++++++++++
 net/core/sock.c        | 30 ++++++++++------------------
 net/packet/af_packet.c | 33 ++++---------------------------
 6 files changed, 40 insertions(+), 96 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 0b0144752d780a..4d049c8e1fbeaa 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -502,13 +502,11 @@ static inline bool insn_is_zext(const struct bpf_insn *insn)
 		offsetof(TYPE, MEMBER);						\
 	})
 
-#ifdef CONFIG_COMPAT
 /* A struct sock_filter is architecture independent. */
 struct compat_sock_fprog {
 	u16		len;
 	compat_uptr_t	filter;	/* struct sock_filter * */
 };
-#endif
 
 struct sock_fprog_kern {
 	u16			len;
@@ -1278,4 +1276,6 @@ struct bpf_sockopt_kern {
 	s32		retval;
 };
 
+int copy_bpf_fprog_from_user(struct sock_fprog *dst, void __user *src, int len);
+
 #endif /* __LINUX_FILTER_H__ */
diff --git a/include/net/compat.h b/include/net/compat.h
index f241666117d88c..745db0d605b62b 100644
--- a/include/net/compat.h
+++ b/include/net/compat.h
@@ -61,7 +61,6 @@ int __get_compat_msghdr(struct msghdr *kmsg, struct compat_msghdr __user *umsg,
 			compat_size_t *len);
 int get_compat_msghdr(struct msghdr *, struct compat_msghdr __user *,
 		      struct sockaddr __user **, struct iovec **);
-struct sock_fprog __user *get_compat_bpf_fprog(char __user *optval);
 int put_cmsg_compat(struct msghdr*, int, int, int, void *);
 
 int cmsghdr_from_user_compat_to_kern(struct msghdr *, struct sock *,
diff --git a/net/compat.c b/net/compat.c
index 5e3041a2c37d4d..3e6c2c5ff2609c 100644
--- a/net/compat.c
+++ b/net/compat.c
@@ -335,49 +335,6 @@ void scm_detach_fds_compat(struct msghdr *kmsg, struct scm_cookie *scm)
 	__scm_destroy(scm);
 }
 
-/* allocate a 64-bit sock_fprog on the user stack for duration of syscall. */
-struct sock_fprog __user *get_compat_bpf_fprog(char __user *optval)
-{
-	struct compat_sock_fprog __user *fprog32 = (struct compat_sock_fprog __user *)optval;
-	struct sock_fprog __user *kfprog = compat_alloc_user_space(sizeof(struct sock_fprog));
-	struct compat_sock_fprog f32;
-	struct sock_fprog f;
-
-	if (copy_from_user(&f32, fprog32, sizeof(*fprog32)))
-		return NULL;
-	memset(&f, 0, sizeof(f));
-	f.len = f32.len;
-	f.filter = compat_ptr(f32.filter);
-	if (copy_to_user(kfprog, &f, sizeof(struct sock_fprog)))
-		return NULL;
-
-	return kfprog;
-}
-EXPORT_SYMBOL_GPL(get_compat_bpf_fprog);
-
-static int do_set_attach_filter(struct socket *sock, int level, int optname,
-				char __user *optval, unsigned int optlen)
-{
-	struct sock_fprog __user *kfprog;
-
-	kfprog = get_compat_bpf_fprog(optval);
-	if (!kfprog)
-		return -EFAULT;
-
-	return sock_setsockopt(sock, level, optname, (char __user *)kfprog,
-			      sizeof(struct sock_fprog));
-}
-
-static int compat_sock_setsockopt(struct socket *sock, int level, int optname,
-				char __user *optval, unsigned int optlen)
-{
-	if (optname = SO_ATTACH_FILTER ||
-	    optname = SO_ATTACH_REUSEPORT_CBPF)
-		return do_set_attach_filter(sock, level, optname,
-					    optval, optlen);
-	return sock_setsockopt(sock, level, optname, optval, optlen);
-}
-
 static int __compat_sys_setsockopt(int fd, int level, int optname,
 				   char __user *optval, unsigned int optlen)
 {
@@ -396,7 +353,7 @@ static int __compat_sys_setsockopt(int fd, int level, int optname,
 		}
 
 		if (level = SOL_SOCKET)
-			err = compat_sock_setsockopt(sock, level,
+			err = sock_setsockopt(sock, level,
 					optname, optval, optlen);
 		else if (sock->ops->compat_setsockopt)
 			err = sock->ops->compat_setsockopt(sock, level,
diff --git a/net/core/filter.c b/net/core/filter.c
index bdd2382e655d85..2bf6624796d86f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -77,6 +77,29 @@
 #include <net/transp_v6.h>
 #include <linux/btf_ids.h>
 
+int copy_bpf_fprog_from_user(struct sock_fprog *dst, void __user *src, int len)
+{
+	if (in_compat_syscall()) {
+		struct compat_sock_fprog f32;
+
+		if (len != sizeof(f32))
+			return -EINVAL;
+		if (copy_from_user(&f32, src, sizeof(f32)))
+			return -EFAULT;
+		memset(dst, 0, sizeof(*dst));
+		dst->len = f32.len;
+		dst->filter = compat_ptr(f32.filter);
+	} else {
+		if (len != sizeof(*dst))
+			return -EINVAL;
+		if (copy_from_user(dst, src, sizeof(*dst)))
+			return -EFAULT;
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL_GPL(copy_bpf_fprog_from_user);
+
 /**
  *	sk_filter_trim_cap - run a packet through a socket filter
  *	@sk: sock associated with &sk_buff
diff --git a/net/core/sock.c b/net/core/sock.c
index 11d6f77dd56207..e085df79482520 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1059,19 +1059,14 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		ret = sock_set_timeout(&sk->sk_sndtimeo, optval, optlen, optname = SO_SNDTIMEO_OLD);
 		break;
 
-	case SO_ATTACH_FILTER:
-		ret = -EINVAL;
-		if (optlen = sizeof(struct sock_fprog)) {
-			struct sock_fprog fprog;
-
-			ret = -EFAULT;
-			if (copy_from_user(&fprog, optval, sizeof(fprog)))
-				break;
+	case SO_ATTACH_FILTER: {
+		struct sock_fprog fprog;
 
+		ret = copy_bpf_fprog_from_user(&fprog, optval, optlen);
+		if (!ret)
 			ret = sk_attach_filter(&fprog, sk);
-		}
 		break;
-
+	}
 	case SO_ATTACH_BPF:
 		ret = -EINVAL;
 		if (optlen = sizeof(u32)) {
@@ -1085,19 +1080,14 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 		}
 		break;
 
-	case SO_ATTACH_REUSEPORT_CBPF:
-		ret = -EINVAL;
-		if (optlen = sizeof(struct sock_fprog)) {
-			struct sock_fprog fprog;
-
-			ret = -EFAULT;
-			if (copy_from_user(&fprog, optval, sizeof(fprog)))
-				break;
+	case SO_ATTACH_REUSEPORT_CBPF: {
+		struct sock_fprog fprog;
 
+		ret = copy_bpf_fprog_from_user(&fprog, optval, optlen);
+		if (!ret)
 			ret = sk_reuseport_attach_filter(&fprog, sk);
-		}
 		break;
-
+	}
 	case SO_ATTACH_REUSEPORT_EBPF:
 		ret = -EINVAL;
 		if (optlen = sizeof(u32)) {
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index 781fee93b7d5e3..35aee9e980536d 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1545,10 +1545,10 @@ static int fanout_set_data_cbpf(struct packet_sock *po, char __user *data,
 
 	if (sock_flag(&po->sk, SOCK_FILTER_LOCKED))
 		return -EPERM;
-	if (len != sizeof(fprog))
-		return -EINVAL;
-	if (copy_from_user(&fprog, data, len))
-		return -EFAULT;
+
+	ret = copy_bpf_fprog_from_user(&fprog, data, len);
+	if (ret)
+		return ret;
 
 	ret = bpf_prog_create_from_user(&new, &fprog, NULL, false);
 	if (ret)
@@ -4040,28 +4040,6 @@ static int packet_getsockopt(struct socket *sock, int level, int optname,
 	return 0;
 }
 
-
-#ifdef CONFIG_COMPAT
-static int compat_packet_setsockopt(struct socket *sock, int level, int optname,
-				    char __user *optval, unsigned int optlen)
-{
-	struct packet_sock *po = pkt_sk(sock->sk);
-
-	if (level != SOL_PACKET)
-		return -ENOPROTOOPT;
-
-	if (optname = PACKET_FANOUT_DATA &&
-	    po->fanout && po->fanout->type = PACKET_FANOUT_CBPF) {
-		optval = (char __user *)get_compat_bpf_fprog(optval);
-		if (!optval)
-			return -EFAULT;
-		optlen = sizeof(struct sock_fprog);
-	}
-
-	return packet_setsockopt(sock, level, optname, optval, optlen);
-}
-#endif
-
 static int packet_notifier(struct notifier_block *this,
 			   unsigned long msg, void *ptr)
 {
@@ -4549,9 +4527,6 @@ static const struct proto_ops packet_ops = {
 	.shutdown =	sock_no_shutdown,
 	.setsockopt =	packet_setsockopt,
 	.getsockopt =	packet_getsockopt,
-#ifdef CONFIG_COMPAT
-	.compat_setsockopt = compat_packet_setsockopt,
-#endif
 	.sendmsg =	packet_sendmsg,
 	.recvmsg =	packet_recvmsg,
 	.mmap =		packet_mmap,
-- 
2.27.0
