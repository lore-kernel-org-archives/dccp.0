From: "Leandro Sales" <leandroal@gmail.com>
Date: Mon, 03 Dec 2007 13:52:31 +0000
Subject: Re: [Announce]: Test tree up{dated,loaded}
Message-Id: <5bc4c4570712030552s5e0af05fp89c60c4c83dd3c9f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20071203084106.GB5484@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20071203084106.GB5484@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

2007/12/3, Gerrit Renker <gerrit@erg.abdn.ac.uk>:
> I have just backported the latest changes that Arnaldo put in the 2.6.25
> tree to the test tree. While it seems correct, I have not run exhaustive
> tests, but will run a few.
>
> I have also updated the CCID4/Faster Restart branches with regard to
> these changes and would like to know if people are actually using these
> branches, as it takes time to keep track of what is going on.
>
> The interdiff for the CCID4 tree is below (there was just one hunk which
> failed in the interdiff; if in doubt please check out the code). The
> updates to CCID3 are analogous.
>
> --- b/net/dccp/ccids/ccid4.c
> +++ b/net/dccp/ccids/ccid4.c
> @@ -56,8 +56,6 @@
>  #define ccid4_pr_debug(format, a...)
>  #endif
>
> -DECLARE_TFRC_TX_CACHE(ccid4_tx_hist);
> -
>  static void ccid4_hc_tx_set_state(struct sock *sk,
>                                   enum tfrc_hc_tx_states state)
>  {
> @@ -355,7 +353,7 @@
>  {
>         struct tfrc_hc_tx_sock *hctx = tfrc_hc_tx_sk(sk);
>         struct tfrc_options_received *opt_recv;
> -       ktime_t t_send, now;
> +       ktime_t now;
>         unsigned long t_nfb;
>         u32 pinv, r_sample;
>
> @@ -363,24 +361,26 @@
>         if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
>               DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
>                 return;
> -
>         /* ... and only in the established state */
> -       switch (hctx->tfrchctx_state) {
> -       case TFRC_SSTATE_NO_FBACK:      /* fall through */
> -       case TFRC_SSTATE_FBACK:         break;
> -       default:                        return;
> -       }
> +       if (hctx->tfrchctx_state != TFRC_SSTATE_FBACK &&
> +           hctx->tfrchctx_state != TFRC_SSTATE_NO_FBACK)
> +               return;
>
> -       /* estimate RTT from history if ACK number is valid */
> -       if (! tfrc_tx_hist_when(&t_send, &hctx->tfrchctx_hist,
> -                               DCCP_SKB_CB(skb)->dccpd_ack_seq)) {
> +       opt_recv = &hctx->tfrchctx_options_received;
> +       now = ktime_get_real();
> +
> +       /* Estimate RTT from history if ACK number is valid */
> +       r_sample = tfrc_tx_hist_rtt(hctx->tfrchctx_hist,
> +                                   DCCP_SKB_CB(skb)->dccpd_ack_seq, now);
> +       if (r_sample = 0) {
>                 DCCP_WARN("%s(%p): %s with bogus ACK-%llu
> ", dccp_role(sk), sk,
>                           dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
>                           (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
>                 return;
>         }
> -
> -       opt_recv = &hctx->tfrchctx_options_received;
> +       /* Validate new RTT sample and update moving average */
> +       r_sample = dccp_sample_rtt(sk, r_sample);
> +       hctx->tfrchctx_rtt = tfrc_ewma(hctx->tfrchctx_rtt, r_sample, 9);
>
>         /* Update receive rate in units of 64 * bytes/second */
>         hctx->tfrchctx_x_recv = opt_recv->tfrcor_receive_rate;
> @@ -394,13 +394,6 @@
>                 hctx->tfrchctx_p = scaled_div(1, pinv);
>
>         /*
> -        * Calculate new RTT sample and update moving average
> -        */
> -       now = ktime_get_real();
> -       r_sample = dccp_sample_rtt(sk, ktime_us_delta(now, t_send));
> -       hctx->tfrchctx_rtt = tfrc_ewma(hctx->tfrchctx_rtt, r_sample, 9);
> -
> -       /*
>          *      Update allowed sending rate X as per draft rfc3448bis-00, 4.2/3
>          */
>         if (hctx->tfrchctx_state = TFRC_SSTATE_NO_FBACK) {
> @@ -440,7 +433,7 @@
>                        (unsigned)(hctx->tfrchctx_x_recv >> 6),
>                        (unsigned)(hctx->tfrchctx_x >> 6));
>
> -       /* unschedule no feedback timer */
> +       /* unschedule nofeedback timer */
>         sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
>
>         /*
> @@ -541,7 +534,7 @@
>         struct tfrc_hc_tx_sock *hctx = ccid_priv(ccid);
>
>         hctx->tfrchctx_state = TFRC_SSTATE_NO_SENT;
> -       tfrc_tx_hist_init(&hctx->tfrchctx_hist, ccid4_tx_hist);
> +       hctx->tfrchctx_hist = NULL;
>         setup_timer(&hctx->tfrchctx_no_feedback_timer,
>                         ccid4_hc_tx_no_feedback_timer, (unsigned long)sk);
>
> @@ -555,8 +548,7 @@
>         ccid4_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
>         sk_stop_timer(sk, &hctx->tfrchctx_no_feedback_timer);
>
> -       /* Empty packet history */
> -       tfrc_tx_hist_cleanup(&hctx->tfrchctx_hist);
> +       tfrc_tx_hist_purge(&hctx->tfrchctx_hist);
>  }
>
>  static void ccid4_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
> @@ -884,25 +876,13 @@
>
>  static __init int ccid4_module_init(void)
>  {
> -       int rc = -ENOBUFS;
> -
> -       if (tfrc_tx_cache_init(&ccid4_tx_hist, "ccid4"))
> -               goto out;
> -
> -       rc = ccid_register(&ccid4);
> -       if (rc != 0)
> -               tfrc_tx_cache_cleanup(ccid4_tx_hist);
> -out:
> -       return rc;
> +       return ccid_register(&ccid4);
>  }
>  module_init(ccid4_module_init);
>
>  static __exit void ccid4_module_exit(void)
>  {
>         ccid_unregister(&ccid4);
> -
> -       if (ccid4_tx_hist != NULL)
> -               tfrc_tx_cache_cleanup(ccid4_tx_hist);
>  }
>  module_exit(ccid4_module_exit);
>
> --- b/net/dccp/ccids/lib/tfrc_ccids.h
> +++ b/net/dccp/ccids/lib/tfrc_ccids.h
> @@ -111,7 +111,7 @@
>         ktime_t                         tfrchctx_t_ld;
>         ktime_t                         tfrchctx_t_nom;
>         u32                             tfrchctx_delta;
> -       struct tfrc_tx_hist_head        tfrchctx_hist;
> +       struct tfrc_tx_hist_entry       *tfrchctx_hist;
>         struct tfrc_options_received    tfrchctx_options_received;
>  };
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

Hi Gerrit,
  thank you for the announcement. I'm using the ccid4 branch and I
suppose that Tommi is also using the tree. I plan to submit new
patches for these days...

Leandro.
