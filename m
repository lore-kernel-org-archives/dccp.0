From: patchwork-bot+netdevbpf@kernel.org
Date: Fri, 19 Nov 2021 11:50:15 +0000
Subject: Re: [PATCH] net: dccp: Use memset_startat() for TP zeroing
Message-Id: <163732261562.10547.7623991356352277593.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20211118203019.1286474-1-keescook@chromium.org>
In-Reply-To: <20211118203019.1286474-1-keescook@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net-next.git (master)
by David S. Miller <davem@davemloft.net>:

On Thu, 18 Nov 2021 12:30:19 -0800 you wrote:
> In preparation for FORTIFY_SOURCE performing compile-time and run-time
> field bounds checking for memset(), avoid intentionally writing across
> neighboring fields.
> 
> Use memset_startat() so memset() doesn't get confused about writing
> beyond the destination member that is intended to be the starting point
> of zeroing through the end of the struct.
> 
> [...]

Here is the summary with links:
  - net: dccp: Use memset_startat() for TP zeroing
    https://git.kernel.org/netdev/net-next/c/f5455a1d9d49

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

