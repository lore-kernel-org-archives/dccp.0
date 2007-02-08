From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 08 Feb 2007 05:50:35 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <45CABA2B.80503@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> You want it to return microseconds precisely so you can distinguish 
>> between
>> cases that require a timer and cases that require something 
>> lighterweight,
>> like a simple rescheduling.  If you pre-truncate the information to
>> millisecond granularity there's no way to distinguish between "send 
>> NOW" and
>> "send pretty soon but not now".  Just divide by 1000 when you actually
>> schedule the timer.
>>
> I'm not sure about this. If you reschedule you've got no guarantee
> when you get your next timeslice.

You've got no GUARANTEE of when you get your next timeslice, but in most 
cases it will be soon.  As opposed to scheduling a timer 1ms in the 
future, where you KNOW you won't run for 1ms, as you say.

Gerrit's problem is burstiness at the level of milliseconds.  The only 
way to solve this is to run at sub-millisecond granularity.  Use hi-res 
timers, or easier, use existing mechanisms for running code frequently: 
i.e., leaving the code runnable.

Eddie


> I also think that timers probably
> aren't that heavy in Linux as it probably weights the scheduler. If
> you ask for something 5 msecs in future you are guaranteed it won't go
> off before then but sometime after..
> 
> Probably one to test some time but I can't see this affecting things
> too much and bigger bugs to fry at present probably. But certainly
> worth checking at some point.
> 
> Ian
