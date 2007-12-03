From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 03 Dec 2007 12:44:12 +0000
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Message-Id: <20071203124412.GC15034@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Dec 03, 2007 at 08:35:12AM +0000, Gerrit Renker escreveu:
> Hi Arnaldo,
> 
> hank you for going through this. I have just backported your recent patches of 2.6.25
> to the DCCP/CCID4/Faster Restart test tree at 
> 	git://eden-feed.erg.abdn.ac.uk/dccp_exp {dccp,ccid4,dccp_fr}
> as per subsequent message.
> | 	 do, so please consider moving DCCP discussion to netdev@vger.kernel.org,
> | 	 where lots of smart networking folks are present and can help our efforts
> | 	 on turning RFCs to code.
> Are you suggesting using netdev exclusively or in addition to dccp@vger.kernel.org?

Well, since at least one person that has contributed significantly in
the past has said he can't cope with traffic on netdev, we can CC
dccp@vger.kernel.org.

> 
> | 	Please take a look at this patch series where I reorganized your work on the new
> | TFRC rx history handling code. I'll wait for your considerations and then do as many
> | interactions as reasonable to get your work merged.
> | 
> | 	It should be completely equivalent, plus some fixes and optimizations, such as:
> It will be necessary to address these points one-by-one. Before diving into making
> fixes and `optimisations', have you tested your code? The patches you are referring to

I have performed basic tests, and when doing so noticed a bug in
inet_diag, that I commented with Herbert Xu and he has since provided a
fix.

> have been posted and re-posted for a period of over 9 months on dccp@vger, and

Being posted and re-posted does not guarantee that the patch is OK or
that is in a form that is acceptable to all tree maintainers. DaveM is
subscribed to dccp@vger and could have picked this if he had the time to
do the review. I didn't, but now I'm trying to spend my time on
reviewing your patches and in the process doing modifications I find
appropriate while trying hard not to introduce bugs in your hard work
to get it merged.

> there are regression tests which show that this code improves on the existing Linux
> implementation. These are labelled as `test tree' on 
> 	http://www.linux-foundation.org/en/Net:DCCP_Testing#Regression_testing
> So if you are making changes to the code, I would like to ask if you have run similar
> regression tests, to avoid having to step back later.

Fair enough, I will do that before asking Herbert or Dave to pull from
my tree.
 
> | . The code that allocates the RX ring deals with failures when one of the entries in
> |   the ring buffer is not successfully allocated, the original code was leaking the
> |   successfully allocated entries.

Sorry for not point out exactly this, here it goes:

Your original patch:

+int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
+{
+	int i;
+
+	for (i = 0; i <= NDUPACK; i++) {
+		h->ring[i] = kmem_cache_alloc(tfrc_rxh_cache, GFP_ATOMIC);
+		if (h->ring[i] = NULL)
+			return 1;
+	}
+	h->loss_count = 0;
+	h->loss_start = 0;
+	return 0;
+}
+EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);

Then, in ccid3_hc_rx_init you do:

static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
{
        struct ccid3_hc_rx_sock *hcrx = ccid_priv(ccid);

        ccid3_pr_debug("entry\n");

        hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
        tfrc_lh_init(&hcrx->ccid3hcrx_li_hist);
        return tfrc_rx_hist_init(&hcrx->ccid3hcrx_hist);
}

So if tfrc_rx_hist_init fail to allocate, say, the last entry in the
ring, it will return 1, and from looking at how you initialize
h->loss_{count,start} to zero I assumed that the whole tfrc_rx_hist
is not zeroed when tfrc_rx_hist_init is called, so one can also assume
that the ring entries are not initialized to NULL and that if the
error recovery is to assume that later on tfrc_rx_hist_cleanup is called
we would not have a leak, but an OOPS when tfrc_rx_hist_cleanup tries
to call kfree_cache_free on the uninitialized ring entries.

But if you look at ccid_new(), that calls ccid3_hc_rx_init(), you'll see
that when the ccid rx or hx routine fails, it just frees the
struct ccid with the area where h->ring is, so, what was not cleaned up
by the ccid init routine is effectively forgot, leaked.

I first did the cleanup at tfrc_rx_hist_init (that I renamed to
tfrc_rx_hist_alloc, since it doesn't just initializes things, but
allocates entries from slab), but then I just made the rx history slab
have arrays of tfrc_rx_hist_entry objects, not individual ones as your
code always allocates them as arrays.

