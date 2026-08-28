Received: from web130.fastservers.africa (web130.fastservers.africa [45.90.123.246])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F36A3EFFC4
	for <dccp@vger.kernel.org>; Fri, 28 Aug 2026 10:39:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.90.123.246
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787913587; cv=none; b=hSWHwtGefNwHlMsxSlVjUVCQ+TmfxHtaJa94mW6JVaHXEVKTniwor8Q2ne8fWGvDj/NyTG6TEU1kn6t1UJeDN6dKCrzp5LhHfJG+tRU9J+AYw0ScDmspKbs3GTEJr9sBYCqEY0XUqmo/PjnRUNtRJvkjoQFjKBIIRynvGNej7AE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787913587; c=relaxed/simple;
	bh=WJOab7kAcPOL8bRV3+smZ/IXMqiplq7cwJ+Jpq3Fu48=;
	h=Message-ID:From:To:Subject:Date:MIME-Version:Content-Type; b=rp6MXfsOHucQyV41wQIf8ohYyCMrvmwllGkbkkeXMKXu5Un/JO15SV6kuV5ItwDkO23b3eX/9GD2ZEPx630oCun+1+FchglQv9k6qPmf5kICFFShe3HPVSS2nr384P3ydGVnnNqmsmY7tRFQeLn+czWxns2HTDz1/zVWYOJ920M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cype.co.tz; spf=pass smtp.mailfrom=cype.co.tz; dkim=pass (2048-bit key) header.d=cype.co.tz header.i=@cype.co.tz header.b=rWK/8GZK; arc=none smtp.client-ip=45.90.123.246
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=cype.co.tz
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cype.co.tz
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cype.co.tz header.i=@cype.co.tz header.b="rWK/8GZK"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed; d=cype.co.tz;
	s=default; h=Content-Transfer-Encoding:Content-Type:MIME-Version:Date:Subject
	:To:From:Reply-To:Message-ID:Sender:Cc:Content-ID:Content-Description:
	Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:
	In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:List-Subscribe:
	List-Post:List-Owner:List-Archive;
	bh=U7gsGwxNew0w0xkqf8U+Yszpvli9aU0DJ88Tw9wxXtc=; b=rWK/8GZKnbGzU+I1ETRaUm0fNR
	KfkQoEbuFVvyaWvO+rJd4QV6ttVPogwYHhhKUOHQwsjpLlyTaqUtHa1Wq1UuulfxcyqqjqAqK3yXS
	OAomYE1dJUbcMNLyRlJ9AbJDw9qOpXH/JzdntP/P6tpAkwHfXhuBxS4Xub4iF3d17gT8HDCeqI+JF
	sksWyAmc2TPeqM63p8gMoXYaW4viCkoHlVPEmG8BtfbSWK55AN21/7grxKfKFywxgT3s6FAQr41ES
	QxpYsrUf4QpiyI+ZHh3UlgP00hIa3sDuYzMiMia6gAuM7ylJpy7sqi/vHnZMcNancS9yhIH7odKvb
	ogRj7FkA==;
Received: from [185.184.171.186] (port=51722 helo=syclps)
	by web130.fastservers.africa with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.4)
	(envelope-from <christina.lusanda@cype.co.tz>)
	id 1wztaB-0000000BqaB-1tm2
	for dccp@vger.kernel.org;
	Fri, 28 Aug 2026 10:13:11 +0000
Message-ID: <86400a5ca86c698ead03da7185446e6450d6a869@cype.co.tz>
Reply-To: =?utf-8?B?0J/QvtC90L7QvNCw0YDQtdC90LrQviDQktGW0YLQsNC70ZbQuSDQntC70LU=?=
	=?utf-8?B?0LrRgdCw0L3QtNGA0L7QstC40Yc=?= <kahc@vimk.com.ua>
From: =?utf-8?B?0J/QvtC90L7QvNCw0YDQtdC90LrQviDQktGW0YLQsNC70ZbQuSDQntC70LU=?=
	=?utf-8?B?0LrRgdCw0L3QtNGA0L7QstC40Yc=?= <christina.lusanda@cype.co.tz>
To: dccp@vger.kernel.org
Subject: =?utf-8?B?0JHRg9C00LXQvNC+INCy0LTRj9GH0L3Rliwg0Y/QutGJ0L4g0JLQuCDRgg==?=
	=?utf-8?B?0LXRgNC80ZbQvdC+0LLQviDQv9C10YDQtdC00LfQstC+0L3QuNGC0LUg0L0=?=
	=?utf-8?B?0LDQvC4gIA==?=
Date: Fri, 28 Aug 2026 13:13:10 +0300
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - web130.fastservers.africa
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - cype.co.tz
X-Get-Message-Sender-Via: web130.fastservers.africa: authenticated_id: christina.lusanda@cype.co.tz
X-Authenticated-Sender: web130.fastservers.africa: christina.lusanda@cype.co.tz
X-Source: 
X-Source-Args: 
X-Source-Dir: 

=D0=94=D0=BE=D0=B1=D1=80=D0=B8=D0=B9 =D0=B4=D0=B5=D0=BD=D1=8C,  =D0=BC=D0=
=B8 =D0=BD=D0=B5 =D0=BC=D0=BE=D0=B6=D0=B5=D0=BC=D0=BE =D0=B4=D0=BE=D0=B4=D0=
=B7=D0=B2=D0=BE=D0=BD=D0=B8=D1=82=D0=B8=D1=81=D1=8F =D0=B4=D0=BE =D0=92=D0=
=B0=D1=81, =D1=82=D0=BE=D0=BC=D1=83 =D0=BF=D1=80=D0=BE=D1=88=D1=83 =D0=9D=
=D0=95=D0=92=D0=86=D0=94=D0=9A=D0=9B=D0=90=D0=94=D0=9D=D0=9E =D0=BF=D0=B5=
=D1=80=D0=B5=D0=B4=D0=B7=D0=B2=D0=BE=D0=BD=D0=B8=D1=82=D0=B8 =D0=BC=D0=B5=
=D0=BD=D1=96 =D0=B7=D0=B0 =D0=BD=D0=BE=D0=BC=D0=B5=D1=80=D0=BE=D0=BC (073=
) 641-73-44.

=D0=97 =D0=BF=D0=BE=D0=B2=D0=B0=D0=B3=D0=BE=D1=8E,
=D0=9A=D1=83=D0=B7=D0=BD=D0=B5=D1=86=D0=BE=D0=B2=D0=B0 =D0=9C=D0=B0=D1=80=
=D0=B8=D0=BD=D0=B0 =D0=84=D0=B2=D0=B3=D0=B5=D0=BD=D1=96=D0=B2=D0=BD=D0=B0
(067) 995-08-92
(073) 641-73-44



