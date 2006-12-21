From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Dec 2006 20:38:57 +0000
Subject: Re: [PATCH 4/5]: DCCP Fix t_nom
Message-Id: <200612212038.57820@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200612201548.12544.ian.mcdonald@jandi.co.nz>
In-Reply-To: <200612201548.12544.ian.mcdonald@jandi.co.nz>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Ian, 

I have found the bug and I am certain that the fix (sent in a minute)
resolves it entirely - making PATCH 4/5 unnecessary.

I am actually on Xmas leave and it takes me about an hour to get to work
and back, but since I caused this bug, I think it is worthwhile.

		Detailed BUG Analysis
		---------------------

1) When is which function called:
	* update_send_time is called by 
		--update_x
		--in nofeedback_timer, state NO_FBACK
		--in tx_packet_recv, also state NO_FBACK
	* update_x is called by
		--nofeedback_timer, state FBACK
		--tx_packet_recv, state FBACK

2) When is t_nom < t_now a problem

 The scheduled send time t_nom is only of relevance in 
 ccid3_hc_tx_send_packet, where it is tested against t_now. In between
 calls to ccid3_hc_tx_send_packet, it does not matter whether t_nom < t_now.
 The real bug - and I thank you for pointing this out - is that when 
 		delay = t_nom - tnow 
 is less than 0. In this case the packet is late, and t_nom is out of sync.
 This is fixed by the patch and below I argue that no other changes are 
 required. 
 
3) Why I am certain that the patch fixes the bug entirely
 
 I applied this patch and used your patch which complains when t_nom < t_now
 in update_send_time. I only got this condition in tx_packet_recv. Here, however,
 we are between calls to send_packet, and it is not necessary to set t_nom=t_now,
 since this will be done at the exact instant of sending the packet. 
 The same applies to calls to the nofeedback timer. 
 
4) Further changes and comments by Eddie/Mark/Colin/Gorry

 People have argued that evaluating the send time should not be necessary
 in nofeedback_timer(). I think this is sound and eventually it would be 
 good to converge the send_packet interface towards this suggestion. 
 Since there are many other issues with CCID 3 at the moment, I would like
 to postpone this until we have at least full 3448/4342 conformance; as an 
 icing on the CCake :-)
 The idea is using `jiffies' instead of the expensive dccp_timestamp 
 (Andrea pointed out making this cheaper using clock=tsc, which also increases
 accuracy). We could store the send time delta in the skb and just decrement
 it -- until it is actually sent, the skb is blank and we could exploit
 that to decrement a jiffie value. 

Once again, many thanks for being so alert.
Gerrit
