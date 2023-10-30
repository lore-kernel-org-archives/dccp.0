Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 31CAA13AC4;
	Mon, 30 Oct 2023 20:11:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="EP0xRikK"
Received: from smtp-fw-52005.amazon.com (smtp-fw-52005.amazon.com [52.119.213.156])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5E155D3;
	Mon, 30 Oct 2023 13:11:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1698696664; x=1730232664;
  h=from:to:cc:subject:date:message-id:mime-version:
   content-transfer-encoding;
  bh=D3Jh+SR1ZYTwMpsUDhRRd92Ci4zuiw6RJYP/0IeoWi0=;
  b=EP0xRikKSlt1dgYm5B48g0NuGJmBcK64/Jutv7Cjt0OvOkBUA+1o6vMI
   THKxaaowFVMQA00eQz/1AV/PwgruzKnBwn1sKdo+QkIvPRlLaXbH//ufX
   Co395oZtmijNU3/JjcVHvfQrVPvuuo4dOsEbtkelir0d7OjqPqpyXS4Ou
   s=;
X-IronPort-AV: E=Sophos;i="6.03,264,1694736000"; 
   d="scan'208";a="613161745"
Received: from iad12-co-svc-p1-lb1-vlan3.amazon.com (HELO email-inbound-relay-pdx-2a-m6i4x-d47337e0.us-west-2.amazon.com) ([10.43.8.6])
  by smtp-border-fw-52005.iad7.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 30 Oct 2023 20:11:02 +0000
Received: from smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev (pdx2-ws-svc-p26-lb5-vlan3.pdx.amazon.com [10.39.38.70])
	by email-inbound-relay-pdx-2a-m6i4x-d47337e0.us-west-2.amazon.com (Postfix) with ESMTPS id 06A7160E0F;
	Mon, 30 Oct 2023 20:10:59 +0000 (UTC)
Received: from EX19MTAUWC002.ant.amazon.com [10.0.38.20:33100]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.52.67:2525] with esmtp (Farcaster)
 id a3f79a5b-e1bf-4e8f-b991-1d7d5ea79bb5; Mon, 30 Oct 2023 20:10:59 +0000 (UTC)
X-Farcaster-Flow-ID: a3f79a5b-e1bf-4e8f-b991-1d7d5ea79bb5
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWC002.ant.amazon.com (10.250.64.143) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1118.39; Mon, 30 Oct 2023 20:10:59 +0000
Received: from 88665a182662.ant.amazon.com (10.187.171.32) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1118.39;
 Mon, 30 Oct 2023 20:10:56 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: "David S. Miller" <davem@davemloft.net>, Eric Dumazet
	<edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, Paolo Abeni
	<pabeni@redhat.com>, David Ahern <dsahern@kernel.org>
CC: Kuniyuki Iwashima <kuniyu@amazon.com>, Kuniyuki Iwashima
	<kuni1840@gmail.com>, <netdev@vger.kernel.org>, <dccp@vger.kernel.org>
Subject: [PATCH v1 net 0/2] dccp/tcp: Relocate security_inet_conn_request().
Date: Mon, 30 Oct 2023 13:10:40 -0700
Message-ID: <20231030201042.32885-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.30.2
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-Originating-IP: [10.187.171.32]
X-ClientProxiedBy: EX19D045UWC002.ant.amazon.com (10.13.139.230) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)
Precedence: Bulk

security_inet_conn_request() reads reqsk's remote address, but it's not
initialised in some places.

Let's make sure the address is set before security_inet_conn_request().


Kuniyuki Iwashima (2):
  dccp: Call security_inet_conn_request() after setting IPv4 addresses.
  dccp/tcp: Call security_inet_conn_request() after setting IPv6
    addresses.

 net/dccp/ipv4.c       | 6 +++---
 net/dccp/ipv6.c       | 6 +++---
 net/ipv6/syncookies.c | 7 ++++---
 3 files changed, 10 insertions(+), 9 deletions(-)

-- 
2.30.2

