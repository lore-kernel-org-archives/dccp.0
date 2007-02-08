From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 08 Feb 2007 01:13:55 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <5640c7e00702071713j233f22d9vcab9c7565a0e7d99@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 2/8/07, Eddie Kohler <kohler@cs.ucla.edu> wrote:
> I have some minor thoughts relating to this.
>
> - In what units are t_nom kept?  I would hope microseconds at least, not
> milliseconds.  You say "dccps_xmit_timer is reset to expire in t_now + rc
> milliseconds"; I assume you mean that the value t_now + rc is cast to
> milliseconds.  Clearly high rates will require that t_nom be kept in
> microseconds at least.

It's definitely microseconds. Nearly all critical stuff such as t_nom,
t_ipi, rtt are calculated in usecs. Early on some code was attempted
to be run as msecs and it was a disaster.

But t_nom wouldn't matter if it was msecs in this case as you send
packets up to t_nom and then set a timer. If there was a backlog
they'd get sent next time and as you say takes way less than 1ms to
send a packet.

>
> I wonder because you say:
>
> >  -> assume that t_ipi is less than 1 millisecond, then in effect all packets are
> >     sent immediately; hence we have a _continuous_ burst of packets
>
> but this does not follow.  If t_ipi<1ms, but is non-zero, then at most 1ms
> worth of packets can be sent in a burst -- not continuous (assuming it takes
> way less than 1ms to send a packet).
>
> - ccid3_hc_tx_send_packet should return a value that is measured in
> MICROSECONDS not milliseconds.  It also sounds like there is a rounding error
> in step 3a); it should probably return (delay + 500)/1000 at least.
>
This is used to set a timer to know when to wake up again which is
valid to be in msecs. We don't want to be firing interrupts in usec
intervals as too intensive and that's why you have t_gran there.

> - What if the delay till the next packet is >0 but <HZ?  It sounds like that
> case is causing the problem.  One answer: Do not schedule a TIMER; instead,
> leave a kernel thread or bottom half scheduled, so that the next time the
> kernel runs, it will poll DCCP, even if that is before 1HZ from now.
>
Might have a look at that but it's not affecting me right now - more
Gerrit's area.

> Make sense?
> Eddie
>
>
-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
