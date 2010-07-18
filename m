From: David Miller <davem@davemloft.net>
Date: Sun, 18 Jul 2010 22:07:34 +0000
Subject: Re: [PATCH 5/5] net: dccp: fix sign bug
Message-Id: <20100718.150734.22057785.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1279380060-15394-1-git-send-email-segooon@gmail.com>
In-Reply-To: <1279380060-15394-1-git-send-email-segooon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Kulikov Vasiliy <segooon@gmail.com>
Date: Sat, 17 Jul 2010 19:21:00 +0400

> 'gap' is unsigned, so this code is wrong:
> 
>     gap = -new_head;
>     ...
>     if (gap > 0) { ... }
> 
> Make 'gap' signed.
> 
> 
> The semantic patch that finds this problem (many false-positive results):
> (http://coccinelle.lip6.fr/)
...
> Signed-off-by: Kulikov Vasiliy <segooon@gmail.com>

Applied, thanks.
