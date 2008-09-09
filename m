From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 09 Sep 2008 08:09:11 +0000
Subject: Re: net-next-2.6 [pull-request] [PATCH 0/37] dccp: Revised set of
Message-Id: <20080909080911.GA9176@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080901164633.GA6456@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

| > This is an update with regard to Wei's comments. I have re-synched=20
| >=20
| > 	git://eden-feed.erg.abdn.ac.uk/dccp_exp		[subtree `dccp']
| > 	http://eden-feed.erg.abdn.ac.uk/cgi-bin/gitweb.cgi?p=DCcp_exp.git;a=3D=
shortlog;h=DCcp
| >=20
| > Also did some testing with a client that only supports CCID 2/3 talking=
 to a client supporting
| > CCID 2/3/4. They could still negotiate and settle for a common CCID.
|=20
Sorry the above includes the whole dccp test tree, over and above the
feature negotiation. We have been waiting for Arnaldo and there was a
phase where people sent comments about this patch set, so I had not
prepared a second net-next-2.6 pull request for this patch set yet.

If you want to revert this, I will prepare a net-next-2.6 clone with
just the revised 37 patches from this set.

Otherwise some parts (as below) need to be modified.


| #if (HZ >=3D 500)
| # define TFRC_T_DELTA		   USEC_PER_MSEC
| #else
| # define TFRC_T_DELTA		   (USEC_PER_SEC / (2 * HZ))
| #warning Coarse CONFIG_HZ resolution -- higher value recommended for TFRC.
| #endif
|=20
| Don't warn about crap like this, instead convert the code over to hrtimer=
s.
|=20
| This kernel being built, even with HZ=100, can do nanosecond timers on
| my systems, but that's only if you would make proper use of them.
|=20
The present sk_timer implementation uses the algorithm from RFC 3448. I
did not want to blindly port it to hrtimer since so far the following
difficulties were in the way:

 * when using the algorithm from RFC 3448, 4.6 directly with hrtimers,
   a large burst of activity will result, especially on fast links;

 * I have doubts whether it will help: each time the precision is improved,
   more frantic high-frequency noise results in CCID-3:
   - at some time socket timestamps were suggested for better RTT measureme=
nt,
     it proved better to reduce the precision to taking timestamps within t=
he
     DCCP module (smoother response and also includes slow receiver);
   - even with that, on Gigabit Ethernet zero-RTT samples still occur;
   - one of the above patches updates CCID-3 to track the sending rate X_re=
cv=20
     with higher frequency. There seems to be not much benefit, when compar=
ing
     the sender plots, the amount of high-frequency noise in X_recv has
     increased after increasing the frequency of updating;

 * some people have suggested to use a timerless algorithm instead which=20
   would just control the number of packets per time. This would require
   rewriting some of the infrastructure (with benefits), it would use
   hrtimers for measuring the time intervals.=20
