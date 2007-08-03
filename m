From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 03 Aug 2007 10:43:24 +0000
Subject: Re: Comments/question on no_feedback_timer
Message-Id: <200708031143.24443@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
In-Reply-To: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian,

to clarify - all rfc3448bis 

It is consistent with revision 00 of draft rfc3448bis; check against:
 http://tools.ietf.org/html/draft-ietf-dccp-rfc3448bis-00#section-4.4



Quoting Ian McDonald:
|  I've got a few comments/questions on the no feedback timer on CCID3.
|  It's probably me not reading the code properly and I've got no idea
|  where the code came from (may have even been us!!)
|  
|  
|  In this code from ccid3_hc_tx_no_feedback_timer we work on x_recv
|  mostly rather than x. I'm wondering why??
|  		/*
|  		 *  Modify the cached value of X_recv
|  		 *
|  		 *  If (X_calc > 2 * X_recv)
|  		 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
|  		 *  Else
|  		 *    X_recv = X_calc / 4;
|  		 *
|  		 *  Note that X_recv is scaled by 2^6 while X_calc is not
|  		 */
|  		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);
|  
|  		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
|  			hctx->ccid3hctx_x_recv |  				max(hctx->ccid3hctx_x_recv / 2,
|  				    (((__u64)hctx->ccid3hctx_s) << 6) /
|  							      (2 * TFRC_T_MBI));
|  		else {
|  			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
|  			hctx->ccid3hctx_x_recv <<= 4;
|  		}
|  		ccid3_hc_tx_update_x(sk, NULL);
Here the relevant passage is 
 4.4 Expiration of nofeedback timer

	"If (X_calc > 2*X_recv)
                X_recv = max(X_recv/2, s/(2*t_mbi));
         Else
                X_recv = X_calc/4;"

This corresponds one-to-one with the above code, given that X_recv is scaled by 2^6.
  
|  and I think this then is potentially problematic when
|  ccid3_hc_tx_update_x if it is less than 2 rtt idle and we go past this
|  code:
|  	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
|  		min_rate = rfc3390_initial_rate(sk);
|  		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
|  	}
|  
|  because we then go through to the rest of the code and we can
|  effectively double the rate (min_rate is doubled at start of
|  ccid3_hc_tx_update_x).
This corresponds to section 4.3 of above URL:

    "4)  Update the sending rate as follows:

             If (sender has been idle or data-limited)
                 min_rate = max(2*X_recv, W_init/R);
             Else
                 min_rate = 2*X_recv;
    "
Again there is a one-to-one correspondence, given the initialisation statement of

    __u64 min_rate = 2 * hctx->ccid3hctx_x_recv;
  
|  This seems bizarre to me. We get no feedback and we double the rate??
|  I know it will get fixed in short order when we detect the loss later
|  on but this just seems wrong.
Here is a misunderstanding. ccid3_hc_tx_idle_rtt() measures the amount of time
the sender has not sent anything, returned as integral number of full RTTs. 
This notion of idling is consistent with section 6.4 of RFC 4342 and further 
consistent with the definition of CCID2's quiescence in section 6.2.1 of RFC 4341.

If it still seems wrong, then this is something on the level of the specification.
It has taken painstaking effort to align the implementation with RFC 4342, 4340,
3448, rfc3448bis. I am quite reluctant to start tearing this apart, since it can
not be done `fix' wise: if you do it, then the complete set of changes from rev00
to rev02 of rfc3448bis needs to be implemented.

|  Can someone else verify before I fix? I do have a habit of reading
|  code wrong so would like verification. 
I repeat, the code is consistent with revision 00 of draft rfc3448bis, available
from http://tools.ietf.org/html/draft-ietf-dccp-rfc3448bis-00

Given the recent discussions of this, I would like to postpone such discussion until
December, after they have reviewed the next revision of rfc3448bis.
