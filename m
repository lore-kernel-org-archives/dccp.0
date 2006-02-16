From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 16 Feb 2006 20:40:04 +0000
Subject: Re: [PATCH 1/1] [DCCP]: Support multi-byte feature values and change ACK ratios
Message-Id: <39e6f6c70602161240q28c21098q594fb250d7b94ccb@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Will review/merge this one today, thanks!

- Arnaldo

PS.: always CC dccp@vger.kernel.org on patch submissions, please :)

On 2/16/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> Support for multi-byte feature values & change of ACK ratios upon negotiation.
>
> Features of multiple bytes may now be negotiated [such as ACK ratios which are
> 16 bits].  ACK ratios are adjusted upon negotiation.
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
>
> ---
>
> diff --git a/include/linux/dccp.h b/include/linux/dccp.h
> index bdd756c..4d47d01 100644
> --- a/include/linux/dccp.h
> +++ b/include/linux/dccp.h
> @@ -329,7 +329,8 @@ static inline unsigned int dccp_hdr_len(
>
>  /* initial values for each feature */
>  #define DCCPF_INITIAL_SEQUENCE_WINDOW          100
> -#define DCCPF_INITIAL_ACK_RATIO                        2
> +/* FIXME: should be 2, but I still need to think about it */
> +#define DCCPF_INITIAL_ACK_RATIO                        1
>
>  #if defined(CONFIG_IP_DCCP_CCID2) || defined(CONFIG_IP_DCCP_CCID2_MODULE)
>  #define DCCPF_INITIAL_CCID                     2
> @@ -354,12 +355,13 @@ static inline unsigned int dccp_hdr_len(
>    *    @dccpo_send_ndp_count - Send NDP Count Feature (7.7.2)
>    */
>  struct dccp_options {
> -       __u64   dccpo_sequence_window;
> -       __u8    dccpo_rx_ccid;
> -       __u8    dccpo_tx_ccid;
> -       __u8    dccpo_send_ack_vector;
> -       __u8    dccpo_send_ndp_count;
> -       __u8                    dccpo_ack_ratio;
> +       __u64                   dccpo_sequence_window;
> +       __u8                    dccpo_rx_ccid;
> +       __u8                    dccpo_tx_ccid;
> +       __u8                    dccpo_send_ack_vector;
> +       __u8                    dccpo_send_ndp_count;
> +       __u16                   dccpo_l_ack_ratio;
> +       __u16                   dccpo_r_ack_ratio;
>         struct list_head        dccpo_pending;
>         struct list_head        dccpo_conf;
>  };
> @@ -375,6 +377,7 @@ struct dccp_opt_pend {
>         __u8                    dccpop_feat;
>         __u8                    *dccpop_val;
>         __u8                    dccpop_len;
> +       __u8                    dccpop_optlen;
>         int                     dccpop_conf;
>         struct dccp_opt_conf    *dccpop_sc;
>  };
> @@ -472,8 +475,6 @@ struct dccp_sock {
>         struct timeval                  dccps_timestamp_time;
>         __u32                           dccps_timestamp_echo;
>         __u32                           dccps_packet_size;
> -       __u16                           dccps_l_ack_ratio;
> -       __u16                           dccps_r_ack_ratio;
>         unsigned long                   dccps_ndp_count;
>         __u32                           dccps_mss_cache;
>         struct dccp_options             dccps_options;
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
> index 8f964dc..3fed24a 100644
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -33,6 +33,7 @@
>  #include <linux/config.h>
>  #include "../ccid.h"
>  #include "../dccp.h"
> +#include "../feat.h"
>  #include "ccid2.h"
>
>  static int ccid2_debug;
> @@ -142,9 +143,12 @@ static int ccid2_hc_tx_send_packet(struc
>         return 100; /* XXX */
>  }
>
> -static void ccid2_change_l_ack_ratio(struct sock *sk, int val)
> +static u16 ccid2_change_l_ack_ratio(struct sock *sk, u16 val)
>  {
>         struct dccp_sock *dp = dccp_sk(sk);
> +       u8  *v;
> +       u16 ar;
> +
>         /*
>          * XXX I don't really agree with val != 2.  If cwnd is 1, ack ratio
>          * should be 1... it shouldn't be allowed to become 2.
> @@ -162,9 +166,25 @@ static void ccid2_change_l_ack_ratio(str
>                         val = max;
>         }
>
> +       BUG_ON(val = 0);
> +       /* no change */
> +       if (dp->dccps_options.dccpo_l_ack_ratio = val)
> +               return val;
> +
>         ccid2_pr_debug("changing local ack ratio to %d\n", val);
> -       WARN_ON(val <= 0);
> -       dp->dccps_l_ack_ratio = val;
> +
> +       /* XXX it would be better to replace the old value of the feature, and
> +        * not allocate memory on each change
> +        */
> +       v = kmalloc(sizeof(ar), GFP_ATOMIC);
> +       if (!v)
> +               return val;
> +
> +       ar = htons(val);
> +       memcpy(v, &ar, sizeof(ar));
> +       dccp_feat_change(sk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
> +                        v, sizeof(ar), GFP_ATOMIC);
> +       return val;
>  }
>
>  static void ccid2_change_cwnd(struct sock *sk, int val)
> @@ -294,17 +314,18 @@ static void ccid2_hc_tx_packet_sent(stru
>         }
>         /* No acks lost up to now... */
>         else {
> +               u16 ack_ratio = ntohs(dp->dccps_options.dccpo_l_ack_ratio);
> +
>                 /* decrease ack ratio if enough packets were sent */
> -               if (dp->dccps_l_ack_ratio > 1) {
> +               if (ack_ratio > 1) {
>                         /* XXX don't calculate denominator each time */
>                         int denom;
>
> -                       denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio -
> -                               dp->dccps_l_ack_ratio;
> +                       denom = ack_ratio * ack_ratio - ack_ratio;
>                         denom = hctx->ccid2hctx_cwnd * hctx->ccid2hctx_cwnd / denom;
>
>                         if (hctx->ccid2hctx_arsent >= denom) {
> -                               ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio - 1);
> +                               ccid2_change_l_ack_ratio(sk, ack_ratio - 1);
>                                 hctx->ccid2hctx_arsent = 0;
>                         }
>                 }
> @@ -525,6 +546,7 @@ static void ccid2_hc_tx_packet_recv(stru
>         int done = 0;
>         int loss = 0;
>         unsigned int maxincr = 0;
> +       u16 ack_ratio = ntohs(dp->dccps_options.dccpo_l_ack_ratio);
>
>         ccid2_hc_tx_check_sanity(hctx);
>         /* check reverse path congestion */
> @@ -555,7 +577,9 @@ static void ccid2_hc_tx_packet_recv(stru
>                                 hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
>                                 hctx->ccid2hctx_rpseq = 0;
>
> -                               ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio << 1);
> +                               ack_ratio <<= 1;
> +                               ack_ratio = ccid2_change_l_ack_ratio(sk,
> +                                                                    ack_ratio);
>                         }
>                 }
>         }
> @@ -581,7 +605,7 @@ static void ccid2_hc_tx_packet_recv(stru
>          * this single ack.  I round up.
>          * -sorbo.
>          */
> -       maxincr = dp->dccps_l_ack_ratio >> 1;
> +       maxincr = ack_ratio >> 1;
>         maxincr++;
>
>         /* go through all ack vectors */
> @@ -765,12 +789,13 @@ static void ccid2_hc_rx_packet_recv(stru
>  {
>         const struct dccp_sock *dp = dccp_sk(sk);
>         struct ccid2_hc_rx_sock *hcrx = ccid2_hc_rx_sk(sk);
> +       u16 ack_ratio = ntohs(dp->dccps_options.dccpo_r_ack_ratio);
>
>         switch (DCCP_SKB_CB(skb)->dccpd_type) {
>         case DCCP_PKT_DATA:
>         case DCCP_PKT_DATAACK:
>                 hcrx->ccid2hcrx_data++;
> -               if (hcrx->ccid2hcrx_data >= dp->dccps_r_ack_ratio) {
> +               if (hcrx->ccid2hcrx_data >= ack_ratio) {
>                         dccp_send_ack(sk);
>                         hcrx->ccid2hcrx_data = 0;
>                 }
> diff --git a/net/dccp/feat.c b/net/dccp/feat.c
> index 641f8af..af96049 100644
> --- a/net/dccp/feat.c
> +++ b/net/dccp/feat.c
> @@ -90,6 +90,22 @@ int dccp_feat_change(struct sock *sk, u8
>         opt->dccpop_conf = 0;
>         opt->dccpop_sc   = NULL;
>
> +       /* determine the length of an individual feature value */
> +       switch(opt->dccpop_feat) {
> +       case DCCPF_CCID:
> +               opt->dccpop_optlen = 1;
> +               break;
> +
> +       case DCCPF_ACK_RATIO:
> +               opt->dccpop_optlen = 2;
> +               break;
> +
> +       default:
> +               opt->dccpop_optlen = 0;
> +               BUG_ON(1); /* XXX implement */
> +               break;
> +       }
> +
>         BUG_ON(opt->dccpop_val = NULL);
>
>         list_add_tail(&opt->dccpop_node, &dp->dccps_options.dccpo_pending);
> @@ -98,6 +114,18 @@ int dccp_feat_change(struct sock *sk, u8
>
>  EXPORT_SYMBOL_GPL(dccp_feat_change);
>
> +static int dccp_feat_update_ar(struct sock *sk, u8 type, u16 ar)
> +{
> +       struct dccp_sock *dp = dccp_sk(sk);
> +
> +       if (type = DCCPO_CHANGE_L)
> +               dp->dccps_options.dccpo_l_ack_ratio = ar;
> +       else
> +               dp->dccps_options.dccpo_r_ack_ratio = ar;
> +
> +       return 0;
> +}
> +
>  static int dccp_feat_update_ccid(struct sock *sk, u8 type, u8 new_ccid_nr)
>  {
>         struct dccp_sock *dp = dccp_sk(sk);
> @@ -128,28 +156,58 @@ static int dccp_feat_update_ccid(struct
>         return 0;
>  }
>
> -/* XXX taking only u8 vals */
> -static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, u8 val)
> +/* caller is responsible for sanity checks.  It is important that val is of the
> + * right length and format
> + */
> +static int dccp_feat_update(struct sock *sk, u8 type, u8 feat, void *val)
>  {
> -       dccp_pr_debug("changing [%d] feat %d to %d\n", type, feat, val);
> +       dccp_pr_debug("changing [%d] feat %d\n", type, feat);
>
>         switch (feat) {
>         case DCCPF_CCID:
> -               return dccp_feat_update_ccid(sk, type, val);
> +               return dccp_feat_update_ccid(sk, type, *((u8*)val));
> +
> +       case DCCPF_ACK_RATIO:
> +               return dccp_feat_update_ar(sk, type, *((u16*)val));
> +
>         default:
> -               dccp_pr_debug("IMPLEMENT changing [%d] feat %d to %d\n",
> -                             type, feat, val);
> +               dccp_pr_debug("IMPLEMENT changing [%d] feat %d\n", type, feat);
>                 break;
>         }
>         return 0;
>  }
>
> +static u8 *dccp_feat_find_intersect(u8 *spref, u8 slen, u8 *rpref, u8 rlen,
> +                                   u8 optlen)
> +{
> +       int i, j;
> +
> +       /* XXX lame algorithm here.  If values are in any order, we can be
> +        * smarter.  Also, we can provide specialized implementation for 1 byte
> +        * features, or features of particular types.
> +        */
> +       dccp_pr_debug("Searching for intersection slen %d rlen %d optlen %d\n",
> +                     slen, rlen, optlen);
> +
> +       for (i = 0; i < slen; i+= optlen) {
> +               for (j = 0; j < rlen; j+= optlen) {
> +
> +                       if ((i + optlen) > slen || (j + optlen) > rlen)
> +                               return NULL;
> +
> +                       if (memcmp(&spref[i], &rpref[j], optlen) = 0)
> +                               return &spref[i];
> +               }
> +       }
> +       return NULL;
> +}
>  static int dccp_feat_reconcile(struct sock *sk, struct dccp_opt_pend *opt,
>                                u8 *rpref, u8 rlen)
>  {
>         struct dccp_sock *dp = dccp_sk(sk);
>         u8 *spref, slen, *res = NULL;
> -       int i, j, rc, agree = 1;
> +       int rc, agree = 1;
> +       int optlen = opt->dccpop_optlen;
>
>         BUG_ON(rpref = NULL);
>
> @@ -172,18 +230,7 @@ static int dccp_feat_reconcile(struct so
>
>         /* FIXME sanity check vals */
>
> -       /* Are values in any order?  XXX Lame "algorithm" here */
> -       /* XXX assume values are 1 byte */
> -       for (i = 0; i < slen; i++) {
> -               for (j = 0; j < rlen; j++) {
> -                       if (spref[i] = rpref[j]) {
> -                               res = &spref[i];
> -                               break;
> -                       }
> -               }
> -               if (res)
> -                       break;
> -       }
> +       res = dccp_feat_find_intersect(spref, slen, rpref, rlen, optlen);
>
>         /* we didn't agree on anything */
>         if (res = NULL) {
> @@ -207,14 +254,13 @@ static int dccp_feat_reconcile(struct so
>         }
>
>         /* need to put result and our preference list */
> -       /* XXX assume 1 byte vals */
> -       rlen = 1 + opt->dccpop_len;
> +       rlen = optlen + opt->dccpop_len;
>         rpref = kmalloc(rlen, GFP_ATOMIC);
>         if (rpref = NULL)
>                 return -ENOMEM;
>
> -       *rpref = *res;
> -       memcpy(&rpref[1], opt->dccpop_val, opt->dccpop_len);
> +       memcpy(rpref, res, optlen);
> +       memcpy(&rpref[optlen], opt->dccpop_val, opt->dccpop_len);
>
>         /* put it in the "confirm queue" */
>         if (opt->dccpop_sc = NULL) {
> @@ -235,7 +281,7 @@ static int dccp_feat_reconcile(struct so
>         opt->dccpop_sc->dccpoc_len = rlen;
>
>         /* update the option on our side [we are about to send the confirm] */
> -       rc = dccp_feat_update(sk, opt->dccpop_type, opt->dccpop_feat, *res);
> +       rc = dccp_feat_update(sk, opt->dccpop_type, opt->dccpop_feat, res);
>         if (rc) {
>                 kfree(opt->dccpop_sc->dccpoc_val);
>                 kfree(opt->dccpop_sc);
> @@ -329,7 +375,7 @@ static int dccp_feat_nn(struct sock *sk,
>         opt->dccpop_len  = len;
>
>         /* change feature */
> -       rc = dccp_feat_update(sk, type, feature, *val);
> +       rc = dccp_feat_update(sk, DCCPO_CHANGE_R, feature, val);
>         if (rc) {
>                 kfree(opt->dccpop_val);
>                 kfree(opt);
> @@ -462,7 +508,7 @@ int dccp_feat_confirm_recv(struct sock *
>
>                         /* We got a confirmation---change the option */
>                         dccp_feat_update(sk, opt->dccpop_type,
> -                                        opt->dccpop_feat, *val);
> +                                        opt->dccpop_feat, val);
>
>                         dccp_pr_debug("feat %d type %d confirmed %d\n",
>                                       feature, type, *val);
> @@ -584,10 +630,10 @@ out_clean:
>
>  EXPORT_SYMBOL_GPL(dccp_feat_clone);
>
> -static int __dccp_feat_init(struct sock *sk, u8 type, u8 feat, u8 *val, u8 len)
> +static int __dccp_feat_init(struct sock *sk, u8 type, u8 feat, void *val, u8 len)
>  {
>         int rc = -ENOMEM;
> -       u8 *copy = kmalloc(len, GFP_KERNEL);
> +       void *copy = kmalloc(len, GFP_KERNEL);
>
>         if (copy != NULL) {
>                 memcpy(copy, val, len);
> @@ -620,7 +666,7 @@ int dccp_feat_init(struct sock *sk)
>
>         /* Ack ratio */
>         rc = __dccp_feat_init(sk, DCCPO_CHANGE_L, DCCPF_ACK_RATIO,
> -                             &dp->dccps_options.dccpo_ack_ratio, 1);
> +                             &dp->dccps_options.dccpo_l_ack_ratio, 2);
>  out:
>         return rc;
>  }
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 266b6b2..305790d 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -1095,7 +1095,6 @@ int dccp_v4_init_sock(struct sock *sk)
>         dp->dccps_mss_cache = 536;
>         dp->dccps_role = DCCP_ROLE_UNDEFINED;
>         dp->dccps_service = DCCP_SERVICE_INVALID_VALUE;
> -       dp->dccps_l_ack_ratio = dp->dccps_r_ack_ratio = 1;
>
>         return 0;
>  }
> diff --git a/net/dccp/options.c b/net/dccp/options.c
> index 7f99306..8852ffe 100644
> --- a/net/dccp/options.c
> +++ b/net/dccp/options.c
> @@ -28,7 +28,8 @@ static const struct dccp_options dccpo_d
>         .dccpo_sequence_window    = DCCPF_INITIAL_SEQUENCE_WINDOW,
>         .dccpo_rx_ccid            = DCCPF_INITIAL_CCID,
>         .dccpo_tx_ccid            = DCCPF_INITIAL_CCID,
> -       .dccpo_ack_ratio          = DCCPF_INITIAL_ACK_RATIO,
> +       .dccpo_l_ack_ratio        = DCCPF_INITIAL_ACK_RATIO,
> +       .dccpo_r_ack_ratio        = DCCPF_INITIAL_ACK_RATIO,
>         .dccpo_send_ack_vector    = DCCPF_INITIAL_SEND_ACK_VECTOR,
>         .dccpo_send_ndp_count     = DCCPF_INITIAL_SEND_NDP_COUNT,
>  };
> @@ -36,6 +37,8 @@ static const struct dccp_options dccpo_d
>  void dccp_options_init(struct dccp_options *dccpo)
>  {
>         memcpy(dccpo, &dccpo_default_values, sizeof(*dccpo));
> +       dccpo->dccpo_l_ack_ratio = htons(dccpo->dccpo_l_ack_ratio);
> +       dccpo->dccpo_r_ack_ratio = htons(dccpo->dccpo_r_ack_ratio);
>  }
>
>  static u32 dccp_decode_value_var(const unsigned char *bf, const u8 len)
>
