Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A88E81426F
	for <dccp@vger.kernel.org>; Thu,  2 Nov 2023 11:15:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="UyRQN0WY"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2AFCE185
	for <dccp@vger.kernel.org>; Thu,  2 Nov 2023 04:14:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1698923698;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=5X9zXTo8eLbZpNfNphwqZUMseNZ35B8f3qHoWgzx6M0=;
	b=UyRQN0WYcFSZz4Dn8thqtY2nYcsdFEHEO2KsSUU928Svs0IA2cXzLRNAq0LboOcLTAXviP
	UNFYGa3KMwpLMP7JviHXnc5bgcljhLYRvNhuyXuyeNY73NPBDErXhL+/o05fWC1emUoH8s
	iHtdMd5DcuDtLGHprPr3mnmSm+Gbb3U=
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com
 [209.85.208.197]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-515-S8_LuyoYOumrJPNOGAbdng-1; Thu, 02 Nov 2023 07:14:57 -0400
X-MC-Unique: S8_LuyoYOumrJPNOGAbdng-1
Received: by mail-lj1-f197.google.com with SMTP id 38308e7fff4ca-2c3e3672dc8so1137711fa.1
        for <dccp@vger.kernel.org>; Thu, 02 Nov 2023 04:14:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1698923695; x=1699528495;
        h=mime-version:user-agent:content-transfer-encoding:references
         :in-reply-to:date:cc:to:from:subject:message-id:x-gm-message-state
         :from:to:cc:subject:date:message-id:reply-to;
        bh=5X9zXTo8eLbZpNfNphwqZUMseNZ35B8f3qHoWgzx6M0=;
        b=ujACkafhe7I9fOCTEqitGQEaqttpTFMudh3yQp5Xz5Eu/l60qliEcP19bUUBAi1pVa
         MufsJCE+qYuf10mDQLimNKBzx2dm1bPK0VkmM1ZLOI4fsY+hqqekBKFkGiYpYWqcmYM7
         2BdEtt1IE9LW0li2SqJQp0YK0g9b+sF1Cmfpa8VlRd4lm9N9+BjCACtCb4lxD+es+Jko
         UZ38xwlycjNOsbPt897gUAlIeAW5ZTjv8+k/dtNyKpUxfgdjPJKznRBjt/FWeYyQtyOS
         lTG46QdBKHw4EOko5gpUzTtZe7FumKO3Cy0Nns+kkAph6R7QTE2N1sLh9W4kBKjx2kv9
         2pVA==
X-Gm-Message-State: AOJu0YwsoCleMoqobmZeww2MDz4D29bs53sZ3tixaTWHzI61+7KTfk8h
	3Z40BqW/NdRuRR1B050uFlN3VT69EFiqjy9iJLB4ttjZLZtF4RJf05hKiySNSLIJQz50pS2OzTw
	6VDOujvP4CH1hkQ==
X-Received: by 2002:a2e:3306:0:b0:2c5:519:bb1b with SMTP id d6-20020a2e3306000000b002c50519bb1bmr12741485ljc.2.1698923695607;
        Thu, 02 Nov 2023 04:14:55 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IHIpcoz45TDqA5S9HUXzHFHPPonuHMZEBqFML5f/SHsIM081u0+qPTrXpL9C2SsQVtX6luAMw==
X-Received: by 2002:a2e:3306:0:b0:2c5:519:bb1b with SMTP id d6-20020a2e3306000000b002c50519bb1bmr12741468ljc.2.1698923695235;
        Thu, 02 Nov 2023 04:14:55 -0700 (PDT)
Received: from gerbillo.redhat.com (146-241-226-153.dyn.eolo.it. [146.241.226.153])
        by smtp.gmail.com with ESMTPSA id k16-20020a05600c1c9000b003fee567235bsm2654539wms.1.2023.11.02.04.14.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 02 Nov 2023 04:14:54 -0700 (PDT)
Message-ID: <f41c06eafd983584647e7d61561ea6282cdb735e.camel@redhat.com>
Subject: Re: [PATCH net] dccp: check for ccid in ccid_hc_tx_send_packet
From: Paolo Abeni <pabeni@redhat.com>
To: Bragatheswaran Manickavel <bragathemanick0908@gmail.com>, 
	davem@davemloft.net, edumazet@google.com, kuba@kernel.org
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, 
 syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
Date: Thu, 02 Nov 2023 12:14:53 +0100
In-Reply-To: <20231028144136.3462-1-bragathemanick0908@gmail.com>
References: <20231028144136.3462-1-bragathemanick0908@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.46.4 (3.46.4-1.fc37) 
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sat, 2023-10-28 at 20:11 +0530, Bragatheswaran Manickavel wrote:
> ccid_hc_tx_send_packet might be called with a NULL ccid pointer
> leading to a NULL pointer dereference

You should describe how such event could happen.

> Below mentioned commit has similarly changes
> commit 276bdb82dedb ("dccp: check ccid before dereferencing")
>=20
> Reported-by: syzbot+c71bc336c5061153b502@syzkaller.appspotmail.com
> Closes: https://syzkaller.appspot.com/bug?extid=3Dc71bc336c5061153b502

and add a suitable fixes here.

(beyond taking care of other critical code paths, as reported by Eric).

Thanks!

Paolo

