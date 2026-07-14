Received: from ns1.suksangroup.com (ns1.suksangroup.com [103.13.31.55])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A181A309EEB
	for <dccp@vger.kernel.org>; Tue, 14 Jul 2026 05:17:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.13.31.55
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784006271; cv=none; b=memHaRXhsFhknpYVKM0BFPgnrv2bgdNI0B7AjVl+bEy9oAMXYNggw4wqkttZW/XqQ6jwxmRQZaMfArxai9Hl7pBFRbMLtxPNgpW6ihm0/e+Cib4YyqHsLnCCpJOif+9VfXWFcuVRS4Rdm9H8zVTSOpa8POmXUa9Ti88HKKnNOO4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784006271; c=relaxed/simple;
	bh=xY0Tz+cu7Zzp6fSboCupRw0Y9/LzHL/NqtnwHzTNG60=;
	h=From:To:Subject:Date:Message-ID:MIME-Version:Content-Type; b=VQ8p+J+ew1NAnfSKH7Ov/d15Wy6BdaljAdqekGJ8O80B4i/KPJcAdoitOoMkvS0T+Ba5LJ8OwIWs78iRR2/eHJtaWCoHKUgScQ4Ql5zCBxBE9gtpQ8zOwUKl96V4qU8Mr1LhjeWfr5u4JRRqlzkg8oHIBm89w0YyTiWBIFwNHU4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=inbox.org; spf=fail smtp.mailfrom=inbox.org; dkim=pass (2048-bit key) header.d=suksangroup.co.th header.i=@suksangroup.co.th header.b=pfV3NCK5; arc=none smtp.client-ip=103.13.31.55
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=none dis=none) header.from=inbox.org
Authentication-Results: smtp.subspace.kernel.org; spf=fail smtp.mailfrom=inbox.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=suksangroup.co.th header.i=@suksangroup.co.th header.b="pfV3NCK5"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=suksangroup.co.th; s=default; h=Content-Transfer-Encoding:Content-Type:
	MIME-Version:Message-ID:Date:Subject:To:From:Reply-To:Sender:Cc:Content-ID:
	Content-Description:Resent-Date:Resent-From:Resent-Sender:Resent-To:Resent-Cc
	:Resent-Message-ID:In-Reply-To:References:List-Id:List-Help:List-Unsubscribe:
	List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=xY0Tz+cu7Zzp6fSboCupRw0Y9/LzHL/NqtnwHzTNG60=; b=pfV3NCK5cnA5MntUcg2t7fYLtl
	LC19EfjNQv1KKW5Mr4ZIq2B13fh6Vr3+1xENh4Szhe2t23Ij69n0zseQq8RtCg3OfR6WumtlSqzc2
	6MUzPBLIE+kMdydqjjG+ZJPA5X4iYnbIcN9i4odFynHxI+uP3Irk7TfaVtP+beuCSPsm4AVNottWm
	2escY59biQkrobluTFC2jzdk0d8+B3crqAWTyTSbelY2CC/UxX3aYxqvfG97e+haOjdxkcz5ZZulF
	hNKVINo0jLBgSAA0cEPz7sfZa8vTISYyuN2TySKGdh5aUT8QJ+YVMdYC+xYj+jt69YicxVOz0EnaC
	LbA7ZelA==;
Received: from [207.189.26.187] (port=61341)
	by ns1.suksangroup.com with esmtpsa  (TLS1.3) tls TLS_AES_256_GCM_SHA384
	(Exim 4.99.4)
	(envelope-from <info@inbox.org>)
	id 1wjVWd-0000000FsV8-0TE9
	for dccp@vger.kernel.org;
	Tue, 14 Jul 2026 12:17:46 +0700
Reply-To: hanns.schofield@lexcapitalgrowth.com
From: Harry Schofield ESQ <info@inbox.org>
To: dccp@vger.kernel.org
Subject: Dear dccp@vger.kernel.org, project stage
Date: 14 Jul 2026 00:17:42 -0500
Message-ID: <20260714001742.9210901AF90A2DB8@inbox.org>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-AntiAbuse: This header was added to track abuse, please include it with any abuse report
X-AntiAbuse: Primary Hostname - ns1.suksangroup.com
X-AntiAbuse: Original Domain - vger.kernel.org
X-AntiAbuse: Originator/Caller UID/GID - [47 12] / [47 12]
X-AntiAbuse: Sender Address Domain - inbox.org
X-Get-Message-Sender-Via: ns1.suksangroup.com: authenticated_id: smtp@suksangroup.co.th
X-Authenticated-Sender: ns1.suksangroup.com: smtp@suksangroup.co.th
X-Source: 
X-Source-Args: 
X-Source-Dir: 


Re:Good day dccp,

Please let me know if this is best email to send you the project=20
info.

Kind regards,

Harry Schofield, ceMBA


