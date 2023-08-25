From: Kuniyuki Iwashima <kuniyu@amazon.com>
Date: Fri, 25 Aug 2023 18:35:08 +0000
Subject: Re: [PATCH net] dccp: Fix out of bounds access in DCCP error handler
Message-Id: <20230825183508.8687-1-kuniyu@amazon.com>
List-Id: <dccp.vger.kernel.org>
References: <20230825133241.3635236-1-jannh@google.com>
In-Reply-To: <20230825133241.3635236-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Jann Horn <jannh@google.com>
Date: Fri, 25 Aug 2023 15:32:41 +0200
> There was a previous attempt to fix an out-of-bounds access in the DCCP
> error handlers, but that fix assumed that the error handlers only want
> to access the first 8 bytes of the DCCP header. Actually, they also look
> at the DCCP sequence number, which is stored beyond 8 bytes, so an
> explicit pskb_may_pull() is required.
> 
> Fixes: 6706a97fec96 ("dccp: fix out of bound access in dccp_v4_err()")
> Fixes: 1aa9d1a0e7ee ("ipv6: dccp: fix out of bound access in dccp_v6_err()")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>

Reviewed-by: Kuniyuki Iwashima <kuniyu@amazon.com>


> ---
>  net/dccp/ipv4.c | 13 +++++++++----
>  net/dccp/ipv6.c | 15 ++++++++++-----
>  2 files changed, 19 insertions(+), 9 deletions(-)
> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index fa8079303cb0..dcd2fb774d82 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -255,12 +255,17 @@ static int dccp_v4_err(struct sk_buff *skb, u32 info)
>  	int err;
>  	struct net *net = dev_net(skb->dev);
>  
> -	/* Only need dccph_dport & dccph_sport which are the first
> -	 * 4 bytes in dccp header.
> +	/* For the first __dccp_basic_hdr_len() check, we only need dh->dccph_x,
> +	 * which is in byte 7 of the dccp header.
>  	 * Our caller (icmp_socket_deliver()) already pulled 8 bytes for us.
> +	 *
> +	 * Later on, we want to access the sequence number fields, which are
> +	 * beyond 8 bytes, so we have to pskb_may_pull() ourselves.
>  	 */
> -	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_sport) > 8);
> -	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_dport) > 8);
> +	dh = (struct dccp_hdr *)(skb->data + offset);
> +	if (!pskb_may_pull(skb, offset + __dccp_basic_hdr_len(dh)))
> +		return -EINVAL;
> +	iph = (struct iphdr *)skb->data;
>  	dh = (struct dccp_hdr *)(skb->data + offset);
>  
>  	sk = __inet_lookup_established(net, &dccp_hashinfo,
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index d29d1163203d..25816e790527 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -74,7 +74,7 @@ static inline __u64 dccp_v6_init_sequence(struct sk_buff *skb)
>  static int dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  			u8 type, u8 code, int offset, __be32 info)
>  {
> -	const struct ipv6hdr *hdr = (const struct ipv6hdr *)skb->data;
> +	const struct ipv6hdr *hdr;
>  	const struct dccp_hdr *dh;
>  	struct dccp_sock *dp;
>  	struct ipv6_pinfo *np;
> @@ -83,12 +83,17 @@ static int dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
>  	__u64 seq;
>  	struct net *net = dev_net(skb->dev);
>  
> -	/* Only need dccph_dport & dccph_sport which are the first
> -	 * 4 bytes in dccp header.
> +	/* For the first __dccp_basic_hdr_len() check, we only need dh->dccph_x,
> +	 * which is in byte 7 of the dccp header.
>  	 * Our caller (icmpv6_notify()) already pulled 8 bytes for us.
> +	 *
> +	 * Later on, we want to access the sequence number fields, which are
> +	 * beyond 8 bytes, so we have to pskb_may_pull() ourselves.
>  	 */
> -	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_sport) > 8);
> -	BUILD_BUG_ON(offsetofend(struct dccp_hdr, dccph_dport) > 8);
> +	dh = (struct dccp_hdr *)(skb->data + offset);
> +	if (!pskb_may_pull(skb, offset + __dccp_basic_hdr_len(dh)))
> +		return -EINVAL;
> +	hdr = (const struct ipv6hdr *)skb->data;
>  	dh = (struct dccp_hdr *)(skb->data + offset);
>  
>  	sk = __inet6_lookup_established(net, &dccp_hashinfo,
> 
> base-commit: 93f5de5f648d2b1ce3540a4ac71756d4a852dc23
> -- 
> 2.42.0.rc1.204.g551eb34607-goog
