From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Sat, 16 Jun 2007 18:27:51 +0000
Subject: Re: [PATCH 1/5]: Shorten statement for updating p
Message-Id: <39e6f6c70706161127s5e8b5459l3003d4b191f715d9@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200706111539.22960@strip-the-willow>
In-Reply-To: <200706111539.22960@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 6/11/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Shorten statement for updating p
>
> This shortens the statement for updating the loss event
> rate p when a feedback packet is received.
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccids/ccid3.c |    7 ++-----
>  1 file changed, 2 insertions(+), 5 deletions(-)
>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -436,12 +436,9 @@ static void ccid3_hc_tx_packet_recv(stru
>                 hctx->ccid3hctx_x_recv = opt_recv->ccid3or_receive_rate;
>                 hctx->ccid3hctx_x_recv <<= 6;
>
> -               /* Update loss event rate */
> +               /* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
>                 pinv = opt_recv->ccid3or_loss_event_rate;
> -               if (pinv = ~0U || pinv = 0)          /* see RFC 4342, 8.5   */
> -                       hctx->ccid3hctx_p = 0;
> -               else                                   /* can not exceed 100% */
> -                       hctx->ccid3hctx_p = 1000000 / pinv;
> +               hctx->ccid3hctx_p = (pinv = ~0U || pinv = 0)? 0 : scaled_div(1, pinv);
>
>                 /*
>                  * Calculate new RTT sample and update moving average

I love '?:', but not when things get complex. I think this should be
kept as if+else.

I'll pick the conversion to scaled_div tho, looks right.

- Arnaldo
