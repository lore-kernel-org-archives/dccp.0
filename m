From: patchwork-bot+netdevbpf@kernel.org
Date: Mon, 17 May 2021 22:40:09 +0000
Subject: Re: [PATCH] net: Remove the member netns_ok
Message-Id: <162129120995.10606.11207863324142799499.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <1621254125-21588-1-git-send-email-yejunedeng@gmail.com>
In-Reply-To: <1621254125-21588-1-git-send-email-yejunedeng@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net-next.git (refs/heads/master):

On Mon, 17 May 2021 20:22:05 +0800 you wrote:
> Every protocol has the 'netns_ok' member and it is euqal to 1. The
> 'if (!prot->netns_ok)' always false in inet_add_protocol().
> 
> Signed-off-by: Yejune Deng <yejunedeng@gmail.com>
> ---
>  include/net/protocol.h    | 1 -
>  net/dccp/ipv4.c           | 1 -
>  net/ipv4/af_inet.c        | 4 ----
>  net/ipv4/gre_demux.c      | 1 -
>  net/ipv4/ipmr.c           | 1 -
>  net/ipv4/protocol.c       | 6 ------
>  net/ipv4/tunnel4.c        | 3 ---
>  net/ipv4/udplite.c        | 1 -
>  net/ipv4/xfrm4_protocol.c | 3 ---
>  net/l2tp/l2tp_ip.c        | 1 -
>  net/sctp/protocol.c       | 1 -
>  11 files changed, 23 deletions(-)

Here is the summary with links:
  - net: Remove the member netns_ok
    https://git.kernel.org/netdev/net-next/c/5796254e467b

You are awesome, thank you!
--
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

