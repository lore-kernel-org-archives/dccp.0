From: David Miller <davem@davemloft.net>
Date: Thu, 03 May 2018 19:15:25 +0000
Subject: Re: [PATCH net] dccp: fix tasklet usage
Message-Id: <20180503.151525.1755893274006498102.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20180503163920.102035-1-edumazet@google.com>
In-Reply-To: <20180503163920.102035-1-edumazet@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Eric Dumazet <edumazet@google.com>
Date: Thu,  3 May 2018 09:39:20 -0700

> syzbot reported a crash in tasklet_action_common() caused by dccp.
> 
> dccp needs to make sure socket wont disappear before tasklet handler
> has completed.
> 
> This patch takes a reference on the socket when arming the tasklet,
> and moves the sock_put() from dccp_write_xmit_timer() to dccp_write_xmitlet()
 ...
> Fixes: dc841e30eaea ("dccp: Extend CCID packet dequeueing interface")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: syzbot <syzkaller@googlegroups.com>

Applied and queued up for -stable, thanks Eric.
