From: Jakub Sitnicki <jakub@cloudflare.com>
Date: Mon, 11 May 2020 09:08:15 +0000
Subject: Re: [PATCH bpf-next 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <877dxivny8.fsf@cloudflare.com>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-3-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, May 08, 2020 at 08:39 PM CEST, Martin KaFai Lau wrote:
> On Fri, May 08, 2020 at 12:45:14PM +0200, Jakub Sitnicki wrote:
>> On Fri, May 08, 2020 at 09:06 AM CEST, Martin KaFai Lau wrote:
>> > On Wed, May 06, 2020 at 02:54:58PM +0200, Jakub Sitnicki wrote:

[...]

>> >> +		return -ESOCKTNOSUPPORT;
>> >> +
>> >> +	/* Check if socket is suitable for packet L3/L4 protocol */
>> >> +	if (sk->sk_protocol != ctx->protocol)
>> >> +		return -EPROTOTYPE;
>> >> +	if (sk->sk_family != ctx->family &&
>> >> +	    (sk->sk_family = AF_INET || ipv6_only_sock(sk)))
>> >> +		return -EAFNOSUPPORT;
>> >> +
>> >> +	/* Select socket as lookup result */
>> >> +	ctx->selected_sk = sk;
>> > Could sk be a TCP_ESTABLISHED sk?
>>
>> Yes, and what's worse, it could be ref-counted. This is a bug. I should
>> be rejecting ref counted sockets here.
> Agree. ref-counted (i.e. checking rcu protected or not) is the right check
> here.
>
> An unrelated quick thought, it may still be fine for the
> TCP_ESTABLISHED tcp_sk returned from sock_map because of the
> "call_rcu(&psock->rcu, sk_psock_destroy);" in sk_psock_drop().
> I was more thinking about in the future, what if this helper can take
> other sk not coming from sock_map.

I see, psock holds a sock reference and will not release it until a full
grace period has elapsed.

Even if holding a ref wasn't a problem, I'm not sure if returning a
TCP_ESTABLISHED socket wouldn't trip up callers of inet_lookup_listener
(tcp_v4_rcv and nf_tproxy_handle_time_wait4), that look for a listener
when processing a SYN to TIME_WAIT socket.
