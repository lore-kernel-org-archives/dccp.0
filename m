From: patchwork-bot+netdevbpf@kernel.org
Date: Sat, 06 Feb 2021 19:20:07 +0000
Subject: Re: [PATCH net-next] dccp: Return the correct errno code
Message-Id: <161263920753.23851.11461572850833171527.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20210204072820.17723-1-zhengyongjun3@huawei.com>
In-Reply-To: <20210204072820.17723-1-zhengyongjun3@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net-next.git (refs/heads/master):

On Thu, 4 Feb 2021 15:28:20 +0800 you wrote:
> When kalloc or kmemdup failed, should return ENOMEM rather than ENOBUF.
> 
> Signed-off-by: Zheng Yongjun <zhengyongjun3@huawei.com>
> ---
>  net/dccp/feat.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Here is the summary with links:
  - [net-next] dccp: Return the correct errno code
    https://git.kernel.org/netdev/net-next/c/247b557ee52a

You are awesome, thank you!
--
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

