From: David Miller <davem@davemloft.net>
Date: Wed, 30 Nov 2016 01:38:01 +0000
Subject: Re: [PATCH net] net/dccp: fix use-after-free in dccp_invalid_packet
Message-Id: <20161129.203801.926114791600466509.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1480343209.18162.50.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2016 06:26:49 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> pskb_may_pull() can reallocate skb->head, we need to reload dh pointer
> in dccp_invalid_packet() or risk use after free.
> 
> Bug found by Andrey Konovalov using syzkaller.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
