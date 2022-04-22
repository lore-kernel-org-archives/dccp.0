From: David Ahern <dsahern@kernel.org>
Date: Fri, 22 Apr 2022 02:32:35 +0000
Subject: Re: [PATCH net-next 2/3] ipv4: Avoid using RTO_ONLINK with ip_route_connect().
Message-Id: <5f09f4d0-71d0-f122-d83e-6071fc2945b2@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <492f91626cab774d7dda27147629c3d56537f847.1650470610.git.gnault@redhat.com>
In-Reply-To: <492f91626cab774d7dda27147629c3d56537f847.1650470610.git.gnault@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 4/20/22 5:21 PM, Guillaume Nault wrote:
> Now that ip_rt_fix_tos() doesn't reset ->flowi4_scope unconditionally,
> we don't have to rely on the RTO_ONLINK bit to properly set the scope
> of a flowi4 structure. We can just set ->flowi4_scope explicitly and
> avoid using RTO_ONLINK in ->flowi4_tos.
> 
> This patch converts callers of ip_route_connect(). Instead of setting
> the tos parameter with RT_CONN_FLAGS(sk), as all callers do, we can:
> 
>   1- Drop the tos parameter from ip_route_connect(): its value was
>      entirely based on sk, which is also passed as parameter.
> 
>   2- Set ->flowi4_scope depending on the SOCK_LOCALROUTE socket option
>      instead of always initialising it with RT_SCOPE_UNIVERSE (let's
>      define ip_sock_rt_scope() for this purpose).
> 
>   3- Avoid overloading ->flowi4_tos with RTO_ONLINK: since the scope is
>      now properly initialised, we don't need to tell ip_rt_fix_tos() to
>      adjust ->flowi4_scope for us. So let's define ip_sock_rt_tos(),
>      which is the same as RT_CONN_FLAGS() but without the RTO_ONLINK
>      bit overload.
> 
> Note:
>   In the original ip_route_connect() code, __ip_route_output_key()
>   might clear the RTO_ONLINK bit of fl4->flowi4_tos (because of
>   ip_rt_fix_tos()). Therefore flowi4_update_output() had to reuse the
>   original tos variable. Now that we don't set RTO_ONLINK any more,
>   this is not a problem and we can use fl4->flowi4_tos in
>   flowi4_update_output().
> 
> Signed-off-by: Guillaume Nault <gnault@redhat.com>
> ---
>  include/net/route.h | 36 ++++++++++++++++++++++++------------
>  net/dccp/ipv4.c     |  5 ++---
>  net/ipv4/af_inet.c  |  6 +++---
>  net/ipv4/datagram.c |  7 +++----
>  net/ipv4/tcp_ipv4.c |  5 ++---
>  5 files changed, 34 insertions(+), 25 deletions(-)
> 

Reviewed-by: David Ahern <dsahern@kernel.org>

