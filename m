From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 28 Aug 2008 21:50:09 +0000
Subject: Re: [PATCH 18/37] dccp: Support for Mandatory options
Message-Id: <20080828215009.GW9193@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1219945512-7723-19-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1219945512-7723-19-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Aug 28, 2008 at 07:44:53PM +0200, Gerrit Renker escreveu:
> Support for Mandatory options is provided by this patch, which will
> be used by subsequent feature-negotiation patches.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> ---
>  net/dccp/feat.h    |    2 ++
>  net/dccp/options.c |   15 +++++++++++++++
>  2 files changed, 17 insertions(+), 0 deletions(-)
> 
> --- a/net/dccp/feat.h
> +++ b/net/dccp/feat.h
> @@ -136,4 +136,6 @@ extern int  dccp_feat_init(struct sock *sk);
>  
>  extern void dccp_encode_value_var(const u64 value, u8 *to, const u8 len);
>  extern u64  dccp_decode_value_var(const u8 *bf, const u8 len);
> +
> +extern int  dccp_insert_option_mandatory(struct sk_buff *skb);
>  #endif /* _DCCP_FEAT_H */
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -467,6 +467,21 @@ static int dccp_insert_option_timestamp_echo(struct dccp_sock *dp,
>  	return 0;
>  }
>  
> +/**
> + * dccp_insert_option_mandatory  -  Mandatory option (5.8.2)
> + * Note that since we are using skb_push, this function needs to be called
> + * _after_ inserting the option it is supposed to influence (stack order).
> + */
> +int dccp_insert_option_mandatory(struct sk_buff *skb)
> +{
> +	if (DCCP_SKB_CB(skb)->dccpd_opt_len >= DCCP_MAX_OPT_LEN)
> +		return -1;
> +
> +	DCCP_SKB_CB(skb)->dccpd_opt_len++;
> +	*skb_push(skb, 1) = DCCPO_MANDATORY;
> +	return 0;
> +}
> +
>  static int dccp_insert_feat_opt(struct sk_buff *skb, u8 type, u8 feat,
>  				u8 *val, u8 len)
>  {
> -- 
> 1.6.0.rc2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
