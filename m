Received: from smtp-fw-52005.amazon.com (smtp-fw-52005.amazon.com [52.119.213.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B9CE15D1;
	Fri, 21 Jun 2024 22:48:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=52.119.213.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719010107; cv=none; b=KTafNaG+2Gy3sSMn7+qSu/SwpWBXfUCud3lCVIli6fShUhCU+rEqoVmgS69eq937Akf60N0If6y/uAHdlSBvTQlWD0g8k7LxbRK4Gy3aMOZzNNYMt95VPjsMsVbCboxGXx6ykfP41bldaDPaTrhuYZ5LcZyRWAg22bro5A7K7nU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719010107; c=relaxed/simple;
	bh=+ixQElxwwpzXsjGVjQW/At/HLoIvmODruZlbcS93qGw=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=LjbPqKoQEhLvn/2p6a8I5tg4pNX2O4PHJH/lHi2YMdwhvSpfCdE/WeVxajKSes4EafxBU2i2wV4ZgNB1kPwFNrkTEpQtgtfS4tIBePJOuTPawJgqgzNyhcB9BV8kXS2WvoWAhYzEZAPEOKx00rwBm/0F6Wkd62rNvznXpMCe1Tw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.co.jp; dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b=Xsj/n/MO; arc=none smtp.client-ip=52.119.213.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.co.jp
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="Xsj/n/MO"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1719010106; x=1750546106;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=xkj6QHoS5bB9dt0+gxdhy2HS7dkn7KEGOuZp/Sviik8=;
  b=Xsj/n/MOTmGv6x/5v4uCh/5+dT8iM6y30e8zK2h7xtwMsQ4rUJalvp0U
   Ru6H6liT4G29OVhvqXmN8EmeUm+OwS4jEmY/dI0VVNte7UZs9e3fDcKRQ
   VSKrW57Fn+dsXs6xhY5egU2hMPlpZQ6H94cdF5YTd7fct/nDtHNLG2j1O
   w=;
X-IronPort-AV: E=Sophos;i="6.08,256,1712620800"; 
   d="scan'208";a="662229041"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev) ([10.43.8.6])
  by smtp-border-fw-52005.iad7.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 21 Jun 2024 22:48:22 +0000
Received: from EX19MTAUWC002.ant.amazon.com [10.0.38.20:21821]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.52.145:2525] with esmtp (Farcaster)
 id 35a9dbf0-b590-4b1f-94b4-18f8a44e83fa; Fri, 21 Jun 2024 22:48:20 +0000 (UTC)
X-Farcaster-Flow-ID: 35a9dbf0-b590-4b1f-94b4-18f8a44e83fa
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWC002.ant.amazon.com (10.250.64.143) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.34;
 Fri, 21 Jun 2024 22:48:20 +0000
Received: from 88665a182662.ant.amazon.com (10.142.201.95) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1258.34; Fri, 21 Jun 2024 22:48:17 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: <luoxuanqiang@kylinos.cn>
CC: <alexandre.ferrieux@orange.com>, <davem@davemloft.net>,
	<dccp@vger.kernel.org>, <dsahern@kernel.org>, <edumazet@google.com>,
	<fw@strlen.de>, <kuba@kernel.org>, <kuniyu@amazon.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>, <pabeni@redhat.com>
Subject: Re: [PATCH net v4] Fix race for duplicate reqsk on identical SYN
Date: Fri, 21 Jun 2024 15:48:07 -0700
Message-ID: <20240621224807.8962-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
References: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: EX19D032UWA003.ant.amazon.com (10.13.139.37) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)

From: luoxuanqiang <luoxuanqiang@kylinos.cn>
Date: Fri, 21 Jun 2024 09:39:29 +0800
> When bonding is configured in BOND_MODE_BROADCAST mode, if two identical
> SYN packets are received at the same time and processed on different CPUs,
> it can potentially create the same sk (sock) but two different reqsk
> (request_sock) in tcp_conn_request().
> 
> These two different reqsk will respond with two SYNACK packets, and since
> the generation of the seq (ISN) incorporates a timestamp, the final two
> SYNACK packets will have different seq values.
> 
> The consequence is that when the Client receives and replies with an ACK
> to the earlier SYNACK packet, we will reset(RST) it.
> 
> ========================================================================
> 
> This behavior is consistently reproducible in my local setup,
> which comprises:
> 
>                   | NETA1 ------ NETB1 |
> PC_A --- bond --- |                    | --- bond --- PC_B
>                   | NETA2 ------ NETB2 |
> 
> - PC_A is the Server and has two network cards, NETA1 and NETA2. I have
>   bonded these two cards using BOND_MODE_BROADCAST mode and configured
>   them to be handled by different CPU.
> 
> - PC_B is the Client, also equipped with two network cards, NETB1 and
>   NETB2, which are also bonded and configured in BOND_MODE_BROADCAST mode.
> 
> If the client attempts a TCP connection to the server, it might encounter
> a failure. Capturing packets from the server side reveals:
> 
> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855116,
> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855123, <==
> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117, <==
> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117,
> 
> Two SYNACKs with different seq numbers are sent by localhost,
> resulting in an anomaly.
> 
> ========================================================================
> 
> The attempted solution is as follows:
> Add a return value to inet_csk_reqsk_queue_hash_add() to confirm if the
> ehash insertion is successful (Up to now, the reason for unsuccessful
> insertion is that a reqsk for the same connection has already been
> inserted). If the insertion fails, release the reqsk.
> 
> Due to the refcnt, Kuniyuki suggests also adding a return value check
> for the DCCP module; if ehash insertion fails, indicating a successful
> insertion of the same connection, simply release the reqsk as well.
> 
> Simultaneously, In the reqsk_queue_hash_req(), the start of the
> req->rsk_timer is adjusted to be after successful insertion.
> 
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>

Reviewed-by: Kuniyuki Iwashima <kuniyu@amazon.com>

Thanks!
