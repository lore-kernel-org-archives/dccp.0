From: "Ian McDonald" <ian.mcdonald@jandi.co.nz>
Date: Mon, 28 Aug 2006 00:18:33 +0000
Subject: Fwd: CCID2 patches
Message-Id: <5640c7e00608271718wce9b5fbwf5ecb33c62a8ab94@mail.gmail.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This was meant to go to dccp rather than netdev... Never mind.

It does raise the question though is whether the dccp mailing list is
worth keeping separate? Thoughts?

Ian
---------- Forwarded message ----------
From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Aug 28, 2006 12:12 PM
Subject: CCID2 patches
To: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Cc: David Miller <davem@davemloft.net>, arnaldo.melo@gmail.com, netdev
<netdev@vger.kernel.org>


> On 8/27/06, Andrea Bittau <a.bittau@cs.ucl.ac.uk> wrote:
> > The two sets of patches are at:
> > http://darkircop.org/dccp
> >

These look good in general and I know you have done a lot of work on these.

Here are some comments. NB I haven't actually compiled or tested -
just from reading the code.

You need a description of each patch and signed off line in each
patch. They can't be accepted in this form. Alternatively they could
be resubmitted.

Please state whether the target is 2.6.18 (bug fixes only) or 2.6.19
(enhancements)

Please state any dependencies between patches.

In patch 01_ackvec_opt:

-int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
+u64 dccp_ackvec_parse(struct sock *sk, u64 ackno,
                      const u8 opt, const u8 *value, const u8 len)
 {
-       if (len > DCCP_MAX_ACKVEC_LEN)
-               return -1;
-
        /* dccp_ackvector_print(DCCP_SKB_CB(skb)->dccpd_ack_seq, value, len); */
-       dccp_ackvec_check_rcv_ackvector(dccp_sk(sk)->dccps_hc_rx_ackvec, sk,
-                                       DCCP_SKB_CB(skb)->dccpd_ack_seq,
-                                       len, value);
-       return 0;
+       return dccp_ackvec_check_rcv_ackvector(dccp_sk(sk)->dccps_hc_rx_ackvec,
+                                              sk, ackno, len, value);

This becomes a one line function. This is only used in one place that I can
see so this should go and that code should go there... Also there is some
weird shit going on as this is also defined as inline with return -1 in
ackvec.h. This needs fixing as well.

In patch 05_ccid2_seq_alloc I don't get this code:

+static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx, int num)
+{
+       struct ccid2_seq *seqp;
+       int i;
+
+       /* check if we have space to preserve the pointer to the buffer */
+       if (hctx->ccid2hctx_seqbufc >= (sizeof(hctx->ccid2hctx_seqbuf) /
+                                       sizeof(struct ccid2_seq*)))
+               return -ENOMEM;
+
+       /* allocate buffer and initialize linked list */
+       seqp = kmalloc(sizeof(*seqp) * num, gfp_any());
+       if (seqp = NULL)
+               return -ENOMEM;
+
+       for (i = 0; i < (num - 1); i++) {
+               seqp[i].ccid2s_next = &seqp[i + 1];
+               seqp[i + 1].ccid2s_prev = &seqp[i];
+       }

If you are allocating an array of structures in effect you shouldn't
need to set next/prev pointers as they are allocated contiguously. If
you are allocating groups of arrays, which I suspect you are, I still
think the design is a bit ugly and wastes memory.

In 06_ccid2_ssthresh you don't justify why ssthresh can be infinite to
start off with. And if it is allowed then I don't think you should do
this by just picking a random high number. Change it to something like
~0

In 07_ccid2_send_poll - changing to 1 msec poll is not nice. I now you
said this should be dequeued. I've just added tx queuing to 2.6.19
tree now so you can do this. Up to Dave/Arnaldo if this is OK as a
short term solution.

In 08_ccid2_cwnd:
+static void ccid2_congestion_event(struct ccid2_hc_tx_sock *hctx,
+                                  struct ccid2_seq *seqp)
+{
+       if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
+               dccp_pr_debug("Multiple losses in one RTT---treating as one\n");

I think that should be a ccid2_pr_debug not a dccp_pr_debug

in 10_ccid2_change:

in ccid2_change_srtt why do you do the test there because you are
going to take twice as many instructions if you are going to alter. Is
this to minimise sets?

in 11_ccid2_profile:

in ccid2_profile_time the code there is ugly. I am guessing you are
assuming 32 bit intel vs 64 bit intel. The world doesn't revolve
around intel. If you need something architecture specific that should
be put into the arch subtree not here.

in ccid2_hc_tx_init why are you using 6000? What is the significant.
Make it a constant defined somewhere.
--
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand


-- 
Ian McDonald
Web: http://wand.net.nz/~iam4
Blog: http://imcdnzl.blogspot.com
WAND Network Research Group
Department of Computer Science
University of Waikato
New Zealand
