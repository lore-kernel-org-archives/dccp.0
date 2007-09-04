From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Tue, 04 Sep 2007 03:06:29 +0000
Subject: Re: [PATCH 6/6] DCCP: Implement faster restart
Message-Id: <5640c7e00709032006ma3e2952ubbea9e8a834c7642@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200708291138.39630.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291138.39630.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 8/30/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> |   static inline u64 rfc3390_initial_rate(struct sock *sk)
> |   {
> |       const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
> |  -    const __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
> |  +    __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
> |                                  max_t(__u32, 2 * hctx->ccid3hctx_s, 4380));
> |
> |  +    if (ccid3_hc_tx_faster_restart_on(ccid3_hc_tx_sk(sk)))
> |  +            w_init *= 2;
> |  +
> The problem with this is that now you will get the quadrupled rate also at startup
> since this function is called at the begin of a connection, not only after an idle
> period, i.e. your connections will start with an initial window of up to 8 * s instead
> of the 4 * s.
>
Yes that certainly was a problem. Fixed now. Thanks for picking that up.

>
> |  +/**
> |    * ccid3_hc_tx_update_x  -  Update allowed sending rate X
> |    * @stamp: most recent time if available - can be left NULL.
> |    * This function tracks draft rfc3448bis, check there for latest details.
> |  @@ -130,13 +156,13 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock
> |  *hctx, ktime_t now)
> |    *       throughout the code. Only X_calc is unscaled (in bytes/second).
> |    *
> |    */
> |  -static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
> |  -
> |  +static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp, bool
> |  nofeedback)
> Similar comment - since the code is only executed within the nofeedback timer,
> it seems much simpler to put this directly into tx_packet_recv, like
>
>         /* perform step (4) of draft rfc3448bis, section 4.3 */
>         if (hctx->ccid3hctx_p > 0) {
>                 hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
>                                                      hctx->ccid3hctx_rtt,
>                                                      hctx->ccid3hctx_p);
>                 if (ccid3_hc_tx_faster_restart_on(hctx)) {
>                         x_fast_max = hctx->ccid3hctx_x_active_recv;
>                         /* ... rest of your code from below ... */
>                 }
>         }
>         ccid3_hc_tx_update_x(sk, &now);
>
>
I had a look at this but the code depends on min_rate which is only in update_x.

I'm posting the revised patch site to http://wand.net.nz/~iam4/dccp/patches24/

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
