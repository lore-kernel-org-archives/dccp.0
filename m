From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Fri, 06 May 2011 14:43:52 +0000
Subject: Re: [PATCH] dccp: handle invalid feature options length
Message-Id: <1304693032.1849.2.camel@dan>
List-Id: <dccp.vger.kernel.org>
References: <1304688438.29544.16.camel@dan>
In-Reply-To: <1304688438.29544.16.camel@dan>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org


> Can you please check again: did you experience this condition, to me it 
> seems the patch is based on reading this code.
> 

I saw this while reading the code.

> In this case, please consider the condition before the switch statement:
> 
>                 /* Check if this isn't a single byte option */
>                 if (opt > DCCPO_MAX_RESERVED) {
>                         if (opt_ptr = opt_end)
>                                 goto out_nonsensical_length;
> 
>                         len = *opt_ptr++;
>                         if (len < 2)
>                                 goto out_nonsensical_length;
>                          
> The described range (DCCPO_CHANGE_L = 32 ... DCCPO_CONFIRM_R = 35) is after DCCPO_MAX_RESERVED = 31,
> so that the above test applies.
> 
> Hence for these option types the len is always at least 1, so that (len - 1) >= 0.
> 

You just missed the important part:

                        if (len < 2)
                                goto out_nonsensical_length;
                        /*
                         * Remove the type and len fields, leaving
                         * just the value size
                         */
                        len     -= 2;

If the len is 2, this check will pass, and the resulting len will be 0,
causing the underflow.

Regards,
Dan

> | --- a/net/dccp/options.c
> | +++ b/net/dccp/options.c
> | @@ -123,6 +123,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
> |  		case DCCPO_CHANGE_L ... DCCPO_CONFIRM_R:
> |  			if (pkt_type = DCCP_PKT_DATA)      /* RFC 4340, 6 */
> |  				break;
> | +			if (len = 0)
> | +				goto out_invalid_option;
> |  			rc = dccp_feat_parse_options(sk, dreq, mandatory, opt,
> |  						    *value, value + 1, len - 1);
> |  			if (rc)
> | 
> | 
> 
> -- 


