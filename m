From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Wed, 08 Mar 2006 19:01:50 +0000
Subject: Re: Report: feat negot state
Message-Id: <20060308190150.GA1388@tribal.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
In-Reply-To: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Mar 08, 2006 at 08:08:53AM -0800, Eddie Kohler wrote:
> >Basically, because i coded server priority features first, and then
> >non-negotiable.  With NN features, you need to send confirms even for 
> >stuff you
> >don't know about [or something like that] so i didn't know where to shove 
> >the
> >confirm =D
> 
> I don't quite understand this.  If you don't know about the feature, then 
> how can you tell whether it is NN?

OK the issue was this.  With SP, you have a preference list, so whenever you
confirm X, you can shove the confirm in the preference list data structure for
X.

For NN, it might be possible to not have a preference for X. [?]  e.g. say you
get CHANGE_L ACK_RATIO, maybe you don't even care about ACK_RATIO yourself, so
you might not have a feature structure list for your own ack ratio, where you
could put the confirm.

This is what happens when coding without thinking / designing.  But hey, time =D

> >2) I'll try to re-write the multi-byte feature support patch.  I believe 
> >this is
> >   important functionality which is missing.
> 
> For NN features, yes.

yea, in fact i initially wrote the patch solely for ack ratios.  I wanted to see
how CCID2 would behave when ack ratios really did change =D

> The Init Cookie option lets the server package up all that state, send it 
> to the client, and forget it.  The server might still have to load a CCID, 
> but that doesn't worry me -- we only have 3 CCIDs.

I remember seeing the init cookie in the spec.  I just re-read it, yes it solves
the problem.  I didn't know it was so versatile [that you can encode ~200 bytes
of data.]  I thought it was just a 32bit number or something.

> It's not that bad.  (1) All feature negotiation options are limited to 252 
> bytes of feature value at most.  (2) All current SP features are one-byte 
> valued.  So you can do this.

yea, but I was thinking if you chain many change X in the same packet.  I'm not
sure that's legal.  But anyway, an implementation may process options from the
tail of the packet to front, and discard any previously seen feature negos for
the same option.

yea, in fact i got "scared" when I wrote the multi-byte patch.  the:
if (c = s)
became a:
if (memcmp(c, s, len) = 0)


anyway, yes, i agree with you that there is no real dos issue.  What got me
thinking about this was mereley "when will my code suck?" [apart from "in the
common case"] =D


As Arnaldo said, the goal is to get this working properly as quickly as
possible.  I don't think we are far.  From what I can see, only two big things
are missing [in feat nego]:
* Timers & Feature negotation.

Both have been written in some patch, it's just a matter of putting the puzzle
together and framing it =D
