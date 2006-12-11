From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Dec 2006 10:31:03 +0000
Subject: Re: [PATCH] BUG-FIX - conversion errors
Message-Id: <200612111031.03755@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612081532.21104@strip-the-willow>
In-Reply-To: <200612081532.21104@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > | =A0Do we calculate mss anywhere?
|  > Yes there is support in dccps_mss_cache .
|  > At the begin of dccp_send_msg e.g. it is used.=20
| =20
|  Yup, look at dccp_sync_mss() used in dccp_connect_init():

<snip>

Thank you for the helpful `pointers' :)  - I was amazed a couple of months =
ago
about how much of that code is active and quietly doing its job with accura=
cy.=20


|  =A0 =A0 =A0 =A0 /*
|  =A0=A0=A0=A0=A0=A0=A0=A0 * FIXME: this should come from the CCID infrast=
ructure, where,
|  =A0=A0=A0=A0=A0=A0=A0=A0 * say, TFRC will say it wants TIMESTAMPS, ELAPS=
ED time, etc,
|  =A0=A0=A0=A0=A0=A0=A0=A0 * for now lets put a rough estimate for NDP + T=
IMESTAMP +
|  =A0=A0=A0=A0=A0=A0=A0=A0 * TIMESTAMP_ECHO + ELAPSED TIME + TFRC_OPT_LOSS=
_EVENT_RATE +
|  =A0=A0=A0=A0=A0=A0=A0=A0 * TFRC_OPT_RECEIVE_RATE + padding to
|  =A0=A0=A0=A0=A0=A0=A0=A0 * make it a multiple of 4
|  =A0 =A0 =A0 =A0 =A0*/
| =20
|  =A0 =A0 =A0 =A0 mss_now -=3D ((5 + 6 + 10 + 6 + 6 + 6 + 3) / 4) * 4;
| =20
I thought that when we are actively using the provided MSS facilities, then=
 there
is more incentive to tackle this one above too.



|  Infrastructure wise I guess struct ccid_operations should have a...
|  lemme read the relevant part of 4340... there CCMPS:
| =20
|  ----------------- 8< -------------
|  14. =A0Maximum Packet Size
| =20
|  =A0 =A0A DCCP implementation MUST maintain the maximum packet size (MPS)
|  =A0 =A0allowed for each active DCCP session. =A0The MPS is influenced by=
 the
|  =A0 =A0maximum packet size allowed by the current congestion control
|  =A0 =A0mechanism (CCMPS), the maximum packet size supported by the path's
|  =A0 =A0links (PMTU, the Path Maximum Transmission Unit) [RFC1191], and t=
he
|  =A0 =A0lengths of the IP and DCCP headers.
|  ----------------- 8< -------------
I don't know how often I read through 4340, 4341 and 4342 trying to find ou=
t what `CCMPS'
is for - it seems that in CCID2 and CCID3 it is both set to `infinity', at =
least I can
find no explicit mention in 4341/4342 of CCMPS.

But for the MSS caching a `ccid_mps' member would be useful anyway for the =
above required purpose.

This in turn re-opens other questions - in CCID3 e.g. feedback packets shou=
ld always contain
also a Loss Intervals option - which is still missing in CCID 3.=20

It is good that you raise this; I put a copy into my ToDo folder and will a=
sk around in some time
if anyone is working on it. If no one else does it I will give it a try at =
some time, but am bogged
down by other work. I am re-working the CCID `larger initial windows' patch=
 at the moment, plus
sequence number issues.=20
