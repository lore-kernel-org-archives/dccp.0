From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 05 Jan 2007 16:00:50 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <459E7632.1030106@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

> Now, for (1) we have a bona-fide bug fix and this should be given priority over other issues. With regard
> to (2), I say the following: if you can prove or show that using the technique which is embedded into your
> algorithm leads to performance improvements in cases such as the following:
> 
> |  Probably the easiest way to illustrate this is:
> |  - Fixed 128 kbits second link.
> |  - Loss occurs when we are only up to 32 kbits per second
> |  - No loss then occurs again or for a very long time
> |  - How do we then use the full bandwidth?
> 
> then you have tackled an original problem - too precious to just code away as a patch. As far as I know,
> this problem has _not been tackled_ neither by any RFC (the closest I can find is RFC 4342, 5.1) nor an Internet
> Draft. Ergo, you would have the material for writing an Internet draft which, if the technique indeed helps
> performance, would be a valuable contribution to the CCID 3 infrastructure.

Um, you misunderstand.  The problem that Ian's patch addresses seems 
entirely within the purview of RFC 3448/4342.  He is not trying to 
innovate.  Recalculating the loss rate after a longer period of non-loss 
is NOT EXPERIMENTAL it is REQUIRED.  The loss event rate is NOT 
calculated ONLY when losses are detected.  It must be calculated on 
every feedback packet.  I don't have time at the moment to look up 
chapter and verse, maybe later.

Ian's implementation strategy is unconventional, it's true, but he is 
attempting to implement RFC-compliant behavior, no more, no less.  He 
might have a bug, but his code is strictly better and more RFC compliant 
than what exists.

I think (for what it's worth) his patch should be accepted as is, and 
maybe he, or someone, will simplify the recalc_recalcloss part later.

Eddie



>  
> |  This is what I think the RFC is saying.
> See above :-)
> 
> 
> 
> |  >  3) I have a suggestion: you seem to be sure of the merits of this solution and report on
> |  >     test results. My suggestion would be to offer using this method via a configuration
> |  >     option (same as per the nofeedback timer threshold). You could put detailed advice into
> |  >     the kernel configuration menu, and we would have the best of both worlds - a standards-
> |  >     compliant TFRC implementation and a configurable Ian's nifty solution. Would that settle
> |  >     things?
> |  >
> |  I'll wait to see the feedback from others first before heading down
> |  that path. Maybe I can even convince you yet! But if we can't resolve
> |  that would be good.
> I can reformulate this now with regard to (2): the technique is novel and so far not documented
> in any RFC/Internet Draft. It would be a valuable addition, but for testing it would be better to have
> it as a configuration option so that people can play with it and note the differences between using it
> and not using it. Given that most of it is already in the dccp_li_hist_recalcloss function, it does
> not seem too hard to encapsulate the algorithm into its own separate function. 
> 
> Given that you are busy at the moment and that I am bogged down with trying to sort out TX/RX history
> locking issues, can we put this on top of the todo list? With regard to the bug fix, I will summarize
> in separate posting.
> 
> Gerrit
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

