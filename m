From: David Miller <davem@davemloft.net>
Date: Mon, 25 Mar 2019 00:13:57 +0000
Subject: Re: [PATCH] net: dccp: Checksum verification considering skb->ip_summed
Message-Id: <20190324.201357.1580092867848179795.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <FRAPR01MB11701F9A1C7014276A68F22AFA7C0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
In-Reply-To: <FRAPR01MB11701F9A1C7014276A68F22AFA7C0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: <Markus.Amend@telekom.de>
Date: Fri, 22 Mar 2019 14:34:58 +0000

> @@ -786,7 +787,8 @@ static int dccp_v4_rcv(struct sk_buff *skb)
>  
>  	iph = ip_hdr(skb);
>  	/* Step 1: If header checksum is incorrect, drop packet and return */
> -	if (dccp_v4_csum_finish(skb, iph->saddr, iph->daddr)) {
> +	if (__skb_checksum_validate(skb, IPPROTO_DCCP,
> +		  true, false, 0, inet_compute_pseudo)) {

The arguments on the second and subsequent lines of a function call must
begin precisely at the first column after the openning parenthesis of
the first line of the function call.

You must use the appropriate number of TAB, then SPACE, characters
necessary to achieve this.
