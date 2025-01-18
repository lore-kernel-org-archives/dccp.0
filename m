Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C1B543169;
	Sat, 18 Jan 2025 03:50:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737172225; cv=none; b=CeEVdRMtgumLfgE1xiqhFDddmnHouX7FDXWQ7p4eJ0j8+d9Zb502ZyE706lxBpKN3HDQiOJbgK3iWl23vNmCvuZXqqCYGcrYyhlV2clo7ZDQ88KDVqTq7e3M+Mr4zPbbvjIu9JKFDK9mPAqi7ESJa4H+d+U/BfPZszpFmeeupp0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737172225; c=relaxed/simple;
	bh=3KKQBu1ZYFd+nk5yZ5yGCYOPajNnt4OxsKSMRedTukQ=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=qqSJI/p7PunIb5WFgUZpieYsSLfytkCbdyvF/qz4qtfaxim8oKlZs/mYjG4Hz0tzetOZKm8kjTA84q7vGJ2mZXwGZuR9K/Dg0AU6QUs+d7vJsy1YRbcL5keBquqo8qiXV1VYOsTu8TKSrMbycXPvOyuLl0w9P68VMrm+klLHo/Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Kpxk5vG8; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kpxk5vG8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8B7CDC4CED1;
	Sat, 18 Jan 2025 03:50:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1737172224;
	bh=3KKQBu1ZYFd+nk5yZ5yGCYOPajNnt4OxsKSMRedTukQ=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=Kpxk5vG8sw7kXc36Mso+yjGaXQptf4jn6Of5M9O/jmb1tLuwfj40WHJtmIW7xekWq
	 SIbu1+tgJ5JIcRdl20lsxQtE+sasCuqjxgLKoNPWTLuSpZeFYPzN/uwfdqbKpUaaHM
	 RWQRJlH8rqgWgmSsyaJ2gyAn37jT4CUNTEy7mw7pWfBki6kVox3y4lfC+NOTNeRjYX
	 90vMPkqG3oxY/cf6uBQnFXi6PH3KL+2WTm+FriadxSuRIpkEnZLh3SGXuecwzRJebX
	 ShecQ62ZMiTqMtiAH8LJba6J9axAKT5VWNvLd1SJZkBKrj1c8Dd27usWE8q+nag6vl
	 Tuz/EbyHAXUqA==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 3440D380AA62;
	Sat, 18 Jan 2025 03:50:49 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net-next v2] dccp: Prepare dccp_v4_route_skb() to .flowi4_tos
 conversion.
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <173717224774.2330660.6681061767957141118.git-patchwork-notify@kernel.org>
Date: Sat, 18 Jan 2025 03:50:47 +0000
References: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
In-Reply-To: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
To: Guillaume Nault <gnault@redhat.com>
Cc: davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com,
 edumazet@google.com, netdev@vger.kernel.org, horms@kernel.org,
 dccp@vger.kernel.org, idosch@nvidia.com

Hello:

This patch was applied to netdev/net-next.git (main)
by Jakub Kicinski <kuba@kernel.org>:

On Thu, 16 Jan 2025 14:10:16 +0100 you wrote:
> Use inet_sk_dscp() to get the socket DSCP value as dscp_t, instead of
> ip_sock_rt_tos() which returns a __u8. This will ease the conversion
> of fl4->flowi4_tos to dscp_t, which now just becomes a matter of
> dropping the inet_dscp_to_dsfield() call.
> 
> Signed-off-by: Guillaume Nault <gnault@redhat.com>
> 
> [...]

Here is the summary with links:
  - [net-next,v2] dccp: Prepare dccp_v4_route_skb() to .flowi4_tos conversion.
    https://git.kernel.org/netdev/net-next/c/02673d58adfa

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


