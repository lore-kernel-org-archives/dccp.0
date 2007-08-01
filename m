From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 01 Aug 2007 16:18:36 +0000
Subject: Re: RFD: Ack Vectors
Message-Id: <200708011718.37036@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200707300934.36798@strip-the-willow>
In-Reply-To: <200707300934.36798@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > With regard to the Ack Vectors, my suggestion however is
|  > =A0* to remove the sysctl - it is confusing;
| =20
|  Agree in current form provided the next bullet point is carried out.
| =20
|  > =A0* to make the use of Ack Vectors dependent on the current RX CCID;
| =20
|  It should be on for CCID2, off for CCID3. It is required for CCID2
|  according to RFC4341. It is optional for CCID3 according to RFC4342.
|  However last time I checked with our CCID3 it breaks it. I haven't
|  checked recently though....
| =20
|  > =A0* the TX CCID need not be considered for the Ack Vector allocation,=
 since the `Send Ack Vector'
|  > =A0 =A0feature is server-priority (RFC 4340, 6.4) and thus negotiated =
by the side which has the RX CCID;
| =20
|  OK.
Omission on my side - I have just checked and found out that the negotiatio=
n of the "Send ack vector
feature" is not yet implemented. It is not something which can be done with=
 a hack, since the CCIDs
can also be negotiated, so that enabling Ack Vectors depends on the end res=
ult of negotiating the
CCID.=20
I think at the moment we should add this as a ToDo. If I get some time I'll=
 try to implement the
above, but it is more work than anticipated and so depends on available tim=
e.
=20
|  > =A0* optional and for debugging: disabling of Ack Vectors in the Kconf=
ig menu.
|  >
|  This implies it is on by default. I think it should be off by default
|  for CCID3.=20
This is resolved, since the Kconfig implementation was quite cleverly done =
(not by me):
config IP_DCCP_CCID2
        tristate "CCID2 (TCP-Like) (EXPERIMENTAL)"
        depends on IP_DCCP
        def_tristate IP_DCCP
        select IP_DCCP_ACKVEC

=3D> When CCID2 is enabled, then support for Ack Vectors is automatically c=
ompiled in.
   (I would like to return in the discussion to the `Null CCID' issue and w=
ill send RFC).

As said, auto-disabling Ack Vectors depending on the CCID is a bit more com=
plicated than
anticipated.


|  The information is not actually needed from an ack vector=20
|  and actually creates more traffic. It seems like
|  draft-kohler-dccp-ccid3-drops-01.txt is a replacement for ack vectors
|  in CCID3 if you need extra info.
Never figured that one out - doesn't the Data Dropped option do the same th=
ing?=20
