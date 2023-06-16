From: patchwork-bot+netdevbpf@kernel.org
Date: Fri, 16 Jun 2023 05:50:20 +0000
Subject: Re: [PATCH net-next v7] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <168689462068.26047.7995810161651055390.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20230609152800.830401-1-leitao@debian.org>
In-Reply-To: <20230609152800.830401-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net-next.git (main)
by Jakub Kicinski <kuba@kernel.org>:

On Fri,  9 Jun 2023 08:27:42 -0700 you wrote:
> Most of the ioctls to net protocols operates directly on userspace
> argument (arg). Usually doing get_user()/put_user() directly in the
> ioctl callback.  This is not flexible, because it is hard to reuse these
> functions without passing userspace buffers.
> 
> Change the "struct proto" ioctls to avoid touching userspace memory and
> operate on kernel buffers, i.e., all protocol's ioctl callbacks is
> adapted to operate on a kernel memory other than on userspace (so, no
> more {put,get}_user() and friends being called in the ioctl callback).
> 
> [...]

Here is the summary with links:
  - [net-next,v7] net: ioctl: Use kernel memory on protocol ioctl callbacks
    https://git.kernel.org/netdev/net-next/c/e1d001fa5b47

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

