Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB4351DE4DF;
	Tue,  3 Dec 2024 09:18:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1733217505; cv=none; b=Ymw6KtWgmcR6h/mU81Xk0mSdIxXXy13VCnwwcDvWrdEb0VhqqvgrCcBzfpBOLVdt0gLlOG5CzKTQe6o01Kt8MH7YvgKvoUGSwaGy75s2CSfAdBSfCD76jFr8dt/yt64T/fDP7KgrAjpp1cIFzGLKUtWPxzsHTwBSYjCCBkmpNiM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1733217505; c=relaxed/simple;
	bh=9yXkUDZMfz4sHLAIVhrP4SvQobY74YVeNzCfgQ8/5Yk=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=Hmv+sXOpqa6VrDSO0Nq9WPgXgRHT1Txvc19NJHENfPt2VsdtzbWlQpnUCE3lFkdsDtJHx/qRLdpaDb6QSsvPst6b1al9zMsKQSZ8a7aPjuAMFaXygfgvA7AyYpEIhmN3sXPo1QjPJEv7LlykBZ0OG3nS6yzzdw3dj3ChiGnB868=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IuKU9OEi; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IuKU9OEi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 79E02C4CED6;
	Tue,  3 Dec 2024 09:18:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1733217505;
	bh=9yXkUDZMfz4sHLAIVhrP4SvQobY74YVeNzCfgQ8/5Yk=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=IuKU9OEi6YOyfP4tt28au5BelFnO2QY4JyZ4WnZy32qQQ0a9SkoD+MhXW2wrTJ8ZK
	 SzMfLFjBaMr56rIbGZSj1kFtD86aHi2bLjW2V5WFKTMS35616rf3Qj/g9O7QmZPRRs
	 c+qnVXiSjTpBM2C+Ufcagq49wVqAZwDyTUN8g2Nqj1upw9IgLaIRU4gXn6J/7sRiyy
	 6o7dInSwV3jWdhC7mUbC/ryZYYcVDCg9qOw3wnMCVM+yeR33FpbScQFQmHx37n7Yvz
	 TU59CldolnyyzDnmvsv++DGcuzyt3FUo7IXLxB7ROg4sA00daH1AT5IiI2S5ycvPGX
	 EYz9tqWydiJlw==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id EB1A53806656;
	Tue,  3 Dec 2024 09:18:40 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH net] dccp: Fix memory leak in dccp_feat_change_recv
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <173321751975.4083494.12180230037136307201.git-patchwork-notify@kernel.org>
Date: Tue, 03 Dec 2024 09:18:39 +0000
References: <20241126143902.190853-1-solodovnikov.ia@phystech.edu>
In-Reply-To: <20241126143902.190853-1-solodovnikov.ia@phystech.edu>
To: Ivan Solodovnikov <solodovnikov.ia@phystech.edu>
Cc: gerrit@erg.abdn.ac.uk, davem@davemloft.net, kuba@kernel.org,
 dccp@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 lvc-project@linuxtesting.org

Hello:

This patch was applied to netdev/net.git (main)
by Paolo Abeni <pabeni@redhat.com>:

On Tue, 26 Nov 2024 17:39:02 +0300 you wrote:
> If dccp_feat_push_confirm() fails after new value for SP feature was accepted
> without reconciliation ('entry == NULL' branch), memory allocated for that value
> with dccp_feat_clone_sp_val() is never freed.
> 
> Here is the kmemleak stack for this:
> 
> unreferenced object 0xffff88801d4ab488 (size 8):
>   comm "syz-executor310", pid 1127, jiffies 4295085598 (age 41.666s)
>   hex dump (first 8 bytes):
>     01 b4 4a 1d 80 88 ff ff                          ..J.....
>   backtrace:
>     [<00000000db7cabfe>] kmemdup+0x23/0x50 mm/util.c:128
>     [<0000000019b38405>] kmemdup include/linux/string.h:465 [inline]
>     [<0000000019b38405>] dccp_feat_clone_sp_val net/dccp/feat.c:371 [inline]
>     [<0000000019b38405>] dccp_feat_clone_sp_val net/dccp/feat.c:367 [inline]
>     [<0000000019b38405>] dccp_feat_change_recv net/dccp/feat.c:1145 [inline]
>     [<0000000019b38405>] dccp_feat_parse_options+0x1196/0x2180 net/dccp/feat.c:1416
>     [<00000000b1f6d94a>] dccp_parse_options+0xa2a/0x1260 net/dccp/options.c:125
>     [<0000000030d7b621>] dccp_rcv_state_process+0x197/0x13d0 net/dccp/input.c:650
>     [<000000001f74c72e>] dccp_v4_do_rcv+0xf9/0x1a0 net/dccp/ipv4.c:688
>     [<00000000a6c24128>] sk_backlog_rcv include/net/sock.h:1041 [inline]
>     [<00000000a6c24128>] __release_sock+0x139/0x3b0 net/core/sock.c:2570
>     [<00000000cf1f3a53>] release_sock+0x54/0x1b0 net/core/sock.c:3111
>     [<000000008422fa23>] inet_wait_for_connect net/ipv4/af_inet.c:603 [inline]
>     [<000000008422fa23>] __inet_stream_connect+0x5d0/0xf70 net/ipv4/af_inet.c:696
>     [<0000000015b6f64d>] inet_stream_connect+0x53/0xa0 net/ipv4/af_inet.c:735
>     [<0000000010122488>] __sys_connect_file+0x15c/0x1a0 net/socket.c:1865
>     [<00000000b4b70023>] __sys_connect+0x165/0x1a0 net/socket.c:1882
>     [<00000000f4cb3815>] __do_sys_connect net/socket.c:1892 [inline]
>     [<00000000f4cb3815>] __se_sys_connect net/socket.c:1889 [inline]
>     [<00000000f4cb3815>] __x64_sys_connect+0x6e/0xb0 net/socket.c:1889
>     [<00000000e7b1e839>] do_syscall_64+0x33/0x40 arch/x86/entry/common.c:46
>     [<0000000055e91434>] entry_SYSCALL_64_after_hwframe+0x67/0xd1
> 
> [...]

Here is the summary with links:
  - [net] dccp: Fix memory leak in dccp_feat_change_recv
    https://git.kernel.org/netdev/net/c/22be4727a8f8

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


