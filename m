From: David Ahern <dsahern@kernel.org>
Date: Fri, 22 Apr 2022 03:10:21 +0000
Subject: Re: [PATCH net-next 0/3] ipv4: First steps toward removing RTO_ONLINK
Message-Id: <2ee8fb0d-aeb4-5010-bc8c-16cbd6e88eff@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <cover.1650470610.git.gnault@redhat.com>
In-Reply-To: <cover.1650470610.git.gnault@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/20/22 5:21 PM, Guillaume Nault wrote:
> RTO_ONLINK is a flag that allows to reduce the scope of route lookups.
> It's stored in a normally unused bit of the ->flowi4_tos field, in
> struct flowi4. However it has several problems:
> 
>  * This bit is also used by ECN. Although ECN bits are supposed to be
>    cleared before doing a route lookup, it happened that some code
>    paths didn't properly sanitise their ->flowi4_tos. So this mechanism
>    is fragile and we had bugs in the past where ECN bits slipped in and
>    could end up being erroneously interpreted as RTO_ONLINK.
> 
>  * A dscp_t type was recently introduced to ensure ECN bits are cleared
>    during route lookups. ->flowi4_tos is the most important structure
>    field to convert, but RTO_ONLINK prevents such conversion, as dscp_t
>    mandates that ECN bits (where RTO_ONLINK is stored) be zero.
> 
> Therefore we need to stop using RTO_ONLINK altogether. Fortunately
> RTO_ONLINK isn't a necessity. Instead of passing a flag in ->flowi4_tos
> to tell the route lookup function to restrict the scope, we can simply
> initialise the scope correctly.
> 

I believe the set looks ok. I think the fib test coverage in selftests
could use more tests to cover tos.
