From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 11 Dec 2006 00:52:47 +0000
Subject: Re: [PATCH 8/22] [DCCP] ccid3: Simplify calculation for reverse lookup of p
Message-Id: <5640c7e00612101652k1548a5d7j9d23ed9b5d793e3b@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20061210030138.GJ17909@mandriva.com>
In-Reply-To: <20061210030138.GJ17909@mandriva.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/10/06, Arnaldo Carvalho de Melo <acme@mandriva.com> wrote:
>  This simplifies the calculation of a value p for a given fval when the
>  first loss interval is computed (RFC 3448, 6.3.1). It makes use of the
>  two new functions scaled_div/scaled_div32 to provide overflow protection.
>
>  Additionally, protection against divide-by-zero is extended - in this
>  case the function will return the maximally possible value of p0%.
>
Just discovered an error in this patch. If we can't determine the loss
rate we should set the interval to ~0 as used by
dccp_li_hist_calc_i_mean. We definitely should not use 1000000 as this
signifies we got 1 million packets without loss and will cause
performance to be ramped up in the face of problems! Possibly we
should use 1 as a case if we want to signify we should slow down
things. Thinking about this and writing a patch shortly.

Ian

> diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
> index bdd13de..89ef118 100644
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -785,12 +785,12 @@ static u32 ccid3_hc_rx_calc_first_li(str
> @@ -834,30 +834,35 @@ found:

> +       if (rtt = 0) {                 /* would result in divide-by-zero */
> +               DCCP_WARN("RTT=0, returning 1/p = 1\n");
> +               return 1000000;
>         }
>
> +       if (x_recv = 0) {              /* would also trigger divide-by-zero */
> +               DCCP_WARN("X_recv=0\n");
> +               if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
> +                       DCCP_BUG("stored value of X_recv is zero");
> +                       return 1000000;
> +               }
>         }
>

-- 
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
