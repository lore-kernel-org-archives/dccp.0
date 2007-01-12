From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Fri, 12 Jan 2007 18:45:26 +0000
Subject: Re: [PATCH 1/1]: Remove build warnings on 64-bit architecture
Message-Id: <5640c7e00701121045j61e46301ua1c285e68c788233@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200701121758.21516@strip-the-willow>
In-Reply-To: <200701121758.21516@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 13/01/07, Gerrit Renker <gerrit@erg.abdn.ac.uk> wrote:
> [CCID 3]: Remove build warnings on 64-bit architecure
>
> This clears build warnings which will appear on some architectures such as sparc64.
>
> These warnings were of the following type:
> warning: format "%llu" expects type "long long unsigned int", but argument 3 has type "__u64"
> warning: format "%ld" expects type "long int", but argument 3 has type "suseconds_t"
>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
>  net/dccp/ccids/ccid3.c |   14 ++++++++------
>  1 file changed, 8 insertions(+), 6 deletions(-)
>
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -93,9 +93,9 @@ static inline void ccid3_update_send_int
>         hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
>                                            TFRC_OPSYS_HALF_TIME_GRAN);
>
> -       ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%llu\n",
> +       ccid3_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
>                        hctx->ccid3hctx_t_ipi, hctx->ccid3hctx_delta,
> -                      hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6);
> +                      hctx->ccid3hctx_s, (unsigned)(hctx->ccid3hctx_x >> 6));
>

You lose precision here since ccid3hctx_x is 64 bit and %u is 32 bit
on a 32 bit platform. You should do a cast to (long long unsigned) on
the last line rather than (unsigned) and leave the format as %llu I
think.

>  }
>  /*
> @@ -138,9 +138,11 @@ static void ccid3_hc_tx_update_x(struct
>         }
>
>         if (hctx->ccid3hctx_x != old_x) {
> -               ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
> -                              "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
> -                              hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
> +               ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
> +                              "X_recv=%u\n", (unsigned)(old_x >> 6),
> +                              (unsigned)(hctx->ccid3hctx_x >> 6),
> +                              hctx->ccid3hctx_x_calc,
> +                              (unsigned)(hctx->ccid3hctx_x_recv >> 6));
>
>                 ccid3_update_send_interval(hctx);
>         }

And the same as above

> @@ -899,7 +901,7 @@ static void ccid3_hc_rx_packet_recv(stru
>                 DCCP_BUG_ON(r_sample < 0);
>                 if (unlikely(r_sample <= t_elapsed))
>                         DCCP_WARN("r_sample=%ldus, t_elapsed=%ldus\n",
> -                                 r_sample, t_elapsed);
> +                                 (long)r_sample, (long)t_elapsed);
>                 else
>                         r_sample -= t_elapsed;
>                 CCID3_RTT_SANITY_CHECK(r_sample);
> -

I can't comment on suseconds stuff as don't know so much...

-- 
Web: http://wand.net.nz/~iam4
Blog: http://iansblog.jandi.co.nz
WAND Network Research Group
