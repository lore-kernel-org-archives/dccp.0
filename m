From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 05 Dec 2007 15:18:54 +0000
Subject: Re: [PATCH v2 0/3][BUG-FIX]: Test tree updates and bug fixes
Message-Id: <20071205151854.GL4653@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <11968535863312-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Dec 05, 2007 at 02:53:09PM +0000, Gerrit Renker escreveu:
> | Thanks, I folded this into the reorganized RX history handling patch,
> | together with reverting ccid3_hc_rx_packet_recv to very close to your
> | original patch, with this changes:
> | 
> | 1. no need to calculate the payload size for non data packets as this
> |    value won't be used.
> | 2. Initialize hcrx->ccid3hcrx_bytes_recv with the payload size when
> |    hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA.
> | 3. tfrc_rx_hist_duplicate() is only called when ccid3hcrx_state !> |    TFRC_RSTATE_NO_DATA, so it doesn't need to goto the done_receiving
> |    label (that was removed as this was its only use) as do_feedback
> |    would always be CCID3_FBACK_NONE and so the test would always fail
> |    and no feedback would be sent, so just return right there.
> | 
> | Now it reads:
> | 
> | static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
> | {
> | 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
> | 	enum ccid3_fback_type do_feedback = CCID3_FBACK_NONE;
> | 	const u32 ndp = dccp_sk(sk)->dccps_options_received.dccpor_ndp;
> | 	const bool is_data_packet = dccp_data_packet(skb);
> | 
> | 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
> | 		if (is_data_packet) {
> | 			const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
> | 			do_feedback = FBACK_INITIAL;
> | 			ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
> | 			hcrx->ccid3hcrx_s > | 				hcrx->ccid3hcrx_bytes_recv = payload_size;
> 
>   => Please see other email regarding bytes_recv, but I think you already got that.
>       Maybe one could then write
>       	hcrx->ccid3hcrx_s = skb->len - dccp_hdr(skb)->dccph_doff * 4;

OK, I got that.
  
> | 		}
> | 		goto update_records;
> |  	}
> | 
> | 	if (tfrc_rx_hist_duplicate(&hcrx->ccid3hcrx_hist, skb))
> | 		return; /* done receiving */
> | 
> | 	if (is_data_packet) {
> | 		const u32 payload = skb->len - dccp_hdr(skb)->dccph_doff * 4;
> | 		/*
> | 		 * Update moving-average of s and the sum of received payload bytes
> | 		 */
> | 		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, payload_size, 9);
> | 		hcrx->ccid3hcrx_bytes_recv += payload_size;
> |  	}
> | 
> | 	/*
> | 	 * Handle pending losses and otherwise check for new loss
> | 	 */
> | 	if (tfrc_rx_hist_new_loss_indicated(&hcrx->ccid3hcrx_hist, skb, ndp))
> | 		goto update_records;
> | 
> | 	/*
> | 	 * Handle data packets: RTT sampling and monitoring p
> | 	 */
> | 	if (unlikely(!is_data_packet))
> | 		goto update_records;
> | 
> | 	if (list_empty(&hcrx->ccid3hcrx_li_hist)) {  /* no loss so far: p = 0 */
> | 		const u32 sample = tfrc_rx_hist_sample_rtt(&hcrx->ccid3hcrx_hist, skb);
> => If you like, you could add the original comment here that p=0 if no	loss occured, i.e.
> 		/*
> 		 * Empty loss history: no loss so far, hence p stays 0.
> 		 * Sample RTT values, since an RTT estimate is required for the
> 		 * computation of p when the first loss occurs; RFC 3448, 6.3.1.
> 		 */

done

> | 		if (sample != 0)
> | 			hcrx->ccid3hcrx_rtt = tfrc_ewma(hcrx->ccid3hcrx_rtt, sample, 9);
> | 	}
> | 
> | 	/*
> | 	 * Check if the periodic once-per-RTT feedback is due; RFC 4342, 10.3
> | 	 */
> | 	if (SUB16(dccp_hdr(skb)->dccph_ccval, hcrx->ccid3hcrx_last_counter) > 3)
> | 		do_feedback = CCID3_FBACK_PERIODIC;
> | 
> | update_records:	
> | 	tfrc_rx_hist_add_packet(&hcrx->ccid3hcrx_hist, skb, ndp);
> | 
> =>  here a jump label is missing. It is not needed by this patch and
>      above you have replaced it with a return + comment, but it is needed in a later
>      patch: when a new loss event occurs, the control jumps to `done_receiving' and
>      sends a feedback packet with type FBACK_PARAM_CHANGE.

OK, I was wondering that the user for FBACK_PARAM_CHANGE in
ccid3_hc_rx_send_feedback was in another patch.

> done_receiving:

Ok, we can add the jump label when we make use of it

> | 	if (do_feedback)
> | 		ccid3_hc_rx_send_feedback(sk, skb, do_feedback);
> | }
> | 
> 
> | Now to some questions and please bear with me as I haven't got to the
> | patches after this:
> | 
> | tfrc_rx_hist->loss_count as of now is a boolean, my understanding is
> | that you are counting loss events, i.e. it doesn't matter in:
> |
> It is not a boolean, but uses a hidden trick which maybe should be commented:
>  * here and in the TCP world NDUPACK = 3
>  * hence the bitfield size for loss_count is 2 bits, which can express
>    at most 3 = NDUPACK (that is why it is declared as loss_count:2)
>  * the trick is that when the loss count increases beyond 3, it automatically 
>    cycles back to 0 (although the code does not rely on that features
>    and does this explicitly);
>  * loss_start is the same

OK, will read the next patches with this in mind, thanks for the
explanations.

- Arnaldo
