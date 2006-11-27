From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 17:13:55 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <200611271713.55431@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Eddie Kohler:
|  Hi Gerrit, Ian,
| =20
|  I am not sure I am completely following this discussion, but there is on=
e=20
|  point I wanted to bring up. =A0DCCP senders DO have an estimate of the=20
|  round-trip time even BEFORE the first feedback packet, namely from the=20
|  Request-Response exchange. =A0RFC 4342 senders and receivers can use the=
 RTT=20
|  measured by the core DCCP protocol. =A0Reading over RFC 4342, this is ex=
tremely=20
|  not clear (sorry), but it was our intention. =A0(Sally, this is right, y=
es?) =A0We=20
|  will put together an erratum for the RFC Editor.
This is an experimental feature and also appears in draft-ietf-dccp-rfc3448=
bis-00.txt,
section 4.2:
    "If the sender does have a round trip sample when it is ready to
     first send data (e.g., from the SYN exchange or from a previous
     connection [RFC2140]), the initial transmit rate X is set to
     W_init/R, and tld is set to the current time."

However, this is a draft, still under revision and subject to further chang=
e.=20

The Linux CCID 3 module is at present not even compliant with 3448 / 4342, =
and we are having
enough work getting that done. There is therefore at the moment little poin=
t in thinking
about what could be done and what should be done: what we are implementing =
is RFC 4342/3448,=20
not more.

And if what is in the specification was not your intention, then this is ce=
rtainly not our problem!

You are suggesting and requesting features for which there is no support cu=
rrently in the RFCs
(see e.g. your earlier suggestion to re-introduce a socket option for packe=
t sizes).=20

What you are suggesting is helpful only for yourself as a writer of specifi=
cations, but it is not
helpful for those who have to implement these specifications. If we give in=
 to suggestions which
are not documented by IETF-reviewed and IETF-approved standards documents, =
then we end up doing=20
experimental work while the main target (a standards-compliant DCCP stack) =
is not even finished.

Therefore, let me put it very clearly: I am against implementing anything w=
hich is not stated in=20
RFCs 3448, RFC 4340, RFC 4341, and RFC 4342. About the rest we might talk w=
hen the Linux implementation
matches these RFCs, but before we have accomplished that: please stop sendi=
ng feature requests or
annotations which are not part of the publicly and IETF-approved RFCs. For =
these purposes, please
use dccp@ietf instead.=20

I am sure we can work out a constructive way of dealing with your interests=
 as well, but it is certainly
not via the avenue of implementing feature requests which you state without=
 contributing in work or in
funding.

Gerrit
