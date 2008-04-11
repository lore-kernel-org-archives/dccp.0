From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 11 Apr 2008 14:05:01 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <20080411140501.GR8192@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Apr 11, 2008 at 04:03:10PM +0200, Patrick McHardy escreveu:
> Gerrit Renker wrote:
>>>>>     [DCCP]: Fix skb->cb conflicts with IP
>>>>>         dev_queue_xmit() and the other IP output functions expect to 
>> <snip>
>>> Dave, I'm not sure whether you've missed this or expect it
>>> to go through Arnaldo, just want to make sure it doesn't
>>> get missed because of a misunderstanding :)
>>>
>>>
>> If it is not too much work, can you please also remove the two attached
>> hunks which are now redundant thanks to the above patch.
>
>
> I've added it to the patch, thanks.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>


> commit eced67957ee99f7b5fafdc73a58bcd037a1789b2
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Apr 4 14:10:23 2008 +0200
> 
>     [DCCP]: Fix skb->cb conflicts with IP
> 
>     dev_queue_xmit() and the other IP output functions expect to get a skb
>     with clear or properly initialized skb->cb. Unlike TCP and UDP, the
>     dccp_skb_cb doesn't contain a struct inet_skb_parm at the beginning,
>     so the DCCP-specific data is interpreted by the IP output functions.
>     This can cause false negatives for the conditional POST_ROUTING hook
>     invocation, making the packet bypass the hook.
> 
>     Add a inet_skb_parm/inet6_skb_parm union to the beginning of
>     dccp_skb_cb to avoid clashes. Also add a BUILD_BUG_ON to make
>     sure it fits in the cb.
> 
>     [ Combined with patch from Gerrit Renker to remove two now unnecessary
>       memsets of IPCB(skb)->opt ]
> 
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
> index fe7726b..f44d492 100644
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -325,6 +325,12 @@ static inline int dccp_bad_service_code(const struct sock *sk,
>   * This is used for transmission as well as for reception.
>   */
>  struct dccp_skb_cb {
> +	union {
> +		struct inet_skb_parm	h4;
> +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> +		struct inet6_skb_parm	h6;
> +#endif
> +	} header;
>  	__u8  dccpd_type:4;
>  	__u8  dccpd_ccval:4;
>  	__u8  dccpd_reset_code,
> diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> index e3f5d37..c91d3c1 100644
> --- a/net/dccp/proto.c
> +++ b/net/dccp/proto.c
> @@ -1057,6 +1057,9 @@ static int __init dccp_init(void)
>  	int ehash_order, bhash_order, i;
>  	int rc = -ENOBUFS;
>  
> +	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
> +		     FIELD_SIZEOF(struct sk_buff, cb));
> +
>  	dccp_hashinfo.bind_bucket_cachep >  		kmem_cache_create("dccp_bind_bucket",
>  				  sizeof(struct inet_bind_bucket), 0,
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -489,7 +489,6 @@ static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
>  
>  		dh->dccph_checksum = dccp_v4_csum_finish(skb, ireq->loc_addr,
>  							      ireq->rmt_addr);
> -		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
>  					    ireq->rmt_addr,
>  					    ireq->opt);
> --- a/net/dccp/output.c
> +++ b/net/dccp/output.c
> @@ -126,7 +126,6 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
>  
>  		DCCP_INC_STATS(DCCP_MIB_OUTSEGS);
>  
> -		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
>  		err = icsk->icsk_af_ops->queue_xmit(skb, 0);
>  		return net_xmit_eval(err);
>  	}

