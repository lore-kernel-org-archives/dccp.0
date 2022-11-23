From: patchwork-bot+netdevbpf@kernel.org
Date: Wed, 23 Nov 2022 04:53:32 +0000
Subject: Re: [PATCH v4 net 0/4] dccp/tcp: Fix bhash2 issues related to WARN_ON() in inet_csk_get_port().
Message-Id: <166917961972.4515.12267352129449341755.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20221119014914.31792-1-kuniyu@amazon.com>
In-Reply-To: <20221119014914.31792-1-kuniyu@amazon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This series was applied to netdev/net.git (master)
by Jakub Kicinski <kuba@kernel.org>:

On Fri, 18 Nov 2022 17:49:10 -0800 you wrote:
> syzkaller was hitting a WARN_ON() in inet_csk_get_port() in the 4th patch,
> which was because we forgot to fix up bhash2 bucket when connect() for a
> socket bound to a wildcard address fails in __inet_stream_connect().
> 
> There was a similar report [0], but its repro does not fire the WARN_ON() due
> to inconsistent error handling.
> 
> [...]

Here is the summary with links:
  - [v4,net,1/4] dccp/tcp: Reset saddr on failure after inet6?_hash_connect().
    https://git.kernel.org/netdev/net/c/77934dc6db0d
  - [v4,net,2/4] dccp/tcp: Remove NULL check for prev_saddr in inet_bhash2_update_saddr().
    https://git.kernel.org/netdev/net/c/8acdad37cd13
  - [v4,net,3/4] dccp/tcp: Update saddr under bhash's lock.
    https://git.kernel.org/netdev/net/c/8c5dae4c1a49
  - [v4,net,4/4] dccp/tcp: Fixup bhash2 bucket when connect() fails.
    https://git.kernel.org/netdev/net/c/e0833d1fedb0

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

