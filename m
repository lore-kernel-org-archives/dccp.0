Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CD41E15219A
	for <dccp@vger.kernel.org>; Mon, 22 Apr 2024 14:31:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713796315; cv=none; b=F9gdmI8r1V2Zgxt3Svj4dkQOP1yq8B1PIOfWgUqLXNQWDBnFPX0Z0NNok2ZMPl8e6nlHYriedTKTxgc95JNnxeolMtI4H/YddHDK0lWfPEsrOf9gvI+dmFZSovz0y2LF1ksOqbzvu5x1g1iOl8aFzx7PXK+h8JDKydUxDglExe4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713796315; c=relaxed/simple;
	bh=pzmC56HFWs/QTkhB91JQ7NJkOCAI0HM6A928WLI6WQg=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=NkWmWUzRBjZl4qlax+znwsDUGIi1jQ25JzYTKp04l4dAMbid/wgWdt9ZMOscEYKmsLVh6ipXaDV2ARAdKKDmKs1tIIk7VKCA+jlPWCYGxYWoBGqTmrsS7OpIJ8TgR4qXCZRT6NbX7hsqqj8HU3ptXI8gtOLLsLHe1mvKprVcjao=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iFAnxokI; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iFAnxokI"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1713796312;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=mhkGPPHbdmj1oVdDbXBZ1Ge+SsAT/eWQ0YBbLSXrT28=;
	b=iFAnxokI+3BAtParhICP/vRhXW1b5yGVTJJ6G2/QGbp9iUWkOHu8bzZU9I2K9YiYocsPoI
	NOQc5hhE0DD4Gwuw5WdcURBgqJMVxfK2zkxpPleCzqHWN/n5GP80KrKKlDrTOvs4Q1TmSO
	vOlOERv3XQ16B++VezehXj3WFs0Aq6o=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-29-RpFUEphdPuaSPkyDwRBhAg-1; Mon, 22 Apr 2024 10:31:46 -0400
X-MC-Unique: RpFUEphdPuaSPkyDwRBhAg-1
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-6a049c7d190so62949166d6.0
        for <dccp@vger.kernel.org>; Mon, 22 Apr 2024 07:31:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1713796306; x=1714401106;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=mhkGPPHbdmj1oVdDbXBZ1Ge+SsAT/eWQ0YBbLSXrT28=;
        b=cxy0q/On/Mh87CdgYhLMqmyTc9focCz+RS8FsLGj6KKHV/5jc0wwNl3wQ39pBEqNgC
         eXAR7F5viVXU/AmixNFWa+QtUhRDm1zCrY74rANPa3Tlbb1U75H1UShWRqMOs93iDCTZ
         yIk1eapn5BawY2Y8tUe12Cfhmgk3LmEYEznbWYSDKDxn1ewuvoHwEm3/kbUVkKhTbII1
         TKRFsWYmVLwJ7ACOe85MGqC03rvTxTUG95CNNGrLLMvHqiYUG+Pj9xIB2i9QeL3+3uwn
         BiTR5hb1HE8XGOimIU7wYpGNDcJk1fWWzYrmL5jBsynXf6W9RUSxeGjtY9msbNLlBncc
         pr0w==
X-Gm-Message-State: AOJu0YxKeBt+SuIAw1NNHmr+Fim5b3EiuZ9FrDcHNRXx3MSaoM02j6T1
	L2FFaA7qsX/jTDgzIzBioRFDt6W9vMUVbAgEyKkPdXvZCyngwnJ5VTr3gguc7g8z+rtJcWk2UGn
	jP8aPXjVtZf6DWhjb7kruZcmJ6k+AelDKzGyfaUmL7wvP69wnW5Y=
X-Received: by 2002:ad4:424f:0:b0:69b:1a43:27f5 with SMTP id l15-20020ad4424f000000b0069b1a4327f5mr10265936qvq.35.1713796305989;
        Mon, 22 Apr 2024 07:31:45 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFgAG0VNYTVd95FVX0FTRiJkrXveidEN6CjszexmNNUFWwDrDgOvzjbXwvC9ZePvx8e1ZiGoQ==
X-Received: by 2002:ad4:424f:0:b0:69b:1a43:27f5 with SMTP id l15-20020ad4424f000000b0069b1a4327f5mr10265921qvq.35.1713796305582;
        Mon, 22 Apr 2024 07:31:45 -0700 (PDT)
