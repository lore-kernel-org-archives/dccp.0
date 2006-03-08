From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Wed, 08 Mar 2006 16:19:48 +0000
Subject: Re: Report: feat negot state
Message-Id: <39e6f6c70603080819x46328de1td7b88055a0007417@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
In-Reply-To: <39e6f6c70603061905i1db54071m6cc2776edd3828bb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 3/8/06, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> Hi guys!

Hi Eddie!

> > * The server must remember which CONFIRMs it sent.  [In fact, the previous code
> >   was bugged because of this I think---it would remember the features of ALL
> >   clients in a single socket... anyway.]
> >
> >   This means that the server must not trash memory, it has to hold some state,
> >   and potentially even setup those options.  E.g. it might have to load a CCID,
> >   etc etc.
>
> The Init Cookie option lets the server package up all that state, send it to
> the client, and forget it.  The server might still have to load a CCID, but
> that doesn't worry me -- we only have 3 CCIDs.

Sure, Init Cookie will be eventually implemented, but I want to
support everything
that is specified in the draft, and furthermore, reworking the core Linux INET
infrastructure to have TCP and DCCP sharing _everything_ that is not specific to
one of them, that has been my goal since day one, if I decided just to implement
Init Cookies I would have a much easier ride, but I'm stubborn on supporting all
the things specified in the draft to the best of my capacity use this
implementation
to fully validate the draft in the Real World(tm), even if takes more time 8)

If one looks at work Eric Dumazet, Ben LaHaise and others are doing on improving
TCP that _already_ are helping DCCP due to all this code sharing, its
wonderful, I
really, really didn't wanted to go the SCTP way where few things is shared with
other INET connection oriented protocols (well, at the time there was
only TCP :P).

> > * The server must actually calculate the CONFIRMS.  With server priority, the
> >   calculation works as follows:  Given preference list C and S of the client and
> >   server respectively, the winning value is the first value which appears in S
> >   and also in C.
> >
> >   Basically:
> >
> >   for each s in S
> >     for each c in C
> >       if (s = c)
> >         w00t();
>
> It's not that bad.  (1) All feature negotiation options are limited to 252
> bytes of feature value at most.  (2) All current SP features are one-byte
> valued.  So you can do this.
>
>      uint32_t bitmap[8] = { 0, 0, 0, 0, 0, 0, 0, 0 }; // 256 bits
>      for each c in C
>        turn on corresponding bit in bitmap;
>      for each s in S
>        if corresponding bit in bitmap is true
>          w00t();
>
> O(n^2) -> O(n).
>
> For multi-byte SP features (if they ever exist), this trick doesn't work, but
> the DOS is less serious, since the maximum preference list length is 1/2 (1/3,
> 1/4...) as long.

Interesting idea, will get back to this after getting what we have now
working as
a first step.

- Arnaldo
