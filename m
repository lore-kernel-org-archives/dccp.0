From: David Miller <davem@davemloft.net>
Date: Fri, 25 Jul 2008 09:51:45 +0000
Subject: Re: [PATCH 5/6] dccp: Fix incorrect length check for ICMPv4 packets
Message-Id: <20080725.025145.51942248.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1216976578-17767-6-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 10:02:57 +0100

> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -207,7 +207,7 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
>  	int err;
>  	struct net *net = dev_net(skb->dev);
>  
> -	if (skb->len < (iph->ihl << 2) + 8) {
> +	if (skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh)) {
>  		ICMP_INC_STATS_BH(net, ICMP_MIB_INERRORS);
>  		return;
>  	}

You can't dereference "dh" before you know there is even
space past offset "iph->ihl << 2".  Yet that is what doing
an unconditional __dccp_basic_hdr_len() call here is going
to do.

The ipv6 patch has the same bug.

The test probably needs to be something like:

	if (skb->len < (iph->ihl << 2) + sizeof(*dh) ||
	    skb->len < (iph->ihl << 2) + __dccp_basic_hdr_len(dh))

in order to make the tests safely.
