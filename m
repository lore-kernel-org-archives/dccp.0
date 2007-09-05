From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 05 Sep 2007 09:02:48 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <200709051002.48674@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|  > When there is little or no documentation in the code saying which variable or piece of
|  > code belongs where, then each time someone wants to change a bit of code has to reverse-
|  > engineer what actually is going on. This can be very time-consuming. So I was not thinking
|  > in terms of merging (although I am sure that Arnaldo will pick out bad code), but of keeping
|  > the code changeable for a longer period and easier to update.
|  >
|  > Don't get me wrong, I don't mean your code here, it is a general problem which I think we
|  > should pay more attention to. And, as said, my ideas of keeping things separate may not be
|  > the best possible solution, only one that I could think of at the moment.
|  >
|  Aha. I see what you mean now. I think the best thing to do here is to
|  label each block of code introduced, that is specific to a version,
|  with the version of the document used.
That's why I thought a separate branch would be nice - it keeps all documentation and patches together
so that even after some pauses in between one knows where the code came from and what it was good for. 

Will you be updating the code when the `real' Faster Restart comes out? We talked about this before,
the situation is that rev-03 is obsolete and in the progress of being replaced by a different approach, so 
the current incarnation is in a kind of disconnected limbo state. It is useful for testing, and that is
why I am certainly happy to track it in (a branch of) the tree; but it is clear that this Faster Restart
will be obsoleted in some future.

That is why I think a separate branch is better - it allows you, even after months of pause, to continue
with your Faster Restart work exactly where it was left previously.

Let me be clear - I don't want to get in the way of style discussions between you and Arnaldo, but I'd
like to keep the test tree as clearly structured as possible. What I don't know at the moment, and shall
investigate, is whether there are other ways of arranging the subtrees while still keeping different 
approaches separable (my understanding of a `branch').

Again, this is not a Faster Restart issue, but a general problem of moving targets. What I am taking
home from this is to make a mental note of annotating the current code with regard to which rfc3448bis
draft version is used (at least it is documented online in these archives).

There is a similar problem with CCID4, which is apparently an also much-discussed draft, and the TFRC-SP
specification is only an Experimental RFC (not Proposed Standard, like DCCP). I know from my own experience
with getting the code for RFC 3828 (a stable Proposed Standard RFC) merged into the mainline that
even then it took a long time and David Miller was not very sympathetic towards unfinished code: initially
I submitted only the IPv4 variant, but was asked to produce v6 also. I.e. when Faster Restart goes mainline,
I'd expect similar questions.

So, my hope is that if we can resolve this satisfactorily for you and all others involved, we will arrive
at a generic solution of distributed development, as I am quite sure that the problem of moving targets will 
persist in the DCCP world for some time to come.

Gerrit
