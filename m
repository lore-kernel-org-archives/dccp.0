From: Martin KaFai Lau <kafai@fb.com>
Date: Mon, 11 May 2020 20:54:35 +0000
Subject: Re: [PATCH bpf-next 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <20200511205435.mgjbkfndpi2sds6z@kafai-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-3-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, May 11, 2020 at 09:26:02PM +0200, Jakub Sitnicki wrote:
> On Mon, May 11, 2020 at 08:59 PM CEST, Martin KaFai Lau wrote:
> > On Mon, May 11, 2020 at 11:08:15AM +0200, Jakub Sitnicki wrote:
> >> On Fri, May 08, 2020 at 08:39 PM CEST, Martin KaFai Lau wrote:
> >> > On Fri, May 08, 2020 at 12:45:14PM +0200, Jakub Sitnicki wrote:
> >> >> On Fri, May 08, 2020 at 09:06 AM CEST, Martin KaFai Lau wrote:
> >> >> > On Wed, May 06, 2020 at 02:54:58PM +0200, Jakub Sitnicki wrote:
> >>
> >> [...]
> >>
> >> >> >> +		return -ESOCKTNOSUPPORT;
> >> >> >> +
> >> >> >> +	/* Check if socket is suitable for packet L3/L4 protocol */
> >> >> >> +	if (sk->sk_protocol != ctx->protocol)
> >> >> >> +		return -EPROTOTYPE;
> >> >> >> +	if (sk->sk_family != ctx->family &&
> >> >> >> +	    (sk->sk_family = AF_INET || ipv6_only_sock(sk)))
> >> >> >> +		return -EAFNOSUPPORT;
> >> >> >> +
> >> >> >> +	/* Select socket as lookup result */
> >> >> >> +	ctx->selected_sk = sk;
> >> >> > Could sk be a TCP_ESTABLISHED sk?
> >> >>
> >> >> Yes, and what's worse, it could be ref-counted. This is a bug. I should
> >> >> be rejecting ref counted sockets here.
> >> > Agree. ref-counted (i.e. checking rcu protected or not) is the right check
> >> > here.
> >> >
> >> > An unrelated quick thought, it may still be fine for the
> >> > TCP_ESTABLISHED tcp_sk returned from sock_map because of the
> >> > "call_rcu(&psock->rcu, sk_psock_destroy);" in sk_psock_drop().
> >> > I was more thinking about in the future, what if this helper can take
> >> > other sk not coming from sock_map.
> >>
> >> I see, psock holds a sock reference and will not release it until a full
> >> grace period has elapsed.
> >>
> >> Even if holding a ref wasn't a problem, I'm not sure if returning a
> >> TCP_ESTABLISHED socket wouldn't trip up callers of inet_lookup_listener
> >> (tcp_v4_rcv and nf_tproxy_handle_time_wait4), that look for a listener
> >> when processing a SYN to TIME_WAIT socket.
> > Not suggesting the sk_assign helper has to support TCP_ESTABLISHED in TCP
> > if there is no use case for it.
> 
> Ack, I didn't think you were. Just explored the consequences.
> 
> > Do you have a use case on supporting TCP_ESTABLISHED sk in UDP?
> > From the cover letter use cases, it is not clear to me it is
> > required.
> >
> > or both should only support unconnected sk?
> 
> No, we don't have a use case for selecting a connected UDP socket.
> 
> I left it as a possiblity because __udp[46]_lib_lookup, where BPF
> sk_lookup is invoked from, can return one.
> 
> Perhaps the user would like to connect the selected receiving socket
> (for instance to itself) to ensure its not used for TX?
> 
> I've pulled this scenario out of the hat. Happy to limit bpf_sk_assign
> to select only unconnected UDP sockets, if returning a connected one
> doesn't make sense.
OTOH, my concern is:
TCP's SK_LOOKUP can override the kernel choice on TCP_LISTEN sk.
UDP's SK_LOOKUP can override the kernel choice on unconnected sk but
not the connected sk.

It could be quite confusing to bpf user if a bpf_prog was written to return
both connected and unconnected UDP sk and logically expect both
will be done before the kernel's choice.

> 
> > Regardless, this details will be useful in the helper's doc.
> 
> I've reworded the helper doc in v2 to say:
> 
>         Description
>                 ...
> 
>                 Only TCP listeners and UDP sockets, that is sockets
>                 which have *SOCK_RCU_FREE* flag set, can be selected.
> 
>                 ...
>         Return
>                 ...
> 
>                 **-ESOCKTNOSUPPORT** if socket does not use RCU freeing.
