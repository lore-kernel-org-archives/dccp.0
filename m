Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D899379F3;
	Mon, 17 Jun 2024 02:02:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718589729; cv=none; b=LOQC7+oO/UFvY0E0Rb4sUfD8KeyZP7uWLoGOGToqhQASKC7mLHG7dgKU1DUQ5XzIuhMDH7VHpFOyittQOW3wmo75burCUUhPIkTuN+WRIZxSS4ERjD0uQXyRlvAOql852x7nd3Xr2h/ZhYtBv9cFs4o4++iQGjB6QLq1jrgFzTI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718589729; c=relaxed/simple;
	bh=dS5Hf5PF/BBHjek4zHm6BwGxbfrTvkffFV4G4hjToFA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=GGkZnFvdeuqBNSot47HlhpcWNsDQezHzBrzUw+UVh0R57UyrPnUCoiEwthX/sWnYKmm3uhgjMzjwz3ji9IMJiwuMKXq8DbC7LEyUdClol0xqURdzfcRw8lX8uczI0I6nhWtiBxROQjImAVvUDAjJrW8dZctsAv03DwgR5BnxBtE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 90f4a2a42c4d11ef9305a59a3cc225df-20240617
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:411dbe07-2d62-4b21-9105-204ca0cfe776,IP:10,
	URL:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:28,RULE:Release_Ham,ACT
	ION:release,TS:23
X-CID-INFO: VERSION:1.1.38,REQID:411dbe07-2d62-4b21-9105-204ca0cfe776,IP:10,UR
	L:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:28,RULE:Release_Ham,ACTIO
	N:release,TS:23
X-CID-META: VersionHash:82c5f88,CLOUDID:8b41239fdb8ca44841a2853ec9b96da0,BulkI
	D:240614185458SXRYECY3,BulkQuantity:5,Recheck:0,SF:64|66|38|24|17|19|44|10
	2,TC:nil,Content:0,EDM:-3,IP:-2,URL:0,File:nil,RT:nil,Bulk:40|20,QS:nil,BE
	C:nil,COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0,NGT
X-CID-BAS: 0,NGT,0,_
X-CID-FACTOR: TF_CID_SPAM_SNR,TF_CID_SPAM_FAS,TF_CID_SPAM_FSD,TF_CID_SPAM_FSI,
	TF_CID_SPAM_FCD
X-UUID: 90f4a2a42c4d11ef9305a59a3cc225df-20240617
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 1255556198; Mon, 17 Jun 2024 10:01:52 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 44BB4B80758A;
	Mon, 17 Jun 2024 10:01:52 +0800 (CST)
