From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 08 Apr 2008 18:18:04 +0000
Subject: Re: [RFC][PATCH 10/12][NETNS][DCCPV6]: Move the dccp_v6_ctl_sk on
Message-Id: <20080408181804.GA8192@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <47FBAB09.9000305@openvz.org>
In-Reply-To: <47FBAB09.9000305@openvz.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Apr 08, 2008 at 09:27:37PM +0400, Pavel Emelyanov escreveu:
> And replace all its usage with init_net's socket.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ---
>  include/net/netns/dccp.h |    1 +
>  net/dccp/ipv6.c          |   16 ++++++++--------
>  2 files changed, 9 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/netns/dccp.h b/include/net/netns/dccp.h
> index e4f16fa..98d2a7c 100644
> --- a/include/net/netns/dccp.h
> +++ b/include/net/netns/dccp.h
> @@ -5,6 +5,7 @@ struct sock;
>  
>  struct netns_dccp {
>  	struct sock *v4_ctl_sk;
> +	struct sock *v6_ctl_sk;
>  };
>  
>  #endif
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 2ca5291..109dab3 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -33,8 +33,7 @@
>  #include "ipv6.h"
>  #include "feat.h"
>  
> -/* Socket used for sending RSTs and ACKs */
> -static struct sock *dccp_v6_ctl_sk;
> +/* dccp_v6_ctl_sk is used for sending RSTs and ACKs */

Wrong comment?
  
>  static struct inet_connection_sock_af_ops dccp_ipv6_mapped;
>  static struct inet_connection_sock_af_ops dccp_ipv6_af_ops;
> @@ -296,6 +295,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
>  	struct ipv6hdr *rxip6h;
>  	struct sk_buff *skb;
>  	struct flowi fl;
> +	struct sock *ctl_sk = init_net.dccp.v6_ctl_sk;
>  
>  	if (dccp_hdr(rxskb)->dccph_type = DCCP_PKT_RESET)
>  		return;
> @@ -303,7 +303,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
>  	if (!ipv6_unicast_destination(rxskb))
>  		return;
>  
> -	skb = dccp_ctl_make_reset(dccp_v6_ctl_sk, rxskb);
> +	skb = dccp_ctl_make_reset(ctl_sk, rxskb);
>  	if (skb = NULL)
>  		return;
>  
> @@ -322,9 +322,9 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
>  	security_skb_classify_flow(rxskb, &fl);
>  
>  	/* sk = NULL, but it is safe for now. RST socket required. */
> -	if (!ip6_dst_lookup(dccp_v6_ctl_sk, &skb->dst, &fl)) {
> +	if (!ip6_dst_lookup(ctl_sk, &skb->dst, &fl)) {
>  		if (xfrm_lookup(&skb->dst, &fl, NULL, 0) >= 0) {
> -			ip6_xmit(dccp_v6_ctl_sk, skb, &fl, NULL, 0);
> +			ip6_xmit(ctl_sk, skb, &fl, NULL, 0);
>  			DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
>  			DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
>  			return;
> @@ -1198,7 +1198,7 @@ static int __init dccp_v6_init(void)
>  
>  	inet6_register_protosw(&dccp_v6_protosw);
>  
> -	err = inet_ctl_sock_create(&dccp_v6_ctl_sk, PF_INET6,
> +	err = inet_ctl_sock_create(&init_net.dccp.v6_ctl_sk, PF_INET6,
>  				   SOCK_DCCP, IPPROTO_DCCP, &init_net);
>  	if (err != 0)
>  		goto out_unregister_protosw;
> @@ -1210,7 +1210,7 @@ out:
>  	return err;
>  
>  out_destroy_ctl_sock:
> -	inet_ctl_sock_destroy(dccp_v6_ctl_sk);
> +	inet_ctl_sock_destroy(init_net.dccp.v6_ctl_sk);
>  out_unregister_protosw:
>  	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
>  	inet6_unregister_protosw(&dccp_v6_protosw);
> @@ -1222,7 +1222,7 @@ out_unregister_proto:
>  static void __exit dccp_v6_exit(void)
>  {
>  	unregister_pernet_subsys(&dccp_v6_ops);
> -	inet_ctl_sock_destroy(dccp_v6_ctl_sk);
> +	inet_ctl_sock_destroy(init_net.dccp.v6_ctl_sk);
>  	inet6_del_protocol(&dccp_v6_protocol, IPPROTO_DCCP);
>  	inet6_unregister_protosw(&dccp_v6_protosw);
>  	proto_unregister(&dccp_v6_prot);
> -- 
> 1.5.3.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
