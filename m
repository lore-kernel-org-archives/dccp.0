From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Thu, 01 Nov 2007 21:58:23 +0000
Subject: Re: [PATCH 16/25] Share ccid3_hc_rx_sock struct and ccid3_hc_rx_sk function via tfrc_ccids
Message-Id: <5bc4c4570711011458i5106babft7d0c3effed9788b6@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312131.50615.leandroal@gmail.com>
In-Reply-To: <200710312131.50615.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/1, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> I think we need to get back to deciding on a naming scheme for the structs. It is not
> your fault, but with the current scheme the names become extremely cryptic:
>
> |  + * @tfrchcrx_last_counter - Tracks window counter (RFC 4342, 8.1)
> |  + * @tfrchcrx_state - Receiver state, one of %tfrc_hc_rx_states
> |  + * @tfrchcrx_bytes_recv - Total sum of DCCP payload bytes
> |  + * @tfrchcrx_x_recv - Receiver estimate of send rate (RFC 3448, sec. 4.3)
> |  + * @tfrchcrx_rtt - Receiver estimate of RTT
> |  + * @tfrchcrx_last_feedback - Time at which last feedback was sent
> |  + * @tfrchcrx_hist - Packet history, exported by TFRC module
> |  + * @tfrchcrx_li_hist - Loss Interval database, exported by TFRC module
> |  + * @tfrchcrx_s - Received packet size in bytes
> |  + * @tfrchcrx_pinv - Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
> |  + */
>
> Similar thing with the #defines - my eyes fail to parse this:
> |  #define ccid3_hc_tx_sk tfrc_hc_tx_sk
> |
> |  +#define ccid3_hc_rx_sock tfrc_hc_rx_sock
> |  +#define ccid3hcrx_s tfrchcrx_s
> |  +#define ccid3hcrx_x_recv tfrchcrx_x_recv
> |  +#define ccid3hcrx_pinv tfrchcrx_pinv
> |  +#define ccid3hcrx_last_feedback tfrchcrx_last_feedback
> |  +#define ccid3hcrx_bytes_recv tfrchcrx_bytes_recv
> |  +#define ccid3hcrx_last_counter tfrchcrx_last_counter
> |  +#define ccid3hcrx_rtt tfrchcrx_rtt
> |  +#define ccid3hcrx_s tfrchcrx_s
> |  +#define ccid3hcrx_hist tfrchcrx_hist
> |  +#define ccid3hcrx_li_hist tfrchcrx_li_hist
>
> My suggestion is to use something like
>         * `ttx_' for TFRC TX related structs/operations/fields
>         * `trx_' for  "   RX  "             "
>         * Arnaldo's scheme for the CCIDs
>                 -- c3rx_ / c4rx_ for RX structs/fields
>                 -- c3tx_ / c4tx_ for TX structs/fields
>
> Of course that costs work. But now is probably the best time to change it - so better
> get it cleaned up before passing it on to Arnaldo.
>

I totally agree with you. I will update the patches.

Leandro.
