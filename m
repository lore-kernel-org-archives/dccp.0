From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 10 Sep 2008 05:01:15 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080910050115.GA3642@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > Please consider pulling from
| > 
| > 	git://eden-feed.erg.abdn.ac.uk/net-next-2.6	 [subtree `master']
| > 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=net-next-2.6.git;a=summary
| > 
| > where I have reverted the pull and compile-tested the result. 
| 
| I hate to have a turd like this in the history, but fine I pulled this :-/
| 
| I may have to rebase net-next-2.6 after all, this is revoltingly ugly...
| 
| This is exactly what I didn't want Gerrit, a royally screwed up GIT
| history because of the mistake.  It's WORSE now with the revert.
| Can't you see that?  That's why I asked for fixup changesets, rather
| than a revert.
| 
| I would have rather you sent me a small set of fixup patches that
| cured whatever problems were in those changes.  That would have shown
| the development history.
| 
| Now we're just going to have crap.  A large set of changes going in, then
| one huge revert, and nobody will ever get to see exactly what happened
| in between.
| 
| I've had enough.
| 
| I'd like to get the DCCP changes through someone else, please.
| Someone willing to learn to use GIT properly.  Someone who understands
| how important it is to keep the GIT history clean and not put a lot of
| noise into the tree.  Someone who has the time to do this right and I
| can trust.
| 
I had hoped that you would regain your senses but it does not seem so.

Not only are you lacking the courage to admit that it was your own fault
to pull a tree no one had asked you to pull, now you are trying to make 
me look foolish to cover your own mistake. 

Remember, it was you who asked for another review period, neither I nor
Arnaldo, nor anyone else had asked you to pull again.

It further did not even occur to you to check the provided gitweb link, nor
did you recognise that you had pulled about 100 instead of 37 patches. And
you seem not to have looked at the diffstats either - what has a change in
tcp_input.c got to do with a DCCP-only patch set?

Not to mention the conflicts which you silently fixed instead of looking at
their cause.

You don't check the results of your own work and now you are trying to 
lecture others about maintainership? Look at yourself.

And to top this up now you are even asking me for "fixup patches" to fix the
about 60 patches that were accidentally sucked in, only a day after giving
us a lecture on the importance of review. What you are asking for here is to
wave through 60 patches without giving people a chance at all to review them.

I am not going to send patches to fix/cover this up. Either we want people to
review patches fairly or we don't.

What you are saying here has little authority. It is just foolish vanity.
I am really sorry for you and hope that you come back to your senses soon.
