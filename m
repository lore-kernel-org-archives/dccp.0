From: Eddie Kohler <kohler@cs.ucla.edu>
Date: Thu, 04 Jan 2007 23:25:45 +0000
Subject: Re: [PATCH 2/5]: DCCP Recalc on non-loss intervals
Message-Id: <459D8CF9.9060506@cs.ucla.edu>
List-Id: <dccp.vger.kernel.org>
References: <200612201545.39441.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201545.39441.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Guys,

I can't follow this code 100%, but here is an analysis of what I can 
understand.  Summary: Ian is correct (I think).

 From Ian's patch, it appears that the OLD code DID NOT include the most 
recent loss interval (i.e., the incomplete loss interval, the one that has no 
losses) in its calculation of i_tot1.  Ian has added the following line to do 
this:

 > +	i_tot1 += non_loss * dccp_li_hist_w[0];

This is correct.  The RFC requires that one of the i_tots include the 
incomplete loss interval.  So this part of the patch is required for RFC 
compliance.

I am assuming however that the incomplete loss interval is NOT included in the 
'hcrx->ccid3hcrx_li_hist' list.  If that list DOES include the incomplete loss 
interval, then the code would need to be different.

I don't quite get why one needs dccp_li_hist_recalc_recalcloss.  One could do 
probably do that simpler, and maybe Ian can explain his reasoning.  Why is it 
necessary at all?  But RFC3448 does require that one use the incomplete loss 
interval in the i_tot calculations.

One nit.  If you are following RFC terminology i_tot0 should include non_loss, 
but in the code i_tot1 does.  The code seems correct except for the switching 
of i_tot0 and i_tot1.

Eddie



