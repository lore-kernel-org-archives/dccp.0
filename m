From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 10 Mar 2008 13:00:56 +0000
Subject: Re: dccp bugs (Was: Re: panic on 2.6.24rc5)
Message-Id: <20080310130056.GA28663@gerrit.erg.abdn.ac.uk>
MIME-Version: 1
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
List-Id: <dccp.vger.kernel.org>
References: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200803081629.09562.tomasz@grobelny.oswiecenia.net>
To: dccp@vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

| > | And so I guess that this NET_XMIT_DROP should be ignored by dccp code?
| >
| > In the test tree it is now (almost) ignored. Since the time you reported
| > this problem I have changed the DCCP_BUG to a DCCP_WARN, so that the
| > drop will still be logged, but there will be fewer such warnings in the
| > log now (in DCCP_WARN, printk is rate-limited).
| >
| I'm not sure it should print the warning. Ok, it's nice to know that the 
| packet was dropped but:
| a) in real world there would be no such information,
| b) it's not something unusual for DCCP to lose packet without warning.
| Maybe it should only warn if debugging option is enabled?
| 
Ok that is a good point. What I will do is to change the DCCP_WARN() for
this error message to a dccp_pr_debug(), so that the message will only 
get printed for debugging purposes.


| > | >  * to avoid this, there is a kernel configuration option of CCID-3
| > | >    to set an upper bound for this.
| > |
| > | How do I set it?
| >
| > In the menu under
| >  Networking -> Network Options -> The DCCP Protocol (EXPERIMENTAL)
| >  -> DCCP CCIDs Configuration (EXPERIMENTAL) -> CCID3
| >  -> (100) Use higher bound for nofeedback timer
| > Ah - just remembered -- the default is 100 milliseconds, so this will
| > probably have caught the problems with the low RTT.
| >
| 100ms? Then it doesn't work as expected because adding just 1ms delay with 
| netem fixed the problem.
| If you meant 100us then it still doesn't work. Changing the parameter to 1000 
| delays the bug - I have to send more packets for it to happen.
| 
It is not as easy as that. This value determines a lower bound, in order
to cope with very low RTTs (i.e. less than 1 millisecond). What this
value changes is when the nofeedback timer is triggered. This is
normally max(4*RTT, 2*s/X), so a minimum of 4 RTT. But when RTTs are
low, it can happen that the nofeedback timer is triggered several times
between sending two frames (e.g. a VoIP inter-frame interval of 20ms). 
The configuration value sets a minimum lower bound of
	timeout = max(CONFIG_RTO_MIN, max(4*RTT, 2*s/X))
to cope with the problem of low RTTs.	

You are calling this a bug -- I think it is quite likely that CCID-3 is simply
not meant for the way you are using it. Please see below.


| > So from what you wrote I read
| >  * without additional delay the described problem occurs and CCID-3
| >    gets into 1-packet-per-64-seconds mode
| >  * when you add 1millisecond delay to the interface then it works ok.
| >
| That's exactly what I meant. After adding this 1ms delay I was not able to 
| reproduce the bug. This does not mean it would not happen after long enough 
| testing.
| 
Thanks for providing the dccp_probe data. I have had a look at it and it
is a bit as expected. The value of the RTT is:

   min: 3usec,  avg: 48.0 usec,  max: 4.513 msec;  with stddev of 324.68.
   
The loss was all the time 0, the receiver reported something like 1.8 kbps
(230 bytes per second).

The start-up behaviour is that there is a spike in the RTT where it
reaches its maximum right at the beginning (4.5 msec); this soon fades
out after the first 5 seconds, after which it reaches the average of 48
microseconds. This RTT is about 5..10 times less than a standard PC RTT
(250..500 microseconds).

Now I have a question: adding 1 ms delay at the interface avoided the
hang-up, but what do you mean by "long enough"? Is this 60 seconds?

I have attached the plot of the t_ipi which indeed climbs to
astronomical values after the initial period (when the RTT was low).

But since the average RTT is 48 microseconds in the `outfile', I am
assuming that the outfile was produced when the delay was not added to
the interface?

There is a long-standing problem (at least 1 year) with regard to CCID-3
over high-speed networks (and lo interface is in fact a high-speed
interface): high link speeds are outside the control region of CCID-3.

The peak limit of controllable speed is about 12 Mbps. Everything higher
that will cause problems. I have not tested, but you may be able to 
also silence this behaviour by using a netem token-bucket filter with
e.g. a maximum bitrate of <= 10 Mbps.


So I think the least thing we need to do is put a warning into the DCCP
Wiki that people should add interface delay when using CCID-3 for 
testing over loopback.

--J/dobhs11T7y2rNN
Content-Type: image/png
Content-Disposition: attachment; filename="t_ipi.png"
Content-Transfer-Encoding: base64

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
AABJRU5ErkJggg==

--J/dobhs11T7y2rNN--
