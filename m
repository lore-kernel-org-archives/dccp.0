Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0481613FED;
	Thu,  2 Nov 2023 12:10:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="o2OXjBVY"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 74FE6C433C8;
	Thu,  2 Nov 2023 12:10:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1698927025;
	bh=WlJKzWqaEBjS2Pn1K0gjn4aYhMZTAtlKcn1gZ31mKbs=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=o2OXjBVYNayAuX5vbWWZXfaMWRMHkxxDjHRQ2dK5nq7adIyKP1T1Vl/02xEqwk0u/
	 g+aSIZ/hAg1igJtcgVcm4dV21F6qJupMdNw/O7lMVIyMT+dMSSIvh9hiXVs+viBhOS
	 nlLWmz7NXRtZxedQ0Z1Wne6svuc4z3ragFGZ7oY6+seK2oCZ3dfRBncDlQgg+KFF36
	 jXEuYX6YJuGJoEXi6t8DxrUSyQQresvPohExSoEYV2R7wFd4BMF94sYxI7sKbA5RAy
	 BW1z1q11m5OGEVS4fL5gx/da+NktcBweBFEWVejUQQYxW3mdsCSZpPBlt6vvH0FFgt
	 EWeKR4I+waQaQ==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
	by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 54928EAB08B;
	Thu,  2 Nov 2023 12:10:25 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v1 net 0/2] dccp/tcp: Relocate security_inet_conn_request().
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <169892702534.9917.11670611602722170451.git-patchwork-notify@kernel.org>
Date: Thu, 02 Nov 2023 12:10:25 +0000
References: <20231030201042.32885-1-kuniyu@amazon.com>
In-Reply-To: <20231030201042.32885-1-kuniyu@amazon.com>
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
 pabeni@redhat.com, dsahern@kernel.org, kuni1840@gmail.com,
 netdev@vger.kernel.org, dccp@vger.kernel.org

Hello:

This series was applied to netdev/net.git (main)
by Paolo Abeni <pabeni@redhat.com>:

On Mon, 30 Oct 2023 13:10:40 -0700 you wrote:
> security_inet_conn_request() reads reqsk's remote address, but it's not
> initialised in some places.
> 
> Let's make sure the address is set before security_inet_conn_request().
> 
> 
> Kuniyuki Iwashima (2):
>   dccp: Call security_inet_conn_request() after setting IPv4 addresses.
>   dccp/tcp: Call security_inet_conn_request() after setting IPv6
>     addresses.
> 
> [...]

Here is the summary with links:
  - [v1,net,1/2] dccp: Call security_inet_conn_request() after setting IPv4 addresses.
    https://git.kernel.org/netdev/net/c/fa2df45af130
  - [v1,net,2/2] dccp/tcp: Call security_inet_conn_request() after setting IPv6 addresses.
    https://git.kernel.org/netdev/net/c/23be1e0e2a83

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


