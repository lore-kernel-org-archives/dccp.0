From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Apr 2007 09:20:14 +0000
Subject: Fwd: Re: [PATCH 27/43]: Accurately determine idle & application-limited periods
Message-Id: <200704111020.14419@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

> [CCID3]: Accurately determine idle & application-limited periods
<snip>
> +/**
> + *  ccid3_hc_tx_idle  -  Whether sender is idle or application-limited
> + *  @now: Current time needs to be supplied
> + *  Returns the number of full RTTs during which the sender has been idle.
> + */
> +static int ccid3_hc_tx_idle(struct ccid3_hc_tx_sock *hctx, struct timeval *now)
> +{
> +       struct timeval last_send;

Maybe this would be better called ccid3_hc_tx_idle_rtt to indicate
what is happening here.

>          */
> -       if (unlikely(hctx->ccid3hctx_idle)) {
> +       if (ccid3_hc_tx_idle(hctx, now) >= 2) {

See what I mean? You're left wondering - what does this code do? It
makes some sense if you check comment above but not totally obvious.

Code seems OK but not yet tested it all.

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>

-- 
Web: http://wand.net.nz/~iam4/
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
