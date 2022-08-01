From: patchwork-bot+netdevbpf@kernel.org
Date: Mon, 01 Aug 2022 19:50:13 +0000
Subject: Re: [PATCH v2] dccp: put dccp_qpolicy_full() and dccp_qpolicy_push() in the same lock
Message-Id: <165938341366.9721.17408043483330420763.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net.git (master)
by Jakub Kicinski <kuba@kernel.org>:

On Fri, 29 Jul 2022 19:00:27 +0800 you wrote:
> In the case of sk->dccps_qpolicy = DCCPQ_POLICY_PRIO, dccp_qpolicy_full
> will drop a skb when qpolicy is full. And the lock in dccp_sendmsg is
> released before sock_alloc_send_skb and then relocked after
> sock_alloc_send_skb. The following conditions may lead dccp_qpolicy_push
> to add skb to an already full sk_write_queue:
> 
> thread1--->lock
> thread1--->dccp_qpolicy_full: queue is full. drop a skb
> thread1--->unlock
> thread2--->lock
> thread2--->dccp_qpolicy_full: queue is not full. no need to drop.
> thread2--->unlock
> thread1--->lock
> thread1--->dccp_qpolicy_push: add a skb. queue is full.
> thread1--->unlock
> thread2--->lock
> thread2--->dccp_qpolicy_push: add a skb!
> thread2--->unlock
> 
> [...]

Here is the summary with links:
  - [v2] dccp: put dccp_qpolicy_full() and dccp_qpolicy_push() in the same lock
    https://git.kernel.org/netdev/net/c/a41b17ff9dac

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

