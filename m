Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 332BF199D9
	for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 21:12:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="PK1h97Hb"
Received: from mail-yb1-xb2e.google.com (mail-yb1-xb2e.google.com [IPv6:2607:f8b0:4864:20::b2e])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5528CF9
	for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 14:12:45 -0700 (PDT)
Received: by mail-yb1-xb2e.google.com with SMTP id 3f1490d57ef6-d9a6399cf78so4387012276.0
        for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 14:12:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1698700364; x=1699305164; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=CB/W/zMQW25ZQ4GuqWwGUYOqtySyY5LGTxre2Rvl2XU=;
        b=PK1h97HbcW9/mQOSZhQYxohYbPLTLscv4NQeNdHp9eGPCVBXwahs2aogjiu6aS6N1Y
         TCYLy16RKETCX26OskPTj/YxLJRri3phN+Wx9Q4Ds0VxKkFMSeJRJQF8zSl643iAy0TB
         t1I+Z2QyzilCJantE6WFfS9OTKB5DqzdQYZIL8UNIFMNer0yQp6grFXsWWOoL4mZQF6A
         gl67dIcPJiXuUfon0sc5AH/otQY2d2VgAe07OMjcjUWWtVkLTBW28mRes+L94COdWHnE
         Y7Uro3YrC9/pBEM1+EAk4jU2uozPZDGdP8BRsYsGc5x+YjKUsOcvTuGrAYTWcUEe78ja
         LGFA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1698700364; x=1699305164;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=CB/W/zMQW25ZQ4GuqWwGUYOqtySyY5LGTxre2Rvl2XU=;
        b=wPoIKPqcQIFFDXsjJdv/Tye8NoAmFT5HM+fvFSdOk06hi4uL0SExxqxydvJFuRP9fd
         iqNX+Sc/oyiBUTQt7fGv56mAJSI//jWWlN9/sZfhcW/p2e+0B1kS+xhU8BUynXJB/IzI
         4hEz4ZUrigcVEogdj6VfA4NJT5FH/L4VndiJgrWMZFhWKPazSNbYrdWYRxRiPdYmA1tD
         j3cifsCi7ARcRL4z21F+vuG8GTn9hZKhNJYyQVLrLPOzPKNjD4pn99wAgCIH6kr2hinx
         eJ3WqftkKQAdDWnhW4e4HsUTN8DKNhf+5LR3tptSbYiGfh0Y16WwZQDPQcIFm6FA+Sg3
         v7vg==
X-Gm-Message-State: AOJu0YwLMuTi9y2wwUamj669kJBlAM++BKc9/rtfUA0pxjcwbaM718cC
	YiHHDexpvuOVl2GktvvTGgaA48dTa7IeHvDOkpsw
X-Google-Smtp-Source: AGHT+IFEfSHWJrsg7ggCsUSBma/S0eCf8DLt82JU8hTr1xy6U3nWMOzs2xHVlGEhFpoKQ2vOqGNuE8ye3ytObygobk0=
X-Received: by 2002:a05:6902:204:b0:da3:6ed0:1587 with SMTP id
 j4-20020a056902020400b00da36ed01587mr603806ybs.2.1698700364409; Mon, 30 Oct
 2023 14:12:44 -0700 (PDT)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20231030201042.32885-1-kuniyu@amazon.com> <20231030201042.32885-3-kuniyu@amazon.com>
In-Reply-To: <20231030201042.32885-3-kuniyu@amazon.com>
From: Paul Moore <paul@paul-moore.com>
Date: Mon, 30 Oct 2023 17:12:33 -0400
Message-ID: <CAHC9VhTrm2shkh=FHcjnqFpDLFCoBwGfsyoSuDH3UFSOeZt+HA@mail.gmail.com>
Subject: Re: [PATCH v1 net 2/2] dccp/tcp: Call security_inet_conn_request()
 after setting IPv6 addresses.
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, 
	Kuniyuki Iwashima <kuni1840@gmail.com>, netdev@vger.kernel.org, dccp@vger.kernel.org, 
	Huw Davies <huw@codeweavers.com>, linux-security-module@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 30, 2023 at 4:12=E2=80=AFPM Kuniyuki Iwashima <kuniyu@amazon.co=
