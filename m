Received: from smtp-fw-80008.amazon.com (smtp-fw-80008.amazon.com [99.78.197.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E7FC13A8E4;
	Thu, 20 Jun 2024 19:16:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=99.78.197.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718910973; cv=none; b=PfIGOeVO3X3FYhC+dfQtya7ZX6CgmsunKNZD6RJyPHy3kClAi9H2hO7hG/BKrkqIs6C/HTgtZrdXIs37uHZA8VBhlGFJWiNncrqM8DZNZAF62HAsOz57SsIVz2ToCvQGnyTZxVWWFm/5SyzoJQrio2gkXbTOGVDNJVQG2ObFaRg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718910973; c=relaxed/simple;
	bh=6JD47Puxr60tRnWotkUmPrg7zRsxmsBb91/lzSABt+Q=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=jevsy7Y9elFy/eLy5gII07XvPxhS+I9vsYOFu/bOEAARHFrr5UFf86VR6lP4P8G8/2bnh8B3OSuALb85acw8bLmXQiGQexcnn4ufmdJaKPvrsYzcm0q92Hkjp1d4YyQfP3GLBacQnUCZHphx2moKtUDa9MY3gtKi1Juc1lh8+UQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.co.jp; dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b=sdLM8JNW; arc=none smtp.client-ip=99.78.197.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.co.jp
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="sdLM8JNW"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1718910972; x=1750446972;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=gUj+8h97Gy88r0ZJPxtHxPnNfzMxGdFNmf5rrTpLMCs=;
  b=sdLM8JNWJiUW1Pa+7GN5Dj4D+bCGheAF/JvIRbDbVuyjbbKP6t+gqZGg
   e0bBRhhF9UKP6J6s770Kmh9RGEJ1fdkg8OqIbH8wYHdp/FZjBOEckNLmp
   DdiqpPxKjUo4E1HXTt7EJysn1AVTTRMjNpMpnIZkymHy0Ldcnrhx2MWv5
   U=;
X-IronPort-AV: E=Sophos;i="6.08,252,1712620800"; 
   d="scan'208";a="98260821"
Received: from pdx4-co-svc-p1-lb2-vlan3.amazon.com (HELO smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev) ([10.25.36.214])
  by smtp-border-fw-80008.pdx80.corp.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 20 Jun 2024 19:14:36 +0000
Received: from EX19MTAUWC001.ant.amazon.com [10.0.21.151:57331]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.33.47:2525] with esmtp (Farcaster)
 id f09946e8-136e-4344-8364-d9aeea270575; Thu, 20 Jun 2024 19:14:36 +0000 (UTC)
X-Farcaster-Flow-ID: f09946e8-136e-4344-8364-d9aeea270575
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWC001.ant.amazon.com (10.250.64.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1258.34; Thu, 20 Jun 2024 19:14:35 +0000
Received: from 88665a182662.ant.amazon.com.com (10.187.171.36) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1258.34; Thu, 20 Jun 2024 19:14:32 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: <luoxuanqiang@kylinos.cn>
CC: <alexandre.ferrieux@orange.com>, <davem@davemloft.net>,
	<dccp@vger.kernel.org>, <dsahern@kernel.org>, <edumazet@google.com>,
	<fw@strlen.de>, <kuba@kernel.org>, <kuniyu@amazon.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>, <pabeni@redhat.com>
Subject: Re: [PATCH net v3] Fix race for duplicate reqsk on identical SYN
Date: Thu, 20 Jun 2024 12:14:24 -0700
Message-ID: <20240620191424.50269-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <2f96ebeb-f366-fda1-f6d6-88ff2637c7cd@kylinos.cn>
References: <2f96ebeb-f366-fda1-f6d6-88ff2637c7cd@kylinos.cn>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: EX19D041UWB003.ant.amazon.com (10.13.139.176) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)

From: luoxuanqiang <luoxuanqiang@kylinos.cn>
Date: Thu, 20 Jun 2024 10:38:36 +0800
> 在 2024/6/20 03:53, Kuniyuki Iwashima 写道:
> > From: luoxuanqiang <luoxuanqiang@kylinos.cn>
> > Date: Wed, 19 Jun 2024 14:54:15 +0800
> >> 在 2024/6/18 01:59, Kuniyuki Iwashima 写道:
> >>> From: luoxuanqiang <luoxuanqiang@kylinos.cn>
> >>> Date: Mon, 17 Jun 2024 15:56:40 +0800
> >>>> When bonding is configured in BOND_MODE_BROADCAST mode, if two identical
> >>>> SYN packets are received at the same time and processed on different CPUs,
> >>>> it can potentially create the same sk (sock) but two different reqsk
> >>>> (request_sock) in tcp_conn_request().
> >>>>
> >>>> These two different reqsk will respond with two SYNACK packets, and since
> >>>> the generation of the seq (ISN) incorporates a timestamp, the final two
> >>>> SYNACK packets will have different seq values.
> >>>>
> >>>> The consequence is that when the Client receives and replies with an ACK
> >>>> to the earlier SYNACK packet, we will reset(RST) it.
> >>>>
> >>>> ========================================================================
> >>>>
> >>>> This behavior is consistently reproducible in my local setup,
> >>>> which comprises:
> >>>>
> >>>>                     | NETA1 ------ NETB1 |
> >>>> PC_A --- bond --- |                    | --- bond --- PC_B
> >>>>                     | NETA2 ------ NETB2 |
> >>>>
> >>>> - PC_A is the Server and has two network cards, NETA1 and NETA2. I have
> >>>>     bonded these two cards using BOND_MODE_BROADCAST mode and configured
> >>>>     them to be handled by different CPU.
> >>>>
> >>>> - PC_B is the Client, also equipped with two network cards, NETB1 and
> >>>>     NETB2, which are also bonded and configured in BOND_MODE_BROADCAST mode.
> >>>>
> >>>> If the client attempts a TCP connection to the server, it might encounter
> >>>> a failure. Capturing packets from the server side reveals:
> >>>>
> >>>> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
> >>>> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
> >>>> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855116,
> >>>> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855123, <==
> >>>> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
> >>>> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
> >>>> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117, <==
> >>>> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117,
> >>>>
> >>>> Two SYNACKs with different seq numbers are sent by localhost,
> >>>> resulting in an anomaly.
> >>>>
> >>>> ========================================================================
> >>>>
> >>>> The attempted solution is as follows:
> >>>> In the tcp_conn_request(), while inserting reqsk into the ehash table,
> >>>> it also checks if an entry already exists. If found, it avoids
> >>>> reinsertion and releases it.
> >>>>
> >>>> Simultaneously, In the reqsk_queue_hash_req(), the start of the
> >>>> req->rsk_timer is adjusted to be after successful insertion.
> >>>>
> >>>> Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>
> >>>> ---
> >>>>    include/net/inet_connection_sock.h |  4 ++--
> >>>>    net/dccp/ipv4.c                    |  2 +-
> >>>>    net/dccp/ipv6.c                    |  2 +-
> >>>>    net/ipv4/inet_connection_sock.c    | 19 +++++++++++++------
> >>>>    net/ipv4/tcp_input.c               |  9 ++++++++-
> >>>>    5 files changed, 25 insertions(+), 11 deletions(-)
> >>>>
> >>>> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> >>>> index 7d6b1254c92d..8ebab6220dbc 100644
> >>>> --- a/include/net/inet_connection_sock.h
> >>>> +++ b/include/net/inet_connection_sock.h
> >>>> @@ -263,8 +263,8 @@ struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
> >>>>    struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
> >>>>    				      struct request_sock *req,
> >>>>    				      struct sock *child);
> >>>> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> >>>> -				   unsigned long timeout);
> >>>> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> >>>> +				   unsigned long timeout, bool *found_dup_sk);
> >>>>    struct sock *inet_csk_complete_hashdance(struct sock *sk, struct sock *child,
> >>>>    					 struct request_sock *req,
> >>>>    					 bool own_req);
> >>>> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> >>>> index ff41bd6f99c3..13aafdeb9205 100644
> >>>> --- a/net/dccp/ipv4.c
> >>>> +++ b/net/dccp/ipv4.c
> >>>> @@ -657,7 +657,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
> >>>>    	if (dccp_v4_send_response(sk, req))
> >>>>    		goto drop_and_free;
> >>>>    
> >>>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
> >>>> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
> >>>>    	reqsk_put(req);
> >>>>    	return 0;
> >>>>    
> >>>> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> >>>> index 85f4b8fdbe5e..493cdb12ce2b 100644
> >>>> --- a/net/dccp/ipv6.c
> >>>> +++ b/net/dccp/ipv6.c
> >>>> @@ -400,7 +400,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
> >>>>    	if (dccp_v6_send_response(sk, req))
> >>>>    		goto drop_and_free;
> >>>>    
> >>>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
> >>>> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
> >>>>    	reqsk_put(req);
> >>>>    	return 0;
> >>>>    
> >>>> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> >>>> index d81f74ce0f02..2fa9b33ae26a 100644
> >>>> --- a/net/ipv4/inet_connection_sock.c
> >>>> +++ b/net/ipv4/inet_connection_sock.c
> >>>> @@ -1122,25 +1122,32 @@ static void reqsk_timer_handler(struct timer_list *t)
> >>>>    	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
> >>>>    }
> >>>>    
> >>>> -static void reqsk_queue_hash_req(struct request_sock *req,
> >>>> -				 unsigned long timeout)
> >>>> +static bool reqsk_queue_hash_req(struct request_sock *req,
> >>>> +				 unsigned long timeout, bool *found_dup_sk)
> >>>>    {
> >>> Given any changes here in reqsk_queue_hash_req() conflicts with 4.19
> >>> (oldest stable) and DCCP does not check found_dup_sk, you can define
> >>> found_dup_sk here, then you need not touch DCCP at all.
> >> Apologies for not fully understanding your advice. If we cannot modify
> >> the content of reqsk_queue_hash_req() and should avoid touching the DCCP
> >> part, it seems the issue requires reworking some interfaces. Specifically:
> >>
> >> The call flow to add reqsk to ehash is as follows:
> >>
> >> tcp_conn_request()
> >>
> >> dccp_v4(6)_conn_request()
> >>
> >>       -> inet_csk_reqsk_queue_hash_add()
> >>
> >>           -> reqsk_queue_hash_req()
> >>
> >>               -> inet_ehash_insert()
> >>
> >> tcp_conn_request() needs to call the same interface inet_csk_reqsk_queue_hash_add()
> >> as dccp_v4(6)_conn_request(), but the critical section for installation check and
> >> insertion into ehash is within inet_ehash_insert().
> >> If reqsk_queue_hash_req() should not be modified, then we need to rewrite
> >> the interfaces to distinguish them. I don't see how redefining found_dup_sk
> >> alone can resolve this conflict point.
> > I just said we cannot avoid conflict so suggested avoiding found_dup_sk
> > in inet_csk_reqsk_queue_hash_add().
> >
> > But I finally ended up modifying DCCP because we return before setting
> > refcnt.
> >
> > ---8<---
> > diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> > index ff41bd6f99c3..b2a8aed35eb0 100644
> > --- a/net/dccp/ipv4.c
> > +++ b/net/dccp/ipv4.c
> > @@ -657,8 +657,11 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
> >   	if (dccp_v4_send_response(sk, req))
> >   		goto drop_and_free;
> >   
> > -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
> > -	reqsk_put(req);
> > +	if (unlikely(inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT)))
> > +		reqsk_free(req);
> > +	else
> > +		reqsk_put(req);
> > +
> >   	return 0;
> >   
> >   drop_and_free:
> > diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> > index d81f74ce0f02..7dd6892b10b9 100644
> > --- a/net/ipv4/inet_connection_sock.c
> > +++ b/net/ipv4/inet_connection_sock.c
> > @@ -1122,25 +1122,33 @@ static void reqsk_timer_handler(struct timer_list *t)
> >   	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
> >   }
> >   
> > -static void reqsk_queue_hash_req(struct request_sock *req,
> > +static bool reqsk_queue_hash_req(struct request_sock *req,
> >   				 unsigned long timeout)
> >   {
> > +	bool found_dup_sk;
> > +
> > +	if (!inet_ehash_insert(req_to_sk(req), NULL, &found_dup_sk))
> > +		return false;
> > +
> >   	timer_setup(&req->rsk_timer, reqsk_timer_handler, TIMER_PINNED);
> >   	mod_timer(&req->rsk_timer, jiffies + timeout);
> >   
> > -	inet_ehash_insert(req_to_sk(req), NULL, NULL);
> >   	/* before letting lookups find us, make sure all req fields
> >   	 * are committed to memory and refcnt initialized.
> >   	 */
> >   	smp_wmb();
> >   	refcount_set(&req->rsk_refcnt, 2 + 1);
> > +	return true;
> >   }
> >   
> > -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> > +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> >   				   unsigned long timeout)
> >   {
> > -	reqsk_queue_hash_req(req, timeout);
> > +	if (!reqsk_queue_hash_req(req, timeout))
> > +		return false;
> > +
> >   	inet_csk_reqsk_queue_added(sk);
> > +	return true;
> >   }
> >   EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
> >   
> > ---8<---
> 
> Thank you for your patient explanation. I understand
> your point and will send out the V4 version, looking
> forward to your review.
> 
> Also, I'd like to confirm a detail with you. For the DCCP part, is it
>   sufficient to simply call reqsk_free() for the return value, or should
> we use goto drop_and_free? The different return values here will
> determine whether a reset is sent, and I lack a comprehensive
> understanding of DCCP. so could you please help me confirm this
> from a higher-level perspective?

I think we need not send RST because in this case there's another
establishing request already in ehash and we should not abort it
as we don't do so in tcp_conn_request().

Thanks!


> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index ff41bd6f99c3..5926159a6f20 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -657,8 +657,11 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>          if (dccp_v4_send_response(sk, req))
>                  goto drop_and_free;
>   
> -       inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
> -       reqsk_put(req);
> +       if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT)))
> +               reqsk_free(req);    // or  goto drop_and_free:   <============
> +       else
> +               reqsk_put(req);
> +
>          return 0;
>   
> drop_and_free:
>      reqsk_free(req);
> drop:
>      __DCCP_INC_STATS(DCCP_MIB_ATTEMPTFAILS);
>      return -1;
> }
