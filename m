From: Breno Leitao <leitao@debian.org>
Date: Mon, 19 Jun 2023 11:20:35 +0000
Subject: Re: [RFC PATCH v2 1/4] net: wire up support for file_operations->uring_cmd()
Message-Id: <ZJA6AwbRWtSiJ5pL@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230614110757.3689731-2-leitao@debian.org>
In-Reply-To: <20230614110757.3689731-2-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jun 14, 2023 at 08:15:10AM -0700, David Ahern wrote:
> On 6/14/23 5:07 AM, Breno Leitao wrote:
> io_uring is just another in-kernel user of sockets. There is no reason
> for io_uring references to be in core net code. It should be using
> exposed in-kernel APIs and doing any translation of its op codes in
> io_uring/  code.

Thanks for the feedback. If we want to keep the network subsystem
untouched, then I we can do it using an approach similar to the
following. Is this a better approach moving forward?

--

From: Breno Leitao <leitao@debian.org>
Date: Mon, 19 Jun 2023 03:37:40 -0700
Subject: [RFC PATCH v2] io_uring: add initial io_uring_cmd support for sockets

Enable io_uring command operations on sockets. Create two
SOCKET_URING_OP commands that will operate on sockets.

For that, use the file_operations->uring_cmd callback, and map it to a
uring socket callback, which handles the SOCKET_URING_OP accordingly.

Signed-off-by: Breno Leitao <leitao@debian.org>
---
 include/linux/io_uring.h      |  6 ++++++
 include/uapi/linux/io_uring.h |  8 ++++++++
 io_uring/uring_cmd.c          | 27 +++++++++++++++++++++++++++
 net/socket.c                  |  2 ++
 4 files changed, 43 insertions(+)

diff --git a/include/linux/io_uring.h b/include/linux/io_uring.h
index 7fe31b2cd02f..d1b20e2a9fb0 100644
--- a/include/linux/io_uring.h
+++ b/include/linux/io_uring.h
@@ -71,6 +71,7 @@ static inline void io_uring_free(struct task_struct *tsk)
 	if (tsk->io_uring)
 		__io_uring_free(tsk);
 }
+int uring_sock_cmd(struct io_uring_cmd *cmd, unsigned int issue_flags);
 #else
 static inline int io_uring_cmd_import_fixed(u64 ubuf, unsigned long len, int rw,
 			      struct iov_iter *iter, void *ioucmd)
@@ -102,6 +103,11 @@ static inline const char *io_uring_get_opcode(u8 opcode)
 {
 	return "";
 }
+static inline int uring_sock_cmd(struct io_uring_cmd *cmd,
+				 unsigned int issue_flags)
+{
+	return -EOPNOTSUPP;
+}
 #endif
 
 #endif
diff --git a/include/uapi/linux/io_uring.h b/include/uapi/linux/io_uring.h
index 0716cb17e436..d93a5ee7d984 100644
--- a/include/uapi/linux/io_uring.h
+++ b/include/uapi/linux/io_uring.h
@@ -703,6 +703,14 @@ struct io_uring_recvmsg_out {
 	__u32 flags;
 };
 
+/*
+ * Argument for IORING_OP_URING_CMD when file is a socket
+ */
+enum {
+	SOCKET_URING_OP_SIOCINQ         = 0,
+	SOCKET_URING_OP_SIOCOUTQ,
+};
+
 #ifdef __cplusplus
 }
 #endif
diff --git a/io_uring/uring_cmd.c b/io_uring/uring_cmd.c
index 5e32db48696d..dcbe6493b03f 100644
--- a/io_uring/uring_cmd.c
+++ b/io_uring/uring_cmd.c
@@ -7,6 +7,7 @@
 #include <linux/nospec.h>
 
 #include <uapi/linux/io_uring.h>
+#include <uapi/asm-generic/ioctls.h>
 
 #include "io_uring.h"
 #include "rsrc.h"
@@ -156,3 +157,29 @@ int io_uring_cmd_import_fixed(u64 ubuf, unsigned long len, int rw,
 	return io_import_fixed(rw, iter, req->imu, ubuf, len);
 }
 EXPORT_SYMBOL_GPL(io_uring_cmd_import_fixed);
+
+int uring_sock_cmd(struct io_uring_cmd *cmd, unsigned int issue_flags)
+{
+	struct socket *sock = cmd->file->private_data;
+	struct sock *sk = sock->sk;
+	int ret, arg = 0;
+
+	if (!sk->sk_prot || !sk->sk_prot->ioctl)
+		return -EOPNOTSUPP;
+
+	switch (cmd->sqe->cmd_op) {
+	case SOCKET_URING_OP_SIOCINQ:
+		ret = sk->sk_prot->ioctl(sk, SIOCINQ, &arg);
+		if (ret)
+			return ret;
+		return arg;
+	case SOCKET_URING_OP_SIOCOUTQ:
+		ret = sk->sk_prot->ioctl(sk, SIOCOUTQ, &arg);
+		if (ret)
+			return ret;
+		return arg;
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+EXPORT_SYMBOL_GPL(uring_sock_cmd);
diff --git a/net/socket.c b/net/socket.c
index b778fc03c6e0..db11e94d2259 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -88,6 +88,7 @@
 #include <linux/xattr.h>
 #include <linux/nospec.h>
 #include <linux/indirect_call_wrapper.h>
+#include <linux/io_uring.h>
 
 #include <linux/uaccess.h>
 #include <asm/unistd.h>
@@ -159,6 +160,7 @@ static const struct file_operations socket_file_ops = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = compat_sock_ioctl,
 #endif
+	.uring_cmd =    uring_sock_cmd,
 	.mmap =		sock_mmap,
 	.release =	sock_close,
 	.fasync =	sock_fasync,
-- 
2.34.1
