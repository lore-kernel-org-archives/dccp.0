Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1B9814A089
	for <dccp@vger.kernel.org>; Tue, 25 Jun 2024 09:50:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719309003; cv=none; b=oxrimXJgdhzNF7+hw9YoyD0toYiOmcYVilJ71U0Lu/AJ5eAZZraMfCijeXgu6reb5fxzNekCAaXtyVvYMKMMIvMy1ftQCL2FqyqZ0sDfUDIv5MbXeWlaDGSEIOFx90EYRKPAzFbUE7eE8jkKWdzCiVRBxwmhp5BngCJnXJkixcU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719309003; c=relaxed/simple;
	bh=A03mgbNmGjbLch5TeEoOwpCQwRBej8p0QYPVVQHgDE4=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=Wp2giGQj5jmePhwDH+0tOjnVJhHkRJ+Gj7vPzmzO0lIy3ZjxcbyBkOXnLyerHOT7ax0V/fjGkrKg/aVKXL43ggM7JBprO7Gr90n2J846HoLdi/IbFAXQ8/xxMhtt09cUU8BaZt2x+lw9VwTD1nhafWPD/kkl7CKHoM6l4TCvtwc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=APNcugPk; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="APNcugPk"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1719309000;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references:autocrypt:autocrypt;
	bh=psNMkpNTGDQzWk3QAta1KKRmCYENugFYCSyQR3BM+L8=;
	b=APNcugPkR5yRFPhzDCu2Y/z7RanIJnG3SZHWk5K+4pQ3qSCAI9/zmPedI9P8spLKHKxiG1
	7PQQtRSDzo655fsY59o7rfKHqCco4IoVmIrVJ2LiIZPUftCz3CVu/76oBL9ffX9khs7ZbO
	RWXnpGPGFEV4ip0uolEQbiVcrKQXRUc=
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com
 [209.85.167.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-50-e_ha2kqKOIy0GqYZb0VQQw-1; Tue, 25 Jun 2024 05:49:55 -0400
X-MC-Unique: e_ha2kqKOIy0GqYZb0VQQw-1
Received: by mail-lf1-f71.google.com with SMTP id 2adb3069b0e04-52cd9f8827cso468274e87.2
        for <dccp@vger.kernel.org>; Tue, 25 Jun 2024 02:49:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1719308994; x=1719913794;
        h=mime-version:user-agent:content-transfer-encoding:autocrypt
         :references:in-reply-to:date:cc:to:from:subject:message-id
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=psNMkpNTGDQzWk3QAta1KKRmCYENugFYCSyQR3BM+L8=;
        b=UHY57qb8cUh9EHJ8uSp8U8VzfhfCsQEwKXocOyrBqCxciJ1xd8Gvkc3H3BhBouW/d5
         0yHz0FFCzQe1HoQ3ee5xNCAgTmSgaRgdO6a+SIBTfharBfSkhmVQYtJTVH0wdFmoMGkz
         7J2nUSv28aI1PTt+8uleiKtunAkV4SI6aMy1oejyUNUc2TQr+5xXydOe1AkV8MF6y+LB
         xFVPJc7h4eIgk4nHrpVd0l1pDkD7zfiQfr2z2FnQPAzCrlBiSRwR6Hpat4Ww9zW8MfLm
         dRCnY4MWY+vkd0j86kEEdAahHog1GEK8g78ynakKZaBW+qQqAG7DPzQB3LPHrYrIOz6x
         SlFg==
X-Gm-Message-State: AOJu0YwjqtiJIdmgNhUcqcY7y2SVCZnx/7Zxo9lix9rme8Iss5a8tIeM
	rLyEuCo/mts/dm8eQpfrQSwsoXMB9uIaZwy9lzBWsvqa/y7jo5PwDQzaYPjBvUS0tkB3lO16Iog
	ruxJLIdzJMIqb/Bza35Gntw6VPsk/dwBGOa7R0ywa+eMsVbYab9w=
X-Received: by 2002:a05:6512:3484:b0:52c:df28:de54 with SMTP id 2adb3069b0e04-52cdf28def2mr3963802e87.4.1719308993957;
        Tue, 25 Jun 2024 02:49:53 -0700 (PDT)
X-Google-Smtp-Source: AGHT+IFpr5j+DHVEDwph2UELN1gJ7+NW8BC0MPTSCjKHUvq7DvAMIqxUYK/rpfqmyzXv4fBz+CiemA==
X-Received: by 2002:a05:6512:3484:b0:52c:df28:de54 with SMTP id 2adb3069b0e04-52cdf28def2mr3963781e87.4.1719308993538;
        Tue, 25 Jun 2024 02:49:53 -0700 (PDT)
Received: from gerbillo.redhat.com ([2a0d:3341:b0ae:da10::f71])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4247d0b636bsm210282705e9.6.2024.06.25.02.49.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 25 Jun 2024 02:49:53 -0700 (PDT)
Message-ID: <35f497afd90fe16ba1408f25ea1ff62af6a73a90.camel@redhat.com>
Subject: Re: [PATCH net v4] Fix race for duplicate reqsk on identical SYN
From: Paolo Abeni <pabeni@redhat.com>
To: luoxuanqiang <luoxuanqiang@kylinos.cn>, kuniyu@amazon.com, 
	edumazet@google.com, kuba@kernel.org, davem@davemloft.net
Cc: dccp@vger.kernel.org, dsahern@kernel.org, fw@strlen.de, 
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
	alexandre.ferrieux@orange.com
Date: Tue, 25 Jun 2024 11:49:51 +0200
In-Reply-To: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
References: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
Autocrypt: addr=pabeni@redhat.com; prefer-encrypt=mutual; keydata=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
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.50.4 (3.50.4-1.fc39) 
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Fri, 2024-06-21 at 09:39 +0800, luoxuanqiang wrote:
> When bonding is configured in BOND_MODE_BROADCAST mode, if two identical
> SYN packets are received at the same time and processed on different CPUs=
,
> it can potentially create the same sk (sock) but two different reqsk
> (request_sock) in tcp_conn_request().
>=20
> These two different reqsk will respond with two SYNACK packets, and since
> the generation of the seq (ISN) incorporates a timestamp, the final two
> SYNACK packets will have different seq values.
>=20
> The consequence is that when the Client receives and replies with an ACK
> to the earlier SYNACK packet, we will reset(RST) it.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> This behavior is consistently reproducible in my local setup,
> which comprises:
>=20
>                   | NETA1 ------ NETB1 |
> PC_A --- bond --- |                    | --- bond --- PC_B
>                   | NETA2 ------ NETB2 |
>=20
> - PC_A is the Server and has two network cards, NETA1 and NETA2. I have
>   bonded these two cards using BOND_MODE_BROADCAST mode and configured
>   them to be handled by different CPU.
>=20
> - PC_B is the Client, also equipped with two network cards, NETB1 and
>   NETB2, which are also bonded and configured in BOND_MODE_BROADCAST mode=
.
>=20
> If the client attempts a TCP connection to the server, it might encounter
> a failure. Capturing packets from the server side reveals:
>=20
> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855116,
> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855123, <=3D=3D
> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117, <=3D=3D
> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117,
>=20
> Two SYNACKs with different seq numbers are sent by localhost,
> resulting in an anomaly.
>=20
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>=20
> The attempted solution is as follows:
> Add a return value to inet_csk_reqsk_queue_hash_add() to confirm if the
> ehash insertion is successful (Up to now, the reason for unsuccessful
> insertion is that a reqsk for the same connection has already been
> inserted). If the insertion fails, release the reqsk.
>=20
> Due to the refcnt, Kuniyuki suggests also adding a return value check
> for the DCCP module; if ehash insertion fails, indicating a successful
> insertion of the same connection, simply release the reqsk as well.
>=20
> Simultaneously, In the reqsk_queue_hash_req(), the start of the
> req->rsk_timer is adjusted to be after successful insertion.
>=20
> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")

Just after applying the patch I wondered if the issue addressed here
should be observable only after commit e994b2f0fb92 ("tcp: do not lock
listener to process SYN packets")?

In practice it should not matter as the latter commit it's older than
the currently older LST, but I'm wondering if I read the things
correctly?

Thanks!

Paolo

