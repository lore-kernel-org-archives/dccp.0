Received: from mail-ej1-f46.google.com (mail-ej1-f46.google.com [209.85.218.46])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 565531F3BAB
	for <dccp@vger.kernel.org>; Wed,  2 Apr 2025 21:14:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.218.46
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1743628472; cv=none; b=k9IEw8dwXjZujNwdUWqCE57wHsEfIlbjouv9F66zcX1HRKj6+D0Go3kXBUx2XADlML4bgkdasALa4ginu0/uy+Jx/F+gMi3HIM35ol7kNoo/DdRCW+t5PUDlN09zcu/54IxP0Ri0zp4t3zBAgYzDwKkzMMNmEwpbER1+/HFrjsQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1743628472; c=relaxed/simple;
	bh=yMtg/5bd9WuFFPh1QUVVbVzPyQ8PxgEFM//QPDYEqaE=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=EYYUMAo4kQ64ctoW4Sl5FFjVSHJBegpdril9t0mJ/fG1vOSEmOvJM9Wdcj7ViLSF33nW5/UhEK77LUwMVWqgAGRR6ZcA4TLQjkc4DxUHA26sydd3XvTv0p7MvvWFRR4oQmrCSHmdeVKkVtUWmpaHXtcBIWRDnuKnHRxbgZL51xs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org; spf=pass smtp.mailfrom=linuxfoundation.org; dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b=Vj9GgJ8z; arc=none smtp.client-ip=209.85.218.46
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=linuxfoundation.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=linux-foundation.org header.i=@linux-foundation.org header.b="Vj9GgJ8z"
Received: by mail-ej1-f46.google.com with SMTP id a640c23a62f3a-ac298c8fa50so36374066b.1
        for <dccp@vger.kernel.org>; Wed, 02 Apr 2025 14:14:29 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=linux-foundation.org; s=google; t=1743628468; x=1744233268; darn=vger.kernel.org;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:from:to:cc:subject:date:message-id:reply-to;
        bh=6vOkaWbZeGW9ejcyKHqKRgGRaPzQmhuks1cZQp6R9ag=;
        b=Vj9GgJ8zKvA6e8ELqWCdTUURFhktlkpRmwAwZhwjeHxPscHXfoqAEptq/2uF0EJ1/0
         B37oLYg6GmtLweMVcqlxdOEVflvDdWZm/Abxk8GkPJehQWPbtDroh3GhnbI189oPHanq
         SYrEZaPwE+e7O5RQ/sJ/tuzwzyUxTmUkaBWj8=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1743628468; x=1744233268;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to;
        bh=6vOkaWbZeGW9ejcyKHqKRgGRaPzQmhuks1cZQp6R9ag=;
        b=Dw2zQRkinOp3eA1GqL7/qj3fYyaSITw2JY+lnc4HOgIJp8FXcb0bj+95PLrgssN+AN
         EBh0h7cRouTE1PpeX1qpVR7y6RjLmqQ4TZZSRBkFeu+maZkQ2+YMGRowYDkijNCoMUyS
         w1yZbqq3b0bK0wDyXeLABLDe98f1b5ZwYinTpj4dtsoOd8T4dU1HS86ttKTH6mpDP4Cn
         cu6zCSFQxepM+qGZJ8+/y1T2nFoSBZxF4ZBsVtw9j/BKq19xI1dfgAec6ZklGSUI5V9e
         SzRYgHVDE+GKGGjCMgooQlE2oOpjGbKF5Ci6uQR+aiWQza/AL+og3p02c4T/1Rzv9iez
         VeRw==
X-Forwarded-Encrypted: i=1; AJvYcCUj3/cK6qZpMo2WROtBKUdyYPKBAvGVOzXSpadXMmjVgBtU6tFB868ITeT370kq88igoj1Y@vger.kernel.org
X-Gm-Message-State: AOJu0Yyy/tR+ZGKAvFm+9uBOZHFIL8ZdB0tCKRTPZM/LbKA9PmRGbnEO
	cZU2lOAdfbCTsmP8Aem+Lbfjo0oBWWE1ImKgFHdtvwaF/a18akHvU2XpU28ihXUIMjZ6KtCM/Rh
	j5q3Ysg==
