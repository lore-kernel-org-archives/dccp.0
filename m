From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 12 May 2008 10:38:39 +0000
Subject: Re: CCID4 Testing - bug fix
Message-Id: <20080512103839.GA6274@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
In-Reply-To: <09D3F703EF3B0A4CBE28449EA9F3D32009EB46E6@nicta-atp-mail.in.nicta.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Since the reduction applies to X_calc only, IMHO it should be moved like this:
| 
| 	/* Update sending rate (step 4 of [RFC 3448, 4.3]) */
|         if (hctx->p > 0) {
| 		hctx->x_calc = tfrc_calc_x(NOM_PACKET_SIZE, 
| 					   hctx->rtt, hctx->p);
| 
| 		/* Apply header penalty as per RFC 4828, 4.2 */
| 		hctx->x_calc *= hctx->s;
| 		do_div(hctx->x_calc, hctx->s + CCID4HCTX_H);
| 	}
| 
No that won't work since it only changes X_calc. So it is probably all
well to just delete the call to  ccid4_hc_tx_x_header_penalty() below
"} else if (ktime_us_delta(now, h", as on your website.


The University of Aberdeen is a charity registered in Scotland, No SC013683.