Ian McDonald wrote:
> This works out when to recalculate the loss rate due to significant
> non-loss interval. We do this at time of recalulating loss rate to save
> having to do it every packet. Instead we just check if it's time to
> recalculate. It looked like there was an early attempt to do this but it
> was quite wrong in its implementation.
> 
> This is making the code conform to RFC 3448, section 5.4
> 
> I've added some extra debugging which is useful in testing as well. In
> loss_interval.c I've just used dccp_pr_debug. I tried to use ccid3_pr_debug
> but ran into problems with circular references.
> 
> This patch applies on top of Gerrit's patches.
> 
> If possible I'd like this to go into 2.6.21 as it's been reported broken by
> about 4 or 5 people.
> 
> Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
> ---
> diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
> index e7eeeeb..a74f905 100644
> --- a/net/dccp/ccids/ccid3.c
> +++ b/net/dccp/ccids/ccid3.c
> @@ -36,9 +36,9 @@
>  #include "../ccid.h"
>  #include "../dccp.h"
>  #include "lib/packet_history.h"
> -#include "lib/loss_interval.h"
>  #include "lib/tfrc.h"
>  #include "ccid3.h"
> +#include "lib/loss_interval.h"
>  
>  static struct dccp_tx_hist *ccid3_tx_hist;
>  static struct dccp_rx_hist *ccid3_rx_hist;
> @@ -384,6 +384,9 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
>  	packet->dccphtx_rtt    = hctx->ccid3hctx_rtt;
>  	packet->dccphtx_sent   = 1;
>  	hctx->ccid3hctx_idle   = 0;
> +
> +	ccid3_pr_debug("seqno = %llu, rtt = %u\n",
> +	   (long long unsigned)packet->dccphtx_seqno, packet->dccphtx_rtt);
>  }
>  
>  static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
> @@ -810,7 +813,7 @@ static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
>   *
>   * returns estimated loss interval in usecs */
>  
> -static u32 ccid3_hc_rx_calc_first_li(struct sock *sk)
> +static u32 ccid3_hc_rx_calc_first_li(struct sock *sk, struct sk_buff *skb)
>  {
>  	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
>  	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
> @@ -901,13 +904,31 @@ found:
>  	ccid3_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
>  		       "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
>  
> -	if (p = 0)
> +	if (p = 0) {
> +		DCCP_WARN("p=0, fval = %llu\n", fval);
>  		return ~0;
> -	else
> -		return 1000000 / p;
> +	} else {
> +		u32 new_interval = 1000000 / p;
> +		u64 recalc_interval;
> +
> +		if (new_interval < 150)
> +			recalc_interval = new_interval + 1;
> +		else
> +			recalc_interval = (new_interval *
> +			(DCCP_RECALC_LOSS_FACTOR+1)) / DCCP_RECALC_LOSS_FACTOR;
> +		hcrx->ccid3hcrx_seq_recalc_loss = dccp_hdr_seq(skb);
> +		add48(&hcrx->ccid3hcrx_seq_recalc_loss, recalc_interval);
> +		ccid3_pr_debug("%s(%p), interval=%u, recalc_interval=%llu, "
> +		   "seqno=%llu recalc_loss=%llu\n", dccp_role(sk), sk,
> +		   new_interval, recalc_interval, dccp_hdr_seq(skb),
> +		   hcrx->ccid3hcrx_seq_recalc_loss);
> +
> +		return new_interval;
> +	}
>  }
>  
> -static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
> +static void ccid3_hc_rx_update_li(struct sock *sk, struct sk_buff *skb,
> +                                  u64 seq_loss, u8 win_loss)
>  {
>  	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
>  	struct dccp_li_hist_entry *head;
> @@ -920,7 +941,7 @@ static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
>  
>  		head = list_entry(hcrx->ccid3hcrx_li_hist.next,
>  		   struct dccp_li_hist_entry, dccplih_node);
> -		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk);
> +		head->dccplih_interval = ccid3_hc_rx_calc_first_li(sk, skb);
>  	} else {
>  		struct dccp_li_hist_entry *entry;
>  		struct list_head *tail;
> @@ -951,10 +972,12 @@ static void ccid3_hc_rx_update_li(struct sock *sk, u64 seq_loss, u8 win_loss)
>  		entry->dccplih_seqno = seq_loss;
>  		entry->dccplih_interval = seq_temp;
>  		entry->dccplih_win_count = win_loss;
> +		ccid3_pr_debug("adding node seqno=%llu, interval=%u\n",
> +		   (u64)entry->dccplih_seqno, entry->dccplih_interval);
>  	}
>  }
>  
> -static int ccid3_hc_rx_detect_loss(struct sock *sk,
> +static int ccid3_hc_rx_detect_loss(struct sock *sk, struct sk_buff *skb,
>                                      struct dccp_rx_hist_entry *packet)
>  {
>  	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
> @@ -979,7 +1002,7 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
>  	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
>  	   > TFRC_RECV_NUM_LATE_LOSS) {
>  		loss = 1;
> -		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
> +		ccid3_hc_rx_update_li(sk, skb, hcrx->ccid3hcrx_seqno_nonloss,
>  		   hcrx->ccid3hcrx_ccval_nonloss);
>  		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
>  		dccp_inc_seqno(&tmp_seqno);
> @@ -1067,7 +1090,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
>  		return;
>  	}
>  
> -	loss = ccid3_hc_rx_detect_loss(sk, packet);
> +	loss = ccid3_hc_rx_detect_loss(sk, skb, packet);
>  
>  	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
>  		return;
> @@ -1088,6 +1111,15 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
>  		if (loss)
>  			break;
>  
> +		if (hcrx->ccid3hcrx_seq_recalc_loss &&
> +		 after48(dccp_hdr_seq(skb), hcrx->ccid3hcrx_seq_recalc_loss)) {
> +			ccid3_pr_debug("%s(%p, state=%s) checking loss "
> +			   "recalc skb=%llu, recalc_loss = %llu\n",
> +			   dccp_role(sk), sk, dccp_state_name(sk->sk_state),
> +			   dccp_hdr_seq(skb),hcrx->ccid3hcrx_seq_recalc_loss);
> +			break;
> +		}
> +
>  		dccp_timestamp(sk, &now);
>  		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
>  		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
> @@ -1100,15 +1132,16 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
>  		return;
>  	}
>  
> -	/* Dealing with packet loss */
> -	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
> +	/* Dealing with loss intervals*/
> +	if (loss)
> +		ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
>  		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
>  
>  	p_prev = hcrx->ccid3hcrx_p;
>  	
>  	/* Calculate loss event rate */
>  	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
> -		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
> +		u32 i_mean = dccp_li_hist_calc_i_mean(hcrx, skb);
>  
>  		/* Scaling up by 1000000 as fixed decimal */
>  		if (i_mean != 0)
> @@ -1116,7 +1149,9 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
>  	} else
>  		DCCP_BUG("empty loss history");
>  
> -	if (hcrx->ccid3hcrx_p > p_prev) {
> +	if (hcrx->ccid3hcrx_p != p_prev) {
> +		ccid3_pr_debug("p_prev = %u, hcrx_p = %u\n", p_prev,
> +		   hcrx->ccid3hcrx_p);
>  		ccid3_hc_rx_send_feedback(sk);
>  		return;
>  	}
> @@ -1135,6 +1170,7 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
>  	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
>  	hcrx->ccid3hcrx_s   = 0;
>  	hcrx->ccid3hcrx_rtt = 0;
> +	hcrx->ccid3hcrx_seqno_nonloss = 0;
>  	return 0;
>  }
>  
> diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
> index 2b18db4..99182bf 100644
> --- a/net/dccp/ccids/ccid3.h
> +++ b/net/dccp/ccids/ccid3.h
> @@ -158,6 +158,7 @@ enum ccid3_hc_rx_states {
>   *  @ccid3hcrx_s  -  Received packet size in bytes
>   *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
>   *  @ccid3hcrx_elapsed_time  -  Time since packet reception
> + *  @ccid3hcrx_seq_recalc_loss - recalc loss due to nonloss (RFC 3448, 5.4)
>   */
>  struct ccid3_hc_rx_sock {
>  	struct tfrc_rx_info		ccid3hcrx_tfrc;
> @@ -176,6 +177,7 @@ struct ccid3_hc_rx_sock {
>  	u16				ccid3hcrx_s;
>  	u32				ccid3hcrx_pinv;
>  	u32				ccid3hcrx_elapsed_time;
> +	u64				ccid3hcrx_seq_recalc_loss;
>  };
>  
>  static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
> diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
> index 372d7e7..cd03ae0 100644
> --- a/net/dccp/ccids/lib/loss_interval.c
> +++ b/net/dccp/ccids/lib/loss_interval.c
> @@ -14,6 +14,7 @@
>  #include <linux/module.h>
>  #include <net/sock.h>
>  #include "../../dccp.h"
> +#include "../ccid3.h"
>  #include "loss_interval.h"
>  
>  struct dccp_li_hist *dccp_li_hist_new(const char *name)
> @@ -81,31 +82,106 @@ static const int dccp_li_hist_w[DCCP_LI_HIST_IVAL_F_LENGTH] = {
>  	4, 4, 4, 4, 3, 2, 1, 1,
>  };
>  
> -u32 dccp_li_hist_calc_i_mean(struct list_head *list)
> +/* This code implements the part of section 5.4 of RFC3448 which says we should
> + * recalculate the average loss interval if we have a sufficient long loss
> + * interval.
> + *
> + * Given that i_mean = weighted average of loss then we can say that
> + * 4*n + 4*i[0] + 4*i[1] + 4*i[2] + 3*i[3] + 2*i[4] + i[5] + i[6] > + *  y*(4*i[0] + 4*i[i] + 4*i[2] + 4*i[3] + 3*i[4]+ 2*i[5] + i[6] + i[7])
> + *
> + * where y is a factor so that we don't check as soon as we hit average
> + * interval and waste CPU cycles needlessly. n is the non-loss interval
> + * and i[x] are the loss intervals. We don't need to divide by the sum
> + * of the weighting as these cancel out on each side.
> + *
> + * We can solve for this equation for n which yields:
> + * n > + *  ((4*i[0] + 4*i[1] + 4*i[2] + 4*i[3] + 3*i[4]+ 2*i[5] + i[6] + i[7])/4) -
> + *  (y*(4*i[0] + 4*i[1] + 4*i[2] + 3*i[3] + 2*i[4] + i[5] + i[6])/4) */
> +
> +static u64 dccp_li_hist_recalc_recalcloss(struct sk_buff *skb,
> +                                        u32 i_tot0, u32 i_tot1)
> +{
> +	u64 recalcloss_seq = dccp_hdr_seq(skb);
> +
> +	dccp_pr_debug("recalcloss_seq=%llu\n", recalcloss_seq);
> +
> +	if (!i_tot0) {
> +		DCCP_WARN("i_tot0 = 0\n");
> +		return 0;
> +	}
> +
> +	/* We don't adjust if > 1 million as will get overflow
> +	 * in calculations and not so serious anyway */
> +	if (i_tot0 > 1000000) {
> +		DCCP_WARN("i_mean > 100000\n");
> +		return 0;
> +	}
> +
> +	i_tot0 /= 4;
> +	i_tot1 = (i_tot1 * (DCCP_RECALC_LOSS_FACTOR+1))/
> +	   (DCCP_RECALC_LOSS_FACTOR*4);
> +
> +	if (i_tot1 >= i_tot0) {
> +		dccp_pr_debug("only incrementing by 1\n");
> +		add48(&recalcloss_seq, 1);
> +	} else
> +		add48(&recalcloss_seq,(u64)(i_tot0 - i_tot1));
> +
> +	dccp_pr_debug("recalcloss_seq=%llu, i_tot0=%u, i_tot1=%u\n",
> +	   recalcloss_seq, i_tot0, i_tot1);
> +
> +	return recalcloss_seq;
> +}
> +
> +u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx, struct sk_buff *skb)
>  {
>  	struct dccp_li_hist_entry *li_entry, *li_next;
> -	int i = 0;
> +	unsigned int i = 0;
>  	u32 i_tot;
>  	u32 i_tot0 = 0;
>  	u32 i_tot1 = 0;
>  	u32 w_tot  = 0;
> +	u64 non_loss = 0;
> +	u32 i_mean;
> +	struct list_head *list = &hcrx->ccid3hcrx_li_hist;
>  
>  	list_for_each_entry_safe(li_entry, li_next, list, dccplih_node) {
>  		if (li_entry->dccplih_interval != ~0U) {
>  			i_tot0 += li_entry->dccplih_interval * dccp_li_hist_w[i];
>  			w_tot  += dccp_li_hist_w[i];
> -			if (i != 0)
> -				i_tot1 += li_entry->dccplih_interval * dccp_li_hist_w[i - 1];
> -		}
> -
> +			if (i != 7)
> +				i_tot1 += li_entry->dccplih_interval
> +				   * dccp_li_hist_w[i + 1];
> +			if (i = 0) {
> +				non_loss = dccp_hdr_seq(skb);
> +				sub48(&non_loss, li_entry->dccplih_seqno);
> +			}
> +			dccp_pr_debug("i=%d, interval=%u, seqno=%llu, "
> +			  "i_tot0=%u, i_tot1=%u, w_tot=%u\n", i,
> +			  li_entry->dccplih_interval,
> +			  (u64)li_entry->dccplih_seqno,i_tot0, i_tot1, w_tot);
> +		} else
> +			dccp_pr_debug("empty loss interval\n");
>  
>  		if (++i > DCCP_LI_HIST_IVAL_F_LENGTH)
>  			break;
>  	}
>  
> -	if (i != DCCP_LI_HIST_IVAL_F_LENGTH)
> +	if (i != DCCP_LI_HIST_IVAL_F_LENGTH) {
> +		DCCP_BUG("Length of loss interval list is %u\n", i);
>  		return 0;
> +	}
>  
> +	hcrx->ccid3hcrx_seq_recalc_loss > +	   dccp_li_hist_recalc_recalcloss(skb, i_tot0, i_tot1);
> +
> +	i_tot1 += non_loss * dccp_li_hist_w[0];
> +	if (i_tot1 > i_tot0)
> +		dccp_pr_debug("i_mean recalculateed due to high nonloss "
> +		   " interval seqno=%llu nonloss=%llu i_tot0=%u, i_tot1=%u\n",
> +		   dccp_hdr_seq(skb), non_loss, i_tot0, i_tot1);
>  	i_tot = max(i_tot0, i_tot1);
>  
>  	if (!w_tot) {
> @@ -113,7 +189,10 @@ u32 dccp_li_hist_calc_i_mean(struct list_head *list)
>  		return 1;
>  	}
>  
> -	return i_tot / w_tot;
> +	i_mean = i_tot / w_tot;
> +	dccp_pr_debug("i_mean=%u\n", i_mean);
> +
> +	return i_mean;
>  }
>  
>  EXPORT_SYMBOL_GPL(dccp_li_hist_calc_i_mean);
> @@ -131,7 +210,7 @@ int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
>  			DCCP_BUG("loss interval list entry is NULL");
>  			return 0;
>  		}
> -		entry->dccplih_interval = ~0;
> +		entry->dccplih_interval = ~0U;
>  		list_add(&entry->dccplih_node, list);
>  	}
>  
> diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
> index eb25701..6fed81b 100644
> --- a/net/dccp/ccids/lib/loss_interval.h
> +++ b/net/dccp/ccids/lib/loss_interval.h
> @@ -50,7 +50,8 @@ static inline void dccp_li_hist_entry_delete(struct dccp_li_hist *hist,
>  extern void dccp_li_hist_purge(struct dccp_li_hist *hist,
>  			       struct list_head *list);
>  
> -extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
> +extern u32 dccp_li_hist_calc_i_mean(struct ccid3_hc_rx_sock *hcrx,
> +   struct sk_buff *skb);
>  
>  extern int dccp_li_hist_interval_new(struct dccp_li_hist *hist,
>     struct list_head *list, const u64 seq_loss, const u8 win_loss);
> diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
> index dd0a986..546ca70 100644
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -80,6 +80,11 @@ extern void dccp_time_wait(struct sock *sk, int state, int timeo);
>  
>  #define DCCP_RTO_MAX ((unsigned)(120 * HZ)) /* FIXME: using TCP value */
>  
> +/* Value as a reciprocal to check for change in loss through long
> + * non-loss intervals. If you change this you must recheck existing
> + * code for overflow possibilities */
> +#define DCCP_RECALC_LOSS_FACTOR 100
> +
>  /* sysctl variables for DCCP */
>  extern int  sysctl_dccp_request_retries;
>  extern int  sysctl_dccp_retries1;
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
