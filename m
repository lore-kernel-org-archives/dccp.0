From: =?utf-8?q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Date: Wed, 14 May 2008 17:49:18 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <200805142049.19466.rdenis@simphalempin.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
To: dccp@vger.kernel.org

Le Wednesday 14 May 2008 20:39:40 Sridhar Samudrala, vous avez écrit :
> On Wed, 2008-05-14 at 09:06 -0700, Ulrich Drepper wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >
> > Gerrit Renker wrote:
> > > ... but it would still be good to have.
> > > [...]
> >
> > Thanks, but I think I got this already from previous mails.
>
> SCTP is another protocol that needs to be supported in getaddrinfo().
> The minimum support that is good to have is to handle the following
> values of ai_socktype and ai_protocol.
>   SOCK_STREAM, IPPROTO_SCTP
>   SOCK_SEQPACKET, IPPROTO_SCTP

Yeah but I don't think ai_socktype = SOCK_STREAM and ai_protocol = 0 should 
return IPPROTO_SCTP. Me fears this will break to many TCP applications in the 
field.

-- 
Rémi Denis-Courmont
http://www.remlab.net/
