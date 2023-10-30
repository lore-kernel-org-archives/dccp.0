Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 79701D51E;
	Mon, 30 Oct 2023 21:20:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="d7WdwEKo"
Received: from smtp-fw-6001.amazon.com (smtp-fw-6001.amazon.com [52.95.48.154])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7D438E1;
	Mon, 30 Oct 2023 14:20:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1698700831; x=1730236831;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=xwZy335tyH6F30dB1h6lhdiab1XKJwNJ1JIvZO/o5hc=;
  b=d7WdwEKo5xTPtVoX9NT/LN13p3p0UBJyHzhNsWJ6XTg6fas+vhqMhirb
   hefACUBHI7904SPYHI3TckYaH5FmGIXt59HDFweT0nMsfsga0nInUcC2W
   K0YhwRL8n4VnruhZ5G+EmezXVodAf4Va2Ect0+OD2b9kwbbC486jC2w0T
   k=;
X-IronPort-AV: E=Sophos;i="6.03,264,1694736000"; 
   d="scan'208";a="367389888"
Received: from iad12-co-svc-p1-lb1-vlan2.amazon.com (HELO email-inbound-relay-pdx-2c-m6i4x-b1c0e1d0.us-west-2.amazon.com) ([10.43.8.2])
  by smtp-border-fw-6001.iad6.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 30 Oct 2023 21:20:28 +0000
Received: from smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev (pdx2-ws-svc-p26-lb5-vlan3.pdx.amazon.com [10.39.38.70])
	by email-inbound-relay-pdx-2c-m6i4x-b1c0e1d0.us-west-2.amazon.com (Postfix) with ESMTPS id 7143D80F74;
	Mon, 30 Oct 2023 21:20:26 +0000 (UTC)
Received: from EX19MTAUWA002.ant.amazon.com [10.0.7.35:5261]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.52.67:2525] with esmtp (Farcaster)
 id 62dc71b0-f8f1-4cb4-b680-a053351c0b34; Mon, 30 Oct 2023 21:20:25 +0000 (UTC)
X-Farcaster-Flow-ID: 62dc71b0-f8f1-4cb4-b680-a053351c0b34
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWA002.ant.amazon.com (10.250.64.202) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.39; Mon, 30 Oct 2023 21:20:25 +0000
Received: from 88665a182662.ant.amazon.com (10.187.171.32) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1118.39;
 Mon, 30 Oct 2023 21:20:22 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: <paul@paul-moore.com>
CC: <davem@davemloft.net>, <dccp@vger.kernel.org>, <dsahern@kernel.org>,
	<edumazet@google.com>, <huw@codeweavers.com>, <kuba@kernel.org>,
	<kuni1840@gmail.com>, <kuniyu@amazon.com>,
	<linux-security-module@vger.kernel.org>, <netdev@vger.kernel.org>,
	<pabeni@redhat.com>
Subject: Re: [PATCH v1 net 2/2] dccp/tcp: Call security_inet_conn_request() after setting IPv6 addresses.
Date: Mon, 30 Oct 2023 14:20:15 -0700
Message-ID: <20231030212015.57180-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <CAHC9VhTrm2shkh=FHcjnqFpDLFCoBwGfsyoSuDH3UFSOeZt+HA@mail.gmail.com>
References: <CAHC9VhTrm2shkh=FHcjnqFpDLFCoBwGfsyoSuDH3UFSOeZt+HA@mail.gmail.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-Originating-IP: [10.187.171.32]
X-ClientProxiedBy: EX19D036UWB002.ant.amazon.com (10.13.139.139) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)
Precedence: Bulk

From: Paul Moore <paul@paul-moore.com>
Date: Mon, 30 Oct 2023 17:12:33 -0400
> On Mon, Oct 30, 2023 at 4:12 PM Kuniyuki Iwashima <kuniyu@amazon.com> wrote:
> >
> > Initially, commit 4237c75c0a35 ("[MLSXFRM]: Auto-labeling of child
> > sockets") introduced security_inet_conn_request() in some functions
> > where reqsk is allocated.  The hook is added just after the allocation,
> > so reqsk's IPv6 remote address was not initialised then.
> >
> > However, SELinux/Smack started to read it in netlbl_req_setattr()
> > after commit e1adea927080 ("calipso: Allow request sockets to be
> > relabelled by the lsm.").
> >
> > Commit 284904aa7946 ("lsm: Relocate the IPv4 security_inet_conn_request()
> > hooks") fixed that kind of issue only in TCPv4 because IPv6 labeling was
> > not supported at that time.  Finally, the same issue was introduced again
> > in IPv6.
> >
> > Let's apply the same fix on DCCPv6 and TCPv6.
> >
> > Fixes: e1adea927080 ("calipso: Allow request sockets to be relabelled by the lsm.")
> > Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
> > ---
> > Cc: Huw Davies <huw@codeweavers.com>
> > Cc: Paul Moore <paul@paul-moore.com>
> > ---
> >  net/dccp/ipv6.c       | 6 +++---
> >  net/ipv6/syncookies.c | 7 ++++---
> >  2 files changed, 7 insertions(+), 6 deletions(-)
> 
> Thanks for catching this and submitting a patch!
> 
> It seems like we should also update dccp_v4_conn_request(), what do you think?

Yes, and it's done in patch 1 as it had a separate Fixes tag.
https://lore.kernel.org/netdev/20231030201042.32885-2-kuniyu@amazon.com/

It seems get_maintainers.pl suggested another email address of
yours for patch 1.  It would be good to update .mailmap ;)

Thanks!
