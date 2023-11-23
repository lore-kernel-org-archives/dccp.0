Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="T0xeNeGu"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 519DD10CE
	for <dccp@vger.kernel.org>; Thu, 23 Nov 2023 08:45:47 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1700757946;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=lBjBl6RiMXteiisXslLo0Yh7FdmVurXCHqt4qx72G+0=;
	b=T0xeNeGuHgM8oAlBSepRjy1ujklJTSYE94ThpaOy0gwyq4ff1HBrNVqeqphSknIdlgnWxC
	q02i4eTgwI0DpI6kq7VbhlWso+NE3SXIge2rh30ZY6FznOD8ArJW+0HFG+uA9vmCINGRBQ
	HTwfr8NUx0CB3D2DVvOEqRvMQc8PgAU=
Received: from mail-ej1-f71.google.com (mail-ej1-f71.google.com
 [209.85.218.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-103-xNouZ6X2Ouig2H7upiVJsg-1; Thu, 23 Nov 2023 11:45:42 -0500
X-MC-Unique: xNouZ6X2Ouig2H7upiVJsg-1
Received: by mail-ej1-f71.google.com with SMTP id a640c23a62f3a-a00d0011a3bso67072066b.2
        for <dccp@vger.kernel.org>; Thu, 23 Nov 2023 08:45:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700757941; x=1701362741;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=lBjBl6RiMXteiisXslLo0Yh7FdmVurXCHqt4qx72G+0=;
        b=hghOoKYd7HMu5u30FvW2YTAU8w6Uk4jJCbmYI0MpZkRTHxXw6t3lVP4icGSah+jw83
         IYr605nBq2JJ/FErb0rZc7Zu04k5hf4rJ63rWsxGUgHofEH71QrzNs/8UD8QnTdQ+N3i
         muD3D5NMOT8iPVWeSAMeiSD26X6GN8vmIMZsFuiBQTmtXDupgZUkCiR7n1qJiuvmjNkj
         biNUuhI76HMhN5sSiyu+kcL/eRklaSk293P0PZBU22uOfR9jJb/Mj0PJWfGXvXnPD7M1
         kbnrMUFDxgdT9bPseXIJXWZCGs5Wgdq/MgZUdXDK6RRTVwgWVilFeJDDKmGzkKLloNgc
         7YwA==
X-Gm-Message-State: AOJu0YzP+qqHqr08TenefbuF0qBJKUyohxXIGv3OBD+LmSVK+GkQ0uY9
	Td8NNHRrGFUb/ivEBqV4LmVfWTVjtkqsI1kJ5QIC4II3TnKi6dRdXMkFAdK91bcoYqGe0KpKuwK
	IBeK08mkLKBMmOpRvYkKbHWCVcRwY1Q==
X-Received: by 2002:a17:906:14d:b0:9e0:5d5c:aa6d with SMTP id 13-20020a170906014d00b009e05d5caa6dmr4276182ejh.20.1700757941730;
        Thu, 23 Nov 2023 08:45:41 -0800 (PST)
X-Google-Smtp-Source: AGHT+IFfaOoZK8ZVUHRmRcmkEFqZf7x8Mab1KDGr4SWVV+OmpRRd1SIVYmQoomns8qprSr9GXpfGYdGZr2ToP/DcJ7w=
X-Received: by 2002:a17:906:14d:b0:9e0:5d5c:aa6d with SMTP id
 13-20020a170906014d00b009e05d5caa6dmr4276162ejh.20.1700757941494; Thu, 23 Nov
 2023 08:45:41 -0800 (PST)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20231115210509.481514-1-vschneid@redhat.com> <20231115210509.481514-2-vschneid@redhat.com>
 <CANn89iJPxrXi35=_OJqLsJjeNU9b8EFb_rk+EEMVCMiAOd2=5A@mail.gmail.com>
 <CAD235PRWd+zF1xpuXWabdgMU01XNpvtvGorBJbLn9ny2G_TSuw@mail.gmail.com> <CANn89iKRSKz0e8v+Z-UsKGs4fQWDt6eTAw71VENbSmfkEicTPA@mail.gmail.com>
In-Reply-To: <CANn89iKRSKz0e8v+Z-UsKGs4fQWDt6eTAw71VENbSmfkEicTPA@mail.gmail.com>
From: Valentin Schneider <vschneid@redhat.com>
Date: Thu, 23 Nov 2023 17:45:29 +0100
Message-ID: <CAD235PTyEce0S-22vg=opQdq0MUwEovdx5henU=9Mwh3Rf8QrA@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] tcp/dcpp: Un-pin tw_timer
To: Eric Dumazet <edumazet@google.com>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-rt-users@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, 
	Juri Lelli <juri.lelli@redhat.com>, Tomas Glozar <tglozar@redhat.com>, 
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 23 Nov 2023 at 17:32, Eric Dumazet <edumazet@google.com> wrote:
>
> On Thu, Nov 23, 2023 at 3:34=E2=80=AFPM Valentin Schneider <vschneid@redh=
at.com> wrote:
> > I thought that was already the case, per inet_twsk_hashdance():
> >
> > /* tw_refcnt is set to 3 because we have :
> >  * - one reference for bhash chain.
> >  * - one reference for ehash chain.
> >  * - one reference for timer.
> >
> > and
> >
> > tw_timer_handler()
> > `\
> >   inet_twsk_kill()
> >   `\
> >     inet_twsk_put()
> >
> > So AFAICT, after we go through the hashdance, there's a reference on
> > tw_refcnt held by the tw_timer.
> > inet_twsk_deschedule_put() can race with arming the timer, but it only
> > calls inet_twsk_kill() if the timer
> > was already armed & has been deleted, so there's no risk of calling it
> > twice... If I got it right :-)
> >
>
> Again, I think you missed some details.
>
> I am OOO for a few days, I do not have time to elaborate.
>
> You will need to properly track active timer by elevating
> tw->tw_refcnt, or I guarantee something wrong will happen.
>

Gotcha, let me dig into this then!

