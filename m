From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 05 Jan 2007 14:47:37 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <200701051447.38069@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Ian,

sorry for the misunderstandings. I do think that you raise important issues. However, the problem
I had with the patch is that it is actually _two_ patches:

	(1) One is fix to make the loss interval calculation compatible with RFC 3448, section 5.4
            Here I couldn't agree with you more and this is a priority issue. However, as I sat down
            and went through your patch, I noted that there are other problems, too. I will post a
            write-up of what I found. Now I see that Eddie has also confirmed that there are problems
            with this code, so we should follow this up.

	(2) The other is a novel method of recalculating the loss rate when, after some first loss,
            there has been a longer period of non-loss (did I get this right?). This is not tackled
            by an RFC so far, hence is experimental.

The fact that there are two patches in one made it difficult to reply and caused the misunderstandings.
It would have been easier to follow if the patch had been split into two; sorry I was not able to follow
the format as it was. 

Now, for (1) we have a bona-fide bug fix and this should be given priority over other issues. With regard
to (2), I say the following: if you can prove or show that using the technique which is embedded into your
algorithm leads to performance improvements in cases such as the following:

|  Probably the easiest way to illustrate this is:
|  - Fixed 128 kbits second link.
|  - Loss occurs when we are only up to 32 kbits per second
|  - No loss then occurs again or for a very long time
|  - How do we then use the full bandwidth?

then you have tackled an original problem - too precious to just code away as a patch. As far as I know,
this problem has _not been tackled_ neither by any RFC (the closest I can find is RFC 4342, 5.1) nor an Internet
Draft. Ergo, you would have the material for writing an Internet draft which, if the technique indeed helps
performance, would be a valuable contribution to the CCID 3 infrastructure.
 
|  This is what I think the RFC is saying.
See above :-)



|  >  3) I have a suggestion: you seem to be sure of the merits of this solution and report on
|  >     test results. My suggestion would be to offer using this method via a configuration
|  >     option (same as per the nofeedback timer threshold). You could put detailed advice into
|  >     the kernel configuration menu, and we would have the best of both worlds - a standards-
|  >     compliant TFRC implementation and a configurable Ian's nifty solution. Would that settle
|  >     things?
|  >
|  I'll wait to see the feedback from others first before heading down
|  that path. Maybe I can even convince you yet! But if we can't resolve
|  that would be good.
I can reformulate this now with regard to (2): the technique is novel and so far not documented
in any RFC/Internet Draft. It would be a valuable addition, but for testing it would be better to have
it as a configuration option so that people can play with it and note the differences between using it
and not using it. Given that most of it is already in the dccp_li_hist_recalcloss function, it does
not seem too hard to encapsulate the algorithm into its own separate function. 

Given that you are busy at the moment and that I am bogged down with trying to sort out TX/RX history
locking issues, can we put this on top of the todo list? With regard to the bug fix, I will summarize
in separate posting.

Gerrit
