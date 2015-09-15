From: David Miller <davem@davemloft.net>
Date: Tue, 15 Sep 2015 23:50:09 +0000
Subject: Re: [PATCH 34/39] dccp: drop null test before destroy functions
Message-Id: <20150915.165009.293831022941705256.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1442146532-9100-35-git-send-email-Julia.Lawall@lip6.fr>
In-Reply-To: <1442146532-9100-35-git-send-email-Julia.Lawall@lip6.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>
Date: Sun, 13 Sep 2015 14:15:27 +0200

> Remove unneeded NULL test.
> 
> The semantic patch that makes this change is as follows:
> (http://coccinelle.lip6.fr/)
> 
> // <smpl>
> @@
> expression x;
> @@
> 
> -if (x != NULL)
>   \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
> 
> @@
> expression x;
> @@
> 
> -if (x != NULL) {
>   \(kmem_cache_destroy\|mempool_destroy\|dma_pool_destroy\)(x);
>   x = NULL;
> -}
> // </smpl>
> 
> Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

Applied.
