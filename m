From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Tue, 20 Nov 2007 20:10:41 +0000
Subject: Re: Test tree patch inventory - update
Message-Id: <20071120201041.GA24995@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Sat, Nov 17, 2007 at 03:42:52PM +0000, Gerrit Renker escreveu:
>                         Test Tree Inventory
> 		        =========> 
> This is the list of current small batches (from oldest to latest) as of Sat 17 Nov.
> The entire test tree is fully bisectable, so batches can be combined freely.
> 
> Spaces in between sets indicate separate blocks.
> 
> The CCID3 set has been completely re-arranged and recombined to give self-contained and
> independent patches. Within the set there are further, self-contained blocks.
> 
> 
> 1. Miscellaneous CCID3 fixes
> ----------------------------
> A small set of various fixes, independent of the main CCID3 patch set.
> 
> 	[CCID3]: Revert use of MSS instead of s

Applied.

> 	[CCID3]: Ignore trivial amounts of elapsed time

Applied, but I think we can revisit elapsed time later by taking a
timestamp earlier, at dccp_v4_rcv, because then there can be time spent
in sk_backlog, etc. We could then store a timestamp on skb->cb and the
ccids would set a flag on dccp_sock to tell that the timestamp is
wanted.

Ah, and there is more space to save, after this patch the layout is
this, on x86_64:

struct ccid3_hc_rx_sock {
	struct tfrc_rx_info     ccid3hcrx_tfrc;                 /*   0  12 */

	/* XXX 4 bytes hole, try to pack */

	u64                     ccid3hcrx_seqno_nonloss:48;     /*  16   8 */
	u64                     ccid3hcrx_ccval_nonloss:4;      /*  16   8 */
	u64                     ccid3hcrx_ccval_last_counter:4; /*  16   8 */
	enum ccid3_hc_rx_states ccid3hcrx_state:8;              /*  20   4 */
	u32                     ccid3hcrx_bytes_recv;           /*  24   4 */

	/* XXX 4 bytes hole, try to pack */

	ktime_t                 ccid3hcrx_tstamp_last_feedback; /* 32   8 */
	ktime_t                 ccid3hcrx_tstamp_last_ack;      /* 40   8 */
	struct list_head        ccid3hcrx_hist;                 /* 48  16 */
	/* --- cacheline 1 boundary (64 bytes) --- */
	struct list_head        ccid3hcrx_li_hist;              /* 64  16 */
	u16                     ccid3hcrx_s;                    /* 80   2 */

	/* XXX 2 bytes hole, try to pack */

	u32                     ccid3hcrx_pinv;                 /* 84   4 */

	/* size: 88, cachelines: 2 */
	/* sum members: 78, holes: 3, sum holes: 10 */
	/* last cacheline: 24 bytes */
};

Just moving ccid3hcrx_bytes_recv to after ccid3hcrx_tfrc we can save 8
bytes.

> 	[CCID3]: Accurately determine idle & application-limited periods

Applied.

> 	[CCID3]: Inline for moving average

Applied
 
> 2. Main CCID3 patch set
> -----------------------
> This is the original CCID3 patch set, developed in Feb/Mar, significantly reordered to
> make the test tree fully bisectable. 
> The patch set does three things (reflected in the order of batches):
> 
> 	(1) new TX history for TFRC (packet_history.{c,h}),

Why do we need DECLARE_TFRC_TX_CACHE?

> 	(2) new RX history for TFRC (packet_history.{c,h}),
> 	(3) new Loss Intervals database (loss_interval.{c,h}).
> 
> (Actually it is 3+1/2 things, the third patch introduces tfrc_module.c).
> 
> 	[TFRC]: Migrate TX history to singly-linked list
> 	[TFRC]: Remove old (doubly-linked list) TX history 
> 
> 	[TFRC]: Provide central source file and debug facility
> 
> 	[TFRC]: New RX history implementation


+static struct kmem_cache *tfrcxh;

Why "xh"?

> 	[CCID3]: Hook up with new RX history interface
> 	[TFRC]: Remove old RX history interface

Will try to continue later today.

- Arnaldo
