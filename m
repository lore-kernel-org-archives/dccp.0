From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 18 Dec 2008 05:46:31 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081218054631.GB6298@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[Sorry for being late in replying, this is the answer from yesterday]

I think that if we look too much into the direction of TCP we
might miss some of the notable differences.

In TCP the congestion module stays the same for the lifetime of a
connection and there is no real negotiation. If the TCP congestion
control module is a sender-side only modification then that even
works transparently for any unmodified standard TCP client.

In DCCP the negotiation is more like SIP where both endpoints compare
their capabilities and make a hanshake to vote for a common value.

(Although it is not supported by the current implementation, it
 is in theory possible to re-negotiate a CCID in the middle of
 a connection.  This could for example make sense when
  * a satellite connection suddenly changes, e.g. reduced
    bandwidth due to rain fading;
  * a mobile IP device makes a handoff from Ethernet to WiFi.)



Before a connection, a user can specify/select candidates:

 * he can advertise simply just "everything that is there";
 * the other extreme is to use just a single CCID (where 
   connection might fail due to lack of alternatives).		 

Only the CCIDs requested currently by the users on a system need
to be loaded, but it would make life much simpler if the configured
modules were already loaded.


With regard to "experimental versus standardised" CCIDs, it takes 
actually quite long before a RFC becomes sufficiently standardised.

For the experimental CCIDs I think that David's suggestion is  preferable:

 * for the sake of development we can create a special way of integrating
   whatever kind of new CCID we are testing;
 * instead of complicating the mainline mechanism by implementing answers
   for all (including pathological) possible cases.

Thinking ahead, if in a few years there is suddenly an abundant choice of
practically useful/useable CCIDs then it may make sense to divide CCIDs
into separate modules again, after conquering their implementation.


From both of your answers I see consensus that at least the standardised
CCIDs should be integrated with dccp.ko. And there is already Arnaldo's
patch to realise this, which is great.

Will integrate Arnaldo's patch with the test tree and the current patch
set. Will be back once this is accomplished.
