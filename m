From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 27 Nov 2006 17:15:53 +0000
Subject: Re: [PATCH 8/10]: Larger initial windows
Message-Id: <200611271715.53572@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611241620.03850@strip-the-willow>
In-Reply-To: <200611241620.03850@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Eddie Kohler:
|  Gerrit, everyone,
|  
|  Again, the INTENTION I think was for the 2-4 packets per RTT to apply 
|  IMMEDIATELY, because the Request-Response exchange gave you an initial RTT 
|  estimate.  But this is just not what RFC 4342 says.  When I figure this out 
|  with Sally we will get back to you, and perhaps publish an erratum, allowing 
|  Linux to have the correct behavior while remaining 'standards compliant'.

see previous reply

|  
|  Eddie
|  
|  
|  Gerrit Renker wrote:
|  > [CCID 3]: Larger initial windows
|  > 
|  > This implements the larger-initial-windows feature for CCID 3, as described
|  > in section 5 of RFC 4342. When the first feedback packet arrives, the sender
|  > can send up to 2..4 packets per RTT, instead of just one. 
|  > 
|  > The patch further
|  >  * reduces the number of timestamping calls by passing the timestamp value
|  >    (which is computed in one of the calling functions anyway) as argument
|  > 
|  >  * renames one constant with a very long name into one which is shorter and 
|  >    resembles the one in RFC 3448 (t_mbi)
|  > 
|  >  * simplifies some of the min_t/max_t cases where both `x', `y' have the same
|  >    type
|  > 
|  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  > ---
|  >  net/dccp/ccids/ccid3.c |   75 +++++++++++++++++++++++++++----------------------
|  >  net/dccp/ccids/ccid3.h |    4 +-
|  >  2 files changed, 44 insertions(+), 35 deletions(-)
|  > 
|  > --- a/net/dccp/ccids/ccid3.c
|  > +++ b/net/dccp/ccids/ccid3.c
|  > @@ -129,35 +129,42 @@ static inline void ccid3_update_send_tim
|  >   * If X has changed, we also update the scheduled send time t_now,
|  >   * the inter-packet interval t_ipi, and the delta value.
|  >   */ 
|  > -static void ccid3_hc_tx_update_x(struct sock *sk)
|  > +static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
|  > +
|  >  {
|  >  	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
|  >  	const __u32 old_x = hctx->ccid3hctx_x;
|  >  
|  >  	DCCP_BUG_ON(hctx->ccid3hctx_rtt = 0);
|  >  
|  > -	/* To avoid large error in calcX */
|  > -	if (hctx->ccid3hctx_p >= TFRC_SMALLEST_P) {
|  > -		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
|  > -						     hctx->ccid3hctx_rtt,
|  > -						     hctx->ccid3hctx_p);
|  > -		hctx->ccid3hctx_x = max_t(u32, min_t(u32, hctx->ccid3hctx_x_calc,
|  > -							  2 * hctx->ccid3hctx_x_recv),
|  > -					       (hctx->ccid3hctx_s /
|  > -					        TFRC_MAX_BACK_OFF_TIME));
|  > -	} else {
|  > -		struct timeval now;
|  > +	/* Compute X after the first feedback packet has arrived */
|  > +	if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
|  > +		/* This implements `Larger Initial Windows' [RFC 4342, sec. 5]
|  > +		 * We deviate in that we use `s' instead of `MSS'.           */
|  > +		u16 w_init = max(     4 * hctx->ccid3hctx_s,
|  > +				 max( 2 * hctx->ccid3hctx_s, 4380));
|  > +		hctx->ccid3hctx_x    = usecs_div(w_init, hctx->ccid3hctx_rtt);
|  > +		hctx->ccid3hctx_t_ld = *now;
|  > +
|  > + 	/* To avoid large error in calcX */
|  > +	} else if (hctx->ccid3hctx_p >= TFRC_SMALLEST_P) {
|  > + 		hctx->ccid3hctx_x_calc = tfrc_calc_x(hctx->ccid3hctx_s,
|  > + 						     hctx->ccid3hctx_rtt,
|  > + 						     hctx->ccid3hctx_p);
|  > +		hctx->ccid3hctx_x = max_t(u32, min(hctx->ccid3hctx_x_calc,
|  > +						   hctx->ccid3hctx_x_recv * 2),
|  > +					       hctx->ccid3hctx_s / TFRC_t_mbi );
|  > +
|  > +	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) >|  > +							  hctx->ccid3hctx_rtt) {
|  > +		hctx->ccid3hctx_x = max(min(hctx->ccid3hctx_x_recv,
|  > +					    hctx->ccid3hctx_x      ) * 2,
|  > +					usecs_div(hctx->ccid3hctx_s,
|  > +					       	  hctx->ccid3hctx_rtt)   );
|  > +		hctx->ccid3hctx_t_ld = *now;
|  > +	} else
|  > +		ccid3_pr_debug("Not changing X\n");
|  >  
|  > -		dccp_timestamp(sk, &now);
|  > -	       	if (timeval_delta(&now, &hctx->ccid3hctx_t_ld) >|  > -		    hctx->ccid3hctx_rtt) {
|  > -			hctx->ccid3hctx_x = max_t(u32, min_t(u32, hctx->ccid3hctx_x_recv,
|  > -								  hctx->ccid3hctx_x) * 2,
|  > -						       usecs_div(hctx->ccid3hctx_s,
|  > -							       	 hctx->ccid3hctx_rtt));
|  > -			hctx->ccid3hctx_t_ld = now;
|  > -		}
|  > -	}
|  >  	if(hctx->ccid3hctx_x != old_x)
|  >  		ccid3_update_send_time(hctx);
|  >  }
|  > @@ -185,6 +192,7 @@ static void ccid3_hc_tx_no_feedback_time
|  >  	struct sock *sk = (struct sock *)data;
|  >  	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
|  >  	unsigned long next_tmout = USEC_PER_SEC / 5;
|  > +	struct timeval now;
|  >  
|  >  	bh_lock_sock(sk);
|  >  	if (sock_owned_by_user(sk)) {
|  > @@ -200,10 +208,8 @@ static void ccid3_hc_tx_no_feedback_time
|  >  	case TFRC_SSTATE_NO_FBACK:
|  >  		/* Halve send rate */
|  >  		hctx->ccid3hctx_x /= 2;
|  > -		if (hctx->ccid3hctx_x < (hctx->ccid3hctx_s /
|  > -					 TFRC_MAX_BACK_OFF_TIME))
|  > -			hctx->ccid3hctx_x = (hctx->ccid3hctx_s /
|  > -					     TFRC_MAX_BACK_OFF_TIME);
|  > +		if (hctx->ccid3hctx_x < (hctx->ccid3hctx_s / TFRC_t_mbi))
|  > +			hctx->ccid3hctx_x = hctx->ccid3hctx_s / TFRC_t_mbi;
|  >  
|  >  		ccid3_pr_debug("%s, sk=%p, state=%s, updated tx rate to %d "
|  >  			       "bytes/s\n",
|  > @@ -240,12 +246,13 @@ static void ccid3_hc_tx_no_feedback_time
|  >  			if (hctx->ccid3hctx_p < TFRC_SMALLEST_P ||
|  >  			    hctx->ccid3hctx_x_calc > 2 * hctx->ccid3hctx_x_recv)
|  >  				hctx->ccid3hctx_x_recv = max_t(u32, hctx->ccid3hctx_x_recv / 2,
|  > -								    hctx->ccid3hctx_s / (2 * TFRC_MAX_BACK_OFF_TIME));
|  > +								    hctx->ccid3hctx_s / (2 * TFRC_t_mbi));
|  >  			else
|  >  				hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc / 4;
|  >  
|  >  			/* Update sending rate */
|  > -			ccid3_hc_tx_update_x(sk);
|  > +			dccp_timestamp(sk, &now);
|  > +			ccid3_hc_tx_update_x(sk, &now);
|  >  		}
|  >  		/*
|  >  		 * Schedule no feedback timer to expire in
|  > @@ -488,10 +495,9 @@ static void ccid3_hc_tx_packet_recv(stru
|  >  		 *
|  >  		 * q is a constant, RFC 3448 recomments 0.9
|  >  		 */
|  > -		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
|  > -			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
|  > +		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK)
|  >  			hctx->ccid3hctx_rtt = r_sample;
|  > -		} else
|  > +		else
|  >  			hctx->ccid3hctx_rtt = (hctx->ccid3hctx_rtt * 9) / 10 +
|  >  					      r_sample / 10;
|  >  
|  > @@ -508,7 +514,11 @@ static void ccid3_hc_tx_packet_recv(stru
|  >  		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
|  >  
|  >  		/* Update sending rate (and likely t_ipi, t_nom, and delta) */
|  > -		ccid3_hc_tx_update_x(sk);
|  > +		ccid3_hc_tx_update_x(sk, &now);
|  > +
|  > +		/* Update the state if necessary */
|  > +		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK)
|  > +			ccid3_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
|  >  
|  >  		/* remove all packets older than the one acked from history */
|  >  		dccp_tx_hist_purge_older(ccid3_tx_hist,
|  > @@ -519,7 +529,6 @@ static void ccid3_hc_tx_packet_recv(stru
|  >  		 */
|  >  		sk->sk_write_space(sk);
|  >  
|  > -
|  >  		/* Update timeout interval. We use the alternative variant of
|  >  		 * [RFC 3448, 3.1] which sets the upper bound of t_rto to one
|  >  		 * second, as it is suggested for TCP (see RFC 2988, 2.4). */
|  > --- a/net/dccp/ccids/ccid3.h
|  > +++ b/net/dccp/ccids/ccid3.h
|  > @@ -48,8 +48,8 @@
|  >  /* In usecs - half the scheduling granularity as per RFC3448 4.6 */
|  >  #define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
|  >  
|  > -/* In seconds */
|  > -#define TFRC_MAX_BACK_OFF_TIME	   64
|  > +/* Parameter t_mbi from [RFC 3448, 4.3]: In seconds */
|  > +#define TFRC_t_mbi		   64
|  >  
|  >  #define TFRC_SMALLEST_P		   40
|  >  
|  > -
|  > To unsubscribe from this list: send the line "unsubscribe dccp" in
|  > the body of a message to majordomo@vger.kernel.org
|  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
