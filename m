From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 14 May 2008 08:09:42 +0000
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Message-Id: <20080514080942.GB4462@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|=20
| R=E9mi Denis-Courmont wrote:
| > In any case, getaddrinfo() should be patched to
| > [...]
|=20
| What should be the behavior is socktype and protocol are zero?  Should
| these two types be returned by default?  What others?  So far we return
| TCP, UDP, and raw socket information.  I'd rather keep the list short
| but since we already have raw sockets in there (because they are in
| POSIX) I won't reject anything that's more useful than raw sockets.
|=20
| - --
RFC 3493 says that 0 for socktype/protocol means that caller will accept
any socket type / protocol, so presumably this does include DCCP and UDP-Li=
te.

It would be just _great_ if getaddrinfo() could support Remi's cases for DC=
CP
(RFC 4340) and UDP-Lite (RFC 3828). So far it is only possible to get an
address by "cheating", i.e. pretending to getaddrinfo to be TCP or UDP. This
does not really work well and still causes lots of problems/broken applicat=
ions.

Gerrit
