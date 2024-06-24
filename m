Received: from mail-ed1-f48.google.com (mail-ed1-f48.google.com [209.85.208.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 949F21422D1
	for <dccp@vger.kernel.org>; Mon, 24 Jun 2024 13:57:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.208.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719237432; cv=none; b=RsTPJ8fvTpTWVjHwYDL/fUxwA6IBXLqL9WBq/dpzYHpwNiAFG4jF95mftCVXOiTbpgPYBHNGwyoZbqZ/sEzMd4Q/cxCWrJslZfhBUg9oBytLMP9MlK+WsWhtnzB2cprJQmTcSodepEqKEmBRpowvQ6ubcjwEt0xJ+OpsEzEpco8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719237432; c=relaxed/simple;
	bh=JcmBNUGTwoexd4d4Kt7dKugDN2tASyAOaxDUgR2FYt8=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=eyTXXWgMqtYrcKF3Du+uSrO1bCtN+ZesReCbynOZiQ3Fisrz2SSD02w2EEX2NTVGu/KfoK5g9tPZFQ9vT3t2NmngDu7zFE/TCv9K3yul61dR6gPjzmmAVpyh8K7gCEK42zgQoj8vOYOiFk6mjhRCApJqVBSCzLPWWkEOwQGp9zU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=zKSqq3tb; arc=none smtp.client-ip=209.85.208.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="zKSqq3tb"
Received: by mail-ed1-f48.google.com with SMTP id 4fb4d7f45d1cf-57d119fddd9so23437a12.1
        for <dccp@vger.kernel.org>; Mon, 24 Jun 2024 06:57:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20230601; t=1719237429; x=1719842229; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=JcmBNUGTwoexd4d4Kt7dKugDN2tASyAOaxDUgR2FYt8=;
        b=zKSqq3tbKQHF6xoKyLxyN0BCC7BIOE8OriqJqlAx+ak1rHc818BjLW0eLEeL4/vXtQ
         cUDdaoHBVk1s2RDDYorX7g64gvuhTHt008wBpmdujimn48GIepFPScIWgXKH1u2tjRHR
         UbMNjp6VZe53F0O77pn1mK/88RfK1tsQnDR0bRTV3SNwIOBCF8eVjsn6nvFyX7tq54ue
         jxRxbr8hjQPLb7SaCsbxu0TLsiNGqVvIYV1pxveVAsrIImXPQU3m2f0p5lYP3ddvH1n9
         EBdnD+3izPVskyvaeOv0oQEo+nvTggR0xb+yb8egj5dd+QAccqciTRZ0Uj03jDAFzqNO
         p19w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1719237429; x=1719842229;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=JcmBNUGTwoexd4d4Kt7dKugDN2tASyAOaxDUgR2FYt8=;
        b=HGQqw41wS4RLkkXC6M+Fv5gikZOJdNNcMWRMLc0CUB9czDle+in9hKKr3QbR6AhT/X
         IHB5lJ4jWvwS69jZKXdqc+htxRj969bIcQaAMcr36yeYqUUXWkFWwIm01ZybmEgYFWub
         0n+mp2kW2J2imumg0vhNY5SG2ZYJgmrMxWFTcIhroajc/XEpgaZBaALUFCPJE4az9iMo
         tZUTbJwu6UitFpnHhwZoWbO7jG1zIN0doeenDlpCa/XMX4+gq63pcnDO61v0CWUnRdaP
         A55vRe65FMq8NAEP15BdlNzYaLvh+uVgtZijF/gmiFPkjbrt9gytoZQ3bPXcs5XP5Ixj
         CkmQ==
X-Forwarded-Encrypted: i=1; AJvYcCWYa8pImAHwjA+FhXP1DTN+8cBSDrqsMtGekXMRrd8Mx76Uzc5vgoRVwxPY+jXRrEH4SSEuKd1h9P4Totx30x4o4/v5aQ==
X-Gm-Message-State: AOJu0YxkeyR1oYllX4QUFSY189TrF+641wm8fJGPiDx7INlnpWZ663wn
	UfVCIwKo/2nf9Q5DYFX8qRSsW1ybpezeGbVO4d26MWYl/NO6n7QITA76FAxDZH5GvJma0CRkyb9
	vrCGg3KGexVoE13mCVTgwHo7v/uSPZ64+JYBp
X-Google-Smtp-Source: AGHT+IHbiy1mlgv62NpSfQr4qTZMGNLyyk2z/JSEgEj2oQ6KuAX1jpFmQzh/as79B6TsYRiexfxYk9JCRIbRT718SCg=
X-Received: by 2002:a05:6402:3549:b0:57c:c5e2:2c37 with SMTP id
 4fb4d7f45d1cf-57d419e2fdbmr270398a12.3.1719237428649; Mon, 24 Jun 2024
 06:57:08 -0700 (PDT)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
In-Reply-To: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
From: Eric Dumazet <edumazet@google.com>
Date: Mon, 24 Jun 2024 15:56:57 +0200
Message-ID: <CANn89i+mrA0CpNLvOCpNi4XS1XsftgAQu71jWb4Ahh++VUzkGA@mail.gmail.com>
Subject: Re: [PATCH net v4] Fix race for duplicate reqsk on identical SYN
To: luoxuanqiang <luoxuanqiang@kylinos.cn>
Cc: kuniyu@amazon.com, kuba@kernel.org, davem@davemloft.net, pabeni@redhat.com, 
	dccp@vger.kernel.org, dsahern@kernel.org, fw@strlen.de, 
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org, 
	alexandre.ferrieux@orange.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, Jun 21, 2024 at 3:39=E2=80=AFAM luoxuanqiang <luoxuanqiang@kylinos.=
cn> wrote:
>
> When bonding is configured in BOND_MODE_BROADCAST mode, if two identical
> SYN packets are received at the same time and processed on different CPUs=
,
> it can potentially create the same sk (sock) but two different reqsk
> (request_sock) in tcp_conn_request().
>
> These two different reqsk will respond with two SYNACK packets, and since
> the generation of the seq (ISN) incorporates a timestamp, the final two
> SYNACK packets will have different seq values.
>
> The consequence is that when the Client receives and replies with an ACK
> to the earlier SYNACK packet, we will reset(RST) it.
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>

Reviewed-by: Eric Dumazet <edumazet@google.com>