> | . We do just one allocation for the ring buffer, as the number of entries is fixed we
> |   should just do one allocation and not TFRC_NDUPACK times.
> Will look at the first point in the patch; with regard to the second point I agree, this
> will make the code simpler, which is good. 

good

> | . I haven't checked if all the code was commited, as I tried to introduce just what was
> |   immediatelly used, probably we'll need to do some changes when working on the merge
> |   of your loss intervals code.
> Sorry I don't understand this point.

Let me check now and tell you for sure:

tfrc_rx_hist_delta_seqno and tfrc_rx_hist_swap were not included, as
they were not used, we should introduce them later, when getting to the
working on the loss interval code.
 
> | . I changed the ccid3_hc_rx_packet_recv code to set hcrx->ccid3hcrx_s for the first
> |   non-data packet instead of calling ccid3_hc_rx_set_state, that would use 0 as the
> |   initial value in the EWMA calculation.

> This is a misunderstanding. Non-data packets are not considered in the moving average
> for the data packet size `s'; and it would be an error to do (consider 40byte Acks vs.
> 1460byte data packets, also it is in RFC 4342). 
> Where would the zero initial value come from? I think this is also a misunderstanding.
> Please have a look below:
> 	static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
> 	{
> 		// ...
> 		u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
> 
> 		if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
> 			if (is_data_packet) {
> 				do_feedback = FBACK_INITIAL;
> 				ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
> 				ccid3_hc_rx_update_s(hcrx, payload_size);
> 			}
> 			goto update_records;
> 		}
> 
> => Non-data packets are ignored for the purposes of computing s (this is in the RFC),
>     consequently update_s() is only called for data packets; using the two following
>     functions:
> 
> 
> 	static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
> 	{
> 		return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
> 	}

I hadn't considered that tfrc_ewma would for every packet check if the
avg was 0 and I find it suboptimal now that I look at it, we are just
feeding data packets, no? So checking just when we are at
TFRC_RSTATE_NO_DATA, as your code does seems to be better, but not by
calling ccid3_hc_rx_update_s, but just doing:

<SNIP>
	{
                do_feedback = CCID3_FBACK_INITIAL;
                ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
                hcrx->ccid3hcrx_s = payload_size;
	}
<SNIP>
 
> 	static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
> 	{
> 		if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
> 			hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
> 	}

	And we also just do test for len > 0 in update_s, that looks like
also excessive, no? As we should pass just data packets, perhaps we should
just do a BUG_ON there.
> 
> => Hence I can't see where a zero value should come from: ccid3hrx_s is initially 
>     initialised with zero (memset(...,0,...)); when first called, update_s() will
>     feed a non-zero payload size to tfrc_ewma(), which will return  `newval' = payload_size,
>     hence the first data packet will contribute a non-zero payload_size.
>     Zero-sized DCCP-Data packets are pathological and are ignored by the CCID calculations
>     (not by the receiver); a corresponding counterpart for zero-sized

Understood, consider this one then an optimization and not a bugfix. My
motivation to add this as an optimization had I realized that tfrc_ewma
checks for avg being zero would have been greatly diminished, but since
we are having all this discussion, I think the optimization is
OK to have merged.
 
> | 
> | 	It is available at:
> | 
> | master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25
> | 
> Need to do this separately. As said, the code has been developed and tested over a long time,
> it took a long while until it acted predictably, so being careful is very important.

Gerrit, I do these kinds of code reorganizations on the core Linux
networking for ages, I'm not perfect (huh! :-P) but I also didn't
performed extensive testing doing coverage analisys of all the
imaginable possibilities, just did my best to improve the abstractions
and the code, ocasionally fixing bugs as I went thru the existing code.

So while I understand your concerns about being careful, rest asured I
_am_ careful and will be even _more_ careful by using the regression
tests you mentioned, as it would be a shame not to use them.

But I can't just take your patches as-is all the time, I have my
personal preferences and will try to use them when taking the time to
merge code from anyone.
 
> I would rather not have my patches merged and continue to run a test tree if the current
> changes alter the behaviour to the worse.

Its not like that, you released your code as GPL, its out there, it
would be a shame not to merge it, but not as-is all the time. I'm making
sure I stick my name when I do major code changes while giving you due
credit for your work.

And heck, this was an [RFC], I didn't pushed this upstream before
listening to your concerns. Its only fair that if you expect me to
review your work, I should expect for you to review my work, even more
when is to improve yours.

Best Regards,

- Arnaldo
