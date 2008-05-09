From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 09 May 2008 15:52:58 +0000
Subject: Re: [PATCH 1/1] [QPOLICY]: cmsg header parsing fixes
Message-Id: <20080509155258.GA32739@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080502202242.74967BC4D@poczta.oswiecenia.net>
In-Reply-To: <20080502202242.74967BC4D@poczta.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > | > | -		default:
| > | > | -			return -EINVAL;
| > | >
<...>
| > By taking them out, you are robbing yourself of the possibility to
| > distinguish between truly invalid arguments ("EINVALs") and
| > incompatibilities.
| >
| But do we need such distinction? If kernel cannot understand part of cmsg data 
| we should just ignore this part. The application will work, maybe slightly 
| less effective than the author intended but it's better than returning error 
| and making it completely useless. This could be called best-effort approach. 
| However, we could return error on unknown or invalid data provided 
| applications can detect which parameters are supported prior to packet 
| submission.
| 
| To summarise I see two options here:
| 1. Provide a way for applications to ask at runtime which DCCP_SCM_xxx options 
| are supported by running kernel. And always return EINVAL on unsupported 
| data.
| 2. Allow ignoring unknown data, it doesn't have to be the default. This could 
| take a form of setsockopt(IGNORE_UNKNOWN_CMSG_DATA) call.
| 
| Both ways the default would be as you propose but applications would be able 
| to work around older kernel version. What do you think about it?
| 
With that explanation I understand clearer where you would like to go. I
don't like (2) since it makes the API more complex (instead of thinking
what to accept, the API then also needs to know what to ignore).

So I'd prefer (1). Like the struct qpolicy_args, this could be something
done later, when there are more qpolicies.

A similar mechanism was used for the CCIDs with ccid_getsockopt_available_ccids(),
which would be one possibility - returning an array of possible policy IDs.  


| > That is the point I missed: it is not necessary to equip all xxx_push()
| > routines with an extra argument, this can be done by the
| > dccp_qpolicy_push() routine.
| >
| Could be, in fact I thought about moving code from dccp_msghdr_parse() to 
| dccp_qpolicy_push(). But on the other hand cmsg data doesn't have to be only 
| about qpolicies. I mean in theory because currently I cannot show a usecase 
| for non-qpolicy specific cmsg data. For me the code could either be as it is 
| or could be moved to dccp_qpolicy_push(). Both options seem to be ok.
| 
Yes, agree - there may well be other uses for cmsg_data.


| > I (...) am questioning whether this is not really over-designed.
| > 
| I wonder if you could rephrase this sentence possibly using a bit simpler 
| English.
| -- 
Here is the sentence again:
> questioning whether this is not really over-designed. So far the
> qpolicy_args is just a wrapper,
> 
> 	struct qpolicy_args {
> 		__u32 priority;
> 	};
> 
What was meant was my own idea of using struct qpolicy_args above,
since at the moment it only has one element.

I don't know what your extension plans are, my suggestion is to wrap up
the patches in the qpolicy subtree, cast them as one patch within the
test tree and continue any additions/further work based on that.

I have been testing this tree for about a week and encountered no
problems (using the default/simple policy mostly).

- Gerrit


The University of Aberdeen is a charity registered in Scotland, No SC013683.

