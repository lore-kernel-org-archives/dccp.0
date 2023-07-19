From: patchwork-bot+netdevbpf@kernel.org
Date: Wed, 19 Jul 2023 11:40:20 +0000
Subject: Re: [PATCH net-next 0/3] net: Remove more RTO_ONLINK users.
Message-Id: <168976682016.23748.15879521041642434800.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <cover.1689600901.git.gnault@redhat.com>
In-Reply-To: <cover.1689600901.git.gnault@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This series was applied to netdev/net-next.git (main)
by David S. Miller <davem@davemloft.net>:

On Mon, 17 Jul 2023 15:53:24 +0200 you wrote:
> Code that initialise a flowi4 structure manually before doing a fib
> lookup can easily avoid overloading ->flowi4_tos with the RTO_ONLINK
> bit. They can just set ->flowi4_scope correctly instead.
> 
> Properly separating the routing scope from ->flowi4_tos will allow to
> eventually convert this field to dscp_t (to ensure proper separation
> between DSCP and ECN).
> 
> [...]

Here is the summary with links:
  - [net-next,1/3] gtp: Set TOS and routing scope independently for fib lookups.
    https://git.kernel.org/netdev/net-next/c/b16b50476714
  - [net-next,2/3] dccp: Set TOS and routing scope independently for fib lookups.
    https://git.kernel.org/netdev/net-next/c/2d6c85ca3eb8
  - [net-next,3/3] sctp: Set TOS and routing scope independently for fib lookups.
    https://git.kernel.org/netdev/net-next/c/ba80e20d7f3f

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

