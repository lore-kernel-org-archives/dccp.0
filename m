Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com [207.171.190.10])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F1C7198822;
	Mon, 17 Jun 2024 17:59:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=207.171.190.10
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718647169; cv=none; b=ZJD+yEQpfbUeNwLGl1h0RJxkhou+cIMKmiDnd9bf4CtCY+hDOFbK7hY9AQkGy4xsHD73MIXmhI/kHqtUAGF9NEo4yiNdga5WKbgtMa2y0E0aWJVVfu2qjQ70Jy1NNy4ZSlVwHpX7s80EX+VilsJx9RMaQOsBH0tjhQlTxEoGQe0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718647169; c=relaxed/simple;
	bh=uGyPNIMlpr25ZmedrDnTmh5uTwrDeVJvbccUSHxxb/0=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=UfwWcEjWD0ge0+HPtapZoCOUZe7Msg5Ie+y3YV8eXHGB7nceUi2uhEEmgODvyv0a3xuPRQPsI3ODgTAGq2ijsL9haskxGErweT/MLsd1EKXlCZ3vN+2HCUtHUElnVTg/7A0Luh/QesASYE3uaOOYYeTtJwpbqdJKylbufZBxXJ8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.co.jp; dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b=JCzkD8PA; arc=none smtp.client-ip=207.171.190.10
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.co.jp
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="JCzkD8PA"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1718647167; x=1750183167;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=cyr40ZYKbs+9RQg+CBiTJjuDFxvMBR/t/WbaK149Hso=;
  b=JCzkD8PAvcIU07keM0nA8yjDK7KieDGUTpd8S1iQVnGbmucKOsHEOjQ3
   owLGVT8oxD2Y1lS24hZMXHxc0LkpeaU/A4s/QcJBLcNQWFpa1LsxSXXcX
   t9daHhpMLf8NdESO3IFoDwavpILMnuBp2MuaiPbZv9xVKszEUJK1AUUvT
   c=;
X-IronPort-AV: E=Sophos;i="6.08,245,1712620800"; 
   d="scan'208";a="350790092"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev) ([10.43.8.6])
  by smtp-border-fw-33001.sea14.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 17 Jun 2024 17:59:20 +0000
Received: from EX19MTAUWC002.ant.amazon.com [10.0.21.151:40873]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.22.54:2525] with esmtp (Farcaster)
 id 4d10abfa-6a97-40fd-9836-5ca99ad9f469; Mon, 17 Jun 2024 17:59:19 +0000 (UTC)
X-Farcaster-Flow-ID: 4d10abfa-6a97-40fd-9836-5ca99ad9f469
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWC002.ant.amazon.com (10.250.64.143) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.34;
 Mon, 17 Jun 2024 17:59:18 +0000
Received: from 88665a182662.ant.amazon.com (10.187.171.38) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1258.34; Mon, 17 Jun 2024 17:59:15 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: <luoxuanqiang@kylinos.cn>
CC: <alexandre.ferrieux@orange.com>, <davem@davemloft.net>,
	<dccp@vger.kernel.org>, <dsahern@kernel.org>, <edumazet@google.com>,
	<fw@strlen.de>, <kuba@kernel.org>, <kuniyu@amazon.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>, <pabeni@redhat.com>
Subject: Re: [PATCH net v3] Fix race for duplicate reqsk on identical SYN
Date: Mon, 17 Jun 2024 10:59:07 -0700
Message-ID: <20240617175907.60655-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20240617075640.207570-1-luoxuanqiang@kylinos.cn>
References: <20240617075640.207570-1-luoxuanqiang@kylinos.cn>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: EX19D041UWB004.ant.amazon.com (10.13.139.143) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)

