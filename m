From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 30 Aug 2007 08:35:06 +0000
Subject: Re: [PATCH 6/6] DCCP: Implement faster restart
Message-Id: <200708300935.06414@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200708291138.39630.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200708291138.39630.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

|   static inline u64 rfc3390_initial_rate(struct sock *sk)
|   {
|   	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
|  -	const __u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
|  +	__u32 w_init = min_t(__u32, 4 * hctx->ccid3hctx_s,
|   				   max_t(__u32, 2 * hctx->ccid3hctx_s, 4380));
|   
|  +	if (ccid3_hc_tx_faster_restart_on(ccid3_hc_tx_sk(sk)))
|  +		w_init *= 2;
|  +
The problem with this is that now you will get the quadrupled rate also at startup
since this function is called at the begin of a connection, not only after an idle
period, i.e. your connections will start with an initial window of up to 8 * s instead
of the 4 * s.


|  +/**
|    * ccid3_hc_tx_update_x  -  Update allowed sending rate X
|    * @stamp: most recent time if available - can be left NULL.
|    * This function tracks draft rfc3448bis, check there for latest details.
|  @@ -130,13 +156,13 @@ static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock 
|  *hctx, ktime_t now)
|    *       throughout the code. Only X_calc is unscaled (in bytes/second).
|    *
|    */
|  -static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
|  -
|  +static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp, bool 
|  nofeedback)
Similar comment - since the code is only executed within the nofeedback timer,
it seems much simpler to put this directly into tx_packet_recv, like

	/* perform step (4) of draft rfc3448bis, section 4.3 */
        if (hctx->ccid3hctx_p > 0) {
                hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
                                                     hctx->ccid3hctx_rtt,
                                                     hctx->ccid3hctx_p);
		if (ccid3_hc_tx_faster_restart_on(hctx)) {
			x_fast_max = hctx->ccid3hctx_x_active_recv;
			/* ... rest of your code from below ... */
		}
	}
        ccid3_hc_tx_update_x(sk, &now);


|  -	if (hctx->ccid3hctx_p > 0) {
|  +	if (ccid3_hc_tx_faster_restart_on(hctx) && !nofeedback)
|  +		if (hctx->ccid3hctx_p > 0) {
|  +			x_fast_max = hctx->ccid3hctx_x_active_recv;
|  +			/* FIXME We should interpolate here but this is under
|  +			 * discussion and doesn't affect my research IAM */
|  +			if (!ccid3_hc_tx_fr_loss(hctx) &&
|  +			  (hctx->ccid3hctx_x_recv > x_fast_max)) {
|  +				x_fast_max = hctx->ccid3hctx_x_recv;
|  +				hctx->ccid3hctx_x_active_recv = x_fast_max;
|  +				hctx->ccid3hctx_t_active_recv = now;
|  +			} else if (ccid3_hc_tx_fr_loss(hctx) &&
|  +			  (hctx->ccid3hctx_x_recv < x_fast_max)) {
|  +				x_fast_max = hctx->ccid3hctx_x_recv / 2;
|  +				hctx->ccid3hctx_x_active_recv = x_fast_max;
|  +				hctx->ccid3hctx_t_active_recv = now;
|  +			}
|  +			if (min_rate < x_fast_max)
|  +				min_rate = min(2*min_rate, x_fast_max);
|  +			/* We double again for faster rate */
|  +			/* FIXME - draft refers to X_recv_set but base
|  +			 * implementation doesn't use this so we stay
|  +			 * consistent with this IAM */
|  +		}
|
