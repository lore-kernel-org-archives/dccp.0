From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 20 Nov 2006 15:46:03 +0000
Subject: Re: [PATCH 3/3] DCCP: Remove unneeded variable
Message-Id: <200611201546.03998@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611191552.40380.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200611191552.40380.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I am not very happy with this - I think the receiver half-connection RTT code should be revised. 
At the present I fail to see why, in ccid3_hc_rx_packet_recv,

	* RTT is only updated on Acks/DataAcks 
	* i.e. either AckVectors need to be in place or sender must at the same time
          be receiver (otherwise it will only get Data packets, never Ack/DataAck)
	* ... comments as per discussion before
	* this is likely a new ToDo, but I would not call it fixed
	* think I found the code Ian was talking about: it is in ccid3_hc_rx_update_li,
                                                        which has a FIXME

Anyway, I have uploaded it to the webpage just the same.

Quoting Ian McDonald:
|  diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
|  index 2fa0c6d..55b972b 100644
|  --- a/net/dccp/ccids/ccid3.c
|  +++ b/net/dccp/ccids/ccid3.c
|  @@ -982,7 +982,6 @@ static void ccid3_hc_rx_packet_recv(stru
|   	const struct dccp_options_received *opt_recv;
|   	struct dccp_rx_hist_entry *packet;
|   	struct timeval now;
|  -	u8 win_count;
|   	u32 p_prev, rtt_prev, r_sample, t_elapsed;
|   	int loss;
|   
|  @@ -1038,8 +1037,6 @@ static void ccid3_hc_rx_packet_recv(stru
|   		return;
|   	}
|   
|  -	win_count = packet->dccphrx_ccval;
|  -
|   	loss = ccid3_hc_rx_detect_loss(sk, packet);
|   
|   	if (DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK)
|  -
|  To unsubscribe from this list: send the line "unsubscribe dccp" in
|  the body of a message to majordomo@vger.kernel.org
|  More majordomo info at  http://vger.kernel.org/majordomo-info.html
|  
|  
