From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Wed, 11 Apr 2007 15:43:56 +0000
Subject: Re: [PATCH 2/25]: Avoid accumulation of large send credit
Message-Id: <461D023C.8020703@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.12007@strip-the-willow>
In-Reply-To: <200703211844.12007@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> Quoting Eddie Kohler:
> |  > Fix:
> |  > ----
> |  >  Avoid any backlog of sending time which is greater than one whole t_ipi. This
> |  >  permits the coarse-granularity bursts mentioned in [RFC 3448, 4.6], but disallows
> |  >  the disproportionally large bursts.
> |  
> |  Actually this does not permit coarse granularity bursts, since it limits 
> |  the maximum burst size to 2 packets.  That is not sufficient for high 
> |  rates and medium-to-low granularities and it is far stricter than TCP.
> |  
> The comment affects the commit message. I can change that if you like.

Yes, that would be the right thing to do.

> With regard to the
> remainder:
> 
> First is the issue with TCP. As shown below, increasing the allowed lag beyond one full 
> t_ipi will effectively increase the sending rate beyond the allowed rate X; which 
> means that the sender sends more per RTT than it is allowed by the throughput equation. 

The RFC3448/RFC4342 credit mechanism simply does not allow long-term rates 
greater than X (once you fix the problem with idle periods).

> And these will accrue for the simple reason that a t_ipi of 1.6 milliseconds becomes 1 millisecond,
> and a t_ipi of 0.9 milliseconds becomes 0 milliseconds. 

You do not mean that DCCP calculates a t_ipi of 0 milliseconds, do you???  The 
RFCs assume that t_ipi is kept in *precise* units, not units of jiffies or 
what-have-you.  t_gran might be greater than t_ipi.

> There is no way to stop a Linux CCID3 sender from ramping X up to the link bandwidth of 1 Gbit/sec;
> but the scheduler can only control packet pacing up to a rate of s * HZ bytes per second.
> Therefore, if we allow slack in the scheduling lag, the bursts on such systems as use
> Gbit or even 10-Gbit ethernet cards will become astronomically large. It is thus safer to choose the
> more restrictive value. Of course, a regrettable compromise. But to do the scheduling right _and_
> safe requires real-time extensions or busy-wait threads (not sure that they will find much favour). 
> The same topic has been discussed several times over on this mailing list. 

I agree that massive bursts are undesirable, but NO bursts is too restrictive.

Your token bucket math, incidentally, is wrong.  The easiest way to see this 
is to note that, according to your math, ANY token bucket filter attempting to 
limit the average output rate would have to have n = 0, making TBFs useless. 
The critical error is in assuming that a TBF allows "s * (n + R * rho)" bytes 
to be sent in a period R.  This is not right; a TBF allows a maximum of s * R 
* rho per longer-term period R; that's the point.  A token bucket filter 
allows only SHORT-term bursts to compensate for earlier slow periods.  Which 
is exactly what we need.

As part of the work on RFC3448bis we are trying to define the best maximum 
credit accumulation.  We are currently thinking R (one RTT), although feedback 
is welcome.  This is much better than t_gran, I think, and will limit 
burstiness a great deal in practice, where most fast connections have very 
short RTTs.  But the credit accumulation in RFC3448bis WILL be explicit, it 
WILL be a normative upper bound, and it certainly won't be zero.

Eddie



