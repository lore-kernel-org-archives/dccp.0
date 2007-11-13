From: "=?ISO-8859-2?Q?=A3eandro_Sales?=" <leandroal@gmail.com>
Date: Tue, 13 Nov 2007 16:20:53 +0000
Subject: Re: [PATCH 4/25] Set packet size to 1460 as per ccid-4 draft
Message-Id: <5bc4c4570711130820w624d6fbfj852e583710549c5@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <200710312129.57873.leandroal@gmail.com>
In-Reply-To: <200710312129.57873.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/11/9, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> | |     if (hctx->ccid4hctx_p > 0)
> | | -           hctx->ccid4hctx_x_calc = tfrc_calc_x(hctx->ccid4hctx_s,
> | | +           hctx->ccid4hctx_x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
> | |                                                  hctx->ccid4hctx_rtt,
> | |                                                  hctx->ccid4hctx_p);
> <snip>
> | The above code is CCID3 with the difference that s = 1460. To better
> | share the code between CCID3/4, I think it would be simpler to
> | initialise `s' with this value, and to dispense with the `update_s'
> | routine that CCID3 uses.
> |
> | Like, for example in ccid4_hc_tx_init:
> |       {
> |               /* ... */
> |               hctx->ccid4hctx_s = NOM_PACKET_SIZE;
> |
> |       }
> |
> | Then one could consider sharing tx_packet_recv code.
> Nope. The above is nonsense, I've just realised the way `s' is used, so
> the comment does not really apply, please forget that.
>
> Using the moving-average as in CCID3, as you do, is probably a good
> idea, since when the packet size is varied in response to congestion
> the spikes will be smoothed out be the earlier averages.
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Ok.

Leandro.
