From: Kuniyuki Iwashima <kuniyu@amazon.co.jp>
Date: Thu, 19 May 2022 07:51:19 +0000
Subject: Re: [PATCH net-next v5 1/2] net: Add a second bind table hashed by port and address
Message-Id: <20220519075119.87442-1-kuniyu@amazon.co.jp>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Joanne Koong <joannelkoong@gmail.com>
Date: Wed, 18 May 2022 16:19:11 -0700
> We currently have one tcp bind table (bhash) which hashes by port
> number only. In the socket bind path, we check for bind conflicts by
> traversing the specified port's inet_bind2_bucket while holding the
> bucket's spinlock (see inet_csk_get_port() and inet_csk_bind_conflict()).
> 
> In instances where there are tons of sockets hashed to the same port
> at different addresses, checking for a bind conflict is time-intensive
> and can cause softirq cpu lockups, as well as stops new tcp connections
> since __inet_inherit_port() also contests for the spinlock.
> 
> This patch proposes adding a second bind table, bhash2, that hashes by
> port and ip address. Searching the bhash2 table leads to significantly
> faster conflict resolution and less time holding the spinlock.
> 
> Signed-off-by: Joanne Koong <joannelkoong@gmail.com>
> Reviewed-by: Eric Dumazet <edumazet@google.com>

Acked-by: Kuniyuki Iwashima <kuniyu@amazon.co.jp>

To maintainers:
lore and patchwork seem to miss this version...?

Thank you.
