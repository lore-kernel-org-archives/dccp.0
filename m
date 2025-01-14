Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB5051C5F0F
	for <dccp@vger.kernel.org>; Tue, 14 Jan 2025 15:46:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736869599; cv=none; b=Uwwwlq9yDezZvBGavf1UEh/KJPt0d1XkZ7DrGUKZ+qw3oxCh7AIfxU5+wNLKG5b4upt1Px1vSIRqlMBSMRNGZLMUpHk9JDMuIUU+f/6uj9IkWVxUB/DkUOnDJDnzRMpi5dClxtjEEiUt+4sh9vPB9/1lI4vdO3UNiyawUWoxMjs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736869599; c=relaxed/simple;
	bh=YPFt6wUJJC5pPILa0gzfWxx1NsQS2SQwGNEkDjpfGGE=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=JHcT0QlrfiVjFmtnbUPmVtzZ8G6stRGfqpp2v19qR6cIfVA5Qizrbs6BnP1xlaIsNG44KIsYR6eKpEYjUTT4riWsqDgoCF3n+uJcslsUVYv9JHh67Iq/EQRlbK6FxyiLOTePSQZE/y77Id2sQ3Y8jvcJ5Xix6JkE7lwdpRLIiOY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=h9s5/Rof; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="h9s5/Rof"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1736869596;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type;
	bh=lqExpISUo9kBV514pBmRFCi52CHAz7eKG3GfZ+jcKIQ=;
	b=h9s5/Rof/sjXeKvm+ywS6S7UN/gkw5LtaI5HXaYh1uaqCoMd4A/trn6E+z9BLMQbuAk4DV
	p7m9JQpn2Vc2VHWz6b+OnxPxY+RQf2DWcHg+lvf2SmZLYokA0afmvVHymZb9I2uUP3Iqox
	umtJm77aDkmt46YhK78tEzGp1a3QeRs=
Received: from mail-wm1-f69.google.com (mail-wm1-f69.google.com
 [209.85.128.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-659-xX2GiOouNFOnETcW_s2ZDw-1; Tue, 14 Jan 2025 10:46:35 -0500
X-MC-Unique: xX2GiOouNFOnETcW_s2ZDw-1
X-Mimecast-MFC-AGG-ID: xX2GiOouNFOnETcW_s2ZDw
Received: by mail-wm1-f69.google.com with SMTP id 5b1f17b1804b1-43626224274so31766425e9.0
        for <dccp@vger.kernel.org>; Tue, 14 Jan 2025 07:46:35 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1736869594; x=1737474394;
        h=content-disposition:mime-version:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=lqExpISUo9kBV514pBmRFCi52CHAz7eKG3GfZ+jcKIQ=;
        b=iXofGDWxuUch9hZ+Y1Ytcx8GH9aCXema98axbS4EcnuBSajRjTwOyLzGhN6PR5En9I
         biTZOrfx7zhedozqXRov5KuluY7ThB8inNE6gtUN6HUIPM+0WfbIY2pGUjL/p6a2MHv8
         X5k0mG6Eu1Rm7KqKAwl2l1TXR963d+Lo9ds5ang9QR/GA1El0yrl/iIHBlhZzAsjX0HW
         56C6dnXq2xOg6EqipNatd3BwzEarEbgrgAbF5vBN5RnJYYfNCmfaI+Mn6BblBAi6tDXi
         j63FAw114aYe+K7qkGv3jJ9OwpmQju6lR22AtEpF6WkEOyd5l79GDczcz5+D9UIGKIbY
         lEVQ==
X-Forwarded-Encrypted: i=1; AJvYcCWUzJE9Dxetx8/p4l+2eXW+Ex0t3SoAc1XzAdah9DHP1+GbW3tipyiUEAe4UBa4SfXvnQ+2@vger.kernel.org
X-Gm-Message-State: AOJu0YyQI9MaGKQdhM20pM2IcNIr+gtN631qxYOQ1v1Q4/dPzWNbVG+S
	R0T1MqAVV9XjMcZ6Rl4LsQNq6q/A4pl3ytP1sjmE/Ey5kW3hOno2kLaxvpyWELq0BxXWKIcLUvA
	u7B3YyJsHBB9VjffeZVYaXiFUyT95j4TFx7az0ySVkz1wj/Vi/Vc=
X-Gm-Gg: ASbGncs7eu8jA1a9zY2b9A1kPrLE9E+8iFWeNwYdowjXqWJ3/B5l0gaC6warnFMHlty
	AENh9FGMlTgmcA+OiCZpRV6eSgFzWooPC/uV14FYRb9p/dPkHjwaBk5lCFQDysY4DUdvMSDbBBn
	T+qqSKEiwb1wFSvL9rwlYs38e+o58hUqk7WPOk4/R7RKdpCPsDQQwBg4Zvw7UyVTI44DvOuOi2h
	XmB2HiEd/QveZMFTioBfDZRHNiOrIdVS2o7NTKM766ugNtYGvM8BHnIRGyGtpgaNXET6nnztTwW
	BdcPOfcfn0nzBtDdMSmwD9oGVxFuq5bYLbM=
X-Received: by 2002:a05:600c:871b:b0:434:f297:8e85 with SMTP id 5b1f17b1804b1-436e26932eamr261706175e9.10.1736869594348;
        Tue, 14 Jan 2025 07:46:34 -0800 (PST)
X-Google-Smtp-Source: AGHT+IEVmSDDf289FWxt/JNttv8t/lfiQJL5J7l3+j9uC1dvGH81nOyFgXSOA6srZBtB/cbPyVinbA==
X-Received: by 2002:a05:600c:871b:b0:434:f297:8e85 with SMTP id 5b1f17b1804b1-436e26932eamr261705885e9.10.1736869594018;
        Tue, 14 Jan 2025 07:46:34 -0800 (PST)
Received: from debian (2a01cb058d23d60010f10d4cace4e3dd.ipv6.abo.wanadoo.fr. [2a01:cb05:8d23:d600:10f1:d4c:ace4:e3dd])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-436e2e89ca5sm214108555e9.29.2025.01.14.07.46.33
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 14 Jan 2025 07:46:33 -0800 (PST)
Date: Tue, 14 Jan 2025 16:46:31 +0100
From: Guillaume Nault <gnault@redhat.com>
To: David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, Eric Dumazet <edumazet@google.com>
Cc: netdev@vger.kernel.org, Simon Horman <horms@kernel.org>,
	dccp@vger.kernel.org, Ido Schimmel <idosch@nvidia.com>
Subject: [PATCH net-next] dccp: Prepare dccp_v4_route_skb() to .flowi4_tos
 conversion.
Message-ID: <ed399406a6ffad5097fa618c3bc7a4ac59546c62.1736869543.git.gnault@redhat.com>
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
of fl4->flowi4_tos to dscp_t, as it will just require to drop the
inet_dscp_to_dsfield() call.

Signed-off-by: Guillaume Nault <gnault@redhat.com>
---
 net/dccp/ipv4.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 5926159a6f20..9e64dbd38cd7 100644
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
+		.flowi4_tos = inet_dscp_to_dsfield(inet_sk_dscp((inet_sk(sk)))),
 		.flowi4_scope = ip_sock_rt_scope(sk),
 		.flowi4_proto = sk->sk_protocol,
 		.fl4_sport = dccp_hdr(skb)->dccph_dport,
-- 
2.39.2

