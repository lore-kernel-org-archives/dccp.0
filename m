From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 12:36:06 +0000
Subject: RFC: TFRC Recalc on non-loss intervals [RFC 3448]
Message-Id: <200701031236.06427@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Can someone please offer an expert opinion on the following TFRC problem:

 =3D> Section 5.4 talks about calculating the average loss interval=20

 =3D> The issue is the following sentence: " we need to decide whether
     to include the interval since the most recent packet loss event."   (*)

 =3D> I am arguing that this is already taken care of by the way I_tot0 and=
 I_tot1
     are compared, i.e. the statement "I_tot =3D max(I_tot0, I_tot1)" enfor=
ces (*)

 =3D> True or False?

|  > | =A0This is making the code conform to RFC 3448, section 5.4
|  > I think there is a big misunderstanding here and the existing code, as=
 far as I can see,
|  > already conforms to [RFC 3448, 5.4].
|  >
|  > I got alerted when I re-read the following comment:
|  > =A0/* This code implements the part of section 5.4 of RFC3448 which sa=
ys we should
|  > =A0 * recalculate the average loss interval if we have a sufficient lo=
ng loss
|  > =A0 * interval.
|  > There is no such statement in RFC 3448, 5.4. The most close to this is
|  > =A0 "When calculating the average loss interval we need to decide whet=
her
|  > =A0 =A0to include the interval since the most recent packet loss event=
. =A0We
|  > =A0 =A0only do this if it is sufficiently large to increase the averag=
e loss
|  > =A0 =A0interval."
| =20
|  The RFC is a little confusing but I think I have carried out it's
|  intention correctly. I'll quote verbatim here the relevant parts:
| =20
|  =A0 =A0When calculating the average loss interval we need to decide whet=
her
|  =A0 =A0to include the interval since the most recent packet loss event. =
=A0We
|  =A0 =A0only do this if it is sufficiently large to increase the average =
loss
|  =A0 =A0interval.
| =20
|  =A0 =A0Thus if the most recent loss intervals are I_0 to I_n, with I_0 b=
eing
|  =A0 =A0the interval since the most recent loss event, then we calculate =
the
|  =A0 =A0average loss interval I_mean as:
| =20
|  Notice here the "interval since the most recent packet loss event".
|  This implies (but would help if explicit) that this is an interval
|  with no loss. We only use if it would increase the average.
| =20
