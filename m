From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Thu, 18 Dec 2008 14:01:11 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081218140111.GF21653@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Thu, Dec 18, 2008 at 06:46:31AM +0100, Gerrit Renker escreveu:
> [Sorry for being late in replying, this is the answer from yesterday]
> 
> I think that if we look too much into the direction of TCP we
> might miss some of the notable differences.

The look at TCP code was more in the sense that TCP doesn't takes the
lock always, having the default congestion control module builtin and
always "advertised"/used, but allows changing it in a slow path
function.

With the new patch this is what we have now in DCCP too.
 
> In TCP the congestion module stays the same for the lifetime of a
> connection and there is no real negotiation. If the TCP congestion
> control module is a sender-side only modification then that even
> works transparently for any unmodified standard TCP client.
> 
> In DCCP the negotiation is more like SIP where both endpoints compare
> their capabilities and make a hanshake to vote for a common value.
> 
> (Although it is not supported by the current implementation, it
>  is in theory possible to re-negotiate a CCID in the middle of
>  a connection.  This could for example make sense when
>   * a satellite connection suddenly changes, e.g. reduced
>     bandwidth due to rain fading;
>   * a mobile IP device makes a handoff from Ethernet to WiFi.)

And that, at least for CCID2 and CCID3 now can be done wihtout having to
first check if they are loaded, taking locks, etc, that was the crux of
this discussion.

> Before a connection, a user can specify/select candidates:
> 
>  * he can advertise simply just "everything that is there";
>  * the other extreme is to use just a single CCID (where 
>    connection might fail due to lack of alternatives).		 
> 
> Only the CCIDs requested currently by the users on a system need
> to be loaded, but it would make life much simpler if the configured
> modules were already loaded.
> 
> With regard to "experimental versus standardised" CCIDs, it takes 
> actually quite long before a RFC becomes sufficiently standardised.
> 
> For the experimental CCIDs I think that David's suggestion is  preferable:
> 
>  * for the sake of development we can create a special way of integrating
>    whatever kind of new CCID we are testing;
>  * instead of complicating the mainline mechanism by implementing answers
>    for all (including pathological) possible cases.

I believe that the RFCv2 patch I submitted accomplishes these two goals
with a minimal patch to the current code.

And if we look higher up in the stack, say at sock_create we can see
that we have this module loading verification all over again done at
socket creation time for all families, but there it uses RCU, etc, but
it used to be something familiar replaced by Stephen Hemminger in this
cset:

http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;hU737fda0bc73cb20f702301d8b52938a5a43630

Looks familiar? Yes, thats is where the ccid locking scheme came from.
 
> Thinking ahead, if in a few years there is suddenly an abundant choice of
> practically useful/useable CCIDs then it may make sense to divide CCIDs
> into separate modules again, after conquering their implementation.
> 
> 
> >From both of your answers I see consensus that at least the standardised
> CCIDs should be integrated with dccp.ko. And there is already Arnaldo's
> patch to realise this, which is great.
> 
> Will integrate Arnaldo's patch with the test tree and the current patch
> set. Will be back once this is accomplished.

Thanks a lot,

- Arnaldo

