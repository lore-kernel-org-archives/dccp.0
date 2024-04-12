Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3651D56B74
	for <dccp@vger.kernel.org>; Fri, 12 Apr 2024 12:20:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1712924422; cv=none; b=KTT86R3qTtAu1bMmF0DvLWiRrLIqPia4fHuoN4dvXm5N+1FIxZt72z8JV/+C7ERLa/IuQuNzMd4L5dtT34jtWNryl0wcw+OXrqNZyLGcXKWQemRoD2U7efnzwCQjHvO7120uc5dVpuC8QJfeV19gc3aVK42wvx2UjbmN7WtCMCw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1712924422; c=relaxed/simple;
	bh=WFmjjSrbeFjEmhLlBiWpRUSOMUY8KYm186SmcYNgeYs=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=boyGzAx5KO78a4or9w+Nw/YPv8ZVIUC/yF2zISj5i3YawrGeMXYyLmKFCsZ9ec/LQ+QySMhjV2xi4Wba9OBwvg6XGV+EPKEWPXoBJp5yPZhLmyogfQPwXMcJyEg9O3d8u36XaxTQyOcQYbyVlVhc1r+ZmPo3NI/Aq9l9wkU59Ys=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Uj1yOAA2; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Uj1yOAA2"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1712924420;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=WFmjjSrbeFjEmhLlBiWpRUSOMUY8KYm186SmcYNgeYs=;
	b=Uj1yOAA2TX4LpKMSULZjzSY8u42jTvL3tcKYlE8VXsELpUi/AzHEcrSfH0RKrrqBHQ8Gdf
	qgQgeKgyYUziiHRhkhbWn2plEDyX9Aiq/UdZGgsaLjsor3Vc3rco6sNasqn3EeAf28/cTI
	HY0QK7G7iJMRhPDSKmMZH7h49I5Ipzo=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-147-jdBgKX4dPji-8CHjrQoHxg-1; Fri, 12 Apr 2024 08:20:18 -0400
X-MC-Unique: jdBgKX4dPji-8CHjrQoHxg-1
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-78d5718e092so73096385a.1
        for <dccp@vger.kernel.org>; Fri, 12 Apr 2024 05:20:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1712924418; x=1713529218;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=WFmjjSrbeFjEmhLlBiWpRUSOMUY8KYm186SmcYNgeYs=;
        b=eNRxphI3tNNvrWRT6HbITugkqCFlPxfJwf3fa++jjfmgU6HsX7MTFooxeblxeA8+II
         WWWjfMQ7qELPIS0Rv47pr40wDBW/iCJ0bdKhSolGtAFoxaSfTQ86JI9GHRqqezNCgkn5
         uZ8g+JZNffOJis9Qa0bGcsCaD7A5u/q+A9dZxs8cKwG4T0bYD4nwP3CplB6E7IjeopKM
         M4H7Sf7ma4TyCAWTRDyqc4SGK5Dn1q9SrtkZ+V9vWaPltggMRHQ5Wabf8vG2vHg57ZTs
         hs4f6AkevbSgfWE7o17Fb9pZ6Obm/IX4gbo3ZpGwJfV7v7NAujy/lAmPJ3+aEVUTrZk+
         jnFA==
X-Gm-Message-State: AOJu0Yz12eFA9lisX4ORX8dJwnLp24D9WbKLsN0AaUuePpqBZ7JZEFu3
	Mn7oRo+g5o4Ljg4RxVNXX8VLUY+TWXXPkcgbJqKOv0zZ/DLeOgqvOVUKLJNMwWAGcLfZPkuoHhO
	RAl0X5pTqd5UvYmdz4362qFCrBmtnYeWoLo/s7ibWzHX2REbX3is=
X-Received: by 2002:a05:620a:394d:b0:78e:cc24:f3fe with SMTP id qs13-20020a05620a394d00b0078ecc24f3femr1810331qkn.2.1712924418012;
        Fri, 12 Apr 2024 05:20:18 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEl1RGrNpjG++v4K183eeVV70SCzpHYcpeio2nSYQsNbwwZxjYJTxzbIAebB5VpqAVwSeJLGQ==
X-Received: by 2002:a05:620a:394d:b0:78e:cc24:f3fe with SMTP id qs13-20020a05620a394d00b0078ecc24f3femr1810306qkn.2.1712924417731;
        Fri, 12 Apr 2024 05:20:17 -0700 (PDT)
Received: from vschneid-thinkpadt14sgen2i.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id m29-20020a05620a215d00b0078d65a42db6sm2319340qkm.95.2024.04.12.05.20.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 12 Apr 2024 05:20:16 -0700 (PDT)
From: Valentin Schneider <vschneid@redhat.com>
To: Jakub Kicinski <kuba@kernel.org>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, "David S.
 Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, Paolo
 Abeni <pabeni@redhat.com>, mleitner@redhat.com, David Ahern
 <dsahern@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Tomas Glozar
 <tglozar@redhat.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v4 1/1] tcp/dcpp: Un-pin tw_timer
In-Reply-To: <20240411100536.224fa1e7@kernel.org>
References: <20240411120535.2494067-1-vschneid@redhat.com>
 <20240411120535.2494067-2-vschneid@redhat.com>
 <20240411100536.224fa1e7@kernel.org>
Date: Fri, 12 Apr 2024 14:20:12 +0200
Message-ID: <xhsmhy19i93ib.mognet@vschneid-thinkpadt14sgen2i.remote.csb>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 11/04/24 10:05, Jakub Kicinski wrote:
>
> Some new crashes started appearing this morning on our testing branch,
> quick look at the splats makes me suspect this change:
>

Thanks for the testing! Seems like my own testing wasn't thorough enough,
let me have a look at this...

