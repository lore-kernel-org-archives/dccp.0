From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu, 25 May 2023 16:06:00 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <CAF=yD-LXcufhJBpkEcUuphFpR1TA4=QwUXw4sKFsSiEL_mwG4Q@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, May 25, 2023 at 11:34=E2=80=AFAM David Ahern <dsahern@kernel.org> w=
rote:
>
> On 5/25/23 9:05 AM, Willem de Bruijn wrote:
> >> +/* A wrapper around sock ioctls, which copies the data from userspace
> >> + * (depending on the protocol/ioctl), and copies back the result to u=
serspace.
> >> + * The main motivation for this function is to pass kernel memory to =
the
> >> + * protocol ioctl callbacks, instead of userspace memory.
> >> + */
> >> +int sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
> >> +{
> >> +       int rc =3D 1;
> >> +
> >> +       if (ipmr_is_sk(sk))
> >> +               rc =3D ipmr_sk_ioctl(sk, cmd, arg);
> >> +       else if (ip6mr_is_sk(sk))
> >> +               rc =3D ip6mr_sk_ioctl(sk, cmd, arg);
> >> +       else if (phonet_is_sk(sk))
> >> +               rc =3D phonet_sk_ioctl(sk, cmd, arg);
> >
> > I don't understand what this buys us vs testing the sk_family,
> > sk_protocol and cmd here.
>
> To keep protocol specific code out of core files is the reason I
> suggested it.

I guess you object to demultiplexing based on per-family
protocol and ioctl cmd constants directly in this file?

That only requires including the smaller uapi headers.

But now net/core/sock.h now still has to add includes
linux/mroute.h, linux/mroute6.h and net/phonet/phonet.h.

Aside on phonet_is_sk, if we're keeping this: this should be
sk_is_phonet? Analogous to sk_is_tcp and such. And, it should suffice
to  demultiplex based on the protocol family, without testing the
type or protocol. The family is defined in protocol-independent header
linux/socket.h. The differences between
PN_PROTO_PHONET and PN_PROTO_PIPE should be handled inside the family
code. So I think it is cleaner just to open-coded as `if
(sk->sk_family =3D=3D PF_PHONET)`
