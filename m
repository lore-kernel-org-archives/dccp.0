From: David Miller <davem@davemloft.net>
Date: Mon, 17 Nov 2008 06:48:34 +0000
Subject: Re: [RFC] dccp ccid-3: High-res or low-res timers?
Message-Id: <20081116.224834.166724077.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20081115105042.GA7798@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 15 Nov 2008 11:50:42 +0100

> 1. Handling unavoidable waiting times
> -------------------------------------
>  One can not expect that, if the scheduling clock says 'send in x
>  microseconds', a packet will indeed leave after x microseconds; due to
>  waiting times. An example is in net/dccp/timer.c, when the socket is
>  currently locked - we wait for a "small" amount of time:
> 
> 	bh_lock_sock(sk);
> 	if (sock_owned_by_user(sk))
> 		sk_reset_timer(sk, &dp->dccps_xmit_timer, jiffies + 1);
> 	else
> 		dccp_write_xmit(sk, 0);
> 	bh_unlock_sock(sk);

This should not happen often enough to be statistically meaningful.

If it does we have serious lock contention and we should fix that.

> 2. Dependency on high-resolution timers
> ---------------------------------------
>  Committing the CCID-3/CCID-4 implementations to using high-resolution
>  timers means that the modules can not be built/loaded when the kernel
>  does not offer sufficient resolution.
> 
>  This has recently made it hard for someone using CCID-3 to find out
>  why DCCP would not run, where the cause was that high-resolution timers
>  were not enabled in the kernel.

This could be argued as a bug in the hrtimer interface.  What it should
do is let you use the interfaces always, and the kernel gives you as
fine a resolution as the current configuration supports.

> 3. Noise in the output
> ----------------------
> When tracking the speed of a car every 10 seconds, there is a lot of variation
> in the values, due to stopping at traffic lights, accelerating etc. But when
> considering a larger timescale, one can say that the average speed from city
> A to city B was xx mph, since the whole journey took 2.5 hours.

This argument is sound.

> 4. Not sure using high-resolution is the answer
> -----------------------------------------------
> While a fine-grained timer resolution may be desirable, it is not
> necessarily a must. The implementation of rate-based pacing in TCP
> (http://www.isi.edu/~johnh/PAPERS/Visweswaraiah97b.html) for instance
> also used low(er) resolution timers and it worked.
> 
> The RFC for CCID-3 (http://www.rfc-archive.org/getrfc.php?rfcS48) also
> does not high-resolution; it supports coarse-grained timestamps (section
> 6.3 and RFC 4342) and discusses implementation issues when using a 
> lower resolution (section 8.3).
> 
> The counter-argument could be that CCID-3 is a transport protocol with a
> built-in Token Bucket Filter so that similar considerations apply as for
> the Qdisc API (net/sched/sch_api.c).
> 
> Summing up, I have doubts that basing CCID-3 will bring advantages and
> would much rather go the other way and (consistently) use lower resolution.
> 
> Thoughts?

I wouldn't bother with high resolution timers, mostly because they are more
expensive and the benefit of them here is at best "unknown".
