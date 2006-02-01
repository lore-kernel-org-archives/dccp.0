From: John Heffner <jheffner@psc.edu>
Date: Wed, 01 Feb 2006 21:40:02 +0000
Subject: Re: [RFC] TCP MTU probing
Message-Id: <200602011640.02318.jheffner@psc.edu>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Monday 30 January 2006 20:21, Ian McDonald wrote:
> On 1/31/06, David S. Miller <davem@davemloft.net> wrote:
> > From: John Heffner <jheffner@psc.edu>
> > Date: Tue, 06 Dec 2005 14:42:53 -0500
> >
> > > I'd like to get a few people at least to look this over, and maybe give
> > > it a try.  One remaining item to consider is how best to cache the
> > > state between connections.  Are there any major concerns or
> > > reservations about this approach, or the patch itself?
>
> Just having a read of this now (missed first time round) and I see
> that PMTUD as per this RFC is also allowed by DCCP in it's spec
> (Section 14.1).
>
> > and then I'll happily at this in for net-2.6.17
>
> At some future stage we should merge this into the DCCP tree too.
> Looking at the code there are quite a few places where it has TCP in
> there where maybe it would be better to have IP in there to save
> further changes when DCCP starts to use the code....

That would be good.  I think SCTP should do this as well.  I moved struct mtup 
from struct tcp_sock to struct inet_connection_sock.  I think most of the 
actual code really ends up being pretty protocol-specific though.

  -John
