From: "Saverio Mascolo" <saverio.mascolo@gmail.com>
Date: Tue, 18 Nov 2008 17:55:51 +0000
Subject: dccp@vger.kernel.org
Message-Id: <b98e548c0811180955q3c7a5358q798b556c67dbc6d6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Dear Gerrit and all,

we have recently submitted to Infocom 2009 a  paper entitled:

"A Mismatch Controller for Implementing Rate-based Transport Protocols"

that is definitely  related with your email. You can find the paper at the =
url:
http://c3lab.poliba.it/images/0/06/Rmc_ratebased.pdf

Basically we show that a simple feedback loop can  compensate and
counteract uncertainty in timers duration due to clock granularity,
shared Operating System  etc. In this way, the sensitivity to  timer
granularity is greatly reduced.

Please not  that RFC3448 (the TFRC RFC) also provide  a heuristic
(reported as Algorithm 1 in our paper) that anticipate packet sending
times to compensate for delays.

We report the abstract of the work below:
{
End-to-end rate-based congestion control algorithms,
such as TFRC, RAP or ARC, are advocated for audio/video
transport over the Internet instead of window-based protocols.
The reason is that a smoother dynamics of packet sending is
advantageous when avoiding abrupt rate changes is of importance.
Once the sending rate has been computed by a generic rate-based
congestion controller, all algorithms proposed in the literature
schedule packets to be sent spaced at intervals that are equal
to the inverse of the sending rate. In this paper we show that
such an implementation omits to consider a key feature. In fact,
the scheduled sending time of a packet is affected by significant
uncertainty due to the fact that it is handled by the Operating
System, which manages a CPU shared by other processes. A
significant experiment reported in the paper shows that a required
constant sending rate can in practice turn into an effective sending
rate that is as low as one half of the desired one. To overcome this
problem, a Rate Mismatch Controller (RMC) is designed aiming
at counteracting the disturbance on the effective sending time due
to the CPU time-varying load. Experimental results using Linux
OS highlight the effectiveness of the proposed controller.
}

Any comments are very welcome.

Thanks for the attention and best regards,
saverio
- Show quoted text -

