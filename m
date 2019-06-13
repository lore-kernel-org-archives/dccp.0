From: <Markus.Amend@telekom.de>
Date: Thu, 13 Jun 2019 06:51:34 +0000
Subject: RE: [PATCH v3] net: dccp: Checksum verification enhancement
Message-Id: <FRAPR01MB117066D965524B71A7E18FA0FAEF0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi David,

Yes, you are right, I overlooked this. Unfortunately the current receive process in the DCCP layer does from my view not properly support the skb->ip_summed flag verification, because the checksum validation takes place at different places. This would require some dirty hacks...

I see two options.

1. Adding the ip_summed flag verification 


or 2. Learn from the UDP stack

Since UDP/UDP-Lite are very similar to DCCP, at least from a checksum verification point, I ask myself if it would make sense to re-work DCCP's receive process according to the one of UDP/UDP-Lite? 
The relevant process in the udp stack (for IPv4) I identified therefore, can be found in /net/ipv4/udp.c, within the function __udp4_lib_rcv. There it is done, compared to DCCP, the other way round it starts with an udp4_csum_init and most likely a later udp_lib_checksum_complete. Both consider skb->ip_summed. If we would implement similar functions into the DCCP stack and adapt the DCCP rcv checksum validation process to the one in UDP could make probably more sense?!


Personally I prefer the second option, what do you think?

BR

Markus


> -----Original Message-----
> From: David Miller <davem@davemloft.net>
> Sent: Sonntag, 5. Mai 2019 18:53
> To: Amend, Markus <Markus.Amend@telekom.de>
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org;
> dccp@vger.kernel.org
> Subject: Re: [PATCH v3] net: dccp: Checksum verification enhancement
> 
> From: <Markus.Amend@telekom.de>
> Date: Tue, 30 Apr 2019 16:11:07 +0000
> 
> > The current patch modifies the checksum verification of a received
> > DCCP packet, by adding the function __skb_checksum_validate into the
> > dccp_vX_rcv routine. The purpose of the modification is to allow the
> > verification of the skb->ip_summed flags during the checksum
> > validation process (for checksum offload purposes). As
> > __skb_checksum_validate covers the functionalities of skb_checksum and
> > dccp_vX_csum_finish they are needless and therefore removed.
> >
> > Signed-off-by: Nathalie Romo Moreno <natha.ro.moreno@gmail.com>
> > Signed-off-by: Markus Amend <markus.amend@telekom.de>
> 
> I don't see how this can be correct as you're not taking the csum coverage
> value into consideration at all.
