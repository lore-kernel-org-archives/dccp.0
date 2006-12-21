From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 21 Dec 2006 22:48:46 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <5640c7e00612211448y6062589fj4a651a4a9ef09202@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit,

Comments inline.

On 12/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  This works out when to recalculate the loss rate due to significant
> |  non-loss interval. We do this at time of recalulating loss rate to save
> |  having to do it every packet. Instead we just check if it's time to
> |  recalculate. It looked like there was an early attempt to do this but it
> |  was quite wrong in its implementation.
> |
> |  This is making the code conform to RFC 3448, section 5.4
> I think there is a big misunderstanding here and the existing code, as far as I can see,
> already conforms to [RFC 3448, 5.4].
>
> I got alerted when I re-read the following comment:
>  /* This code implements the part of section 5.4 of RFC3448 which says we should
>   * recalculate the average loss interval if we have a sufficient long loss
>   * interval.
> There is no such statement in RFC 3448, 5.4. The most close to this is
>   "When calculating the average loss interval we need to decide whether
>    to include the interval since the most recent packet loss event.  We
>    only do this if it is sufficiently large to increase the average loss
>    interval."

The RFC is a little confusing but I think I have carried out it's
intention correctly. I'll quote verbatim here the relevant parts:

   When calculating the average loss interval we need to decide whether
   to include the interval since the most recent packet loss event.  We
   only do this if it is sufficiently large to increase the average loss
   interval.

   Thus if the most recent loss intervals are I_0 to I_n, with I_0 being
   the interval since the most recent loss event, then we calculate the
   average loss interval I_mean as:

Notice here the "interval since the most recent packet loss event".
This implies (but would help if explicit) that this is an interval
with no loss. We only use if it would increase the average.

Backing up my implications is that we have intervals from I_0 to I_n
which is actually n+1 intervals so therefore I read I_0 to be the
interval of non-loss. Does this help? Once you see that it all falls
into place.

> If you mean this, then the patch is not necessary. The reason is that this statement
> refers to I_tot0 versus I_tot1. The statement
>
>   I_tot = max(I_tot0, I_tot1);
>
> takes care of using the `interval since the most recent packet loss event' only if
> it is sufficiently large. It is not explicit to see, but is implicitly contained in the
> way the two weighted averages are compared against each other: it boils down to
> comparing I_0 against the oldest 5 loss intervals.
>
> [ For a more detailed explanation, cf. the MSc thesis by Widmer, I also have a set of
>   notes on this case ]
>
I didn't mean that but someone had tried to implement it and had done
it incorrectly. The intent as I read is not to compare the calculation
with and without the most recent loss interval but to compare with and
without the non-loss interval.

The implementation in the kernel, which was wrong logic, also had
wrong implementation! The code was taken over from FreeBSD (relicensed
under GPL) and we actually didn't analyse properly and were excluding
the wrong item from the loop as linked lists ran the opposite
direction in FreeBSD to Linux in this case!!

> Hence the recalculation is taken care of already, by the way I_tot0/1 are used.
>
> I have had some more time looking at the patch, and it seems a performance-booster, I don't
> understand why it is there, and I can find no support in the RFCs for it. As far as I can see,
> it is non-standard.

I believe it is standard as per earlier. It does boost performance but
correctly so. Search the archives for Burak and you will see what it
solves. It is particularly applicable to links like satellite with
fixed bandwidth. Think about say a 128 Kbits link and you get a loss
when you are at 40 Kbits per second. If you get no more loss then you
can never achieve your link speed as i_mean is not recalculated.

>
> Can you please tell me what the intention is - I think that there may be a better solution
> to recalculating p when, for a longer time, there has been no loss. I'd be more than willing to
> help with this, but I would like to avoid using non-standard solutions.
>
See above.

>
> |  +            if (new_interval < 150)
> |  +                    recalc_interval = new_interval + 1;
> |  +            else
> |  +                    recalc_interval = (new_interval *
> |  +                    (DCCP_RECALC_LOSS_FACTOR+1)) / DCCP_RECALC_LOSS_FACTOR;
> If DCCP_RECALC_LOSS_FACTOR is a constant,
>  * why is  150 not? and
>  * why was 150 chosen here?
>
I should put this in a constant and document. Basically if you do the
maths and check the rounding then anything less than 150 will give you
a result of 0 but we want a minimum of 1. This just saves doing a
multiply and a divide and my guess is that a compare is a relatively
cheap operation to save on the following two operations. Saying this I
haven't profiled it.

> |  + * Given that i_mean = weighted average of loss then we can say that
> |  + * 4*n + 4*i[0] + 4*i[1] + 4*i[2] + 3*i[3] + 2*i[4] + i[5] + i[6] > |  + *  y*(4*i[0] + 4*i[i] + 4*i[2] + 4*i[3] + 3*i[4]+ 2*i[5] + i[6] + i[7])
>                       ^
>                       i[1]
> |  + *
> |  + * where y is a factor so that we don't check as soon as we hit average
> |  + * interval and waste CPU cycles needlessly. n is the non-loss interval
> |  + * and i[x] are the loss intervals. We don't need to divide by the sum
> |  + * of the weighting as these cancel out on each side.
> |  + *
> |  + * We can solve for this equation for n which yields:
> |  + * n > |  + *  ((4*i[0] + 4*i[1] + 4*i[2] + 4*i[3] + 3*i[4]+ 2*i[5] + i[6] + i[7])/4) -
> |  + *  (y*(4*i[0] + 4*i[1] + 4*i[2] + 3*i[3] + 2*i[4] + i[5] + i[6])/4) */
> |  +
> I can not at the moment say what this does - is your intention to compare I_tot0 and I_tot1?
> It seems this is something new, and it would make sense to communicate the idea to the 3448bis
> authors (and discuss this with them), maybe this is a new solution and has merit.
>
All this is is a method of not having to call calc_i_mean for EVERY
packet which would be very expensive on CPU. It is new but is a very
simple mathematical solution to detect when the change is big enough,
so once again you do a compare on each packet rather than a whole lot
of multiplies/divides. It isn't going beyond the RFC really at all -
just a clever implementation I like to think :-)

> What I know of 3448/3448bis however, is that the code presented therein resulted
> from several years of intensive ns-2 testing as well as practical experiments.
> With that, I think 3448/3448bis should be given preference when it comes to implementing.
>

Agree and believe I have done so. I have tested myself in quite a few
different cases. This took me quite a large number of hours to work
this patch out.
>
> |  --- a/net/dccp/dccp.h
> |  +++ b/net/dccp/dccp.h
> |  @@ -80,6 +80,11 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
> |
> |   #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
> |
> |  +/* Value as a reciprocal to check for change in loss through long
> |  + * non-loss intervals. If you change this you must recheck existing
> |  + * code for overflow possibilities */
> |  +#define DCCP_RECALC_LOSS_FACTOR 100
> |  +
> I have a quibble with this one: it is a CCID3 variable (not used in the global DCCP code),
> it would be better to rename it into CCID3_RECALC_LOSS_FACTOR and put it into ccid3.h
>
No problem. Will change the location.

Ian
-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
