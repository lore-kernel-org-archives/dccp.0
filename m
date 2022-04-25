From: Guillaume Nault <gnault@redhat.com>
Date: Mon, 25 Apr 2022 10:04:32 +0000
Subject: Re: [PATCH net-next 1/3] ipv4: Don't reset ->flowi4_scope in ip_rt_fix_tos().
Message-Id: <20220425100432.GA3478@pc-4.home>
List-Id: <dccp.vger.kernel.org>
References: <c3fdfe3353158c9b9da14602619fb82db5e77f27.1650470610.git.gnault@redhat.com>
In-Reply-To: <c3fdfe3353158c9b9da14602619fb82db5e77f27.1650470610.git.gnault@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Fri, Apr 22, 2022 at 08:40:01AM -0600, David Ahern wrote:
> On 4/22/22 4:53 AM, Guillaume Nault wrote:
> > On Thu, Apr 21, 2022 at 08:30:52PM -0600, David Ahern wrote:
> >> On 4/20/22 5:21 PM, Guillaume Nault wrote:
> >>> All callers already initialise ->flowi4_scope with RT_SCOPE_UNIVERSE,
> >>> either by manual field assignment, memset(0) of the whole structure or
> >>> implicit structure initialisation of on-stack variables
> >>> (RT_SCOPE_UNIVERSE actually equals 0).
> >>>
> >>> Therefore, we don't need to always initialise ->flowi4_scope in
> >>> ip_rt_fix_tos(). We only need to reduce the scope to RT_SCOPE_LINK when
> >>> the special RTO_ONLINK flag is present in the tos.
> >>>
> >>> This will allow some code simplification, like removing
> >>> ip_rt_fix_tos(). Also, the long term idea is to remove RTO_ONLINK
> >>> entirely by properly initialising ->flowi4_scope, instead of
> >>> overloading ->flowi4_tos with a special flag. Eventually, this will
> >>> allow to convert ->flowi4_tos to dscp_t.
> >>>
> >>> Signed-off-by: Guillaume Nault <gnault@redhat.com>
> >>> ---
> >>> It's important for the correctness of this patch that all callers
> >>> initialise ->flowi4_scope to 0 (in one way or another). Auditing all of
> >>> them is long, although each case is pretty trivial.
> >>>
> >>> If it helps, I can send a patch series that converts implicit
> >>> initialisation of ->flowi4_scope with an explicit assignment to
> >>> RT_SCOPE_UNIVERSE. This would also have the advantage of making it
> >>> clear to future readers that ->flowi4_scope _has_ to be initialised. I
> >>> haven't sent such patch series to not overwhelm reviewers with trivial
> >>> and not technically-required changes (there are 40+ places to modify,
> >>> scattered over 30+ different files). But if anyone prefers explicit
> >>> initialisation everywhere, then just let me know and I'll send such
> >>> patches.
> >>
> >> There are a handful of places that open code the initialization of the
> >> flow struct. I *think* I found all of them in 40867d74c374.
> > 
> > By open code, do you mean "doesn't use flowi4_init_output() nor
> > ip_tunnel_init_flow()"? If so, I think there are many more.
> > 
> 
> no, you made a comment about flow struct being initialized to 0 which
> implicitly initializes scope. My comment is that there are only a few
> places that do not use either `memset(flow, 0, sizeof())` or `struct
> flowi4 fl4 = {}` to fully initialize the struct.

Yes, that's right. But I've only audited the call paths that lead to
ip_route_output_key_hash() (plus the ICMP error handlers), as these are
the ones that were relevant for this patch series. So I haven't looked
at flow initialisation in the ip_route_input*() or IPv6 call paths.
