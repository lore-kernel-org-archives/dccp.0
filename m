From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 12 Jan 2007 10:39:13 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <200701121039.13177@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  Summary: I agree with Ian that hrtimer support is not required, and that=
=20
|  bursts are OK. =A0They are explicitly allowed by the RFC.
I don't have much disagreement with your points. However, the `bursts' issue
can really not be dismissed as unproblematic. Please see other reply.

| =20
|  > =A0 When a sender first starts sending at time t_0, it calculates t_ip=
i,
|  > =A0 and calculates a nominal send time t_1 =3D t_0 + t_ipi for packet =
1.
|  > =A0 When the application becomes idle, it checks the current time, t_n=
ow,
|  > =A0 and then requests re-scheduling after (t_ipi - (t_now - t_0))
|  > =A0 seconds. =A0When the application is re-scheduled, it checks the cu=
rrent
|  > =A0 time, t_now, again. =A0If (t_now > t_1 - delta) then packet 1 is s=
ent.
|  >=20
|  > Note that initially we set t_ipi to 1 second. This could be set to a
|  > better value based on connection setup as per Eddie and your
|  > discussion earlier but I haven't implemented this yet. In this way my
|  > code is a hack that I remove the 1 second and add the initial RTT once
|  > we obtain it. I see this ugliness can be removed when we make the code
|  > base conform to the RFC intent (it is not in RFC yet but Eddie said he
|  > would propose for revision)
| =20
|  For what it's worth, it's as close to in the RFC as it can get without a=
=20
|  revision. =A0The authors of the RFC agree that we meant the initial=20
|  Request-Response RTT to be usable as an initial RTT estimate; the=20
|  working group agreed; errata has been sent.
So we are RFC-compliant for the moment. One point which remains unresolved =
is,
the above is about RTTs, but what about the initial sending rate of 1 packet
per second, which implies an initial t_ipi of 1 second?
