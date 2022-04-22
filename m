From: David Ahern <dsahern@kernel.org>
Date: Fri, 22 Apr 2022 02:30:52 +0000
Subject: Re: [PATCH net-next 1/3] ipv4: Don't reset ->flowi4_scope in ip_rt_fix_tos().
Message-Id: <0d4e27ee-385c-fd5d-bd31-51e9e2382667@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <c3fdfe3353158c9b9da14602619fb82db5e77f27.1650470610.git.gnault@redhat.com>
In-Reply-To: <c3fdfe3353158c9b9da14602619fb82db5e77f27.1650470610.git.gnault@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/20/22 5:21 PM, Guillaume Nault wrote:
> All callers already initialise ->flowi4_scope with RT_SCOPE_UNIVERSE,
> either by manual field assignment, memset(0) of the whole structure or
> implicit structure initialisation of on-stack variables
> (RT_SCOPE_UNIVERSE actually equals 0).
> 
> Therefore, we don't need to always initialise ->flowi4_scope in
> ip_rt_fix_tos(). We only need to reduce the scope to RT_SCOPE_LINK when
> the special RTO_ONLINK flag is present in the tos.
> 
> This will allow some code simplification, like removing
> ip_rt_fix_tos(). Also, the long term idea is to remove RTO_ONLINK
> entirely by properly initialising ->flowi4_scope, instead of
> overloading ->flowi4_tos with a special flag. Eventually, this will
> allow to convert ->flowi4_tos to dscp_t.
> 
> Signed-off-by: Guillaume Nault <gnault@redhat.com>
> ---
> It's important for the correctness of this patch that all callers
> initialise ->flowi4_scope to 0 (in one way or another). Auditing all of
> them is long, although each case is pretty trivial.
> 
> If it helps, I can send a patch series that converts implicit
> initialisation of ->flowi4_scope with an explicit assignment to
> RT_SCOPE_UNIVERSE. This would also have the advantage of making it
> clear to future readers that ->flowi4_scope _has_ to be initialised. I
> haven't sent such patch series to not overwhelm reviewers with trivial
> and not technically-required changes (there are 40+ places to modify,
> scattered over 30+ different files). But if anyone prefers explicit
> initialisation everywhere, then just let me know and I'll send such
> patches.

There are a handful of places that open code the initialization of the
flow struct. I *think* I found all of them in 40867d74c374.

> ---
>  net/ipv4/route.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/net/ipv4/route.c b/net/ipv4/route.c
> index e839d424b861..d8f82c0ac132 100644
> --- a/net/ipv4/route.c
> +++ b/net/ipv4/route.c
> @@ -503,8 +503,8 @@ static void ip_rt_fix_tos(struct flowi4 *fl4)
>  	__u8 tos = RT_FL_TOS(fl4);
>  
>  	fl4->flowi4_tos = tos & IPTOS_RT_MASK;
> -	fl4->flowi4_scope = tos & RTO_ONLINK ?
> -			    RT_SCOPE_LINK : RT_SCOPE_UNIVERSE;
> +	if (tos & RTO_ONLINK)
> +		fl4->flowi4_scope = RT_SCOPE_LINK;
>  }
>  
>  static void __build_flow_key(const struct net *net, struct flowi4 *fl4,

Reviewed-by: David Ahern <dsahern@kernel.org>
