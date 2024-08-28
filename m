Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CC1215B119
	for <dccp@vger.kernel.org>; Wed, 28 Aug 2024 08:18:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724833094; cv=none; b=bsC/yVqp7FdDJig+2y7m9haXgq6B8ap46iHZS2c2U2MmgcG8mxsKWo5f79qygyycTWEXIky9wknQ4rPiF3aNYD2Ech9WNPgYK5qKgNKoz1gqW/uU4ELLm0fZpwlmgwd4RzueGs9zBL1aoGc9wPhVFcHzPGogQOEvJfrWcYT7pvE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724833094; c=relaxed/simple;
	bh=JL2xVBVvXl/dIQqSPuxus+zASWnK4WlSmgDr1Fwhd5I=;
	h=From:In-Reply-To:References:To:Cc:Subject:MIME-Version:
	 Content-Type:Date:Message-ID; b=AcVKilJNb1tRSQzVP3Q57VGpimsBXjeQYhBBOoEZG0TzS4QgBbXCnlKfDAGTkJezgpvT6t1NvrOrNeT9XvyVhnWRaogYxOOBVwQ0Kf406JdpfuH+7CilJ/iJTZRcJ4mddllHdRo0jEU1XMKLnDbjh49px9Zvs+bm3bVfsAISsjY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=SRZY1f54; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="SRZY1f54"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1724833091;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=Vntgy4JmkKEFTS6EF2ERAWqp5h9DO26vFt8a4ezAyKA=;
	b=SRZY1f54WQYtV7xv6LH0Ed4p7bbSX5RYgBOR/dyXdc9mFJgPf1EKEPYAwyNsnor9xCWNw/
	LCiivRlBJKqpZT7uiB4DrMhQhp8bpT+34wwsX/1glMfrWyQeZlImwstbogI75te29UNaOd
	3bGq2r1WmZIxkRCAyCfYFsLkZqAov/s=
Received: from mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-473-osS7qHy7NCezDtA0lPbHuQ-1; Wed,
 28 Aug 2024 04:18:07 -0400
X-MC-Unique: osS7qHy7NCezDtA0lPbHuQ-1
Received: from mx-prod-int-04.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-04.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.40])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-02.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id C22B318EB228;
	Wed, 28 Aug 2024 08:18:04 +0000 (UTC)
Received: from warthog.procyon.org.uk (unknown [10.42.28.30])
	by mx-prod-int-04.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id AEF1619560A3;
	Wed, 28 Aug 2024 08:17:58 +0000 (UTC)
Organization: Red Hat UK Ltd. Registered Address: Red Hat UK Ltd, Amberley
	Place, 107-111 Peascod Street, Windsor, Berkshire, SI4 1TE, United
	Kingdom.
	Registered in England and Wales under Company Registration No. 3798903
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1b1ee6e6-ff2e-45d6-bfe2-1f8efaba7b38@huawei.com>
References: <1b1ee6e6-ff2e-45d6-bfe2-1f8efaba7b38@huawei.com> <20240824074033.2134514-8-lihongbo22@huawei.com> <20240824074033.2134514-1-lihongbo22@huawei.com> <563923.1724501215@warthog.procyon.org.uk>
To: Hongbo Li <lihongbo22@huawei.com>
Cc: dhowells@redhat.com, johannes@sipsolutions.net, davem@davemloft.net,
    edumazet@google.com, kuba@kernel.org, pabeni@redhat.com,
    allison.henderson@oracle.com, dsahern@kernel.org, pshelar@ovn.org,
    linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
    rds-devel@oss.oracle.com, dccp@vger.kernel.org, dev@openvswitch.org,
    linux-afs@lists.infradead.org
Subject: Re: [PATCH net-next 7/8] net/rxrpc: Use min() to simplify the code
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-ID: <948380.1724833077.1@warthog.procyon.org.uk>
Date: Wed, 28 Aug 2024 09:17:57 +0100
Message-ID: <948381.1724833077@warthog.procyon.org.uk>
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.40

Hongbo Li <lihongbo22@huawei.com> wrote:

> I see reason is u8, so may I use min_t(u8, sp->ack.reason,
> RXRPC_ACK__INVALID)?

No, please don't use min_t(<unsigned type>, ...) if umin() will do.  IIRC,
some arches can't do byte-level arithmetic.

Thanks,
David

