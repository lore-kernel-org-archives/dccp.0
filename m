From: patchwork-bot+netdevbpf@kernel.org
Date: Thu, 25 Aug 2022 02:40:19 +0000
Subject: Re: [PATCH RESEND net-next v4 0/3] Add a second bind table hashed by port and address
Message-Id: <166139521930.434.1076457897005126686.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20220822181023.3979645-1-joannelkoong@gmail.com>
In-Reply-To: <20220822181023.3979645-1-joannelkoong@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This series was applied to netdev/net-next.git (master)
by Jakub Kicinski <kuba@kernel.org>:

On Mon, 22 Aug 2022 11:10:20 -0700 you wrote:
> Currently, there is one bind hashtable (bhash) that hashes by port only.
> This patchset adds a second bind table (bhash2) that hashes by port and
> address.
> 
> The motivation for adding bhash2 is to expedite bind requests in situations
> where the port has many sockets in its bhash table entry (eg a large number
> of sockets bound to different addresses on the same port), which makes checking
> bind conflicts costly especially given that we acquire the table entry spinlock
> while doing so, which can cause softirq cpu lockups and can prevent new tcp
> connections.
> 
> [...]

Here is the summary with links:
  - [RESEND,net-next,v4,1/3] net: Add a bhash2 table hashed by port and address
    https://git.kernel.org/netdev/net-next/c/28044fc1d495
  - [RESEND,net-next,v4,2/3] selftests/net: Add test for timing a bind request to a port with a populated bhash entry
    https://git.kernel.org/netdev/net-next/c/c35ecb95c448
  - [RESEND,net-next,v4,3/3] selftests/net: Add sk_bind_sendto_listen and sk_connect_zero_addr
    https://git.kernel.org/netdev/net-next/c/1be9ac87a75a

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

