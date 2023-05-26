From: Breno Leitao <leitao@debian.org>
Date: Fri, 26 May 2023 09:08:20 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZHB3BNopbx+5AnIa@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

On Thu, May 25, 2023 at 12:06:00PM -0400, Willem de Bruijn wrote:
> On Thu, May 25, 2023 at 11:34=E2=80=AFAM David Ahern <dsahern@kernel.org>=
 wrote:
> > On 5/25/23 9:05 AM, Willem de Bruijn wrote:
> > > I don't understand what this buys us vs testing the sk_family,
> > > sk_protocol and cmd here.
> >
> > To keep protocol specific code out of core files is the reason I
> > suggested it.
>=20
> I guess you object to demultiplexing based on per-family
> protocol and ioctl cmd constants directly in this file?
>=20
> That only requires including the smaller uapi headers.
>=20
> But now net/core/sock.h now still has to add includes
> linux/mroute.h, linux/mroute6.h and net/phonet/phonet.h.
>=20
> Aside on phonet_is_sk, if we're keeping this: this should be
> sk_is_phonet? Analogous to sk_is_tcp and such. And, it should suffice
> to  demultiplex based on the protocol family, without testing the
> type or protocol. The family is defined in protocol-independent header
> linux/socket.h. The differences between
> PN_PROTO_PHONET and PN_PROTO_PIPE should be handled inside the family
> code. So I think it is cleaner just to open-coded as `if
> (sk->sk_family =3D PF_PHONET)`

Should we do the same for ipmr as well? Currently I am checking it
using:

	return sk->sk_type =3D SOCK_RAW && inet_sk(sk)->inet_num =3D IPPROTO_ICMPV=
6;

This is what ip{6}mr functions[1] are use to check if `sk` is using ip{6}mr.
If we just use `sk->family`, then I suppose that `sk_is_ip6mr` would be
something as coded below. Is this correct?

	static inline int sk_is_ip6mr(struct sock *sk)
	{
		return sk->sk_family =3D PF_INET6;
	}

Anyway, should we continue with the current (V3) approach, where we keep
the protocol code out of core files, or, should I come back to the
previous (V2) approach, where the protocol checks is coded directly in
the core file?

Thanks for the review!
[1] Link: https://github.com/torvalds/linux/blob/0d85b27b0cc6b5cf54567c5ad9=
13a247a71583ce/net/ipv6/ip6mr.c#L1666
