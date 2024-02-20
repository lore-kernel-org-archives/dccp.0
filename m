Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C3D0B77631
	for <dccp@vger.kernel.org>; Tue, 20 Feb 2024 17:38:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1708450714; cv=none; b=JTEOC6Ym/AyuCHUwdGY8ftsoRfUDdV4WEcJrD4yRKyJvciElp4U6OeN00Hs4CT+YdnybT+CF9BffDHvKk/IoFqACtUHVOq0QmQucMNyKR0OImSLOvGLIP8sTa9OYNfQCcxlKfX72I3q0L00P91dD3Cuwudh31tZUNJiUna4DQgg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1708450714; c=relaxed/simple;
	bh=sWPQxpJ5JhFTeEb001dgjhbqbJO6mGNTN4LhH7v9mso=;
	h=From:To:Cc:Subject:In-Reply-To:References:Date:Message-ID:
	 MIME-Version:Content-Type; b=bqU/D0JB5F6NoU+mZcGn8tcFbaFj44m5scw5ZwCalGCJYjhOkgENEZ5BY1N6eAAB1xtWK1ozOlNIakqlVsrIOA7Qmolsjzs6BPfST4nZ4qJbghGvBSLPE3VFNmkBB3T+sPEjIEZhpj7rkcXmvGigIwQUSr/g40hpiWdyVHTqezg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=CUtbcg6I; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CUtbcg6I"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1708450711;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=qn55PbDxlcyDzSN0idKbH2F2di32wdsURfOsZLp+bU0=;
	b=CUtbcg6I7RQiiJQl4ovHoybHixIkZ09p8DF65nRVNrpzwwD12p2/6/Xmn9hs1FPB3oeTTQ
	18ewXrAWan/aLIyzqqT7l/irXQqMZSbXF/35wYiot7m6DGWOjCmx3ISKhKo22jMBXIwwMh
	QmAQag6qb0A+6+OW22qDFG6cLEf6m1k=
Received: from mail-qv1-f71.google.com (mail-qv1-f71.google.com
 [209.85.219.71]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-154-c20iB8RlMTO421F0mPtzIQ-1; Tue, 20 Feb 2024 12:38:30 -0500
X-MC-Unique: c20iB8RlMTO421F0mPtzIQ-1
Received: by mail-qv1-f71.google.com with SMTP id 6a1803df08f44-6800aa45af1so78043566d6.3
        for <dccp@vger.kernel.org>; Tue, 20 Feb 2024 09:38:30 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1708450709; x=1709055509;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=qn55PbDxlcyDzSN0idKbH2F2di32wdsURfOsZLp+bU0=;
        b=WjnvSDNQ1Lp5ONWjULUS0tlxhhm4E1WXeYT0v35drUUONgzC/7jhfsaU9f8a+eYvf9
         acV/Jmgg3Ootdk5TWjP0wKesRgIiT+sBHtrvXSG4svtI7lj37UMaidC9dgOsIiH/RF49
         /gP8qpseUbcxxRy4IzsrE+Z8HEJH+fkIxVXq7gKcZtcPjxauv1qUhclQKHzOc8aiCo8C
         jrLpbCvaSOkT5KU/j5uXwLfe0CgWPIoBMjEKMoxFBEw2+9gxzjoqixhy4ddr7p1ZYzFC
         jTwBCvnRxs733WJbSUd0jm41vZS9yzdWzhwhpZ+MWbSoaf04N+s29w69juKqMtOoN4BR
         Kl/g==
X-Forwarded-Encrypted: i=1; AJvYcCVjesqj3LrWsD15tkq778cWKaAE32xwxgdCf4Dm63Mf8h+88/eAvEDJVBUifMvwiRVCNs4LT8/34rLU66bipxZxfJyQeQ==
X-Gm-Message-State: AOJu0Yzac9NnXHocIvejxNcsqXQzrsg/qSXBYt+cEzU0rSixn14wzLis
	syYEBLspsbKt65ujBDNn8hKh/PBKZzHLjYEDMUgtovR9q1xZ7r2cr+7Lt8IP3g2sT4P56dXa8th
	etxxCsyNnBiCFT6klUz0/YWMovhXNRIhjsWpKDU85eKW+AG3qbAM=
X-Received: by 2002:a05:6214:e61:b0:68f:6260:f723 with SMTP id jz1-20020a0562140e6100b0068f6260f723mr7978323qvb.49.1708450709580;
        Tue, 20 Feb 2024 09:38:29 -0800 (PST)
X-Google-Smtp-Source: AGHT+IGPEiisDHYagQqfgdyTO0C+ZU+atUpAKG/0i+pMgPq3cIPMfW9JW9MVlTXN5kfFRL0jV660rA==
X-Received: by 2002:a05:6214:e61:b0:68f:6260:f723 with SMTP id jz1-20020a0562140e6100b0068f6260f723mr7978308qvb.49.1708450709254;
        Tue, 20 Feb 2024 09:38:29 -0800 (PST)
Received: from vschneid-thinkpadt14sgen2i.remote.csb (213-44-141-166.abo.bbox.fr. [213.44.141.166])
        by smtp.gmail.com with ESMTPSA id nc9-20020a0562142dc900b0068f58a8e09csm3498212qvb.108.2024.02.20.09.38.26
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 20 Feb 2024 09:38:28 -0800 (PST)
From: Valentin Schneider <vschneid@redhat.com>
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: bigeasy@linutronix.de, davem@davemloft.net, dccp@vger.kernel.org,
 dsahern@kernel.org, edumazet@google.com, juri.lelli@redhat.com,
 kuba@kernel.org, linux-kernel@vger.kernel.org,
 linux-rt-users@vger.kernel.org, mleitner@redhat.com,
 netdev@vger.kernel.org, pabeni@redhat.com, tglozar@redhat.com,
 tglx@linutronix.de, kuniyu@amazon.com
Subject: Re: [PATCH v3 1/1] tcp/dcpp: Un-pin tw_timer
In-Reply-To: <20240219185537.13666-1-kuniyu@amazon.com>
References: <20240219095729.2339914-2-vschneid@redhat.com>
 <20240219185537.13666-1-kuniyu@amazon.com>
Date: Tue, 20 Feb 2024 18:38:25 +0100
Message-ID: <xhsmhmsrvf33i.mognet@vschneid-thinkpadt14sgen2i.remote.csb>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 19/02/24 10:55, Kuniyuki Iwashima wrote:
> From: Valentin Schneider <vschneid@redhat.com>
>> @@ -53,16 +53,14 @@ void dccp_time_wait(struct sock *sk, int state, int timeo)
>>  		if (state == DCCP_TIME_WAIT)
>>  			timeo = DCCP_TIMEWAIT_LEN;
>>  
>> -		/* tw_timer is pinned, so we need to make sure BH are disabled
>> -		 * in following section, otherwise timer handler could run before
>> -		 * we complete the initialization.
>> -		 */
>> -		local_bh_disable();
>> -		inet_twsk_schedule(tw, timeo);
>> -		/* Linkage updates.
>> -		 * Note that access to tw after this point is illegal.
>> -		 */
>> +	       local_bh_disable();
>
> This line seems not correctly indented, same for TCP change.
>
>
>
>> +
>> +		// Linkage updates
>>  		inet_twsk_hashdance(tw, sk, &dccp_hashinfo);
>> +		inet_twsk_schedule(tw, timeo);
>> +		// Access to tw after this point is illegal.
>
> Also please use /**/ style for these comments, same for TCP too.
>

Will do, thanks!

