From: David Miller <davem@davemloft.net>
Date: Fri, 29 Mar 2019 17:56:52 +0000
Subject: Re: [PATCH v2] net: dccp: Checksum verification enhancement
Message-Id: <20190329.105652.1950793642095951687.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <FRAPR01MB117083E6F526BDCB88742713FA5F0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
In-Reply-To: <FRAPR01MB117083E6F526BDCB88742713FA5F0@FRAPR01MB1170.DEUPRD01.PROD.OUTLOOK.DE>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: <Markus.Amend@telekom.de>
Date: Tue, 26 Mar 2019 08:54:41 +0000

> Modify checksum verification to allow the validation of skb->ip_summed, in case the checksum has already been verified in lower layers.

Please format your commit message to ~80 column lines.

> @@ -763,8 +763,9 @@ int dccp_invalid_packet(struct sk_buff *skb)
>  	}
>  
>  	/* If header checksum is incorrect, drop packet and return.
> -	 * (This step is completed in the AF-dependent functions.) */
> -	skb->csum = skb_checksum(skb, 0, cscov, 0);
> +	 * (This step is completed in the AF-dependent functions.)
> +	 * skb->csum = skb_checksum(skb, 0, cscov, 0);
> +	 */

Please do not just comment out code, explain what is operation can be expected
to be done already here and why.
