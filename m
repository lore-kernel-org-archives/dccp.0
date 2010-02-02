From: Neil Horman <nhorman@tuxdriver.com>
Date: Tue, 02 Feb 2010 15:39:29 +0000
Subject: Re: [PATCH 02/86] dccp: revert buggy auto-loading of dccp module
Message-Id: <20100202153929.GA12697@hmsreliant.think-freely.org>
List-Id: <dccp.vger.kernel.org>
References: <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Tue, Feb 02, 2010 at 03:06:15PM -0000, gerrit@erg.abdn.ac.uk wrote:
> > --- a/net/dccp/probe.c
> > +++ b/net/dccp/probe.c
> > @@ -161,7 +161,8 @@ static __init int dccpprobe_init(void)
> >  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
> > &dccpprobe_fops))
> >  		goto err0;
> >
> > -	ret = try_then_request_module((register_jprobe(&dccp_send_probe) = 0),
> > +	try_then_request_module(
> > +		((ret = register_jprobe(&dccp_send_probe)) = 0),
> >  					"dccp");
> >  	if (ret)
> >  		goto err1;
> 
> Apologies for the late response -- delays are sometimes possible due to
> day job. The only problem that I had with this patch was that it was
> apparently not tested, causing the described problems.
> 
> 
> > I've not tested it, but this should do it,
> > without re-breaking the silent dependency.
> 
> I will test it and get back to you until tomorrow morning (GMT),
> if it works I'll also push it out in the test tree.
> 
> Thanks a lot for getting back and devising a different route.
> 
Thanks, and apologies for being brusque.  I just didn't want to fix what is
clearly a problem in what you describe by rebreaking a previously seen problem.
I expect this should work just fine.  Let me know if it doesn't and I'll
resurrect my test bed here and take a look
Neil

> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
