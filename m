From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Sep 2008 04:27:09 +0000
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change
Message-Id: <20080903042709.GB4105@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> +/**
>> + * dccp_feat_change_recv  -  Process incoming ChangeL/R options
>> + * @fn: feature-negotiation list to update
>> + * @is_mandatory: whether the Change was preceded by a Mandatory option
>> + * @opt: %DCCPO_CHANGE_L or %DCCPO_CHANGE_R
>> + * @feat: one of %dccp_feature_numbers
>> + * @val: NN value or SP value/preference list
>> + * @len: length of @val in bytes
>> + * @server: whether this node is the server (1) or the client (0)
>> + */
>> +static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
>> +				u8 feat, u8 *val, u8 len, const bool server)
>> +{
>> +	u8 defval, type = dccp_feat_type(feat);
>> +	const bool local = (opt = DCCPO_CHANGE_R);
>> +	struct dccp_feat_entry *entry;
>> +	dccp_feat_val fval;
>> +
>> +	if (len = 0 || type = FEAT_UNKNOWN)		/* 6.1 and 6.6.8 */
>> +		goto unknown_feature_or_value;
>> +
>> +	/*
>> +	 *	Negotiation of NN features: Change R is invalid, so there is no
>> +	 *	simultaneous negotiation; hence we do not consult the list.
>> +	 */
>> +	if (type = FEAT_NN) {
>> +		if (local)
>> +			goto not_valid_or_not_known;
>>   
> ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>
>  Here should be "goto unknown_feature_or_value"?
>
> Change R is invalid, and RFC4340 6.6.8
>
> An endpoint receiving an invalid Change option MUST respond with the
> corresponding empty Confirm option.
>
> Is this right?
I am not sure.
Section 6.3.2 says that Change R options must not be sent for NN options. A
Change R is different from an invalid value - it is an option which is out
of place in such a context. A sender using such an option for NN features
has a clear bug.

Hence my interpretation of this situation was to flag this bug to the peer:
 * the peer gets sent an Option Error rather than an empty Confirm,
 * if it was a Mandatory option, both interpretations are equivalent.

But there is also the robustness principle (3.6), so thank you, I will
change it to the `unknown_feature_or_value'.


>> +
>> +	/*
>> +	 *	Unidirectional/simultaneous negotiation of SP features (6.3.1)
>> +	 */
>> +	entry = dccp_feat_list_lookup(fn, feat, local);
>> +	if (entry = NULL) {
>> +		if (!dccp_feat_sp_list_ok(feat, val, len))
>> +			goto unknown_feature_or_value;
>>   
>
> Check for sp feat list should before code "entry =  
> dccp_feat_list_lookup(fn, feat, local);",
> here only check for features not register by local endpoint, if the  
> feature is registed, the validity check is missing?
>
No, in this case the validity check is performed already as part of the socket
registration routines - which in turn end up calling dccp_feat_sp_list_ok.  
If a user tries to register invalid SP values on the socket, the attempt
will fail with EINVAL. If the user does not register values, the feature
defaults (6.4) are used, which are valid by definition.
The host is conservative in what it allows to send out.
