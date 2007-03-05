From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Mar 2007 09:49:49 +0000
Subject: Re: [dccp] Question on resetting nominal send time
Message-Id: <200703050949.49387@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
In-Reply-To: <5640c7e00701161351q19360335mf2862a31596ae94a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Eddie,

Sorry for the delay in responding.

|  What follows is a first cut at a solution. =A0Any thoughts from others??
| =20
|  If t_ipi is used to schedule transmissions, then the following equation =
should=20
|  be applied each time the application is scheduled:
| =20
|  =A0 =A0 t_ipi :=3D max(t_ipi, t_now - RTT/2)
| =20
|  This never lets t_ipi fall more than 1/2 RTT behind the current time. =
=A0An=20
|  application is still allowed to send packets in a small burst after an i=
dle=20
|  period, but the size of that burst is limited to RTT/2 worth of packets.
| =20
|  RTT/2 was chosen because senders can send 2*last_receive_rate in any RTT.
| =20
|  I am sure that this simple choice has disadvantages, such as little burs=
ts at=20
|  the beginnings of idle periods. =A0One could be more conservative and se=
t e.g.
| =20
|  =A0 =A0 =A0t_ipi :=3D max(t_ipi, t_now - t_gran).
| =20
|  But I think RTT/2 might be OK. =A0Implementation experience would be pre=
ferred.
| =20
|  This issue is really an implementation issue. =A0RFC3448 4.6 is not exac=
tly=20
|  normative; it discusses one way to achieve a send rate, not a required=20
|  implementation. =A0So in some sense the implementer is free to choose an=
ything=20
|  reasonable.

In TFRC t_ipi is always smaller than RTT, so RTT/2 is an upper bound. I thi=
nk it makes
sense (from an implementation standpoint) to use one full t_ipi as upper bo=
und. This
is similar to your solution in that both values are less than RTT, and both=
 provide
a means to stop large `packet storms'.=20
The reason for chosing t_ipi is that the size of the large burst depends on=
 the number
of full t_ipi intervals that fit into the time interval that the receiver i=
s lagging=20
behind (can send detailed derivation). But, as said, both choices are simil=
ar.

Gerrit