X-Gm-Gg: ASbGncuy3hgXr8mKyqRPbb9QScm7d+JK4fLhM4wFafi1EteRDLTu9b/JggetlD6fF5d
	UmB1YFkmzl94a/Ok4KDQekvJXKsMkL2QMmcIHLt7tSy7+8EEqqZVxlg8eM0scwNFnwFGKXDDVIY
	HMq4vtVmhAmke7+sQl31OEh8b7aLXvFpAv+up0x9WzOUdxK9UoWLIqO+ey7KxJMeYuqoAS+dSrm
	Rb1amSFqgwJBOnSFkifgK0PylsjE+s6KYLoB/t11Fign7PCjblKI/OyJsbvqJNubIZPWtlxb2Hp
	YMG5OHxtbEf+mY7w0Q1/wQv5U9bU+LB83G/F+4CmeojbzWqlUEZf+S5HfHCrnbNBmXNS7dFIXOe
	3muXfK2Hkcd3cw1LxUag=
X-Google-Smtp-Source: AGHT+IEQUc3JAcppvrW5KsNhSh1anFC03UD1N+HlELa60rYqebffPvMMFOlf9sAK7ejcMlld9IlU7g==
X-Received: by 2002:a17:907:d86:b0:ac3:121e:f2cb with SMTP id a640c23a62f3a-ac7bc03af5cmr21504966b.1.1743628468439;
        Wed, 02 Apr 2025 14:14:28 -0700 (PDT)
Received: from mail-ej1-f53.google.com (mail-ej1-f53.google.com. [209.85.218.53])
        by smtp.gmail.com with ESMTPSA id a640c23a62f3a-ac719220358sm959671166b.36.2025.04.02.14.14.27
        for <dccp@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Wed, 02 Apr 2025 14:14:28 -0700 (PDT)
Received: by mail-ej1-f53.google.com with SMTP id a640c23a62f3a-ac298c8fa50so36371466b.1
        for <dccp@vger.kernel.org>; Wed, 02 Apr 2025 14:14:27 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AJvYcCU8DTAJB7IgkxY7INkQuyCtRAX98qPBHjDQxKWU5MBT6WR7lHtFGDed9sAcadUgFDtO36ZO@vger.kernel.org
X-Received: by 2002:a17:907:9409:b0:ac7:970b:8ee5 with SMTP id
 a640c23a62f3a-ac7bc126208mr19593966b.27.1743628091735; Wed, 02 Apr 2025
 14:08:11 -0700 (PDT)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <Z-sDc-0qyfPZz9lv@mini-arch> <39515c76-310d-41af-a8b4-a814841449e3@samba.org>
 <407c1a05-24a7-430b-958c-0ca78c467c07@samba.org> <ed2038b1-0331-43d6-ac15-fd7e004ab27e@samba.org>
 <Z+wH1oYOr1dlKeyN@gmail.com> <Z-wKI1rQGSgrsjbl@mini-arch> <0f0f9cfd-77be-4988-8043-0d1bd0d157e7@samba.org>
 <Z-xi7TH83upf-E3q@mini-arch> <4b7ac4e9-6856-4e54-a2ba-15465e9622ac@samba.org>
 <20250402132906.0ceb8985@pumpkin> <Z-1Hgv4ImjWOW8X2@mini-arch> <20250402214638.0b5eed55@pumpkin>
In-Reply-To: <20250402214638.0b5eed55@pumpkin>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 2 Apr 2025 14:07:54 -0700
X-Gmail-Original-Message-ID: <CAHk-=wi7p9bKgZt1E1BWE-NjwSRDBQs=Coviiz0ZTQy9OhHvPg@mail.gmail.com>
X-Gm-Features: AQ5f1JpKVAIlc4pALP5yKNCr8F3ijIqVBIOCCdqoIfNZomenel-ajZbKWJ5EdvE
Message-ID: <CAHk-=wi7p9bKgZt1E1BWE-NjwSRDBQs=Coviiz0ZTQy9OhHvPg@mail.gmail.com>
Subject: Re: [RFC PATCH 0/4] net/io_uring: pass a kernel pointer via optlen_t
 to proto[_ops].getsockopt()
