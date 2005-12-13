From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 13 Dec 2005 13:05:08 +0000
Subject: Re: [PATCH 1/3] DCCP: Introduce ACK vector records
Message-Id: <39e6f6c70512130505y639155d8h77d0d2ca77167d4f@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
References: <20051213093130.GA8532@tribal.sorbonet.org>
In-Reply-To: <20051213093130.GA8532@tribal.sorbonet.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 12/13/05, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> Initial support for ACK vector records.  Currently there is a fixed
> number of records which doesn't grow at run-time.  Need to decide
> what to do [currently dies] when we run out of records [allocate more,
> return -1?].
>
> Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
>
> ---
>
> diff --git a/net/dccp/Kconfig b/net/dccp/Kconfig
> index 187ac18..f39abaf 100644
> --- a/net/dccp/Kconfig
> +++ b/net/dccp/Kconfig
> @@ -36,6 +36,13 @@ config IP_DCCP_DEBUG
>
>           Just say N.
>
> +config IP_DCCP_ACKVEC
> +       bool "DCCP ACK vector"
> +       ---help---
> +         Enable the use of ACK vectors.
> +
> +         Just say N.
> +
>  config IP_DCCP_UNLOAD_HACK
>         depends on IP_DCCP=m && IP_DCCP_CCID3=m
>         bool "DCCP control sock unload hack"
> diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
> index c9a62cc..12a1fa5 100644
> --- a/net/dccp/ackvec.c
> +++ b/net/dccp/ackvec.c
> @@ -17,15 +17,84 @@
>
>  #include <net/sock.h>
>
> +static void dccp_ackvec_insert_avr(struct dccp_ackvec *av,
> +                                  struct dccp_ackvec_record *avr)
> +{
> +       struct dccp_ackvec_record *pos, *prev;
> +
> +       BUG_ON(av = NULL);
> +       BUG_ON(avr = NULL);
> +
> +#if CONFIG_IP_DCCP_DEBUG
> +       dccp_pr_debug("SEQ=%llu %p\n", avr->dccpavr_ack_seqno, avr);
> +       pos = av->dccpav_record;
> +
> +       while (pos) {
> +               dccp_pr_debug("Printing seq=%llu %p\n", pos->dccpavr_ack_seqno,
> +                             pos);
> +               pos = pos->dccpavr_next;
> +       }
> +#endif
> +       pos = av->dccpav_record;
> +
> +       /* first record */
> +       if (!pos) {
> +               avr->dccpavr_next = avr->dccpavr_prev = NULL;
> +               av->dccpav_record = avr;
> +               return;
> +       }
> +
> +       /* find where to insert record... ordered by seqno */
> +       while (pos) {
> +               prev = pos;
> +               if (avr->dccpavr_ack_seqno > pos->dccpavr_ack_seqno)
> +                       break;
> +               pos = pos->dccpavr_next;
> +       }
> +
> +       /* last record */
> +       if (!pos) {
> +               BUG_ON(prev = NULL);
> +
> +               prev->dccpavr_next = avr;
> +               avr->dccpavr_prev = prev;
> +               avr->dccpavr_next = NULL;
> +               return;
> +       }
> +
> +       /* in the middle somewhere or head */
> +       avr->dccpavr_next = pos;
> +       avr->dccpavr_prev = pos->dccpavr_prev;
> +       pos->dccpavr_prev = avr;
> +
> +       /* middle */
> +       if (avr->dccpavr_prev) {
> +               BUG_ON(avr->dccpavr_prev = NULL);
> +
> +               avr->dccpavr_prev->dccpavr_next = avr;
> +       }
> +       /* head */
> +       else {
> +               av->dccpav_record = avr;
> +       }
> +}
> +
>  int dccp_insert_option_ackvec(struct sock *sk, struct sk_buff *skb)
>  {
>         struct dccp_sock *dp = dccp_sk(sk);
>         struct dccp_ackvec *av = dp->dccps_hc_rx_ackvec;
> -       int len = av->dccpav_vec_len + 2;
> +       int len;
>         struct timeval now;
>         u32 elapsed_time;
>         unsigned char *to, *from;
> +       struct dccp_ackvec_record *avr;
> +#ifdef CONFIG_IP_DCCP_DEBUG
> +       const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
> +                               "CLIENT rx ack: " : "server rx ack: ";
> +#endif
>
> +       BUG_ON(av = NULL);
> +       len = av->dccpav_vec_len + 2;
>         dccp_timestamp(sk, &now);
>         elapsed_time = timeval_delta(&now, &av->dccpav_time) / 10;
>
> @@ -35,19 +104,24 @@ int dccp_insert_option_ackvec(struct soc
>         if (DCCP_SKB_CB(skb)->dccpd_opt_len + len > DCCP_MAX_OPT_LEN)
>                 return -1;
>
> -       /*
> -        * XXX: now we have just one ack vector sent record, so
> -        * we have to wait for it to be cleared.
> -        *
> -        * Of course this is not acceptable, but this is just for
> -        * basic testing now.
> +       /* We don't have space to store ACK vector.
> +        * Two options:
> +        * 1) Allocate more space.
> +        * 2) Error.
> +        * We do 2 because it's easy =D
> +        * -sorbo.
>          */
> -       if (av->dccpav_ack_seqno != DCCP_MAX_SEQNO + 1)
> +       if (av->dccpav_record_pool_free = av->dccpav_record_pool_len) {
> +               BUG_ON(1);
>                 return -1;
> +       }
> +       avr = av->dccpav_record_pool[av->dccpav_record_pool_free++];
> +       BUG_ON(avr = NULL);
>
>         DCCP_SKB_CB(skb)->dccpd_opt_len += len;
>
>         to    = skb_push(skb, len);
> +       BUG_ON(to = NULL);
>         *to++ = DCCPO_ACK_VECTOR_0;
>         *to++ = len;
>
> @@ -55,8 +129,8 @@ int dccp_insert_option_ackvec(struct soc
>         from = av->dccpav_buf + av->dccpav_buf_head;
>
>         /* Check if buf_head wraps */
> -       if (av->dccpav_buf_head + len > av->dccpav_vec_len) {
> -               const u32 tailsize = (av->dccpav_vec_len - av->dccpav_buf_head);
> +       if (av->dccpav_buf_head + len > av->dccpav_buf_len) {
> +               const u32 tailsize = (av->dccpav_buf_len - av->dccpav_buf_head);
>
>                 memcpy(to, from, tailsize);
>                 to   += tailsize;
> @@ -76,26 +150,37 @@ int dccp_insert_option_ackvec(struct soc
>          *
>          * This implemention uses just one ack record for now.
>          */
> -       av->dccpav_ack_seqno = DCCP_SKB_CB(skb)->dccpd_seq;
> -       av->dccpav_ack_ptr   = av->dccpav_buf_head;
> -       av->dccpav_ack_ackno = av->dccpav_buf_ackno;
> -       av->dccpav_ack_nonce = av->dccpav_buf_nonce;
> -       av->dccpav_sent_len  = av->dccpav_vec_len;
> +       avr->dccpavr_ack_seqno  = DCCP_SKB_CB(skb)->dccpd_seq;
> +       avr->dccpavr_ack_ptr    = av->dccpav_buf_head;
> +       avr->dccpavr_ack_ackno  = av->dccpav_buf_ackno;
> +       avr->dccpavr_ack_nonce  = av->dccpav_buf_nonce;
> +       avr->dccpavr_sent_len   = av->dccpav_vec_len;
>
> +       dccp_ackvec_insert_avr(av, avr);
>         dccp_pr_debug("%sACK Vector 0, len=%d, ack_seqno=%llu, "
>                       "ack_ackno=%llu\n",
> -                     debug_prefix, av->dccpav_sent_len,
> -                     (unsigned long long)av->dccpav_ack_seqno,
> -                     (unsigned long long)av->dccpav_ack_ackno);
> -       return -1;
> +                     debug_prefix, avr->dccpavr_sent_len,
> +                     (unsigned long long)avr->dccpavr_ack_seqno,
> +                     (unsigned long long)avr->dccpavr_ack_ackno);
> +
> +       return 0;
>  }
>
>  struct dccp_ackvec *dccp_ackvec_alloc(const unsigned int len,
>                                       const gfp_t priority)
>  {
> +       struct dccp_ackvec_record *avr;
>         struct dccp_ackvec *av = kmalloc(sizeof(*av) + len, priority);
>
>         if (av != NULL) {
> +               /* Initial pool of records.  We should allow for this pool to
> +                * grow at run-time or just put a maximum value for it...
> +                * For now, it's a maximum value.
> +                * -sorbo.
> +                */
> +               unsigned int records = 128;
> +               unsigned int i;
> +
>                 av->dccpav_buf_len      = len;
>                 av->dccpav_buf_head     >                         av->dccpav_buf_tail = av->dccpav_buf_len - 1;
> @@ -106,13 +191,40 @@ struct dccp_ackvec *dccp_ackvec_alloc(co
>                 av->dccpav_time.tv_sec  = 0;
>                 av->dccpav_time.tv_usec = 0;
>                 av->dccpav_sent_len     = av->dccpav_vec_len = 0;
> -       }
> +               av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1;
>
> +               av->dccpav_record_pool = kmalloc(
> +                    sizeof(*av->dccpav_record_pool) * records, priority);
> +               if (av->dccpav_record_pool = NULL)
> +                       goto fail_rec_pool;
> +
> +               avr = kmalloc(sizeof(*avr) * records, priority);
> +               if (avr = NULL)
> +                       goto fail_avr;
> +
> +               av->dccpav_record = NULL;
> +               av->dccpav_record_pool_len = records;
> +               /* position 0 contains original pointer, so we can free it */
> +               av->dccpav_record_pool_free = 1;
> +               for (i = 0; i < av->dccpav_record_pool_len; i++)
> +                       av->dccpav_record_pool[i] = avr++;
> +       }
> +out:
>         return av;
> +
> +fail_avr:
> +       kfree(av->dccpav_record_pool);
> +
> +fail_rec_pool:
> +       kfree(av);
> +       av = NULL;
> +       goto out;
>  }
>
>  void dccp_ackvec_free(struct dccp_ackvec *av)
>  {
> +       kfree(av->dccpav_record_pool[0]);
> +       kfree(av->dccpav_record_pool);
>         kfree(av);
>  }
>
> @@ -291,43 +403,61 @@ void dccp_ackvec_print(const struct dccp
>  }
>  #endif
>
> -static void dccp_ackvec_trow_away_ack_record(struct dccp_ackvec *av)
> +static void dccp_ackvec_throw_away_ack_record(struct dccp_ackvec *av,
> +                                             struct dccp_ackvec_record *avr)
>  {
> -       /*
> -        * As we're keeping track of the ack vector size (dccpav_vec_len) and
> -        * the sent ack vector size (dccpav_sent_len) we don't need
> -        * dccpav_buf_tail at all, but keep this code here as in the future
> -        * we'll implement a vector of ack records, as suggested in
> -        * draft-ietf-dccp-spec-11.txt Appendix A. -acme
> +       /* In appendix A of the spec, I think that ack_ptr + 1 means "ack_ptr
> +        * one slot to the left".  I.e. we already acked ACK_PTR so we only
> +        * wish to ack new stuff in the future.  Thus ack_ptr - 1 in this code.
> +        * -sorbo.
>          */
> -#if 0
> -       av->dccpav_buf_tail = av->dccpav_ack_ptr + 1;
> -       if (av->dccpav_buf_tail >= av->dccpav_vec_len)
> -               av->dccpav_buf_tail -= av->dccpav_vec_len;
> -#endif
> -       av->dccpav_vec_len -= av->dccpav_sent_len;
> +       /* XXX: we don't use buf_tail but update it anyway... */
> +       av->dccpav_buf_tail = avr->dccpavr_ack_ptr;
> +       if (!av->dccpav_buf_tail)
> +               av->dccpav_buf_tail = av->dccpav_buf_len;
> +       av->dccpav_buf_tail--;
> +
> +       av->dccpav_vec_len -= avr->dccpavr_sent_len;
> +
> +       /* free records */
> +       dccp_pr_debug("free avr: %llu %p\n", avr->dccpavr_ack_seqno, avr);
> +
> +       if (avr->dccpavr_prev)
> +               avr->dccpavr_prev->dccpavr_next = NULL;
> +       else
> +               av->dccpav_record = NULL;
> +       while (avr) {
> +               av->dccpav_record_pool_free--;
> +               BUG_ON(av->dccpav_record_pool_free = 0);
> +
> +               av->dccpav_record_pool[av->dccpav_record_pool_free] = avr;
> +               avr = avr->dccpavr_next;
> +       }
>  }
>
>  void dccp_ackvec_check_rcv_ackno(struct dccp_ackvec *av, struct sock *sk,
>                                  const u64 ackno)
>  {
> -       /* Check if we actually sent an ACK vector */
> -       if (av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1)
> -               return;
> -
> -       if (ackno = av->dccpav_ack_seqno) {
> +       struct dccp_ackvec_record *avr;
> +
> +       avr = av->dccpav_record;
> +       while (avr) {
> +               if (ackno = avr->dccpavr_ack_seqno) {
>  #ifdef CONFIG_IP_DCCP_DEBUG
> -               struct dccp_sock *dp = dccp_sk(sk);
> -               const char *debug_prefix = dp->dccps_role = DCCP_ROLE_CLIENT ?
> -                                       "CLIENT rx ack: " : "server rx ack: ";
> +                       struct dccp_sock *dp = dccp_sk(sk);
> +                       const char *debug_prefix > +                               dp->dccps_role = DCCP_ROLE_CLIENT ?
> +                                "CLIENT rx ack: " : "server rx ack: ";
>  #endif
> -               dccp_pr_debug("%sACK packet 0, len=%d, ack_seqno=%llu, "
> -                             "ack_ackno=%llu, ACKED!\n",
> -                             debug_prefix, 1,
> -                             (unsigned long long)av->dccpav_ack_seqno,
> -                             (unsigned long long)av->dccpav_ack_ackno);
> -               dccp_ackvec_trow_away_ack_record(av);
> -               av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1;
> +                       dccp_pr_debug("%sACK packet 0, len=%d, ack_seqno=%llu, "
> +                                     "ack_ackno=%llu, ACKED!\n",
> +                                     debug_prefix, 1,
> +                                     (unsigned long long)avr->dccpavr_ack_seqno,
> +                                     (unsigned long long)avr->dccpavr_ack_ackno);
> +                       dccp_ackvec_throw_away_ack_record(av, avr);
> +                       break;
> +               }
> +               avr = avr->dccpavr_next;
>         }
>  }
>
> @@ -337,26 +467,12 @@ static void dccp_ackvec_check_rcv_ackvec
>                                             const unsigned char *vector)
>  {
>         unsigned char i;
> +       struct dccp_ackvec_record *avr;
>
> +       avr = av->dccpav_record;
>         /* Check if we actually sent an ACK vector */
> -       if (av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1)
> +       if (!avr)
>                 return;
> -       /*
> -        * We're in the receiver half connection, so if the received an ACK
> -        * vector ackno (e.g. 50) before dccpav_ack_seqno (e.g. 52), we're
> -        * not interested.
> -        *
> -        * Extra explanation with example:
> -        *
> -        * if we received an ACK vector with ackno 50, it can only be acking
> -        * 50, 49, 48, etc, not 52 (the seqno for the ACK vector we sent).
> -        */
> -       /* dccp_pr_debug("is %llu < %llu? ", ackno, av->dccpav_ack_seqno); */
> -       if (before48(ackno, av->dccpav_ack_seqno)) {
> -               /* dccp_pr_debug_cat("yes\n"); */
> -               return;
> -       }
> -       /* dccp_pr_debug_cat("no\n"); */
>
>         i = len;
>         while (i--) {
> @@ -365,11 +481,22 @@ static void dccp_ackvec_check_rcv_ackvec
>
>                 dccp_set_seqno(&ackno_end_rl, ackno - rl);
>
> +               /* if our AVR sequence number is greater than the ack, go
> +                * forward in the AVR list until it is not so.
> +                */
> +               while (avr) {
> +                       if (!after48(avr->dccpavr_ack_seqno, ackno))
> +                               break;
> +                       avr = avr->dccpavr_next;
> +               }
> +               if (!avr)
> +                       break;
> +
>                 /*
>                  * dccp_pr_debug("is %llu <= %llu <= %llu? ", ackno_end_rl,
>                  * av->dccpav_ack_seqno, ackno);
>                  */
> -               if (between48(av->dccpav_ack_seqno, ackno_end_rl, ackno)) {
> +               if (between48(avr->dccpavr_ack_seqno, ackno_end_rl, ackno)) {
>                         const u8 state = (*vector &
>                                           DCCP_ACKVEC_STATE_MASK) >> 6;
>                         /* dccp_pr_debug_cat("yes\n"); */
> @@ -389,14 +516,11 @@ static void dccp_ackvec_check_rcv_ackvec
>                                               av->dccpav_ack_seqno,
>                                               (unsigned long long)
>                                               av->dccpav_ack_ackno);
> -                               dccp_ackvec_trow_away_ack_record(av);
> +                               dccp_ackvec_throw_away_ack_record(av, avr);
> +                               break;
>                         }
> -                       /*
> -                        * If dccpav_ack_seqno was not received, no problem
> -                        * we'll send another ACK vector.
> -                        */
> -                       av->dccpav_ack_seqno = DCCP_MAX_SEQNO + 1;
> -                       break;
> +                       /* If it wasn't received, continue scanning... we might
> +                        * find another one. */
>                 }
>                 /* dccp_pr_debug_cat("no\n"); */
>
> diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
> index d0fd6c6..4aa16df 100644
> --- a/net/dccp/ackvec.h
> +++ b/net/dccp/ackvec.h
> @@ -26,6 +26,19 @@
>  #define DCCP_ACKVEC_STATE_MASK         0xC0 /* 11000000 */
>  #define DCCP_ACKVEC_LEN_MASK           0x3F /* 00111111 */
>
> +/* ACK vector record as defined in Appendix A of spec.
> + * The list is sorted by ack_seqno
> + */
> +struct dccp_ackvec_record {
> +       u64                             dccpavr_ack_seqno;
> +       unsigned int                    dccpavr_ack_ptr;
> +       u64                             dccpavr_ack_ackno;
> +       u8                              dccpavr_ack_nonce;
> +       unsigned int                    dccpavr_sent_len;
> +       struct dccp_ackvec_record*      dccpavr_next;
> +       struct dccp_ackvec_record*      dccpavr_prev;
> +};
> +

Use struct list_head

>  /** struct dccp_ackvec - ack vector
>   *
>   * This data structure is the one defined in the DCCP draft
> @@ -54,19 +67,23 @@
>   * @dccpav_buf - circular buffer of acknowledgeable packets
>   */
>  struct dccp_ackvec {
> -       unsigned int    dccpav_buf_head;
> -       unsigned int    dccpav_buf_tail;
> -       u64             dccpav_buf_ackno;
> -       u64             dccpav_ack_seqno;
> -       u64             dccpav_ack_ackno;
> -       unsigned int    dccpav_ack_ptr;
> -       unsigned int    dccpav_sent_len;
> -       unsigned int    dccpav_vec_len;
> -       unsigned int    dccpav_buf_len;
> -       struct timeval  dccpav_time;
> -       u8              dccpav_buf_nonce;
> -       u8              dccpav_ack_nonce;
> -       u8              dccpav_buf[0];
> +       unsigned int                    dccpav_buf_head;
> +       unsigned int                    dccpav_buf_tail;
> +       u64                             dccpav_buf_ackno;
> +       u64                             dccpav_ack_seqno;
> +       u64                             dccpav_ack_ackno;
> +       unsigned int                    dccpav_ack_ptr;
> +       unsigned int                    dccpav_sent_len;
> +       unsigned int                    dccpav_vec_len;
> +       unsigned int                    dccpav_buf_len;
> +       struct timeval                  dccpav_time;
> +       u8                              dccpav_buf_nonce;
> +       u8                              dccpav_ack_nonce;
> +       struct dccp_ackvec_record*      dccpav_record;
> +       struct dccp_ackvec_record**     dccpav_record_pool;
> +       unsigned int                    dccpav_record_pool_free;
> +       unsigned int                    dccpav_record_pool_len;
> +       u8                              dccpav_buf[0];
>  };

Try to not reflow the struct for source code alignment at first, to
ease review, then send a patch just reflowing.

>  struct sock;
> diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
> index 93f26dd..1dcd835 100644
> --- a/net/dccp/dccp.h
> +++ b/net/dccp/dccp.h
> @@ -226,7 +226,8 @@ extern int dccp_child_process(struct soc
>  extern int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>                                   struct dccp_hdr *dh, unsigned len);
>  extern int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
> -                               const struct dccp_hdr *dh, const unsigned len);
> +                               const struct dccp_hdr *dh, const unsigned len,
> +                               int fastlane);
>
>  extern int dccp_v4_init_sock(struct sock *sk);
>  extern int dccp_v4_destroy_sock(struct sock *sk);
> diff --git a/net/dccp/input.c b/net/dccp/input.c
> index 55e921b..757539a 100644
> --- a/net/dccp/input.c
> +++ b/net/dccp/input.c
> @@ -152,27 +152,36 @@ static int dccp_check_seqno(struct sock
>  }
>
>  int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
> -                        const struct dccp_hdr *dh, const unsigned len)
> +                        const struct dccp_hdr *dh, const unsigned len,
> +                        int fastlane)
>  {
>         struct dccp_sock *dp = dccp_sk(sk);
>
> -       if (dccp_check_seqno(sk, skb))
> -               goto discard;
> +       /*  If called from the DCCP_OPEN state [fast path] then perform checks
> +        *  as upper layers don't.  If called from DCCP_PARTOPEN, checks will
> +        *  be done by upper layers... so don't repeat them. [else ack vector
> +        *  will be added twice! and packet will be dropped]
> +        *  -sorbo
> +        */
> +       if (fastlane) {

This is unrelated to ack vector records, so should be sent as a
separate changeset and discussed on its own merits

> +               if (dccp_check_seqno(sk, skb))
> +                       goto discard;
>
> -       if (dccp_parse_options(sk, skb))
> -               goto discard;
> +               if (dccp_parse_options(sk, skb))
> +                       goto discard;
>
> -       if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
> -               dccp_event_ack_recv(sk, skb);
> +               if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
> +                       dccp_event_ack_recv(sk, skb);
>
> -       if (dp->dccps_options.dccpo_send_ack_vector &&
> -           dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
> -                           DCCP_SKB_CB(skb)->dccpd_seq,
> -                           DCCP_ACKVEC_STATE_RECEIVED))
> -               goto discard;
> +               if (dp->dccps_options.dccpo_send_ack_vector &&
> +                   dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
> +                                   DCCP_SKB_CB(skb)->dccpd_seq,
> +                                   DCCP_ACKVEC_STATE_RECEIVED))
> +                       goto discard;
>
> -       ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
> -       ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
> +               ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
> +               ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
> +       }
>
>         switch (dccp_hdr(skb)->dccph_type) {
>         case DCCP_PKT_DATAACK:
> @@ -288,6 +297,12 @@ static int dccp_rcv_request_sent_state_p
>                         goto out_invalid_packet;
>                 }
>
> +                if (dp->dccps_options.dccpo_send_ack_vector &&
> +                    dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
> +                                    DCCP_SKB_CB(skb)->dccpd_seq,
> +                                    DCCP_ACKVEC_STATE_RECEIVED))
> +                        goto out_invalid_packet; /* FIXME: change error code */
> +
>                 dp->dccps_isr = DCCP_SKB_CB(skb)->dccpd_seq;
>                 dccp_update_gsr(sk, dp->dccps_isr);
>                 /*
> @@ -400,7 +415,7 @@ static int dccp_rcv_respond_partopen_sta
>
>                 if (dh->dccph_type = DCCP_PKT_DATAACK ||
>                     dh->dccph_type = DCCP_PKT_DATA) {
> -                       dccp_rcv_established(sk, skb, dh, len);
> +                       dccp_rcv_established(sk, skb, dh, len, 0);
>                         queued = 1; /* packet was queued
>                                        (by dccp_rcv_established) */
>                 }
> @@ -474,14 +489,14 @@ int dccp_rcv_state_process(struct sock *
>                 if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
>                         dccp_event_ack_recv(sk, skb);
>
> -               ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
> -               ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
> -
>                 if (dp->dccps_options.dccpo_send_ack_vector &&
>                     dccp_ackvec_add(dp->dccps_hc_rx_ackvec, sk,
>                                     DCCP_SKB_CB(skb)->dccpd_seq,
>                                     DCCP_ACKVEC_STATE_RECEIVED))
>                         goto discard;
> +
> +               ccid_hc_rx_packet_recv(dp->dccps_hc_rx_ccid, sk, skb);
> +               ccid_hc_tx_packet_recv(dp->dccps_hc_tx_ccid, sk, skb);
>         }
>
>         /*
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index f935659..5fdad99 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -795,7 +795,7 @@ int dccp_v4_do_rcv(struct sock *sk, stru
>         struct dccp_hdr *dh = dccp_hdr(skb);
>
>         if (sk->sk_state = DCCP_OPEN) { /* Fast path */
> -               if (dccp_rcv_established(sk, skb, dh, skb->len))
> +               if (dccp_rcv_established(sk, skb, dh, skb->len, 1))
>                         goto reset;
>                 return 0;
>         }
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index ba50c96..14f1c13 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -1159,7 +1159,7 @@ static int dccp_v6_do_rcv(struct sock *s
>                 opt_skb = skb_clone(skb, GFP_ATOMIC);
>
>         if (sk->sk_state = DCCP_OPEN) { /* Fast path */
> -               if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
> +               if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len, 1))
>                         goto reset;
>                 return 0;
>         }
