From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 02 Apr 2007 08:57:06 +0000
Subject: Re: [PATCH 24/25]: Macro for moving average
Message-Id: <200704020957.07122@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211846.10823@strip-the-willow>
In-Reply-To: <200703211846.10823@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > +/**
|  > + * Macro for exponentially weighted moving average
|  > + * @weight: Weight to be used as damping factor, in units of 1/10
|  > + * Beware that @val is evaluated multiple times.
|  > + */
|  > +#define TFRC_EWMA(val, newval, weight) \
|  > + =A0 =A0 =A0 val =3D val? ((weight) * val + (10 - (weight)) * (newval=
)) / 10 : (newval)
|  > +
|  Just wondering why you pass weight when you only use 9 anyway and it
|  just adds a step. Is it used in following patches with a different
|  weight?
| =20
In the following patches it is used one more time, which is for the `Preven=
ting=20
Oscillations' changeset (this is not in the next patch set but in the one a=
fter that);
here again the weight 9/10 is used. I think it is useful to keep the `weigh=
t' argument,
since RFC 3448 suggests to use a different weight for the RTT sample when t=
he `Oscillation
Prevention' e.g. is not deployed (a q close to zero).
I think it is better to keep the weight argument, it allows changing the co=
de later, while
still providing the abstraction: for CCID 3 there are 4 uses of this macro =
alone.
