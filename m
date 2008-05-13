From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 13 May 2008 16:59:35 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <OF8AA2B2D0.51E14DBC-ON88257448.005BC2A0-88257448.005D57D0@us.ibm.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Arnaldo Carvalho de Melo <acme@redhat.com> wrote on 05/13/2008 09:23:25 
AM:

> Em Tue, May 13, 2008 at 08:50:59AM -0700, David Stevens escreveu:
> > Are they mutually exclusive?
> > 
> > Why not add SOCK_DGRAM/IPPROTO_DCCP support while leaving
> 
> Because DCCP is not SOCK_DGRAM at all? :)

        Well, SOCK_STREAM/IPPROTO_DCCP then. :-) But it isn't really that
either, as Remi said.
        If you do a connect() on a UDP socket, it doesn't cease to
be a SOCK_DGRAM socket, so I don't really care about that distinction,
but if others do, that's ok with me. There are ACKs here, too, so maybe.
        My point was really that, though not as pretty, the world won't
end if there are two ways to get to the same kind of socket, and
especially if adding a new one makes getaddrinfo() easier to deal with.
If the best way isn't the existing way, we could add it, and keep the
old way for backward compatibility only.
        A "0" protocol had better continue to be TCP and UDP, and
specifying IPPROTO_DCCP makes it clear what the user wants, regardless
of the type. So "just working" (even with any of SOCK_DGRAM, SOCK_STREAM,
and SOCK_DCCP) seems perfectly reasonable to me. My $.02.
        A wrapper sound ok to me too.

                                                                +-DLS

