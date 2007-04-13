From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Apr 2007 18:27:21 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <200704131927.21551@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Your arguments consider only the specification. What you don't see, and Ian also doesn't seem
to see, is that this implementation conforms to the ideas of TFRC only up to a maximum speed
of s * HZ bytes per second; under benign conditions this is about 12..15 Mbits/sec.

Once you are past that speed you effectively have a `raw socket' module whose only resemblance 
to TFRC/DCCP is the package format; without even a hint of congestion control.

Here for instance is typical output, copied & pasted just a minute ago:

$ iperf -sd -t20
------------------------------------------------------------
Server listening on DCCP port 5001
DCCP datagram buffer size:   106 KByte (default)
------------------------------------------------------------
[  4] local 192.235.214.65 port 5001 connected with 192.235.214.75 port 40524
[  4]  0.0-20.4 sec  1.08 GBytes    454 Mbits/sec                              

If you ask the above sender to reduce its speed to 200 Mbits/sec in response to network congestion
reported via ECN receiver or feedback it will _not_ do that - simply because it is unable to control
those speeds. It will continue to send at maximum speed (up to 80% link bandwidth is possible).

Only when you ask it to reduce below s * HZ will it be able to slow down, which here would mean
to reduce from 454 Mbits/sec to 12 Mbits/sec.

That said, without this patch you will get a stampede of packets for the other reason that
the scheduler is not as precise as required; it will always add up the lag arising from
interpreting e.g. 1.7 as 1 and 0.9 as 0 milliseconds. I still would like this patch in for exactly
these reasons.

Seriously, I think that Linux or any other scheduler-based OS is simply the wrong platform for CCID3, 
this here can not give you the precision and the controllability that your specification assumes
and requires. 

You are aware of Ian's (and I doubt whether he is the only one) aversions against high-res timers.
This would remove these silly accumulations and remove the need for patches such as this one.

The other case is the use of interface timestamps. With interface timestamps, I was able to accurately
sample the link RTT as it is reported e.g. by ping. With the present layer-4 timestamps, this goes up
back again to very high values, simply because the inaccuracies add all up. 

Conversely, it very much seems that the specification needs some revision before it becomes implementable
on a non-realtime OS. Can you give us something which we can implement with the constraints we have
(i.e. no interface timestamps, no high-res timers, accumulation of inaccuracies)?

CCID2 works nicely since it does not have all these precision requirements.





Quoting Eddie Kohler:
|  > That is one of the problems here - in the RFC such problems do not arise, but the implementation needs
|  > to address these correctly.
|  
|  The RFC's solution to this problem, which involves t_gran, EXACTLY addresses this
|  
|  > |  Your token bucket math, incidentally, is wrong.  The easiest way to see this 
|  > |  is to note that, according to your math, ANY token bucket filter attempting to 
|  > |  limit the average output rate would have to have n = 0, making TBFs useless. 
|  > |  The critical error is in assuming that a TBF allows "s * (n + R * rho)" bytes 
|  > |  to be sent in a period R.  This is not right; a TBF allows a maximum of s * R 
|  > |  * rho per longer-term period R; that's the point.  A token bucket filter 
|  > |  allows only SHORT-term bursts to compensate for earlier slow periods.  Which 
|  > |  is exactly what we need.
|  > Please take another look. The formula is correct (you will find the same one e.g in Andrew
|  > Tanenbaum's book). 
|  
|  So I assume what you are referring to is the clause "average rate OVER ONE 
|  RTT"?  Sorry I missed that.  I missed it because it is not TFRC's goal.  Can 
|  you point to the section in RFC3448 or RFC4342 that prohibits a TFRC sender 
|  from ever sending a (transient) rate more than X over one RTT?  RFC3448 4.6 
|  allows burstiness much more than a single packet, and the intro allows 
|  fluctuations of up to a factor of 2 relative to the fair rate
|  
|  > I think (with regard to the paragraph below) that your perspective is an entirely different one,
|  > namely to solve the question "which kind of token bucket do we need to obtain an a rate which
|  > is on average consistent with X". 
|  
|  That is *TFRC's* perspective: finding packet sends that on average are 
|  consistent with X.  As demonstrated by 4.6 and elsewhere
|  
|  How much above X may an application transiently send?  The intro would argue 2x.
|  
|  > But until this is truly resolved I want this patch in.
|  
|  Fine, I disagree, Ian disagrees (as far as I read its messages).  You are 
|  fixing one problem and creating another: artificially low send rates
|  
|  Eddie
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
