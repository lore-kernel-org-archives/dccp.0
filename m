From: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
Date: Sun, 26 Nov 2006 17:10:00 +0000
Subject: Re: [PATCH 2/6]: Simplify control flow in the calculation of t_ipi
Message-Id: <39e6f6c70611260910o4d0ceb86r1dd53b5d11dd8d9b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200611211545.18544@strip-the-willow>
In-Reply-To: <200611211545.18544@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/21/06, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Simplify control flow in the calculation of t_ipi
>
>
> This patch performs a simplifying (performance) optimisation:
>
>  In each call of the inline function ccid3_calc_new_t_ipi(), the state is
>  tested against TFRC_SSTATE_NO_FBACK. This is expensive when the function
>  is called very often. A simpler solution, implemented by this patch, is
>  to adapt the control flow.
>
> Background:
> -----------
>  Upon sender initialisation, the values of t_ipi, t_nom = t_0, delta, as
>  well as the initial packet sending rate, are all constants [RFC 3448, 4.2].
>  Until feedback arrives, these values are not changed. Hence it is not necessary
>  to recalculate t_ipi, t_nom, delta until the first feedback has arrived, i.e.
>  as long as the state TFRC_SSTATE_NO_FBACK persists.
>
> Justification:
> --------------
>  ccid3_calc_new_t_ipi() is called only in two places:
>
>    * in ccid3_hc_tx_packet_recv(); here the state is never TFRC_SSTATE_NO_FBACK, due to
>         if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
>                 ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
>                 /* ... */
>    * in ccid3_hc_tx_packet_sent()
>
>  => Only in the second case, the state might be TFRC_SSTATE_NO_FBACK and this only
>      during the initial phase of a connection.
>
> Solution:
> ---------
>  This patch avoids such a recalculation by a simple change of control flow in
>  ccid3_hc_tx_packet_sent(). As a consequence, ccid3_calc_new_t_ipi() is never called in
>  the state TFRC_SSTATE_NO_FBACK, hence the test against this state can safely be removed.
>
>  In addition, a problematic comment in ccid3_calc_new_t_ipi() was removed:
>    * the first part of the comment (initial t_ipi = 1 second) is correct
>    * the second part of the comment is not correct wrt. [RFC 3448, 4.4]

Why is the second part of the comment wrong?

RFC 3448, 4.4:

4.4.  Expiration of nofeedback timer

   If the nofeedback timer expires, the sender should perform the
   following actions:

   1) Cut the sending rate in half.  If the sender has received feedback
      from the receiver, this is done by modifying the sender's cached
      copy of X_recv (the receive rate).  Because the sending rate is
      limited to at most twice X_recv, modifying X_recv limits the
      current sending rate, but allows the sender to slow-start,
      doubling its sending rate each RTT, if feedback messages resume
      reporting no losses.

If the sending rate is halved, doesn't it implies the inter packet
interval is doubled?

Otherwise I'm fine with the patch, just waiting for comments above
this specific part (comment removal).

- Arnaldo
