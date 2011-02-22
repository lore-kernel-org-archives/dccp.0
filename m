From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 22 Feb 2011 11:34:25 +0000
Subject: Re: [PATCH 4/4] dccp: Enable the Ack Ratio Feature but keep CCID2
Message-Id: <20110222113425.GE3962@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1297648018.9816.147.camel@jero-laptop>
In-Reply-To: <1297648018.9816.147.camel@jero-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| --- a/net/dccp/feat.c
| +++ b/net/dccp/feat.c
| @@ -86,18 +86,6 @@ static int dccp_hdlr_ecn(struct sock *sk, u64 ecn_incapable, bool rx)
|  
|  static int dccp_hdlr_ack_ratio(struct sock *sk, u64 ratio, bool rx)
|  {
| -#ifndef __CCID2_COPES_GRACEFULLY_WITH_DYNAMIC_ACK_RATIO_UPDATES__
| -	/*
| -	 * FIXME: This is required until several problems in the CCID-2 code are
| -	 * resolved. The CCID-2 code currently does not cope well; using dynamic
| -	 * Ack Ratios greater than 1 caused instabilities. These were manifest
| -	 * in hangups and long RTO timeouts (1...3 seconds). Until this has been
| -	 * stabilised, it is safer not to activate dynamic Ack Ratio changes.
| -	 */
| -	dccp_pr_debug("Not changing %s Ack Ratio from 1 to %u\n",
| -		      rx ? "RX" : "TX", (u16)ratio);
| -	ratio = 1;
| -#endif
|  	if (rx)
|  		dccp_sk(sk)->dccps_r_ack_ratio = ratio;
|  	else
| 
This also affects the remote ack ratio in ccid2_hc_rx_packet_recv() -- did you observe any 
interactions with that? I am ok with the patch otherwise, since it is a work in progress,
where both (work and progress) have been missing for quite some time.

