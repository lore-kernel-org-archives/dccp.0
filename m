Return-Path: <dccp-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4AF6ECDB47E
	for <dccp@archiver.kernel.org>; Wed, 18 Oct 2023 15:01:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235255AbjJRPBG (ORCPT <rfc822;dccp@archiver.kernel.org>);
        Wed, 18 Oct 2023 11:01:06 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:50238 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229570AbjJRPBF (ORCPT <rfc822;dccp@vger.kernel.org>);
        Wed, 18 Oct 2023 11:01:05 -0400
Received: from mail-wm1-x32d.google.com (mail-wm1-x32d.google.com [IPv6:2a00:1450:4864:20::32d])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2C22BEA
        for <dccp@vger.kernel.org>; Wed, 18 Oct 2023 08:01:03 -0700 (PDT)
Received: by mail-wm1-x32d.google.com with SMTP id 5b1f17b1804b1-4078fe6a063so74155e9.1
        for <dccp@vger.kernel.org>; Wed, 18 Oct 2023 08:01:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1697641261; x=1698246061; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=Fk+MM8czq8tgZOqn2VBLd0vJ/2zm2P/1DV6ZL3LXnqE=;
        b=aAV69AUYEaScpeEE4dqzuh1sZIvqWOPFIphoLC8aRoiaT8GrEqautZKWObyyzrjvRn
         UrWfntfBBY3PlHLKvBFHO236zsWpGT0Femg6Be9eC6TBUmHlc8t7TsbecToKqBPscogd
         H7YSZJhIi4H8Wh+WVhIHRnoHT1pyU3L88I+Ovu9kOn+vcuc2Cvl83DFithEHOu3j2/ie
         DUth8KVwby4BnASthE5KHIb82K53Ao4D1hIy7LXlZU1GmVhymlbIi/WqfyirYlE/rSD2
         wG5mrjVNMVoqqThc3pyQ2u8OD4SWfUDDQTp9C2QuSJZFGbHKt1Tss4cVXcpUFYiVcm24
         aREg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1697641261; x=1698246061;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=Fk+MM8czq8tgZOqn2VBLd0vJ/2zm2P/1DV6ZL3LXnqE=;
        b=Vsb5755Pn7zCOzfNzKy+foFNSsneUQcGuNfuJZpQtYFZg7tKkYgsivDs7nEckoOkqj
         qXnb47bYoY6T5+pOUE1Eaw9jSTeobs5iuhNb8KPSgt+CkKGjaUowRhSd/9IdIw0AsbUQ
         J215YhG0CwjR8gHn+4RCKdH4i5Sm8k+k4FGiPN9CeKx4A7QeHmdjO3ynOIyUwLXuiD4J
         GkFypRGRPiwJ6K+sn86/mVsaK/+9f7JiepW0sJI++vJNLb1+BFh3YT9UGzAtXVjCglIs
         2/IZ/OYUcXukJeEr4n2yxIAdht+r9MSXhViyv4GY4LNGTqcyxngi2W2V1vyJuUgHA6D7
         xzuQ==
X-Gm-Message-State: AOJu0Yza+B7GPe8c5YBJUlV3YMnasZjM9TIz+sgKBz5FwNs5jxa7Op5z
        8SmUZVroHwjLNAzRLsks0UAosyaFhaPnYY5w1GfcWOJtX0on0fyjlMpUaA==
X-Google-Smtp-Source: AGHT+IFWwSb1RVFY6lDcXkgSyswXKbEpQdqRJL3k+/d4+rZy2CE3vpR2U4Gis3Ebw3YUMony2CiNFuWPAhLI9dg3x/Q=
X-Received: by 2002:a1c:790b:0:b0:405:38d1:e146 with SMTP id
 l11-20020a1c790b000000b0040538d1e146mr135173wme.4.1697641261203; Wed, 18 Oct
 2023 08:01:01 -0700 (PDT)
MIME-Version: 1.0
References: <20231016125934.1970789-1-vschneid@redhat.com> <CANn89i+pQ3j+rb2SjFWjCU7BEges3TADDes5+csEr1JJamtzPQ@mail.gmail.com>
 <xhsmhil74m10c.mognet@vschneid.remote.csb>
In-Reply-To: <xhsmhil74m10c.mognet@vschneid.remote.csb>
From:   Eric Dumazet <edumazet@google.com>
Date:   Wed, 18 Oct 2023 17:00:46 +0200
Message-ID: <CANn89iJUicsEdbp7qrsaSUg8jQ=dBUr0nK296LxXp5rnPrw8cA@mail.gmail.com>
Subject: Re: [RFC PATCH] tcp/dcpp: Un-pin tw_timer
To:     Valentin Schneider <vschneid@redhat.com>
Cc:     dccp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>,
        Paolo Abeni <pabeni@redhat.com>,
        David Ahern <dsahern@kernel.org>,
        Juri Lelli <juri.lelli@redhat.com>,
        Tomas Glozar <tglozar@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
List-ID: <dccp.vger.kernel.org>
X-Mailing-List: dccp@vger.kernel.org

On Wed, Oct 18, 2023 at 4:57=E2=80=AFPM Valentin Schneider <vschneid@redhat=
.com> wrote:

>
> Looks reasonable to me, I'll go write v2.
>
> Thanks for the help!

Sure thing !

BTW, we also use TIMER_PINNED for req->rsk_timer, are you working on it too=
 ?
