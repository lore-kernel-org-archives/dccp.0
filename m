From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Wed, 10 Jan 2007 19:40:50 +0000
Subject: Re: [PATCH 1/1] DCCP: Fix up t_nom - FOLLOW-UP
Message-Id: <5640c7e00701101140y1d6a5ed8y12479602ee90bfec@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701101021.38920@strip-the-willow>
In-Reply-To: <200701101021.38920@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Thank you for this summary. I think that this discussion shows the
fundamental difference in our patches and therefore the fundamental
issue we need to resolve. It would be helpful if Eddie or others
throws in their 2 cents worth.

On 10/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
>                 Packet scheduling tardiness problem
>                 -----------------------------------
>
> I would like to continue discussion on your patch; I hope you are not dismayed
> about the response: this concerned only the code changes as such. I think that
> there is a valid point which you were trying to resolve.
>
I'm not dismayed at all by the response. These issues sometimes take a
lot of discussion before they go into the kernel. Look at hrtimers,
kevents, netchannels, reiser4 etc and you will see that we are a in
low number of revisions! It is far better to discuss so that we all
understand what is happening and can get the best possible solution.

> I have therefore consulted with colleagues and tried to find out why successive
> packets might be too late. This resulted in the following.
>
> (A) The granularity of the rate-based packet scheduling is too coarse
>
>     We are resolving t_ipi with microsecond granularity but the timing for the
>     delay between packets uses millisecond granularity (schedule_timeout). This
>     means we can only generate inter-packet delays in the range of 1 millisecond
>     up to 15.625 milliseconds (the largest possible inter-packet interval which
>     corresponds to 1 byte per each 64 seconds).
>
>     As a result, our range of speeds that can be influenced is:
>
>             1/64 byte per second  ....  1000 bytes per second
>
>     In all other cases, the delay will be 0 (due to integer division) and hence
>     their packet spacing solely depends on how fast the hardware can cope.
>
>     In essence, this is like a car whose accelerator works really well in the
>     range 1 meter/hour up to 2 miles per hour, and for everything else it tries
>     to use top speed of 120 mph.
>

This is correct provided you are working on the assumption of part B.
I think that this is the whole crux of the problem and why we haven't
got an agreed patch between us yet.

Rather than espouse my views directly I'll try and comment on the RFC
which is the canonical definition of what we should be doing. I've put
in the whole 4.6 section of RFC 3448 and commented inline.

4.6.  Scheduling of Packet Transmissions

   As TFRC is rate-based, and as operating systems typically cannot
   schedule events precisely, it is necessary to be opportunistic about
   sending data packets so that the correct average rate is maintained
   despite the course-grain or irregular scheduling of the operating
   system.

Note here that the requirement is not to maintain precise timing. The
requirement is to maintain the correct average rate. This was the
light that went on in my head when I was reviewing both of our
previous iterations. I believe we were coming from the wrong starting
point - we were trying to improve scheduling, not maintain the correct
rate.

   Thus a typical sending loop will calculate the correct
   inter-packet interval, t_ipi, as follows:

        t_ipi = s/X_inst;

Note here that we must calculate t_ipi by this definition. It doesn't
say whether it MUST be in sending loop (capitals deliberate as these
have special meaning) so my approach of doing in sending loop is fine
as is yours provided we pick up both changes in s and X_inst. From
memory you detect changes in X_inst and recalculate t_ipi but not for
s (although it could be other way around).

   When a sender first starts sending at time t_0, it calculates t_ipi,
   and calculates a nominal send time t_1 = t_0 + t_ipi for packet 1.
   When the application becomes idle, it checks the current time, t_now,
   and then requests re-scheduling after (t_ipi - (t_now - t_0))
   seconds.  When the application is re-scheduled, it checks the current
   time, t_now, again.  If (t_now > t_1 - delta) then packet 1 is sent.

