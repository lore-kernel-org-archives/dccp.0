From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Fri, 05 Jan 2007 21:38:33 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <459EC559.60501@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit

Chapter and verse, all from RFC 3448.

5.4: "When calculating the average loss interval we need to decide whether
    to include the interval since the most recent packet loss event.  We
    only do this if it is sufficiently large to increase the average loss
    interval."

    => If the time since the last loss interval will increase the average 
loss interval, then it should be included.
    => Note that the time since the last loss interval will increase on every 
successful packet receipt.
    => Therefore we may need to recalculate the average loss interval after 
every successful packet receipt (or, at the sender, on every feedback packet).

5.4: "I_0 being the interval since the most recent loss event"

    => I_0 is the time since the last loss interval.

5.5: "As described in Section 5.4 the average loss interval is calculated
    using the n previous loss intervals I_1, ..., I_n, and the interval
    I_0 that represents the number of packets received since the last
    loss event."

    => thus I_0 means the same thing in 5.4 and 5.5

5.5: "I_0 [is] the number of packets received since the last loss event"

    => yet another way to say the same thing

5.5: "Note that with each new packet arrival, I_0 will increase further"

    => YET ANOTHER way to say the same thing.

In summary
- I_0 is the interval since the most recent loss event
- I_0 increases with every packet received
- The average loss interval calculation depends on I_0
- The average loss interval should be recalculated whenever I_0 changes
- I_0 changes with every packet received
- What more can I say here?????
- All of this average loss interval calculation applies equally to sender and 
receiver; it is in section 5, a general section on "calculating loss event 
rate"; and as the intro to section 5 says, "Loss rate measurement is performed 
at the receiver"

Ian's patch is NOT experimental; Ian is attempting to implement standard 
compliant behavior; Ian's change is documented in the RFCs; etc.; etc.; etc.

Can we put this to bed?

If you still don't understand, please be clearer about why not.

Eddie




Gerrit Renker wrote:
> |  Um, you misunderstand.  The problem that Ian's patch addresses seems 
> |  entirely within the purview of RFC 3448/4342.  He is not trying to 
> |  innovate.  Recalculating the loss rate after a longer period of non-loss 
> |  is NOT EXPERIMENTAL it is REQUIRED.  The loss event rate is NOT 
> |  calculated ONLY when losses are detected.  It must be calculated on 
> |  every feedback packet.  I don't have time at the moment to look up 
> |  chapter and verse, maybe later.
> Please take another look at the patch: what you are saying is true but applies to the _sender_, but Ian's
> code is entirely within the _receiver_. We are not at 4342 yet, at the moment the receiver calculates
> the loss event rate and then contacts the receiver.
> 
> Can you please look up chapter and verse -- I have read all related documents and can only identify
> section 5.4 of RFC 3448. With regard to this, we are in agreement: this needs to be audited to be conform.
> 
> But with regard to recalculating the loss rate after a longer period of non-loss: 
> 
>  => either there is indeed a reference for this in the current RFCs (it is not [RFC 3448, 5.4] and not the
>      corresponding section in 3448bis) but then neither Ian nor I have found this
> 
>  => or there is no such reference and then we should clearly separate the issues into (a) making sure that
>      the code complies to [RFC 3448, 5.4] and (b) what do we do with the "recalculating the loss rate after
>      a longer period of non-loss" ?
> 
> 
> |  I think (for what it's worth) his patch should be accepted as is, and 
> |  maybe he, or someone, will simplify the recalc_recalcloss part later.
> I agree with the points you raised, but disagree with adding an experimental part. The reason is that
> the CCID 3 module is still seriously broken:
> 
> 	* from the output of dccp_probe one can see that the entire system is oscillating and not
>           reaching a stable fixed point; even under ideal, non-loss conditions
>         * the behaviour using tools such as iperf is unpredictable
>         * performance is very poor: sometimes, on a good day one gets 50% of the bandwidth, but at other
>           test runs the speed goes down to only a couple of Mbits/sec (and this with a loss rate of 0)
> 
> Therefore my suggestion is for the moment to only put in changes which are documented in the RFCs, fix
> all these bugs, and add everything else once the basic problems have been sorted out.
