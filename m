From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Thu, 22 Jun 2006 18:04:59 +0000
Subject: Re: [PATCH 11/11] CCID2: Add network profiling code for monitoring state
Message-Id: <5640c7e00606221104k7d85c1c7u5087648cb7b4fd63@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20060622180047.GK4230@shorty.sorbonet.org>
In-Reply-To: <20060622180047.GK4230@shorty.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am interested. I was thinking of writing the equivalent of tcp
probes (Stephen Hemminger) for dccp and would like to look.

On 6/23/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> Add "profiling" code to CCID2.  It is now possible to monitor the state of CCID2
> from user-land.  Currently, the information which is available is:
> * cwnd
> * pipe
> * srtt
> * packets / second.
>
> If you are interested in a userland tool for collecting such data let me know.
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
>
> ---
>
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
> index b6f6681..50da0f5 100644
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -35,6 +35,7 @@ #include "../dccp.h"
>  #include "ccid2.h"
>
>  static int ccid2_debug;
> +static int ccid2_profile;
>
>  #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
>  #define ccid2_pr_debug(format, a...) \
> @@ -90,6 +91,131 @@ #else
>  #define ccid2_hc_tx_check_sanity(hctx) do {} while (0)
>  #endif
>
> +static int ccid2_pv_init(struct ccid2_profvar *pv, int type, int count)
> +{
> +       pv->ccid2pv_size = count;
> +       pv->ccid2pv_pos = 0;
> +       pv->ccid2pv_overflow = 0;
> +       pv->ccid2pv_type = type;
> +
> +       pv->ccid2pv_data = kmalloc(sizeof(*pv->ccid2pv_data) * pv->ccid2pv_size,
> +                                  gfp_any());
> +       if (!pv->ccid2pv_data)
> +               return -ENOMEM;
> +
> +       return 0;
> +}
> +
> +static void ccid2_pv_del(struct ccid2_profvar *pv)
> +{
> +       if (pv->ccid2pv_data) {
> +               kfree(pv->ccid2pv_data);
> +               pv->ccid2pv_data = 0;
> +       }
> +}
> +
> +static u64 ccid2_profile_time(void)
> +{
> +#if defined(__i386__)
> +       u32 l, h;
> +       u64 t;
> +
> +       rdtsc(l, h);
> +
> +       t = h;
> +       t <<= 32;
> +       t |= l;
> +
> +       return t;
> +#else
> +       return jiffies;
> +#endif
> +}
> +
> +static void ccid2_pv_add(struct ccid2_profvar *pv, long val)
> +{
> +       struct ccid2_profdata *pd = &pv->ccid2pv_data[pv->ccid2pv_pos];
> +
> +       pd->ccid2pd_time = ccid2_profile_time();
> +       pd->ccid2pd_val = val;
> +
> +       pv->ccid2pv_pos++;
> +       if (pv->ccid2pv_pos >= pv->ccid2pv_size) {
> +               pv->ccid2pv_pos = 0;
> +
> +               /* strictly speaking, there is no overflow until the next write
> +                * happens, but for ease of programming, we set the bit here.
> +                */
> +               pv->ccid2pv_overflow = 1;
> +       }
> +}
> +
> +static int ccid2_pv_copy_to_user(struct ccid2_profvar *pv, void __user *buf,
> +                                int copylen)
> +{
> +       int totlen;
> +       int rc;
> +       unsigned char over = pv->ccid2pv_overflow;
> +       unsigned char __user *bufp = buf;
> +       struct ccid2_pdhdr hdr;
> +
> +       totlen = sizeof(hdr);
> +
> +       /* If we overflowed, the whole buffer has new data */
> +       if (over)
> +               totlen += pv->ccid2pv_size * sizeof(*pv->ccid2pv_data);
> +       else
> +               totlen += pv->ccid2pv_pos  * sizeof(*pv->ccid2pv_data);
> +
> +       if (copylen > totlen)
> +               copylen = totlen;
> +
> +       if (copylen < sizeof(hdr))
> +               return -EINVAL;
> +       totlen = copylen;
> +
> +       /* header */
> +       copylen -= sizeof(hdr);
> +       hdr.ccid2pdh_overflow = over;
> +       hdr.ccid2pdh_type = pv->ccid2pv_type;
> +       hdr.ccid2pdh_len = copylen;
> +       if ((rc = copy_to_user(bufp, &hdr, sizeof(hdr))))
> +               return rc;
> +       bufp += sizeof(hdr);
> +
> +       /* copy data */
> +       if (over) {
> +               struct ccid2_profdata *pd;
> +               int rem = pv->ccid2pv_size - pv->ccid2pv_pos;
> +
> +               /* copy tail of buffer first */
> +               pd = &pv->ccid2pv_data[pv->ccid2pv_pos];
> +               while (rem--) {
> +                       if (copylen < sizeof(*pd))
> +                               break;
> +
> +                       rc = copy_to_user(bufp, pd, sizeof(*pd));
> +                       if (rc)
> +                               return rc;
> +
> +                       bufp += sizeof(*pd);
> +                       copylen -= sizeof(*pd);
> +                       pd++;
> +               }
> +       }
> +
> +       rc = copy_to_user(bufp, pv->ccid2pv_data, copylen);
> +       if (rc)
> +               return rc;
> +
> +       /* reset buffer */
> +       /* XXX assumes that the user supplied a buffer large enough */
> +       pv->ccid2pv_overflow = 0;
> +       pv->ccid2pv_pos = 0;
> +
> +       return totlen;
> +}
> +
>  static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num)
>  {
>         struct ccid2_seq *seqp;
> @@ -187,6 +313,13 @@ static void ccid2_change_l_ack_ratio(str
>         dp->dccps_l_ack_ratio = val;
>  }
>
> +static inline void ccid2_profile_var(struct ccid2_hc_tx_sock *hctx, int var,
> +                                    long val)
> +{
> +       if (ccid2_profile)
> +               ccid2_pv_add(&hctx->ccid2hctx_profile.ccid2txp_vars[var], val);
> +}
> +
>  static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, int val)
>  {
>         if (val = 0)
> @@ -197,6 +330,7 @@ static void ccid2_change_cwnd(struct cci
>
>         BUG_ON(val < 1);
>         hctx->ccid2hctx_cwnd = val;
> +       ccid2_profile_var(hctx, CCID2_PROF_CWND, hctx->ccid2hctx_cwnd);
>  }
>
>  static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
> @@ -207,10 +341,17 @@ static void ccid2_change_srtt(struct cci
>                 return;
>
>         hctx->ccid2hctx_srtt = val;
> +       ccid2_profile_var(hctx, CCID2_PROF_SRTT, hctx->ccid2hctx_srtt);
>  }
>
>  static void ccid2_change_pipe(struct ccid2_hc_tx_sock *hctx, long val)
>  {
> +       /* Don't log all pipe changes---too much stuff */
> +       if (abs(hctx->ccid2hctx_profile.ccid2txp_lpipe - val) > 2) {
> +               ccid2_profile_var(hctx, CCID2_PROF_PIPE, val);
> +               hctx->ccid2hctx_profile.ccid2txp_lpipe = val;
> +       }
> +
>         hctx->ccid2hctx_pipe = val;
>  }
>
> @@ -287,6 +428,22 @@ static void ccid2_hc_tx_packet_sent(stru
>
>         ccid2_hc_tx_check_sanity(hctx);
>
> +       if (ccid2_profile) {
> +               unsigned long diff;
> +
> +               hctx->ccid2hctx_profile.ccid2txp_packets++;
> +               diff = (long)jiffies -
> +                      (long)hctx->ccid2hctx_profile.ccid2txp_packets_last;
> +
> +               if (diff >= HZ) {
> +                       ccid2_profile_var(hctx, CCID2_PROF_PS,
> +                                         (hctx->ccid2hctx_profile.
> +                                          ccid2txp_packets/diff)*HZ);
> +                       hctx->ccid2hctx_profile.ccid2txp_packets = 0;
> +                       hctx->ccid2hctx_profile.ccid2txp_packets_last = jiffies;
> +               }
> +       }
> +
>         BUG_ON(!hctx->ccid2hctx_sendwait);
>         hctx->ccid2hctx_sendwait = 0;
>         ccid2_change_pipe(hctx, hctx->ccid2hctx_pipe+1);
> @@ -754,6 +911,26 @@ static int ccid2_hc_tx_init(struct ccid
>  {
>          struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
>
> +       if (ccid2_profile) {
> +               int rc;
> +               int i;
> +
> +               for (i = 0; i < CCID2_PROF_LAST; i++) {
> +                       rc = ccid2_pv_init(&hctx->ccid2hctx_profile.
> +                                          ccid2txp_vars[i], i, 6000);
> +                       if (rc) {
> +                               while (--i > 0)
> +                                       ccid2_pv_del(&hctx->ccid2hctx_profile.
> +                                                    ccid2txp_vars[i]);
> +                               return rc;
> +                       }
> +               }
> +
> +               hctx->ccid2hctx_profile.ccid2txp_lpipe = 0;
> +               hctx->ccid2hctx_profile.ccid2txp_packets = 0;
> +               hctx->ccid2hctx_profile.ccid2txp_packets_last = jiffies;
> +       }
> +
>         ccid2_change_cwnd(hctx, 1);
>         hctx->ccid2hctx_ssthresh  = 666666; /* "infinite" [for a while] */
>         hctx->ccid2hctx_numdupack = 3;
> @@ -789,6 +966,13 @@ static void ccid2_hc_tx_exit(struct sock
>         for (i = 0; i < hctx->ccid2hctx_seqbufc; i++)
>                 kfree(hctx->ccid2hctx_seqbuf[i]);
>         hctx->ccid2hctx_seqbufc = 0;
> +
> +       if (ccid2_profile) {
> +               int i;
> +
> +               for (i = 0; i < CCID2_PROF_LAST; i++)
> +                       ccid2_pv_del(&hctx->ccid2hctx_profile.ccid2txp_vars[i]);
> +       }
>  }
>
>  static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
> @@ -808,6 +992,58 @@ static void ccid2_hc_rx_packet_recv(stru
>         }
>  }
>
> +static int ccid2_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
> +                                 u32 __user *optval, int __user *optlen)
> +{
> +       return -ENOPROTOOPT;
> +}
> +
> +static int ccid2_hc_tx_profile(struct sock *sk, u32 __user *optval,
> +                              int __user *optlen)
> +{
> +       struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
> +       int rem;
> +       int rc;
> +       int copied = 0;
> +       int i;
> +       unsigned char __user *buf = (unsigned char *) optval;
> +
> +       rc = get_user(rem, optlen);
> +       if (rc)
> +               return rc;
> +
> +       for (i = 0; i < CCID2_PROF_LAST; i++) {
> +               rc = ccid2_pv_copy_to_user(&hctx->ccid2hctx_profile.
> +                                          ccid2txp_vars[i], buf, rem);
> +               if (rc < 0)
> +                       return rc;
> +
> +               rem -= rc;
> +               copied += rc;
> +               buf += rc;
> +               if (rem <= 0)
> +                       break;
> +       }
> +
> +       rc = put_user(copied, optlen);
> +       if (rc)
> +               return rc;
> +
> +       return 0;
> +}
> +
> +static int ccid2_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
> +                                 u32 __user *optval, int __user *optlen)
> +{
> +       switch (optname) {
> +       case DCCP_SOCKOPT_CCID_TX_INFO:
> +               if (ccid2_profile)
> +                       return ccid2_hc_tx_profile(sk, optval, optlen);
> +       }
> +
> +       return -ENOPROTOOPT;
> +}
> +
>  static struct ccid_operations ccid2 = {
>         .ccid_id                = 2,
>         .ccid_name              = "ccid2",
> @@ -820,11 +1056,16 @@ static struct ccid_operations ccid2 = {
>         .ccid_hc_tx_packet_recv = ccid2_hc_tx_packet_recv,
>         .ccid_hc_rx_obj_size    = sizeof(struct ccid2_hc_rx_sock),
>         .ccid_hc_rx_packet_recv = ccid2_hc_rx_packet_recv,
> +       .ccid_hc_rx_getsockopt  = ccid2_hc_rx_getsockopt,
> +       .ccid_hc_tx_getsockopt  = ccid2_hc_tx_getsockopt,
>  };
>
>  module_param(ccid2_debug, int, 0444);
>  MODULE_PARM_DESC(ccid2_debug, "Enable debug messages");
>
> +module_param(ccid2_profile, int, 0444);
> +MODULE_PARM_DESC(ccid2_profile, "Enable profiling");
> +
>  static __init int ccid2_module_init(void)
>  {
>         return ccid_register(&ccid2);
> diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
> index 3bc4b76..d208657 100644
> --- a/net/dccp/ccids/ccid2.h
> +++ b/net/dccp/ccids/ccid2.h
> @@ -35,6 +35,41 @@ struct ccid2_seq {
>         struct ccid2_seq        *ccid2s_next;
>  };
>
> +struct ccid2_pdhdr {
> +       u8      ccid2pdh_overflow;
> +       u8      ccid2pdh_type;
> +       int     ccid2pdh_len;
> +};
> +
> +struct ccid2_profdata {
> +       u64     ccid2pd_time;
> +       long    ccid2pd_val;
> +};
> +
> +enum {
> +       CCID2_PROF_CWND = 0,
> +       CCID2_PROF_SRTT,
> +       CCID2_PROF_PIPE,
> +       CCID2_PROF_PS,
> +
> +       CCID2_PROF_LAST
> +};
> +
> +struct ccid2_profvar {
> +       struct ccid2_profdata   *ccid2pv_data;
> +       int                     ccid2pv_size;
> +       int                     ccid2pv_pos;
> +       int                     ccid2pv_overflow;
> +       int                     ccid2pv_type;
> +};
> +
> +struct ccid2_txprofile {
> +       struct ccid2_profvar    ccid2txp_vars[CCID2_PROF_LAST];
> +       long                    ccid2txp_lpipe;
> +       long                    ccid2txp_packets;
> +       unsigned long           ccid2txp_packets_last;
> +};
> +
>  #define CCID2_SEQBUF_LEN 256
>  #define CCID2_SEQBUF_MAX 128
>
> @@ -72,6 +107,7 @@ struct ccid2_hc_tx_sock {
>         int                     ccid2hctx_rpdupack;
>         int                     ccid2hctx_sendwait;
>         unsigned long           ccid2hctx_last_cong;
> +       struct ccid2_txprofile  ccid2hctx_profile;
>  };
>
>  struct ccid2_hc_rx_sock {
> -
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