Note that initially we set t_ipi to 1 second. This could be set to a
better value based on connection setup as per Eddie and your
discussion earlier but I haven't implemented this yet. In this way my
code is a hack that I remove the 1 second and add the initial RTT once
we obtain it. I see this ugliness can be removed when we make the code
base conform to the RFC intent (it is not in RFC yet but Eddie said he
would propose for revision)

   Now a new t_ipi may be calculated, and used to calculate a nominal
   send time t_2 for packet 2: t2 = t_1 + t_ipi.  The process then
   repeats, with each successive packet's send time being calculated
   from the nominal send time of the previous packet.

   In some cases, when the nominal send time, t_i, of the next packet is
   calculated, it may already be the case that t_now > t_i - delta.  In
   such a case the packet should be sent immediately.  Thus if the
   operating system has coarse timer granularity and the transmit rate
   is high, then TFRC may send short bursts of several packets separated
   by intervals of the OS timer granularity.

Note a couple of phrases here "the packet should be sent immediately",
"TFRC may send short bursts of several packets separated by intervals
of the OS timer granularity". This is why I don't think we should ever
reset t_nom to the current time. Doing this stops us achieving the
average rate required. With reseting t_nom what we are doing is
setting X as the maximum instantaneous rate rather than the average
rate we are trying to achieve.

   The parameter delta is to allow a degree of flexibility in the send
   time of a packet.  If the operating system has a scheduling timer
   granularity of t_gran seconds, then delta would typically be set to:

        delta = min(t_ipi/2, t_gran/2);

   t_gran is 10ms on many Unix systems.  If t_gran is not known, a value
   of 10ms can be safely assumed.

We do this properly.

>     Therefore I wonder if there is some kind of `micro/nanosleep' which we can use?
>     Did some grepping and inevitably landed in kernel/hrtimers.c - any advice on
>     how to best deploy these?
>
>     On healthy links the inter-packet times are often in the range of multiples of
>     10 microseconds (60 microseconds is frequent).
>
I don't believe we need to do this from a practical point of view as
the RFC says we aim for average packet rate rather than precise
timing. It is interesting from a research point of view whether we
achieve better results from smoother packet flow given precise timing,
and I have seen published literature on this effect. It is not
necessary for RFC compliance though.

However if you want to implement for research that is fine provided
that we satisfy a couple of criteria:
- negligible performance impact. I would have thought that hrtimer
would add to overhead a reasonable amount. Is the point of hrtimers to
achieve a large number of timers per second with low overhead or does
it allow you to precisely schedule an event at a time you precisely
require? By my calculations using CCID3 on a 1 GBits/sec link using 1
hrtimer per packet would mean around 90,000 timer fires per second vs
a maximum of 1000 timeslices if we are using standard setup and HZ of
1000. Interrupting other operations 90,000 times per second is surely
not good??
- cross platform support. I'm not sure if platforms like ARM support
hrtimers. I want to see CCID3 used across many platforms and small
embedded devices based on ARM would be a key market (your cellphone
for video calls for example).

Based on this I think hrtimer support is not needed but if it is done
then it should be an option not a requirement.

>
> (B) Fixing send time for packets which are too late
>
>     You were mentioning bursts of packets which appear to be too late. I consulted
>     with a colleague of how to fix this: the solution seems much more complicated
>     than the current infrastructure supports.
>     Suppose the TX queue length is n and the packet at the head of the queue is too
>     late. Then one would need to recompute the sending times for each packet in the
>     TX queue by taking into account the tardiness (it would not be sufficient to
>     simply drain the queue). It seems that we would need to implement a type of
>     credit-based system (e.g. like a Token Bucket Filter); in effect a kind of Qdisc
>     on layer 4.
>
> When using only a single t_nom for the next-packet-to-send as we are doing at the moment,
> resetting t_nom to t_now when packets are late seems the most sensible thing to do.
>
> So what I think we should do is fix the packet scheduling algorithm to use finer-grained
> delay. Since in practice no one really is interested in speeds of 1kbyte/sec and below,
> it in effect means that we are not controlling packet spacing at all.
>
See above.

-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
