From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 04 Sep 2007 14:58:25 +0000
Subject: Re: [PATCH 0/6] DCCP: Implement TFRC Faster Restart
Message-Id: <200709041558.26097@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291113.07431.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291113.07431.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > * when updating to the forthcoming rev04 of the current rev03 of the F=
aster Restart
|  > =A0 draft, one needs to track the old changes and it is difficult to s=
ay now what the
|  > =A0 changes will look like
|  >
|  Agree. But don't think this is an obstacle to merging as we are
|  running obsolete code in other branch/mainline ;-)
|
That is not what I meant. Of course it is not an obstacle of getting code `=
in', but the
problem is in getting the code `out' or updated when there is time for a ne=
w revision.

When there is little or no documentation in the code saying which variable =
or piece of
code belongs where, then each time someone wants to change a bit of code ha=
s to reverse-
engineer what actually is going on. This can be very time-consuming. So I w=
as not thinking
in terms of merging (although I am sure that Arnaldo will pick out bad code=
), but of keeping
the code changeable for a longer period and easier to update.

Don't get me wrong, I don't mean your code here, it is a general problem wh=
ich I think we
should pay more attention to. And, as said, my ideas of keeping things sepa=
rate may not be
the best possible solution, only one that I could think of at the moment.

 =20
|  > * the CCID3 code is currently facing the following revisions
|  > =A0 =A0 =A0 =A0 - the current code implements rev00
|  > =A0 =A0 =A0 =A0 - Tommi's CCID4 relies on rev01 (not sure about Leandr=
o's)
|  > =A0 =A0 =A0 =A0 - your FR code actually would need rev02
|  > =A0 =A0 =A0 =A0 - rev02 is in the process of being revised and obsolet=
ed into rev03
|  >
|  Agree all the versions are a mess. I think it's worthwhile starting on
|  upgrading the code base but not a project I'm undertaking at the
|  moment (or you).
Hopefully there will be some IETF consolidation about rfc3448bis in Decembe=
r, then all this
could be reduced to one revision.=20

Imagine -- 4 different developers and 3 different draft versions :(
