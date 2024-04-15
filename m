Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3617578C6F
	for <dccp@vger.kernel.org>; Mon, 15 Apr 2024 14:33:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713191633; cv=none; b=am70VN9XuI5V0kDYWmtZy+sfVRrPEWCwOfZ/AkhnfjGblavgDCAyISUVEKPwkwGKnjivBbo4vOA8jB3yBiv8I+AREjzBjcMz+EdGNgFQTWDQqxDMfx1S6qrkhYaJB38DGdqOurdNMdTdF/G34Uq0Hx2QY5SwrsX5ZM4TqdVPSFw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713191633; c=relaxed/simple;
	bh=pZatBN48J9TWETE5SB7D46qgelWlOsIMx+cbhmR3oRg=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=NEzmCrpqkywWB8tGzj0amdXRYzyhvdwCFogoMXEmLaN4bK+3eCHxPQVe3LuKXcLTfUzezeQJ92j7J06RjoAWa/mO5tnVY+BnHjnoFqaPrB/eUx4OIiN552VXYRVut9m3G7KRqDffQVkQF8G2rVJizUDwXKcTchrOy/97AI58Sjg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JLjQw+W3; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JLjQw+W3"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1713191631;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=vVrDx/bbmS5+gjreM3QEYo2TK7GLIM4cDsvY9MJ08SA=;
	b=JLjQw+W3RV2uSyb0BPk0UNr94Cef5X0HWav8EjMaojM3k13nB01+vhwhEZa3EQrv/5GWzL
	3d98JmR/FHgGGUcZq9oe1k0BImJLm6Rbeo2+wQrQtzQORCPK3KAOfsanJkpybdxsEQW651
	DbpZdlXwQx/I3UF+iFWyAvQxrN759EM=
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com
 [209.85.222.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-185-08_dv06-PbmJ4_7MUE3Hsw-1; Mon, 15 Apr 2024 10:33:49 -0400
X-MC-Unique: 08_dv06-PbmJ4_7MUE3Hsw-1
Received: by mail-qk1-f197.google.com with SMTP id af79cd13be357-78edd30a24fso234631085a.3
        for <dccp@vger.kernel.org>; Mon, 15 Apr 2024 07:33:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713191629; x=1713796429;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=vVrDx/bbmS5+gjreM3QEYo2TK7GLIM4cDsvY9MJ08SA=;
        b=QjeyFIiIMnGQCHZdGcMA3kd+s+tELxMqiADU4nYTXyXBPJ/dFeaHmtTHBQyvWks/r2
         DJEbCOQBZx+dhrUr4tdKo0IZaGNYXi4fILiuCpLOwiWOXsQPm+tTrguyV59b1soxdT1T
         pdOPi7RWs2fK6kO9ZX2KqvixViLk7XeZwYm/7RWVIh4tWW4n65e06A6POXIKwwrD9mbe
         5j+OhQxyJUHCygLwjhkraJFWMqPMqIM4EvhB8Mvpb1RhBr1UEcRtvCey7vp0VYp5++cU
         VfGIbs23AGpwIfOaTpdpaeg2TGQCDGusTUDA+NLPO9cjRiJFIhP2QjI7AMqCQGfrwE1y
         rePA==
X-Gm-Message-State: AOJu0YyjlTGTqZCMSiFiZa7cvOqMOiWheH8Gidr6rLaKMQBXaLU5iZvn
	B8GRHKJS1uhBM6p5hw/LbmS9bxGaoWv3t8IFvsutsCJr/eHD3Xx516q2aBNKcYIgAk6jGzwwUF7
	MH5jymrJwbEdpDW20J5QjPTUGllsaihKqkxaoh1IQSZLvUxoVayI=
X-Received: by 2002:a05:620a:3954:b0:78e:ddf7:6fe0 with SMTP id qs20-20020a05620a395400b0078eddf76fe0mr6573749qkn.12.1713191628928;
        Mon, 15 Apr 2024 07:33:48 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IEVrJdf1YrlbIDodHP7H3KT78ZybQZ1V4+ryioGJKTmmhKZaifv9jT+Tuqcjbx63KCbMDtb7g==
X-Received: by 2002:a05:620a:3954:b0:78e:ddf7:6fe0 with SMTP id qs20-20020a05620a395400b0078eddf76fe0mr6573724qkn.12.1713191628647;
        Mon, 15 Apr 2024 07:33:48 -0700 (PDT)
Received: from vschneid-thinkpadt14sgen2i.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id vq17-20020a05620a559100b0078ebb93d940sm6418319qkn.20.2024.04.15.07.33.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Apr 2024 07:33:48 -0700 (PDT)
From: Valentin Schneider <vschneid@redhat.com>
To: Eric Dumazet <edumazet@google.com>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-rt-users@vger.kernel.org, "David S.
 Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, Paolo
 Abeni <pabeni@redhat.com>, mleitner@redhat.com, David Ahern
 <dsahern@kernel.org>, Juri Lelli <juri.lelli@redhat.com>, Tomas Glozar
 <tglozar@redhat.com>, Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
 Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v5 0/2] tcp/dcpp: Un-pin tw_timer