> C o n c l u s i o n :
> ==========> The patch fixes a serious problem which will occur in any application using CCID3, due to
> realistically possible conditions such as
> 
>  * a low sending rate and/or
>  * silence periods and/or
>  * scheduling inaccuracies (as described above).
> 
> I therefore still want it in!
> 
> 
> 
> |  
> |  >  D e t a i l e d   J u s t i f i c a t i o n   [not commit message]
> |  >  ------------------------------------------------------------------
> |  >  Let t_nom < t_now be such that t_now = t_nom + n*t_ipi + t_r, where
> |  >  n is a natural number and t_r < t_ipi. Then 
> |  >  
> |  >  	t_nom - t_now = - (n*t_ipi + t_r)
> |  >  
> |  >  First consider n=0: the current packet is sent immediately, and for
> |  >  the next one the send time is
> |  >  	
> |  >  	t_nom'  =  t_nom + t_ipi  =  t_now + (t_ipi - t_r)
> |  >  
> |  >  Thus the next packet is sent t_r time units earlier. The result is
> |  >  burstier traffic, as the inter-packet spacing is reduced; this 
> |  >  burstiness is mentioned by [RFC 3448, 4.6]. 
> |  >  
> |  >  Now consider n=1. This case is illustrated below
> |  >  
> |  >  	|<----- t_ipi -------->|<-- t_r -->|
> |  >  
> |  >  	|----------------------|-----------|
> |  >  	t_nom                              t_now
> |  >  
> |  >  Not only can the next packet be sent t_r time units earlier, a third
> |  >  packet can additionally be sent at the same time. 
> |  >  
> |  >  This case can be generalised in that the packet scheduling mechanism
> |  >  now acts as a Token Bucket Filter whose bucket size equals n: when
> |  >  n=0, a packet can only be sent when the next token arrives. When n>0,
> |  >  a burst of n packets can be sent immediately in addition to the tokens
> |  >  which arrive with rate rho = 1/t_ipi.
> |  >  
> |  >  The aim of CCID 3 is an on average smooth traffic with allowed sending
> |  >  rate X. The following determines the required bucket size n for the 
> |  >  purpose of achieving, over the period of one RTT R, an average allowed
> |  >  sending rate X.
> |  >  The number of bytes sent during this period is X*R. Tokens arrive with
> |  >  rate rho at the bucket, whose size n shall be determined now. Over the
> |  >  period of R, the TBF allows s * (n + R * rho) bytes to be sent, since
> |  >  each token represents a packet of size s. Hence we have the equation
> |  >  
> |  >  		s * (n + R * rho) = X * R
> |  >  	<=>	n + R/t_ipi	  = X/s * R = R / t_ipi
> |  >  
> |  >  which shows that n must be 0. Hence we can not allow a `credit' of
> |  >  t_nom - t_now > t_ipi time units to accrue in the packet scheduling.
> |  > 
> |  > 
> |  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> |  > ---
> |  >  net/dccp/ccids/ccid3.c |   12 ++++++++++--
> |  >  1 file changed, 10 insertions(+), 2 deletions(-)
> |  > 
> |  > --- a/net/dccp/ccids/ccid3.c
> |  > +++ b/net/dccp/ccids/ccid3.c
> |  > @@ -362,7 +362,15 @@ static int ccid3_hc_tx_send_packet(struc
> |  >  	case TFRC_SSTATE_NO_FBACK:
> |  >  	case TFRC_SSTATE_FBACK:
> |  >  		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
> |  > -		ccid3_pr_debug("delay=%ld\n", (long)delay);
> |  > +		/*
> |  > +		 * Lagging behind for more than a full t_ipi: when this occurs,
> |  > +		 * a send credit accrues which causes packet storms, violating
> |  > +		 * even the average allowed sending rate. This case happens if
> |  > +		 * the application idles for some time, or if it emits packets
> |  > +		 * at a rate smaller than X/s. Avoid such accumulation.
> |  > +		 */
> |  > +		if (delay + (suseconds_t)hctx->ccid3hctx_t_ipi  <  0)
> |  > +			hctx->ccid3hctx_t_nom = now;
> |  >  		/*
> |  >  		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
> |  >  		 *
> |  > @@ -371,7 +379,7 @@ static int ccid3_hc_tx_send_packet(struc
> |  >  		 * else
> |  >  		 *       // send the packet in (t_nom - t_now) milliseconds.
> |  >  		 */
> |  > -		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
> |  > +		else if (delay - (suseconds_t)hctx->ccid3hctx_delta  >=  0)
> |  >  			return delay / 1000L;
> |  >  
> |  >  		ccid3_hc_tx_update_win_count(hctx, &now);
> |  > -
> |  > To unsubscribe from this list: send the line "unsubscribe dccp" in
> |  > the body of a message to majordomo@vger.kernel.org
> |  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> |  
> |  
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
