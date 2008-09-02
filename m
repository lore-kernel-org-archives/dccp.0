From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 02 Sep 2008 06:59:42 +0000
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change feature-negotiation
Message-Id: <48BCE45E.1080709@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> This is a revision of [PATCH 3/3] submitted a few days ago, correcting
> the use of a jump label - the control wrongly went to invalid_option
> when feature negotiation failed.
>
> Also tidied the patch up a little to make it easier to review.
>
> ----------------------------> Patch v3 <-----------------------------
> dccp: Process incoming Change feature-negotiation options
>
> This adds/replaces code for processing incoming ChangeL/R options.
> The main difference is that:
>  * mandatory FN options are now interpreted inside the function
>   (there are too many individual cases to do this externally);
>  * the function returns an appropriate Reset code or 0,
>    which is then used to fill in the data for the Reset packet.
>
> Old code, which is no longer used or referenced, has been removed.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/feat.c    |  148 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  net/dccp/feat.h    |    4 -
>  net/dccp/options.c |   23 ++------
>  3 files changed, 157 insertions(+), 18 deletions(-)
>
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -128,22 +128,13 @@ int dccp_parse_options(struct sock *sk, 
>  				      (unsigned long long)opt_recv->dccpor_ndp);
>  			break;
>  		case DCCPO_CHANGE_L:
> -			/* fall through */
>  		case DCCPO_CHANGE_R:
>  			if (pkt_type = DCCP_PKT_DATA)
>  				break;
> -			if (len < 2)
> -				goto out_invalid_option;
> -			rc = dccp_feat_change_recv(sk, opt, *value, value + 1,
> -						   len - 1);
> -			/*
> -			 * When there is a change error, change_recv is
> -			 * responsible for dealing with it.  i.e. reply with an
> -			 * empty confirm.
> -			 * If the change was mandatory, then we need to die.
> -			 */
> -			if (rc && mandatory)
> -				goto out_invalid_option;
> +			rc = dccp_feat_parse_options(sk, dreq, mandatory, opt,
> +						    *value, value + 1, len - 1);
> +			if (rc)
> +				goto out_featneg_failed;
>  			break;
>  		case DCCPO_CONFIRM_L:
>  			/* fall through */
> @@ -277,8 +268,10 @@ out_nonsensical_length:
>  
>  out_invalid_option:
>  	DCCP_INC_STATS_BH(DCCP_MIB_INVALIDOPT);
> -	DCCP_SKB_CB(skb)->dccpd_reset_code = DCCP_RESET_CODE_OPTION_ERROR;
> -	DCCP_WARN("DCCP(%p): invalid option %d, len=%d", sk, opt, len);
> +	rc = DCCP_RESET_CODE_OPTION_ERROR;
> +out_featneg_failed:
> +	DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
> +	DCCP_SKB_CB(skb)->dccpd_reset_code = rc;
>  	DCCP_SKB_CB(skb)->dccpd_reset_data[0] = opt;
>  	DCCP_SKB_CB(skb)->dccpd_reset_data[1] = len > 0 ? value[0] : 0;
>  	DCCP_SKB_CB(skb)->dccpd_reset_data[2] = len > 1 ? value[1] : 0;
> --- a/net/dccp/feat.h
> +++ b/net/dccp/feat.h
> @@ -113,8 +113,8 @@ static inline void dccp_feat_debug(const
>  extern int  dccp_feat_register_sp(struct sock *sk, u8 feat, u8 is_local,
>  				  u8 const *list, u8 len);
>  extern int  dccp_feat_register_nn(struct sock *sk, u8 feat, u64 val);
> -extern int  dccp_feat_change_recv(struct sock *sk, u8 type, u8 feature,
> -				  u8 *val, u8 len);
> +extern int  dccp_feat_parse_options(struct sock *, struct dccp_request_sock *,
> +				    u8 mand, u8 opt, u8 feat, u8 *val, u8 len);
>  extern int  dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
>  				   u8 *val, u8 len);
>  extern void dccp_feat_clean(struct dccp_minisock *dmsk);
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -973,7 +973,6 @@ static int dccp_feat_nn(struct sock *sk,
>  
>  	return 0;
>  }
> -#endif /* (later) */
>  
>  static void dccp_feat_empty_confirm(struct dccp_minisock *dmsk,
>  				    u8 type, u8 feature)
> @@ -1084,6 +1083,7 @@ int dccp_feat_change_recv(struct sock *s
>  }
>  
>  EXPORT_SYMBOL_GPL(dccp_feat_change_recv);
> +#endif	/* (later) */
>  
>  int dccp_feat_confirm_recv(struct sock *sk, u8 type, u8 feature,
>  			   u8 *val, u8 len)
> @@ -1224,6 +1224,152 @@ out_clean:
>  
>  EXPORT_SYMBOL_GPL(dccp_feat_clone);
>  
> +/**
> + * dccp_feat_change_recv  -  Process incoming ChangeL/R options
> + * @fn: feature-negotiation list to update
> + * @is_mandatory: whether the Change was preceded by a Mandatory option
> + * @opt: %DCCPO_CHANGE_L or %DCCPO_CHANGE_R
> + * @feat: one of %dccp_feature_numbers
> + * @val: NN value or SP value/preference list
> + * @len: length of @val in bytes
> + * @server: whether this node is the server (1) or the client (0)
> + */
> +static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
> +				u8 feat, u8 *val, u8 len, const bool server)
> +{
> +	u8 defval, type = dccp_feat_type(feat);
> +	const bool local = (opt = DCCPO_CHANGE_R);
> +	struct dccp_feat_entry *entry;
> +	dccp_feat_val fval;
> +
> +	if (len = 0 || type = FEAT_UNKNOWN)		/* 6.1 and 6.6.8 */
> +		goto unknown_feature_or_value;
> +
> +	/*
> +	 *	Negotiation of NN features: Change R is invalid, so there is no
> +	 *	simultaneous negotiation; hence we do not consult the list.
> +	 */
> +	if (type = FEAT_NN) {
> +		if (local)
> +			goto not_valid_or_not_known;
>   
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Here should be "goto unknown_feature_or_value"?

Change R is invalid, and RFC4340 6.6.8

An endpoint receiving an invalid Change option MUST respond with the
corresponding empty Confirm option.

Is this right?

> +
> +		if (len > sizeof(fval.nn))
> +			goto unknown_feature_or_value;
> +
> +		/* 6.3.2: "The feature remote MUST accept any valid value..." */
> +		fval.nn = dccp_decode_value_var(val, len);
> +		if (!dccp_feat_is_valid_nn_val(feat, fval.nn))
> +			goto unknown_feature_or_value;
> +
> +		return dccp_feat_push_confirm(fn, feat, local, &fval);
> +	}
> +
> +	/*
> +	 *	Unidirectional/simultaneous negotiation of SP features (6.3.1)
> +	 */
> +	entry = dccp_feat_list_lookup(fn, feat, local);
> +	if (entry = NULL) {
> +		if (!dccp_feat_sp_list_ok(feat, val, len))
> +			goto unknown_feature_or_value;
>   

Check for sp feat list should before code "entry = 
dccp_feat_list_lookup(fn, feat, local);",
here only check for features not register by local endpoint, if the 
feature is registed, the
validity check is missing?

> +		/*
> +		 * No particular preferences have been registered. We deal with
> +		 * this situation by assuming that all valid values are equally
> +		 * acceptable, and apply the following checks:
> +		 * - if the peer's list is a singleton, we accept a valid value;
> +		 * - if we are the server, we first try to see if the peer (the
> +		 *   client) advertises the default value. If yes, we use it,
> +		 *   otherwise we accept the preferred value;
> +		 * - else if we are the client, we use the first list element.
> +		 */
> +		if (dccp_feat_clone_sp_val(&fval, val, 1))
> +			return DCCP_RESET_CODE_TOO_BUSY;
> +
> +		if (len > 1 && server) {
> +			defval = dccp_feat_default_value(feat);
> +			if (dccp_feat_preflist_match(&defval, 1, val, len) > -1)
> +				fval.sp.vec[0] = defval;
> +		}
> +
> +		/* Treat unsupported CCIDs like invalid values */
> +		if (feat = DCCPF_CCID && !ccid_support_check(fval.sp.vec, 1)) {
> +			kfree(fval.sp.vec);
> +			goto not_valid_or_not_known;
> +		}
> +
> +		return dccp_feat_push_confirm(fn, feat, local, &fval);
> +
> +	} else if (entry->state = FEAT_UNSTABLE) {	/* 6.6.2 */
> +		return 0;
> +	}
> +
> +	if (dccp_feat_reconcile(&entry->val, val, len, server, true)) {
> +		entry->empty_confirm = 0;
> +	} else if (is_mandatory) {
> +		return DCCP_RESET_CODE_MANDATORY_ERROR;
> +	} else if (entry->state = FEAT_INITIALISING) {
> +		/*
> +		 * Failed simultaneous negotiation (server only): try to `save'
> +		 * the connection by checking whether entry contains the default
> +		 * value for @feat. If yes, send an empty Confirm to signal that
> +		 * the received Change was not understood - which implies using
> +		 * the default value.
> +		 * If this also fails, we use Reset as the last resort.
> +		 */
> +		WARN_ON(!server);
> +		defval = dccp_feat_default_value(feat);
> +		if (!dccp_feat_reconcile(&entry->val, &defval, 1, server, true))
> +			return DCCP_RESET_CODE_OPTION_ERROR;
> +		entry->empty_confirm = 1;
> +	}
> +	entry->needs_confirm   = 1;
> +	entry->needs_mandatory = 0;
> +	entry->state	       = FEAT_STABLE;
> +	return 0;
> +
> +unknown_feature_or_value:
> +	if (!is_mandatory)
> +		return dccp_push_empty_confirm(fn, feat, local);
> +
> +not_valid_or_not_known:
> +	return is_mandatory ? DCCP_RESET_CODE_MANDATORY_ERROR
> +			    : DCCP_RESET_CODE_OPTION_ERROR;
> +}
> +
> +/**
> + * dccp_feat_parse_options  -  Process Feature-Negotiation Options
> + * @sk: for general use and used by the client during connection setup
> + * @dreq: used by the server during connection setup
> + * @mandatory: whether @opt was preceded by a Mandatory option
> + * @opt: %DCCPO_CHANGE_L | %DCCPO_CHANGE_R | %DCCPO_CONFIRM_L | %DCCPO_CONFIRM_R
> + * @feat: one of %dccp_feature_numbers
> + * @val: value contents of @opt
> + * @len: length of @val in bytes
> + * Returns 0 on success, a Reset code for ending the connection otherwise.
> + */
> +int dccp_feat_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
> +			    u8 mandatory, u8 opt, u8 feat, u8 *val, u8 len)
> +{
> +	struct dccp_sock *dp = dccp_sk(sk);
> +	struct list_head *fn = dreq ? &dreq->dreq_featneg : &dp->dccps_featneg;
> +	bool server = false;
> +
> +	switch (sk->sk_state) {
> +	/*
> +	 *	Negotiation during connection setup
> +	 */
> +	case DCCP_LISTEN:
> +		server = true;			/* fall through */
> +	case DCCP_REQUESTING:
> +		switch (opt) {
> +		case DCCPO_CHANGE_L:
> +		case DCCPO_CHANGE_R:
> +			return dccp_feat_change_recv(fn, mandatory, opt, feat,
> +						     val, len, server);
> +		}
> +	}
> +	return 0;	/* ignore FN options in all other states */
> +}
> +
>  int dccp_feat_init(struct sock *sk)
>  {
>  	struct dccp_sock *dp = dccp_sk(sk);
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>   

