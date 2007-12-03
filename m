From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Mon, 03 Dec 2007 14:54:43 +0000
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Message-Id: <20071203145443.GE15034@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Mon, Dec 03, 2007 at 01:49:47PM +0000, Gerrit Renker escreveu:
> | > Are you suggesting using netdev exclusively or in addition to dccp@vger.kernel.org?
> | 
> | Well, since at least one person that has contributed significantly in
> | the past has said he can't cope with traffic on netdev, we can CC
> | dccp@vger.kernel.org
> I have a similar problem with the traffic but agree and will copy as well.
> 
> 
> | > have been posted and re-posted for a period of over 9 months on dccp@vger, and
> | 
> | Being posted and re-posted does not guarantee that the patch is OK or
> | that is in a form that is acceptable to all tree maintainers.

> With the first point I couldn't agree more, but this is not really what I meant - the point
> was that despite posting and re-posting there was often silence. And now there is feedback,
> in form of a patchset made by you; and all that I am asking for is just to be given the time to
> look that through. Last time a RFC patch appeared at 3pm and was checked in the same evening
> (only found out next morning).

I was too optimistic about that one, feeling that it was safe, sorry
about that, will avoid doing that in the future.

> With your experience and long background as a maintainer maybe you expect quicker turn-around
> times, but I also had waited patiently until you had had a chance to review the stuff I sent.

Agreed, my bad, will be more patient with my side as you've been with
yours :-)

> | > | . The code that allocates the RX ring deals with failures when one of the entries in
> | > |   the ring buffer is not successfully allocated, the original code was leaking the
> | > |   successfully allocated entries.
> | 
> | Sorry for not point out exactly this, here it goes:
> | 
> | Your original patch:
> | 
> | +int tfrc_rx_hist_init(struct tfrc_rx_hist *h)
> | +{
> | +	int i;
> | +
> | +	for (i = 0; i <= NDUPACK; i++) {
> | +		h->ring[i] = kmem_cache_alloc(tfrc_rxh_cache, GFP_ATOMIC);
> | +		if (h->ring[i] = NULL)
> | +			return 1;
> | +	}
> | +	h->loss_count = 0;
> | +	h->loss_start = 0;
> | +	return 0;
> | +}
> | +EXPORT_SYMBOL_GPL(tfrc_rx_hist_init);
> | 
> I expected this and it actually was very clear from your original message. I fully back up
> your solution in this point, see below. But my question above was rather: are there any
> other bugs rather than the above leakage, which is what the previous email seemed to indicate?
> 
> With regard to your solution - you are using
> 
> 	int tfrc_rx_hist_alloc(struct tfrc_rx_hist *h)
> 	{
> 		h->ring = kmem_cache_alloc(tfrc_rx_hist_slab, GFP_ATOMIC);
> 		h->loss_count = h->loss_start = 0;
> 		return h->ring = NULL;
> 	}
> 
> which is better not only for one but for two reasons. It solves the leakage and in addition makes
> the entire code simpler. Fully agreed.

good
   
> 
> | 
> | > | . I haven't checked if all the code was commited, as I tried to introduce just what was
> | > |   immediatelly used, probably we'll need to do some changes when working on the merge
> | > |   of your loss intervals code.
> | > Sorry I don't understand this point.
> | 
> | Let me check now and tell you for sure:
> | 
> | tfrc_rx_hist_delta_seqno and tfrc_rx_hist_swap were not included, as
> | they were not used, we should introduce them later, when getting to the
> | working on the loss interval code.
> Ah thanks, that was really not clear. Just beginning to work through the set.

great
 
