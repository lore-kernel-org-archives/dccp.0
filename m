From: Breno Leitao <leitao@debian.org>
Date: Fri, 02 Jun 2023 16:19:06 +0000
Subject: Re: [PATCH net-next v4] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZHoWeiDVoLV1VMpT@gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20230530175403.2434218-1-leitao@debian.org>
In-Reply-To: <20230530175403.2434218-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, May 31, 2023 at 03:01:56AM -0400, Willem de Bruijn wrote:
> Breno Leitao wrote:
> > +int ip6mr_sk_ioctl(struct sock *sk, unsigned int cmd, void __user *arg);
> > +static inline int sk_is_ip6mr(struct sock *sk)
> > +{
> > +	return sk->sk_family = AF_INET6 &&
> > +		inet_sk(sk)->inet_num = IPPROTO_ICMPV6;
> > +}
 
> Technically, this is just sk_is_icmpv6, which is broader than IPv6
> multicast routing.

Right, let me rename it to reflect this properly.

> No other concerns from me.

Thanks for the detailed review.

> Two small asides, that are fine to ignore.
> 
> The $PROTO_sk_ioctl functions could conceivably call directly into
> the $PROTO_ioctl functions without the indirect function pointer.
> But that would require open coding the sock_sk_ioctl_inout helpers.
> 
> The demux now first checks relatively unlikely multicast routing
> and phonet before falling through to the more common protocols. But
> ioctl is not a hot path operation.

I am more than happy to open code sock_sk_ioctl_inout into protocol
functions, but, I would prefer to do it in a follow up patch, since this
one is close (I hope) to address the original problem. I hope it works
for you.

Thanks!
