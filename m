From: Tommi Saviranta <wnd@iki.fi>
Date: Thu, 01 Nov 2007 13:12:21 +0000
Subject: Re: [PATCH 25/25] Final adjustments to ccid3.c, ccid4.c and
Message-Id: <20071101131221.GP19989@kikai.katei.fi>
List-Id: <dccp.vger.kernel.org>
References: <200710312132.10510.leandroal@gmail.com>
In-Reply-To: <200710312132.10510.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Oct 31, 2007 at 21:32:10 -0300, Leandro wrote:
> [CCID-3/4] Final adjustments to ccid3.c, ccid4.c and lib/tfrc_ccids.c
> 
> According to the chosen strategy explained in [PATCH 15/25], some
> defines become unnecessary. This patch removes them and adjusts
> ccid3.c, ccid4.c and lib/ccid34_lib.c to use tfrc_ccids definitions
> directly.
> 
> Signed-off-by: Leandro Melo de Sales <leandro@embedded.ufcg.edu.br>

Tabs have transformed into spaces again, probably thanks to copy-paste.

> -static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
> +static inline void ccid4_update_send_interval(struct tfrc_hc_tx_sock *hctx)
>  {
>          /* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second).
>           * TFRC-SP enforces a minimum interval of 10 milliseconds. */
> -        hctx->ccid4hctx_t_ipi > -              max_t(u32, scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
> -                                      hctx->ccid4hctx_x), MIN_SEND_RATE);
> +        hctx->tfrchctx_t_ipi > +              max_t(u32, scaled_div32(((u64)hctx->tfrchctx_s) << 6,
> +                                      hctx->tfrchctx_x), MIN_SEND_RATE);

> -static inline void ccid4_hc_tx_x_header_penalty(struct ccid4_hc_tx_sock *hctx)
> +static inline void ccid4_hc_tx_x_header_penalty(struct tfrc_hc_tx_sock *hctx)
>  {
> -        hctx->ccid4hctx_x *= hctx->ccid4hctx_s;
> -        do_div(hctx->ccid4hctx_x, (hctx->ccid4hctx_s + CCID4HCTX_H));
> +        hctx->tfrchctx_x *= hctx->tfrchctx_s;
> +        do_div(hctx->tfrchctx_x, (hctx->tfrchctx_s + CCID4HCTX_H));
>  }

