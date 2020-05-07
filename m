From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 07 May 2020 20:55:24 +0000
Subject: Re: [PATCH bpf-next 02/17] bpf: Introduce SK_LOOKUP program type with a dedicated attach point
Message-Id: <20200507205524.pv2pnujxdrbktdc4@kafai-mbp>
List-Id: <dccp.vger.kernel.org>
References: <20200506125514.1020829-3-jakub@cloudflare.com>
In-Reply-To: <20200506125514.1020829-3-jakub@cloudflare.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, May 06, 2020 at 03:53:35PM +0200, Jakub Sitnicki wrote:
> On Wed, May 06, 2020 at 03:16 PM CEST, Lorenz Bauer wrote:
> > On Wed, 6 May 2020 at 13:55, Jakub Sitnicki <jakub@cloudflare.com> wrote:
> 
> [...]
> 
> >> @@ -4012,4 +4051,18 @@ struct bpf_pidns_info {
> >>         __u32 pid;
> >>         __u32 tgid;
> >>  };
> >> +
> >> +/* User accessible data for SK_LOOKUP programs. Add new fields at the end. */
> >> +struct bpf_sk_lookup {
> >> +       __u32 family;           /* AF_INET, AF_INET6 */
> >> +       __u32 protocol;         /* IPPROTO_TCP, IPPROTO_UDP */
> >> +       /* IP addresses allows 1, 2, and 4 bytes access */
> >> +       __u32 src_ip4;
> >> +       __u32 src_ip6[4];
> >> +       __u32 src_port;         /* network byte order */
> >> +       __u32 dst_ip4;
> >> +       __u32 dst_ip6[4];
> >> +       __u32 dst_port;         /* host byte order */
> >
> > Jakub and I have discussed this off-list, but we couldn't come to an
> > agreement and decided to invite
> > your opinion.
> >
> > I think that dst_port should be in network byte order, since it's one
> > less exception to the
> > rule to think about when writing BPF programs.
> >
> > Jakub's argument is that this follows __sk_buff->local_port precedent,
> > which is also in host
> > byte order.
> 
> Yes, would be great to hear if there is a preference here.
> 
> Small correction, proposed sk_lookup program doesn't have access to
> __sk_buff, so perhaps that case matters less.
> 
> bpf_sk_lookup->dst_port, the packet destination port, is in host byte
> order so that it can be compared against bpf_sock->src_port, socket
> local port, without conversion.
> 
> But I also see how it can be a surprise for a BPF user that one field has
> a different byte order.
I would also prefer port and addr were all in the same byte order.
However, it is not the cases for the other prog_type ctx.
People has stomped on it from time to time.  May be something
can be done at the libbpf to hide this difference.

I think uapi consistency with other existing ctx is more important here.
(i.e. keep the "local" port in host order).  Otherwise, the user will
be slapped left and right when writting bpf_prog in different prog_type.

Armed with the knowledge on skc_num, the "local" port is
in host byte order in the current existing prog ctx.  It is
unfortunate that the "dst"_port in this patch is the "local" port.
The "local" port in "struct bpf_sock" is actually the "src"_port. :/
Would "local"/"remote" be clearer than "src"/dst" in this patch?
