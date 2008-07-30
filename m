From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 30 Jul 2008 17:23:15 +0000
Subject: Re: [PATCH 1/7] dccp ccid-3: Runtime verification of timer
Message-Id: <20080730172315.GB10381@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1217268843-19667-2-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| >
| > This prevents module loading when the timer resolution is too low
| > (e.g. when using jiffies as a clocksource or when disabling high
| > resolution timers on sparc64).
| >
| > Rationale:
| > ----------
| > The DCCP base time resolution is 10 microseconds (RFC 4340, 13.1...3). Using a
| > timer with a lower resolution than that was found to trigger the following bug
| > warnings/problems on high-speed networks (e.g. local loopback):
| >
| >  * small RTT samples are rounded down to 0
| >  (in some cases, even negative RTT samples occurred);
| >  * the CCID-3 feedback timer complains that the feedback interval is 0,
| >   since the coarse-grained resolution rounds RTT-wise intervals down.
| >
| > The following syslog messages were observed with a low resolution:
| >  11:24:00 kernel: BUG: delta (0) <= 0 at ccid3_hc_rx_send_feedback()
| >  11:26:12 kernel: BUG: delta (0) <= 0 at ccid3_hc_rx_send_feedback()
| >  11:26:30 kernel: dccp_sample_rtt: unusable RTT sample 0, using min
| >  11:26:30 last message repeated 5 times
<snip>
| 
| I don't think this is the right direction to head. I think it is
| acceptable to have not perfect performance if HR timers aren't loaded
| (and I'm sure ways could be made to improve this) but to disable CCID3
| altogether is quite drastic. Where will CCID3 be used - think embedded
| multimedia home devices. These may not have HR timers....
| 
| So I disagree with this one.
| 
I think we need to continue this discussion on two levels
 1. what should/could be done
 2. what the code currently supports.

With regard to the first point I fully agree with you. If it would be
possible to use a jiffy-based timer basis for the TFRC (CCID-3/4) code
it would make things easier. The code changes that this requires are
however too big. It will take a lot of time to find something usable.

In this regard, here is one of the most urgent ToDos: developing an
RFC1323-style algorithm for use with DCCP timestamps and elapsed time
option. This would kill several birds with one stone, since the CCID-2
RTT estimation code is currently below par (not even as good as the 
TCP code). But RTT sampling is just one part of the problem, the other
problem is the interval between feedback packets. If you look at the
patch which computes X_recv - when the interval is too small/large, the
reported value of X_recv becomes too large/small, respectively.

The second question under point (1) is whether the embedded devices
actually lack high-resolution timer support. I am CC:-ing this to
Leandro, who I hope will be able to provide some information about 
whether this will cause problems on the Maemo platform. 

Or hopefully some knowledgeable embedded-systems people on this list will
shed some light regarding availability of high-res. (<= 10 usec) timers.

Regarding point (2): the code implicitly depends on a time resolution 
in the order of 10s of microseconds. The most recent example was the 
bug reported by Tomasz, which resulted from a loopback RTT of less than
4 microseconds. Many people now use virtualisation and will want DCCP
to still work even with extremely low RTTs.		     

Even if embedded systems do not have high resolution timers, I think it
is not good to remove this protection, since frankly the code does not
work without a fine-grained timer resolution. The protection is there
to ensure that the code gets the conditions it implicitly requires.