Received: from vschneid-thinkpadt14sgen2i.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id g12-20020a0cf08c000000b006913aa64629sm4260487qvk.22.2024.04.22.07.31.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 22 Apr 2024 07:31:45 -0700 (PDT)
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
In-Reply-To: <CANn89iJRev5Kn_jEgimDfyHosmiyYeaz2gHRGS2tcFC-yMbGaQ@mail.gmail.com>
References: <20240415113436.3261042-1-vschneid@redhat.com>
 <CANn89iJYX8e_3Or9a5Q55NuQ8ZAHfYL+p_SpM0yz91sdj4HqtQ@mail.gmail.com>
 <xhsmhmspu8zlj.mognet@vschneid-thinkpadt14sgen2i.remote.csb>
 <CANn89iJRev5Kn_jEgimDfyHosmiyYeaz2gHRGS2tcFC-yMbGaQ@mail.gmail.com>
Date: Mon, 22 Apr 2024 16:31:41 +0200
Message-ID: <xhsmhbk618o4y.mognet@vschneid-thinkpadt14sgen2i.remote.csb>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


Apologies for the delayed reply, I was away for most of last week;

On 16/04/24 17:01, Eric Dumazet wrote:
> On Mon, Apr 15, 2024 at 4:33=E2=80=AFPM Valentin Schneider <vschneid@redh=
at.com> wrote:
>>
>> On 15/04/24 14:35, Eric Dumazet wrote:
>> > On Mon, Apr 15, 2024 at 1:34=E2=80=AFPM Valentin Schneider <vschneid@r=
edhat.com> wrote:
>> >> v4 -> v5
>> >> ++++++++
>> >>
>> >> o Rebased against latest Linus' tree
>> >> o Converted tw_timer into a delayed work following Jakub's bug report=
 on v4
>> >>   http://lore.kernel.org/r/20240411100536.224fa1e7@kernel.org
>> >
>> > What was the issue again ?
>> >
>> > Please explain precisely why it was fundamentally tied to the use of
>> > timers (and this was not possible to fix the issue without
>> > adding work queues and more dependencies to TCP stack)
>>
>> In v4 I added the use of the ehash lock to serialize arming the timewait
>> timer vs destroying it (inet_twsk_schedule() vs inet_twsk_deschedule_put=
()).
>>
>> Unfortunately, holding a lock both in a timer callback and in the context
>> in which it is destroyed is invalid. AIUI the issue is as follows:
>>
>>   CPUx                        CPUy
>>   spin_lock(foo);
>>                               <timer fires>
>>                               call_timer_fn()
>>                                 spin_lock(foo) // blocks
>>   timer_shutdown_sync()
>>     __timer_delete_sync()
>>       __try_to_del_timer_sync() // looped as long as timer is running
>>                        <deadlock>
>>
>> In our case, we had in v4:
>>
>>   inet_twsk_deschedule_put()
>>     spin_lock(ehash_lock);
>>                                           tw_timer_handler()
>>                                             inet_twsk_kill()
>>                                               spin_lock(ehash_lock);
>>                                               __inet_twsk_kill();
>>     timer_shutdown_sync(&tw->tw_timer);
>>
>> The fix here is to move the timer deletion to a non-timer
>> context. Workqueues fit the bill, and as the tw_timer_handler() would ju=
st queue
>> a work item, I converted it to a delayed_work.
>
> I do not like this delayed work approach.
>
> Adding more dependencies to the TCP stack is not very nice from a
> maintainer point of view.
>
> Why couldn't you call timer_shutdown_sync() before grabbing the lock ?

We need the timer_shutdown_sync() and mod_timer() of tw->tw_timer to be
serialized in some way. If they aren't, we have the following race:

                             tcp_time_wait()
                               inet_twsk_hashdance()
  inet_twsk_deschedule_put()
    // Returns 0 because not pending, but prevents future arming
    timer_shutdown_sync()
                               inet_twsk_schedule()
                                 // Returns 0 as if timer had been succesfu=
lly armed
                                 mod_timer()

This means inet_twsk_deschedule_put() doesn't end up calling
inet_twsk_kill() (because the timer wasn't pending when it got shutdown),
but inet_twsk_schedule() doesn't arm it either despite the hashdance()
having updated the refcounts.

If we leave the deschedule as a del_timer_sync(), the timer ends up armed
in inet_twsk_schedule(), but that means waiting for the timer to fire to
clean up the resources despite having called inet_twsk_deschedule_put().

