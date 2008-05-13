From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 13 May 2008 17:34:54 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080513173454.GH15306@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Em Tue, May 13, 2008 at 08:06:34PM +0300, R=E9mi Denis-Courmont escreveu:
> Le Tuesday 13 May 2008 19:59:35 David Stevens, vous avez =E9crit=A0:
> >         Well, SOCK_STREAM/IPPROTO_DCCP then. :-) But it isn't really th=
at
> > either, as Remi said.
> >         If you do a connect() on a UDP socket, it doesn't cease to
> > be a SOCK_DGRAM socket, so I don't really care about that distinction,
> > but if others do, that's ok with me. There are ACKs here, too, so maybe.
>=20
> But connect() is a _non-blocking_ operation which merely sets the _defaul=
t_=20
> destination (you can still sendto() someone else).
>=20
> Using socket types blindly may also break applications using=20
> getsockopt(SO_TYPE), if they exists (I think I wrote one once...) to=20
> determine how to use a socket.
>=20
> SOCK_DCCP was perhaps a bad idea, but SOCK_DGRAM seems worse. In the end,=
 it's=20
> more a matter of patching libc getaddrinfo than changing the kernel API=20
> anyway. Did AIX not have a similar socket type as DCCP under a more gener=
ic=20
> name by the way?

/me feels Deja Vu :-)

Lemme dig the URL for the discussion where SOCK_DCCP was discussed and
AIX was summoned, etc :-)

- Arnaldo
