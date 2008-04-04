From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 04 Apr 2008 13:47:11 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <20080404134711.GB5989@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Apr 04, 2008 at 02:25:25PM +0100, Gerrit Renker escreveu:
> Arnaldo,
> 
> just a thought - I recall that there used to be a bug related to this,
> which required to insert the following before sending an skb:
>      
>      memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt))
> 
> This was about 1+1/2 .. 2 years ago and lead to crashes when the memset
> was removed. Maybe with this solution the memsets are then no longer
> necessary? The reference is
>  * output.c:dccp_transmit_skb()
>  * ipv4.c:dccp_v4_send_response()

Well spotted, yes, those can now be safely removed, since we don't touch
the initial inet6?_skb_parm area it will remain as zeros (alloc_skb did
that for us) and we don't have to zero it anymore before passing it to
IP.

- Arnaldo

> Gerrit	
> 
> | commit eced67957ee99f7b5fafdc73a58bcd037a1789b2
> | Author: Patrick McHardy <kaber@trash.net>
> | Date:   Fri Apr 4 14:10:23 2008 +0200
> | 
> |     [DCCP]: Fix skb->cb conflicts with IP
> |     
> |     dev_queue_xmit() and the other IP output functions expect to get a skb
> |     with clear or properly initialized skb->cb. Unlike TCP and UDP, the
> |     dccp_skb_cb doesn't contain a struct inet_skb_parm at the beginning,
> |     so the DCCP-specific data is interpreted by the IP output functions.
> |     This can cause false negatives for the conditional POST_ROUTING hook
> |     invocation, making the packet bypass the hook.
> |     
> |     Add a inet_skb_parm/inet6_skb_parm union to the beginning of
> |     dccp_skb_cb to avoid clashes. Also add a BUILD_BUG_ON to make
> |     sure it fits in the cb.
> |     
> |     Signed-off-by: Patrick McHardy <kaber@trash.net>
> | 
> | diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
> | index fe7726b..f44d492 100644
> | --- a/net/dccp/dccp.h
> | +++ b/net/dccp/dccp.h
> | @@ -325,6 +325,12 @@ static inline int dccp_bad_service_code(const struct sock *sk,
> |   * This is used for transmission as well as for reception.
> |   */
> |  struct dccp_skb_cb {
> | +	union {
> | +		struct inet_skb_parm	h4;
> | +#if defined(CONFIG_IPV6) || defined (CONFIG_IPV6_MODULE)
> | +		struct inet6_skb_parm	h6;
> | +#endif
> | +	} header;
> |  	__u8  dccpd_type:4;
> |  	__u8  dccpd_ccval:4;
> |  	__u8  dccpd_reset_code,
> | diff --git a/net/dccp/proto.c b/net/dccp/proto.c
> | index e3f5d37..c91d3c1 100644
> | --- a/net/dccp/proto.c
> | +++ b/net/dccp/proto.c
> | @@ -1057,6 +1057,9 @@ static int __init dccp_init(void)
> |  	int ehash_order, bhash_order, i;
> |  	int rc = -ENOBUFS;
> |  
> | +	BUILD_BUG_ON(sizeof(struct dccp_skb_cb) >
> | +		     FIELD_SIZEOF(struct sk_buff, cb));
> | +
> |  	dccp_hashinfo.bind_bucket_cachep > |  		kmem_cache_create("dccp_bind_bucket",
> |  				  sizeof(struct inet_bind_bucket), 0,
> 
> 
> -- 
> 
> 
> The University of Aberdeen is a charity registered in Scotland, No SC013683.
> 
