From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 08 Feb 2007 01:47:22 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <5640c7e00702071747g67eef8b3u381fdd481a90ee3@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/8/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> >> - ccid3_hc_tx_send_packet should return a value that is measured in
> >> MICROSECONDS not milliseconds.  It also sounds like there is a
> >> rounding error
> >> in step 3a); it should probably return (delay + 500)/1000 at least.
> >>
> > This is used to set a timer to know when to wake up again which is
> > valid to be in msecs. We don't want to be firing interrupts in usec
> > intervals as too intensive and that's why you have t_gran there.
>
> You want it to return microseconds precisely so you can distinguish between
> cases that require a timer and cases that require something lighterweight,
> like a simple rescheduling.  If you pre-truncate the information to
> millisecond granularity there's no way to distinguish between "send NOW" and
> "send pretty soon but not now".  Just divide by 1000 when you actually
> schedule the timer.
>
I'm not sure about this. If you reschedule you've got no guarantee
when you get your next timeslice. I also think that timers probably
aren't that heavy in Linux as it probably weights the scheduler. If
you ask for something 5 msecs in future you are guaranteed it won't go
off before then but sometime after..

Probably one to test some time but I can't see this affecting things
too much and bigger bugs to fry at present probably. But certainly
worth checking at some point.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
