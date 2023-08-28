From: patchwork-bot+netdevbpf@kernel.org
Date: Mon, 28 Aug 2023 09:20:24 +0000
Subject: Re: [PATCH net] dccp: Fix out of bounds access in DCCP error handler
Message-Id: <169321442419.7279.7733954383397054161.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230825133241.3635236-1-jannh@google.com>
In-Reply-To: <20230825133241.3635236-1-jannh@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net.git (main)
by David S. Miller <davem@davemloft.net>:

On Fri, 25 Aug 2023 15:32:41 +0200 you wrote:
> There was a previous attempt to fix an out-of-bounds access in the DCCP
> error handlers, but that fix assumed that the error handlers only want
> to access the first 8 bytes of the DCCP header. Actually, they also look
> at the DCCP sequence number, which is stored beyond 8 bytes, so an
> explicit pskb_may_pull() is required.
> 
> Fixes: 6706a97fec96 ("dccp: fix out of bound access in dccp_v4_err()")
> Fixes: 1aa9d1a0e7ee ("ipv6: dccp: fix out of bound access in dccp_v6_err()")
> Cc: stable@vger.kernel.org
> Signed-off-by: Jann Horn <jannh@google.com>
> 
> [...]

Here is the summary with links:
  - [net] dccp: Fix out of bounds access in DCCP error handler
    https://git.kernel.org/netdev/net/c/977ad86c2a1b

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

