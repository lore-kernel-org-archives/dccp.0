Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D11653A6
	for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 15:49:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nghZKH6b"
Received: from mail-ed1-x52c.google.com (mail-ed1-x52c.google.com [IPv6:2a00:1450:4864:20::52c])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3C08BF3
	for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 08:49:21 -0700 (PDT)
Received: by mail-ed1-x52c.google.com with SMTP id 4fb4d7f45d1cf-54357417e81so4268a12.0
        for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 08:49:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1698680960; x=1699285760; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=FkWEvSpj4EOzW1FIq48dR5K6zMnw3n6lBUOqN6Xvf9E=;
        b=nghZKH6b+lS1Z/EVQwhZix/byx/bJu0xcffRkCRaH4PS5oTTjZEixMhrDfleD9/iPX
         9we+bOgD8C3gPZ9m7ApXONgBa0ZSfZSCFcqx8tXYxTVq2gwCrcFCi3Xezqee6bqISoUO
         66Jb/7nKcdSkbm6vtRuCw9uFeEubg2j983J6jH8UwXNbIhAr+kadSsSz9hYXRUG42Es8
         dhWhEekCTaAFdkXeVSrOF0UX78VvXt1HUXhIUP7bgRv6MlGdtVo4BSQlMurJE40NNPfs
         ZukJzHa+5E+wu7xCt5rKXi92NczazCtzyOQDfSWbFsbHrgG5++cUKPAKg1VXh1dTYoCN
         j9JQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1698680960; x=1699285760;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=FkWEvSpj4EOzW1FIq48dR5K6zMnw3n6lBUOqN6Xvf9E=;
        b=IsKR2RX6tVMGUYn8/N484EDVxz4pJsBNcK3hAxtE20BSRLnlW/VUWcvQBDT+S4yxA5
         6hAmqOm0Xy5xq2NvrQOF57KOAG6JlELBLSYZtMYBn8kyKG3PBKBKWOjK1uaoYIQTUMzF
         ZQGN57u9a5mt9XdciwUmSWuusy4fVqUvsSCpBVz1vszkaHzVJ1Nt6Wm/xAovLhmYXQhU
         RC1I5/b5yPpdKncVmbefov/ZuDfNX31GQNxVpgZ/AvsG56BcC+51z9LVs3mnYoChM6HG
         bj0KuVfBQ8MYFC0BEtu0uDdVr2k6HpCnoD1TjcmKnh0bCrEyz28zvRJvy/ilIJtBSu33
         fl2w==
X-Gm-Message-State: AOJu0YxFhLrqxf1SY+/m5HBdnKMnuJGm8iboi15QHnkI9IkXikHwtv6A
	u+lgBgaCEdkcsJ4x+kjewA2avzOYMpLui2FzTxm7RnRsc9ppO+LLDeI=
X-Google-Smtp-Source: AGHT+IHmnsYDLOCh0X2FX2ePeYR5kt25POJ/6EJ5OuyPzDSCNjm9Kly3q4T57cyTmD//emtw3QSiA7mgey1mzsGEqjw=
X-Received: by 2002:a50:baee:0:b0:540:e63d:3cfb with SMTP id
 x101-20020a50baee000000b00540e63d3cfbmr130594ede.3.1698680960030; Mon, 30 Oct
 2023 08:49:20 -0700 (PDT)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20231028144136.3462-1-bragathemanick0908@gmail.com>
 <CANn89iJyLWy6WEa_1p+jKpGBfq=h=TX=_7p_-_i4j6mHcMXbgA@mail.gmail.com> <e38353e7-ea99-434b-9700-151ab2de6f85@gmail.com>
In-Reply-To: <e38353e7-ea99-434b-9700-151ab2de6f85@gmail.com>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 30 Oct 2023 16:49:06 +0100
Message-ID: <CANn89iKPTdE+oAB30gp4koC7ddnga20R8H6V3qismvvEP80aqg@mail.gmail.com>
Subject: Re: [PATCH net] dccp: check for ccid in ccid_hc_tx_send_packet
To: Bragatheswaran Manickavel <bragathemanick0908@gmail.com>
Cc: davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, 
	dccp@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
	syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 30, 2023 at 4:40=E2=80=AFPM Bragatheswaran Manickavel
<bragathemanick0908@gmail.com> wrote:
>
>
> On 30/10/23 14:29, Eric Dumazet wrote:
> > On Sat, Oct 28, 2023 at 4:41=E2=80=AFPM Bragatheswaran Manickavel
> > <bragathemanick0908@gmail.com> wrote:
> >> ccid_hc_tx_send_packet might be called with a NULL ccid pointer
> >> leading to a NULL pointer dereference
> >>
> >> Below mentioned commit has similarly changes
> >> commit 276bdb82dedb ("dccp: check ccid before dereferencing")
> >>
> >> Reported-by: syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
> >> Closes: https://syzkaller.appspot.com/bug?extid=3Dc71bc336c5061153b502
> >> Signed-off-by: Bragatheswaran Manickavel <bragathemanick0908@gmail.com=
>
> >> ---
> >>   net/dccp/ccid.h | 2 +-
> >>   1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
> >> index 105f3734dadb..1015dc2b9392 100644
> >> --- a/net/dccp/ccid.h
> >> +++ b/net/dccp/ccid.h
> >> @@ -163,7 +163,7 @@ static inline int ccid_packet_dequeue_eval(const i=
nt return_code)
> >>   static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct s=
ock *sk,
> >>                                           struct sk_buff *skb)
> >>   {
> >> -       if (ccid->ccid_ops->ccid_hc_tx_send_packet !=3D NULL)
> >> +       if (ccid !=3D NULL && ccid->ccid_ops->ccid_hc_tx_send_packet !=
=3D NULL)
> >>                  return ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb=
);
> >>          return CCID_PACKET_SEND_AT_ONCE;
> >>   }
> >> --
> >> 2.34.1
> >>
> > If you are willing to fix dccp, I would make sure that some of
> > lockless accesses to dccps_hc_tx_ccid
> > are also double checked and fixed.
> >
> > do_dccp_getsockopt() and dccp_get_info()
>
>
> Hi Eric,
>
> In both do_dccp_getsockopt() and dccp_get_info(), dccps_hc_rx_ccid are
> checked properly before access.
>

Not really, because another thread can change the value at the same time.

Adding checks is not solving races.
