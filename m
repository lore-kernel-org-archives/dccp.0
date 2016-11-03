From: David Miller <davem@davemloft.net>
Date: Thu, 03 Nov 2016 20:19:27 +0000
Subject: Re: [PATCH net] dccp: do not release listeners too soon
Message-Id: <20161103.161927.2250111271074026849.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1478132081.7065.403.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1478132081.7065.403.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 17:14:41 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey Konovalov reported following error while fuzzing with syzkaller :
 ...
> It turns out DCCP calls __sk_receive_skb(), and this broke when
> lookups no longer took a reference on listeners.
> 
> Fix this issue by adding a @refcounted parameter to __sk_receive_skb(),
> so that sock_put() is used only when needed.
> 
> Fixes: 3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable.
