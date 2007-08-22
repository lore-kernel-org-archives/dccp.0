From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 22 Aug 2007 13:02:13 +0000
Subject: Re: [PATCH 2/3]: Provide 10s of microsecond timesource
Message-Id: <200708221402.13494@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708212000.16659@strip-the-willow>
In-Reply-To: <200708212000.16659@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

|  > I can see the following alternatives, what is your stance regarding:
|  > =A0(a) keep as it is (probably not agreeing due to this email?)
|  > =A0(b) keep principle, but use at socket creation (glitch comes possib=
ly later, but will still occur)
|  > =A0(c) ditch principle and use even lower granularity - milliseconds (=
jiffies seems like a natural match)
|  >=20
|  > My personal favourite is (c).
| =20
|  I think that we should provide the best granularity available we can
|  while not impacting non DCCP code (remember the net_enable_timestamp()
|  case?). CCID3 probably is what people will try first, I guess.
|
You are fully right on this one - when thinking again about (c) I thought t=
his is
nonsense, especially since new CCIDs will come and good resolution is avail=
able.
Fully agree with you.
 =20

|  Just checked and dccp_insert_option_timestamp already is called only
|  from two places: ccid3 and from dccp_insert_options when sending the
|  REQUEST packet, also on behalf of ccid3, I'll check if we can somehow
|  shift this option insertion in the REQUEST packet entirely to the
|  CCID3 code.
To be honest, I wasn't sure where to place this and timer.c seemed to be a =
generic=20
place. It may be that other code (as in your comment regarding CCID2) wants
to do a timestamp, so moving it to the CCID code could restrict this.

Aside: I had another thought recently - that of providing an `RTT' field
in the dccp_sk. In the spec there are numerous references to `if x does not=
 happen
for y RTTs, then do z'. This field could be initialised with the default RT=
T from=20
section 3.4 of RFC 4340 (200msec), so that it is there if some code needs i=
t.

 =20
|  Humm, there is also elapsed time in dccp_timestamp_echo, but that is a
|  delta, so we should have enough space on 32 bits... but because of that
|  we need to do timestamping on dccp_parse_options and not in the CCID
|  code that needs this... i.e. if we want to avoid having dccps_epoch in
|  dccp_sock we might as well get rid of dccps_timestamp_time and
|  dccps_timestamp_echo, shifting it to some other struct that would be
|  inserted on any CCID that wants to use these timestamping.
I haven't checked this but to me the dccps_timestamp_time seemed a very good
idea for measuring the elapsed time delta. I thought that this was pretty w=
ell
done.

I am taking your comments home, I will try to figure out if there is a bett=
er alternative
to the 11.9 hours glitch (which could happen before 11.9 hours have passed).

 =20
|  Checking RFC4341 (CCID2):
| =20
|  =A0 =A06. The sender estimates round-trip times, either through keeping
|  =A0 =A0 =A0 track of acknowledgement round-trip times as TCP does or thr=
ough
|  =A0 =A0 =A0 explicit Timestamp options, and calculates a TimeOut (TO) va=
lue
|  =A0 =A0 =A0 much as the RTO (Retransmit Timeout) is calculated in TCP. =
=A0
There is a trap here. I have been thinking about the same stuff when workin=
g on CCID3.
It reads very simple, but opens a can of worms. When looking at the RFC 132=
3 code for
this kind of timestamping, one can see that there are quite a few cases whe=
re this simple
notion of RTT sampling can go very wrong. And they also did an Internet Dra=
ft which corrected
the errors from the RFC 1323 spec for this (it is referenced in the TCP cod=
e somewhere).
I'd take my hat off to anyone able to turn this into a robust algorithm, I =
think this is not
trivial do get right. The way it is done in CCID3 is robust IMHO, i.e. take=
 one timestamp
when the packet leaves, take another when the reply comes and compute the d=
ifference.
