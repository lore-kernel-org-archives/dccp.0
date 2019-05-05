From: David Miller <davem@davemloft.net>
Date: Sun, 05 May 2019 16:53:09 +0000
Subject: Re: [PATCH v3] net: dccp: Checksum verification enhancement
Message-Id: <20190505.095309.439816991626967361.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: <Markus.Amend@telekom.de>
Date: Tue, 30 Apr 2019 16:11:07 +0000

> The current patch modifies the checksum verification of a received DCCP
> packet, by adding the function __skb_checksum_validate into the
> dccp_vX_rcv routine. The purpose of the modification is to allow the
> verification of the skb->ip_summed flags during the checksum validation
> process (for checksum offload purposes). As __skb_checksum_validate
> covers the functionalities of skb_checksum and dccp_vX_csum_finish they
> are needless and therefore removed.
> 
> Signed-off-by: Nathalie Romo Moreno <natha.ro.moreno@gmail.com>
> Signed-off-by: Markus Amend <markus.amend@telekom.de>

I don't see how this can be correct as you're not taking the csum
coverage value into consideration at all.
