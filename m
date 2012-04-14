From: David Miller <davem@davemloft.net>
Date: Sat, 14 Apr 2012 19:29:26 +0000
Subject: Re: [PATCH net-next] inet: makes syn_ack_timeout mandatory
Message-Id: <20120414.152926.446676650978105923.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1334304965.5300.8713.camel@edumazet-glaptop>
In-Reply-To: <1334304965.5300.8713.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 13 Apr 2012 10:16:05 +0200

> From: : Eric Dumazet <edumazet@google.com>
> 
> There are two struct request_sock_ops providers, tcp and dccp.
> 
> inet_csk_reqsk_queue_prune() can avoid testing syn_ack_timeout being
> NULL if we make it non NULL like syn_ack_timeout
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
