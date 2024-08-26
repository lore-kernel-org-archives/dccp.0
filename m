Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD5681990BA
	for <dccp@vger.kernel.org>; Mon, 26 Aug 2024 17:58:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1724695116; cv=none; b=oiJ+PvRVteMxZcBavc5tV+/dPBFxkLLBzeuzTZyXpDZoN8/FOPTNGnQBpJsdsT9+/RjvN2nRab8jj6WxdaI2FDAszkThV0akl+zFRaw5HI1cZuSJeypV5haERWTm4ir4Y5exM0ZgIMmWcMnPD+cXArSfOQU5j1WciYFCoIo22V8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1724695116; c=relaxed/simple;
	bh=m1vUJTxnbLYPFWSRrsUTILzyGkkzYoBIFbULE6uwxGg=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=ozkYBdoZcJ3mOKJOxwclSmprM5kLEMIfMuguIYefshiXPjIGfklahNgcnudZ05i98vt+gGrcBVC10F+gwN1DBzahiJfSkPWW3GmuR8gPqoVBCW1zrwwiBYppRtAeeR51OeXN9G1pYEPIh+TekvxsQYDnilaEgndaZ08Mgs0vdJs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=RIryVE8G; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="RIryVE8G"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1724695113;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=PBgRdIE0fHsznPVlKpBGuT212MrBY8tRlvifAXJEjaA=;
	b=RIryVE8G7pU0UAFBheVIXPADS6QL3SMaO5p3ERxkK1l7S2hRoq8f5lakf+PDsvrpOe6Ccv
	8bQOt87Kn1ExnuMJxQIJMC1HuuBvhoBg+x0UVpaEsfHSHKAOpILvZbZhtbwsIGb8xuQfgp
	Z5YYIC2QhEnT6fqk+Zc4tbMAJVI7//I=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-378-yQ2ZEuefOtCKeeNswtEoWw-1; Mon,
 26 Aug 2024 13:58:29 -0400
X-MC-Unique: yQ2ZEuefOtCKeeNswtEoWw-1
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 4B8A91953956;
	Mon, 26 Aug 2024 17:58:26 +0000 (UTC)
Received: from RHTRH0061144 (unknown [10.22.8.86])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 6C1181955F40;
	Mon, 26 Aug 2024 17:58:21 +0000 (UTC)
From: Aaron Conole <aconole@redhat.com>
To: Hongbo Li via dev <ovs-dev@openvswitch.org>
Cc: <johannes@sipsolutions.net>,  <davem@davemloft.net>,
  <edumazet@google.com>,  <kuba@kernel.org>,  <pabeni@redhat.com>,
  <allison.henderson@oracle.com>,  <dsahern@kernel.org>,
  <pshelar@ovn.org>,  Hongbo Li <lihongbo22@huawei.com>,
  <linux-wireless@vger.kernel.org>,  <netdev@vger.kernel.org>,
  <rds-devel@oss.oracle.com>,  <dccp@vger.kernel.org>,
  <dev@openvswitch.org>,  <linux-afs@lists.infradead.org>
Subject: Re: [ovs-dev] [PATCH net-next 6/8] net/openvswitch: Use max() to
 simplify the code
In-Reply-To: <20240824074033.2134514-7-lihongbo22@huawei.com> (Hongbo Li via
	dev's message of "Sat, 24 Aug 2024 15:40:31 +0800")
References: <20240824074033.2134514-1-lihongbo22@huawei.com>
	<20240824074033.2134514-7-lihongbo22@huawei.com>
User-Agent: Gnus/5.13 (Gnus v5.13)
Date: Mon, 26 Aug 2024 13:58:19 -0400
Message-ID: <f7t4j7788uc.fsf@redhat.com>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Hongbo Li via dev <ovs-dev@openvswitch.org> writes:

> Let's use max() to simplify the code and fix the
> Coccinelle/coccicheck warning reported by minmax.cocci.
>
> Signed-off-by: Hongbo Li <lihongbo22@huawei.com>
> ---

Reviewed-by: Aaron Conole <aconole@redhat.com>

>  net/openvswitch/vport.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
> index 8732f6e51ae5..859208df65ea 100644
> --- a/net/openvswitch/vport.c
> +++ b/net/openvswitch/vport.c
> @@ -534,7 +534,7 @@ static int packet_length(const struct sk_buff *skb,
>  	 * account for 802.1ad. e.g. is_skb_forwardable().
>  	 */
>  
> -	return length > 0 ? length : 0;
> +	return max(length, 0);
>  }
>  
>  void ovs_vport_send(struct vport *vport, struct sk_buff *skb, u8 mac_proto)

