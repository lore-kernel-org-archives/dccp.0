Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D69792F4A;
	Mon, 30 Oct 2023 20:11:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="EZZYnn8z"
Received: from smtp-fw-33001.amazon.com (smtp-fw-33001.amazon.com [207.171.190.10])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id DD8C9D3;
	Mon, 30 Oct 2023 13:11:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1698696694; x=1730232694;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=8H7Tc7BgK67YLBbUNVmarHEeDwDPzX6Fl+1zmS9igDw=;
  b=EZZYnn8zPxQTkFyrEweep7CbV5LXtMTw81XPZBfslCL7MYvPM7vdNAAT
   pKHA/tH3rbIQELhvCjpZX52UWInI+gKW1qid33GSKf8DDO+n21vLkrNOm
   9AsWTSw2bhwvTLAhv4qmjgad2vk0hKsQpKJoJ4g9Cv7HkbFLAnvd7iOXL
   g=;
X-IronPort-AV: E=Sophos;i="6.03,264,1694736000"; 
   d="scan'208";a="311005798"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-pdx-2b-m6i4x-f323d91c.us-west-2.amazon.com) ([10.43.8.6])
  by smtp-border-fw-33001.sea14.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 30 Oct 2023 20:11:27 +0000
Received: from smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev (pdx2-ws-svc-p26-lb5-vlan2.pdx.amazon.com [10.39.38.66])
	by email-inbound-relay-pdx-2b-m6i4x-f323d91c.us-west-2.amazon.com (Postfix) with ESMTPS id 125BC40D87;
	Mon, 30 Oct 2023 20:11:25 +0000 (UTC)
Received: from EX19MTAUWC001.ant.amazon.com [10.0.7.35:46380]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.48.150:2525] with esmtp (Farcaster)
 id a2212cfa-7106-4c6a-9c98-047b53dc47e2; Mon, 30 Oct 2023 20:11:24 +0000 (UTC)
X-Farcaster-Flow-ID: a2212cfa-7106-4c6a-9c98-047b53dc47e2
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWC001.ant.amazon.com (10.250.64.174) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.39; Mon, 30 Oct 2023 20:11:24 +0000
Received: from 88665a182662.ant.amazon.com (10.187.171.32) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1118.39;
 Mon, 30 Oct 2023 20:11:21 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: "David S. Miller" <davem@davemloft.net>, Eric Dumazet
	<edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni
	<pabeni@redhat.com>, David Ahern <dsahern@kernel.org>
CC: Kuniyuki Iwashima <kuniyu@amazon.com>, Kuniyuki Iwashima
	<kuni1840@gmail.com>, <netdev@vger.kernel.org>, <dccp@vger.kernel.org>,
	"James Morris" <jmorris@namei.org>, Casey Schaufler <casey@schaufler-ca.com>,
	"Paul Moore" <paul.moore@hp.com>
Subject: [PATCH v1 net 1/2] dccp: Call security_inet_conn_request() after setting IPv4 addresses.
Date: Mon, 30 Oct 2023 13:10:41 -0700
Message-ID: <20231030201042.32885-2-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20231030201042.32885-1-kuniyu@amazon.com>
References: <20231030201042.32885-1-kuniyu@amazon.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.187.171.32]
X-ClientProxiedBy: EX19D036UWB001.ant.amazon.com (10.13.139.133) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)
Precedence: Bulk

Initially, commit 4237c75c0a35 ("[MLSXFRM]: Auto-labeling of child
sockets") introduced security_inet_conn_request() in some functions
where reqsk is allocated.  The hook is added just after the allocation,
so reqsk's IPv4 remote address was not initialised then.

However, SELinux/Smack started to read it in netlbl_req_setattr()
after the cited commits.

This bug was partially fixed by commit 284904aa7946 ("lsm: Relocate
the IPv4 security_inet_conn_request() hooks").

This patch fixes the last bug in DCCPv4.

Fixes: 389fb800ac8b ("netlabel: Label incoming TCP connections correctly in SELinux")
Fixes: 07feee8f812f ("netlabel: Cleanup the Smack/NetLabel code to fix incoming TCP connections")
Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
---
Cc: James Morris <jmorris@namei.org>
Cc: Casey Schaufler <casey@schaufler-ca.com>
Cc: Paul Moore <paul.moore@hp.com>
---
 net/dccp/ipv4.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 1b8cbfda6e5d..44b033fe1ef6 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -629,9 +629,6 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (dccp_parse_options(sk, dreq, skb))
 		goto drop_and_free;
 
-	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_free;
-
 	ireq = inet_rsk(req);
 	sk_rcv_saddr_set(req_to_sk(req), ip_hdr(skb)->daddr);
 	sk_daddr_set(req_to_sk(req), ip_hdr(skb)->saddr);
@@ -639,6 +636,9 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq->ireq_family = AF_INET;
 	ireq->ir_iif = READ_ONCE(sk->sk_bound_dev_if);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	/*
 	 * Step 3: Process LISTEN state
 	 *
-- 
2.30.2

