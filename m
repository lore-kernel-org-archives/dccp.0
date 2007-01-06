From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Sat, 06 Jan 2007 20:36:38 +0000
Subject: Re: [PATCH 4/4] DCCP: Recalculate t_nom on change of t_ipi
Message-Id: <5640c7e00701061236n6cb6cc7fha5d2bc1594d51bdb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612281708.38935.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612281708.38935.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 1/4/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> Ian is right that there is a problem, but this fixes one symptom, but there are
> two causes, which are not resolved by this patch:
>
>  (1) t_nom becoming negative is caused by tardiness in packet scheduling
>      and therefore it should be resolved at the location which deals with packet
>      sending (ccid3_hc_tx_send_packet), and not in ccid3_update_send_time()
>
I thought my solution was better. I originally implemented the same
solution as you and then realised this point 1 you discuss. But it
should be negative in these cases as per RFC 3448 4.6

When a sender first starts sending at time t_0, it calculates t_ipi,
   and calculates a nominal send time t_1 = t_0 + t_ipi for packet 1.
   When the application becomes idle, it checks the current time, t_now,
   and then requests re-scheduling after (t_ipi - (t_now - t_0))
   seconds.  When the application is re-scheduled, it checks the current
   time, t_now, again.  If (t_now > t_1 - delta) then packet 1 is sent.

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

Note there that several packets can be sent in bursts. Your code stops
this and slows transmit down quite a lot.

However I think now my solution is not perfect. What I was trying to
work around and fix was that the t_ipi gets altered down from 1
second.

However thinking about it some more we are doing this the wrong way
altogether and should do it in the sending loop ONLY as per the
suggestion (not requirement) at the top of section 4.6

   As TFRC is rate-based, and as operating systems typically cannot
   schedule events precisely, it is necessary to be opportunistic about
   sending data packets so that the correct average rate is maintained
   despite the course-grain or irregular scheduling of the operating
   system.  Thus a typical sending loop will calculate the correct
   inter-packet interval, t_ipi, as follows:

        t_ipi = s/X_inst;

The special case that we need to deal with is this one from section 5
of RFC4342:
   [RFC3448], Section 4, specifies an initial sending rate of one packet
   per round-trip time (RTT) as follows: The sender initializes the
   allowed sending rate to one packet per second.  As soon as a feedback
   packet is received from the receiver, the sender has a measurement of
   the round-trip time and then sets the initial allowed sending rate to
   one packet per RTT.

>  (2) Using this routine carries with it a race condition: several functions
>      (ccid3_hc_tx_send_packet, this routine, ccid3_hc_tx_update_x, ccid3_hc_tx_packet_recv)
>      have asynchronous, concurrent read-write access to t_nom.
>
> Please see earlier discussion on `tardiness bug' and the detailed analysis provided with
> the `race condition' patch.
>
I think that rewriting this code as per point 1 will eliminate this
problem provided we do it properly.

So the short answer is we both made improvements but we've both got it
not quite right and we need to revise again.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
