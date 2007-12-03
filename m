From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Dec 2007 08:35:12 +0000
Subject: Re: [RFC][PATCHES 0/7]: Reorganization of RX history patches
Message-Id: <20071203083512.GA5484@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1196631416-17778-1-git-send-email-acme@redhat.com>
In-Reply-To: <1196631416-17778-1-git-send-email-acme@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Arnaldo,

hank you for going through this. I have just backported your recent patches of 2.6.25
to the DCCP/CCID4/Faster Restart test tree at 
	git://eden-feed.erg.abdn.ac.uk/dccp_exp {dccp,ccid4,dccp_fr}
as per subsequent message.
| 	 do, so please consider moving DCCP discussion to netdev@vger.kernel.org,
| 	 where lots of smart networking folks are present and can help our efforts
| 	 on turning RFCs to code.
Are you suggesting using netdev exclusively or in addition to dccp@vger.kernel.org?
  

| 	Please take a look at this patch series where I reorganized your work on the new
| TFRC rx history handling code. I'll wait for your considerations and then do as many
| interactions as reasonable to get your work merged.
| 
| 	It should be completely equivalent, plus some fixes and optimizations, such as:
It will be necessary to address these points one-by-one. Before diving into making
fixes and `optimisations', have you tested your code? The patches you are referring to
have been posted and re-posted for a period of over 9 months on dccp@vger, and
there are regression tests which show that this code improves on the existing Linux
implementation. These are labelled as `test tree' on 
	http://www.linux-foundation.org/en/Net:DCCP_Testing#Regression_testing
So if you are making changes to the code, I would like to ask if you have run similar
regression tests, to avoid having to step back later.


 
| . The code that allocates the RX ring deals with failures when one of the entries in
|   the ring buffer is not successfully allocated, the original code was leaking the
|   successfully allocated entries.
| 
| . We do just one allocation for the ring buffer, as the number of entries is fixed we
|   should just do one allocation and not TFRC_NDUPACK times.
Will look at the first point in the patch; with regard to the second point I agree, this
will make the code simpler, which is good. 

| . I haven't checked if all the code was commited, as I tried to introduce just what was
|   immediatelly used, probably we'll need to do some changes when working on the merge
|   of your loss intervals code.
Sorry I don't understand this point.

| . I changed the ccid3_hc_rx_packet_recv code to set hcrx->ccid3hcrx_s for the first
|   non-data packet instead of calling ccid3_hc_rx_set_state, that would use 0 as the
|   initial value in the EWMA calculation.
This is a misunderstanding. Non-data packets are not considered in the moving average
for the data packet size `s'; and it would be an error to do (consider 40byte Acks vs.
1460byte data packets, also it is in RFC 4342). 
Where would the zero initial value come from? I think this is also a misunderstanding.
Please have a look below:
	static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
	{
		// ...
		u32 sample, payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;

		if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
			if (is_data_packet) {
				do_feedback = FBACK_INITIAL;
				ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
				ccid3_hc_rx_update_s(hcrx, payload_size);
			}
			goto update_records;
		}

=> Non-data packets are ignored for the purposes of computing s (this is in the RFC),
    consequently update_s() is only called for data packets; using the two following
    functions:


	static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
	{
		return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
	}

	static inline void ccid3_hc_rx_update_s(struct ccid3_hc_rx_sock *hcrx, int len)
	{
		if (likely(len > 0))	/* don't update on empty packets (e.g. ACKs) */
			hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
	}

=> Hence I can't see where a zero value should come from: ccid3hrx_s is initially 
    initialised with zero (memset(...,0,...)); when first called, update_s() will
    feed a non-zero payload size to tfrc_ewma(), which will return  `newval' = payload_size,
    hence the first data packet will contribute a non-zero payload_size.
    Zero-sized DCCP-Data packets are pathological and are ignored by the CCID calculations
    (not by the receiver); a corresponding counterpart for zero-sized

| 
| 	It is available at:
| 
| master.kernel.org:/pub/scm/linux/kernel/git/acme/net-2.6.25
| 
Need to do this separately. As said, the code has been developed and tested over a long time,
it took a long while until it acted predictably, so being careful is very important.

I would rather not have my patches merged and continue to run a test tree if the current
changes alter the behaviour to the worse.
