Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D4252139563
	for <dccp@vger.kernel.org>; Mon, 26 Aug 2024 06:37:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724654272; cv=none; b=geHg2WupHeRkWTQcPYj6TVI4wtjXPnFy0D3L5IgVD77HGjLPbv6cl3rsORcOoIcO4uF3DEx6NZzxk2T1Qfj6o3quvrWAfjiLALS8GWuYUd0EjSzBCwqB4g+kzUp1DZbYAyKSgAV4BCFZS91mPr5AQyv5P8v4hhwC+Io1z94ix8g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724654272; c=relaxed/simple;
	bh=tIqjP7wkBcetb1vT1IM+Khjh2UxNrkOVUPOtgZvtKvk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PNuAd7OrR/nLlV66Gdw4Nax5at0q7Jt1wAAlGflqf+ZbkXix22kYyKNpvaxsIcB95m+5O5cr1sJKNj402j7ckheau2HjdgiTBxEFTYIOxFByHqHA67mBoSUa9e23WzMfc9dTYfPuf2Kwc7sUDiIdhwgPPX4Oeu2Z3nahmBu+Zt4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=C3o3/sPB; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="C3o3/sPB"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1724654269;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=45FOD6KTcPecHM5IOLAynL+DDZ1FnLvddcnxAZcFSfY=;
	b=C3o3/sPBhAwuLWxp3lY2+xi3lrPIbT5zyXv5LNctky5u41xSYLJf/yS2AROm2phFlxdg+w
	4FLJ9QcG7vMP6WRSDvbHbPmVxZkw23msQtpy9ygqaaXEoEDgWsZL4nIZdcVkG8k+lyhdau
	rXVMzhYVsiqwumZP0EeV7tBFp/lK1rg=
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com
 [209.85.167.69]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-610-V9WVY6BePdOkRuubh9Dvkg-1; Mon, 26 Aug 2024 02:37:48 -0400
X-MC-Unique: V9WVY6BePdOkRuubh9Dvkg-1
Received: by mail-lf1-f69.google.com with SMTP id 2adb3069b0e04-5334656d5c3so3800430e87.1
        for <dccp@vger.kernel.org>; Sun, 25 Aug 2024 23:37:48 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1724654267; x=1725259067;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=45FOD6KTcPecHM5IOLAynL+DDZ1FnLvddcnxAZcFSfY=;
        b=v9uZo3oImkpurHo36eV06Zshzaovptm4GMH0jwfGtG6vWPFJp7rNol4NeSrdOWM3ZL
         Aj0li0zucYcKorw1dwIetEdY3rlox2a62HvwPYfHoRYSj8Ct+1BmKSvV1SIjjmDp9lrk
         /Zask9AGuZ7fVqPrVMWJRIS9kAp5XR0ZrYHMKOmH55ZMpbkmqvlfNfviLq5VhcN97qHO
         fv4GCrOhPKhjUutJi/QGBJKvAdk4ZWPwqonPqkw5Js8unPqe+Zu2t3GzISUkZg4B/6rH
         mBkFnfXH4P7g+se0exOGpQ7U2qEwfTvBEZp8awcjUnwV3B3Hkvf6fNQEAb/ZH5e0AuvP
         zC7w==
X-Forwarded-Encrypted: i=1; AJvYcCWAkpEetw8nVesZ9+DSa7303sMMgrD4ngn8YrrfoEUOku7MsD+VAkV04cL7mEhSOlEncEGu@vger.kernel.org
X-Gm-Message-State: AOJu0YwCGGHxJ4M+CkBWgVKLZThb51IVHiW95wKS62b43Cpe2SSaxpKl
	GbwrUbW8tdM8sxjYbhE27F1hz/CUdiwLF0evowR4W6eUWHZhYGEFjgGvRs8mitxEQJ57tbFRlkj
	pbxhGBUuRDSVHmXgXC8dsY2FZV0BJpfp7fkOHmucsX/Eu75FUWlg=
X-Received: by 2002:a05:6512:3191:b0:52c:df3d:4e9d with SMTP id 2adb3069b0e04-534387bc61dmr5752301e87.37.1724654266740;
        Sun, 25 Aug 2024 23:37:46 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IHybNBZvXvGT1JAjBIuJZk4lctTsFDvHNw8UbEsu8wiVnEjhBh18CnKX34zVm4ZL+xWbkh2ig==
X-Received: by 2002:a05:6512:3191:b0:52c:df3d:4e9d with SMTP id 2adb3069b0e04-534387bc61dmr5752279e87.37.1724654266155;
        Sun, 25 Aug 2024 23:37:46 -0700 (PDT)
Received: from [172.16.2.75] (5920ab7b.static.cust.trined.nl. [89.32.171.123])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-a868f436badsm622206966b.139.2024.08.25.23.37.45
        (version=TLS1_2 cipher=ECDHE-ECDSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Aug 2024 23:37:45 -0700 (PDT)
From: Eelco Chaudron <echaudro@redhat.com>
To: Hongbo Li <lihongbo22@huawei.com>
Cc: johannes@sipsolutions.net, davem@davemloft.net, edumazet@google.com,
 kuba@kernel.org, pabeni@redhat.com, allison.henderson@oracle.com,
 dsahern@kernel.org, pshelar@ovn.org, linux-wireless@vger.kernel.org,
 netdev@vger.kernel.org, rds-devel@oss.oracle.com, dccp@vger.kernel.org,
 dev@openvswitch.org, linux-afs@lists.infradead.org
Subject: Re: [PATCH net-next 6/8] net/openvswitch: Use max() to simplify the
 code
Date: Mon, 26 Aug 2024 08:37:44 +0200
X-Mailer: MailMate (1.14r6056)
Message-ID: <B4FCA95A-F6E0-4610-8671-780A2015C5F4@redhat.com>
In-Reply-To: <20240824074033.2134514-7-lihongbo22@huawei.com>
References: <20240824074033.2134514-1-lihongbo22@huawei.com>
 <20240824074033.2134514-7-lihongbo22@huawei.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain



On 24 Aug 2024, at 9:40, Hongbo Li wrote:

> Let's use max() to simplify the code and fix the
> Coccinelle/coccicheck warning reported by minmax.cocci.
>
> Signed-off-by: Hongbo Li <lihongbo22@huawei.com>

The change looks good to me.

Acked-by: Eelco Chaudron <echaudro@redhat.com>
> ---
>  net/openvswitch/vport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index 8732f6e51ae5..859208df65ea 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -534,7 +534,7 @@ static int packet_length(const struct sk_buff *skb,
>  	 * account for 802.1ad. e.g. is_skb_forwardable().
>  	 */
>
> -	return length > 0 ? length : 0;
> +	return max(length, 0);
>  }
>
>  void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)
> -- 
> 2.34.1

