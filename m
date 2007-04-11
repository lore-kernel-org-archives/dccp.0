From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Apr 2007 09:06:32 +0000
Subject: Re: [PATCH 1/25]: Fix bug in the calculation of very low sending rates
Message-Id: <200704111006.32576@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200703211844.06124@strip-the-willow>
In-Reply-To: <200703211844.06124@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Eddie Kohler:
|  I'm surprised that this case occurs:
|  
|  Gerrit Renker wrote:
|  > [CCID 3]: Fix bug in the calculation of very low sending rates
|  > 
|  > This fixes an error in the calculation of t_ipi when X converges towards
|  > very low sending rates (between 1 and 64 bytes per second).
|  > 
|  > Although this case may not sound likely, it can be reproduced by connecting,
|  > hitting enter (1 byte sent) and waiting for some time, during which the
|  > nofeedback timer halves the sending rate until finally it reaches the region
|  > 1..64 bytes/sec. Computing X is handled correctly (tested separately); but by
|  > dividing X _before_ entering the calculation of t_ipi, X becomes zero as
|  > a result.  This in turn triggers a BUG condition caught in scaled_div().
|  
|  According to RFC 4342, the allowed sending rate should never be reduced 
|  below the TCP initial sending rate of two or four packets per RTT, 
|  depending on the packet size, as the result of an idle or slow period.
|  
|  Hitting enter and then waiting is an idle period.
|  
|  Since X is the allowed transmit rate, it seems Linux implementation is 
|  not following this at the moment; but perhaps there is code elsewhere 
|  handling this case?
|  
Respecting the TCP initial sending rate is handled by rfc3390_initial_rate(), but this
patch is in a different section of the code; the nofeedback timer reducing X.
This patch is not affected by and does not affect the TCP initial rate. 

It is a bona-fide bug fix and only concerned with rounding errors. The present code is 
wrong and will cause a BUG condition under the described conditions.
|  >  static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
|  >  {
|  >  	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
|  > -	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
|  > -					   hctx->ccid3hctx_x >> 6);
|  > +	hctx->ccid3hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s) << 6,
|  > +					     hctx->ccid3hctx_x);
The bug here is in scaled_div(hctx->ccid3hctx_s, hctx->ccid3hctx_x >> 6): the right-shift
is done before the division operation is evaluated. Thus sending rates in the range 
1/64 bytes/sec ... 1 byte/sec will appear as 0, and consequently trigger "divide-by-zero"
BUG condition in scaled_div. And this case is perfectly possible, due to the definition
of s/t_mbi and s/(2*t_mbi) in RFC 3448, 4.3 - both values would with the above show as 0
when s is very small.

It may be that due to the TCP initial rate this case is rare, but it still represents a
bug condition and must not be allowed to occur. 
