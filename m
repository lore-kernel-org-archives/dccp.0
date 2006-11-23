From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 23 Nov 2006 11:59:43 +0000
Subject: Re: [PATCH 3/6]: Fix calculation of t_ipi time of scheduled transmission
Message-Id: <200611231159.43164@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
In-Reply-To: <5640c7e00611210945l39bc33f5q3ab38c0bba022c1a@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* if (t_now > t_nom - delta)
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0 // send the packet now
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* else
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* =A0 =A0 =A0 // send the packet in (=
t_nom - t_now) milliseconds.
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (delay < hctx->ccid3hctx_delta)
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D 0;
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
|  > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D delay/1000L;
| =20
|  Shouldn't that last line be rc =3D (delay-hctx->ccid3hctx_delta)/1000 as
|  you're not taking the delta into account on the else clause.

The value of `delay' is the difference between t_nom =3D t_(i+1) and t_now:

	delay =3D timeval_delta(&hctx->ccid3hctx_t_nom, &now);

If this difference is less than delta (which includes the case when t_now is
later than t_nom such that the difference is negative), then the packet is =
sent now.

If the difference is greater than delta then t_now < t_nom and the packet i=
s too early
to be sent; [RFC 3448, 4.6] says to reschedule in=20

          t_ipi - (t_now - t_i) =3D t_ipi - (t_now - t_i) =3D (t_i + t_ipi)=
 - t_now
                                                        =3D t_(i+1)       -=
 t_now
                                                        =3D t_nom         -=
 t_now

Hence we can reuse the timeval_delta. Maybe the variable should be renamed =
to highlight
the fact that it is a time difference, but I quite liked `delay'.