> | > 	static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
> | > 	{
> | > 		// ...
> | > 		u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
> | > 
> | > 		if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
> | > 			if (is_data_packet) {
> | > 				do_feedback = FBACK_INITIAL;
> | > 				ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
> | > 				ccid3_hc_rx_update_s(hcrx, payload_size);
> | > 			}
> | > 			goto update_records;
> | > 		}
> | > 
> | > => Non-data packets are ignored for the purposes of computing s (this is in the RFC),
> | >     consequently update_s() is only called for data packets; using the two following
> | >     functions:
> | > 
> | > 
> | > 	static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
> | > 	{
> | > 		return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
> | > 	}
> | 
> | I hadn't considered that tfrc_ewma would for every packet check if the
> | avg was 0 and I find it suboptimal now that I look at it, we are just
> | feeding data packets, no? 
> Yes exactly, only data packets are used for s.
> 
> | > 	static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
> | > 	{
> | > 		if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
> | > 			hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
> | > 	}
> | 
> | 	And we also just do test for len > 0 in update_s, that looks like
> | also excessive, no?
> Hm, I think we need to make it robust against API bugs and/or zero-sized
> data packets. The check `len > 0' may seem redundant but it catches such
> a condition. For a moving average an accidental zero value will have
> quite an impact on the overall value. In CCID3 it is
> 
>   	x_new = 0.9 * x_old + 0.1 * len
> 
> So if len is accidentally 0 where it should not be, then each time the
> moving average is reduced to 90%.

So we must make it a BUG_ON, not something that is to be always present.
 
> |As we should pass just data packets, perhaps we should just do a BUG_ON there.

> That is a good idea, can we make it a DCCP_WARN-like thing so that the computer does
> not freeze? 

that is ok at this point where we're still going thru lots of patches,
as soon as we collectively agree that it should be a serious bug to pass
a 0 sized packet to this routine, we can turn it into a BUG_ON. But we
must make it from now clear that it is something completely unexpected.
 
> | Understood, consider this one then an optimization and not a bugfix. My
> | motivation to add this as an optimization had I realized that tfrc_ewma
> | checks for avg being zero would have been greatly diminished, 
> | but since we are having all this discussion, I think the optimization is
> | OK to have merged.

> I see your point but as this is in patch 7/7 can you please allow me
> some time to digest it.  

OK, its normal working day, so I'm supposed to be doing "Real Work", so
you'll have plenty of time to look at it before I get back at doing more
serious work on DCCP.
 
> | > | 
> | > | 	It is available at:
> | > | 
> | > | master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25
> | > | 
> | > Need to do this separately. As said, the code has been developed and tested over a long time,
> | > it took a long while until it acted predictably, so being careful is very important.
> | 
> | Gerrit, I do these kinds of code reorganizations on the core Linux
> | networking for ages, I'm not perfect (huh! :-P) but I also didn't
> | performed extensive testing doing coverage analisys of all the
> | imaginable possibilities, just did my best to improve the abstractions
> | and the code, ocasionally fixing bugs as I went thru the existing code.
> | 

> As above - more than likely you will have done a really good job. In the
> past experience of collaborating with you I can not recall a single bad
> thing introduced, and learned lots from that. It is just, I am not as
> fast as you and need longer to understand what is going on. 
> As a comparison - the entire patch set took about a full month to do.
> But that meant I am reasonably sure the algorithm is sound and can cope
> with problematic conditions.

And from what I saw so far that is my impression too, if you look at
what I'm doing it is:

1. go thru the whole patch trying to understand hunk by hunk
2. do consistency changes (add namespace prefixes)
3. reorganize the code to look more like what is already there, we
   both have different backgrounds and tastes about how code should
   be written, so its only normal that if we want to keep the code
   consistent, and I want that, I jump into things I think should be
   "reworded", while trying to keep the algorithm expressed by you.
 
> | But I can't just take your patches as-is all the time, I have my
> | personal preferences and will try to use them when taking the time to
> | merge code from anyone.
> |
> ... which is perfectly allright and actually I am grateful for that. It was just
> last week where your feedback on the passive-close states lead to a reconsideration
> which brought to light three previously unresolved problems:
> 
>  (a) an skb leakage which you pointed out
>  (b) not checking for state transitions from other states
>  (c) how to handle simultaneous-close
> 
> So it all started when you said you had concerns about (a), but you may
> have had an inkling or so, and see there were two more problems. Had you
> silently merged these patches, these three problems would probably still
> exist.

Glad that I was of help
 
> In other words I am not interested in accepting-patches-for-instant-gratification,
> let's discuss where the code may be weak and iron that out.

Excellent
 
> Thanks a lot for your clarifying email I now understand better.
> Hopefully there will be feedback. If you can bear with me until tomorrow
> (Tuesday) or better Wednesday, I will have a look and send feedback
> about your patch set. I already have some ideas, but need to sit down
> and look at it.

That is perfectly fine and will give me time to use the regression
testing that you mentioned and also to let me think about further
automatization on regression testing.

Thank you,

- Arnaldo
