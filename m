From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 07 Aug 2007 11:21:47 +0000
Subject: Re: [RFC][PATCH 2/2]: Promote CCID2 as default CCID
Message-Id: <200708071221.48077@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708021546.30471@strip-the-willow>
In-Reply-To: <200708021546.30471@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > =A0 =A0 Providing CCID2 as minimum-required CCID (like Reno/Cubic in T=
CP) seems reasonable.
| =20
|  I don't think it is required. The current Kconfig setup builds it by
|  default if you enable DCCP/
Yes that is true, but only in form of a default value; due to=20
 config IP_DCCP_CCID2
        # ...
        def_tristate IP_DCCP     < ---

My point of view is that only experienced people should disable CCID2; firs=
tly due to the
default assumptions (without further ado and configuration, DCCP will try t=
o load CCID2 as
its assigned default CCID), and further due to the suggestion in 4340 as a =
default: for an
unexperienced user, using CCID3 can have a bit of a learning curve.

 =20
|  I think this is worthwhile and should go ahead still. Better
|  documentation is always good. Couple of minor nits with this which
|  I've got below.
Thanks a lot - I will address this and re-post.

|  > +DCCP is a proposed IETF standard, and the homepage for DCCP as a prot=
ocol is at:
|  > =A0 =A0 =A0 =A0 http://www.read.cs.ucla.edu/dccp/
| =20
|  Home page is really
|  http://www.ietf.org/html.charters/dccp-charter.html now and isn't it a
|  standard now rather than proposed standard?
|  >
Hm, don't think so - if you look at the three levels of RFC 2026:

 * Proposed standard requires some maturity of specification, but:
    "Implementors should treat Proposed Standards as immature specification=
s. It is=20
     desirable to implement them in order to gain experience and to validat=
e, test,=20
     and clarify the specification. However, since the content of Proposed =
Standards
     may be changed if problems are found or better solutions are identifie=
d, deploying
     implementations of such standards into a disruption-sensitive environm=
ent is not=20
     recommended." (sec. 4.1.1)

 *  Draft Standard: "A specification from which at least two independent an=
d interoperable
                     implementations from different code bases have been de=
veloped [...]"
    We've got enough work already with one alone ... :)

 * Internet Standard: "A specification for which significant implementation=
 and successful
                       operational experience has been obtained [...]"

