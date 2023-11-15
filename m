Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="F0Dlmms4"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2EFA919B4
	for <dccp@vger.kernel.org>; Wed, 15 Nov 2023 13:05:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1700082323;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=M/2ZyYZIlXaVrQ5H2NVMzh6RQkIaOQLrSYQoOoe/xlo=;
	b=F0Dlmms4Yw+39O81YmCnDUs1Hg+jcVQgntW75uAp8L3U33GgJSt0c8qXwy1h9/g/NNsCi0
	2v+wUf3+3xqEx6ZZEIntpfbsZFzmtPnCXYmkpWhcCwv5JHk/FpfnABm8AidRklVUJErrbD
	Y1767LE2u55tV4zpmSm3emfD8Hry1Bc=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-250-JizxYATBPXy1AFjmuMswsQ-1; Wed, 15 Nov 2023 16:05:20 -0500
X-MC-Unique: JizxYATBPXy1AFjmuMswsQ-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.rdu2.redhat.com [10.11.54.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id AC3D585A58B;
	Wed, 15 Nov 2023 21:05:19 +0000 (UTC)
Received: from vschneid-thinkpadt14sgen2i.remote.csb (unknown [10.22.34.128])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 604403D6;
	Wed, 15 Nov 2023 21:05:19 +0000 (UTC)
From: Valentin Schneider <vschneid@redhat.com>
To: dccp@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-rt-users@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	David Ahern <dsahern@kernel.org>,
	Juri Lelli <juri.lelli@redhat.com>,
	Tomas Glozar <tglozar@redhat.com>,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Thomas Gleixner <tglx@linutronix.de>
Subject: [PATCH v2 2/2] tcp/dcpp: Don't disable bh around timewait_sock initialization
Date: Wed, 15 Nov 2023 16:05:09 -0500
Message-ID: <20231115210509.481514-3-vschneid@redhat.com>
In-Reply-To: <20231115210509.481514-1-vschneid@redhat.com>
References: <20231115210509.481514-1-vschneid@redhat.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.1

Now that the tw_timer is armed *after* the hashdance, it is the last step
of the timewait initialization. We can thus enable softirqs without running
the risk of the timer handler running before the initialization is done.

This is conceptually a revert of
  cfac7f836a71 ("tcp/dccp: block bh before arming time_wait timer")

Signed-off-by: Valentin Schneider <vschneid@redhat.com>
---
 net/dccp/minisocks.c     | 4 ----
 net/ipv4/tcp_minisocks.c | 4 ----
 2 files changed, 8 deletions(-)

diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 2f0fad4255e36..cb990bc92a5c9 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -53,15 +53,11 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
 		if (state == DCCP_TIME_WAIT)
 			timeo = DCCP_TIMEWAIT_LEN;
 
-	       local_bh_disable();
-
 		// Linkage updates
 		inet_twsk_hashdance(tw, sk, &dccp_hashinfo);
 		inet_twsk_schedule(tw, timeo);
 		// Access to tw after this point is illegal.
 		inet_twsk_put(tw);
-
-		local_bh_enable();
 	} else {
 		/* Sorry, if we're out of memory, just CLOSE this
 		 * socket up.  We've got bigger problems than
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 48eb0310fe837..c7d46674d55cb 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -338,15 +338,11 @@ void tcp_time_wait(struct sock *sk, int state, int timeo)
 		if (state == TCP_TIME_WAIT)
 			timeo = TCP_TIMEWAIT_LEN;
 
-	       local_bh_disable();
-
 		// Linkage updates.
 		inet_twsk_hashdance(tw, sk, net->ipv4.tcp_death_row.hashinfo);
 		inet_twsk_schedule(tw, timeo);
 		// Access to tw after this point is illegal.
 		inet_twsk_put(tw);
-
-		local_bh_enable();
 	} else {
 		/* Sorry, if we're out of memory, just CLOSE this
 		 * socket up.  We've got bigger problems than
-- 
2.41.0

