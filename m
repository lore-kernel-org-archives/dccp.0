From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Date: Tue, 12 May 2020 23:58:40 +0000
Subject: Re: [PATCH bpf-next v2 05/17] inet: Run SK_LOOKUP BPF program on socket lookup
Message-Id: <20200512235840.znwcyu3gpxemucwh@ast-mbp>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-6-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-6-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, May 12, 2020 at 03:52:52PM +0200, Jakub Sitnicki wrote:
> On Mon, May 11, 2020 at 10:44 PM CEST, Alexei Starovoitov wrote:
> > On Mon, May 11, 2020 at 08:52:06PM +0200, Jakub Sitnicki wrote:
> >> Run a BPF program before looking up a listening socket on the receive path.
> >> Program selects a listening socket to yield as result of socket lookup by
> >> calling bpf_sk_assign() helper and returning BPF_REDIRECT code.
> >>
> >> Alternatively, program can also fail the lookup by returning with BPF_DROP,
> >> or let the lookup continue as usual with BPF_OK on return.
> >>
> >> This lets the user match packets with listening sockets freely at the last
> >> possible point on the receive path, where we know that packets are destined
> >> for local delivery after undergoing policing, filtering, and routing.
> >>
> >> With BPF code selecting the socket, directing packets destined to an IP
> >> range or to a port range to a single socket becomes possible.
> >>
> >> Suggested-by: Marek Majkowski <marek@cloudflare.com>
> >> Reviewed-by: Lorenz Bauer <lmb@cloudflare.com>
> >> Signed-off-by: Jakub Sitnicki <jakub@cloudflare.com>
> >> ---
> >>  include/net/inet_hashtables.h | 36 +++++++++++++++++++++++++++++++++++
> >>  net/ipv4/inet_hashtables.c    | 15 ++++++++++++++-
> >>  2 files changed, 50 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/include/net/inet_hashtables.h b/include/net/inet_hashtables.h
> >> index 6072dfbd1078..3fcbc8f66f88 100644
> >> --- a/include/net/inet_hashtables.h
> >> +++ b/include/net/inet_hashtables.h
> >> @@ -422,4 +422,40 @@ int __inet_hash_connect(struct inet_timewait_death_row *death_row,
> >>
> >>  int inet_hash_connect(struct inet_timewait_death_row *death_row,
> >>  		      struct sock *sk);
> >> +
> >> +static inline struct sock *bpf_sk_lookup_run(struct net *net,
> >> +					     struct bpf_sk_lookup_kern *ctx)
> >> +{
> >> +	struct bpf_prog *prog;
> >> +	int ret = BPF_OK;
> >> +
> >> +	rcu_read_lock();
> >> +	prog = rcu_dereference(net->sk_lookup_prog);
> >> +	if (prog)
> >> +		ret = BPF_PROG_RUN(prog, ctx);
> >> +	rcu_read_unlock();
> >> +
> >> +	if (ret = BPF_DROP)
> >> +		return ERR_PTR(-ECONNREFUSED);
> >> +	if (ret = BPF_REDIRECT)
> >> +		return ctx->selected_sk;
> >> +	return NULL;
> >> +}
> >> +
> >> +static inline struct sock *inet_lookup_run_bpf(struct net *net, u8 protocol,
> >> +					       __be32 saddr, __be16 sport,
> >> +					       __be32 daddr, u16 dport)
> >> +{
> >> +	struct bpf_sk_lookup_kern ctx = {
> >> +		.family		= AF_INET,
> >> +		.protocol	= protocol,
> >> +		.v4.saddr	= saddr,
> >> +		.v4.daddr	= daddr,
> >> +		.sport		= sport,
> >> +		.dport		= dport,
> >> +	};
> >> +
> >> +	return bpf_sk_lookup_run(net, &ctx);
> >> +}
> >> +
> >>  #endif /* _INET_HASHTABLES_H */
> >> diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
> >> index ab64834837c8..f4d07285591a 100644
> >> --- a/net/ipv4/inet_hashtables.c
> >> +++ b/net/ipv4/inet_hashtables.c
> >> @@ -307,9 +307,22 @@ struct sock *__inet_lookup_listener(struct net *net,
> >>  				    const int dif, const int sdif)
> >>  {
> >>  	struct inet_listen_hashbucket *ilb2;
> >> -	struct sock *result = NULL;
> >> +	struct sock *result, *reuse_sk;
> >>  	unsigned int hash2;
> >>
> >> +	/* Lookup redirect from BPF */
> >> +	result = inet_lookup_run_bpf(net, hashinfo->protocol,
> >> +				     saddr, sport, daddr, hnum);
> >> +	if (IS_ERR(result))
> >> +		return NULL;
> >> +	if (result) {
> >> +		reuse_sk = lookup_reuseport(net, result, skb, doff,
> >> +					    saddr, sport, daddr, hnum);
> >> +		if (reuse_sk)
> >> +			result = reuse_sk;
> >> +		goto done;
> >> +	}
> >> +
> >
> > The overhead is too high to do this all the time.
> > The feature has to be static_key-ed.
> 
> Static keys is something that Lorenz has also suggested internally, but
> we wanted to keep it simple at first.
> 
> Introduction of static keys forces us to decide when non-init_net netns
> are allowed to attach to SK_LOOKUP, as attaching enabling SK_LOOKUP in
> isolated netns will affect the rx path in init_net.
> 
> I see two options, which seem sensible:
> 
> 1) limit SK_LOOKUP to init_net, which makes testing setup harder, or
> 
> 2) allow non-init_net netns to attach to SK_LOOKUP only if static key
>    has been already enabled (via sysctl?).