To: David Laight <david.laight.linux@gmail.com>
Cc: Stanislav Fomichev <stfomichev@gmail.com>, Stefan Metzmacher <metze@samba.org>, 
	Breno Leitao <leitao@debian.org>, Jens Axboe <axboe@kernel.dk>, 
	Pavel Begunkov <asml.silence@gmail.com>, Jakub Kicinski <kuba@kernel.org>, Christoph Hellwig <hch@lst.de>, 
	Karsten Keil <isdn@linux-pingi.de>, Ayush Sawal <ayush.sawal@chelsio.com>, 
	Andrew Lunn <andrew+netdev@lunn.ch>, "David S. Miller" <davem@davemloft.net>, 
	Eric Dumazet <edumazet@google.com>, Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
	Kuniyuki Iwashima <kuniyu@amazon.com>, Willem de Bruijn <willemb@google.com>, David Ahern <dsahern@kernel.org>, 
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>, Xin Long <lucien.xin@gmail.com>, 
	Neal Cardwell <ncardwell@google.com>, Joerg Reuter <jreuter@yaina.de>, 
	Marcel Holtmann <marcel@holtmann.org>, Johan Hedberg <johan.hedberg@gmail.com>, 
	Luiz Augusto von Dentz <luiz.dentz@gmail.com>, Oliver Hartkopp <socketcan@hartkopp.net>, 
	Marc Kleine-Budde <mkl@pengutronix.de>, Robin van der Gracht <robin@protonic.nl>, 
	Oleksij Rempel <o.rempel@pengutronix.de>, kernel@pengutronix.de, 
	Alexander Aring <alex.aring@gmail.com>, Stefan Schmidt <stefan@datenfreihafen.org>, 
	Miquel Raynal <miquel.raynal@bootlin.com>, Alexandra Winter <wintera@linux.ibm.com>, 
	Thorsten Winkler <twinkler@linux.ibm.com>, James Chapman <jchapman@katalix.com>, 
	Jeremy Kerr <jk@codeconstruct.com.au>, Matt Johnston <matt@codeconstruct.com.au>, 
	Matthieu Baerts <matttbe@kernel.org>, Mat Martineau <martineau@kernel.org>, 
	Geliang Tang <geliang@kernel.org>, Krzysztof Kozlowski <krzk@kernel.org>, 
	Remi Denis-Courmont <courmisch@gmail.com>, Allison Henderson <allison.henderson@oracle.com>, 
	David Howells <dhowells@redhat.com>, Marc Dionne <marc.dionne@auristor.com>, 
	Wenjia Zhang <wenjia@linux.ibm.com>, Jan Karcher <jaka@linux.ibm.com>, 
	"D. Wythe" <alibuda@linux.alibaba.com>, Tony Lu <tonylu@linux.alibaba.com>, 
	Wen Gu <guwen@linux.alibaba.com>, Jon Maloy <jmaloy@redhat.com>, 
	Boris Pismenny <borisp@nvidia.com>, John Fastabend <john.fastabend@gmail.com>, 
	Stefano Garzarella <sgarzare@redhat.com>, Martin Schiller <ms@dev.tdt.de>, =?UTF-8?B?QmrDtnJuIFTDtnBlbA==?= <bjorn@kernel.org>, 
	Magnus Karlsson <magnus.karlsson@intel.com>, 
	Maciej Fijalkowski <maciej.fijalkowski@intel.com>, Jonathan Lemon <jonathan.lemon@gmail.com>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Jesper Dangaard Brouer <hawk@kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-sctp@vger.kernel.org, linux-hams@vger.kernel.org, 
	linux-bluetooth@vger.kernel.org, linux-can@vger.kernel.org, 
	dccp@vger.kernel.org, linux-wpan@vger.kernel.org, linux-s390@vger.kernel.org, 
	mptcp@lists.linux.dev, linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com, 
	linux-afs@lists.infradead.org, tipc-discussion@lists.sourceforge.net, 
	virtualization@lists.linux.dev, linux-x25@vger.kernel.org, 
	bpf@vger.kernel.org, isdn4linux@listserv.isdn4linux.de, 
	io-uring@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"

On Wed, 2 Apr 2025 at 13:46, David Laight <david.laight.linux@gmail.com> wrote:
>
> The problem is that the generic code has to deal with all the 'wild stuff'.
> It is also common to do non-sequential accesses - so iov_iter doesn't match
> at all.
> There also isn't a requirement for scatter-gather.

Note that the generic code has special cases for the simple stuff,
which is all that the sockopt code would need.

Now, that's _particularly_ true for the "single user address range"
thing, where there's a special ITER_UBUF thing.

We don't actually have a "single kernel range" version of that, but
ITER_KVEC is simple to use, and the sockopt code could say "I only
ever look at the first buffer".

It's ok to just not handle all the cases, and you don't *have* to use
the generic "copy_from_iter()" routines if you don't want to.

In fact, I would expect that something like sockopt generally wouldn't
want to use the normal iter copying routines, since those are
basically all geared towards "copy and update the iter".

           Linus
