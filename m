From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Date: Tue, 13 May 2008 17:37:38 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <200805132037.39580.rdenis@simphalempin.com>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Le Tuesday 13 May 2008 20:03:25 Gerrit Renker, vous avez =E9crit=A0:
> Using work-arounds is brittle and frustrating when the API behaviour
> suddenly changes. My experience of using such a wrapper was:
>
>  * it passed UDP(-Lite), TCP through without changing the socket type;
>  * when passed DCCP, it set the socket type to 0, to avoid `ai_socktype
>    not supported' getaddrinfo error;

>  * this used to work fine until about January, when something in the
>    lookup machinery for dual-stack hosts changed:
>    - before, AF_UNSPEC + ai_socktype=3D0 put IPv6 first into the result l=
ist,
>    - now the the result order is reversed (IPv4 sockets are returned firs=
t)

You're probably using a recent libc that applies RFC3484 _properly_. If you=
=20
still want IPv6 first, no matter what addresses the host has, I think the=20
AI_PASSIVE flag should do the trick. Then again, working around RFC3484=20
policy is _not_ a good idea.

As far as I am concerned, for DCCP, I (meaning VLC) currently use SOCK_STRE=
AM,=20
and overrides the socktype and protocol fields in the socket() call=20
manually - so I don't get a TCP socjet.

In any case, getaddrinfo() should be patched to
1/ accept ai_socktype =3D SOCK_DCCP and ai_protocol =3D IPPROTO_DCCP,
2/ accept ai_socktype =3D SOCK_DCCP and ai_protocol =3D 0,
   and set ai_protocol to IPPROTO_DCCP in the results,
3/ (perhaps?) accept ai_protocol =3D IPPROTO_DCCP and ai_socktype =3D 0,
   and set ai_socktype to SOCK_DCCP in the results.

Similarly:
1/ accept ai_socktype =3D SOCK_DGRAM and ai_protocol =3D IPPROTO_UDPLITE,
2/ (intentionally omitted - keep normal UDP non-Lite behavior)
3/ (perhaps?) accept ai_protocol =3D IPPROTO_UDPLITE and ai_socktype =3D 0,
   and set ai_socktype to SOCK_DGRAM in the results.

Voil=E0. Best to check this with Ulrich Drepper, no?

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
