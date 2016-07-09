From: David Miller <davem@davemloft.net>
Date: Sat, 09 Jul 2016 22:15:07 +0000
Subject: Re: [PATCH net] dccp: avoid deadlock in dccp_v4_ctl_send_reset
Message-Id: <20160709.181507.1107002266440808218.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1467968637.17638.44.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1467968637.17638.44.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 08 Jul 2016 11:03:57 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> In the prep work I did before enabling BH while handling socket backlog,
> I missed two points in DCCP :
> 
> 1) dccp_v4_ctl_send_reset() uses bh_lock_sock(), assuming BH were
> blocked. It is not anymore always true.
> 
> 2) dccp_v4_route_skb() was using __IP_INC_STATS() instead of
>   IP_INC_STATS()
> 
> A similar fix was done for TCP, in commit 47dcc20a39d0
> ("ipv4: tcp: ip_send_unicast_reply() is not BH safe")
> 
> Fixes: 7309f8821fd6 ("dccp: do not assume DCCP code is non preemptible")
> Fixes: 5413d1babe8f ("net: do not block BH while processing socket backlog")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>

Applied and queued up for -stable, thanks.
