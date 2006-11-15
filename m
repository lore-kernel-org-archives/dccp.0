From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 15 Nov 2006 14:47:51 +0000
Subject: CCID3: dead code in  ccid3_hc_rx_packet_recv?
Message-Id: <200611151447.51245@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

While working on the promised EWMA patch for CCID 3 packet sizes, I stumbled over two things
and can make no sense of a bit of CCID 3 Receive code:

	1) ccid3_hc_rx_sock maintains a real-timer RTT counter ccid3hcrx_rtt
           which is an alias for a TFRC structure defined in <linux/tfrc.h>
	2) ccid3_hc_rx_packet_recv (detailed below) updates this, but leaves the variable
           `win_count = packet->dccphrx_ccval;'  entirely untouched after initialisation

It may be that ... ?
	* this is because a real-time counter as opposed to the 4-digit window value
          counter affords better reliability (but then win_count should be removed)
	* this stems from the original TFRC code and might need update
        

I'd be glad for clarification about this code:


static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
{
	/* ... */
	switch (DCCP_SKB_CB(skb)->dccpd_type) {
	case DCCP_PKT_ACK:
		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
			return;
	case DCCP_PKT_DATAACK:
		/* ... */
		rtt_prev = hcrx->ccid3hcrx_rtt;
		/* ... */
		r_sample = timeval_usecs(&now);
		t_elapsed = opt_recv->dccpor_elapsed_time * 10;

		/* 
                   after updating r_sample with regard to t_elapsed ... 
                   => The code that now follows is identical with ccid3_hc_tx_packet_recv
		       --is this a leftover ?
		       --should it not rather update the sending structure (ccid3hctx_rtt)
		   => why not use win_count ??
                 */

		if (hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)
			hcrx->ccid3hcrx_rtt = r_sample;
		else
			hcrx->ccid3hcrx_rtt = (hcrx->ccid3hcrx_rtt * 9) / 10 +
					      r_sample / 10;
		/* ... */
		break;
	case DCCP_PKT_DATA:
		break;
	default: /* We're not interested in other packet types, move along */
		return;
	}
	/* ... */

	win_count = packet->dccphrx_ccval; /* XXX this is the only place `win_count' appears */

	/* ... */
}	
