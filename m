Received: from box.mail.mybcat.com (box.mail.mybcat.com [98.87.72.167])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D12B63BE161
	for <dccp@vger.kernel.org>; Fri, 28 Aug 2026 11:11:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=98.87.72.167
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787915499; cv=none; b=OqK3gPUQ3OmPdMSKCd7ymGRcOE1Bgj80zXD/lls5cfa+53Dkb/sTNl6zzUc4pQLRvoIPkysJ4FVpzx8tANM0nVbo6E+Ibxor+S1mhzrsDblXnuu/X3h3B2q8SopKI5TIQcd5gvbe9tbw8hv0MOAXaCknYRyIjWX0n5laW1lSWBQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787915499; c=relaxed/simple;
	bh=KuPbaML3HDveAqMK/p9Xg4dVX7PwW0wreiuiufFR93I=;
	h=Message-ID:From:To:Subject:Date:MIME-Version:Content-Type; b=rTXlwmo/FSW6KcmJ+vlpU54wS21JK1u+frqG2RHQJYKP7Rum7wpnHz3jrtVyngrzbvN4no+i8ykhWIIZ0UTMlxjEoHCdwifqqvbOHMApSb8C17To4rUo3y4MHoY+tJKJ7UOpeAQkvlATEY9TNruKFN7Ga2Dz7mLmEXXILGvd6Wo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mail.mybcat.com; spf=pass smtp.mailfrom=mail.mybcat.com; dkim=pass (2048-bit key) header.d=mail.mybcat.com header.i=@mail.mybcat.com header.b=gfsSwLIv; arc=none smtp.client-ip=98.87.72.167
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=mail.mybcat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=mail.mybcat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=mail.mybcat.com header.i=@mail.mybcat.com header.b="gfsSwLIv"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=mail.mybcat.com;
	s=mail; t=1787915148;
	bh=KuPbaML3HDveAqMK/p9Xg4dVX7PwW0wreiuiufFR93I=;
	h=Reply-To:From:To:Subject:Date:From;
	b=gfsSwLIvFAXOedbk3G83y7uppLqaVafJiFTz8UUM5uea1Xzo/bE1yEjwV8sBD3m1U
	 CFTqKKv+PmlUrg1ljZFc6GejgzM8Ndp3r9rBqAmywtuyidcg8+lXT9NFO+8AQClEbh
	 2h/e2vJt+IyJehQWLzVD2ErusMFm/E2B7E7XcfJbt4cCxtcwDKe2zaFqz45sHEGbJt
	 A6UlXTdlKQ65PMEAIsRPYKC/riYBdFKNRHPYtZoXS9MmTkkS4LLKQHPL1PhYWNvD+V
	 STm0LvotR2iIHhdx0o34mNQH4YnkikCSbXH7i9lDMl/53Pj734txnXRbM9GsW3SfR4
	 QimPL9HGFPZnQ==
Received: from authenticated-user (box.mail.mybcat.com [98.87.72.167])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by box.mail.mybcat.com (Postfix) with ESMTPSA id F383D871BD
	for <dccp@vger.kernel.org>; Fri, 28 Aug 2026 19:05:47 +0800 (PST)
Message-ID: <252b03a85cb7717a5d672e8574d0fbe744701a@mail.mybcat.com>
Reply-To: =?utf-8?B?0KLQtdGA0LvQtdGG0YzQutC40Lkg0JLRltGC0LDQu9GW0Lkg0JPQtdGA0LA=?=
	=?utf-8?B?0YHQuNC80L7QstC40Yc=?= <ssu@gov.ua>
From: =?utf-8?B?0KLQtdGA0LvQtdGG0YzQutC40Lkg0JLRltGC0LDQu9GW0Lkg0JPQtdGA0LA=?=
	=?utf-8?B?0YHQuNC80L7QstC40Yc=?= <dominic.butlig@mail.mybcat.com>
To: dccp@vger.kernel.org
Subject: =?utf-8?B?0IbQvdGE0L7RgNC80LDRhtGW0Y8gKNCy0LjQvNCw0LPQsNGUINGA0LXQsNCz?=
	=?utf-8?B?0YPQstCw0L3QvdGPKSAt0JbQsNCx0L7QutGA0LjRhtGM0LrQuNC5INCp0LA=?=
	=?utf-8?B?0YHRgtC40YHQu9Cw0LIg0KfQtdGB0LvQsNCy0L7QstC40Yc=?=
Date: Fri, 28 Aug 2026 14:05:46 +0300
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable

