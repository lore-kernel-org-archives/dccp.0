From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Mon, 22 May 2023 19:26:55 +0000
Subject: Re: [PATCH v2] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <CAF=yD-+3SnE2gsE4S3=uxxEgW+2MCLdTLx24G72fkS=AkchCEA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230522134735.2810070-1-leitao@debian.org>
In-Reply-To: <20230522134735.2810070-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Mon, May 22, 2023 at 9:51=E2=80=AFAM Breno Leitao <leitao@debian.org> wr=
ote:
>
> Most of the ioctls to net protocols  operates directly on userspace
> argument (arg). Usually doing get_user()/put_user() directly in the
> ioctl callback.  This is not flexible, because it is hard to reuse these
> functions without passing userspace buffers.
>
> Change the "struct proto" ioctls to avoid touching userspace memory and
> operate on kernel buffers, i.e., all protocol's ioctl callbacks is
> adapted to operate on a kernel memory other than on userspace (so, no
> more {put,get}_user() and friends being called in the ioctl callback).
>
> This changes the "struct proto" ioctl format in the following way:
>
>     int                     (*ioctl)(struct sock *sk, int cmd,
> -                                        unsigned long arg);
> +                                        int *karg);
>
> So, the "karg" argument, which is passed to the ioctl callback, is a
> pointer allocated to kernel space memory (inside a function wrapper -
> sk_ioctl()). This buffer (karg) may contain input argument
> (copied from userspace in a prep function) and it might return a
> value/buffer, which is copied back to userspace if necessary. There is
> not one-size-fits-all format (that is I am using 'may' above), but
> basically, there are three type of ioctls:
>
> 1) Do not read from userspace, returns a result to userspace
> 2) Read an input parameter from userspace, and does not return anything
>   to userspace
> 3) Read an input from userspace, and return a buffer to userspace.
>
> The default case (1) (where no input parameter is given, and an "int" is
> returned to userspace) encompasses more than 90% of the cases, but there
> are two other exceptions. Here is a list of exceptions:
>
> * Protocol RAW:
>    * cmd =3D SIOCGETVIFCNT:
>      * input and output =3D struct sioc_vif_req
>    * cmd =3D SIOCGETSGCNT
>      * input and output =3D struct sioc_sg_req
>    * Explanation: for the SIOCGETVIFCNT case, userspace passes the input
>      argument, which is struct sioc_vif_req. Then the callback populates
>      the struct, which is copied back to userspace.
>
> * Protocol RAW6:
>    * cmd =3D SIOCGETMIFCNT_IN6
>      * input and output =3D struct sioc_mif_req6
>    * cmd =3D SIOCGETSGCNT_IN6
>      * input and output =3D struct sioc_sg_req6
>
> * Protocol PHONET:
>   * cmd =3D=3D SIOCPNADDRESOURCE | SIOCPNDELRESOURCE
>      * input int (4 bytes)
>   * Nothing is copied back to userspace.
>
> For the exception cases, functions sk_ioctl_in{out}() will
> copy the userspace input, and copy it back to kernel space.
>
> The wrapper that prepare the buffer and put the buffer back to user is
> sk_ioctl(), so, instead of calling sk->sk_prot->ioctl(), the
> callee now calls sk_ioctl(), which will handle all cases.
>
> Signed-off-by: Breno Leitao <leitao@debian.org>

Going forward, please mark patches for net-next with [PATCH net-next v2]

> --- a/include/net/udp.h
> +++ b/include/net/udp.h
> @@ -283,7 +283,7 @@ void udp_flush_pending_frames(struct sock *sk);
>  int udp_cmsg_send(struct sock *sk, struct msghdr *msg, u16 *gso_size);
>  void udp4_hwcsum(struct sk_buff *skb, __be32 src, __be32 dst);
>  int udp_rcv(struct sk_buff *skb);
> -int udp_ioctl(struct sock *sk, int cmd, unsigned long arg);
> +int udp_ioctl(struct sock *sk, int cmd, int *karg);
>  int udp_init_sock(struct sock *sk);
>  int udp_pre_connect(struct sock *sk, struct sockaddr *uaddr, int addr_le=
n);
>  int __udp_disconnect(struct sock *sk, int flags);
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 5440e67bcfe3..a2cea95aec99 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -114,6 +114,8 @@
>  #include <linux/memcontrol.h>
>  #include <linux/prefetch.h>
>  #include <linux/compat.h>
> +#include <linux/mroute.h>
> +#include <linux/mroute6.h>

This is for the ioctl constants only, right.

Then like those header files, include the uapi header, and only that,
to minimize the dependencies added to net/core/sock.c

>  #include <linux/uaccess.h>
>
> @@ -138,6 +140,7 @@
>
>  #include <net/tcp.h>
>  #include <net/busy_poll.h>
> +#include <net/phonet/phonet.h>
>
>  #include <linux/ethtool.h>
>
> @@ -4106,3 +4109,112 @@ int sock_bind_add(struct sock *sk, struct sockadd=
r *addr, int addr_len)
>         return sk->sk_prot->bind_add(sk, addr, addr_len);
>  }
>  EXPORT_SYMBOL(sock_bind_add);
> +
> +#ifdef CONFIG_PHONET
> +/* Copy u32 value from userspace and do not return anything back */
> +static int sk_ioctl_in(struct sock *sk, unsigned int cmd, void __user *a=
rg)

The pointer can be const.

> +{
> +       int karg;
> +
> +       if (get_user(karg, (u32 __user *)arg))
> +               return -EFAULT;

The comment and cast are u32, but the datatype is int. Is there a
reason for that.

> +       return sk->sk_prot->ioctl(sk, cmd, &karg);
> +}
> +#endif
