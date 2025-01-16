Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 58C4722A4F1
	for <dccp@vger.kernel.org>; Thu, 16 Jan 2025 13:51:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1737035481; cv=none; b=VOhdlUYxokEOzlIEkRtH3lk7d4hB2GcEnTgxm6R2dyBdAVAT+vEumjLQA2RXbpqUfamr2wKaKTGDYGgPPn467fhcwdTuYA1i2/krS8QcNECHckRF3Ew/F2L4JKQfkwjlilMXipTwGos/KGclyjTyCRz+zNmX1VOQvvsozVk0OS4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1737035481; c=relaxed/simple;
	bh=qNLhPseTfvfnrGx3PuQePTdrPtb7dP4K1mmUh2cou+Y=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Q/l4yNkq/lyp2mo0oMtCjhlYhXwsXLFbPjvmSw8nPEn1KTorjI6qyYOz5hkchFEhTAvyRhy6GZlI56Po33Kw48msklBVtyOwLtC2h4SnOu2Pqtv97SnuF3xk+fWWAgazbLTkU2ZLIzjBTolfIFsliZKv/9KsZu6sP2GsUiolRDU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=bLeTiPJe; arc=none smtp.client-ip=209.85.208.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bLeTiPJe"
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-5d9f0a6adb4so1977019a12.1
        for <dccp@vger.kernel.org>; Thu, 16 Jan 2025 05:51:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1737035477; x=1737640277; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=qNLhPseTfvfnrGx3PuQePTdrPtb7dP4K1mmUh2cou+Y=;
        b=bLeTiPJe9QCYz/l2t9zZUqkwD30asEq+wV6zD/DVVSPNiS8M6ciABb9mqBcwkv15X/
         RqADNFBbXl9BZ4ek99VnNK3Lk02XlxWkFO+eOUgNuouxsmCF1Aggyx/8GVZsvRf05bes
         rrSHRMLlJ9dBDvO5WVUT38WTKPPo//CsNjrA4GwsHIdTsvCO7Ef5pchH7oBc270M8HoG
         9nuGlT6zf3Tv1cmjbcPBdxIIRa2SedP5cvdAquj8maryr7Z8RGY72BAbp1KcHb49Miey
         zBPusiAIkfRkg9OHF0GG36cN/zcoeVR9/XjDqMjlpOKKsL8YfqcwQWsjfvpaPyHIj377
         ZKjw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1737035477; x=1737640277;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=qNLhPseTfvfnrGx3PuQePTdrPtb7dP4K1mmUh2cou+Y=;
        b=e37k+lfk2QtuKuNzjAXT03aKw3z2zoUVZWqKjDMrVI5aq9TA9jmQv4S2t18EOqo3Bf
         YQhHVHKHfXgFnCf/EaXlD17LNH6lFSvq6SkRLBttW6I8S1x6QewCKTGzpTjUDbwHByQ6
         lx6/GwJmJca9pdJGu58KM9GXp0Hp8874r7EdjDjOfhIVu8bByq1wdk/9Y2UZ76VPgnVF
         8Fp+u92vFtyM7/YT4Qv258gx7lqVvJT5+56FEH5c/0um5UY2AZyMTMHYwayhTAV5loj0
         IlH/8snCmHoYqIvd8j6349cgCphsFNiqZ13TNnXE+chbdv9F6CfkWn8bFLa21Ao5EuYE
         Lfvw==
X-Forwarded-Encrypted: i=1; AJvYcCVBFEfreNK7BM+HQcMI59RyTdk5ywhPKx8TcCRWsviMGce4njg/7xHfr1ou64tqJS8+fDib@vger.kernel.org
X-Gm-Message-State: AOJu0Yw1Zv4SIkz794Sq2kN2qagxjxaPG8k7tOI1C8+cZVQIeOoeauDo
	zngQlcLb7xRjDbFK55WEPZW1O/chvPbyGSY1tfvKnFpvbOkMa4Lud/qhxwq4Dmj2hKCGMAXGu4v
	9Ym0rSyTDuAegbmyAn394dO0k120+LU1IgdGn
X-Gm-Gg: ASbGncuRepJiGiIBvy3dk9RjRqssEVCaex4ZcR7eGfIw+GMwhO4yaZxSPRDcHS2xSXi
	78E9O4eWBqrtr5ORi3teoed4SUG/+u6beD2ml
X-Google-Smtp-Source: AGHT+IEtReXnldTm1Hjssz1tb1eLK7md7tV97HcI8JfIh+WsZrFAgIQvHZEGQS8T5E/fvPkOUUVxCx8m9fgCnTRfDK0=
X-Received: by 2002:a05:6402:4306:b0:5d0:c098:69 with SMTP id
 4fb4d7f45d1cf-5d972e13643mr33435003a12.16.1737035476495; Thu, 16 Jan 2025
 05:51:16 -0800 (PST)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
In-Reply-To: <208dc5ca28bb5595d7a545de026bba18b1d63bda.1737032802.git.gnault@redhat.com>
From: Eric Dumazet <edumazet@google.com>
Date: Thu, 16 Jan 2025 14:51:05 +0100
X-Gm-Features: AbW1kvaSPhZoozSV3Y0s6GwVaZM1IAsIYh3kBw9yoEN9KYOTuZufMEUzzkJ06mc
Message-ID: <CANn89iKY6Gww84HphTWRj2C3TPa6hs29+SA4gfwN5+JTsf--GQ@mail.gmail.com>
Subject: Re: [PATCH net-next v2] dccp: Prepare dccp_v4_route_skb() to
 .flowi4_tos conversion.
To: Guillaume Nault <gnault@redhat.com>
Cc: David Miller <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, 
	Paolo Abeni <pabeni@redhat.com>, netdev@vger.kernel.org, Simon Horman <horms@kernel.org>, 
	dccp@vger.kernel.org, Ido Schimmel <idosch@nvidia.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 16, 2025 at 2:10=E2=80=AFPM Guillaume Nault <gnault@redhat.com>=
 wrote:
>
> Use inet_sk_dscp() to get the socket DSCP value as dscp_t, instead of
> ip_sock_rt_tos() which returns a __u8. This will ease the conversion
> of fl4->flowi4_tos to dscp_t, which now just becomes a matter of
> dropping the inet_dscp_to_dsfield() call.
>
> Signed-off-by: Guillaume Nault <gnault@redhat.com>
> ---

Reviewed-by: Eric Dumazet <edumazet@google.com>
