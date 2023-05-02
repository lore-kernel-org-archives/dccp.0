From: Adrien Delorme <delorme.ade@outlook.com>
Date: Tue, 02 May 2023 09:21:55 +0000
Subject: RE: [PATCH 0/5] add initial io_uring_cmd support for sockets
Message-Id: <GV1P193MB200533CC9A694C4066F4807CEA6F9@GV1P193MB2005.EURP193.PROD.OUTLOOK.COM>
List-Id: <dccp.vger.kernel.org>
References: <20230406144330.1932798-1-leitao@debian.org>
In-Reply-To: <20230406144330.1932798-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From Adrien Delorme

> From: David Ahern 
> Sent: 12 April 2023 7:39 
> > Sent: 11 April 2023 16:28
> ....
> > Christoph's patch set a few years back that removed set_fs broke the
> > ability to do in-kernel ioctl and {s,g}setsockopt calls. I did not
> > follow that change; was it a deliberate intent to not allow these
> > in-kernel calls vs wanting to remove the set_fs? e.g., can we add a
> > kioctl variant for in-kernel use of the APIs?
>
> I think that was a side effect, and with no in-tree in-kernel
> users (apart from limited calls in bpf) it was deemed acceptable.
> (It is a PITA for any code trying to use SCTP in kernel.)
>
> One problem is that not all sockopt calls pass the correct length.
> And some of them can have very long buffers.
> Not to mention the ones that are read-modify-write.
>
> A plausible solution is to pass a 'fat pointer' that contains
> some, or all, of:
>       - A userspace buffer pointer.
>       - A kernel buffer pointer.
>       - The length supplied by the user.
>       - The length of the kernel buffer.
>       = The number of bytes to copy on completion.
> For simple user requests the syscall entry/exit code
> would copy the data to a short on-stack buffer.
> Kernel users just pass the kernel address.
> Odd requests can just use the user pointer.
>
> Probably needs accessors that add in an offset.
>
> It might also be that some of the problematic sockopt
> were in decnet - now removed.

Hello everyone,

I'm currently working on an implementation of {get,set} sockopt. 
Since this thread is already talking about it, I hope that I replying at the correct place. 

My implementation is rather simple using a struct that will be used to pass the necessary info throught sqe->cmd.

Here is my implementation based of kernel version 6.3 : 

Signed-off-by: Adrien Delorme <delorme.ade@outlook.com>

