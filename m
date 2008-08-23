From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 23 Aug 2008 10:50:46 +0000
Subject: Re: [PATCH] dccp: Reponsed with Reset when packet is received with
Message-Id: <20080823105046.GA25665@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <48AB7147.2010003@cn.fujitsu.com>
In-Reply-To: <48AB7147.2010003@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> In any case, I will be adding 
>>
>> --- a/net/dccp/options.c
>> +++ b/net/dccp/options.c
>> @@ -243,6 +243,7 @@ ignore_option:
>>  	}
>>   	/* mandatory was the last byte in option list -> reset connection */
>> +	rc = DCCP_RESET_CODE_OPTION_ERROR;
>>  	if (mandatory)
>>  		goto out_invalid_option;
>>   
>
> This patch seems not correctly. The patch may look like this :
>    while (opt_ptr != opt_end) {                 rc = 
> DCCP_RESET_CODE_OPTION_ERROR;
>    ...
>    }
>
> rc may be override by process change option, if is OK, rc become 0. So  
> the code "goto out_invalid_option;" in while statements will get reset  
> code 0.
>
You are right. In addition the above was not a good idea and had lead to
revising the test tree patch which set the reset code. The update resulted
in the abbreviated control flow shown below, with the cases:

 1. Header options with nonsensical lengths (-> out_nonsensical_length)
    These are now ignored as per 5.8 (page 30), as well as any options
    following the first erratic option.
 2. Invalid header options
    These cover mainly cases from 5.8, 5.8.2, and 6.6.8, in particular:
    - Mandatory option follows Mandatory option;
    - Mandatory was the last option in the list;
    - invalid per-option length (defined for each option individually);
    - failure of ccid_hc_{rx,tx}_parse_options()
      => at the moment, only ccid3_hc_tx_parse_options() is defined,
         and this also fails only if the per-option length is invalid.
 3. Invalid feature-negotiation option
    The feature-negotiation options have special semantics, as defined in
    6.6.7, 6.6.8, and 6.6.9. This is why the `rc' code is set by the
    feature-negotiation code. In all other current cases, "Option Error"
    is returned.

While at it, I noticed that there was an error in the third patch I had
submitted a few days ago. So thanks as always for looking through the
code, will submit/upload a revised version.

Gerrit

/* ------------------> updated control flow <------------------------- */
int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
{
	int rc;

	// ...
	switch ()  
		// ...
		case DCCPO_CHANGE_L ... DCCPO_CONFIRM_R:
			if (pkt_type = DCCP_PKT_DATA)      /* RFC 4340, 6 */
				break;
			rc = dccp_feat_parse_options(sk, dreq, mandatory, opt,
						    *value, value + 1, len - 1);
			if (rc)
				goto out_invalid_option;
			break;
	// ...			

	/* mandatory was the last byte in option list -> reset connection */
	if (mandatory)
		goto out_invalid_option;

out_nonsensical_length:
	/* RFC 4340, 5.8: ignore option and all remaining option space */
	return 0;

out_invalid_option:
	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
	rc = DCCP_RESET_CODE_OPTION_ERROR;
out_featneg_failed:
	DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
	DCCP_SKB_CB(skb)->dccpd_reset_code = rc;
	DCCP_SKB_CB(skb)->dccpd_reset_data[0] = opt;
	DCCP_SKB_CB(skb)->dccpd_reset_data[1] = len > 0 ? value[0] : 0;
	DCCP_SKB_CB(skb)->dccpd_reset_data[2] = len > 1 ? value[1] : 0;
	return -1;
}