m> wrote:
>
> Initially, commit 4237c75c0a35 ("[MLSXFRM]: Auto-labeling of child
> sockets") introduced security_inet_conn_request() in some functions
> where reqsk is allocated.  The hook is added just after the allocation,
> so reqsk's IPv6 remote address was not initialised then.
>
> However, SELinux/Smack started to read it in netlbl_req_setattr()
> after commit e1adea927080 ("calipso: Allow request sockets to be
> relabelled by the lsm.").
>
> Commit 284904aa7946 ("lsm: Relocate the IPv4 security_inet_conn_request()
> hooks") fixed that kind of issue only in TCPv4 because IPv6 labeling was
> not supported at that time.  Finally, the same issue was introduced again
> in IPv6.
>
> Let's apply the same fix on DCCPv6 and TCPv6.
>
> Fixes: e1adea927080 ("calipso: Allow request sockets to be relabelled by =
the lsm.")
> Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
> ---
> Cc: Huw Davies <huw@codeweavers.com>
> Cc: Paul Moore <paul@paul-moore.com>
> ---
>  net/dccp/ipv6.c       | 6 +++---
>  net/ipv6/syncookies.c | 7 ++++---
>  2 files changed, 7 insertions(+), 6 deletions(-)

Thanks for catching this and submitting a patch!

It seems like we should also update dccp_v4_conn_request(), what do you thi=
nk?

> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 8d344b219f84..4550b680665a 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -360,15 +360,15 @@ static int dccp_v6_conn_request(struct sock *sk, st=
ruct sk_buff *skb)
>         if (dccp_parse_options(sk, dreq, skb))
>                 goto drop_and_free;
>
> -       if (security_inet_conn_request(sk, skb, req))
> -               goto drop_and_free;
> -
>         ireq =3D inet_rsk(req);
>         ireq->ir_v6_rmt_addr =3D ipv6_hdr(skb)->saddr;
>         ireq->ir_v6_loc_addr =3D ipv6_hdr(skb)->daddr;
>         ireq->ireq_family =3D AF_INET6;
>         ireq->ir_mark =3D inet_request_mark(sk, skb);
>
> +       if (security_inet_conn_request(sk, skb, req))
> +               goto drop_and_free;
> +
>         if (ipv6_opt_accepted(sk, skb, IP6CB(skb)) ||
>             np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
>             np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
> diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> index 500f6ed3b8cf..12eedc6ca2cc 100644
> --- a/net/ipv6/syncookies.c
> +++ b/net/ipv6/syncookies.c
> @@ -181,14 +181,15 @@ struct sock *cookie_v6_check(struct sock *sk, struc=
t sk_buff *skb)
>         treq =3D tcp_rsk(req);
>         treq->tfo_listener =3D false;
>
> -       if (security_inet_conn_request(sk, skb, req))
> -               goto out_free;
> -
>         req->mss =3D mss;
>         ireq->ir_rmt_port =3D th->source;
>         ireq->ir_num =3D ntohs(th->dest);
>         ireq->ir_v6_rmt_addr =3D ipv6_hdr(skb)->saddr;
>         ireq->ir_v6_loc_addr =3D ipv6_hdr(skb)->daddr;
> +
> +       if (security_inet_conn_request(sk, skb, req))
> +               goto out_free;
> +
>         if (ipv6_opt_accepted(sk, skb, &TCP_SKB_CB(skb)->header.h6) ||
>             np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
>             np->rxopt.bits.rxhlim || np->rxopt.bits.rxohlim) {
> --
> 2.30.2

--=20
paul-moore.com
