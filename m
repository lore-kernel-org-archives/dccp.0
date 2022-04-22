From: patchwork-bot+netdevbpf@kernel.org
Date: Fri, 22 Apr 2022 12:50:12 +0000
Subject: Re: [PATCH net-next 0/3] ipv4: First steps toward removing RTO_ONLINK
Message-Id: <165063181235.24908.15151109016653470553.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <cover.1650470610.git.gnault@redhat.com>
In-Reply-To: <cover.1650470610.git.gnault@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This series was applied to netdev/net-next.git (master)
by David S. Miller <davem@davemloft.net>:

On Thu, 21 Apr 2022 01:21:19 +0200 you wrote:
> RTO_ONLINK is a flag that allows to reduce the scope of route lookups.
> It's stored in a normally unused bit of the ->flowi4_tos field, in
> struct flowi4. However it has several problems:
> 
>  * This bit is also used by ECN. Although ECN bits are supposed to be
>    cleared before doing a route lookup, it happened that some code
>    paths didn't properly sanitise their ->flowi4_tos. So this mechanism
>    is fragile and we had bugs in the past where ECN bits slipped in and
>    could end up being erroneously interpreted as RTO_ONLINK.
> 
> [...]

Here is the summary with links:
  - [net-next,1/3] ipv4: Don't reset ->flowi4_scope in ip_rt_fix_tos().
    https://git.kernel.org/netdev/net-next/c/16a28267774c
  - [net-next,2/3] ipv4: Avoid using RTO_ONLINK with ip_route_connect().
    https://git.kernel.org/netdev/net-next/c/67e1e2f4854b
  - [net-next,3/3] ipv4: Initialise ->flowi4_scope properly in ICMP handlers.
    https://git.kernel.org/netdev/net-next/c/b1ad41384866

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

