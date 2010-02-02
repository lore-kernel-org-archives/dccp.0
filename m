From: gerrit@erg.abdn.ac.uk
Date: Tue, 02 Feb 2010 15:06:15 +0000
Subject: Re: [PATCH 02/86] dccp: revert buggy auto-loading of dccp module
Message-Id: <53767.148.187.160.35.1265123175.squirrel@148.187.160.35>
List-Id: <dccp.vger.kernel.org>
References: <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1265005087-5549-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> --- a/net/dccp/probe.c
> +++ b/net/dccp/probe.c
> @@ -161,7 +161,8 @@ static __init int dccpprobe_init(void)
>  	if (!proc_net_fops_create(&init_net, procname, S_IRUSR,
> &dccpprobe_fops))
>  		goto err0;
>
> -	ret = try_then_request_module((register_jprobe(&dccp_send_probe) = 0),
> +	try_then_request_module(
> +		((ret = register_jprobe(&dccp_send_probe)) = 0),
>  					"dccp");
>  	if (ret)
>  		goto err1;

Apologies for the late response -- delays are sometimes possible due to
day job. The only problem that I had with this patch was that it was
apparently not tested, causing the described problems.


> I've not tested it, but this should do it,
> without re-breaking the silent dependency.

I will test it and get back to you until tomorrow morning (GMT),
if it works I'll also push it out in the test tree.

Thanks a lot for getting back and devising a different route.


