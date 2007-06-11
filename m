From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 08:18:25 +0000
Subject: Re: [PATCH 1/3]: Inline for time delta
Message-Id: <200706110918.25384@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200706091932.15559@strip-the-willow>
In-Reply-To: <200706091932.15559@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > --- a/net/dccp/dccp.h
|  > +++ b/net/dccp/dccp.h
|  > @@ -421,6 +421,11 @@ static inline suseconds_t timeval_delta(
|  > =A0 =A0 =A0 =A0 return secs * USEC_PER_SEC + usecs;
|  > =A0}
|  >
|  > +static inline s64 ktime_delta(ktime_t later, ktime_t earlier)
|  > +{
|  > + =A0 =A0 =A0 return ktime_to_us(ktime_sub(later, earlier));
|  > +}
|  > +
|  > =A0static inline void timeval_add_usecs(struct timeval *tv,
|  > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0const suseconds_t usecs)
|  > =A0{
| =20
|  Judging from patches I've seen rejected recently I'd say this should
|  be shifted into the same place as ktime_sub is defined. Also rename to
|  ktime_sub_us.
| =20
ktime_sub is defined in include/linux/ktime.h - the file only contains gene=
ric
definitions, everything is in nanoseconds, struct timeval, or struct timesp=
ec.

The other place is include/linux/skbuff.h, where net_timedelta() is defined=
.=20
This is probably due to the skb->tstamp field - as a utility function to be=
 used=20
with skbs.

Neither place seems appropriate for above function, it is more specific tha=
n the=20
ones in ktime.h. I am at a loss where else if not the DCCP code, where it is
specifically used, to place it.=20

The name was chosen for consistency with timeval_delta(), which is the curr=
ent
function for microsecond time differences in net/dccp/dccp.h.
