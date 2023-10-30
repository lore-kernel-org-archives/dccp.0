Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B15A1B264;
	Mon, 30 Oct 2023 20:12:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="DzSo2njk"
Received: from smtp-fw-9105.amazon.com (smtp-fw-9105.amazon.com [207.171.188.204])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0A257EE;
	Mon, 30 Oct 2023 13:12:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1698696727; x=1730232727;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=6D8jozM7hlxpoJDs8NW6wHWs2AyXFU+odsgu2PbgbLc=;
  b=DzSo2njk/iZMiGzt9Fq7R4MQFkeliIPyruP4B3iLHAornjbnuT0QLy1p
   Wafvp6wwaUj9tRbTUxXlvtue67IJHokHQOUMUdOJxAoVAVS4Vv37nYVu2
   3ukbceLLDsqc5XiTU5ZqQP8X3KL86IlLfE2JkWiKpKFBPH3MJLgyOwTxP
   g=;
X-IronPort-AV: E=Sophos;i="6.03,264,1694736000"; 
   d="scan'208";a="681869741"
Received: from pdx4-co-svc-p1-lb2-vlan2.amazon.com (HELO email-inbound-relay-iad-1a-m6i4x-54a853e6.us-east-1.amazon.com) ([10.25.36.210])
  by smtp-border-fw-9105.sea19.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 30 Oct 2023 20:12:00 +0000
Received: from smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev (iad7-ws-svc-p70-lb3-vlan3.iad.amazon.com [10.32.235.38])
	by email-inbound-relay-iad-1a-m6i4x-54a853e6.us-east-1.amazon.com (Postfix) with ESMTPS id ABF7448A83;
	Mon, 30 Oct 2023 20:11:56 +0000 (UTC)
Received: from EX19MTAUWB002.ant.amazon.com [10.0.38.20:9222]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.17.46:2525] with esmtp (Farcaster)
 id b6ce74ca-60c7-4fa5-a2de-c6acfb0b2ea1; Mon, 30 Oct 2023 20:11:55 +0000 (UTC)
X-Farcaster-Flow-ID: b6ce74ca-60c7-4fa5-a2de-c6acfb0b2ea1
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWB002.ant.amazon.com (10.250.64.231) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.39; Mon, 30 Oct 2023 20:11:48 +0000
Received: from 88665a182662.ant.amazon.com (10.187.171.32) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.39; Mon, 30 Oct 2023 20:11:45 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: "David S. Miller" <davem@davemloft.net>, Eric Dumazet
	<edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni
	<pabeni@redhat.com>, David Ahern <dsahern@kernel.org>
CC: Kuniyuki Iwashima <kuniyu@amazon.com>, Kuniyuki Iwashima
	<kuni1840@gmail.com>, <netdev@vger.kernel.org>, <dccp@vger.kernel.org>, "Huw
 Davies" <huw@codeweavers.com>, Paul Moore <paul@paul-moore.com>
Subject: [PATCH v1 net 2/2] dccp/tcp: Call security_inet_conn_request() after setting IPv6 addresses.
Date: Mon, 30 Oct 2023 13:10:42 -0700
Message-ID: <20231030201042.32885-3-kuniyu@amazon.com>
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
X-ClientProxiedBy: EX19D043UWC002.ant.amazon.com (10.13.139.222) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)
Precedence: Bulk

Initially, commit 4237c75c0a35 ("[MLSXFRM]: Auto-labeling of child
sockets") introduced security_inet_conn_request() in some functions
where reqsk is allocated.  The hook is added just after the allocation,
so reqsk's IPv6 remote address was not initialised then.

However, SELinux/Smack started to read it in netlbl_req_setattr()
after commit e1adea927080 ("calipso: Allow request sockets to be
relabelled by the lsm.").

Commit 284904aa7946 ("lsm: Relocate the IPv4 security_inet_conn_request()
hooks") fixed that kind of issue only in TCPv4 because IPv6 labeling was
not supported at that time.  Finally, the same issue was introduced again
in IPv6.

Let's apply the same fix on DCCPv6 and TCPv6.

Fixes: e1adea927080 ("calipso: Allow request sockets to be relabelled by the lsm.")
Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
---
Cc: Huw Davies <huw@codeweavers.com>
Cc: Paul Moore <paul@paul-moore.com>
---
 net/dccp/ipv6.c       | 6 +++---
 net/ipv6/syncookies.c | 7 ++++---
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 8d344b219f84..4550b680665a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -360,15 +360,15 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (dccp_parse_options(sk, dreq, skb))
 		goto drop_and_free;
 
-	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_free;
-
 	ireq = inet_rsk(req);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
 	ireq->ireq_family = AF_INET6;
 	ireq->ir_mark = inet_request_mark(sk, skb);
 
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
 	if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 500f6ed3b8cf..12eedc6ca2cc 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -181,14 +181,15 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	treq = tcp_rsk(req);
 	treq->tfo_listener = false;
 
-	if (security_inet_conn_request(sk, skb, req))
-		goto out_free;
-
 	req->mss = mss;
 	ireq->ir_rmt_port = th->source;
 	ireq->ir_num = ntohs(th->dest);
 	ireq->ir_v6_rmt_addr = ipv6_hdr(skb)->saddr;
 	ireq->ir_v6_loc_addr = ipv6_hdr(skb)->daddr;
+
+	if (security_inet_conn_request(sk, skb, req))
+		goto out_free;
+
 	if (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
 	    np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
-- 
2.30.2

