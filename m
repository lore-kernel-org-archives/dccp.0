From: Remi Denis-Courmont <rdenis@simphalempin.com>
Date: Tue, 13 May 2008 12:53:59 +0000
Subject: Re: [RFC] [DCCP]: Deprecate =?UTF-8?Q?SOCK=5FDCCP=20in=20favour=20of=20SO?=
Message-Id: <48a00ddc692de4b7b71273614e61ab17@chewa.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org


On Tue, 13 May 2008 08:28:53 +0100, Gerrit Renker <gerrit@erg.abdn.ac.uk>
wrote:
> There is an API and an address resolution problem involved in specifying
a
> separate/distinct socket type `SOCK_DCCP'.
(...)
> Having also seen the work-arounds in programs that other people wrote,
> I believe that the above change will make it in the long term easier for
> people to write DCCP-enabled applications.

DCCP clearly fails the POSIX definition of SOCK_DGRAM in different ways.

I think this is not a good idea.

> It also relieves the libc writers from having to support another socket
> type.

As long as SOCK_DCCP-or-whatever is not automatically selected when
ai_socktype is nul, this should be both easy to implement in libc *and*
backward compatible (applications will not try to use DCCP implicitly).

> A quick look at SCTP shows that they also did not introduce new socket
> types, relying on the existing SOCK_STREAM/SOCK_SEQPACKET ones.

But they follow the semantics for them.

> It might be still early enough to resolve this, before it is widely used
> and can then only be supported via work-arounds.
>=20
> I can't see a disadvantage here and the only work required is to update
> that
> datagram-based not automatically means connection-less.
>=20
> Is there support for this change or are there reasons to keep SOCK_DCCP?

Maybe the name SOCK_DCCP sucks, but I think DCCP needs a "new" socket type
anyway.

--=20
R=C3=A9mi Denis-Courmont
http://www.remlab.net