diff -uprN a/include/uapi/linux/io_uring.h b/include/uapi/linux/io_uring.h
--- a/include/uapi/linux/io_uring.h     2023-04-23 15:02:52.000000000 -0400
+++ b/include/uapi/linux/io_uring.h     2023-04-24 07:55:21.406981696 -0400
@@ -235,6 +235,25 @@ enum io_uring_op {
  */
#define IORING_URING_CMD_FIXED (1U << 0)

+/* struct io_uring_cmd->cmd_op flags for socket operations */
+#define IO_URING_CMD_OP_GETSOCKOPT 0x0
+#define IO_URING_CMD_OP_SETSOCKOPT 0x1
+
+/* Struct to pass args for IO_URING_CMD_OP_GETSOCKOPT and IO_URING_CMD_OP_SETSOCKOPT operations */
+struct args_setsockopt_uring{
+       int                             level;
+       int                     optname;
+       char __user *   user_optval;
+       int                     optlen;
+};
+
+struct args_getsockopt_uring{
+       int                             level;
+       int                     optname;
+       char __user *   user_optval;
+       int      __user *       optlen;
+};
+

/*
  * sqe->fsync_flags
diff -uprN a/net/socket.c b/net/socket.c
--- a/net/socket.c      2023-04-23 15:02:52.000000000 -0400
+++ b/net/socket.c      2023-04-24 08:06:44.800981696 -0400
@@ -108,6 +108,11 @@
#include <linux/ptp_clock_kernel.h>
#include <trace/events/sock.h>

+#ifdef CONFIG_IO_URING
+#include <uapi/linux/io_uring.h>
+#include <linux/io_uring.h>
+#endif
+
#ifdef CONFIG_NET_RX_BUSY_POLL
unsigned int sysctl_net_busy_read __read_mostly;
unsigned int sysctl_net_busy_poll __read_mostly;
@@ -132,6 +137,11 @@ static ssize_t sock_splice_read(struct f
                                struct pipe_inode_info *pipe, size_t len,
                                unsigned int flags);

+
+#ifdef CONFIG_IO_URING
+int socket_uring_cmd_handler(struct io_uring_cmd *cmd, unsigned int flags);
+#endif
+
#ifdef CONFIG_PROC_FS
static void sock_show_fdinfo(struct seq_file *m, struct file *f)
{
@@ -166,6 +176,9 @@ static const struct file_operations sock
        .splice_write = generic_splice_sendpage,
        .splice_read =  sock_splice_read,
        .show_fdinfo =  sock_show_fdinfo,
+#ifdef CONFIG_IO_URING
+       .uring_cmd = socket_uring_cmd_handler,
+#endif
};

static const char * const pf_family_names[] = {
@@ -2330,6 +2343,126 @@ SYSCALL_DEFINE5(getsockopt, int, fd, int
        return __sys_getsockopt(fd, level, optname, optval, optlen);
}

+#ifdef CONFIG_IO_URING
+
+/*
+ * Make getsockopt operation with io_uring.
+ * This fonction is based of the __sys_getsockopt without sockfd_lookup_light
+ * since io_uring retrieves it for us.
+ */
+int uring_cmd_getsockopt(struct socket *sock, int level, int optname, char __user *optval,
+               int __user *optlen)
+{
+       int err;
+       int max_optlen;
+
+       err = security_socket_getsockopt(sock, level, optname);
+       if (err)
+               goto out_put;
+
+       if (!in_compat_syscall())
+               max_optlen = BPF_CGROUP_GETSOCKOPT_MAX_OPTLEN(optlen);
+
+       if (level == SOL_SOCKET)
+               err = sock_getsockopt(sock, level, optname, optval, optlen);
+       else if (unlikely(!sock->ops->getsockopt))
+               err = -EOPNOTSUPP;
+       else
+               err = sock->ops->getsockopt(sock, level, optname, optval,
+                                           optlen);
+
+       if (!in_compat_syscall())
+               err = BPF_CGROUP_RUN_PROG_GETSOCKOPT(sock->sk, level, optname,
+                                                    optval, optlen, max_optlen,
+                                                    err);
+out_put:
+       return err;
+}
+
+/*
+ * Make setsockopt operation with io_uring.
+ * This fonction is based of the __sys_setsockopt without sockfd_lookup_light
+ * since io_uring retrieves it for us.
+ */
+int uring_cmd_setsockopt(struct socket *sock, int level, int optname, char *user_optval,
+               int optlen)
+{
+       sockptr_t optval = USER_SOCKPTR(user_optval);
+       char *kernel_optval = NULL;
+       int err;
+
+       if (optlen < 0)
+               return -EINVAL;
+
+       err = security_socket_setsockopt(sock, level, optname);
+       if (err)
+               goto out_put;
+
+       if (!in_compat_syscall())
+               err = BPF_CGROUP_RUN_PROG_SETSOCKOPT(sock->sk, &level, &optname,
+                                                    user_optval, &optlen,
+                                                    &kernel_optval);
+       if (err < 0)
+               goto out_put;
+       if (err > 0) {
+               err = 0;
+               goto out_put;
+       }
+
+       if (kernel_optval)
+               optval = KERNEL_SOCKPTR(kernel_optval);
+       if (level == SOL_SOCKET && !sock_use_custom_sol_socket(sock))
+               err = sock_setsockopt(sock, level, optname, optval, optlen);
+       else if (unlikely(!sock->ops->setsockopt))
+               err = -EOPNOTSUPP;
+       else
+               err = sock->ops->setsockopt(sock, level, optname, optval,
+                                           optlen);
+       kfree(kernel_optval);
+out_put:
+       return err;
+}
+
+/*
+ * Handler uring_cmd socket file_operations.
+ *
+ * Operation code and struct are defined in /include/uapi/linux/io_uring.h
+ * The io_uring ring needs to be set with the flags : IORING_SETUP_SQE128 and IORING_SETUP_CQE32
+ *
+ */
+int socket_uring_cmd_handler(struct io_uring_cmd *cmd, unsigned int flags){
+
+       /* Retrieve socket */
+       struct socket *sock = sock_from_file(cmd->file);
+
+       if (!sock)
+               return -EINVAL;
+
+       /* Does the requested operation */
+       switch (cmd->cmd_op) {
+               case IO_URING_CMD_OP_GETSOCKOPT:
+                       struct args_getsockopt_uring *values_get = (struct args_getsockopt_uring *) cmd->cmd;
+                       return uring_cmd_getsockopt(sock,
+                                                                               values_get->level,
+                                                                               values_get->optname,
+                                                                               values_get->user_optval,
+                                                                               values_get->optlen);
+
+               case IO_URING_CMD_OP_SETSOCKOPT:
+                       struct args_setsockopt_uring *values_set = (struct args_setsockopt_uring *) cmd->cmd;
+                       return uring_cmd_setsockopt(sock,
+                                                                               values_set->level,
+                                                                               values_set->optname,
+                                                                               values_set->user_optval,
+                                                                               values_set->optlen);
+               default:
+                       break;
+
+       }
+       return -EINVAL;
+}
+#endif
+
/*
  *     Shutdown a socket.
  */

I would appreciate any feedback or advice you may have on this work. Hopefully it will be of some kind of help. Thank you for your time and consideration.

Adrien
