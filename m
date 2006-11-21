From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 21 Nov 2006 17:54:32 +0000
Subject: Re: [PATCH 1/6]: Fix bug in calculation of first t_nom and first t_ipi
Message-Id: <5640c7e00611210954u6257b8bdw751ad37a138645d9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.07412@strip-the-willow>
In-Reply-To: <200611211545.07412@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Looks good in theory. Will check some more. Have you double checked
against RFC4342 as that overrides parts of RFC 3448 (see section 5 in
particular)?

Ian

On 11/22/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [DCCP]: Fix bug in calculation of first t_nom and first t_ipi
>
> Problem:
> --------
>  Currently the inter-packet-interval for the first packet is set to 500msec instead
>  of the 1 second specified in RFC 3448 (detailed derivation below).
>  Furthermore, the code is complicated, since t_ipi is, in fact, added twice to t_0 = t_now.
>
> Solution:
> ---------
>  This patch
>         * sets the initial value of t_ipi to 1 second, as per RFC 3448
>         * simplifies the initial setting of t_ipi and t_delta through a case analysis
>
>
> Detailed Derivation:
> --------------------
>  When the first CCID 3 packet is sent in ccid3_hc_tx_send_packet, t_ipi is set to
>
>                 hctx->ccid3hctx_t_ipi = TFRC_INITIAL_IPI;
>
>  which is USEC_PER_SEC / 4 = 250 msec. This is then added twice to t_0, due to:
>
>         case TFRC_SSTATE_NO_SENT:
>                 // ...
>                 /* Set nominal send time for initial packet */
>                 hctx->ccid3hctx_t_nom = now;
>                 timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
>                 rc = 0;
>                 break;
>         // ...
>         /* Can we send? if so add options and add to packet history */
>         if (rc = 0) {
>                 // ...
>                 timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
>         }
>
>  As a result, t_1 = t_0 + t_ipi = t_now + t_ipi
>                   = t_0 + 500msec
>
>  This contradicts RFC 3448, due to the following requirements:
>
>   a) Section 4.2, "Sender Initialization"
>      "the value of X[/s] is set to 1 packet/second [...] The
>       initial values for R (RTT) and t_RTO are undefined"
>
>   b) Section 4.5, "Preventing Oscillations
>      R_sqmean is undefined since R is undefined
>      Therefore, X_init = X
>
>   c) Section 4.6, "Scheduling of Packet Transmissions"
>
>      t_ipi = X_init / s = 1 second
>
>  A further simplification is possible for the initial `delta' value, which is
>  defined in [RFC 3448, section 4.6] as
>
>         t_delta = min(t_ipi/2, t_gran/2)
>
>  t_gran/2 here is TFRC_OPSYS_HALF_TIME_GRAN = USEC_PER_SEC / (2 * HZ).
>  Since Linux always schedules with a higher granularity than 1 second,
>  the initial value of t_delta is thus simply
>
>         t_delta = min(USEC_PER_SEC / 2 , USEC_PER_SEC / (2 * HZ))
>                 =  USEC_PER_SEC / (2 * HZ)
>
>  Lastly, TFRC_INITIAL_IPI is not referenced anywhere else and can thus be removed.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
