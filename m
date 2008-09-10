From: David Miller <davem@davemloft.net>
Date: Wed, 10 Sep 2008 05:19:14 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080909.221914.193697907.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Sep 2008 07:01:15 +0200

> Not only are you lacking the courage to admit that it was your own fault
> to pull a tree no one had asked you to pull, now you are trying to make 
> me look foolish to cover your own mistake. 

Your subject line said, and it's still being used in this thread:
"net-next-2.6 [pull-request]"

What the heck should I take that to mean exactly?

> It further did not even occur to you to check the provided gitweb link, nor
> did you recognise that you had pulled about 100 instead of 37 patches. And
> you seem not to have looked at the diffstats either - what has a change in
> tcp_input.c got to do with a DCCP-only patch set?
>
> Not to mention the conflicts which you silently fixed instead of looking at
> their cause.

I did look at the merge conflicts I fixed up, code moved from one place
to another or got handled by new helper routines which were being
called, so I picked the appropriate hunk and validated the build.

If I wasn't all that sure of the result I would have replied to you
instead saying "this tree is messed up, I'm not pulling"  And I do
that all the time.

The shorter answer is I did my best and I TRUSTED YOU to only point
a GIT URL my way that was explicitly ready.  Else, you'd say "don't
pull this" rather than have "net-next-2.6 pull request" in the subject
line.

> What you are saying here has little authority. It is just foolish vanity.

Gerrit, it's over.  The only one in vain is you.
