From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 03 Jan 2007 12:56:11 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <200701031256.11671@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Hi Ian,

I appreciate the work you have put into this patch and have no doubt that
it may have cost a lot of time, but the problem here is one of perspective.

Let's separate the issues:

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
|  Backing up my implications is that we have intervals from I_0 to I_n
|  which is actually n+1 intervals so therefore I read I_0 to be the
|  interval of non-loss. Does this help? Once you see that it all falls
|  into place.
| =20
|  > If you mean this, then the patch is not necessary. The reason is that =
this statement
|  > refers to I_tot0 versus I_tot1. The statement
|  >
|  > =A0 I_tot =3D max(I_tot0, I_tot1);
|  >
|  > takes care of using the `interval since the most recent packet loss ev=
ent' only if
|  > it is sufficiently large. It is not explicit to see, but is implicitly=
 contained in the
|  > way the two weighted averages are compared against each other: it boil=
s down to
|  > comparing I_0 against the oldest 5 loss intervals.
|  >
|  > [ For a more detailed explanation, cf. the MSc thesis by Widmer, I als=
o have a set of
|  > =A0 notes on this case ]
|  >
|  I didn't mean that but someone had tried to implement it and had done
|  it incorrectly. The intent as I read is not to compare the calculation
|  with and without the most recent loss interval but to compare with and
|  without the non-loss interval.
 1) see previous posting - I think we are still having a misunderstanding h=
ere and
    I do think that what you cite above is already covered by the condition=
=20
    I_tot =3D max(I_tot0, I_tot1)". That would mean, as soon as we implemen=
t [RFC 3448, 5.4],
    we have this sorted out (and this method has been tested for 7 years).

|  The implementation in the kernel, which was wrong logic, also had
|  wrong implementation! The code was taken over from FreeBSD (relicensed
|  under GPL) and we actually didn't analyse properly and were excluding
|  the wrong item from the loop as linked lists ran the opposite
|  direction in FreeBSD to Linux in this case!!
 2) if you think this has not been implemented correctly, then can you plea=
se point out
    > where <. The situation at the moment is: you are saying "X has been i=
mplemented
    wrongly, so I use Y to solve the problem". Y however has not much in co=
mmon with X, so
    we are left with a broken method X and a non-standard method Y.=20

|  > As far as I can see, it is non-standard.
| =20
|  I believe it is standard as per earlier. It does boost performance but
|  correctly so. Search the archives for Burak and you will see what it
|  solves. It is particularly applicable to links like satellite with
|  fixed bandwidth. Think about say a 128 Kbits link and you get a loss
|  when you are at 40 Kbits per second. If you get no more loss then you
|  can never achieve your link speed as i_mean is not recalculated.
 3) I have a suggestion: you seem to be sure of the merits of this solution=
 and report on=20
    test results. My suggestion would be to offer using this method via a c=
onfiguration
    option (same as per the nofeedback timer threshold). You could put deta=
iled advice into
    the kernel configuration menu, and we would have the best of both world=
s - a standards-
    compliant TFRC implementation and a configurable Ian's nifty solution. =
Would that settle
    things?


|  All this is is a method of not having to call calc_i_mean for EVERY
|  packet which would be very expensive on CPU. It is new but is a very
 4) This code is only invoked when ccid3_hc_rx_detect_loss() returns true, =
hence it is not
    invoked for every packet.=20
