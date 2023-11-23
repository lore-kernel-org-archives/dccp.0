Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Z39ieLvO"
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3FD55D40
	for <dccp@vger.kernel.org>; Thu, 23 Nov 2023 06:34:39 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1700750078;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=jJ7Ki4jyK6CXGE03cStoDbMuXGPhHn+xPGZmYbAaox4=;
	b=Z39ieLvOQ02hX6ZFFBJMQBcL5DDekuQ6YSEOYfo/NgRp1uUhtkAKEBDztQaNkLCSHLOJDR
	stalq2USV7wgE780sM+beng42Pr/yjNR75PHLjGcAcruSJRMapkKQEE3/Vl3RiG7eOlrjJ
	VG0ZzZvaAFqG6zKiWz9wwFXw0Q/C6ek=
Received: from mail-ej1-f70.google.com (mail-ej1-f70.google.com
 [209.85.218.70]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-113-BK77AnbhMkG1ifVJ6fr-wQ-1; Thu, 23 Nov 2023 09:34:37 -0500
X-MC-Unique: BK77AnbhMkG1ifVJ6fr-wQ-1
Received: by mail-ej1-f70.google.com with SMTP id a640c23a62f3a-a01efffd9e4so60393866b.0
        for <dccp@vger.kernel.org>; Thu, 23 Nov 2023 06:34:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1700750075; x=1701354875;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=jJ7Ki4jyK6CXGE03cStoDbMuXGPhHn+xPGZmYbAaox4=;
        b=DWJC/1uGh0VxGkY3oeN9i8mA0jlp6jlHUJeqc5GVQXtZvjdD1XBKfn89RCiIUMybGT
         JrSKwDZ0NOhZid3Gv2IROs3M4AotBz6eECfn6kAwJpojg3QCa/Ug71l/67UhAAckwl1c
         EgplgmFjNwMEdtWFUT/NcuIKM0zQ+mbEp6ZG0ca298JYM9veZdEnKuWdsqVB077RJWO/
         0DMX5DCd4UgGp0uZbNzShs1tULnGkavTlYApPgykQ285VHkezLeT6s5V/OdhJVy268Tu
         jhcKLAefSKbiNldQ2q/L3TcG3FcPEZaDP2q4g8AiJhkY2ieDIrK4M2fiSHRYShpYpCsk
         T2Ng==
X-Gm-Message-State: AOJu0YyUwFbLW+/V4EOZoJrO7L97MUpL/otY3/p7u+BWSMXrviQOg8b7
	qXeYnrJxityqRmuORnHktkQgJToh0G2OqT7sEl7E05Hp857/fgsF5hpk6qKnzkbCEr9T4zupZqH
	OPlOo4NXnkdk6XaGBRwU2P617j537XhIJt934qssN
X-Received: by 2002:a17:906:10d9:b0:9fd:8d07:a3ad with SMTP id v25-20020a17090610d900b009fd8d07a3admr4074580ejv.17.1700750075154;
        Thu, 23 Nov 2023 06:34:35 -0800 (PST)
X-Google-Smtp-Source: AGHT+IHJGIgYt3XV572SfRjarH9RjhlJNwD5AtR5SICWYkEEOs2fQ/XmS1ZzGbCjAF0HNd+6pHOl5+0CkBtgRGOD50s=
X-Received: by 2002:a17:906:10d9:b0:9fd:8d07:a3ad with SMTP id
 v25-20020a17090610d900b009fd8d07a3admr4074560ejv.17.1700750074891; Thu, 23
 Nov 2023 06:34:34 -0800 (PST)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20231115210509.481514-1-vschneid@redhat.com> <20231115210509.481514-2-vschneid@redhat.com>
 <CANn89iJPxrXi35=_OJqLsJjeNU9b8EFb_rk+EEMVCMiAOd2=5A@mail.gmail.com>
In-Reply-To: <CANn89iJPxrXi35=_OJqLsJjeNU9b8EFb_rk+EEMVCMiAOd2=5A@mail.gmail.com>
From: Valentin Schneider <vschneid@redhat.com>
Date: Thu, 23 Nov 2023 15:34:23 +0100
Message-ID: <CAD235PRWd+zF1xpuXWabdgMU01XNpvtvGorBJbLn9ny2G_TSuw@mail.gmail.com>
Subject: Re: [PATCH v2 1/2] tcp/dcpp: Un-pin tw_timer
To: Eric Dumazet <edumazet@google.com>
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-rt-users@vger.kernel.org, "David S. Miller" <davem@davemloft.net>, 
	Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, David Ahern <dsahern@kernel.org>, 
	Juri Lelli <juri.lelli@redhat.com>, Tomas Glozar <tglozar@redhat.com>, 
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>, Thomas Gleixner <tglx@linutronix.de>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hi Eric,

On Mon, 20 Nov 2023 at 18:56, Eric Dumazet <edumazet@google.com> wrote:
>
> On Wed, Nov 15, 2023 at 10:05=E2=80=AFPM Valentin Schneider <vschneid@red=
hat.com> wrote:
> >
> > @@ -53,16 +53,14 @@ void dccp_time_wait(struct sock *sk, int state, int=
 timeo)
> >                 if (state =3D=3D DCCP_TIME_WAIT)
> >                         timeo =3D DCCP_TIMEWAIT_LEN;
> >
> > -               /* tw_timer is pinned, so we need to make sure BH are d=
isabled
> > -                * in following section, otherwise timer handler could =
run before
> > -                * we complete the initialization.
> > -                */
> > -               local_bh_disable();
> > -               inet_twsk_schedule(tw, timeo);
> > -               /* Linkage updates.
> > -                * Note that access to tw after this point is illegal.
> > -                */
> > +              local_bh_disable();
> > +
> > +               // Linkage updates
> >                 inet_twsk_hashdance(tw, sk, &dccp_hashinfo);
> > +               inet_twsk_schedule(tw, timeo);
>
> We could arm a timer there, while another thread/cpu found the TW in
> the ehash table.
>
>
>
> > +               // Access to tw after this point is illegal.
> > +               inet_twsk_put(tw);
>
> This would eventually call inet_twsk_free() while the timer is armed.
>
> I think more work is needed.
>
> Perhaps make sure that a live timer owns a reference on tw->tw_refcnt
> (This is not the case atm)
>

I thought that was already the case, per inet_twsk_hashdance():

/* tw_refcnt is set to 3 because we have :
 * - one reference for bhash chain.
 * - one reference for ehash chain.
 * - one reference for timer.

and

tw_timer_handler()
`\
  inet_twsk_kill()
  `\
    inet_twsk_put()

So AFAICT, after we go through the hashdance, there's a reference on
tw_refcnt held by the tw_timer.
inet_twsk_deschedule_put() can race with arming the timer, but it only
calls inet_twsk_kill() if the timer
was already armed & has been deleted, so there's no risk of calling it
twice... If I got it right :-)

