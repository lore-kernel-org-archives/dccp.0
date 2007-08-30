From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Aug 2007 15:29:00 +0000
Subject: Re: Test Tree Regression Tests
Message-Id: <200708301629.00760@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708241637.53767@strip-the-willow>
In-Reply-To: <200708241637.53767@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Quoting Ian McDonald:
|  > It is comparable but not equivalent, since in the above you are using =
a TBF which will change the nature
|  > of the traffic. I use the following (with qlen=10000):
|  >
|  > =A0 =A0 =A0 =A0 tc qdisc add dev eth0 root handle 1:0 netem delay ${de=
lay}ms
|  > =A0 =A0 =A0 =A0 tc qdisc add dev eth0 parent 1:1 pfifo limit ${qlen}
|  >
|  OK - I must confess to not studying the difference in queue
|  disciplines greatly, but I did find quickly the default queue lengths
|  were no use really.
I have done a little more testing and found that in this setting the FIFO l=
engths apparently do not
have a big impact. But I recall from earlier experiences with TBF and rate-=
limited traffic that=20
under-dimensioned queue lengths can lead to drops when the traffic is heavy.
 =20

|  > | =A0The reason for me putting zero % loss on return path is that we a=
re
|  > | =A0testing unidirectional flows. As such I wanted all feedback to co=
me
|  > | =A0back and if we lost feedback packets it would increase variabilit=
y. We
|  > | =A0should test loss of feedback packets for protocol reasons but not=
 so
|  > | =A0much for performance testing.
|  > Ah - I see, so this means that for performance testing I'd have to use=
:?
|  >
|  > =A0 =A0 =A0 =A0 tc qdisc add dev eth0 root netem delay 75ms loss 10% =
=A0 =A0 =A0# the forward path
|  > =A0 =A0 =A0 =A0 tc qdisc add dev eth1 root netem delay 75ms =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 # reverse path (no feedback loss)
|  >
|  Yes - I just happened to have a line with loss 0% from my python code
|  which is functionally equivalent to above.
I have added that to my script and tested a bit. It didn't decrease the var=
iability drastically (it is
still 130 Kbps ... 244 Kbps for the 150ms RTT / 10% loss case and t  second=
 runs), but then, we are=20
not dealing with a scientific instrument here; and there are lots of other =
factors which influence the
traffic.

I put the script online on http://www.erg.abdn.ac.uk/users/gerrit/dccp/test=
ing_dccp/tfrc_test.tc
Suggestions for improvements (a pythonised version would certainly be nice)=
 are welcome.
