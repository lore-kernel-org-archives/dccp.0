From: David Miller <davem@davemloft.net>
Date: Thu, 31 Aug 2017 05:16:49 +0000
Subject: Re: [PATCH] net: dccp: Add handling of IPV6_PKTOPTIONS to dccp_v6_do_rcv()
Message-Id: <20170830.221649.818214075248119092.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20170830090435.58406d1b@dev>
In-Reply-To: <20170830090435.58406d1b@dev>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Andrii Vladyka <tulup@mail.ru>
Date: Wed, 30 Aug 2017 09:04:35 +0300

> +	if (opt_skb) 
                    ^^^^

Trailing whitespace.

> @@ -653,6 +647,36 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
>  		__kfree_skb(opt_skb);
>  	kfree_skb(skb);
>  	return 0;
> +	
   ^^^^^^^

Likewise.