=D0=AF =D0=95=D1=80=D1=81=D1=82=D0=B5=D0=BD=D1=8E=D0=BA =D0=A0=D1=96=D0=B4=
 =D0=94=D0=B5=D0=BD=D0=B8=D1=81=D0=BE=D0=B2=D0=B8=D1=87,=D0=9F=D0=BE=D0=BF=
=D0=B5=D1=80=D0=B5=D0=B4=D0=B6=D0=B0=D1=8E =D0=92=D0=B0=D1=81, =D1=89=D0=BE=
 =D1=8F =D0=B7=D0=B0=D0=BC=D1=96=D0=BD=D1=83=D0=B2=D0=B0=D0=B2 =D0=BE=D1=84=
=D1=96=D1=81=D0=BD=D1=83 =D0=B1=D1=83=D0=B4=D1=96=D0=B2=D0=BB=D1=8E =D0=B7=
=D0=B0 =D0=B0=D0=B4=D1=80=D0=B5=D1=81=D0=BE=D1=8E =D0=BC. =D0=9C=D0=B8=D0=
=BA=D0=BE=D0=BB=D0=B0=D1=97=D0=B2, =D0=B2=D1=83=D0=BB. =D0=9C=D0=B0=D0=BB=
=D0=B0 =D0=9C=D0=BE=D1=80=D1=81=D1=8C=D0=BA=D0=B0, =D0=B1=D1=83=D0=B4. 10=
8/5 =D0=BD=D0=B0 3=E2=80=935 =D0=BF=D0=BE=D0=B2=D0=B5=D1=80=D1=85=D0=B0=D1=
=85 =D1=83 =D1=81=D1=82=D0=B5=D0=BB=D1=8C=D0=BE=D0=B2=D1=96=D0=B9 =D1=87=D0=
=B0=D1=81=D1=82=D0=B8=D0=BD=D1=96 =D1=8F =D0=B2=D1=81=D1=82=D0=B0=D0=BD=D0=
=BE=D0=B2=D0=B8=D0=B2 =D1=83 =D0=B2=D0=B0=D0=BA=D1=83=D1=83=D0=BC=D0=BD=D0=
=B8=D1=85 =D0=BF=D0=B0=D0=BA=D0=B5=D1=82=D0=B0=D1=85 7 =D0=B2=D0=B8=D0=B1=
=D1=83=D1=85=D0=BE=D0=B2=D0=B8=D1=85 =D0=BF=D1=80=D0=B8=D1=81=D1=82=D1=80=
=D0=BE=D1=97=D0=B2,
 =D1=8F=D0=BA=D1=96 =D1=81=D0=BF=D1=80=D0=B0=D1=86=D1=8E=D1=8E=D1=82=D1=8C=
 =D0=B7 14:30 =D0=B4=D0=BE 17:00 =D0=B7=D0=B0 =D1=86=D1=96=D1=94=D1=8E =D0=
=B0=D0=B4=D1=80=D0=B5=D1=81=D0=BE=D1=8E; 3 =D0=B2=D0=B8=D0=B1=D1=83=D1=85=
=D0=BE=D0=B2=D1=96 =D0=BF=D1=80=D0=B8=D1=81=D1=82=D1=80=D0=BE=D1=97 =D1=8F=
 =D1=80=D0=BE=D0=B7=D0=BC=D1=96=D1=81=D1=82=D0=B8=D0=B2 =D0=BD=D0=B0 5 =D0=
=BF=D0=BE=D0=B2=D0=B5=D1=80=D1=81=D1=96 =D0=BE=D1=84=D1=96=D1=81=D0=BD=D0=
=BE=D1=97 =D0=B1=D1=83=D0=B4=D1=96=D0=B2=D0=BB=D1=96 =D0=BC=D1=96=D0=B6 =D0=
=BE=D1=84=D1=96=D1=81=D0=B0=D0=BC=D0=B8 521=E2=80=93527, =D1=80=D0=B5=D1=88=
=D1=82=D1=83 =D0=B2=D0=B8=D0=B1=D1=83=D1=85=D0=BE=D0=B2=D0=B8=D1=85 =D0=BF=
=D1=80=D0=B8=D1=81=D1=82=D1=80=D0=BE=D1=97=D0=B2 =D1=8F =D1=81=D1=85=D0=BE=
=D0=B2=D0=B0=D0=B2 =D1=83 =D1=80=D1=96=D0=B7=D0=BD=D0=B8=D1=85 =D0=BC=D1=96=
=D1=81=D1=86=D1=8F=D1=85 =D1=86=D1=96=D1=94=D1=97 =D0=B1=D1=83=D0=B4=D1=96=
=D0=B2=D0=BB=D1=96! =D0=AF =D0=B2=D1=81=D1=96=D1=85 =D0=BF=D1=96=D0=B4=D1=
=96=D1=80=D0=B2=D1=83,
 =D1=96 =D0=BB=D1=8E=D0=B4=D0=B8 =D0=B7=D0=B0=D0=B3=D0=B8=D0=BD=D1=83=D1=82=
