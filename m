From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 08 Jan 2007 09:29:47 +0000
Subject: Re: [PATCH-UPDATE]: 3f_CCID3_refactor_loss_interval_code_McDonald.diff
Message-Id: <200701080929.47990@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701051455.16936@strip-the-willow>
In-Reply-To: <200701051455.16936@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  On 1/6/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
|  > I would like to retract the change in the interface of update_li which we discussed recently.
|  >
|  > The reason is that the caller supplies `loss' parameters (a loss sequence number and a loss
|  > CCVal); the fact that in the current implementation this coincides with the fields
|  >
|  >        hccrx->ccid3hcrx_seqno_nonloss and
|  >        hcrx->ccid3hcrx_ccval_nonloss
|  >
|  > in ccid3_hc_rx_detect_loss is more of a coincidence.
|  
|  I disagree with you on this. It's not a coincidence at all. I planned
|  the code that way. It "happens" to have the right values because I put
|  them there.
|  
|  > I have been going over this code several
|  > times and come to the conclusion that not changing the interface of update_li is the cleanest
|  > way. I have uploaded this to the online directory, below are the differences to Ian's original.
|  >
|  >
|  I disagree with this. However I can see some confusion because we are
|  equating nonloss and loss variables and the variables are named badly
|  in the loss interval code. What I've done is stuck with my original
|  patch but changed the variable names seq_loss and win_loss to
|  seq_nonloss and win_nonloss respectively.
|  
|  I've posted the new version online. Can you now use this one please?
You are right - the way it is used corresponds to the highest sequence number received before the loss.
Therefore of course it is nonloss what we are storing. Thanks for the explanation, I have downloaded
your patch, refreshed it with regard to offset etc, acked, and uploaded again as 3f.

Thanks
Gerrit
