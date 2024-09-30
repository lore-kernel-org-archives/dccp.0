Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr [192.134.164.83])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F3979190052;
	Mon, 30 Sep 2024 11:21:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=192.134.164.83
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1727695308; cv=none; b=tzlw2riSRuIda6JleYz5nGL2P/KFH8ITLVaD84n2yEE0hvXlOAG0/f+K8UkPtZ4Q9GO8XId9cOvMn6qNGIEscAoQ2n9SoQ/dHzHmB28PqrkUT8YtMRgWcrvDQli/q0NkKJgZx49j2C/t/G59TJ7uz9ajZoi8CUggtO/jsbuepNE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1727695308; c=relaxed/simple;
	bh=pLq3YOT6+rNHjYOPVLrgKEdscljtkQsbJ2htKr9ITqg=;
	h=From:To:Cc:Subject:Date:Message-Id:In-Reply-To:References:
	 MIME-Version; b=pcPT++bsgmBctQKn7htTdFsvoxJOR10oJcC9l6MMu0qzpyHaXAoDko4qumgby01hmiG4SDNn8xj5kOmN1As9oLekQT0dNeFXh+t0hpdxccx/zOyn1KjT9aOWYRJ777oz95isvW1JqBrJ2dttt8SFNGqxFLbSL4qUr/l1/WNcpJ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=inria.fr; spf=pass smtp.mailfrom=inria.fr; dkim=pass (1024-bit key) header.d=inria.fr header.i=@inria.fr header.b=lJFK0vOr; arc=none smtp.client-ip=192.134.164.83
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=inria.fr
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=inria.fr
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=inria.fr header.i=@inria.fr header.b="lJFK0vOr"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=inria.fr; s=dc;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=nWSmtARBk2gEHkUFa2bT2tPofkcYuwxfvTcgtvxT/uU=;
  b=lJFK0vOrS5fbWQcJGzSnI82bsXvhhboUYzhz+27wFj1HndtT1jdW/RKo
   cudYKM4L4K4LzaoL4iGHMmEBrKkm7m9GkpYOrbZYVBk/H0o6DKRAtN8m2
   3eOQfpu8wZljBWVMPZwGSGTbDJSQSEsJ3vDUlPEEGBErsEpZKryOfXUu4
   I=;
Authentication-Results: mail2-relais-roc.national.inria.fr; dkim=none (message not signed) header.i=none; spf=SoftFail smtp.mailfrom=Julia.Lawall@inria.fr; dmarc=fail (p=none dis=none) d=inria.fr
X-IronPort-AV: E=Sophos;i="6.11,165,1725314400"; 
   d="scan'208";a="185956881"
Received: from i80.paris.inria.fr (HELO i80.paris.inria.fr.) ([128.93.90.48])
  by mail2-relais-roc.national.inria.fr with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 30 Sep 2024 13:21:26 +0200
From: Julia Lawall <Julia.Lawall@inria.fr>
To: "David S. Miller" <davem@davemloft.net>
Cc: kernel-janitors@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	dccp@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 10/35] dccp: Reorganize kerneldoc parameter names
Date: Mon, 30 Sep 2024 13:20:56 +0200
Message-Id: <20240930112121.95324-11-Julia.Lawall@inria.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20240930112121.95324-1-Julia.Lawall@inria.fr>
References: <20240930112121.95324-1-Julia.Lawall@inria.fr>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Reorganize kerneldoc parameter names to match the parameter
order in the function header.

Problems identified using Coccinelle.

Signed-off-by: Julia Lawall <Julia.Lawall@inria.fr>

---
 net/dccp/feat.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/dccp/feat.c b/net/dccp/feat.c
index 54086bb05c42..90ac50556ee0 100644
--- a/net/dccp/feat.c
+++ b/net/dccp/feat.c
@@ -626,9 +626,9 @@ static u8 dccp_feat_sp_list_ok(u8 feat_num, u8 const *sp_list, u8 sp_len)
 
 /**
  * dccp_feat_insert_opts  -  Generate FN options from current list state
- * @skb: next sk_buff to be sent to the peer
  * @dp: for client during handshake and general negotiation
  * @dreq: used by the server only (all Changes/Confirms in LISTEN/RESPOND)
+ * @skb: next sk_buff to be sent to the peer
  */
 int dccp_feat_insert_opts(struct dccp_sock *dp, struct dccp_request_sock *dreq,
 			  struct sk_buff *skb)

