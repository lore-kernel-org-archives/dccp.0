From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Sat, 03 Jun 2023 08:21:50 +0000
Subject: Re: [PATCH net-next v5] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <CAF=yD-Kk9mVWPZN50NUu8uGwEbySNS-WzvJ=1HTTcVsA6OOuvA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230602163044.1820619-1-leitao@debian.org>
In-Reply-To: <20230602163044.1820619-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Fri, Jun 2, 2023 at 6:31=E2=80=AFPM Breno Leitao <leitao@debian.org> wro=
te:
>
> Most of the ioctls to net protocols operates directly on userspace
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
> pointer allocated to kernel space memory (inside a function wrapper).
> This buffer (karg) may contain input argument (copied from userspace in
> a prep function) and it might return a value/buffer, which is copied
> back to userspace if necessary. There is not one-size-fits-all format
> (that is I am using 'may' above), but basically, there are three type of
> ioctls:
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
> For the exception cases, functions sock_sk_ioctl_inout() will
> copy the userspace input, and copy it back to kernel space.
>
> The wrapper that prepare the buffer and put the buffer back to user is
> sk_ioctl(), so, instead of calling sk->sk_prot->ioctl(), the callee now
> calls sk_ioctl(), which will handle all cases.
>
> Signed-off-by: Breno Leitao <leitao@debian.org>

Please check the checkpatch output

https://patchwork.hopto.org/static/nipa/753609/13265673/checkpatch/stdout

> +static inline int phonet_sk_ioctl(struct sock *sk, unsigned int cmd, voi=
d __user *arg)
> +{
> +       int karg;
> +
> +       switch (cmd) {
> +       case SIOCPNADDRESOURCE:
> +       case SIOCPNDELRESOURCE:
> +               if (get_user(karg, (int __user *)arg))
> +                       return -EFAULT;
> +
> +               return sk->sk_prot->ioctl(sk, cmd, &karg);
> +       }
> +       /* A positive return value means that the ioctl was not processed=
 */
> +       return 1;
> +}
>  #endif

> +/* A wrapper around sock ioctls, which copies the data from userspace
> + * (depending on the protocol/ioctl), and copies back the result to user=
space.
> + * The main motivation for this function is to pass kernel memory to the
> + * protocol ioctl callbacks, instead of userspace memory.
> + */
> +int sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
> +{
> +       int rc =3D 1;
> +
> +       if (sk_is_ipmr(sk))
> +               rc =3D ipmr_sk_ioctl(sk, cmd, arg);
> +       else if (sk_is_icmpv6(sk))
> +               rc =3D ip6mr_sk_ioctl(sk, cmd, arg);
> +       else if (sk_is_phonet(sk))
> +               rc =3D phonet_sk_ioctl(sk, cmd, arg);

Does this handle all phonet ioctl cases correctly?

Notably pn_socket_ioctl has a SIOCPNGETOBJECT that reads and writes a u16.
