From: David Miller <davem@davemloft.net>
Date: Thu, 03 Nov 2016 20:19:41 +0000
Subject: Re: [PATCH net] dccp: do not send reset to already closed sockets
Message-Id: <20161103.161941.367902189230382386.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1478135064.7065.409.camel@edumazet-glaptop3.roam.corp.google.com>
In-Reply-To: <1478135064.7065.409.camel@edumazet-glaptop3.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 02 Nov 2016 18:04:24 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Andrey reported following warning while fuzzing with syzkaller
> 
> WARNING: CPU: 1 PID: 21072 at net/dccp/proto.c:83 dccp_set_state+0x229/0x290
> Kernel panic - not syncing: panic_on_warn set ...
 ...
> Fix this the same way we did for TCP in commit 565b7b2d2e63
> ("tcp: do not send reset to already closed sockets")
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> Tested-by: Andrey Konovalov <andreyknvl@google.com>

Applied and queued up for -stable.
