From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Mon, 27 Nov 2006 16:03:36 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first
Message-Id: <456B0C58.3060302@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Gerrit, Ian,

I am not sure I am completely following this discussion, but there is one 
point I wanted to bring up.  DCCP senders DO have an estimate of the 
round-trip time even BEFORE the first feedback packet, namely from the 
Request-Response exchange.  RFC 4342 senders and receivers can use the RTT 
measured by the core DCCP protocol.  Reading over RFC 4342, this is extremely 
not clear (sorry), but it was our intention.  (Sally, this is right, yes?)  We 
will put together an erratum for the RFC Editor.

Eddie


Gerrit Renker wrote:
> Quoting Ian McDonald:
> |  Looks good in theory. Will check some more. Have you double checked
> |  against RFC4342 as that overrides parts of RFC 3448 (see section 5 in
> |  particular)?
> You are right to raise this, thank you.
> 
> I have checked the patch against both RFC 3448 and 4342: what this patch does is fully
> standards-compliant; I copy the relevant references below.
> 
>   1) [RFC 3448, 4.2] emphasizes that the values of R (RTT) and t_RTO are undefined
>      until the first feedback packet arrives.
> 
>   2) The relevant section of RFC 4342 is on page 6:
> 
>      "[RFC3448], Section 4, specifies an initial sending rate of one packet
>       per round-trip time (RTT) as follows: The sender initializes the
>       allowed sending rate to one packet per second.As soon as a feedback
>       packet is received from the receiver, the sender has a measurement of
>       the round-trip time and then sets the initial allowed sending rate to
>       one packet per RTT."
> 
>      It then goes on and changes the RFC 3448 recommendation of an initial sending rate
>      of 1 packet per RTT to 2..4 packets per RTT depending on the packet size.
> 
>     => These are all issues which are not applicable until the first feedback has arrived.
> 
>   3) Further below, on [RFC 4342, page 7] we have the following clarification:
> 
>      "If the sender never receives a feedback packet from the receiver, and
>       as a consequence never gets to set the allowed sending rate to one
>       packet per RTT, then the sending rate is left at its initial rate of
>       one packet per second, [...]"
> 
> 
> Conclusion
> ----------
>   The relevant parts of RFC 4342 which override RFC 3448 are of no concern for this patch,
>   since these are not applicable until the first feedback packet has arrived. As a consequence,
>   this patch fully conforms to both RFC 3448 (as presented in detail below) and RFC 4342. 
>   The patch submission therefore stands as before.
> 
>   However, I think your point is valid and we should add a ToDo for that section
>   of code which re-adjusts the sending rate after the first feedback packet has arrived. 
>    
> Thank you
> Gerrit  
> 
> |  
> |  On 11/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |  > [DCCP]: Fix bug in calculation of first t_nom and first t_ipi
> |  >
> |  > Problem:
> |  > --------
> |  >  Currently the inter-packet-interval for the first packet is set to 500msec instead
> |  >  of the 1 second specified in RFC 3448 (detailed derivation below).
> |  >  Furthermore t_ipi is added twice to t_now instead of just once.
> |  >
> |  > Solution:
> |  > ---------
> |  >  This patch
> |  >         * sets the initial value of t_ipi to 1 second, as per RFC 3448
> |  >         * simplifies the initial setting of t_ipi and t_delta through a case analysis
> |  >
> |  >
> |  > Detailed Derivation:
> |  > --------------------
> |  >  When the first CCID 3 packet is sent in ccid3_hc_tx_send_packet, t_ipi is set to
> |  >
> |  >                 hctx->ccid3hctx_t_ipi = TFRC_INITIAL_IPI;
> |  >
> |  >  which is USEC_PER_SEC / 4 = 250 msec. This is then added twice to t_0, due to:
> |  >
> |  >         case TFRC_SSTATE_NO_SENT:
> |  >                 // ...
> |  >                 /* Set nominal send time for initial packet */
> |  >                 hctx->ccid3hctx_t_nom = now;
> |  >                 timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
> |  >                 rc = 0;
> |  >                 break;
> |  >         // ...
> |  >         /* Can we send? if so add options and add to packet history */
> |  >         if (rc = 0) {
> |  >                 // ...
> |  >                 timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
> |  >         }
> |  >
> |  >  As a result, t_1 = t_0 + t_ipi = t_now + t_ipi
> |  >                   = t_0 + 500msec
> |  >
> |  >  This contradicts RFC 3448, due to the following requirements:
> |  >
> |  >   a) Section 4.2, "Sender Initialization"
> |  >      "the value of X[/s] is set to 1 packet/second [...] The
> |  >       initial values for R (RTT) and t_RTO are undefined"
> |  >
> |  >   b) Section 4.5, "Preventing Oscillations
> |  >      R_sqmean is undefined since R is undefined
> |  >      Therefore, X_init = X
> |  >
> |  >   c) Section 4.6, "Scheduling of Packet Transmissions"
> |  >
> |  >      t_ipi = X_init / s = 1 second
> |  >
> |  >  A further simplification is possible for the initial `delta' value, which is
> |  >  defined in [RFC 3448, section 4.6] as
> |  >
> |  >         t_delta = min(t_ipi/2, t_gran/2)
> |  >
> |  >  t_gran/2 here is TFRC_OPSYS_HALF_TIME_GRAN = USEC_PER_SEC / (2 * HZ).
> |  >  Since Linux always schedules with a higher granularity than 1 second,
> |  >  the initial value of t_delta is thus simply
> |  >
> |  >         t_delta = min(USEC_PER_SEC / 2 , USEC_PER_SEC / (2 * HZ))
> |  >                 =  USEC_PER_SEC / (2 * HZ)
> |  >
> |  >  Lastly, TFRC_INITIAL_IPI is not referenced anywhere else and can thus be removed.
> |  >
> |  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> |  
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
