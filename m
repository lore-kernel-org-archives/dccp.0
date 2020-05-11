From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Mon, 11 May 2020 20:44:45 +0000
Subject: Re: [PATCH bpf-next v2 05/17] inet: Run SK_LOOKUP BPF program on socket lookup
Message-Id: <20200511204445.i7sessmtszox36xd@ast-mbp>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-6-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-6-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Mon, May 11, 2020 at 08:52:06PM +0200, Jakub Sitnicki wrote:
> Run a BPF program before looking up a listening socket on the receive path.
> Program selects a listening socket to yield as result of socket lookup by
> calling bpf_sk_assign() helper and returning BPF_REDIRECT code.
> 
> Alternatively, program can also fail the lookup by returning with BPF_DROP,
> or let the lookup continue as usual with BPF_OK on return.
> 
> This lets the user match packets with listening sockets freely at the last
> possible point on the receive path, where we know that packets are destined
> for local delivery after undergoing policing, filtering, and routing.
> 
> With BPF code selecting the socket, directing packets destined to an IP
> range or to a port range to a single socket becomes possible.
> 
> Suggested-by: Marek Majkowski <marek@cloudflare.com>
> Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
> ---
>  include/net/inet_hashtables.h | 36 +++++++++++++++++++++++++++++++++++
>  net/ipv4/inet_hashtables.c    | 15 ++++++++++++++-
>  2 files changed, 50 insertions(+), 1 deletion(-)
> 
> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> index 6072dfbd1078..3fcbc8f66f88 100644
> --- a/include/net/inet_hashtables.h
> +++ b/include/net/inet_hashtables.h
> @@ -422,4 +422,40 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
>  
>  int inet_hash_connect(struct inet_timewait_death_row *death_row,
>  		      struct sock *sk);
> +
> +static inline struct sock *bpf_sk_lookup_run(struct net *net,
> +					     struct bpf_sk_lookup_kern *ctx)
> +{
> +	struct bpf_prog *prog;
> +	int ret = BPF_OK;
> +
> +	rcu_read_lock();
> +	prog = rcu_dereference(net->sk_lookup_prog);
> +	if (prog)
> +		ret = BPF_PROG_RUN(prog, ctx);
> +	rcu_read_unlock();
> +
> +	if (ret = BPF_DROP)
> +		return ERR_PTR(-ECONNREFUSED);
> +	if (ret = BPF_REDIRECT)
> +		return ctx->selected_sk;
> +	return NULL;
> +}
> +
> +static inline struct sock *inet_lookup_run_bpf(struct net *net, u8 protocol,
> +					       __be32 saddr, __be16 sport,
> +					       __be32 daddr, u16 dport)
> +{
> +	struct bpf_sk_lookup_kern ctx = {
> +		.family		= AF_INET,
> +		.protocol	= protocol,
> +		.v4.saddr	= saddr,
> +		.v4.daddr	= daddr,
> +		.sport		= sport,
> +		.dport		= dport,
> +	};
> +
> +	return bpf_sk_lookup_run(net, &ctx);
> +}
> +
>  #endif /* _INET_HASHTABLES_H */
> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> index ab64834837c8..f4d07285591a 100644
> --- a/net/ipv4/inet_hashtables.c
> +++ b/net/ipv4/inet_hashtables.c
> @@ -307,9 +307,22 @@ struct sock *__inet_lookup_listener(struct net *net,
>  				    const int dif, const int sdif)
>  {
>  	struct inet_listen_hashbucket *ilb2;
> -	struct sock *result = NULL;
> +	struct sock *result, *reuse_sk;
>  	unsigned int hash2;
>  
> +	/* Lookup redirect from BPF */
> +	result = inet_lookup_run_bpf(net, hashinfo->protocol,
> +				     saddr, sport, daddr, hnum);
> +	if (IS_ERR(result))
> +		return NULL;
> +	if (result) {
> +		reuse_sk = lookup_reuseport(net, result, skb, doff,
> +					    saddr, sport, daddr, hnum);
> +		if (reuse_sk)
> +			result = reuse_sk;
> +		goto done;
> +	}
> +

The overhead is too high to do this all the time.
The feature has to be static_key-ed.

Also please add multi-prog support. Adding it later will cause
all sorts of compatibility issues. The semantics of multi-prog
needs to be thought through right now.
For example BPF_DROP or BPF_REDIRECT could terminate the prog_run_array
sequence of progs while BPF_OK could continue.
It's not ideal, but better than nothing.
Another option could be to execute all attached progs regardless
of return code, but don't let second prog override selected_sk blindly.
bpf_sk_assign() could get smarter.

Also please switch to bpf_link way of attaching. All system wide attachments
should be visible and easily debuggable via 'bpftool link show'.
Currently we're converting tc and xdp hooks to bpf_link. This new hook
should have it from the beginning.
