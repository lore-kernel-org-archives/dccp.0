Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 71FD32139D3
	for <dccp@vger.kernel.org>; Tue, 14 Jan 2025 22:32:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736893964; cv=none; b=XkNQVJ0fwU/b668gXrP+gYDtgtNp6Pd8WKYaQ/AShpJeTeRBZpa0CJlSNerKljgC9vwnjJzdCxeI4AE05z+e+6k2NEsHruU0f62LzvCu5yS+1BFb3gPkHflEGJfhM0p5LRfoiiwxCn12aYKdsw8wP+EHpNu/IqzOhK87MV1pW+I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736893964; c=relaxed/simple;
	bh=No1AcZLmMDHHDap7hoIvBaYgEv6potLO0+VvXeobTsQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=e9VqJPD4wHy3V8g1FmTiPt1sdFyhxDcMWH9i8e9ijwnFFIN7FiiDfaeDxUgYbh4HyeKwQPw321yOR3zEgNTZ4r9PozcdPhLBSnGGftHNbb4Xx/GhC6znzzZjYzprTpEbVvUq1H2dPEGLZUiAXAqAVr5tW9MaF1d+P8GrPjebTHc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=P/Mx5fPn; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="P/Mx5fPn"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1736893960;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=cXzL1vV65DpnrZV/iKoCOHsa84AKRcCUDSn/2FoDiIY=;
	b=P/Mx5fPngLJIGxWgazAsSznxrDrj2zGjEZ4AypstxwxQkS1Ph4dVx4XTfkN3i/RMY9JNAB
	ueSTpsPJCs5cToo5PUgjObqS9HI6E61+tdJC0sBFssB+WtXGSSWn6CcHnERwzekH7tgd5m
	iijsKnPSPOBTVC3HjUigXPZS44Cnqpc=
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com
 [209.85.221.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-693-sFxncEAJPoSxMBOhzO7bvQ-1; Tue, 14 Jan 2025 17:32:37 -0500
X-MC-Unique: sFxncEAJPoSxMBOhzO7bvQ-1
X-Mimecast-MFC-AGG-ID: sFxncEAJPoSxMBOhzO7bvQ
Received: by mail-wr1-f71.google.com with SMTP id ffacd0b85a97d-38a9118c486so3732946f8f.1
        for <dccp@vger.kernel.org>; Tue, 14 Jan 2025 14:32:36 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1736893956; x=1737498756;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :mime-version:references:message-id:subject:cc:to:from:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=cXzL1vV65DpnrZV/iKoCOHsa84AKRcCUDSn/2FoDiIY=;
        b=q0YLsCPvHJX3N4s+ty2f44Opf8TuG8bfwUiKHT/cxeemFkhxYk2GYou+9MNvV1IGHW
         EH52zWcRWuiyavZ8y/7ITm/+5xowWDvllZsk3a44BoO9Eq8dHZYKJwjwRMMim5tk2v3j
         CuXFdYCKNo+d31oLn3haafH6K75pdAoAmCaZBdM0DMq6jsqxCV1heXk9aoYMdVuyo17s
         LfdJEXi3BtPFxNNkVMe/JwI0fPSYv8h82+f41sgrrH9/wwh5m+u/68AM+cZEar2cF5vy
         ++/vvA8Sjnw+drhsEQxKUCfqH4vxBxdhT9SAdVubAdiEhjFf7oSSN+7f6J+LQPjMk6G/
         AgtQ==
X-Forwarded-Encrypted: i=1; AJvYcCVkEASgdalHvgSyRSD0pVVZxaq3nG99UQhx1OfskqP0HwoXZ5OHk0M2AD5rjVe3iQiNQuyl@vger.kernel.org
X-Gm-Message-State: AOJu0YwWQmFKNqUVDFnCLE1sOpzSk048nIkddBKysVXNq0Y70g+fSVhn
	0R52SUMGdmLKy7uOQUkTbtpobIyZmur/Hfu1uJmwOILWZVbEdqsCujCttWYaSw7JhypECY6oRrn
	R03Cgk4YfbHGahqQXD403BgRox3/vHkIG745fppusbbOYag/0yrk=
X-Gm-Gg: ASbGnctuXtnLWN66ew7O/T6gNqQbHE2izmUUSPoMHngwuU/F7NYGf+n/BuS4uliqQ5l
	mtxPLgdfEppuMsGWqY45pRNpix0LXvOoRf4zSlHKee+LXIbnf8BgtPmY6I3u1hIdR+Ou/iKSxn8
	CM8Vuw8Nvd4kV5EDEt26pFUJH20Lri8jTry+2L8GpMx1pfIeQCCp+eTqZopDjxqwhnb5RyPg03F
	3pXFraUQ0q5nsgg0iOEH9kAMosQPfJT5kC1UfvMc6cZLK1Eaj3JURjpk6GBs6bxRSQvOSUL+5jo
	BQ1s8uMwRgVO+KUxsNy5UMxhOKk0EerzZ1o=
X-Received: by 2002:a5d:64a3:0:b0:386:3e0f:944b with SMTP id ffacd0b85a97d-38a8730fbd5mr22356136f8f.37.1736893955991;
        Tue, 14 Jan 2025 14:32:35 -0800 (PST)
X-Google-Smtp-Source: AGHT+IFIoP1HwW0/t+OHdp8+LpDOPhCQg7yQw88zYxN5SmOWMYjCVPKr8ZggLKfsAsyhkm6mkTIw3g==
X-Received: by 2002:a5d:64a3:0:b0:386:3e0f:944b with SMTP id ffacd0b85a97d-38a8730fbd5mr22356124f8f.37.1736893955605;
        Tue, 14 Jan 2025 14:32:35 -0800 (PST)
Received: from debian (2a01cb058d23d60010f10d4cace4e3dd.ipv6.abo.wanadoo.fr. [2a01:cb05:8d23:d600:10f1:d4c:ace4:e3dd])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-38a8e383965sm16244784f8f.31.2025.01.14.14.32.34
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 14 Jan 2025 14:32:35 -0800 (PST)
Date: Tue, 14 Jan 2025 23:32:33 +0100
From: Guillaume Nault <gnault@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Cc: David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org,
	Simon Horman <horms@kernel.org>, dccp@vger.kernel.org,
	Ido Schimmel <idosch@nvidia.com>
Subject: Re: [PATCH net-next] dccp: Prepare dccp_v4_route_skb() to
 .flowi4_tos conversion.
Message-ID: <Z4bmAVVyf4Z9VyRc@debian>
References: <ed399406a6ffad5097fa618c3bc7a4ac59546c62.1736869543.git.gnault@redhat.com>
 <CANn89iJQus-pqLta39df06DJLES8KgytN5iaVz9xv_HAz3F6Vw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CANn89iJQus-pqLta39df06DJLES8KgytN5iaVz9xv_HAz3F6Vw@mail.gmail.com>

On Tue, Jan 14, 2025 at 06:43:15PM +0100, Eric Dumazet wrote:
> On Tue, Jan 14, 2025 at 4:46 PM Guillaume Nault <gnault@redhat.com> wrote:
> >
> > Use inet_sk_dscp() to get the socket DSCP value as dscp_t, instead of
> > ip_sock_rt_tos() which returns a __u8. This will ease the conversion
> > of fl4->flowi4_tos to dscp_t, as it will just require to drop the
> > inet_dscp_to_dsfield() call.
> >
> > Signed-off-by: Guillaume Nault <gnault@redhat.com>
> > ---
> >  net/dccp/ipv4.c | 3 ++-
> >  1 file changed, 2 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> > index 5926159a6f20..9e64dbd38cd7 100644
> > --- a/net/dccp/ipv4.c
> > +++ b/net/dccp/ipv4.c
> > @@ -15,6 +15,7 @@
> >
> >  #include <net/icmp.h>
> >  #include <net/inet_common.h>
> > +#include <net/inet_dscp.h>
> >  #include <net/inet_hashtables.h>
> >  #include <net/inet_sock.h>
> >  #include <net/protocol.h>
> > @@ -473,7 +474,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net *net, struct sock *sk,
> >                 .flowi4_oif = inet_iif(skb),
> >                 .daddr = iph->saddr,
> >                 .saddr = iph->daddr,
> > -               .flowi4_tos = ip_sock_rt_tos(sk),
> > +               .flowi4_tos = inet_dscp_to_dsfield(inet_sk_dscp((inet_sk(sk)))),
> 
> You probably can replace ((X)) with (X) ?
> ->
>  .flowi4_tos = inet_dscp_to_dsfield(inet_sk_dscp(inet_sk(sk))),

Indeed, I'll change that in v2.

> >                 .flowi4_scope = ip_sock_rt_scope(sk),
> >                 .flowi4_proto = sk->sk_protocol,
> >                 .fl4_sport = dccp_hdr(skb)->dccph_dport,
> > --
> > 2.39.2
> >
> 

