From: Babil <gsbabil@gmail.com>
Date: Mon, 12 May 2008 11:49:11 +0000
Subject: Re: CCID4 Testing - bug fix
Message-Id: <c39e786b0805120449u25fd0869y39b7559402b69771@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
In-Reply-To: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Monday 12 May 2008 8:38:39 pm Gerrit Renker wrote:
> | Since the reduction applies to X_calc only, IMHO it should be moved like
> | this:
> |
> |     /* Update sending rate (step 4 of [RFC 3448, 4.3]) */
> |         if (hctx->p > 0) {
> |             hctx->x_calc = tfrc_calc_x(NOM_PACKET_SIZE,
> |                                        hctx->rtt, hctx->p);
> |
> |             /* Apply header penalty as per RFC 4828, 4.2 */
> |             hctx->x_calc *= hctx->s;
> |             do_div(hctx->x_calc, hctx->s + CCID4HCTX_H);
> |     }
>
> No that won't work since it only changes X_calc. So it is probably all
> well to just delete the call to  ccid4_hc_tx_x_header_penalty() below
> "} else if (ktime_us_delta(now, h", as on your website.
>
>
> The University of Aberdeen is a charity registered in Scotland, No
> SC013683.

We have done our tests removing the 2nd "ccid4_hc_tx_x_header_penalty()" after
the "else if" and it seems to work. The graphs for the "patched ccid4" (200ms
and 1000ms) will testify the results.

Could anyone point me to some instructions on howto request/commit changes
done on dccp codes downloaded from: git://eden-feed.erg.abdn.ac.uk/dccp_exp ?

Thank you Gerrit for your replies.

-babil.