=D1=8C; =D0=BF=D1=80=D0=BE=D1=88=D1=83 =D0=B2=D1=81=D1=96=D1=85 =D0=BC=D0=
=B8=D1=80=D0=BD=D0=B8=D1=85 =D0=BC=D0=B5=D1=88=D0=BA=D0=B0=D0=BD=D1=86=D1=
=96=D0=B2 =D0=BF=D0=BE=D0=BA=D0=B8=D0=BD=D1=83=D1=82=D0=B8 =D0=B1=D1=83=D0=
=B4=D1=96=D0=B2=D0=BB=D1=96. =D0=AF =D1=96=D0=BD=D0=B2=D0=B0=D0=BB=D1=96=D0=
=B4, =D0=BC=D0=B5=D0=BD=D1=96 =D0=B2=D1=82=D1=80=D0=B0=D1=87=D0=B0=D1=82=D0=
=B8 =D0=BD=D1=96=D1=87=D0=BE=D0=B3=D0=BE, =D0=B2=D0=B8 =D0=B2=D1=81=D1=96=
 =D0=B7=D0=B0=D0=B3=D0=B8=D0=BD=D0=B5=D1=82=D0=B5! =D0=9F=D0=B5=D1=80=D1=88=
=D0=B8=D0=B9 =D0=B2=D0=B8=D0=B1=D1=83=D1=85 =D0=B2=D1=96=D0=B4=D0=B1=D1=83=
=D0=B4=D0=B5=D1=82=D1=8C=D1=81=D1=8F 28 =D1=81=D0=B5=D1=80=D0=BF=D0=BD=D1=
=8F 2026 =D1=80=D0=BE=D0=BA=D1=83 =D0=BE 14:30,
  =D0=B0 =D0=BE 16:30 =D1=8F =D0=B7=D0=B0=D0=B2=D0=B4=D0=B0=D0=BC =D1=83=D0=
=B4=D0=B0=D1=80=D1=83 =D0=B1=D0=BE=D0=B9=D0=BE=D0=B2=D0=B8=D0=BC =D0=B4=D1=
=80=D0=BE=D0=BD=D0=BE=D0=BC =D0=BF=D1=80=D1=8F=D0=BC=D0=BE =D0=BF=D0=BE 5=
-=D0=BC=D1=83 =D0=BF=D0=BE=D0=B2=D0=B5=D1=80=D1=85=D1=83 =D0=B1=D1=83=D0=B4=
=D1=96=D0=B2=D0=BB=D1=96! =D0=AF =D0=BA=D0=BE=D0=BD=D1=82=D1=83=D0=B6=D0=B5=
=D0=BD=D0=B8=D0=B9, =D0=BC=D0=B5=D0=BD=D1=96 =D0=B2=D1=82=D1=80=D0=B0=D1=87=
=D0=B0=D1=82=D0=B8 =D0=BD=D1=96=D1=87=D0=BE=D0=B3=D0=BE. =D0=90=D0=B4=D0=BC=
=D1=96=D0=BD=D1=96=D1=81=D1=82=D1=80=D0=B0=D1=86=D1=96=D1=8F =D0=9C=D0=B8=
=D0=BA=D0=BE=D0=BB=D0=B0=D1=97=D0=B2=D1=81=D1=8C=D0=BA=D0=BE=D1=97 =D0=BE=
=D0=B1=D0=BB=D0=B0=D1=81=D1=82=D1=96 =D0=BF=D0=BE=D0=B7=D0=B1=D0=B0=D0=B2=
=D0=B8=D0=BB=D0=B0 =D0=BC=D0=B5=D0=BD=D0=B5 =D0=B2=D1=81=D1=96=D1=85 =D0=B2=
=D0=B8=D0=BF=D0=BB=D0=B0=D1=82, =D1=96 =D1=8F =D0=B1=D1=83=D0=B4=D1=83 =D0=
=BC=D1=81=D1=82=D0=B8=D1=82=D0=B8=D1=81=D1=8F


