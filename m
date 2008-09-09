From: David Miller <davem@davemloft.net>
Date: Tue, 09 Sep 2008 12:15:46 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080909.051546.193801654.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 9 Sep 2008 13:59:48 +0200

> Let's keep this clean and simple. There has been a mistake here and it
> needs to be fixed. It does not help to argue loudly whose fault it was.
> 
> Please consider pulling from
> 
> 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	 [subtree `master']
> 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git;a=summary
> 
> where I have reverted the pull and compile-tested the result. 

I hate to have a turd like this in the history, but fine I pulled this :-/

I may have to rebase net-next-2.6 after all, this is revoltingly ugly...

This is exactly what I didn't want Gerrit, a royally screwed up GIT
history because of the mistake.  It's WORSE now with the revert.
Can't you see that?  That's why I asked for fixup changesets, rather
than a revert.

I would have rather you sent me a small set of fixup patches that
cured whatever problems were in those changes.  That would have shown
the development history.

Now we're just going to have crap.  A large set of changes going in, then
one huge revert, and nobody will ever get to see exactly what happened
in between.

I've had enough.

I'd like to get the DCCP changes through someone else, please.
Someone willing to learn to use GIT properly.  Someone who understands
how important it is to keep the GIT history clean and not put a lot of
noise into the tree.  Someone who has the time to do this right and I
can trust.
