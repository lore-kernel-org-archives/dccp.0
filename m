From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Feb 2011 11:33:16 +0000
Subject: Re: [PATCH 1/4] dccp: Prevent Congestion Window > Sequence Window
Message-Id: <20110222113315.GB3962@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297647802.9816.144.camel@jero-laptop>
In-Reply-To: <1297647802.9816.144.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Also add code to adjust the sequence window to be about 5 times the
| number of packets in the network (RFC 4340 7.5.2) and to adjust the Ack
| Ratio so that the remote sequence window will hold about 5 times the
| number of packets in the network.

<...>
| +	if (r_seq_used*5 >= dp->dccps_r_seq_win)
| +		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio*2);
| +	else if (r_seq_used*5 < (dp->dccps_r_seq_win/2))
| +		ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio/2);
| +
| +	if (hc->tx_cwnd*5 >= dp->dccps_l_seq_win)
| +			ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win*2);
| +	else if (hc->tx_cwnd*5 < (dp->dccps_l_seq_win/2))
| +			ccid2_change_l_seq_window(sk, dp->dccps_l_seq_win/2);
| +

It would be good to make the `5' a #define constant and to integrate the 
commit message as comment above the code.

