From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 08 May 2020 18:39:28 +0000
Subject: Re: [PATCH bpf-next 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <20200508183928.ofudkphlb3vgpute@kafai-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-3-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, May 08, 2020 at 12:45:14PM +0200, Jakub Sitnicki wrote:
> On Fri, May 08, 2020 at 09:06 AM CEST, Martin KaFai Lau wrote:
> > On Wed, May 06, 2020 at 02:54:58PM +0200, Jakub Sitnicki wrote:
> >> Add a new program type BPF_PROG_TYPE_SK_LOOKUP and a dedicated attach type
> >> called BPF_SK_LOOKUP. The new program kind is to be invoked by the
> >> transport layer when looking up a socket for a received packet.
> >>
> >> When called, SK_LOOKUP program can select a socket that will receive the
> >> packet. This serves as a mechanism to overcome the limits of what bind()
> >> API allows to express. Two use-cases driving this work are:
> >>
> >>  (1) steer packets destined to an IP range, fixed port to a socket
> >>
> >>      192.0.2.0/24, port 80 -> NGINX socket
> >>
> >>  (2) steer packets destined to an IP address, any port to a socket
> >>
> >>      198.51.100.1, any port -> L7 proxy socket
> >>
> >> In its run-time context, program receives information about the packet that
> >> triggered the socket lookup. Namely IP version, L4 protocol identifier, and
> >> address 4-tuple. Context can be further extended to include ingress
> >> interface identifier.
> >>
> >> To select a socket BPF program fetches it from a map holding socket
> >> references, like SOCKMAP or SOCKHASH, and calls bpf_sk_assign(ctx, sk, ...)
> >> helper to record the selection. Transport layer then uses the selected
> >> socket as a result of socket lookup.
> >>
> >> This patch only enables the user to attach an SK_LOOKUP program to a
> >> network namespace. Subsequent patches hook it up to run on local delivery
> >> path in ipv4 and ipv6 stacks.
> >>
> >> Suggested-by: Marek Majkowski <marek@cloudflare.com>
> >> Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
> >> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
> >> ---
> 

[...]

> >> +BPF_CALL_3(bpf_sk_lookup_assign, struct bpf_sk_lookup_kern *, ctx,
> >> +	   struct sock *, sk, u64, flags)
> >> +{
> >> +	if (unlikely(flags != 0))
> >> +		return -EINVAL;
> >> +	if (unlikely(!sk_fullsock(sk)))
> > May be ARG_PTR_TO_SOCKET instead?
> 
> I had ARG_PTR_TO_SOCKET initially, then switched to SOCK_COMMON to match
> the TC bpf_sk_assign proto. Now that you point it out, it makes more
> sense to be more specific in the helper proto.
> 
> >
> >> +		return -ESOCKTNOSUPPORT;
> >> +
> >> +	/* Check if socket is suitable for packet L3/L4 protocol */
> >> +	if (sk->sk_protocol != ctx->protocol)
> >> +		return -EPROTOTYPE;
> >> +	if (sk->sk_family != ctx->family &&
> >> +	    (sk->sk_family = AF_INET || ipv6_only_sock(sk)))
> >> +		return -EAFNOSUPPORT;
> >> +
> >> +	/* Select socket as lookup result */
> >> +	ctx->selected_sk = sk;
> > Could sk be a TCP_ESTABLISHED sk?
> 
> Yes, and what's worse, it could be ref-counted. This is a bug. I should
> be rejecting ref counted sockets here.
Agree. ref-counted (i.e. checking rcu protected or not) is the right check
here.

An unrelated quick thought, it may still be fine for the
TCP_ESTABLISHED tcp_sk returned from sock_map because of the
"call_rcu(&psock->rcu, sk_psock_destroy);" in sk_psock_drop().
I was more thinking about in the future, what if this helper can take
other sk not coming from sock_map.

> 
> Callers of __inet_lookup_listener() and inet6_lookup_listener() expect
> an RCU-freed socket on return.
> 
> For UDP lookup, returning a TCP_ESTABLISHED (connected) socket is okay.
> 
> 
> Thank you for valuable comments. Will fix all of the above in v2.
