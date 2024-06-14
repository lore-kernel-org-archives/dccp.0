Received: from smtp-fw-6002.amazon.com (smtp-fw-6002.amazon.com [52.95.49.90])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7B79782C67;
	Fri, 14 Jun 2024 22:24:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=52.95.49.90
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718403892; cv=none; b=Ow8kB03N6KJiAr9tbzRK9gHDYMO89EthV6MvDAhNOv8jsYbDKQ093AkhG1PovVQKuryz4F2llpmnavqfBnQwNrXVifMOOaGgX8W//A7nrAX96+lS3oka0Y19QD310iyonxqXUBrTQrrraTDFapiFLHQCvy/X2mKPxig1b4broOs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718403892; c=relaxed/simple;
	bh=+D3s1E3b7iqirRzTszp4FQo05Wzq00jT40LBJspl2o4=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=kSi5EJsu2wYmyuvYquYbTc4Cmeca18o/Afui2KPd23C2olGLX6rmWUIIwXxU5V263FXlVa/GQ0aGIWdisqdMOMXPOGv8/KQZ1fRuIZReopM1gYommnl1uJJdbhY9YGD9HaxiYJ5hynAGtK84zl8rZb/smpN3sfvAHG7KKQ1mlcg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.co.jp; dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b=jPFf7/Wz; arc=none smtp.client-ip=52.95.49.90
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.co.jp
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="jPFf7/Wz"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1718403891; x=1749939891;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=lrbkSMJHYRvwFfElUgPPy2+Gr7nlFJz0ezq9T68Sy2I=;
  b=jPFf7/Wz7zIqkGufksejIepUmk5pRTHIb1uDTx6QvK2kqfxQSwROQXMn
   zuegOt0Jf0Gy1d79+ssjEZBzGPArltdqXD/NcaqBKT79Kpo4+7OjJlb+c
   JTDo1VuLFrxT3lzulQhd+1KHhP1iu26Mddy/26uUBDDT7RHyfUy93B8ea
   4=;
X-IronPort-AV: E=Sophos;i="6.08,238,1712620800"; 
   d="scan'208";a="413537530"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev) ([10.43.8.6])
  by smtp-border-fw-6002.iad6.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 14 Jun 2024 22:24:47 +0000
Received: from EX19MTAUWC001.ant.amazon.com [10.0.7.35:6178]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.46.168:2525] with esmtp (Farcaster)
 id 7229e181-4b41-4e7e-a0bd-13f0a6f85223; Fri, 14 Jun 2024 22:24:46 +0000 (UTC)
X-Farcaster-Flow-ID: 7229e181-4b41-4e7e-a0bd-13f0a6f85223
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWC001.ant.amazon.com (10.250.64.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1258.34; Fri, 14 Jun 2024 22:24:46 +0000
Received: from 88665a182662.ant.amazon.com.com (10.106.100.24) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1258.34; Fri, 14 Jun 2024 22:24:42 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: <luoxuanqiang@kylinos.cn>
CC: <davem@davemloft.net>, <dccp@vger.kernel.org>, <dsahern@kernel.org>,
	<edumazet@google.com>, <fw@strlen.de>, <kuba@kernel.org>,
	<kuniyu@amazon.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <pabeni@redhat.com>
Subject: Re: [PATCH net v2] Fix race for duplicate reqsk on identical SYN
Date: Fri, 14 Jun 2024 15:24:33 -0700
Message-ID: <20240614222433.19580-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <7075bb26-ede9-0dc7-fe93-e18703e5ddaa@kylinos.cn>
References: <7075bb26-ede9-0dc7-fe93-e18703e5ddaa@kylinos.cn>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: EX19D036UWC003.ant.amazon.com (10.13.139.214) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)

From: luoxuanqiang <luoxuanqiang@kylinos.cn>
Date: Fri, 14 Jun 2024 20:42:07 +0800
> 在 2024/6/14 18:54, Florian Westphal 写道:
> > luoxuanqiang <luoxuanqiang@kylinos.cn> wrote:
> >>   include/net/inet_connection_sock.h |  2 +-
> >>   net/dccp/ipv4.c                    |  2 +-
> >>   net/dccp/ipv6.c                    |  2 +-
> >>   net/ipv4/inet_connection_sock.c    | 15 +++++++++++----
> >>   net/ipv4/tcp_input.c               | 11 ++++++++++-
> >>   5 files changed, 24 insertions(+), 8 deletions(-)
> >>
> >> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> >> index 7d6b1254c92d..8773d161d184 100644
> >> --- a/include/net/inet_connection_sock.h
> >> +++ b/include/net/inet_connection_sock.h
> >> @@ -264,7 +264,7 @@ struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
> >>   				      struct request_sock *req,
> >>   				      struct sock *child);
> >>   void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> >> -				   unsigned long timeout);
> >> +				   unsigned long timeout, bool *found_dup_sk);
> > Nit:
> >
> > I think it would be preferrable to change retval to bool rather than
> > bool *found_dup_sk extra arg, so one can do

+1


> >
> > bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> >    				   unsigned long timeout)
> > {
> > 	if (!reqsk_queue_hash_req(req, timeout))
> > 		return false;
> >
> > i.e. let retval indicate wheter reqsk was inserted or not.
> >
> > Patch looks good to me otherwise.
> 
> Thank you for your confirmation!
> 
> Regarding your suggestion, I had considered it before,
> but besides tcp_conn_request() calling inet_csk_reqsk_queue_hash_add(),
> dccp_v4(v6)_conn_request() also calls it. However, there is no
> consideration for a failed insertion within that function, so it's
> reasonable to let the caller decide whether to check for duplicate
> reqsk.

I guess you followed 01770a1661657 where found_dup_sk was introduced,
but note that the commit is specific to TCP SYN Cookie and TCP Fast Open
and DCCP is not related.

Then, own_req is common to TCP and DCCP, so found_dup_sk was added as an
additional argument.

However, another similar commit 5e0724d027f05 actually added own_req check
in DCCP path.

I personally would'nt care if DCCP was not changed to handle such a
failure because DCCP will be removed next year, but I still prefer
Florian's suggestion.

Thanks
