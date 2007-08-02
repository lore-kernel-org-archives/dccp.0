From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 02 Aug 2007 23:14:55 +0000
Subject: Comments/question on no_feedback_timer
Message-Id: <5640c7e00708021614j780c829ao3ce950b25c8ac67@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I've got a few comments/questions on the no feedback timer on CCID3.
It's probably me not reading the code properly and I've got no idea
where the code came from (may have even been us!!)


In this code from ccid3_hc_tx_no_feedback_timer we work on x_recv
mostly rather than x. I'm wondering why??
		/*
		 *  Modify the cached value of X_recv
		 *
		 *  If (X_calc > 2 * X_recv)
		 *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
		 *  Else
		 *    X_recv = X_calc / 4;
		 *
		 *  Note that X_recv is scaled by 2^6 while X_calc is not
		 */
		BUG_ON(hctx->ccid3hctx_p && !hctx->ccid3hctx_x_calc);

		if (hctx->ccid3hctx_x_calc > (hctx->ccid3hctx_x_recv >> 5))
			hctx->ccid3hctx_x_recv 				max(hctx->ccid3hctx_x_recv / 2,
				    (((__u64)hctx->ccid3hctx_s) << 6) /
							      (2 * TFRC_T_MBI));
		else {
			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
			hctx->ccid3hctx_x_recv <<= 4;
		}
		ccid3_hc_tx_update_x(sk, NULL);

and I think this then is potentially problematic when
ccid3_hc_tx_update_x if it is less than 2 rtt idle and we go past this
code:
	if (ccid3_hc_tx_idle_rtt(hctx, now) >= 2) {
		min_rate = rfc3390_initial_rate(sk);
		min_rate = max(min_rate, 2 * hctx->ccid3hctx_x_recv);
	}

because we then go through to the rest of the code and we can
effectively double the rate (min_rate is doubled at start of
ccid3_hc_tx_update_x).

This seems bizarre to me. We get no feedback and we double the rate??
I know it will get fixed in short order when we detect the loss later
on but this just seems wrong.

Can someone else verify before I fix? I do have a habit of reading
code wrong so would like verification.

Ian
-- 
Web1: http://wand.net.nz/~iam4/
Web2: http://www.jandi.co.nz
Blog: http://iansblog.jandi.co.nz
