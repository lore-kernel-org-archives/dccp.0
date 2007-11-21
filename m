From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 21 Nov 2007 12:46:46 +0000
Subject: Re: Test tree patch inventory - update
Message-Id: <20071121124646.GD24995@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <20071120201041.GA24995@ghostprotocols.net>
In-Reply-To: <20071120201041.GA24995@ghostprotocols.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Nov 21, 2007 at 11:52:55AM +0000, Gerrit Renker escreveu:
> | >                         Test Tree Inventory
> | > 		            =========> | >
> | > 	[CCID3]: Ignore trivial amounts of elapsed time
> | 
> | Applied, but I think we can revisit elapsed time later by taking a
> | timestamp earlier, at dccp_v4_rcv, because then there can be time spent
> | in sk_backlog, etc. We could then store a timestamp on skb->cb and the
> | ccids would set a flag on dccp_sock to tell that the timestamp is
> | wanted.
> | 
> The elapsed time is needed for RTT measurements and you are right, the
> hole RTT measurement issue needs more work. And this includes CCID2
> which goes into the other extreme and uses a coarse-grained HZ
> resolution of RTTs. But ever since there was the issue with interface
> timestamps (skb_get_timestamp) I got convinced that it is not useful
> to increase the resolution below, say, 1 millisecond. (There was a
> discussion with Ian about above patch where this came up.) The reason
> is that when we do such fine-grained resolution, we also get a lot of
> noise: much of the TCP code works very well with just the jiffies
> resolution.
> With regard to your point, I think it would be ideal to use timestamps
> in the TCP High-Speed way (RFC 1323), where we could use a resolution of
> 0.00001 seconds (dccp_timestamp() and RFC 4340, 13.). That is still
> very high-resolution when considering that the RFC2988 remarks regarding
> clock granularity in part referred back to that old BSD timer which had
> a 0.5 second granularity.
> I agree fully with your suggestion: all CCID-specific RTT measurement
> code can be eliminated once there is a working alternative. The
> challenge that needs to be overcome is to make the timestamp usage robust
> against packet duplication and re-ordering.

I'll try at some point to measure the maximum time a packet stays on
sk_backlog on a heavily loaded server. But agreed, this is not urgent,
just to keep on the back of our minds for later.
 
> | Just moving ccid3hcrx_bytes_recv to after ccid3hcrx_tfrc we can save 8
> | bytes.
> This is good news - with regard to the above I still have in the back of
> my mind that there are unused icsk fields which may also be used for
> storing timestamps; this could help (in a future effort) to reduce further.
> 
>   
> | > 2. Main CCID3 patch set
> | > -----------------------
> | > This is the original CCID3 patch set, developed in Feb/Mar, significantly reordered to
> | > make the test tree fully bisectable. 
> | > The patch set does three things (reflected in the order of batches):
> | > 
> | > 	(1) new TX history for TFRC (packet_history.{c,h}),
> | 
> | Why do we need DECLARE_TFRC_TX_CACHE?
> | 
> It is not needed for compilation. When I first did this patch set there were three different
> kmem_caches defined in ccid3.c:
> 	* one for the TX history (packet_history.c; for which the above macro was declared),
> 	* one for the RX history (packet_history.c)
> 	* one for the Loss History (loss_interval.c)
> The loss interval history has since gone, this was done when you worked on Ian's patch set
> around March/April. When the patch set is fully applied, the RX history cache also goes,
> since the new patch set uses at most 4 entries per socket which are supplied by a static
> kmem_cache in packet_history.c.
> Long story, short conclusion: if you think this is an eyesore, feel free to take it out. I
> left it in since I thought it would make the purpose clearer (since ctags then automatically
> jumps to packet_history.h).
> 
> 
> | > 	[TFRC]: New RX history implementation
> | 
> | 
> | +static struct kmem_cache *tfrcxh;
> | 
> | Why "xh"?
> | 
> This is a typo, my mistake. I had meant to use the suffix `rxh' to indicate that
> this static cache is for the RX history, but it somehow merged with `r'
> from tfrc. Are you okay with tfrc_rxh? I will uploaded a revised patch

tfrc_rx_hist would be better, its not overly long and for the casual
reader provides more info.

> which uses this identifier instead. Thank you for pointing this out.
> 
> Gerrit
