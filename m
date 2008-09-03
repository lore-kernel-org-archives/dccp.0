From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Sep 2008 08:24:09 +0000
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change
Message-Id: <20080903082409.GB9001@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080823105647.GA15928@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >> +static u8 dccp_feat_change_recv(struct list_head *fn, u8 is_mandatory, u8 opt,
| >> +				u8 feat, u8 *val, u8 len, const bool server)
<snip>
| >> +	if (type = FEAT_NN) {
| >> +		if (local)
| >> +			goto not_valid_or_not_known;
| >>   
| > ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
| >
| >  Here should be "goto unknown_feature_or_value"?
| >
| > Change R is invalid, and RFC4340 6.6.8
| >
| > An endpoint receiving an invalid Change option MUST respond with the
| > corresponding empty Confirm option.
| >
| > Is this right?
| I am not sure.
| Section 6.3.2 says that Change R options must not be sent for NN options. A
| Change R is different from an invalid value - it is an option which is out
| of place in such a context. A sender using such an option for NN features
| has a clear bug.
| 
| Hence my interpretation of this situation was to flag this bug to the peer:
|  * the peer gets sent an Option Error rather than an empty Confirm,
|  * if it was a Mandatory option, both interpretations are equivalent.
| 
| But there is also the robustness principle (3.6), so thank you, I will
| change it to the `unknown_feature_or_value'.
| 
I have serious doubts whether the above is the right thing. Jumping to
unknown_feature_or_value means the following

unknown_feature_or_value:
        if (!is_mandatory)
		return dccp_push_empty_confirm(fn, feat, local);

not_valid_or_not_known:
        return is_mandatory ? DCCP_RESET_CODE_MANDATORY_ERROR
	                    : DCCP_RESET_CODE_OPTION_ERROR;

=> Hence the host is asked to send an invalid option type, a Confirm L,
    in response to the invalid Change R.
    A Confirm L in the context of negotiating NN features is never a valid
    option, so this jump is paradox. I think this was the reason why it
    was originally a Reset. 

    Are there any objections reverting this to the original state, i.e.
    sending a Reset instead of a Confirm L for an out-of-place Change R?

Gerrit