In-Reply-To: <CANn89iJYX8e_3Or9a5Q55NuQ8ZAHfYL+p_SpM0yz91sdj4HqtQ@mail.gmail.com>
References: <20240415113436.3261042-1-vschneid@redhat.com>
 <CANn89iJYX8e_3Or9a5Q55NuQ8ZAHfYL+p_SpM0yz91sdj4HqtQ@mail.gmail.com>
Date: Mon, 15 Apr 2024 16:33:44 +0200
Message-ID: <xhsmhmspu8zlj.mognet@vschneid-thinkpadt14sgen2i.remote.csb>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 15/04/24 14:35, Eric Dumazet wrote:
> On Mon, Apr 15, 2024 at 1:34=E2=80=AFPM Valentin Schneider <vschneid@redh=
at.com> wrote:
>>
>> Hi,
>>
>> This is v5 of the series where the tw_timer is un-pinned to get rid of
>> interferences in isolated CPUs setups.
>>
>> The first patch is a new one stemming from Jakub's bug reported. It's th=
ere
>> mainly to make the reviewing a bit easier, but as it changes behaviour i=
t should
>> be squashed with the second one.
>>
>> Revisions
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> v4 -> v5
>> ++++++++
>>
>> o Rebased against latest Linus' tree
>> o Converted tw_timer into a delayed work following Jakub's bug report on=
 v4
>>   http://lore.kernel.org/r/20240411100536.224fa1e7@kernel.org
>
> What was the issue again ?
>
> Please explain precisely why it was fundamentally tied to the use of
> timers (and this was not possible to fix the issue without
> adding work queues and more dependencies to TCP stack)

In v4 I added the use of the ehash lock to serialize arming the timewait
timer vs destroying it (inet_twsk_schedule() vs inet_twsk_deschedule_put()).

Unfortunately, holding a lock both in a timer callback and in the context
in which it is destroyed is invalid. AIUI the issue is as follows:

  CPUx                        CPUy
  spin_lock(foo);
                              <timer fires>
                              call_timer_fn()
                                spin_lock(foo) // blocks
  timer_shutdown_sync()
    __timer_delete_sync()
      __try_to_del_timer_sync() // looped as long as timer is running
                       <deadlock>

In our case, we had in v4:

  inet_twsk_deschedule_put()
    spin_lock(ehash_lock);
                                          tw_timer_handler()
                                            inet_twsk_kill()
                                              spin_lock(ehash_lock);
                                              __inet_twsk_kill();
    timer_shutdown_sync(&tw->tw_timer);

The fix here is to move the timer deletion to a non-timer
context. Workqueues fit the bill, and as the tw_timer_handler() would just =
queue
a work item, I converted it to a delayed_work.

