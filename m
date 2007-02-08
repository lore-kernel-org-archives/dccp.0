From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 08 Feb 2007 01:23:13 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <45CA7B81.10003@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>> - ccid3_hc_tx_send_packet should return a value that is measured in
>> MICROSECONDS not milliseconds.  It also sounds like there is a 
>> rounding error
>> in step 3a); it should probably return (delay + 500)/1000 at least.
>>
> This is used to set a timer to know when to wake up again which is
> valid to be in msecs. We don't want to be firing interrupts in usec
> intervals as too intensive and that's why you have t_gran there.

You want it to return microseconds precisely so you can distinguish between 
cases that require a timer and cases that require something lighterweight, 
like a simple rescheduling.  If you pre-truncate the information to 
millisecond granularity there's no way to distinguish between "send NOW" and 
"send pretty soon but not now".  Just divide by 1000 when you actually 
schedule the timer.

E


> 
>> - What if the delay till the next packet is >0 but <HZ?  It sounds 
>> like that
>> case is causing the problem.  One answer: Do not schedule a TIMER; 
>> instead,
>> leave a kernel thread or bottom half scheduled, so that the next time the
>> kernel runs, it will poll DCCP, even if that is before 1HZ from now.
>>
> Might have a look at that but it's not affecting me right now - more
> Gerrit's area.
> 
>> Make sense?
>> Eddie
>>
>>
