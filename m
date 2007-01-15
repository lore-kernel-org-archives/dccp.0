From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Jan 2007 11:38:34 +0000
Subject: Re: [PATCH 1/1] DCCP: Another attempt at fixing up t_nom
Message-Id: <200701151138.35152@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200701131756.24975.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200701131756.24975.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The differences between this patch and 3e are diminishing. Both always update t_nom in 
ccid3_hc_tx_send_packet, so there would be no great leap moving	timeval_add_usecs
from ccid3_update_send_time to the end of ccid3_hc_tx_send_packet. (A further advantage
is that then t_ipi / delta is only recomputed when necessary, not for each packet sent.)

So the main difference is in the code regarding the initial t_ipi of 1 second. 


  
  +-----------*---------------------|--------------------------------
  |           ^                     |
  t_0         first feedback        t_0 + 1 second
              arrives
  first                             application wakes up
  packet                            second packet sent
  sent

The changes affect all packets from the second one on in the send queue. Since the t_ipi will
typically be much less than 1 second, the effect of subtracting 1 second and adding the current 
t_ipi to t_nom = t_0 has the effect that up to the entire tx queue is sent immediately. This
is because the subtraction creates a negative credit.

A numerical example: let's assume RTT = 5 ms, t_ipi = 100 usec, tx_qlen = 100. First packet has been
sent, so there are 99 packets in the queue when the first feedback packet arrives at t_0 + 5 msec.
Recomputing t_nom gives t_0 plus 100 usec, so we are already late for that. Subsequent call to 
sk_write_space in ccid3_hc_tx_packet_recv wakes up the application, which then calls ccid3_hc_tx_send_packet
in state FBACK: delay is negative, packet is sent immediately (as intended), then t_ipi0usec are
added to t_nom. The result is that t_nom is now t_0 + 2* 100 usec, which still is -4.80 milliseconds
from now. As a result, in this example up to 50 packets are sent in a burst now, spaced by 100 usecs.

Without the `hack', the first packet is sent, when feedback arrives after 5msec, t_ipi is updated, but
not t_nom. Waking up the application via sk_write_space results in going back to sleep until, t_0 + 1 second,
after which the packets are sent with the correct spacing of 100 usec.

So this would slightly speed up things for the first batch of packets. The downside is that we are
opening the back door for another race condition which occurs when tx_send_packet tries to push out a 
packet shortly after t_ipi has been subtracted from t_nom; this would mess up the value of t_nom since
then t_ipi is added twice (both in update_send_time and in tx_send_packet via another call to update_send_time).

So my conclusion is, if you absolutely insist that re-subtracting t_ipi as above is better, we should merge your
patch and 3d, and mark clearly, via an `XXX' or `FIXME' that this is a temporary solution (and may be liable to 
a race condition).

Another alternative which we could do is to use a configuration option which sets a fixed value of an initial
RTT. From this value we could compute the initial speed (as per Eddie's email and in the same manner we would do
it if we had the initial RTT information), and uses this instead of the - agreed, it is rather larger - initial
t_ipi of 1 second. As with the other option, one could use the value `0' to disable the optional setting of a 
fixed initial RTT. 

I see in the initial value of the RTT the main difference between 3e and your patch and wait for your comments
on the above.

Gerrit

Quoting Ian McDonald:
|  Calculate t_nom as per RFC3448 section 4.6. We have been making it too
|  complicated previously.
|  
|  We do have a bit of a hack for initial ipi as we are not picking up the rtt
|  from initial setup. This should be tidied up in future.
|  
|  Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
|  ---
|  diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
|  index 1ebb4da..57f9fb8 100644
|  --- a/net/dccp/ccids/ccid3.c
|  +++ b/net/dccp/ccids/ccid3.c
|  @@ -82,12 +82,10 @@ static void ccid3_hc_tx_set_state(struct sock *sk,
|   
|   /*
|    * Recalculate scheduled nominal send time t_nom, inter-packet interval
|  - * t_ipi, and delta value. Should be called after each change to X.
|  + * t_ipi, and delta value. Should be called after each packet sent.
|    */
|  -static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
|  +static void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
|   {
|  -	timeval_sub_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
|  -
|   	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
|   	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
|   					   hctx->ccid3hctx_x >> 6);
|  @@ -118,8 +116,6 @@ static inline void ccid3_update_send_time(struct ccid3_hc_tx_sock *hctx)
|    *       fine-grained resolution of sending rates. This requires scaling by 2^6
|    *       throughout the code. Only X_calc is unscaled (in bytes/second).
|    *
|  - * If X has changed, we also update the scheduled send time t_now,
|  - * the inter-packet interval t_ipi, and the delta value.
|    */
|   static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
|   
|  @@ -145,13 +141,10 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
|   		hctx->ccid3hctx_t_ld = *now;
|   	}
|   
|  -	if (hctx->ccid3hctx_x != old_x) {
|  +	if (hctx->ccid3hctx_x != old_x)
|   		ccid3_pr_debug("X_prev=%llu, X_now=%llu, X_calc=%u, "
|   			       "X_recv=%llu\n", old_x >> 6, hctx->ccid3hctx_x >> 6,
|   			       hctx->ccid3hctx_x_calc, hctx->ccid3hctx_x_recv >> 6);
|  -
|  -		ccid3_update_send_time(hctx);
|  -	}
|   }
|   
|   /*
|  @@ -344,6 +337,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
|   
|   		/* Set t_0 for initial packet */
|   		hctx->ccid3hctx_t_nom = now;
|  +		timeval_add_usecs(&hctx->ccid3hctx_t_nom,
|  +		   hctx->ccid3hctx_t_ipi);
|   		break;
|   	case TFRC_SSTATE_NO_FBACK:
|   	case TFRC_SSTATE_FBACK:
|  @@ -361,6 +356,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
|   			return delay / 1000L;
|   
|   		ccid3_hc_tx_update_win_count(hctx, &now);
|  +		ccid3_update_send_time(hctx);
|   		break;
|   	case TFRC_SSTATE_TERM:
|   		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
|  @@ -371,9 +367,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
|   	dp->dccps_hc_tx_insert_options = 1;
|   	DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid3hctx_last_win_count;
|   
|  -	/* set the nominal send time for the next following packet */
|  -	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
|  -
|   	return 0;
|   }
|   
|  @@ -486,6 +479,11 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
|   			hctx->ccid3hctx_x    = scaled_div(w_init << 6, r_sample);
|   			hctx->ccid3hctx_t_ld = now;
|   
|  +
|  +			/* adjust down from initial 1 second now we have rtt */
|  +			timeval_sub_usecs(&hctx->ccid3hctx_t_nom,
|  +			   hctx->ccid3hctx_t_ipi);
|  +
|   			ccid3_update_send_time(hctx);
|   
|   			ccid3_pr_debug("%s(%p), s=%u, MSS=%u, w_init=%u, "
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
