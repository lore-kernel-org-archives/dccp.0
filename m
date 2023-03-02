From: Paolo Abeni <pabeni@redhat.com>
Date: Thu, 02 Mar 2023 14:27:37 +0000
Subject: Re: [PATCH] [net:netfilter]: Keep conntrack reference until IPsecv6 policy checks are done
Message-Id: <3dc0b4652c04c508b21f2028a20b7f81387c7fd4.camel@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <20230302113523.GD23204@breakpoint.cc>
In-Reply-To: <20230302113523.GD23204@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Thu, 2023-03-02 at 16:53 +0530, Madhu Koriginja wrote:
> Keep the conntrack reference until policy checks have been performed for
> IPsec V6 NAT support. The reference needs to be dropped before a packet is
> queued to avoid having the conntrack module unloadable.
> 
> Signed-off-by: Madhu Koriginja <madhu.koriginja@nxp.com>
> 	V1-V2: added missing () in ip6_input.c in below condition
> 	if (!(ipprot->flags & INET6_PROTO_NOPOLICY))
> ---
>  net/dccp/ipv6.c      |  1 +
>  net/ipv6/ip6_input.c | 14 +++++++-------
>  net/ipv6/raw.c       |  2 +-
>  net/ipv6/tcp_ipv6.c  |  2 ++
>  net/ipv6/udp.c       |  2 ++
>  5 files changed, 13 insertions(+), 8 deletions(-)
> 
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 58a401e9cf09..eb503096db6c 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -771,6 +771,7 @@ static int dccp_v6_rcv(struct sk_buff *skb)
>  
>  	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
>  		goto discard_and_relse;
> +	nf_reset(skb);

nf_reset() is gone since commit 895b5c9f206e ("netfilter: drop bridge
nf reset from nf_reset"), you should use instead nf_reset_ct(): in the
current form the patch does not apply cleanly (nor build after manual
edit).


Cheers,

Paolo
