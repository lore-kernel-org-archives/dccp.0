From: "#ZHOU BIN#" <ZHOU0022@ntu.edu.sg>
Date: Tue, 29 Nov 2005 07:21:18 +0000
Subject: A doubt on the behavior of a TFRC receiver in the code
Message-Id: <A975FFC51622704CBEAB749E263D179901554035@mail01.student.main.ntu.edu.sg>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi all,

I met some problems when studying the following section of source code, which is about the behavior of a TFRC receiver:

static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
{	
	.
993	ins = dccp_rx_hist_add_packet(ccid3_rx_hist, &hcrx->ccid3hcrx_hist,
				      &hcrx->ccid3hcrx_li_hist, packet);
	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
		return;
999	switch (hcrx->ccid3hcrx_state) {
	case TFRC_RSTATE_NO_DATA:
		.
		return;
1008	case TFRC_RSTATE_DATA:
		hcrx->ccid3hcrx_bytes_recv += skb->len -
					      dccp_hdr(skb)->dccph_doff * 4;
1011		if (ins != 0)
1012			break;
		dccp_timestamp(sk, &now);
		if (timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) >		    hcrx->ccid3hcrx_rtt) {
			hcrx->ccid3hcrx_tstamp_last_ack = now;
			ccid3_hc_rx_send_feedback(sk);
		}
		return;
	default:
		.
		return;
	}
	/* Dealing with packet loss */
	.
1032	ccid3_hc_rx_detect_loss(sk);
	p_prev = hcrx->ccid3hcrx_p;
	/* Calculate loss event rate */
	if (!list_empty(&hcrx->ccid3hcrx_li_hist))
		/* Scaling up by 1000000 as fixed decimal */
		hcrx->ccid3hcrx_p = 1000000 / dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
	if (hcrx->ccid3hcrx_p > p_prev) {
		ccid3_hc_rx_send_feedback(sk);
		return;
	}
}

According to RFC 3448 section 6.1,

"When a data packet is received, the receiver performs the following steps:
   1) Add the packet to the packet history.
   2) Let the previous value of p be p_prev.  Calculate the new value of p as described in Section 5.
   3) If p > p_prev, cause the feedback timer to expire, and perform the actions described in Section 6.2
      If p <= p_prev no action need be performed."

To my way of thinking, the step 1 is done in line 993. However, the step 2 and 3 have no chance to be done in most cases: in the switch process starting from line 999, the only possibility to jump out to the "p" calculation (line 1032) is the variable "ins" is not be 0 (line 1011 and 1012). But ins=1 only happens when unordered packet is received. This is quite different from what RFC says. 

What's wrong in my analysis?

Thank you.

Regards,
Zhou Bin
