Received: from mail-ed1-f44.google.com (mail-ed1-f44.google.com [209.85.208.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F349D1ADC7A
	for <dccp@vger.kernel.org>; Tue, 14 Jan 2025 17:43:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736876609; cv=none; b=Vi877SOkTWn0IIVvURANxgvOX5thv5+vWi9xl8YHbA8+CYaa+bUAY8YVby40lQL0eoTAvZsWG2diVD2XfT+kiCLhakX7h4yl6Q1dKR3zEMrT+6/T3xuk5kQf2wm981hp1TsVLsii2IQeXdzjX++bB+QQ03pHZbD9NgMksFN/Tyg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736876609; c=relaxed/simple;
	bh=g3RSz4tvQ+K8kYL7EDIG9hyMf9wv0irpaIEFqf7Zn+w=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=VQN90rskK4BC/L4zIWegpxz8b9AE6cyB37rHsU4D6jVOzSdy6H9OmIeNlfMq9JAWCZd6FYi6NsKdfWnex61B1nGPjV5wV+suK6FjDcC3ZhhPodKv4Dt9jCh1a91Pws2YiOKxHuv0qUZeKr/9rFtn0iuTDoMxWq3Br5HUtJng8JE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=WOCaVblg; arc=none smtp.client-ip=209.85.208.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WOCaVblg"
Received: by mail-ed1-f44.google.com with SMTP id 4fb4d7f45d1cf-5d7e527becaso9580014a12.3
        for <dccp@vger.kernel.org>; Tue, 14 Jan 2025 09:43:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1736876606; x=1737481406; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=pNTVUbPev2Susw6wdu2cyGHrOMaUb0OBH3JWwwciS6A=;
        b=WOCaVblgMUyP/pmpvBWG52jBpIqtdwrKwtIMmrM0LJXKMa35c7WtXO4N5MjwxEnZzl
         oQajoro2cdUNe8dYi20Uf8ol9fSwNmCQxQp3PKzKHn/h+uzUz5NENErhZhgP6Cz08+Fa
         QrsLy7nJCwD5c4AtO7Gf6MRsKoca8R/N/nQedxELfRErVfoL5KdTZhmHf5moGfN7dzgu
         ZP+VsS2yXDJ1BpBd/x20GBV/cTjaSUw1zdeLm1Ch9g+q+Bjvi8VRvOv+f7t0AjmmdM+J
         /YvvvCjAjzh1mETYt1ou3SbETG2iIMaT3x/2fcCXEZMKg5GlE71mEvmsrp9muE89LPyd
         Rntg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1736876606; x=1737481406;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=pNTVUbPev2Susw6wdu2cyGHrOMaUb0OBH3JWwwciS6A=;
        b=XijbYJaV9HMHuV5we0SNwR8/TYVkP4OLR3Hl1WpP4NkGrvbVaRCJAlWmcw9o9ZaZ8+
         frv7cD5x1qAPpJuElqN57LI6UPmpfllYyuLUIJ3hAGwatgUry63ouDcpbgnp2CCtfPlt
         R8rTG1GOCvDARHbgvR/DhKBYj4W/Z2xntVUPoh4mEU+ejbu1VHOZMVwuWej96rUcDaew
         dlMvU2mOuoJzMdhN9BzWZH0iha7hneJYeomnazCzBeHFMr7RLJZKbf1DsHtoOD5soqcM
         UsHCN6ECgji2Bcu+eldSAigy91cX6dkuFfc8zefyfLAHbTJW3tPvDGCkC+65dsqnOKpf
         ofrw==
X-Forwarded-Encrypted: i=1; AJvYcCUXVyXGhNA6w6Ly5Oq4LtD61cJiyMIdTlr91/hTf7C35Q7di+m/kZK9isk7DbhHN3NfeNt/@vger.kernel.org
X-Gm-Message-State: AOJu0Yyd6PFmSF8zFiEp4lKIVBfYurZ8RPataHe7KxDYJsN1yN/yoOqn
	0RuSjU2qq0f12mmO9GUQHh99e+BhOYlRjLziYuwsD6zNmcWkjHEmI+6684jVCk3U0zWGc001wnL
	xsIwk8RaKZUTkv6KN2bzdIIbHJiP6XgnkhHPz
X-Gm-Gg: ASbGnctIM4nO6UQuq84DU59onpCiLfZlTUbmC6cpDMoekNNCXQEtEy67qmnFbY6mNBh
	1zJlDRKcDGlFSfl1Ee/be56dfloSjDu/OjLsimw==
X-Google-Smtp-Source: AGHT+IFzTWI62UvqCB5IdmtsIaLJLBkThu6h1KkwDfNMS0U5jS0EWO8wF3L9m6Rj6WOPwj6CnnraA+RdB+SsYxlHrA8=
X-Received: by 2002:a05:6402:50d4:b0:5d0:9054:b119 with SMTP id
 4fb4d7f45d1cf-5d972e63dd4mr56979803a12.21.1736876606178; Tue, 14 Jan 2025
 09:43:26 -0800 (PST)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <ed399406a6ffad5097fa618c3bc7a4ac59546c62.1736869543.git.gnault@redhat.com>
In-Reply-To: <ed399406a6ffad5097fa618c3bc7a4ac59546c62.1736869543.git.gnault@redhat.com>
From: Eric Dumazet <edumazet@google.com>
Date: Tue, 14 Jan 2025 18:43:15 +0100
X-Gm-Features: AbW1kvZeC67blwoiBPqZHrEQE5Xccb5vHPa0Wzmu4PYZWSG7h3tJf1ebn1aW8gQ
Message-ID: <CANn89iJQus-pqLta39df06DJLES8KgytN5iaVz9xv_HAz3F6Vw@mail.gmail.com>
Subject: Re: [PATCH net-next] dccp: Prepare dccp_v4_route_skb() to .flowi4_tos conversion.
To: Guillaume Nault <gnault@redhat.com>
Cc: David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, 
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, Simon Horman <horms@kernel.org>, 
	dccp@vger.kernel.org, Ido Schimmel <idosch@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, Jan 14, 2025 at 4:46=E2=80=AFPM Guillaume Nault <gnault@redhat.com>=
 wrote:
>
> Use inet_sk_dscp() to get the socket DSCP value as dscp_t, instead of
> ip_sock_rt_tos() which returns a __u8. This will ease the conversion
> of fl4->flowi4_tos to dscp_t, as it will just require to drop the
> inet_dscp_to_dsfield() call.
>
> Signed-off-by: Guillaume Nault <gnault@redhat.com>
> ---
>  net/dccp/ipv4.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 5926159a6f20..9e64dbd38cd7 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -15,6 +15,7 @@
>
>  #include <net/icmp.h>
>  #include <net/inet_common.h>
> +#include <net/inet_dscp.h>
>  #include <net/inet_hashtables.h>
>  #include <net/inet_sock.h>
>  #include <net/protocol.h>
> @@ -473,7 +474,7 @@ static struct dst_entry* dccp_v4_route_skb(struct net=
 *net, struct sock *sk,
>                 .flowi4_oif =3D inet_iif(skb),
>                 .daddr =3D iph->saddr,
>                 .saddr =3D iph->daddr,
> -               .flowi4_tos =3D ip_sock_rt_tos(sk),
> +               .flowi4_tos =3D inet_dscp_to_dsfield(inet_sk_dscp((inet_s=
k(sk)))),

You probably can replace ((X)) with (X) ?
->
 .flowi4_tos =3D inet_dscp_to_dsfield(inet_sk_dscp(inet_sk(sk))),


>                 .flowi4_scope =3D ip_sock_rt_scope(sk),
>                 .flowi4_proto =3D sk->sk_protocol,
>                 .fl4_sport =3D dccp_hdr(skb)->dccph_dport,
> --
> 2.39.2
>
