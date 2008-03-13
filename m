From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 13 Mar 2008 08:06:43 +0000
Subject: Re: packet priorities
Message-Id: <20080313080643.GA6466@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803071151.55379.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| > So the current dropping policy of the internal TX buffer is "tail drop".
| > By specifying priorities this can be improved to "drop worst packet
| > first".
| > 
| > The question here is, when the interpacket gap value is, say `IPG',
| > and IPG is distributed according to some distribution, is is possible to
| > specify a timeout value `timeout', i.e. setting
| > 	      IPG' = IPG + timeout?
| > 
| > One could set this up such that timeout/IPG < delta, where delta is
| > the maximum error, say 5%?
| > 
| > Does this make sense - are there other/better suggestions?
| 
| Implementing the timeout mechanism in D-ITG should be quite simple. And
| calculating the timeout as a percentage of the IPG is also simple.
| However, I think this approach can slow down a bit the generation
| process. In the sense that, for each packet, a different timeout may be
| specified, which causes calling some set_timeout function very
| frequently for high packet rates. 
| 
| Moreover, from a real application point of view, the usefulness of
| having a timeout that is a percentage of the IPG is not clear to me.
I was just guessing and asking for comments - no doubt there are
smarter solutions than using a percentage of the timeout.

| Roughly speaking, D-ITG extract the IPG from a random number generator,
| waits for that IPG, and then issues a "send" putting the packet into the
| socket buffer. This is to emulate the behavior of the applications (e.g.
| VoIP or WEB clients) which perform "send" function calls according to
| certain models (e.g a constant time for VoIP or a kind of random for
| other applications). Setting the timeout as a percentage of the IPG will
| surely help D-ITG to be more accurate in replicating the application
| behavior, which is good for a traffic generator. However, it could be
| not as good for a real application, e.g. a VoIP client, which should
| prefer to have a fixed timeout for all its packets, regardless of the
| IPG. What do you think ?
| 
Thanks a lot for the input. 

The variable vs. constant time-to-live re-appears also in audio
streaming. It is not a problem, since the application supposedly knows 
what an upper bound of the time-to-live is (e.g. from RTP timestamp).

As far as I know servers use the same principle of waiting the
inter-packet gap time before the send(). In Darwin Streaming Server it
is done in this way, and the IPG times change each time according to
the playout time set in the hint track.

This can be emulated with some random distribution for the inter-packet
gap in D-ITG. I don't know whether there are plans to let D-ITG take
trace files with given inter-packet gaps as input, but this is another
way of testing; as at the moment no meaningful servers exist for DCCP.
