Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B959E1DE4E1
	for <dccp@vger.kernel.org>; Thu, 16 Jan 2025 13:10:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737033024; cv=none; b=CJb2Sed40QAl1rjbArdgyLN4QTsQrmI1YBgr8SlFpEkXTWN1mlYqEFfJsHl7Vi72/tBIGQCnzRe3M5qs6pQlwMZNs4gCFkWevr58LFZL+AFXYtJWM7s+n86u9Z1wsEgNI9I0ZJbaEWIkEiFMViSw28UI/wcazhTHtfGqnNVMKAY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737033024; c=relaxed/simple;
	bh=XbtJDtjO1AzzG13YQ31Gos6JOzfzGVg68mtNqGPC6QM=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=CkDzQUb/0hgosIyZqEQ2VjBxot/goFUCLUvFmlMPPJWA4De3FPE9qt7wgN53yDPIpitj5wsmR+OEnoslJrlrms/WZC7H16TFVspVN488ITwBr1XW8j366eDtYkTmVE0j9j1yixz5+XsvBAK9ZcltP2YCTGYvbA3RGmhLVYiX5JI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=C5/Djge/; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="C5/Djge/"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1737033021;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type;
	bh=JMPXd/pIK34W8GzTwNPr5mzD4lfJU0TtT5BZPeG/Q94=;
	b=C5/Djge/sWw5tETOj1tfSs/UrJG3wttAhff2JlOrgfc8PKtoPDbO7t+EuS+OHP8t6mTkgB
	JZP4APYeiyJqBc4j4HIEYlvo38mksAWfAaSAkROu+DPMP3p8zqri6/S5BYWbLUe4do9V2b
	0xSkh2SX07chdWPgsbw/rWzT6SC21Yg=
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com
 [209.85.221.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-441-f1N_jD-WM06eSHfLTQRXAw-1; Thu, 16 Jan 2025 08:10:20 -0500
X-MC-Unique: f1N_jD-WM06eSHfLTQRXAw-1
X-Mimecast-MFC-AGG-ID: f1N_jD-WM06eSHfLTQRXAw
Received: by mail-wr1-f69.google.com with SMTP id ffacd0b85a97d-3862c67763dso357774f8f.3
        for <dccp@vger.kernel.org>; Thu, 16 Jan 2025 05:10:19 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1737033019; x=1737637819;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=JMPXd/pIK34W8GzTwNPr5mzD4lfJU0TtT5BZPeG/Q94=;
        b=nprfQEvbF6y8pfTBhCb73PsNkJ0BsEknS3m8bqRBwJ/YMEatalHJQ+Hm74Bw5xB/Yo
         jYw4B3+DwfNakkaAi3dkCFGLhcsU4cSqdD9AyoPRmplIpMuVTkMy/wW228XYkUNZVTXG
         ul0LGCF5akPMIOSgBCD6AiAHr3zXtYyjPGue8WAB7gifpwyKc2t1DRTdfC+uQcHr5KJ9
         0+NJO7Gd2pz+6r1mr7GhnOgmLFtYuRSXaaeotHBhR4hUQNCwNcWyx0i/N8xAmv/+HGWc
         cjQTnggpSG5S0ukq24GAHBPbfV41kZEvwKtcfsjRaG6q4kKpEuiqPpmx9EYQXkPm+Br+
         fGxA==
X-Forwarded-Encrypted: i=1; AJvYcCUd7CTVQDd4upp7JBDNhvnR2WLCwedptyWmLUSfvIDSE4rjeo1SWVymJmBsFGYWmi3aU1r8@vger.kernel.org
X-Gm-Message-State: AOJu0YxWRDh1iXAaBOzenKrcWWLV9LGOdBSiU62xPEISFX3kn/RGol/Y
	8QVW11H4RbfGfym/ToJclMRgzEXEVoRnNyZHCMpgfKs+w0EuSFo4LAtn2AOVhtFZW3sN0pY5+uU
	AaqEq6Ce8Js/PGVtRpuam/hOP3NpBbXXti+JTOYGK9V9MBDMGEcE=
X-Gm-Gg: ASbGncuLegVK/eMjwY2TSwIQJYALG6M3gqHCx9vmuWOcEkrvijjZ7hiTqwOUTs0uaCP
	CLwrJCjQE7lAUjnmyircBZ5PESZWrLTsO4IqycXabp4juyNTi36KbxfWa9WMHt+Wzt65AEYurZ+
	6YIxgDJdTZAP0nnkMfR6dRoDuu+WqOTGFsoEhtcqNvGusfPEta+sLkZqXZFlyrIXo/cl8QemWvp
	LJz4tKQK++U0TjzQihcRvNjP909AyKWJhEE0k/h5fK5ni6CKfxYA80t+hY8vX2Kt6NxOuOhJfE3
	4PgcXX+F+6fCi2psZy7Drnq0MfBQga20zpOp
X-Received: by 2002:a05:6000:4023:b0:38b:e32a:10aa with SMTP id ffacd0b85a97d-38be32a12eemr8987430f8f.5.1737033018918;
        Thu, 16 Jan 2025 05:10:18 -0800 (PST)
X-Google-Smtp-Source: AGHT+IEwi6LQc4eWIr5l+YO7NdD5PedD20B7qjjCk+VK8z5YlzJYCUasg2J7ErNEJGNePlHHtcGpPQ==
X-Received: by 2002:a05:6000:4023:b0:38b:e32a:10aa with SMTP id ffacd0b85a97d-38be32a12eemr8987402f8f.5.1737033018549;
        Thu, 16 Jan 2025 05:10:18 -0800 (PST)
Received: from debian (2a01cb058d23d60074daf58b34fd2b3c.ipv6.abo.wanadoo.fr. [2a01:cb05:8d23:d600:74da:f58b:34fd:2b3c])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-38bea3c2344sm3095668f8f.70.2025.01.16.05.10.17
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 16 Jan 2025 05:10:17 -0800 (PST)
Date: Thu, 16 Jan 2025 14:10:16 +0100
From: Guillaume Nault <gnault@redhat.com>
To: David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Eric Dumazet <edumazet@google.com>
Cc: netdev@vger.kernel.org, Simon Horman <horms@kernel.org>,
	dccp@vger.kernel.org, Ido Schimmel <idosch@nvidia.com>
Subject: [PATCH net-next v2] dccp: Prepare dccp_v4_route_skb() to .flowi4_tos
 conversion.
Message-ID: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Use inet_sk_dscp() to get the socket DSCP value as dscp_t, instead of
ip_sock_rt_tos() which returns a __u8. This will ease the conversion
of fl4->flowi4_tos to dscp_t, which now just becomes a matter of
dropping the inet_dscp_to_dsfield() call.

Signed-off-by: Guillaume Nault <gnault@redhat.com>
---
v2: Remove useless parenthesis (Eric).
    Slightly reword the commit message for clarity.

 net/dccp/ipv4.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5926159a6f20..be515ba821e2 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -15,6 +15,7 @@
 
 #include <net/icmp.h>
 #include <net/inet_common.h>
+#include <net/inet_dscp.h>
 #include <net/inet_hashtables.h>
 #include <net/inet_sock.h>
 #include <net/protocol.h>
@@ -473,7 +474,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
 		.flowi4_oif = inet_iif(skb),
 		.daddr = iph->saddr,
 		.saddr = iph->daddr,
-		.flowi4_tos = ip_sock_rt_tos(sk),
+		.flowi4_tos = inet_dscp_to_dsfield(inet_sk_dscp(inet_sk(sk))),
 		.flowi4_scope = ip_sock_rt_scope(sk),
 		.flowi4_proto = sk->sk_protocol,
 		.fl4_sport = dccp_hdr(skb)->dccph_dport,
-- 
2.39.2

