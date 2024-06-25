Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B882147C96;
	Tue, 25 Jun 2024 09:50:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719309035; cv=none; b=KF/yFfuMv/nk8tsjive0/gfQfFdJnd56rsL9EDAmm2252dHcvV9XJkRZ56bYD47LQd6z9G3M8D77DwiKtkGsia3+LBpzSl+jYxuOVqV/Yd+2uxkYasOn1cGRwmEm0y3jEVwo2z1dLLUq1ncUSaSfGUtg903nTPrGPgDFb1d65sI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719309035; c=relaxed/simple;
	bh=8piofPzlXAHJRtUvNGgITSoj/v8akSwtuEuQ9malAeY=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=CMPQ8v9qeVKTptzY6rLPrVipBT0wxY3pqSIjl/1EsO8urnQvSK1mushnQQ5XonDfYlnoPaJ4txG6nPq4bxaaK+j3LfTMA+hCCk1NAzYeBoSrYwR+/56phrmZVdb7JxDaQSlWO05B3F+4BcwHGtWnwhyfJ/FrcO50PAZrXFsDhJg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RwlHj7tp; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RwlHj7tp"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 2A4A1C32789;
	Tue, 25 Jun 2024 09:50:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1719309035;
	bh=8piofPzlXAHJRtUvNGgITSoj/v8akSwtuEuQ9malAeY=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=RwlHj7tpXNs1XZ0jUIJk9/7m0vfmEpCfhnrAabopbixJgIJpyEJ1tptD6owK+p5Lu
	 X+cQ9RzmW2Kyns2G41lMqX51htFeHB82OP0k3BRmxqUtgyWrADp7mfROcnaRr+kswk
	 migEwlF68k3Sw4JPby7hd0L493C0DErtRvWVvKpKdZqsLnMQChghCllLFgmfKvFrWJ
	 ubfjh+yErowTp9rCPmXiwRcW+0QPIrOkRtCtdh9W7nn0KuLcokzcy6IzmVIEqKikVw
	 uj42ibaruPJY3We95rEFg8n25drRVZX5WsjgBVqKMhntVhar6z7HEhQOsEnv4659yf
	 xjO/ma+JipcYQ==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
	by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 1B2BDC43638;
	Tue, 25 Jun 2024 09:50:35 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net v4] Fix race for duplicate reqsk on identical SYN
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <171930903510.26753.16745690029094137653.git-patchwork-notify@kernel.org>
Date: Tue, 25 Jun 2024 09:50:35 +0000
References: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
In-Reply-To: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
To: luoxuanqiang <luoxuanqiang@kylinos.cn>
Cc: kuniyu@amazon.com, edumazet@google.com, kuba@kernel.org,
 davem@davemloft.net, pabeni@redhat.com, dccp@vger.kernel.org,
 dsahern@kernel.org, fw@strlen.de, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, alexandre.ferrieux@orange.com

Hello:

This patch was applied to netdev/net.git (main)
by Paolo Abeni <pabeni@redhat.com>:

On Fri, 21 Jun 2024 09:39:29 +0800 you wrote:
> When bonding is configured in BOND_MODE_BROADCAST mode, if two identical
> SYN packets are received at the same time and processed on different CPUs,
> it can potentially create the same sk (sock) but two different reqsk
> (request_sock) in tcp_conn_request().
> 
> These two different reqsk will respond with two SYNACK packets, and since
> the generation of the seq (ISN) incorporates a timestamp, the final two
> SYNACK packets will have different seq values.
> 
> [...]

Here is the summary with links:
  - [net,v4] Fix race for duplicate reqsk on identical SYN
    https://git.kernel.org/netdev/net/c/ff46e3b44219

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


