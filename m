From: David Miller <davem@davemloft.net>
Date: Thu, 03 Nov 2016 20:20:32 +0000
Subject: Re: [PATCH net] ipv6: dccp: fix out of bound access in dccp_v6_err()
Message-Id: <20161103.162032.1632688241226729817.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1478143848.7065.429.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1478143848.7065.429.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 20:30:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> dccp_v6_err() does not use pskb_may_pull() and might access garbage.
> 
> We only need 4 bytes at the beginning of the DCCP header, like TCP,
> so the 8 bytes pulled in icmpv6_notify() are more than enough.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied and queue up for -stable.

Thanks Eric.
