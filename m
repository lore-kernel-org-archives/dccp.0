From: Christoph Hellwig <hch@lst.de>
Date: Thu, 23 Jul 2020 06:08:47 +0000
Subject: [PATCH 05/26] net: switch copy_bpf_fprog_from_user to sockptr_t
Message-Id: <20200723060908.50081-6-hch@lst.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pass a sockptr_t to prepare for set_fs-less handling of the kernel
pointer from bpf-cgroup.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 include/linux/filter.h | 3 ++-
 net/core/filter.c      | 6 +++---
 net/core/sock.c        | 6 ++++--
 net/packet/af_packet.c | 4 ++--
 4 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 1c6b6d982bf498..d07a6e973a7d6f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -20,6 +20,7 @@
 #include <linux/kallsyms.h>
 #include <linux/if_vlan.h>
 #include <linux/vmalloc.h>
+#include <linux/sockptr.h>
 #include <crypto/sha.h>
 
 #include <net/sch_generic.h>
@@ -1276,7 +1277,7 @@ struct bpf_sockopt_kern {
 	s32		retval;
 };
 
-int copy_bpf_fprog_from_user(struct sock_fprog *dst, void __user *src, int len);
+int copy_bpf_fprog_from_user(struct sock_fprog *dst, sockptr_t src, int len);
 
 struct bpf_sk_lookup_kern {
 	u16		family;
diff --git a/net/core/filter.c b/net/core/filter.c
index 3fa16b8c0d616a..29e3455122f772 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -77,14 +77,14 @@
 #include <net/transp_v6.h>
 #include <linux/btf_ids.h>
 
-int copy_bpf_fprog_from_user(struct sock_fprog *dst, void __user *src, int len)
+int copy_bpf_fprog_from_user(struct sock_fprog *dst, sockptr_t src, int len)
 {
 	if (in_compat_syscall()) {
 		struct compat_sock_fprog f32;
 
 		if (len != sizeof(f32))
 			return -EINVAL;
-		if (copy_from_user(&f32, src, sizeof(f32)))
+		if (copy_from_sockptr(&f32, src, sizeof(f32)))
 			return -EFAULT;
 		memset(dst, 0, sizeof(*dst));
 		dst->len = f32.len;
@@ -92,7 +92,7 @@ int copy_bpf_fprog_from_user(struct sock_fprog *dst, void __user *src, int len)
 	} else {
 		if (len != sizeof(*dst))
 			return -EINVAL;
-		if (copy_from_user(dst, src, sizeof(*dst)))
+		if (copy_from_sockptr(dst, src, sizeof(*dst)))
 			return -EFAULT;
 	}
 
diff --git a/net/core/sock.c b/net/core/sock.c
index 6da54eac2b3456..71fc7e4ddd0648 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1063,7 +1063,8 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_ATTACH_FILTER: {
 		struct sock_fprog fprog;
 
-		ret = copy_bpf_fprog_from_user(&fprog, optval, optlen);
+		ret = copy_bpf_fprog_from_user(&fprog, USER_SOCKPTR(optval),
+					       optlen);
 		if (!ret)
 			ret = sk_attach_filter(&fprog, sk);
 		break;
@@ -1084,7 +1085,8 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	case SO_ATTACH_REUSEPORT_CBPF: {
 		struct sock_fprog fprog;
 
-		ret = copy_bpf_fprog_from_user(&fprog, optval, optlen);
+		ret = copy_bpf_fprog_from_user(&fprog, USER_SOCKPTR(optval),
+					       optlen);
 		if (!ret)
 			ret = sk_reuseport_attach_filter(&fprog, sk);
 		break;
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index c240fb5de3f014..d8d4f78f78e451 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1536,7 +1536,7 @@ static void __fanout_set_data_bpf(struct packet_fanout *f, struct bpf_prog *new)
 	}
 }
 
-static int fanout_set_data_cbpf(struct packet_sock *po, char __user *data,
+static int fanout_set_data_cbpf(struct packet_sock *po, sockptr_t data,
 				unsigned int len)
 {
 	struct bpf_prog *new;
@@ -1584,7 +1584,7 @@ static int fanout_set_data(struct packet_sock *po, char __user *data,
 {
 	switch (po->fanout->type) {
 	case PACKET_FANOUT_CBPF:
-		return fanout_set_data_cbpf(po, data, len);
+		return fanout_set_data_cbpf(po, USER_SOCKPTR(data), len);
 	case PACKET_FANOUT_EBPF:
 		return fanout_set_data_ebpf(po, data, len);
 	default:
-- 
2.27.0
