From: David Miller <davem@davemloft.net>
Date: Thu, 03 Nov 2016 20:51:07 +0000
Subject: Re: [PATCH net] ipv6: dccp: add missing bind_conflict to dccp_ipv6_mapped
Message-Id: <20161103.165107.2230811543246914716.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1478188786.7065.453.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 03 Nov 2016 08:59:46 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> While fuzzing kernel with syzkaller, Andrey reported a nasty crash
> in inet6_bind() caused by DCCP lacking a required method.
> 
> Fixes: ab1e0a13d7029 ("[SOCK] proto: Add hashinfo member to struct proto")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable, thanks Eric.
