Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="hJIJdovF"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6CBAC1729
	for <dccp@vger.kernel.org>; Fri,  8 Dec 2023 06:47:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1702046861;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=7OyK/hwOtOLcmVz6X7PhUXWLJeC6+muyilj4AjJlSQo=;
	b=hJIJdovFLgLc/zQXkFoX6CRYHKWhdn2Um3JAHdYus0E+3SPqNRxGpLbuq9XZLZaJeMDum6
	8ACeriA6rw4R/eziYr25N8F7ZPDTFwzX4hevHfEdyV0unG5FPaqZ4lIX4RbDmqyZaE93G9
	RsZRgCbzzm3FC3knY1Xp1xAdDP5WqZY=
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com
 [209.85.222.200]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-490-llPQhrC2MM6OWOVVow7OHg-1; Fri, 08 Dec 2023 09:47:40 -0500
X-MC-Unique: llPQhrC2MM6OWOVVow7OHg-1
Received: by mail-qk1-f200.google.com with SMTP id af79cd13be357-77f10001de7so223114985a.3
        for <dccp@vger.kernel.org>; Fri, 08 Dec 2023 06:47:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1702046860; x=1702651660;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=7OyK/hwOtOLcmVz6X7PhUXWLJeC6+muyilj4AjJlSQo=;
        b=RU4TJqZ/j1oJ5lKXLhHdZ2WusweZqqdJo2QJgr3NibsMGMGBB0pKdRGsX4yvxOGsZj
         6E87E9K9dOQdy9mRG1pt2AJU9BgPdVYPH0X5sZmIer0Pudo7lgb8ONJ8fEqWiU4WUk/I
         sWrNbcDaSg/Jzx1153KAVoeDsYmiJoyWmXp8P5aSjXgmy9lgFW1tqntGoCxNj7lXxl4x
         LKDdBCPH/3K1fNbArCwPhy4GHG2QT2rBpdooE+GOGJL2a9+Wq/VUwQy1kulUpv17r82w
         R4WtftJk27epCTb/b99WK7vZ7rnz/3LPsATfz2+I+49QsaVbA4gjIOOOJTqxvInw3XQt
         mAsQ==
X-Gm-Message-State: AOJu0Yy2oPucmrohlN69+nu4Qmxju+vNn85Z/YujzKPOtiiqD6Vk1V1o
	GNAkJP+IonCO1fAZsFvjG/dTGKFAnCb6eXbJKSwsdKAyEC2/al0nKnukvWtMprcEuHsLeeyZkq+
	Poki3kEIcjOjkhQ==
X-Received: by 2002:a05:620a:12fc:b0:77f:9a0:4c0b with SMTP id f28-20020a05620a12fc00b0077f09a04c0bmr189738qkl.106.1702046859815;
        Fri, 08 Dec 2023 06:47:39 -0800 (PST)
X-Google-Smtp-Source: AGHT+IHS8oTk7W/sdXJxFVN3x8zdP6FLYD5tfQZpwV95j+7itXBMVNqFHiJaPRhZ+yDKJ0sbtIxg7g==
X-Received: by 2002:a05:620a:12fc:b0:77f:9a0:4c0b with SMTP id f28-20020a05620a12fc00b0077f09a04c0bmr189720qkl.106.1702046859556;
        Fri, 08 Dec 2023 06:47:39 -0800 (PST)
Received: from vschneid-thinkpadt14sgen2i.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id h6-20020a05620a13e600b0077f287b2393sm733803qkl.63.2023.12.08.06.47.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 08 Dec 2023 06:47:38 -0800 (PST)
From: Valentin Schneider <vschneid@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, "David S.
 Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo
 Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, Juri Lelli
 <juri.lelli@redhat.com>, Tomas Glozar <tglozar@redhat.com>, Sebastian
 Andrzej Siewior <bigeasy@linutronix.de>, Thomas Gleixner
 <tglx@linutronix.de>
Subject: Re: [PATCH v2 1/2] tcp/dcpp: Un-pin tw_timer
In-Reply-To: <CANn89iKRSKz0e8v+Z-UsKGs4fQWDt6eTAw71VENbSmfkEicTPA@mail.gmail.com>
References: <20231115210509.481514-1-vschneid@redhat.com>
 <20231115210509.481514-2-vschneid@redhat.com>
 <CANn89iJPxrXi35=_OJqLsJjeNU9b8EFb_rk+EEMVCMiAOd2=5A@mail.gmail.com>
 <CAD235PRWd+zF1xpuXWabdgMU01XNpvtvGorBJbLn9ny2G_TSuw@mail.gmail.com>
 <CANn89iKRSKz0e8v+Z-UsKGs4fQWDt6eTAw71VENbSmfkEicTPA@mail.gmail.com>
Date: Fri, 08 Dec 2023 15:47:35 +0100
Message-ID: <xhsmh8r64bvjs.mognet@vschneid-thinkpadt14sgen2i.remote.csb>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 23/11/23 17:32, Eric Dumazet wrote:
> Again, I think you missed some details.
>
> I am OOO for a few days, I do not have time to elaborate.
>
> You will need to properly track active timer by elevating
> tw->tw_refcnt, or I guarantee something wrong will happen.

I apologize if I'm being thick skulled, I've been staring at the code and
tracing on live systems and I still can't see the issue with refcounts.

The patch has the hashdance set the refcount to 4:
         * - one reference for bhash chain.
         * - one reference for ehash chain.
         * - one reference for timer.
         * - one reference for ourself (our caller will release it).

AFAICT, finding & using the socket via the ehash table comes with a refcount_inc
(e.g. __inet_lookup_established()).

Worst case, the lookup happens after programming the timer, and we get a
inet_twsk_deschedule_put(). This reduces the refcount by:

  3 via inet_twsk_kill():
   1 (sk_nulls_del_node_init_rcu())
   1 (inet_twsk_bind_unhash())
   1 (inet_twsk_put())
  1 via inet_twsk_put()

IOW 4 total. So we can have:

  tcp_time_wait()
    inet_twsk_hashdance();  // refcount = 4
    inet_twsk_schedule();   // timer armed

                            tcp_v4_rcv()
                              sk = __inet_lookup_skb(); // refcount = 5 (+1)
                              inet_twsk_deschedule_put(inet_twsk(sk));
                                inet_twsk_kill(tw) // refcount = 2 (-3)
                                inet_twsk_put(tw)  // refcount = 1 (-1)

    inet_twsk_put(tw) // refcount = 0 (-1)

__inet_hash_connect() can invoke inet_twsk_bind_unhash() by itself before
calling inet_twsk_deschedule_put(), but that just means it won't be done by
the latter, so the total refcount delta remains the same.

Thinking about it differently, this would mean that currently (without the
patch) another CPU can bring the refcount to 0 without disarming the timer,
because the patch is making the initial value one higher.

What am I missing?

