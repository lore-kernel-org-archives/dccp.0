From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Fri, 26 May 2023 14:09:53 +0000
Subject: Re: [PATCH net-next v3] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <CAF=yD-LO8fZJfayJoFPO_wvMw=FLGbf_DYUcaBpKv81OEOQVUA@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230525125503.400797-1-leitao@debian.org>
In-Reply-To: <20230525125503.400797-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

On Fri, May 26, 2023 at 5:08 AM Breno Leitao <leitao@debian.org> wrote:
>
> On Thu, May 25, 2023 at 12:06:00PM -0400, Willem de Bruijn wrote:
> > On Thu, May 25, 2023 at 11:34 AM David Ahern <dsahern@kernel.org> wrote:
> > > On 5/25/23 9:05 AM, Willem de Bruijn wrote:
> > > > I don't understand what this buys us vs testing the sk_family,
> > > > sk_protocol and cmd here.
> > >
> > > To keep protocol specific code out of core files is the reason I
> > > suggested it.
> >
> > I guess you object to demultiplexing based on per-family
> > protocol and ioctl cmd constants directly in this file?
> >
> > That only requires including the smaller uapi headers.
> >
> > But now net/core/sock.h now still has to add includes
> > linux/mroute.h, linux/mroute6.h and net/phonet/phonet.h.
> >
> > Aside on phonet_is_sk, if we're keeping this: this should be
> > sk_is_phonet? Analogous to sk_is_tcp and such. And, it should suffice
> > to  demultiplex based on the protocol family, without testing the
> > type or protocol. The family is defined in protocol-independent header
> > linux/socket.h. The differences between
> > PN_PROTO_PHONET and PN_PROTO_PIPE should be handled inside the family
> > code. So I think it is cleaner just to open-coded as `if
> > (sk->sk_family == PF_PHONET)`
>
> Should we do the same for ipmr as well? Currently I am checking it
> using:
>
>         return sk->sk_type == SOCK_RAW && inet_sk(sk)->inet_num == IPPROTO_ICMPV6;
>
> This is what ip{6}mr functions[1] are use to check if `sk` is using ip{6}mr.
> If we just use `sk->family`, then I suppose that `sk_is_ip6mr` would be
> something as coded below. Is this correct?
>
>         static inline int sk_is_ip6mr(struct sock *sk)
>         {
>                 return sk->sk_family == PF_INET6;
>         }

Actually, for multicast routing, the protocol check is required.

> Anyway, should we continue with the current (V3) approach, where we keep
> the protocol code out of core files, or, should I come back to the
> previous (V2) approach, where the protocol checks is coded directly in
> the core file?

David expressed preference for the current approach. So let's stay with that.