I think both are overkill.
Just enable that static_key if any netns has progs.
Loading this prog type will be privileged operation even after cap_bpf.

> >
> > Also please add multi-prog support. Adding it later will cause
> > all sorts of compatibility issues. The semantics of multi-prog
> > needs to be thought through right now.
> > For example BPF_DROP or BPF_REDIRECT could terminate the prog_run_array
> > sequence of progs while BPF_OK could continue.
> > It's not ideal, but better than nothing.
> 
> I must say this approach is quite appealing because it's simple to
> explain. I would need a custom BPF_PROG_RUN_ARRAY, though.

of course.

> I'm curious what downside do you see here?
> Is overriding an earlier DROP/REDIRECT verdict useful?
> 
> > Another option could be to execute all attached progs regardless
> > of return code, but don't let second prog override selected_sk blindly.
> > bpf_sk_assign() could get smarter.
> 
> So if IIUC the rough idea here would be like below?
> 
> - 1st program calls
> 
>   bpf_sk_assign(ctx, sk1, 0 /*flags*/) -> 0 (OK)
> 
> - 2nd program calls
> 
>   bpf_sk_assign(ctx, sk2, 0) -> -EBUSY (already selected)
>   bpf_sk_assign(ctx, sk2, BPF_EXIST) -> 0 (OK, replace existing)
> 
> In this case the last program to run has the final say, as opposed to
> the semantics where DROP/REDIRECT terminates.
> 
> Also, 2nd and subsequent programs would probably need to know if and
> which socket has been already selected. I think the selection could be
> exposed in context as bpf_sock pointer.

I think running all is better.
The main down side of terminating early is predictability.
Imagine first prog is doing the sock selection based on some map configuration.
Then second prog gets loaded and doing its own selection.
These two progs are managed by different user space processes.
Now first map got changed and second prog stopped seeing the packets.
No warning. Nothing. With "bpf_sk_assign(ctx, sk2, 0) -> -EBUSY"
the second prog at least will see errors and will be able to log
and alert humans to do something about it.
The question of ordering come up, of course. But that ordering concerns
we had for some time with cgroup-bpf run array and it wasn't horrible.
We're still trying to solve it on cgroup-bpf side in a generic way,
but simple first-to-attach -> first-to-run was good enough there
and I think will be here as well. The whole dispatcher project
and managing policy, priority, ordering in user space better to solve
it generically for all cases. But the kernel should do simple basics.
