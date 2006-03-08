From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Wed, 08 Mar 2006 16:39:11 +0000
Subject: Re: Report: feat negot state
Message-Id: <39e6f6c70603080839t7d98f573u764a01d635ffd5e8@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
In-Reply-To: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/8/06, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> Hi Arnaldo,
>
> Arnaldo Carvalho de Melo wrote:
> >>The Init Cookie option lets the server package up all that state, send it to
> >>the client, and forget it.  The server might still have to load a CCID, but
> >>that doesn't worry me -- we only have 3 CCIDs.
> >
> >
> > Sure, Init Cookie will be eventually implemented, but I want to
> > support everything
> > that is specified in the draft, and furthermore, reworking the core Linux INET
> > infrastructure to have TCP and DCCP sharing _everything_ that is not specific to
> > one of them, that has been my goal since day one, if I decided just to implement
> > Init Cookies I would have a much easier ride, but I'm stubborn on supporting all
> > the things specified in the draft to the best of my capacity use this
> > implementation
> > to fully validate the draft in the Real World(tm), even if takes more time 8)
> >
> > If one looks at work Eric Dumazet, Ben LaHaise and others are doing on improving
> > TCP that _already_ are helping DCCP due to all this code sharing, its
> > wonderful, I
> > really, really didn't wanted to go the SCTP way where few things is shared with
> > other INET connection oriented protocols (well, at the time there was
> > only TCP :P).
>
> This is a great approach!  But TCP implements syn cookies, which is very
> similar to the Init Cookie.  So Init Cookies are not totally DCCP-only.  I'm
> just saying the DOS need not be such a big deal.

Sure, my idea is to abstract TCP syncookies/DCCP Init Cookies at the
struct inet_request_sock level, then both will have the same code flow :-)

So stay tuned as after we get the feature negotiation mostly working I'll attack
this new syncookies/init cookie abstraction.

Ah, another thing in the backburner is to support DCCPv6 only, i.e. right now we
have dccp_ipv4 and dccp_ipv6 modules, but dccp_ipv6 still requires dccp_ipv4
due to v6 mapped v4 addresses, that is not selectable, but I'll rework this code
at the inet_connection_sock level to make it possible to have a IPv6 only setup,
paving the way for IPv4 retirement as I promised to DaveM 8-) :-P

- Arnaldo