X-ns-mid: postfix-666F9910-122784188
Received: from [10.42.12.252] (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id 58349B80758A;
	Mon, 17 Jun 2024 02:01:49 +0000 (UTC)
Message-ID: <b20c01d5-5a8f-03e6-6573-ea46e0df5ebb@kylinos.cn>
Date: Mon, 17 Jun 2024 10:01:48 +0800
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.11.0
Subject: Re: [PATCH net v2] Fix race for duplicate reqsk on identical SYN
Content-Language: en-US
To: Eric Dumazet <edumazet@google.com>, Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: davem@davemloft.net, dccp@vger.kernel.org, dsahern@kernel.org,
 fw@strlen.de, kuba@kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, pabeni@redhat.com
References: <7075bb26-ede9-0dc7-fe93-e18703e5ddaa@kylinos.cn>
 <20240614222433.19580-1-kuniyu@amazon.com>
 <CANn89i+RP1K+mOd5V7LOKMFtMhy0rZrpFDCDQ-RbQ31GkYbc9g@mail.gmail.com>
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
In-Reply-To: <CANn89i+RP1K+mOd5V7LOKMFtMhy0rZrpFDCDQ-RbQ31GkYbc9g@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable


=E5=9C=A8 2024/6/15 14:40, Eric Dumazet =E5=86=99=E9=81=93:
> On Sat, Jun 15, 2024 at 12:24=E2=80=AFAM Kuniyuki Iwashima <kuniyu@amaz=
on.com> wrote:
>> From: luoxuanqiang <luoxuanqiang@kylinos.cn>
>> Date: Fri, 14 Jun 2024 20:42:07 +0800
>>> =E5=9C=A8 2024/6/14 18:54, Florian Westphal =E5=86=99=E9=81=93:
>>>> luoxuanqiang <luoxuanqiang@kylinos.cn> wrote:
>>>>>    include/net/inet_connection_sock.h |  2 +-
>>>>>    net/dccp/ipv4.c                    |  2 +-
>>>>>    net/dccp/ipv6.c                    |  2 +-
>>>>>    net/ipv4/inet_connection_sock.c    | 15 +++++++++++----
>>>>>    net/ipv4/tcp_input.c               | 11 ++++++++++-
>>>>>    5 files changed, 24 insertions(+), 8 deletions(-)
>>>>>
>>>>> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_=
connection_sock.h
>>>>> index 7d6b1254c92d..8773d161d184 100644
>>>>> --- a/include/net/inet_connection_sock.h
>>>>> +++ b/include/net/inet_connection_sock.h
>>>>> @@ -264,7 +264,7 @@ struct sock *inet_csk_reqsk_queue_add(struct so=
ck *sk,
>>>>>                                   struct request_sock *req,
>>>>>                                   struct sock *child);
>>>>>    void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct reque=
st_sock *req,
>>>>> -                             unsigned long timeout);
>>>>> +                             unsigned long timeout, bool *found_du=
p_sk);
>>>> Nit:
>>>>
>>>> I think it would be preferrable to change retval to bool rather than
>>>> bool *found_dup_sk extra arg, so one can do
>> +1
>>
>>
>>>> bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_s=
ock *req,
>>>>                                 unsigned long timeout)
>>>> {
>>>>      if (!reqsk_queue_hash_req(req, timeout))
>>>>              return false;
>>>>
>>>> i.e. let retval indicate wheter reqsk was inserted or not.
>>>>
>>>> Patch looks good to me otherwise.
>>> Thank you for your confirmation!
>>>
>>> Regarding your suggestion, I had considered it before,
>>> but besides tcp_conn_request() calling inet_csk_reqsk_queue_hash_add(=
),
>>> dccp_v4(v6)_conn_request() also calls it. However, there is no
>>> consideration for a failed insertion within that function, so it's
>>> reasonable to let the caller decide whether to check for duplicate
>>> reqsk.
>> I guess you followed 01770a1661657 where found_dup_sk was introduced,
>> but note that the commit is specific to TCP SYN Cookie and TCP Fast Op=
en
>> and DCCP is not related.
>>
>> Then, own_req is common to TCP and DCCP, so found_dup_sk was added as =
an
>> additional argument.
>>
>> However, another similar commit 5e0724d027f05 actually added own_req c=
heck
>> in DCCP path.
>>
>> I personally would'nt care if DCCP was not changed to handle such a
>> failure because DCCP will be removed next year, but I still prefer
>> Florian's suggestion.
>>
> Other things to consider :
>
> - I presume this patch targets net tree, and luoxuanqiang needs the
> fix to reach stable trees.
>
> - This means a Fixes: tag is needed
>
> - This also means that we should favor a patch with no or trivial
> conflicts for stable backports.
>
> Should the patch target the net-next tree, then the requirements can
> be different.

Hello Eric and Kuniyuk,

Thank you for the information!

I've tested the kernel versions 4.19 and 6.10, and they both have
similar issues (I suspect this problem has been around for quite some
time). My intention is to propose a fix to the more stable branches as
soon as possible to cover a wider range. Like Eric mentioned, I hope to
minimize conflicts, so I expect to keep the original DCCP logic intact
and refer to the check for found_dup_sk in 01770a1661657. For DCCP, if
insertion into ehash fails, we might also need to consider handling
rsk_refcnt, as tcp_conn_request() requires rsk_refcnt to be 0 to release
reqsk.

Of course, if DCCP will be removed from net-next, I agree with
Kuniyuki and Florian's suggestions and will envision a better commit
content.

BRs!

