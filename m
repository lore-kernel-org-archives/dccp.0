From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 13 Apr 2007 23:43:40 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <462015AC.10909@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

This might work, but I'd need to work it through.

The fact is that ALL TCP-like algorithms have rates that are inversely 
proportional to the RTT.  But in TCP and windowed protocols this happens 
naturally due to ack clocking.  In CCID3, there's no ack clocking.  Acks 
arrive much more seldom -- down to once per RTT, rather than once per 2 
packets.  Thus the RTT measurement is EXPLICITLY fed in to the throughput 
equation.  In TCP the RTT measurement mostly just feeds in to the RTO, which 
is why the protocol's behavior is less sensitive to the measurement.

DCCP *MIGHT* work just fine with the inflated RTT measurements (i.e. the RTT 
including IP processing) but there is yet another gerrit missive to work 
through to see how real that complaint is.

A less aggressive version of "turn off RTT for LANs" would be simply to 
subtract an estimate of the IP<->card path's cost from the measured coarse 
RTT.  This would fix the problem.  If you used a stable minimum estimate, the 
RTT would naturally "inflate" when the host was busy, which as Ian points out 
is what we actually want.  How to obtain an estimate?  Probably anything would 
do, including something derived at boot time from BogoMIPS.

-*-

As for coarse-grained timers, does DCCP CCID3 *only* send packets at timer 
granularity?  This would differ from TCP which sends packets as acks arrive. 
It should be relatively easy in CCID3 to likewise try to send packets as acks 
arrive.  There are fewer acks, of course, but still on LANs where RTT << 
timer_granularity this would reduce burstiness.  (All assuming CCID3 doesn't 
do this already.)

Eddie


David Miller wrote:
> From: Eddie Kohler <kohler@cs.ucla.edu>
> Date: Fri, 13 Apr 2007 13:37:57 -0700
> 
>> Gerrit.  I know the implementation is broken for high rates.  But you are 
>> saying that it is impossible to implement CCID3 congestion control at high 
>> rates.  I am not convinced.  Among other things, CCID3's t_gran section gives 
>> the implementation EXACTLY the flexibility required to smoothly transition 
>> from a purely rate-based, packet-at-a-time sending algorithm to a hybrid 
>> algorithm where periodic bursts provide a rate that is on average X.
>>
>> Your examples repeatedly demonstrate that the current implementation is 
>> broken.  Cool.
>>
>> If you were to just say this was an interim fix it would be easier, but I'd 
>> still be confused, since fixing tihs issue does not seem hard.  Just limit the 
>> accumulated send credit to something greater than 0, such as the RTT.
> 
> Eddie, this is an interesting idea, but would you be amicable to the
> suggestion I made in another email?  Basically if RTT is extremely
> low, don't do any of this limiting.
> 
> What sense is there to doing any of this for very low RTTs?  It is
> a very honest question.
> 
> If we hit some congestion in a switch on the local network, responding
> to that signal is pointless because the congestion event will pass
> before we even get the feedback showing us that there was congestion
> in the first place.
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
