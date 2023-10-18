Return-Path: <dccp-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9439ECDB47E
	for <dccp@archiver.kernel.org>; Wed, 18 Oct 2023 15:28:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231472AbjJRP2K (ORCPT <rfc822;dccp@archiver.kernel.org>);
        Wed, 18 Oct 2023 11:28:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:57818 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230444AbjJRP2J (ORCPT <rfc822;dccp@vger.kernel.org>);
        Wed, 18 Oct 2023 11:28:09 -0400
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id BA77098
        for <dccp@vger.kernel.org>; Wed, 18 Oct 2023 08:27:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1697642844;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:content-type:content-type:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=LO3U/3O7orcDX1UKblPetHP+0g37M+8wNFC9UUNpGbg=;
        b=CYutXAeyKfMF66i6HF0a6bvZuMk8XYzpI7MZzxXaLCmDOVztYl9V7grttxXdjmP6d80vQz
        kklUPX5RxOJknnK6/wN6aMnT3iLwGg8klPJoovGTU/WSy4YxL0BVL7Kh8Ah7qLNSyriF9c
        WjAW7QmE9zd/EXl0K3lqKXJoiZNGijs=
Received: from mail-qv1-f70.google.com (mail-qv1-f70.google.com
 [209.85.219.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-428-isUJ8aLWPHuKCa0W-nIBYQ-1; Wed, 18 Oct 2023 11:27:23 -0400
X-MC-Unique: isUJ8aLWPHuKCa0W-nIBYQ-1
Received: by mail-qv1-f70.google.com with SMTP id 6a1803df08f44-66d253b90a1so56214196d6.2
        for <dccp@vger.kernel.org>; Wed, 18 Oct 2023 08:27:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697642843; x=1698247643;
        h=content-transfer-encoding:mime-version:message-id:date:references
         :in-reply-to:subject:cc:to:from:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=LO3U/3O7orcDX1UKblPetHP+0g37M+8wNFC9UUNpGbg=;
        b=Su8H0zdzgpjzBS9ZA85cTdSnIN1t7aWRF2Eg56u4PJsUmC441tP1n6NftiqRB8j1qF
         ZV3EZzzPv45zlp3BKGbAgqGuWXgWDKePLPuC7zS1ow6xF9vDAZEHjmSIiZabONozppvh
         h4c1uyqXG9L48113z+35mNXxgqY0TsO+qHjXsKV73QKCRZD+d4lbX5hAfKBHC1o5kSo2
         V3Lw1+VmxVtkw1+Eiq6ZqwsmiR+O3DGC5rW2/F8VIAigixIfyI9dPZBtHDU6yFx1L2pv
         JK5rCYj8F+9U0LrSEm6m+Lv9wt2ZNcyWMf7RZl4+zzLD8G2L6J7kM3VAR0CEt3E+wKkf
         yNPw==
X-Gm-Message-State: AOJu0YzVBqYX8jCpAGo/K9fq7SBibFU5ykJUvT98mAC0I9rmk8ziDe/G
        uXKP8tnYZM1m4pcHCQZyxaVqNzv6WPhsPCZ1N32adunw5ScQNPDTGjh04INXeg505GYmUN/LH4T
        e9rrbVU1vJ2zgXw==
X-Received: by 2002:a05:6214:2602:b0:66c:ffe1:e244 with SMTP id gu2-20020a056214260200b0066cffe1e244mr7592498qvb.62.1697642842849;
        Wed, 18 Oct 2023 08:27:22 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IH6fCGqNMshOHcVQgHFixpMRES/AbjqtXvQxpoRaWfInZXTWRZ0YrGHrSAVlJmDRabVuafBLg==
X-Received: by 2002:a05:6214:2602:b0:66c:ffe1:e244 with SMTP id gu2-20020a056214260200b0066cffe1e244mr7592455qvb.62.1697642842210;
        Wed, 18 Oct 2023 08:27:22 -0700 (PDT)
Received: from vschneid.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id dy20-20020ad44e94000000b006588bd29c7esm35137qvb.28.2023.10.18.08.27.19
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 18 Oct 2023 08:27:21 -0700 (PDT)
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
In-Reply-To: <CANn89iJUicsEdbp7qrsaSUg8jQ=dBUr0nK296LxXp5rnPrw8cA@mail.gmail.com>
References: <20231016125934.1970789-1-vschneid@redhat.com>
 <CANn89i+pQ3j+rb2SjFWjCU7BEges3TADDes5+csEr1JJamtzPQ@mail.gmail.com>
 <xhsmhil74m10c.mognet@vschneid.remote.csb>
 <CANn89iJUicsEdbp7qrsaSUg8jQ=dBUr0nK296LxXp5rnPrw8cA@mail.gmail.com>
Date:   Wed, 18 Oct 2023 17:27:18 +0200
Message-ID: <xhsmhfs28lzmx.mognet@vschneid.remote.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <dccp.vger.kernel.org>
X-Mailing-List: dccp@vger.kernel.org

On 18/10/23 17:00, Eric Dumazet wrote:
> On Wed, Oct 18, 2023 at 4:57=E2=80=AFPM Valentin Schneider <vschneid@redh=
at.com> wrote:
>
>>
>> Looks reasonable to me, I'll go write v2.
>>
>> Thanks for the help!
>
> Sure thing !
>
> BTW, we also use TIMER_PINNED for req->rsk_timer, are you working on it t=
oo ?

Ah, no, that wasn't on my radar. This hasn't shown up on our systems
yet. From a cursory look it does look like it could lead to similar issues,
I'll add that to my todolist. Thanks!

