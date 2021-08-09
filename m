From: patchwork-bot+netdevbpf@kernel.org
Date: Mon, 09 Aug 2021 09:10:05 +0000
Subject: Re: [PATCH -net] dccp: add do-while-0 stubs for dccp_pr_debug macros
Message-Id: <162850020556.22991.14180369324728108258.git-patchwork-notify@kernel.org>
List-Id: <dccp.vger.kernel.org>
References: <20210808230440.15784-1-rdunlap@infradead.org>
In-Reply-To: <20210808230440.15784-1-rdunlap@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hello:

This patch was applied to netdev/net.git (refs/heads/master):

On Sun,  8 Aug 2021 16:04:40 -0700 you wrote:
> GCC complains about empty macros in an 'if' statement, so convert
> them to 'do {} while (0)' macros.
> 
> Fixes these build warnings:
> 
> net/dccp/output.c: In function 'dccp_xmit_packet':
> ../net/dccp/output.c:283:71: warning: suggest braces around empty body in an 'if' statement [-Wempty-body]
>   283 |                 dccp_pr_debug("transmit_skb() returned err=%d\n", err);
> net/dccp/ackvec.c: In function 'dccp_ackvec_update_old':
> ../net/dccp/ackvec.c:163:80: warning: suggest braces around empty body in an 'else' statement [-Wempty-body]
>   163 |                                               (unsigned long long)seqno, state);
> 
> [...]

Here is the summary with links:
  - [-net] dccp: add do-while-0 stubs for dccp_pr_debug macros
    https://git.kernel.org/netdev/net/c/86aab09a4870

You are awesome, thank you!
--
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html

