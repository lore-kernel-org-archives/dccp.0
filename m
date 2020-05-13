From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 13 May 2020 18:10:20 +0000
Subject: Re: [PATCH bpf-next v2 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <20200513181020.dmj3fg3dbvuzl626@kafai-mbp.dhcp.thefacebook.com>
List-Id: <dccp.vger.kernel.org>
References: <20200511185218.1422406-3-jakub@cloudflare.com>
In-Reply-To: <20200511185218.1422406-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, May 13, 2020 at 04:34:13PM +0200, Jakub Sitnicki wrote:
> On Wed, May 13, 2020 at 07:41 AM CEST, Martin KaFai Lau wrote:
> > On Mon, May 11, 2020 at 08:52:03PM +0200, Jakub Sitnicki wrote:
> >
> > [ ... ]
> >
> >> +BPF_CALL_3(bpf_sk_lookup_assign, struct bpf_sk_lookup_kern *, ctx,
> >> +	   struct sock *, sk, u64, flags)
> > The SK_LOOKUP bpf_prog may have already selected the proper reuseport sk.
> > It is possible by looking up sk from sock_map.
> >
> > Thus, it is not always desired to do lookup_reuseport() after sk_assign()
> > in patch 5.  e.g. reuseport_select_sock() just uses a normal hash if
> > there is no reuse->prog.
> >
> > A flag (e.g. "BPF_F_REUSEPORT_SELECT") can be added here to
> > specifically do the reuseport_select_sock() after sk_assign().
> > If not set, reuseport_select_sock() should not be called.
> 
> That's true that in addition to steering connections to different
> services with SK_LOOKUP, you could also, in the same program,
> load-balance among sockets belonging to one service.
> 
> So skipping the reuseport socket selection, if sk_lookup already did
> load-balancing sounds useful.
> 
> Thinking about our use-case, I think we would always pass
> BPF_F_REUSEPORT_SELECT to sk_assign() because we either (i) know that
> application is using reuseport and want it manage the load-balancing
> socket group by itself, or (ii) don't know if application is using
> reuseport and don't want to break expected behavior.
Thanks for the explanation.

> 
> IOW, we'd like reuseport selection to run by default because application
> expects it to happen if it was set up. OTOH, the application doesn't
> have to be aware that there is sk_lookup attached (we can put one of its
> sockets in sk_lookup SOCKMAP when systemd activates it).
> 
> Beacuse of that I'd be in favor of having a flag for sk_assign() that
> disables reuseport selection on demand.
> 
> WDYT?
Sure, it is hard to comment which use case is more common than
another to take the default ;)
I think there are use caes for both, so no strong opinion on this ;)
