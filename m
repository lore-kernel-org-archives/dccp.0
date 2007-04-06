From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 06 Apr 2007 08:21:34 +0000
Subject: Re: [PATCH 6/43]: New infrastructure for loss detection
Message-Id: <200704060921.34592@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200704051633.35466@strip-the-willow>
In-Reply-To: <200704051633.35466@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Eddie -

|  Sorry if this is a stupid question, but are the entries corresponding to Loss 
|  Intervals stored elsewhere?  You need at least 8 entries for that mandatory 
|  option.
10 patches too early - this patch does only the receiver history structure. The
Loss Intervals database structure starts at patch #16 (12a) and ends at patch #24. 
The number of entries is 9, 8 loss intervals plus space for tracking I_0.



|  
|  
|  Gerrit Renker wrote:
|  > [CCID 3]: New infrastructure for loss detection
|  > 
|  > This provides a generic RX history unit for TFRC based protocols.
|  > 
|  > Why?
|  > I have spent several weeks trying to make sense out of the existing, circular-list
|  > based RX history implementation. It is complex, heavy-weight and puts nothing but
|  > stones in the way of fixing the identified current bugs in loss detection.
|  > 
|  > A full list implementation is in fact not needed: both for RTT estimation
|  > (needed only to compute the first loss interval, RFC 3448, 6.3.1) and for
|  > loss detection, only a minimum of 4 entries is needed. The overhead of
|  > allocating and later garbage-collecting further entries is not justified,
|  > and it introduces a memory and processing bottleneck.
|  > 
|  > The present design is lightweight and object-oriented:
|  >  * only the minimum number of entries is used;
|  >  * circular array of pointers:
|  >    - faster swapping of entries for sorting,
|  >    - the indexed-array semantics matches the requirments of loss detection
|  >      (3 consecutive packets) and RTT estimation (also consecutive packets)
|  >      much more naturally than a doubly-linked list;
|  >  * one and the same structure is used both for RTT sampling and for
|  >    loss detection, reducing memory demands;
|  >  * generic definition, can later be reused for small-packet variant of
|  >    CCID 3 etc.
|  > 
|  > This patch lays the foundation in terms of the main data structure with some rudimentary
|  > routines for basic access. Further patches will fill in the details with regard to CCID3.
|  > 
|  > Details of the algorithm are documented and illustrated in section 3 of
|  > http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/
|  > 
|  > Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
|  > ---
|  >  net/dccp/ccids/lib/packet_history.h |  101 ++++++++++++++++++++++++++++++++++++
|  >  1 file changed, 101 insertions(+)
|  > 
|  > --- a/net/dccp/ccids/lib/packet_history.h
|  > +++ b/net/dccp/ccids/lib/packet_history.h
|  > @@ -45,6 +45,9 @@
|  >  /* Number of later packets received before one is considered lost */
|  >  #define TFRC_RECV_NUM_LATE_LOSS	 3
|  >  
|  > +/* Number of packets to wait after a missing packet (RFC 4342, 6.1) */
|  > +#define NDUPACK 3
|  > +
|  >  #define TFRC_WIN_COUNT_PER_RTT	 4
|  >  /* Subtraction a-b modulo-16, respects circular wrap-around */
|  >  #define SUB16(a,b)		(((a) + 16 - (b)) & 0xF)
|  > @@ -106,6 +109,104 @@ struct dccp_rx_hist {
|  >  extern struct dccp_rx_hist *dccp_rx_hist_new(const char *name);
|  >  extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
|  >  
|  > +/**
|  > + *   tfrc_rx_hist  -  RX history structure for TFRC-based protocols
|  > + *
|  > + *   @ring:		Packet history for RTT sampling and loss detection
|  > + *   @loss_count:	Number of entries in circular history
|  > + *   @loss_start:	Movable index (for loss detection)
|  > + *   @rtt_sample_prev:  Used during RTT sampling, points to candidate entry
|  > + *   @lock:		Serialize concurrent access
|  > + */
|  > +struct tfrc_rx_hist {
|  > +	struct dccp_rx_hist_entry	*ring[NDUPACK + 1];
|  > +	u8				loss_count:2,
|  > +					loss_start:2;
|  > +#define rtt_sample_prev			loss_start
|  > +	spinlock_t			lock;
|  > +};
|  > +
|  > +/*
|  > + * Macros for loss detection.
|  > + * @loss_prev:  entry with highest-received-seqno before loss was detected
|  > + * @hist_index: index to reach n-th entry after loss_start
|  > + * @hist_entry: return the n-th history entry  after loss_start
|  > + * @last_rcv:   entry with highest-received-seqno so far
|  > + */
|  > +#define loss_prev(h)		(h)->ring[(h)->loss_start]
|  > +#define hist_index(h, n)	(((h)->loss_start + (n)) & NDUPACK)
|  > +#define hist_entry(h, n)	(h)->ring[hist_index(h, n)]
|  > +#define last_rcv(h)		(h)->ring[hist_index(h, (h)->loss_count)]
|  > +
|  > +/*
|  > + * Macros to access history entries for RTT sampling.
|  > + * @rtt_last_s: reference entry to compute RTT samples against
|  > + * @rtt_prev_s: previously suitable (wrt rtt_last_s) RTT-sampling entry
|  > + */
|  > +#define rtt_last_s(h)		(h)->ring[0]
|  > +#define rtt_prev_s(h)		(h)->ring[(h)->rtt_sample_prev]
|  > +
|  > +/* initialise loss detection and disable RTT sampling */
|  > +static inline void tfrc_rx_hist_loss_indicated(struct tfrc_rx_hist *h)
|  > +{
|  > +	h->loss_count = 1;
|  > +}
|  > +
|  > +/* indicate whether previously a packet was detected missing */
|  > +static inline int tfrc_rx_loss_pending(struct tfrc_rx_hist *h)
|  > +{
|  > +	return h->loss_count;
|  > +}
|  > +
|  > +/* any data packets missing between last reception and skb ? */
|  > +static inline int tfrc_rx_new_loss_indicated(struct tfrc_rx_hist *h,
|  > +					     struct sk_buff *skb, u32 ndp)
|  > +{
|  > +	int delta = dccp_delta_seqno(last_rcv(h)->dccphrx_seqno,
|  > +				     DCCP_SKB_CB(skb)->dccpd_seq);
|  > +
|  > +	if (delta > 1 && ndp < delta)
|  > +		tfrc_rx_hist_loss_indicated(h);
|  > +
|  > +	return tfrc_rx_loss_pending(h);
|  > +}
|  > +
|  > +/* has the packet contained in skb been seen before ? */
|  > +static inline int tfrc_rx_duplicate(struct tfrc_rx_hist *h, struct sk_buff *skb)
|  > +{
|  > +	const u64 seq = DCCP_SKB_CB(skb)->dccpd_seq;
|  > +	int i;
|  > +
|  > +	if (dccp_delta_seqno(loss_prev(h)->dccphrx_seqno, seq) <= 0)
|  > +		return 1;
|  > +
|  > +	for (i = 1; i <= h->loss_count; i++)
|  > +		if (dccp_delta_seqno(hist_entry(h, i)->dccphrx_seqno, seq) = 0)
|  > +			return 1;
|  > +
|  > +	return 0;
|  > +}
|  > +
|  > +/* return the signed modulo-2^48 sequence number distance from entry e1 to e2 */
|  > +static inline s64 tfrc_rx_hist_delta_seqno(struct tfrc_rx_hist *h, u8 e1, u8 e2)
|  > +{
|  > +	DCCP_BUG_ON(e1 > h->loss_count || e2 > h->loss_count);
|  > +
|  > +	return dccp_delta_seqno(hist_entry(h, e1)->dccphrx_seqno,
|  > +				hist_entry(h, e2)->dccphrx_seqno);
|  > +}
|  > +
|  > +static inline void tfrc_rx_hist_swap(struct dccp_rx_hist_entry **a,
|  > +				     struct dccp_rx_hist_entry **b)
|  > +{
|  > +	struct dccp_rx_hist_entry *tmp = *a;
|  > +
|  > +	*a = *b;
|  > +	*b = tmp;
|  > +}
|  > +
|  > +
|  > +/* Older history management functions */
|  >  static inline struct dccp_rx_hist_entry *
|  >  			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
|  >  					       const struct sock *sk,
|  > -
|  > To unsubscribe from this list: send the line "unsubscribe dccp" in
|  > the body of a message to majordomo@vger.kernel.org
|  > More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