From: luoxuanqiang <luoxuanqiang@kylinos.cn>
Date: Mon, 17 Jun 2024 15:56:40 +0800
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
> In the tcp_conn_request(), while inserting reqsk into the ehash table,
> it also checks if an entry already exists. If found, it avoids
> reinsertion and releases it.
> 
> Simultaneously, In the reqsk_queue_hash_req(), the start of the
> req->rsk_timer is adjusted to be after successful insertion.
> 
> Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>
> ---
>  include/net/inet_connection_sock.h |  4 ++--
>  net/dccp/ipv4.c                    |  2 +-
>  net/dccp/ipv6.c                    |  2 +-
>  net/ipv4/inet_connection_sock.c    | 19 +++++++++++++------
>  net/ipv4/tcp_input.c               |  9 ++++++++-
>  5 files changed, 25 insertions(+), 11 deletions(-)
> 
> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_connection_sock.h
> index 7d6b1254c92d..8ebab6220dbc 100644
> --- a/include/net/inet_connection_sock.h
> +++ b/include/net/inet_connection_sock.h
> @@ -263,8 +263,8 @@ struct dst_entry *inet_csk_route_child_sock(const struct sock *sk,
>  struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
>  				      struct request_sock *req,
>  				      struct sock *child);
> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> -				   unsigned long timeout);
> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> +				   unsigned long timeout, bool *found_dup_sk);
>  struct sock *inet_csk_complete_hashdance(struct sock *sk, struct sock *child,
>  					 struct request_sock *req,
>  					 bool own_req);
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index ff41bd6f99c3..13aafdeb9205 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -657,7 +657,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
>  	if (dccp_v4_send_response(sk, req))
>  		goto drop_and_free;
>  
> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
>  	reqsk_put(req);
>  	return 0;
>  
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 85f4b8fdbe5e..493cdb12ce2b 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -400,7 +400,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
>  	if (dccp_v6_send_response(sk, req))
>  		goto drop_and_free;
>  
> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
>  	reqsk_put(req);
>  	return 0;
>  
> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
> index d81f74ce0f02..2fa9b33ae26a 100644
> --- a/net/ipv4/inet_connection_sock.c
> +++ b/net/ipv4/inet_connection_sock.c
> @@ -1122,25 +1122,32 @@ static void reqsk_timer_handler(struct timer_list *t)
>  	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
>  }
>  
> -static void reqsk_queue_hash_req(struct request_sock *req,
> -				 unsigned long timeout)
> +static bool reqsk_queue_hash_req(struct request_sock *req,
> +				 unsigned long timeout, bool *found_dup_sk)
>  {

Given any changes here in reqsk_queue_hash_req() conflicts with 4.19
(oldest stable) and DCCP does not check found_dup_sk, you can define
found_dup_sk here, then you need not touch DCCP at all.


> +	if (!inet_ehash_insert(req_to_sk(req), NULL, found_dup_sk))
> +		return false;
> +
> +	/* The timer needs to be setup after a successful insertion. */
>  	timer_setup(&req->rsk_timer, reqsk_timer_handler, TIMER_PINNED);
>  	mod_timer(&req->rsk_timer, jiffies + timeout);
>  
> -	inet_ehash_insert(req_to_sk(req), NULL, NULL);
>  	/* before letting lookups find us, make sure all req fields
>  	 * are committed to memory and refcnt initialized.
>  	 */
>  	smp_wmb();
>  	refcount_set(&req->rsk_refcnt, 2 + 1);
> +	return true;
>  }
>  
> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> -				   unsigned long timeout)
> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock *req,
> +				   unsigned long timeout, bool *found_dup_sk)
>  {
> -	reqsk_queue_hash_req(req, timeout);
> +	if (!reqsk_queue_hash_req(req, timeout, found_dup_sk))
> +		return false;
> +
>  	inet_csk_reqsk_queue_added(sk);
> +	return true;
>  }
>  EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
>  
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 9c04a9c8be9d..e006c374f781 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -7255,8 +7255,15 @@ int tcp_conn_request(struct request_sock_ops *rsk_ops,
>  	} else {
>  		tcp_rsk(req)->tfo_listener = false;
>  		if (!want_cookie) {
> +			bool found_dup_sk = false;
> +
>  			req->timeout = tcp_timeout_init((struct sock *)req);
> -			inet_csk_reqsk_queue_hash_add(sk, req, req->timeout);
> +			if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, req->timeout,
> +								    &found_dup_sk))) {
> +				reqsk_free(req);
> +				return 0;
> +			}
> +
>  		}
>  		af_ops->send_synack(sk, dst, &fl, req, &foc,
>  				    !want_cookie ? TCP_SYNACK_NORMAL :
> -- 
> 2.25.1
