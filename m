From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 09 Nov 2007 15:03:28 +0000
Subject: Re: [PATCH 6/25] Reduce allowed sending rate by a factor that accounts for packet header size
Message-Id: <20071109150328.GA27398@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200710312130.18806.leandroal@gmail.com>
In-Reply-To: <200710312130.18806.leandroal@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Please see at bottom of message.

| On Thu, Nov 08, 2007 at 10:15:23 +0000, Gerrit Renker wrote:
| > Since ccid4_hc_tx_x_header_penalty() is called in both the if/else
| > branches, it looks to me that you can put it before the if/else. 
| > If you then wanted to abstract this function, it looks as if a wrapper
| > could be used:
| > 
| > 	ccid4_hc_tx_update_x(hctx) 
| > 	{
| >               ccid4_hc_tx_x_header_penalty(hctx);
| > 		tfrc_hc_tx_update_x(...);
| > 	}
| > 
| > Makes sense?
| 
| ccid4_hc_tx_x_header_penalty() modifies hctx->ccid4hctx_x. If new x
| differs from old x at the end of ccid4_hc_tx_update_x(),
| ccid4_update_send_interval() is called. As far as I can see, if we
| wanted to have tfrc_hc_tx_update_x(), the caller of that function would
| have to deal with changed x by calling *_update_send_interval(), which
| is CCID-dependant.
| 
| Maybe tfrc_hc_tx_update_x() could update x, return old x, and indeed let
| the caller to call ccid4_hc_tx_x_header_penalty(), if wanted, and
| finally *_update_send_interval, if necessary. Since
| ccid4_hc_tx_update_x() is currently called from two different places, we
| could have something like this instead:
| 
| static void ccid4_hc_tx_update_x(hctx)
| {
| 	const  __u64 old_x = tfrc_hc_tx_update_x(hctx);
| 	ccid4_hc_tx_x_header_penalty(hctx);
| 	if (hctx->ccid4hctx_x != old_x)
| 		ccid4_update_send_interval(hctx);
| }
| 
| And respectively:
| 
| static void ccid3_hc_tx_update_x(hctx)
| {
| 	const  __u64 old_x = tfrc_hc_tx_update_x(hctx);
| 	if (hctx->ccid4hctx_x != old_x)
| 		ccid3_update_send_interval(hctx);
| }
| 
| Finally, tfrc_hc_tx_update_x() should be trimmed a little:
| 
| @@ -198,3 +198,2
| -	if (hctx->ccid4hctx_x != old_x)
| -		foo_update_send_interval(hctx);
| +	return old_x;
|  }
| 
| -
I agree, you have a valid point here. Maybe I should not have started
this thread, after first suggesting to keep things separate. But I am
guessing that eventually you would like to reduce code duplication, the
above was a start.

Now with regard to the above - we end up having three different
functions doing each a slice of the work and with interleaved calling.

I have another suggestion which I believe may be simpler: The `header
penalty' is just a multiplication applied to X. The sender does not
use X directly, but rather t_ipi = s/X. And it has to compute this
anyway, in update_send_interval(), each time X changes.

I wonder whether the following works, it is in any event much simpler:

 * t_ipi is computed as t_ipi = s / X'
 * the header penalty X' is derived from X as X' = X * s / (s + 36)

Taken together, we have 

	t_ipi = s / X'
	      = s / (X * s / (s + 36))
	      = (s + 36) / X

Thus, the suggestion is to

 * keep update_x the same for CCID3 and CCID4 
 * only change update_send_interval()

This has the added advantage of higher precision than the previous
approach (accumulation of rounding errors). I think it would look like

 /* 
  * Update t_ipi with regard to the header penalty X *= s/(s + 36),
  * which is factored into the t_ipi equation
  */
 hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s +  CCID4_NOM) << 6,
                                             hctx->ccid3hctx_x);

since all the X* quantities are scaled by 2^64 to avoid fixed-point
division problems.