On Sun, Nov 16, 2008 at 9:14 AM, Ian McDonald <ian.mcdonald@jandi.co.nz> wr=
ote:
>
> OK. I'll add a few comments even though I'm a little bit rusty...
>
> I was previously an advocate of low resolution timers and then use
> bursts as needed to achieve the average rate as specified in RFC3448.
>
> The reasoning for this was very much as you discuss in point 1 - that
> you achieve less than the desired rate with high resolution timers as
> you will never get exactly to transmit at the time you require (unless
> you have a "hard" realtime system with desired accuracy) - so any
> delay will slow down your transmit rate, and that high resolution
> timers may not be available on all architectures. I also had a third
> reason - overhead - if you're interrupting other tasks and having to
> do a context switch many, many times a second surely that isn't so
> good?
>
> However RFC 5348 changes this as this clause is added to 4.6:
>  To limit burstiness, a TFRC implementation MUST prevent bursts of
>   arbitrary size.  This limit MUST be less than or equal to one round-
>   trip time's worth of packets.  A TFRC implementation MAY limit bursts
>   to less than a round-trip time's worth of packets
>
> and this is further explained in section 8.3 and the downside - that
> you can't send big bursts so you can't get the full calculated rate.
>
> The RFC uses an example of 1 msec scheduling and 0.1 msec RTT. However
> what would be worse is devices on a LAN with 10 msec timer - e.g. two
> embedded devices at home - I haven't done the maths but I think the
> rate achievable would be quite low.
>
> One thing that I think we do need to be careful about though is
> assuming that we should be trying to get very high speed transfer -
> DCCP is not what we would layer a file serving protocol on top of....
> (some have argued you shouldn't even use TCP for this on a LAN...)
>
> Thinking laterally there is another possible solution - something I
> used way back in the 80s for another project - build your own
> scheduler! We could set a high resolution timer to tick every 0.1 msec
> and then use the coarse grained algorithm at that point....
>
> This is a hack to some degree and I can imagine David Miller
> suggesting that it is more a protocol issue... The other thing is that
> if we did this we would have to only do it when we actually need and
> use higher granularity at other times or else the Powertop people may
> not be so happy.
>
> Anyway - something to think about. I've also added the IETF list as
> well in case people there have the answers.
>
> Regards
>
> Ian
>
> On Sat, Nov 15, 2008 at 11:50 PM, Gerrit Renker <gerrit@erg.abdn.ac.uk> w=
rote:
> >
> > I would appreciate some advice and insights regarding the use of
> > high-resolution timers within a transport protocol, specifically
> > DCCP with CCID-3 (RFC 5348).
> >
> > Currently the implementation is in a limbo of high-resolution and
> > low-resolution code. It is not good, neither here nor there, so
> > I would like to work on making the interface consistent.
> >
> > After thinking this through I encountered a number of points
> > which made me question whether high-resolution timers will lead to
> > better performance and a cleaner interface.
> >
> > I'd appreciate comments and input on this, the points are below.
> >
> > 1. Handling unavoidable waiting times
> > -------------------------------------
> >  One can not expect that, if the scheduling clock says 'send in x
> >  microseconds', a packet will indeed leave after x microseconds; due to
> >  waiting times. An example is in net/dccp/timer.c, when the socket is
> >  currently locked - we wait for a "small" amount of time:
> >
> >        bh_lock_sock(sk);
> >        if (sock_owned_by_user(sk))
> >                sk_reset_timer(sk, &dp->dccps_xmit_timer, jiffies + 1);
> >        else
> >                dccp_write_xmit(sk, 0);
> >        bh_unlock_sock(sk);
> >
> >
> > 2. Dependency on high-resolution timers
> > ---------------------------------------
> >  Committing the CCID-3/CCID-4 implementations to using high-resolution
> >  timers means that the modules can not be built/loaded when the kernel
> >  does not offer sufficient resolution.
> >
> >  This has recently made it hard for someone using CCID-3 to find out
> >  why DCCP would not run, where the cause was that high-resolution timers
> >  were not enabled in the kernel.
> >
> >
> > 3. Noise in the output
> > ----------------------
> > When tracking the speed of a car every 10 seconds, there is a lot of va=
riation
> > in the values, due to stopping at traffic lights, accelerating etc. But=
 when
> > considering a larger timescale, one can say that the average speed from=
 city
> > A to city B was xx mph, since the whole journey took 2.5 hours.
> >
> > The same can currently be observed with X_recv - there is one commit wh=
ich
> > tries to make X_recv as fine-grained as possible, it is labelled "dccp =
ccid-3:
> > Update the computation of X_recv",
> > http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3Dc=
ommitdiff;h-0b687025494e5d8918ffcc7029d793390835cc
> >
> > The result is that X_recv now shows much wider variation, on a small ti=
mescale
> > there is a lot happening. It can best be seen by plotting the X_recv us=
ing
> > dccp_probe. Without this commit the graphs are much 'quieter' and just =
show
> > the long-term average.
> >
> > In TCP Westwood for instance a low-pass filter is used to filter out the
> > high-frequency changes in the measurements of the Ack Rate:
> >
> > "TCP Westwood: Bandwidth Estimation for Enhanced Transport over Wireles=
s Links"
> > Mobicom 2001
> > http://www.cs.ucla.edu/NRL/hpi/tcpw/tcpw_papers/2001-mobicom-0.pdf
> >
> > I'd appreciate opinions on this, as I think
> >
> > With regard to CCID-3, it also seems to be be better to revert the above
> > commit and just use long-term averages.
> >
> >
> > 4. Not sure using high-resolution is the answer
> > -----------------------------------------------
> > While a fine-grained timer resolution may be desirable, it is not
> > necessarily a must. The implementation of rate-based pacing in TCP
> > (http://www.isi.edu/~johnh/PAPERS/Visweswaraiah97b.html) for instance
> > also used low(er) resolution timers and it worked.
> >
> > The RFC for CCID-3 (http://www.rfc-archive.org/getrfc.php?rfcS48) also
> > does not high-resolution; it supports coarse-grained timestamps (section
> > 6.3 and RFC 4342) and discusses implementation issues when using a
> > lower resolution (section 8.3).
> >
> > The counter-argument could be that CCID-3 is a transport protocol with a
> > built-in Token Bucket Filter so that similar considerations apply as for
> > the Qdisc API (net/sched/sch_api.c).
> >
> > Summing up, I have doubts that basing CCID-3 will bring advantages and
> > would much rather go the other way and (consistently) use lower resolut=
ion.
> >
> > Thoughts?
>
>
>
> --
> Web: http://wand.net.nz/~iam4/, http://www.jandi.co.nz
> Blog: http://iansblog.jandi.co.nz



--
Prof. Saverio Mascolo
Dipartimento di Elettrotecnica ed Elettronica
Politecnico di Bari
Via Orabona 4
70125 Bari
Italy
Tel. +39 080 5963621
Fax. +39 080 5963410
email:mascolo@poliba.it

http://www-dee.poliba.it/dee-web/Personale/mascolo.html


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D This message may contain c=
onfidential and/or legally privileged information.
  If you are not the intended recipient of the message, please destroy it.
 Any unauthorized dissemination, distribution, or copying of the material in
 this message, and any attachments to the message, is strictly forbidden.
