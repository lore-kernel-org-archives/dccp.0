Return-Path: <dccp-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61996CDB47E
	for <dccp@archiver.kernel.org>; Wed, 18 Oct 2023 14:58:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1345087AbjJRO6d (ORCPT <rfc822;dccp@archiver.kernel.org>);
        Wed, 18 Oct 2023 10:58:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60982 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1345109AbjJRO6c (ORCPT <rfc822;dccp@vger.kernel.org>);
        Wed, 18 Oct 2023 10:58:32 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BB86BBA
        for <dccp@vger.kernel.org>; Wed, 18 Oct 2023 07:57:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1697641064;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=929sHe0GqloPiKWV58z9G1yiEL0iCqJOnGu3b5vkn9k=;
        b=A4bb7bUhGrgHuTJ2c72Guo7cEBbg6E4we7jeScY8XKmfu43w20QbOfxjI6+Xe/FYPm/Q52
        LmFwlhjlGRLbyh9+MHJhaMMij2CNgvoK/0yCbWKo59wH8LT6JLEDq2ZFk0oHwQKzl3Ai/1
        5f6yEz/NFTcxtRSf0MhV+dPVcAt5jKA=
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com
 [209.85.167.199]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-433-rjh_LBabPcGtC1M5lIk2bg-1; Wed, 18 Oct 2023 10:57:43 -0400
X-MC-Unique: rjh_LBabPcGtC1M5lIk2bg-1
Received: by mail-oi1-f199.google.com with SMTP id 5614622812f47-3ae65e9d394so9590372b6e.2
        for <dccp@vger.kernel.org>; Wed, 18 Oct 2023 07:57:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697641062; x=1698245862;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=929sHe0GqloPiKWV58z9G1yiEL0iCqJOnGu3b5vkn9k=;
        b=VSkubwNR0cAbmzpQQVCZT2cSEKXap8nISXC2Pj4++2pfVE8H1FPb/2nbMM6w7mM7aM
         raxS+NYla6U79wUwX8i+Cy7F9Qw8RDg9f8cIJ3XKrRiX8XflweHpY9NjBTbsYlGYSXuv
         Bk1Mlf6OyKwVu4wsanrbLIkYsnDkHKQ5kWoGjOgHQgG1Y4f7iCsaxJqFcxLVX0bX68wI
         o1sh1loNNoUWW2tpRAJaDJ2UJvjTP0oiahBwxmXySuBITH98ewtKozGo9/holLAkeWg6
         WWsD/DA/izEtNTFIhPnQL5MShXQpHTLYXwK8JT3VbRU3k/OYqP70KAg775h3QbCdZm9w
         8K5g==
X-Gm-Message-State: AOJu0YwPP4aq7yfbLd3zuFHqPQ6zP50xM+PLZAO+F5vLTd6NaI8KOG6N
        /1uJp327Rc1H29utWNcaqNXUE4Fh+jO5jGsil4rr6w/Rq1iaenZlChhCHIrx7C81Ymg5T66MoRs
        PwJ5zISaPx58ixA==
X-Received: by 2002:a05:6808:685:b0:3a9:e8e2:57a7 with SMTP id k5-20020a056808068500b003a9e8e257a7mr5130533oig.53.1697641062544;
        Wed, 18 Oct 2023 07:57:42 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFlTaAuCZ+WGM/yTbr4Akp0ylPrazS8xDJ9YmXz8Jrm+XLu5qIkNdbRCxoExwzI82bjSJAq2g==
X-Received: by 2002:a05:6808:685:b0:3a9:e8e2:57a7 with SMTP id k5-20020a056808068500b003a9e8e257a7mr5130514oig.53.1697641062140;
        Wed, 18 Oct 2023 07:57:42 -0700 (PDT)
Received: from vschneid.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id bl31-20020a05620a1a9f00b00767d4a3f4d9sm15800qkb.29.2023.10.18.07.57.40
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Oct 2023 07:57:41 -0700 (PDT)
From:   Valentin Schneider <vschneid@redhat.com>
To:     Eric Dumazet <edumazet@google.com>
Cc:     dccp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        David Ahern <dsahern@kernel.org>,
        Juri Lelli <juri.lelli@redhat.com>,
        Tomas Glozar <tglozar@redhat.com>
Subject: Re: [RFC PATCH] tcp/dcpp: Un-pin tw_timer
In-Reply-To: <CANn89i+pQ3j+rb2SjFWjCU7BEges3TADDes5+csEr1JJamtzPQ@mail.gmail.com>
References: <20231016125934.1970789-1-vschneid@redhat.com>
 <CANn89i+pQ3j+rb2SjFWjCU7BEges3TADDes5+csEr1JJamtzPQ@mail.gmail.com>
Date:   Wed, 18 Oct 2023 16:57:39 +0200
Message-ID: <xhsmhil74m10c.mognet@vschneid.remote.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <dccp.vger.kernel.org>
X-Mailing-List: dccp@vger.kernel.org

On 16/10/23 17:40, Eric Dumazet wrote:
> On Mon, Oct 16, 2023 at 3:00=E2=80=AFPM Valentin Schneider <vschneid@redh=
at.com> wrote:
>>
>> The TCP timewait timer is proving to be problematic for setups where sch=
eduler
>> CPU isolation is achieved at runtime via cpusets (as opposed to statical=
ly via
>> isolcpus=3Ddomains).
>>
>> What happens there is a CPU goes through tcp_time_wait(), arming the tim=
e_wait
>> timer, then gets isolated. TCP_TIMEWAIT_LEN later, the timer fires, caus=
ing
>> interference for the now-isolated CPU. This is conceptually similar to t=
he issue
>> described in
>>   e02b93124855 ("workqueue: Unbind kworkers before sending them to exit(=
)")
>>
>> Making the timer un-pinned would resolve this, as it would be queued onto
>> HK_FLAG_TIMER CPUs. It would Unfortunately go against
>>   ed2e92394589 ("tcp/dccp: fix timewait races in timer handling")
>> as we'd need to arm the timer after the *hashdance() to not have it fire=
 before
>> we've finished setting up the timewait_socket.
>>
>> However, looking into this, I cannot grok what race is fixed by having t=
he timer
>> *armed* before the hashdance.
>
> That was because :
>
> 1) the timer could expire before we had a chance to set refcnt to
> a non zero value. I guess this is fine if we use an extra atomic decremen=
t.
>
> OR
>
> 2) another cpu could find the TW and delete it (trying to cancel the
> tw_timer) before
>    we could arm the timer.  ( inet_twsk_deschedule_put() is using
> del_timer_sync() followed by inet_twsk_kill())
>
> Thus the tw timer would be armed for 60 seconds, then we would have to
> wait for the timer to really
> get rid of the tw structure.
>
> I think you also need to change inet_twsk_deschedule_put() logic ?
>

Gotcha, thank you for pointing it out.

>> Keep softirqs disabled, but make the timer un-pinned and arm it after the
>> hashdance. Remote CPUs may start using the timewait socket before the ti=
mer is
>> armed, but their execution of __inet_lookup_established() won't prevent =
the
>> arming of the timer.
>
> OK, I guess we can live with the following race :
>
> CPU0
>
>    allocates a tw, insert it in hash table
>
> CPU1:                               finds the TW and removes it (timer
> cancel does nothing)
>
> CPU0
>    arms a TW timer, lasting
>

Looks reasonable to me, I'll go write v2.

Thanks for the help!

