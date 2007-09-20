From: "=?ISO-2022-JP?B?GyRCJUQbKEIgTGVhbmRybyBTYWxlcw==?="
Date: Thu, 20 Sep 2007 17:49:50 +0000
Subject: Re: [PATCH 2/5] CCID 4: Clone existing implementation of CCID 3 into ccid4.[ch]
Message-Id: <5bc4c4570709201049k62bdf5e6v19ced526cbfe75c7@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20070920112321.GA26233@kikai.katei.fi>
In-Reply-To: <20070920112321.GA26233@kikai.katei.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/9/20, Tommi Saviranta <wnd@iki.fi>:
> (Yup, it is less than 40 KiB.)
>
>
> Signed-off-by: Tommi Saviranta <wnd@iki.fi>
>
> ---
> diff --git a/net/dccp/ccids/ccid4.c b/net/dccp/ccids/ccid4.c
> new file mode 100644
> index 0000000..7610c6e
> --- /dev/null
> +++ b/net/dccp/ccids/ccid4.c
> @@ -0,0 +1,984 @@
> +/*
> + *  net/dccp/ccids/ccid4.c
> + *
> + *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
> + *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
> + *  Copyright (c) 2005-7 Ian McDonald <ian.mcdonald@jandi.co.nz>
> + *
> + *  An implementation of the DCCP protocol
> + *
> + *  This code has been developed by the University of Waikato WAND
> + *  research group. For further information please see http://www.wand.net.nz/
> + *
> + *  This code also uses code from Lulea University, rereleased as GPL by its
> + *  authors:
> + *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
> + *
> + *  Changes to meet Linux coding standards, to make it meet latest ccid4 draft
> + *  and to make it work as a loadable module in the DCCP stack written by
> + *  Arnaldo Carvalho de Melo <acme@conectiva.com.br>.
> + *
> + *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include "../dccp.h"
> +#include "ccid4.h"
> +
> +#ifdef CONFIG_IP_DCCP_CCID4_DEBUG
> +static int ccid4_debug;
> +#define ccid4_pr_debug(format, a...)   DCCP_PR_DEBUG(ccid4_debug, format, ##a)
> +#else
> +#define ccid4_pr_debug(format, a...)
> +#endif
> +
> +DECLARE_TFRC_TX_CACHE(ccid4_tx_hist);
> +
> +/*
> + *     Transmitter Half-Connection Routines
> + */
> +#ifdef CONFIG_IP_DCCP_CCID4_DEBUG
> +static const char *ccid4_tx_state_name(enum ccid4_hc_tx_states state)
> +{
> +       static char *ccid4_state_names[] = {
> +       [TFRC_SSTATE_NO_SENT]  = "NO_SENT",
> +       [TFRC_SSTATE_NO_FBACK] = "NO_FBACK",
> +       [TFRC_SSTATE_FBACK]    = "FBACK",
> +       [TFRC_SSTATE_TERM]     = "TERM",
> +       };
> +
> +       return ccid4_state_names[state];
> +}
> +#endif
> +
> +static void ccid4_hc_tx_set_state(struct sock *sk,
> +                                 enum ccid4_hc_tx_states state)
> +{
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       enum ccid4_hc_tx_states oldstate = hctx->ccid4hctx_state;
> +
> +       ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
> +                      dccp_role(sk), sk, ccid4_tx_state_name(oldstate),
> +                      ccid4_tx_state_name(state));
> +       WARN_ON(state = oldstate);
> +       hctx->ccid4hctx_state = state;
> +}
> +
> +/*
> + * Compute the initial sending rate X_init in the manner of RFC 3390:
> + *
> + *     X_init  =  min(4 * s, max(2 * s, 4380 bytes)) / RTT
> + *
> + * Note that RFC 3390 uses MSS, RFC 4342 refers to RFC 3390, and rfc3448bis
> + * (rev-02) clarifies the use of RFC 3390 with regard to the above formula.
> + * For consistency with other parts of the code, X_init is scaled by 2^6.
> + */
> +static inline u64 rfc3390_initial_rate(struct sock *sk)
> +{
> +       const struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       const __u32 w_init = min_t(__u32, 4 * hctx->ccid4hctx_s,
> +                                  max_t(__u32, 2 * hctx->ccid4hctx_s, 4380));
> +
> +       return scaled_div(w_init << 6, hctx->ccid4hctx_rtt);
> +}
> +
> +/*
> + * Recalculate t_ipi and delta (should be called whenever X changes)
> + */
> +static inline void ccid4_update_send_interval(struct ccid4_hc_tx_sock *hctx)
> +{
> +       /* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
> +       hctx->ccid4hctx_t_ipi = scaled_div32(((u64)hctx->ccid4hctx_s) << 6,
> +                                            hctx->ccid4hctx_x);
> +
> +       /* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
> +       hctx->ccid4hctx_delta = min_t(u32, hctx->ccid4hctx_t_ipi / 2,
> +                                          TFRC_OPSYS_HALF_TIME_GRAN);
> +
> +       ccid4_pr_debug("t_ipi=%u, delta=%u, s=%u, X=%u\n",
> +                      hctx->ccid4hctx_t_ipi, hctx->ccid4hctx_delta,
> +                      hctx->ccid4hctx_s, (unsigned)(hctx->ccid4hctx_x >> 6));
> +
> +}
> +
> +static u32 ccid4_hc_tx_idle_rtt(struct ccid4_hc_tx_sock *hctx, ktime_t now)
> +{
> +       u32 delta = ktime_us_delta(now, hctx->ccid4hctx_t_last_win_count);
> +
> +       return delta/hctx->ccid4hctx_rtt;
> +}
> +
> +/**
> + * ccid4_hc_tx_update_x  -  Update allowed sending rate X
> + * @stamp: most recent time if available - can be left NULL.
> + * This function tracks draft rfc3448bis, check there for latest details.
> + *
> + * Note: X and X_recv are both stored in units of 64 * bytes/second, to support
> + *       fine-grained resolution of sending rates. This requires scaling by 2^6
> + *       throughout the code. Only X_calc is unscaled (in bytes/second).
> + *
> + */
> +static void ccid4_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
> +
> +{
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       __u64 min_rate = 2 * hctx->ccid4hctx_x_recv;
> +       const  __u64 old_x = hctx->ccid4hctx_x;
> +       ktime_t now = stamp? *stamp : ktime_get_real();
> +
> +       /*
> +        * Handle IDLE periods: do not reduce below RFC3390 initial sending rate
> +        * when idling [RFC 4342, 5.1]. Definition of idling is from rfc3448bis:
> +        * a sender is idle if it has not sent anything over a 2-RTT-period.
> +        * For consistency with X and X_recv, min_rate is also scaled by 2^6.
> +        */
> +       if (ccid4_hc_tx_idle_rtt(hctx, now) >= 2) {
> +               min_rate = rfc3390_initial_rate(sk);
> +               min_rate = max(min_rate, 2 * hctx->ccid4hctx_x_recv);
> +       }
> +
> +       if (hctx->ccid4hctx_p > 0) {
> +
> +               hctx->ccid4hctx_x = min(((__u64)hctx->ccid4hctx_x_calc) << 6,
> +                                       min_rate);
> +               hctx->ccid4hctx_x = max(hctx->ccid4hctx_x,
> +                                       (((__u64)hctx->ccid4hctx_s) << 6) /
> +                                                               TFRC_T_MBI);
> +
> +       } else if (ktime_us_delta(now, hctx->ccid4hctx_t_ld)
> +                               - (s64)hctx->ccid4hctx_rtt >= 0) {
> +
> +               hctx->ccid4hctx_x > +                       max(min(2 * hctx->ccid4hctx_x, min_rate),
> +                           scaled_div(((__u64)hctx->ccid4hctx_s) << 6,
> +                                      hctx->ccid4hctx_rtt));
> +               hctx->ccid4hctx_t_ld = now;
> +       }
> +
> +       if (hctx->ccid4hctx_x != old_x) {
> +               ccid4_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
> +                              "X_recv=%u\n", (unsigned)(old_x >> 6),
> +                              (unsigned)(hctx->ccid4hctx_x >> 6),
> +                              hctx->ccid4hctx_x_calc,
> +                              (unsigned)(hctx->ccid4hctx_x_recv >> 6));
> +
> +               ccid4_update_send_interval(hctx);
> +       }
> +}
> +
> +/*
> + *     Track the mean packet size `s' (cf. RFC 4342, 5.3 and  RFC 3448, 4.1)
> + *     @len: DCCP packet payload size in bytes
> + */
> +static inline void ccid4_hc_tx_update_s(struct ccid4_hc_tx_sock *hctx, int len)
> +{
> +       const u16 old_s = hctx->ccid4hctx_s;
> +
> +       hctx->ccid4hctx_s = tfrc_ewma(hctx->ccid4hctx_s, len, 9);
> +
> +       if (hctx->ccid4hctx_s != old_s)
> +               ccid4_update_send_interval(hctx);
> +}
> +
> +/*
> + *     Update Window Counter using the algorithm from [RFC 4342, 8.1].
> + *     The algorithm is not applicable if RTT < 4 microseconds.
> + */
> +static inline void ccid4_hc_tx_update_win_count(struct ccid4_hc_tx_sock *hctx,
> +                                               ktime_t now)
> +{
> +       u32 quarter_rtts;
> +
> +       if (unlikely(hctx->ccid4hctx_rtt < 4))  /* avoid divide-by-zero */
> +               return;
> +
> +       quarter_rtts = ktime_us_delta(now, hctx->ccid4hctx_t_last_win_count);
> +       quarter_rtts /= hctx->ccid4hctx_rtt / 4;
> +
> +       if (quarter_rtts > 0) {
> +               hctx->ccid4hctx_t_last_win_count = now;
> +               hctx->ccid4hctx_last_win_count  += min_t(u32, quarter_rtts, 5);
> +               hctx->ccid4hctx_last_win_count  &= 0xF;         /* mod 16 */
> +       }
> +}
> +
> +static void ccid4_hc_tx_no_feedback_timer(unsigned long data)
> +{
> +       struct sock *sk = (struct sock *)data;
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       unsigned long t_nfb = USEC_PER_SEC / 5;
> +
> +       bh_lock_sock(sk);
> +       if (sock_owned_by_user(sk)) {
> +               /* Try again later. */
> +               /* XXX: set some sensible MIB */
> +               goto restart_timer;
> +       }
> +
> +       ccid4_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
> +                      ccid4_tx_state_name(hctx->ccid4hctx_state));
> +
> +       if (hctx->ccid4hctx_state = TFRC_SSTATE_FBACK)
> +               ccid4_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
> +       else if (hctx->ccid4hctx_state != TFRC_SSTATE_NO_FBACK)
> +               goto out;
> +
> +       /*
> +        * Determine new allowed sending rate X as per draft rfc3448bis, 4.4
> +        */
> +       if (hctx->ccid4hctx_t_rto = 0 ||       /* no feedback received yet */
> +           hctx->ccid4hctx_p = 0       ) {
> +
> +               /* halve send rate directly */
> +               hctx->ccid4hctx_x = max(hctx->ccid4hctx_x / 2,
> +                                       (((__u64)hctx->ccid4hctx_s) << 6) /
> +                                                                   TFRC_T_MBI);
> +               ccid4_update_send_interval(hctx);
> +       } else {
> +               /*
> +                *  Modify the cached value of X_recv
> +                *
> +                *  If (X_calc > 2 * X_recv)
> +                *    X_recv = max(X_recv / 2, s / (2 * t_mbi));
> +                *  Else
> +                *    X_recv = X_calc / 4;
> +                *
> +                *  Note that X_recv is scaled by 2^6 while X_calc is not
> +                */
> +               BUG_ON(hctx->ccid4hctx_p && !hctx->ccid4hctx_x_calc);
> +
> +               if (hctx->ccid4hctx_x_calc > (hctx->ccid4hctx_x_recv >> 5))
> +                       hctx->ccid4hctx_x_recv > +                               max(hctx->ccid4hctx_x_recv / 2,
> +                                   (((__u64)hctx->ccid4hctx_s) << 6) /
> +                                                             (2 * TFRC_T_MBI));
> +               else {
> +                       hctx->ccid4hctx_x_recv = hctx->ccid4hctx_x_calc;
> +                       hctx->ccid4hctx_x_recv <<= 4;
> +               }
> +               ccid4_hc_tx_update_x(sk, NULL);
> +       }
> +       ccid4_pr_debug("Reduced X to %llu/64 bytes/sec\n",
> +                       (unsigned long long)hctx->ccid4hctx_x);
> +
> +       /*
> +        * Set new timeout for the nofeedback timer.
> +        * See comments in packet_recv() regarding the value of t_RTO.
> +        */
> +       if (unlikely(hctx->ccid4hctx_t_rto = 0))       /* no feedback yet */
> +               t_nfb = TFRC_INITIAL_TIMEOUT;
> +       else
> +               t_nfb = max(hctx->ccid4hctx_t_rto, 2 * hctx->ccid4hctx_t_ipi);
> +
> +restart_timer:
> +       sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
> +                          jiffies + usecs_to_jiffies(t_nfb));
> +out:
> +       bh_unlock_sock(sk);
> +       sock_put(sk);
> +}
> +
> +/*
> + * returns
> + *   > 0: delay (in msecs) that should pass before actually sending
> + *   = 0: can send immediately
> + *   < 0: error condition; do not send packet
> + */
> +static int ccid4_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
> +{
> +       struct dccp_sock *dp = dccp_sk(sk);
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       ktime_t now = ktime_get_real();
> +       s64 delay;
> +
> +       /*
> +        * This function is called only for Data and DataAck packets. Sending
> +        * zero-sized Data(Ack)s is theoretically possible, but for congestion
> +        * control this case is pathological - ignore it.
> +        */
> +       if (unlikely(skb->len = 0))
> +               return -EBADMSG;
> +
> +       switch (hctx->ccid4hctx_state) {
> +       case TFRC_SSTATE_NO_SENT:
> +               sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
> +                              (jiffies +
> +                               usecs_to_jiffies(TFRC_INITIAL_TIMEOUT)));
> +               hctx->ccid4hctx_last_win_count   = 0;
> +               hctx->ccid4hctx_t_last_win_count = now;
> +
> +               /* Set t_0 for initial packet */
> +               hctx->ccid4hctx_t_nom = now;
> +
> +               hctx->ccid4hctx_s = skb->len;
> +
> +               /*
> +                * Use initial RTT sample when available: recommended by erratum
> +                * to RFC 4342. This implements the initialisation procedure of
> +                * draft rfc3448bis, section 4.2. Remember, X is scaled by 2^6.
> +                */
> +               if (dp->dccps_syn_rtt) {
> +                       ccid4_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
> +                       hctx->ccid4hctx_rtt  = dp->dccps_syn_rtt;
> +                       hctx->ccid4hctx_x    = rfc3390_initial_rate(sk);
> +                       hctx->ccid4hctx_t_ld = now;
> +               } else {
> +                       /* Sender does not have RTT sample: X_pps = 1 pkt/sec */
> +                       hctx->ccid4hctx_x = hctx->ccid4hctx_s;
> +                       hctx->ccid4hctx_x <<= 6;
> +               }
> +               ccid4_update_send_interval(hctx);
> +
> +               ccid4_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
> +               break;
> +       case TFRC_SSTATE_NO_FBACK:
> +       case TFRC_SSTATE_FBACK:
> +               delay = ktime_us_delta(hctx->ccid4hctx_t_nom, now);
> +               ccid4_pr_debug("delay=%ld\n", (long)delay);
> +               /*
> +                *      Scheduling of packet transmissions [RFC 3448, 4.6]
> +                *
> +                * if (t_now > t_nom - delta)
> +                *       // send the packet now
> +                * else
> +                *       // send the packet in (t_nom - t_now) milliseconds.
> +                */
> +               if (delay - (s64)hctx->ccid4hctx_delta >= 1000)
> +                       return (u32)delay / 1000L;
> +
> +               ccid4_hc_tx_update_win_count(hctx, now);
> +               break;
> +       case TFRC_SSTATE_TERM:
> +               DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
> +               return -EINVAL;
> +       }
> +
> +       /* prepare to send now (add options etc.) */
> +       dp->dccps_hc_tx_insert_options = 1;
> +       DCCP_SKB_CB(skb)->dccpd_ccval = hctx->ccid4hctx_last_win_count;
> +
> +       /* set the nominal send time for the next following packet */
> +       hctx->ccid4hctx_t_nom = ktime_add_us(hctx->ccid4hctx_t_nom,
> +                                            hctx->ccid4hctx_t_ipi);
> +       return 0;
> +}
> +
> +static void ccid4_hc_tx_packet_sent(struct sock *sk, int more,
> +                                   unsigned int len)
> +{
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +
> +       ccid4_hc_tx_update_s(hctx, len);
> +
> +       if (tfrc_tx_hist_add(&hctx->ccid4hctx_hist, dccp_sk(sk)->dccps_gss))
> +               DCCP_CRIT("packet history - out of memory!");
> +}
> +
> +static void ccid4_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
> +{
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       struct ccid4_options_received *opt_recv;
> +       ktime_t t_send, now;
> +       unsigned long t_nfb;
> +       u32 pinv, r_sample;
> +
> +       /* we are only interested in ACKs */
> +       if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
> +             DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
> +               return;
> +
> +       /* ... and only in the established state */
> +       switch (hctx->ccid4hctx_state) {
> +       case TFRC_SSTATE_NO_FBACK:      /* fall through */
> +       case TFRC_SSTATE_FBACK:         break;
> +       default:                        return;
> +       }
> +
> +       /* estimate RTT from history if ACK number is valid */
> +       if (! tfrc_tx_hist_when(&t_send, &hctx->ccid4hctx_hist,
> +                               DCCP_SKB_CB(skb)->dccpd_ack_seq)) {
> +               DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
> +                         dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
> +                         (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
> +               return;
> +       }
> +
> +       opt_recv = &hctx->ccid4hctx_options_received;
> +
> +       /* Update receive rate in units of 64 * bytes/second */
> +       hctx->ccid4hctx_x_recv = opt_recv->ccid4or_receive_rate;
> +       hctx->ccid4hctx_x_recv <<= 6;
> +
> +       /* Update loss event rate (scaled by 1e6), cf. RFC 4342, 8.5 */
> +       pinv = opt_recv->ccid4or_loss_event_rate;
> +       hctx->ccid4hctx_p = (pinv = ~0U || pinv = 0)? 0 : scaled_div(1, pinv);
> +
> +       /*
> +        * Calculate new RTT sample and update moving average
> +        */
> +       now = ktime_get_real();
> +       r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, t_send));
> +       hctx->ccid4hctx_rtt = tfrc_ewma(hctx->ccid4hctx_rtt, r_sample, 9);
> +
> +       /*
> +        *      Update allowed sending rate X as per draft rfc3448bis, 4.2/4.3
> +        */
> +       if (hctx->ccid4hctx_state = TFRC_SSTATE_NO_FBACK) {
> +
> +               ccid4_hc_tx_set_state(sk, TFRC_SSTATE_FBACK);
> +
> +               if (hctx->ccid4hctx_t_rto = 0) {
> +                       /*
> +                        * Initial feedback packet: Larger Initial Windows (4.2)
> +                        */
> +                       hctx->ccid4hctx_x    = rfc3390_initial_rate(sk);
> +                       hctx->ccid4hctx_t_ld = now;
> +
> +                       ccid4_update_send_interval(hctx);
> +
> +                       goto done_computing_x;
> +
> +               } else if (hctx->ccid4hctx_p = 0) {
> +                       /*
> +                        * First feedback after nofeedback timer expiry (4.3)
> +                        */
> +                       goto done_computing_x;
> +               }
> +       }
> +       /* perform step (4) of draft rfc3448bis, section 4.3 */
> +       if (hctx->ccid4hctx_p > 0)
> +               hctx->ccid4hctx_x_calc = tfrc_calc_x(hctx->ccid4hctx_s,
> +                                                    hctx->ccid4hctx_rtt,
> +                                                    hctx->ccid4hctx_p);
> +       ccid4_hc_tx_update_x(sk, &now);
> +
> +done_computing_x:
> +       ccid4_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, p=%u, X_calc=%u, "
> +                      "X_recv=%u, X=%u\n", dccp_role(sk), sk,
> +                      hctx->ccid4hctx_rtt, r_sample, hctx->ccid4hctx_s,
> +                      hctx->ccid4hctx_p, hctx->ccid4hctx_x_calc,
> +                      (unsigned)(hctx->ccid4hctx_x_recv >> 6),
> +                      (unsigned)(hctx->ccid4hctx_x >> 6));
> +
> +       /* unschedule no feedback timer */
> +       sk_stop_timer(sk, &hctx->ccid4hctx_no_feedback_timer);
> +
> +       /*
> +        * As we have calculated new ipi, delta, t_nom it is possible
> +        * that we now can send a packet, so wake up dccp_wait_for_ccid
> +        */
> +       sk->sk_write_space(sk);
> +
> +       /*
> +        * Update timeout interval for the nofeedback timer.
> +        * We use a configuration option to increase the lower bound.
> +        * This can help avoid triggering the nofeedback timer too
> +        * often ('spinning') on LANs with small RTTs.
> +        */
> +       hctx->ccid4hctx_t_rto = max_t(u32, 4 * hctx->ccid4hctx_rtt,
> +                                          CONFIG_IP_DCCP_CCID4_RTO *
> +                                          (USEC_PER_SEC/1000));
> +       /*
> +        * Schedule no feedback timer to expire in
> +        * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
> +        */
> +       t_nfb = max(hctx->ccid4hctx_t_rto, 2 * hctx->ccid4hctx_t_ipi);
> +
> +       sk_reset_timer(sk, &hctx->ccid4hctx_no_feedback_timer,
> +                          jiffies + usecs_to_jiffies(t_nfb));
> +
> +       ccid4_pr_debug("Scheduled no feedback timer to expire in %lu jiffies"
> +                      "(%luus)\n", usecs_to_jiffies(t_nfb), t_nfb);
> +}
> +
> +static int ccid4_hc_tx_parse_options(struct sock *sk, unsigned char option,
> +                                    unsigned char len, u16 idx,
> +                                    unsigned char *value)
> +{
> +       int rc = 0;
> +       const struct dccp_sock *dp = dccp_sk(sk);
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       struct ccid4_options_received *opt_recv;
> +       u32 opt_val;
> +
> +       opt_recv = &hctx->ccid4hctx_options_received;
> +
> +       if (opt_recv->ccid4or_seqno != dp->dccps_gsr) {
> +               opt_recv->ccid4or_seqno              = dp->dccps_gsr;
> +               opt_recv->ccid4or_loss_event_rate    = ~0;
> +               opt_recv->ccid4or_loss_intervals_idx = 0;
> +               opt_recv->ccid4or_loss_intervals_len = 0;
> +               opt_recv->ccid4or_receive_rate       = 0;
> +       }
> +
> +       switch (option) {
> +       case TFRC_OPT_LOSS_EVENT_RATE:
> +               if (unlikely(len != 4)) {
> +                       DCCP_WARN("%s(%p), invalid len %d "
> +                                 "for TFRC_OPT_LOSS_EVENT_RATE\n",
> +                                 dccp_role(sk), sk, len);
> +                       rc = -EINVAL;
> +               } else {
> +                       opt_val = get_unaligned((u32 *)value);
> +                       opt_recv->ccid4or_loss_event_rate = ntohl(opt_val);
> +                       ccid4_pr_debug("%s(%p), LOSS_EVENT_RATE=%u\n",
> +                                      dccp_role(sk), sk,
> +                                      opt_recv->ccid4or_loss_event_rate);
> +               }
> +               break;
> +       case TFRC_OPT_LOSS_INTERVALS:
> +               opt_recv->ccid4or_loss_intervals_idx = idx;
> +               opt_recv->ccid4or_loss_intervals_len = len;
> +               ccid4_pr_debug("%s(%p), LOSS_INTERVALS=(%u, %u)\n",
> +                              dccp_role(sk), sk,
> +                              opt_recv->ccid4or_loss_intervals_idx,
> +                              opt_recv->ccid4or_loss_intervals_len);
> +               break;
> +       case TFRC_OPT_RECEIVE_RATE:
> +               if (unlikely(len != 4)) {
> +                       DCCP_WARN("%s(%p), invalid len %d "
> +                                 "for TFRC_OPT_RECEIVE_RATE\n",
> +                                 dccp_role(sk), sk, len);
> +                       rc = -EINVAL;
> +               } else {
> +                       opt_val = get_unaligned((u32 *)value);
> +                       opt_recv->ccid4or_receive_rate = ntohl(opt_val);
> +                       ccid4_pr_debug("%s(%p), RECEIVE_RATE=%u\n",
> +                                      dccp_role(sk), sk,
> +                                      opt_recv->ccid4or_receive_rate);
> +               }
> +               break;
> +       }
> +
> +       return rc;
> +}
> +
> +static int ccid4_hc_tx_init(struct ccid *ccid, struct sock *sk)
> +{
> +       struct ccid4_hc_tx_sock *hctx = ccid_priv(ccid);
> +
> +       hctx->ccid4hctx_state = TFRC_SSTATE_NO_SENT;
> +       tfrc_tx_hist_init(&hctx->ccid4hctx_hist, ccid4_tx_hist);
> +
> +       hctx->ccid4hctx_no_feedback_timer.function > +                               ccid4_hc_tx_no_feedback_timer;
> +       hctx->ccid4hctx_no_feedback_timer.data     = (unsigned long)sk;
> +       init_timer(&hctx->ccid4hctx_no_feedback_timer);
> +
> +       return 0;
> +}
> +
> +static void ccid4_hc_tx_exit(struct sock *sk)
> +{
> +       struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +
> +       ccid4_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
> +       sk_stop_timer(sk, &hctx->ccid4hctx_no_feedback_timer);
> +
> +       /* Empty packet history */
> +       tfrc_tx_hist_cleanup(&hctx->ccid4hctx_hist);
> +}
> +
> +static void ccid4_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
> +{
> +       const struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +
> +       /* Listen socks doesn't have a private CCID block */
> +       if (sk->sk_state = DCCP_LISTEN)
> +               return;
> +
> +       info->tcpi_rto = hctx->ccid4hctx_t_rto;
> +       info->tcpi_rtt = hctx->ccid4hctx_rtt;
> +}
> +
> +static int ccid4_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
> +                                 u32 __user *optval, int __user *optlen)
> +{
> +       const struct ccid4_hc_tx_sock *hctx = ccid4_hc_tx_sk(sk);
> +       const void *val;
> +
> +       /* Listen socks doesn't have a private CCID block */
> +       if (sk->sk_state = DCCP_LISTEN)
> +               return -EINVAL;
> +
> +       switch (optname) {
> +       case DCCP_SOCKOPT_CCID_TX_INFO:
> +               if (len < sizeof(hctx->ccid4hctx_tfrc))
> +                       return -EINVAL;
> +               len = sizeof(hctx->ccid4hctx_tfrc);
> +               val = &hctx->ccid4hctx_tfrc;
> +               break;
> +       default:
> +               return -ENOPROTOOPT;
> +       }
> +
> +       if (put_user(len, optlen) || copy_to_user(optval, val, len))
> +               return -EFAULT;
> +
> +       return 0;
> +}
> +
> +/*
> + *     Receiver Half-Connection Routines
> + */
> +#ifdef CONFIG_IP_DCCP_CCID4_DEBUG
> +static const char *ccid4_rx_state_name(enum ccid4_hc_rx_states state)
> +{
> +       static char *ccid4_rx_state_names[] = {
> +       [TFRC_RSTATE_NO_DATA] = "NO_DATA",
> +       [TFRC_RSTATE_DATA]    = "DATA",
> +       [TFRC_RSTATE_TERM]    = "TERM",
> +       };
> +
> +       return ccid4_rx_state_names[state];
> +}
> +#endif
> +
> +static void ccid4_hc_rx_set_state(struct sock *sk,
> +                                 enum ccid4_hc_rx_states state)
> +{
> +       struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +       enum ccid4_hc_rx_states oldstate = hcrx->ccid4hcrx_state;
> +
> +       ccid4_pr_debug("%s(%p) %-8.8s -> %s\n",
> +                      dccp_role(sk), sk, ccid4_rx_state_name(oldstate),
> +                      ccid4_rx_state_name(state));
> +       WARN_ON(state = oldstate);
> +       hcrx->ccid4hcrx_state = state;
> +}
> +
> +static inline void ccid4_hc_rx_update_s(struct ccid4_hc_rx_sock *hcrx, int len)
> +{
> +       if (likely(len > 0))    /* don't update on empty packets (e.g. ACKs) */
> +               hcrx->ccid4hcrx_s = tfrc_ewma(hcrx->ccid4hcrx_s, len, 9);
> +}
> +
> +static void ccid4_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb,
> +                                     enum ccid4_fback_type fbtype)
> +{
> +       struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +       struct dccp_sock *dp = dccp_sk(sk);
> +       ktime_t now = ktime_get_real();
> +       s64 delta = 0;
> +
> +       if (unlikely(hcrx->ccid4hcrx_state = TFRC_RSTATE_TERM))
> +               return;
> +
> +       switch (fbtype) {
> +       case FBACK_INITIAL:
> +               hcrx->ccid4hcrx_x_recv = 0;
> +               hcrx->ccid4hcrx_pinv   = ~0U;   /* see RFC 4342, 8.5 */
> +               break;
> +       case FBACK_PARAM_CHANGE:
> +               /*
> +                * When parameters change (new loss or p > p_prev), we do not
> +                * have a reliable estimate for R_m of [RFC 3448, 6.2] and so
> +                * need to  reuse the previous value of X_recv. However, when
> +                * X_recv was 0 (due to early loss), this would kill X down to
> +                * s/t_mbi (i.e. one packet in 64 seconds).
> +                * To avoid such drastic reduction, we approximate X_recv as
> +                * the number of bytes since last feedback.
> +                * This is a safe fallback, since X is bounded above by X_calc.
> +                */
> +               if (hcrx->ccid4hcrx_x_recv > 0)
> +                       break;
> +               /* fall through */
> +       case FBACK_PERIODIC:
> +               delta = ktime_us_delta(now, hcrx->ccid4hcrx_last_feedback);
> +               if (delta <= 0)
> +                       DCCP_BUG("delta (%ld) <= 0", (long)delta);
> +               else
> +                       hcrx->ccid4hcrx_x_recv > +                               scaled_div32(hcrx->ccid4hcrx_bytes_recv, delta);
> +               break;
> +       default:
> +               return;
> +       }
> +       ccid4_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
> +                      hcrx->ccid4hcrx_x_recv, hcrx->ccid4hcrx_pinv);
> +
> +       hcrx->ccid4hcrx_last_feedback = now;
> +       hcrx->ccid4hcrx_last_counter  = dccp_hdr(skb)->dccph_ccval;
> +       hcrx->ccid4hcrx_bytes_recv    = 0;
> +
> +       dp->dccps_hc_rx_insert_options = 1;
> +       dccp_send_ack(sk);
> +}
> +
> +static int ccid4_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
> +{
> +       const struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +       __be32 x_recv, pinv;
> +
> +       if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
> +               return 0;
> +
> +       if (dccp_packet_without_ack(skb))
> +               return 0;
> +
> +       x_recv = htonl(hcrx->ccid4hcrx_x_recv);
> +       pinv   = htonl(hcrx->ccid4hcrx_pinv);
> +
> +       if (dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
> +                              &pinv, sizeof(pinv)) ||
> +           dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
> +                              &x_recv, sizeof(x_recv)))
> +               return -1;
> +
> +       return 0;
> +}
> +
> +/** ccid4_first_li  -  Implements [RFC 3448, 6.3.1]
> + *
> + * Determine the length of the first loss interval via inverse lookup.
> + * Assume that X_recv can be computed by the throughput equation
> + *                 s
> + *     X_recv = --------
> + *              R * fval
> + * Find some p such that f(p) = fval; return 1/p (scaled).
> + */
> +static u32 ccid4_first_li(struct sock *sk)
> +{
> +       struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +       u32 x_recv, p, delta;
> +       u64 fval;
> +
> +       if (hcrx->ccid4hcrx_rtt = 0) {
> +               DCCP_WARN("No RTT estimate available, using fallback RTT\n");
> +               hcrx->ccid4hcrx_rtt = DCCP_FALLBACK_RTT;
> +       }
> +
> +       delta = ktime_to_us(net_timedelta(hcrx->ccid4hcrx_last_feedback));
> +       x_recv = scaled_div32(hcrx->ccid4hcrx_bytes_recv, delta);
> +       if (x_recv = 0) {              /* would also trigger divide-by-zero */
> +               DCCP_WARN("X_recv=0\n");
> +               if ((x_recv = hcrx->ccid4hcrx_x_recv) = 0) {
> +                       DCCP_BUG("stored value of X_recv is zero");
> +                       return ~0U;
> +               }
> +       }
> +
> +       fval = scaled_div(hcrx->ccid4hcrx_s, hcrx->ccid4hcrx_rtt);
> +       fval = scaled_div32(fval, x_recv);
> +       p = tfrc_calc_x_reverse_lookup(fval);
> +
> +       ccid4_pr_debug("%s(%p), receive rate=%u bytes/s, implied "
> +                      "loss rate=%u\n", dccp_role(sk), sk, x_recv, p);
> +
> +       return p = 0? ~0U : scaled_div(1, p);
> +}
> +
> +static void ccid4_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
> +{
> +       struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +       enum   ccid4_fback_type  do_feedback = FBACK_NONE;
> +       u32 sample, ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp,
> +           payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
> +       u8  is_data_packet = dccp_data_packet(skb);
> +
> +       spin_lock(&hcrx->ccid4hcrx_hist.lock);
> +
> +       if (unlikely(hcrx->ccid4hcrx_state = TFRC_RSTATE_NO_DATA)) {
> +               if (is_data_packet) {
> +                       do_feedback = FBACK_INITIAL;
> +                       ccid4_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
> +                       ccid4_hc_rx_update_s(hcrx, payload_size);
> +               }
> +               goto update_records;
> +       }
> +
> +       if (tfrc_rx_duplicate(&hcrx->ccid4hcrx_hist, skb))
> +               goto done_receiving;
> +
> +       if (is_data_packet) {
> +               ccid4_hc_rx_update_s(hcrx, payload_size);
> +               hcrx->ccid4hcrx_bytes_recv += payload_size;
> +       }
> +
> +       /*
> +        *      Handle pending losses and otherwise check for new loss
> +        */
> +       if (tfrc_rx_loss_pending(&hcrx->ccid4hcrx_hist) &&
> +           tfrc_rx_handle_loss(&hcrx->ccid4hcrx_hist,
> +                               &hcrx->ccid4hcrx_li_hist,
> +                               skb, ndp, ccid4_first_li, sk) ) {
> +               do_feedback = FBACK_PARAM_CHANGE;
> +               goto done_receiving;
> +       }
> +
> +       if (tfrc_rx_new_loss_indicated(&hcrx->ccid4hcrx_hist, skb, ndp))
> +               goto update_records;
> +
> +       /*
> +        *      Handle data packets: RTT sampling and monitoring p
> +        */
> +       if (unlikely(!is_data_packet))
> +               goto update_records;
> +
> +       if (! tfrc_lh_is_initialised(&hcrx->ccid4hcrx_li_hist)) {
> +               /*
> +                * Empty loss history: no loss so far, hence p stays 0.
> +                * Sample RTT values, since an RTT estimate is required for the
> +                * computation of p when the first loss occurs; RFC 3448, 6.3.1.
> +                */
> +               sample = tfrc_rx_sample_rtt(&hcrx->ccid4hcrx_hist, skb);
> +               if (sample != 0)
> +                       hcrx->ccid4hcrx_rtt > +                               tfrc_ewma(hcrx->ccid4hcrx_rtt, sample, 9);
> +
> +       } else if (tfrc_lh_update_i_mean(&hcrx->ccid4hcrx_li_hist, skb))
> +               /*
> +                * Step (3) of [RFC 3448, 6.1]: Recompute I_mean and, if I_mean
> +                * has decreased (resp. p has increased), send feedback now.
> +                */
> +               do_feedback = FBACK_PARAM_CHANGE;
> +
> +       /* check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3 */
> +       if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid4hcrx_last_counter) > 3)
> +               do_feedback = FBACK_PERIODIC;
> +
> +update_records:
> +       tfrc_rx_hist_update(&hcrx->ccid4hcrx_hist, skb, ndp);
> +
> +done_receiving:
> +       spin_unlock(&hcrx->ccid4hcrx_hist.lock);
> +
> +       if (do_feedback)
> +               ccid4_hc_rx_send_feedback(sk, skb, do_feedback);
> +}
> +
> +static int ccid4_hc_rx_init(struct ccid *ccid, struct sock *sk)
> +{
> +       struct ccid4_hc_rx_sock *hcrx = ccid_priv(ccid);
> +
> +       ccid4_pr_debug("entry\n");
> +
> +       tfrc_lh_init(&hcrx->ccid4hcrx_li_hist);
> +       hcrx->ccid4hcrx_state = TFRC_RSTATE_NO_DATA;
> +
> +       return tfrc_rx_hist_init(&hcrx->ccid4hcrx_hist);
> +}
> +
> +static void ccid4_hc_rx_exit(struct sock *sk)
> +{
> +       struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +
> +       ccid4_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
> +
> +       tfrc_rx_hist_cleanup(&hcrx->ccid4hcrx_hist);
> +       tfrc_lh_cleanup(&hcrx->ccid4hcrx_li_hist);
> +}
> +
> +static void ccid4_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
> +{
> +       const struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +
> +       /* Listen socks doesn't have a private CCID block */
> +       if (sk->sk_state = DCCP_LISTEN)
> +               return;
> +
> +       info->tcpi_ca_state = hcrx->ccid4hcrx_state;
> +       info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
> +       info->tcpi_rcv_rtt  = hcrx->ccid4hcrx_rtt;
> +}
> +
> +static int ccid4_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
> +                                 u32 __user *optval, int __user *optlen)
> +{
> +       const struct ccid4_hc_rx_sock *hcrx = ccid4_hc_rx_sk(sk);
> +       const void *val;
> +       struct tfrc_rx_info rx_info;
> +
> +       /* Listen socks don't have a private CCID block */
> +       if (sk->sk_state = DCCP_LISTEN)
> +               return -EINVAL;
> +
> +       switch (optname) {
> +       case DCCP_SOCKOPT_CCID_RX_INFO:
> +               if (len < sizeof(rx_info))
> +                       return -EINVAL;
> +               len = sizeof(rx_info);
> +               val = &rx_info;
> +               rx_info.tfrcrx_x_recv   = hcrx->ccid4hcrx_x_recv;
> +               rx_info.tfrcrx_rtt      = hcrx->ccid4hcrx_rtt;
> +               rx_info.tfrcrx_p        = hcrx->ccid4hcrx_pinv = 0? ~0U
> +                                       : scaled_div(1, hcrx->ccid4hcrx_pinv);
> +               break;
> +       default:
> +               return -ENOPROTOOPT;
> +       }
> +
> +       if (put_user(len, optlen) || copy_to_user(optval, val, len))
> +               return -EFAULT;
> +
> +       return 0;
> +}
> +
> +static struct ccid_operations ccid4 = {
> +       .ccid_id                   = DCCPC_CCID4,
> +       .ccid_name                 = "ccid4",
> +       .ccid_owner                = THIS_MODULE,
> +       .ccid_hc_tx_obj_size       = sizeof(struct ccid4_hc_tx_sock),
> +       .ccid_hc_tx_init           = ccid4_hc_tx_init,
> +       .ccid_hc_tx_exit           = ccid4_hc_tx_exit,
> +       .ccid_hc_tx_send_packet    = ccid4_hc_tx_send_packet,
> +       .ccid_hc_tx_packet_sent    = ccid4_hc_tx_packet_sent,
> +       .ccid_hc_tx_packet_recv    = ccid4_hc_tx_packet_recv,
> +       .ccid_hc_tx_parse_options  = ccid4_hc_tx_parse_options,
> +       .ccid_hc_rx_obj_size       = sizeof(struct ccid4_hc_rx_sock),
> +       .ccid_hc_rx_init           = ccid4_hc_rx_init,
> +       .ccid_hc_rx_exit           = ccid4_hc_rx_exit,
> +       .ccid_hc_rx_insert_options = ccid4_hc_rx_insert_options,
> +       .ccid_hc_rx_packet_recv    = ccid4_hc_rx_packet_recv,
> +       .ccid_hc_rx_get_info       = ccid4_hc_rx_get_info,
> +       .ccid_hc_tx_get_info       = ccid4_hc_tx_get_info,
> +       .ccid_hc_rx_getsockopt     = ccid4_hc_rx_getsockopt,
> +       .ccid_hc_tx_getsockopt     = ccid4_hc_tx_getsockopt,
> +};
> +
> +#ifdef CONFIG_IP_DCCP_CCID4_DEBUG
> +module_param(ccid4_debug, bool, 0444);
> +MODULE_PARM_DESC(ccid4_debug, "Enable debug messages");
> +#endif
> +
> +static __init int ccid4_module_init(void)
> +{
> +       int rc = -ENOBUFS;
> +
> +       if (tfrc_tx_cache_init(&ccid4_tx_hist, "ccid4"))
> +               goto out;
> +
> +       rc = ccid_register(&ccid4);
> +       if (rc != 0)
> +               tfrc_tx_cache_cleanup(ccid4_tx_hist);
> +out:
> +       return rc;
> +}
> +module_init(ccid4_module_init);
> +
> +static __exit void ccid4_module_exit(void)
> +{
> +       ccid_unregister(&ccid4);
> +
> +       if (ccid4_tx_hist != NULL)
> +               tfrc_tx_cache_cleanup(ccid4_tx_hist);
> +}
> +module_exit(ccid4_module_exit);
> +
> +MODULE_AUTHOR("Ian McDonald <ian.mcdonald@jandi.co.nz>, "
> +             "Arnaldo Carvalho de Melo <acme@ghostprotocols.net>");
> +MODULE_DESCRIPTION("DCCP TFRC CCID4 CCID");
> +MODULE_LICENSE("GPL");
> +MODULE_ALIAS("net-dccp-ccid-4");
> diff --git a/net/dccp/ccids/ccid4.h b/net/dccp/ccids/ccid4.h
> new file mode 100644
> index 0000000..d233f6d
> --- /dev/null
> +++ b/net/dccp/ccids/ccid4.h
> @@ -0,0 +1,177 @@
> +#ifndef _DCCP_CCID4_H_
> +#define _DCCP_CCID4_H_
> +/*
> + *  net/dccp/ccids/ccid4.h
> + *
> + *  Copyright (c) 2007   The University of Aberdeen, Scotland, UK
> + *  Copyright (c) 2005-7 The University of Waikato, Hamilton, New Zealand.
> + *
> + *  An implementation of the DCCP protocol
> + *
> + *  This code has been developed by the University of Waikato WAND
> + *  research group. For further information please see http://www.wand.net.nz/
> + *  or e-mail Ian McDonald - ian.mcdonald@jandi.co.nz
> + *
> + *  This code also uses code from Lulea University, rereleased as GPL by its
> + *  authors:
> + *  Copyright (c) 2003 Nils-Erik Mattsson, Joacim Haggmark, Magnus Erixzon
> + *
> + *  Changes to meet Linux coding standards, to make it meet latest ccid4 draft
> + *  and to make it work as a loadable module in the DCCP stack written by
> + *  Arnaldo Carvalho de Melo <acme@conectiva.com.br>.
> + *
> + *  Copyright (c) 2005 Arnaldo Carvalho de Melo <acme@conectiva.com.br>
> + *
> + *  This program is free software; you can redistribute it and/or modify
> + *  it under the terms of the GNU General Public License as published by
> + *  the Free Software Foundation; either version 2 of the License, or
> + *  (at your option) any later version.
> + *
> + *  This program is distributed in the hope that it will be useful,
> + *  but WITHOUT ANY WARRANTY; without even the implied warranty of
> + *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
> + *  GNU General Public License for more details.
> + *
> + *  You should have received a copy of the GNU General Public License
> + *  along with this program; if not, write to the Free Software
> + *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
> + */
> +#include <linux/ktime.h>
> +#include <linux/list.h>
> +#include <linux/types.h>
> +#include <linux/tfrc.h>
> +#include <asm/unaligned.h>
> +#include "lib/tfrc.h"
> +#include "../ccid.h"
> +
> +/* Two seconds as per RFC 3448 4.2 */
> +#define TFRC_INITIAL_TIMEOUT      (2 * USEC_PER_SEC)
> +
> +/* In usecs - half the scheduling granularity as per RFC3448 4.6 */
> +#define TFRC_OPSYS_HALF_TIME_GRAN  (USEC_PER_SEC / (2 * HZ))
> +
> +/* Parameter t_mbi from [RFC 3448, 4.3]: backoff interval in seconds */
> +#define TFRC_T_MBI                64
> +
> +enum ccid4_options {
> +       TFRC_OPT_LOSS_EVENT_RATE = 192,
> +       TFRC_OPT_LOSS_INTERVALS  = 193,
> +       TFRC_OPT_RECEIVE_RATE    = 194,
> +};
> +
> +struct ccid4_options_received {
> +       u64 ccid4or_seqno:48,
> +           ccid4or_loss_intervals_idx:16;
> +       u16 ccid4or_loss_intervals_len;
> +       u32 ccid4or_loss_event_rate;
> +       u32 ccid4or_receive_rate;
> +};
> +
> +/* TFRC sender states */
> +enum ccid4_hc_tx_states {
> +       TFRC_SSTATE_NO_SENT = 1,
> +       TFRC_SSTATE_NO_FBACK,
> +       TFRC_SSTATE_FBACK,
> +       TFRC_SSTATE_TERM,
> +};
> +
> +/** struct ccid4_hc_tx_sock - CCID4 sender half-connection socket
> + *
> + * @ccid4hctx_x - Current sending rate in 64 * bytes per second
> + * @ccid4hctx_x_recv - Receive rate    in 64 * bytes per second
> + * @ccid4hctx_x_calc - Calculated rate in bytes per second
> + * @ccid4hctx_rtt - Estimate of current round trip time in usecs
> + * @ccid4hctx_p - Current loss event rate (0-1) scaled by 1000000
> + * @ccid4hctx_s - Packet size in bytes
> + * @ccid4hctx_t_rto - Nofeedback Timer setting in usecs
> + * @ccid4hctx_t_ipi - Interpacket (send) interval (RFC 3448, 4.6) in usecs
> + * @ccid4hctx_state - Sender state, one of %ccid4_hc_tx_states
> + * @ccid4hctx_last_win_count - Last window counter sent
> + * @ccid4hctx_t_last_win_count - Timestamp of earliest packet
> + *                              with last_win_count value sent
> + * @ccid4hctx_no_feedback_timer - Handle to no feedback timer
> + * @ccid4hctx_t_ld - Time last doubled during slow start
> + * @ccid4hctx_t_nom - Nominal send time of next packet
> + * @ccid4hctx_delta - Send timer delta (RFC 3448, 4.6) in usecs
> + * @ccid4hctx_hist - Packet history
> + * @ccid4hctx_options_received - Parsed set of retrieved options
> + */
> +struct ccid4_hc_tx_sock {
> +       struct tfrc_tx_info             ccid4hctx_tfrc;
> +#define ccid4hctx_x                    ccid4hctx_tfrc.tfrctx_x
> +#define ccid4hctx_x_recv               ccid4hctx_tfrc.tfrctx_x_recv
> +#define ccid4hctx_x_calc               ccid4hctx_tfrc.tfrctx_x_calc
> +#define ccid4hctx_rtt                  ccid4hctx_tfrc.tfrctx_rtt
> +#define ccid4hctx_p                    ccid4hctx_tfrc.tfrctx_p
> +#define ccid4hctx_t_rto                        ccid4hctx_tfrc.tfrctx_rto
> +#define ccid4hctx_t_ipi                        ccid4hctx_tfrc.tfrctx_ipi
> +       u16                             ccid4hctx_s;
> +       enum ccid4_hc_tx_states         ccid4hctx_state:8;
> +       u8                              ccid4hctx_last_win_count;
> +       ktime_t                         ccid4hctx_t_last_win_count;
> +       struct timer_list               ccid4hctx_no_feedback_timer;
> +       ktime_t                         ccid4hctx_t_ld;
> +       ktime_t                         ccid4hctx_t_nom;
> +       u32                             ccid4hctx_delta;
> +       struct tfrc_tx_hist_head        ccid4hctx_hist;
> +       struct ccid4_options_received   ccid4hctx_options_received;
> +};
> +
> +static inline struct ccid4_hc_tx_sock *ccid4_hc_tx_sk(const struct sock *sk)
> +{
> +       void *ccid4_tx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
> +
> +       BUG_ON(ccid4_tx_priv = NULL);
> +       return ccid4_tx_priv;
> +}
> +
> +/* CCID4 receiver states */
> +enum ccid4_hc_rx_states {
> +       TFRC_RSTATE_NO_DATA = 1,
> +       TFRC_RSTATE_DATA,
> +       TFRC_RSTATE_TERM    = 127,
> +};
> +
> +/* CCID4 feedback types */
> +enum ccid4_fback_type {
> +       FBACK_NONE = 0,
> +       FBACK_INITIAL,
> +       FBACK_PERIODIC,
> +       FBACK_PARAM_CHANGE
> +};
> +
> +/** struct ccid4_hc_rx_sock - CCID4 receiver half-connection socket
> + *
> + *  @ccid4hcrx_last_counter  -  Tracks window counter (RFC 4342, 8.1)
> + *  @ccid4hcrx_state  -  Receiver state, one of %ccid4_hc_rx_states
> + *  @ccid4hcrx_bytes_recv  -  Total sum of DCCP payload bytes
> + *  @ccid4hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
> + *  @ccid4hcrx_rtt  -  Receiver estimate of RTT
> + *  @ccid4hcrx_last_feedback  -  Time at which last feedback was sent
> + *  @ccid4hcrx_hist  -  Packet history, exported by TFRC module
> + *  @ccid4hcrx_li_hist  -  Loss Interval database, exported by TFRC module
> + *  @ccid4hcrx_s  -  Received packet size in bytes
> + *  @ccid4hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
> + */
> +struct ccid4_hc_rx_sock {
> +       u8                              ccid4hcrx_last_counter:4;
> +       enum ccid4_hc_rx_states         ccid4hcrx_state:8;
> +       u32                             ccid4hcrx_bytes_recv;
> +       u32                             ccid4hcrx_x_recv;
> +       u32                             ccid4hcrx_rtt;
> +       ktime_t                         ccid4hcrx_last_feedback;
> +       struct tfrc_rx_hist             ccid4hcrx_hist;
> +       struct tfrc_loss_hist           ccid4hcrx_li_hist;
> +       u16                             ccid4hcrx_s;
> +#define ccid4hcrx_pinv                 ccid4hcrx_li_hist.i_mean
> +};
> +
> +static inline struct ccid4_hc_rx_sock *ccid4_hc_rx_sk(const struct sock *sk)
> +{
> +       void *ccid4_rx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
> +
> +       BUG_ON(ccid4_rx_priv = NULL);
> +       return ccid4_rx_priv;
> +}
> +
> +#endif /* _DCCP_CCID4_H_ */
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Signed-off-by: Leandro Sales <leandro@embedded.ufcg.edu.br>
