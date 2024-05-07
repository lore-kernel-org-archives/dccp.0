Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 059F073514;
	Tue,  7 May 2024 23:20:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1715124029; cv=none; b=AMSOuqntjl8rkgi0Fajah+XSDK9CjtbzykUvqe7xLwlgkj9ZB4RfTZl/Mb2UUOtOE1JZjsD+VJW79dObKs833viQwRcfUDD4rgU7sJJS1mUdBcoDsdk/0fTUziFtZ2RWoFPzb7WdfNH2mMaH/9Ft/X3/0cq5OZ9WjG16f7r4sig=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1715124029; c=relaxed/simple;
	bh=JdarES88yp6jfonQ2dpwnyScD7nI33DnAuqFsPHcG0A=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=aoSzAFt9ihCq803jYUif1HSuOfre+OMjurM5Kkr3RobIw9xO1uHjj8jH5BNQuRyQjHOkp2Q7QcARbQkPeAJ79q/xMh5JBjrP65HKrpAJoimMgIKOPcVAD0jd2YYMMEm+57Gve6vjaaDG5L0mkgf/zDT0NWGXWxxf3mmN0TShN6M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MMlynYBI; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MMlynYBI"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 7A963C2BBFC;
	Tue,  7 May 2024 23:20:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1715124028;
	bh=JdarES88yp6jfonQ2dpwnyScD7nI33DnAuqFsPHcG0A=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc:From;
	b=MMlynYBIY86aPPQrPEivRJIdIzvI7iCysExgeFyORoOmwxYucoIZxZDWI4SBh9ji6
	 sBLgu8ZscBIfs9pjD9UNudXcpLBYX8+JeImhLp+8d1UPNQOOU4YqMtC8p7yebyC0RR
	 l4DovdfNpJ3OC4KWPxZ8dv9sgzxWkbG2AAEJbErkwwLkulQSbUl+vj6Utxv6WrOuXw
	 6o0EXg/bWt3VwfQ157V/wWYZNl++kzhHBVAZ9BfR0wPHik0Z69uvzShLhwXbPnQMtk
	 IDQXjWIF+/6jQ9Ty7r9V0MkvAZfgwaxTTlF8OkyYLAz7NW08JuxhmJQ8aj0pPDpFib
	 nbOH/sMiKh2eg==
Received: from aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (localhost.localdomain [127.0.0.1])
	by aws-us-west-2-korg-oddjob-1.ci.codeaurora.org (Postfix) with ESMTP id 6F06DC43617;
	Tue,  7 May 2024 23:20:28 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH] net: dccp: Fix ccid2_rtt_estimator() kernel-doc
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <171512402845.11379.8750245287455297553.git-patchwork-notify@kernel.org>
Date: Tue, 07 May 2024 23:20:28 +0000
References: <20240505-ccid2_rtt_estimator-kdoc-v1-1-09231fcb9145@quicinc.com>
In-Reply-To: <20240505-ccid2_rtt_estimator-kdoc-v1-1-09231fcb9145@quicinc.com>
To: Jeff Johnson <quic_jjohnson@quicinc.com>
Cc: davem@davemloft.net, edumazet@google.com, kuba@kernel.org,
 pabeni@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org

Hello:

This patch was applied to netdev/net-next.git (main)
by Jakub Kicinski <kuba@kernel.org>:

On Sun, 5 May 2024 13:09:31 -0700 you wrote:
> make C=1 reports:
> 
> warning: Function parameter or struct member 'mrtt' not described in 'ccid2_rtt_estimator'
> 
> So document the 'mrtt' parameter.
> 
> Signed-off-by: Jeff Johnson <quic_jjohnson@quicinc.com>
> 
> [...]

Here is the summary with links:
  - net: dccp: Fix ccid2_rtt_estimator() kernel-doc
    https://git.kernel.org/netdev/net-next/c/feb8c2b76eb3

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


