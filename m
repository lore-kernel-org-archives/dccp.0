Received: from lindbergh.monkeyblade.net (lindbergh.monkeyblade.net [23.128.96.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBD5F1C69D
	for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 22:00:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=paul-moore.com header.i=@paul-moore.com header.b="QYpRhANy"
Received: from mail-yw1-x1131.google.com (mail-yw1-x1131.google.com [IPv6:2607:f8b0:4864:20::1131])
	by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 68AD8E8
	for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 15:00:12 -0700 (PDT)
Received: by mail-yw1-x1131.google.com with SMTP id 00721157ae682-5a7afd45199so48031017b3.0
        for <dccp@vger.kernel.org>; Mon, 30 Oct 2023 15:00:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=paul-moore.com; s=google; t=1698703211; x=1699308011; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=vl6sqkkoABwL8j4SqRZMYnBmV6Bv+iWE2PJFKhoRckg=;
        b=QYpRhANy+JNMyamRlCGUiXHlNx2IHowH0Cy9kALa3G+r9NbHeZUZLAhKQ0X444ogQA
         Jp9oVoEH/UrnkwsfBIVroHB2dG3718wU2af9PqNjPV4G50fzNcT4RiTgj8I/3G5r+JxF
         RBPdeiF8bkeRj2+onW7pTZnA+pXsDplo3bF0+vKdGyLZbPewXR4dfUBdctHD0xZQysss
         qQ9XZ8ozlZiXQ+K77arKLLaa1OQuYklOTLfGSE7BEoBDEMW0X/0bQyJeVUKbItcVRCJi
         zJMIBZVEbOhumZy2MU0wJOiiHs02X2fqgqzNkBxU7dX/XIDpOG4sKhk9yPCw5ZqcPI5q
         ywfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1698703211; x=1699308011;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to;
        bh=vl6sqkkoABwL8j4SqRZMYnBmV6Bv+iWE2PJFKhoRckg=;
        b=Olpxy6oYVMVDQhug8U9xfDGQ6KGDM/8pM256wXp70A4g6NN9yKEUyWFznznrT9m94S
         +XWlWJfBQh39cjVdJ2BYzx70mF6YK3KCcVNvucJvGUK7llB2UCWLaeDnwsOp2pWU+MMA
         6+HMA7vopzMVs/8JXhys1jkTbZ2pOQDNPwyoDyfRiqmITz9AZeLH0hYt5pKnqoOYin2e
         K3In/wgKPNtgOkXt5bNimQiEMa2cpb2AOurSZgutFqf3k6toFN3yoslSFY4N+CT63sai
         wn21FHzUVwdmxa5Cu4aCHblr5rLHCPIypZf0ezmIMGBQWl0sK9u1JsH5Uazs1NJwqeQF
         1l/g==
X-Gm-Message-State: AOJu0YwoSqw6USPwy+tv+qecaesFtn/zYWSfj0gbRoekkl9gd4UpbxtE
	LjpQn8/J00fXsJwi2zhuNv5eyBZi9QFfxxcuqKqiVkjoNsm0t7w=
X-Google-Smtp-Source: AGHT+IEHNaD64e1BKBY2tf605KyQyK8JDATjsKkIBbGALDgeIlIz/WaVE3v3elWG/kwwdddXmmLCJjBKqymvgbKBLZQ=
X-Received: by 2002:a25:9083:0:b0:d99:de67:c3dc with SMTP id
 t3-20020a259083000000b00d99de67c3dcmr9656516ybl.2.1698703211378; Mon, 30 Oct
 2023 15:00:11 -0700 (PDT)
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAHC9VhTrm2shkh=FHcjnqFpDLFCoBwGfsyoSuDH3UFSOeZt+HA@mail.gmail.com>
 <20231030212015.57180-1-kuniyu@amazon.com>
In-Reply-To: <20231030212015.57180-1-kuniyu@amazon.com>
From: Paul Moore <paul@paul-moore.com>
Date: Mon, 30 Oct 2023 18:00:00 -0400
Message-ID: <CAHC9VhRM_-414uEaYjkMDRgWU9LbESuVzvC+KF-m=5zNTNvj-w@mail.gmail.com>
Subject: Re: [PATCH v1 net 2/2] dccp/tcp: Call security_inet_conn_request()
 after setting IPv6 addresses.
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: davem@davemloft.net, dccp@vger.kernel.org, dsahern@kernel.org, 
	edumazet@google.com, huw@codeweavers.com, kuba@kernel.org, kuni1840@gmail.com, 
	linux-security-module@vger.kernel.org, netdev@vger.kernel.org, 
	pabeni@redhat.com
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 30, 2023 at 5:20=E2=80=AFPM Kuniyuki Iwashima <kuniyu@amazon.co=
m> wrote:
> From: Paul Moore <paul@paul-moore.com>
> Date: Mon, 30 Oct 2023 17:12:33 -0400
> > On Mon, Oct 30, 2023 at 4:12=E2=80=AFPM Kuniyuki Iwashima <kuniyu@amazo=
n.com> wrote:
> > >
> > > Initially, commit 4237c75c0a35 ("[MLSXFRM]: Auto-labeling of child
> > > sockets") introduced security_inet_conn_request() in some functions
> > > where reqsk is allocated.  The hook is added just after the allocatio=
n,
> > > so reqsk's IPv6 remote address was not initialised then.
> > >
> > > However, SELinux/Smack started to read it in netlbl_req_setattr()
> > > after commit e1adea927080 ("calipso: Allow request sockets to be
> > > relabelled by the lsm.").
> > >
> > > Commit 284904aa7946 ("lsm: Relocate the IPv4 security_inet_conn_reque=
st()
> > > hooks") fixed that kind of issue only in TCPv4 because IPv6 labeling =
was
> > > not supported at that time.  Finally, the same issue was introduced a=
gain
> > > in IPv6.
> > >
> > > Let's apply the same fix on DCCPv6 and TCPv6.
> > >
> > > Fixes: e1adea927080 ("calipso: Allow request sockets to be relabelled=
 by the lsm.")
> > > Signed-off-by: Kuniyuki Iwashima <kuniyu@amazon.com>
> > > ---
> > > Cc: Huw Davies <huw@codeweavers.com>
> > > Cc: Paul Moore <paul@paul-moore.com>
> > > ---
> > >  net/dccp/ipv6.c       | 6 +++---
> > >  net/ipv6/syncookies.c | 7 ++++---
> > >  2 files changed, 7 insertions(+), 6 deletions(-)
> >
> > Thanks for catching this and submitting a patch!
> >
> > It seems like we should also update dccp_v4_conn_request(), what do you=
 think?
>
> Yes, and it's done in patch 1 as it had a separate Fixes tag.
> https://lore.kernel.org/netdev/20231030201042.32885-2-kuniyu@amazon.com/

Great, thanks for doing that.  netdev folks, please feel free to add
my ACK to both patches in the patchset.

Acked-by: Paul Moore <paul@paul-moore.com>

> It seems get_maintainers.pl suggested another email address of
> yours for patch 1.  It would be good to update .mailmap ;)

Yes, I really should, thanks for the reminder.  I'll send an update to
Linus once I get the merge window PRs sorted out.

--=20
paul-moore.com
