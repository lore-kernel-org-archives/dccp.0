From: patchwork-bot+netdevbpf@kernel.org
Date: Wed, 08 Sep 2021 10:40:08 +0000
Subject: Re: [PATCH] dccp: don't duplicate ccid when cloning dccp sock
Message-Id: <163109760806.16056.10288524962758514205.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <D95F1297-95A1-4AC9-B0C2-803C453B1BAE@psu.edu>
In-Reply-To: <D95F1297-95A1-4AC9-B0C2-803C453B1BAE@psu.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net.git (refs/heads/master):

On Wed, 8 Sep 2021 03:40:59 +0000 you wrote:
> Commit 2677d2067731 ("dccp: don't free ccid2_hc_tx_sock ...") fixed
> a UAF but reintroduced CVE-2017-6074.
> 
> When the sock is cloned, two dccps_hc_tx_ccid will reference to the
> same ccid. So one can free the ccid object twice from two socks after
> cloning.
> 
> [...]

Here is the summary with links:
  - dccp: don't duplicate ccid when cloning dccp sock
    https://git.kernel.org/netdev/net/c/d9ea761fdd19

You are awesome, thank you!
--
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

