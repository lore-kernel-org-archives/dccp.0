From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 08 Nov 2007 11:18:30 +0000
Subject: Re: [PATCH 5/25] Enforces a minimum interval of 10 milliseconds as per CCID-4 draft
Message-Id: <20071108111830.GC15246@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.12981.leandroal@gmail.com>
In-Reply-To: <200710312130.12981.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| @@ -111,9 +111,11 @@ static inline u64 rfc3390_initial_rate(s
|   */
|  static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
|  {
| -	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
| -	hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
| -					     hctx->ccid4hctx_x);
| +        /* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second).
| +         * TFRC-SP enforces a minimum interval of 10 milliseconds. */
| +        hctx->ccid4hctx_t_ipi | +              max_t(u32, scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
| +                                      hctx->ccid4hctx_x), MIN_SEND_RATE);
Whitespace - I have taken the liberty of replacing the above blanks with
tabs. Also a comment regarding comments: as far as I know the accepted
practice for multiline comments is

	/*
	 * comment text which extends over one line
	 * and another
	 */

While at it, I've done this also. Maybe the code would be clearer to read this way:

	hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
					     hctx->ccid4hctx_x));
	if (hctx->ccid4hctx_t_ipi <  MIN_SEND_RATE)
		hctx->ccid4hctx_t_ipi = MIN_SEND_RATE;

This is one of the cases where the overly long tags `ccid4hctx_' are in	the way.
If we had c4tx, the above reads	

	hctx->c4tx_t_ipi = scaled_div32(((u64)hctx->c4tx_s) <<6, hctx->c4tx_x));
	if (hctx->c4tx_t_ipi <  MIN_SEND_RATE)
		hctx->c4tx_t_ipi = MIN_SEND_RATE;

So the problem is not your code, it is again these long identifiers. I
am overhauling the old CCID3 patch set, maybe this should be kept on the
todo list -- comments?
