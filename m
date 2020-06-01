From: David Miller <davem@davemloft.net>
Date: Mon, 01 Jun 2020 18:54:25 +0000
Subject: Re: [PATCH v2] net: dccp: Add SIOCOUTQ IOCTL support (send buffer fill)
Message-Id: <20200601.115425.2049687853139691101.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Richard Sailer <richard_siegfried@systemli.org>
Date: Sat, 30 May 2020 18:31:59 +0200

> @@ -375,6 +375,14 @@ int dccp_ioctl(struct sock *sk, int cmd, unsigned long arg)
>  		goto out;
>  
>  	switch (cmd) {
> +	case SIOCOUTQ: {
> +		/* Using sk_wmem_alloc here because sk_wmem_queued is not used by DCCP and
> +		 * always 0, comparably to UDP.
> +		 */
> +		int amount = sk_wmem_alloc_get(sk);
> +		rc = put_user(amount, (int __user *)arg);
> +	}
> +		       break;

Please fix this indentation.
