Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E166F10E3;
	Fri, 21 Jun 2024 01:36:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718933800; cv=none; b=ILv9jM4W/kK245uiyrHMlb/JzEILdriHDnWHgLdZ/vwRCdbGk3HAvcWc2TEDuiutRAtc4f7FU0tGVT+4fKC8nAKHTWrtlUxTH3Km4CL21Lm1kYmNyB+Iz8CW5l7/OOM1Tk9JWnPi3m5ZL1km9m5p3FQESEGAtMHUfjoXSg4+Byc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718933800; c=relaxed/simple;
	bh=f1lUzGrNttZNp3wLOBzLTMlkvcvk1eCekF6iV4dmk2k=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=cG9b+LjuJ2P9HyO4auabWqOm6Kjf5yPvURk5zYD0WCuJhjurRpXVbFkZ/ViKIZKR4lmS/ps+B54Hz09fHvlrX+z3Tm6AH3omSQB+YYH5spdzJBJhJrteACOW3xYsezEsCefxml1C3rhSOJwV89Mq5q+ajuvJXRT6l45Ho/zV9/w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: ab4e7d0e2f6e11ef9305a59a3cc225df-20240621
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:a2ca5ed6-ab13-4f50-9986-fb5f91654265,IP:10,
	URL:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTI
	ON:release,TS:-5
X-CID-INFO: VERSION:1.1.38,REQID:a2ca5ed6-ab13-4f50-9986-fb5f91654265,IP:10,UR
	L:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTION
	:release,TS:-5
X-CID-META: VersionHash:82c5f88,CLOUDID:20a29486e40e81aea773cbac1da97898,BulkI
	D:240617193145NAFL2O91,BulkQuantity:6,Recheck:0,SF:64|66|24|17|19|44|102,T
	C:nil,Content:0,EDM:-3,IP:-2,URL:0,File:nil,RT:nil,Bulk:40,QS:nil,BEC:nil,
	COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0
X-CID-BAS: 0,_,0,_
X-CID-FACTOR: TF_CID_SPAM_FAS,TF_CID_SPAM_FSD,TF_CID_SPAM_FSI,TF_CID_SPAM_SNR
X-UUID: ab4e7d0e2f6e11ef9305a59a3cc225df-20240621
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 2095884178; Fri, 21 Jun 2024 09:36:23 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 8C2E9B803C9D;
	Fri, 21 Jun 2024 09:36:23 +0800 (CST)
X-ns-mid: postfix-6674D917-446331139
Received: from [10.42.12.252] (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id 480E0B803C9D;
	Fri, 21 Jun 2024 01:36:16 +0000 (UTC)
Message-ID: <6508a8d3-cf46-7f28-c7d1-b2a4662d08f7@kylinos.cn>
Date: Fri, 21 Jun 2024 09:36:15 +0800
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.11.0
Subject: Re: [PATCH net v3] Fix race for duplicate reqsk on identical SYN
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: alexandre.ferrieux@orange.com, davem@davemloft.net, dccp@vger.kernel.org,
 dsahern@kernel.org, edumazet@google.com, fw@strlen.de, kuba@kernel.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, pabeni@redhat.com
References: <2f96ebeb-f366-fda1-f6d6-88ff2637c7cd@kylinos.cn>
 <20240620191424.50269-1-kuniyu@amazon.com>
Content-Language: en-US
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
In-Reply-To: <20240620191424.50269-1-kuniyu@amazon.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable


=E5=9C=A8 2024/6/21 03:14, Kuniyuki Iwashima =E5=86=99=E9=81=93:
> From: luoxuanqiang <luoxuanqiang@kylinos.cn>
> Date: Thu, 20 Jun 2024 10:38:36 +0800
>> =E5=9C=A8 2024/6/20 03:53, Kuniyuki Iwashima =E5=86=99=E9=81=93:
>>> From: luoxuanqiang <luoxuanqiang@kylinos.cn>
>>> Date: Wed, 19 Jun 2024 14:54:15 +0800
>>>> =E5=9C=A8 2024/6/18 01:59, Kuniyuki Iwashima =E5=86=99=E9=81=93:
>>>>> From: luoxuanqiang <luoxuanqiang@kylinos.cn>
>>>>> Date: Mon, 17 Jun 2024 15:56:40 +0800
>>>>>> When bonding is configured in BOND_MODE_BROADCAST mode, if two ide=
ntical
>>>>>> SYN packets are received at the same time and processed on differe=
nt CPUs,
>>>>>> it can potentially create the same sk (sock) but two different req=
sk
>>>>>> (request_sock) in tcp_conn_request().
>>>>>>
>>>>>> These two different reqsk will respond with two SYNACK packets, an=
d since
>>>>>> the generation of the seq (ISN) incorporates a timestamp, the fina=
l two
>>>>>> SYNACK packets will have different seq values.
>>>>>>
>>>>>> The consequence is that when the Client receives and replies with =
an ACK
>>>>>> to the earlier SYNACK packet, we will reset(RST) it.
>>>>>>
>>>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>>>
>>>>>> This behavior is consistently reproducible in my local setup,
>>>>>> which comprises:
>>>>>>
>>>>>>                      | NETA1 ------ NETB1 |
>>>>>> PC_A --- bond --- |                    | --- bond --- PC_B
>>>>>>                      | NETA2 ------ NETB2 |
>>>>>>
>>>>>> - PC_A is the Server and has two network cards, NETA1 and NETA2. I=
 have
>>>>>>      bonded these two cards using BOND_MODE_BROADCAST mode and con=
figured
>>>>>>      them to be handled by different CPU.
>>>>>>
>>>>>> - PC_B is the Client, also equipped with two network cards, NETB1 =
and
>>>>>>      NETB2, which are also bonded and configured in BOND_MODE_BROA=
DCAST mode.
>>>>>>
>>>>>> If the client attempts a TCP connection to the server, it might en=
counter
>>>>>> a failure. Capturing packets from the server side reveals:
>>>>>>
>>>>>> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
>>>>>> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
>>>>>> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855116,
>>>>>> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855123, <=3D=3D
>>>>>> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
>>>>>> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
>>>>>> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117, <=3D=3D
>>>>>> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117,
>>>>>>
>>>>>> Two SYNACKs with different seq numbers are sent by localhost,
>>>>>> resulting in an anomaly.
>>>>>>
>>>>>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>>>>>
>>>>>> The attempted solution is as follows:
>>>>>> In the tcp_conn_request(), while inserting reqsk into the ehash ta=
ble,
>>>>>> it also checks if an entry already exists. If found, it avoids
>>>>>> reinsertion and releases it.
>>>>>>
>>>>>> Simultaneously, In the reqsk_queue_hash_req(), the start of the
>>>>>> req->rsk_timer is adjusted to be after successful insertion.
>>>>>>
>>>>>> Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>
>>>>>> ---
>>>>>>     include/net/inet_connection_sock.h |  4 ++--
>>>>>>     net/dccp/ipv4.c                    |  2 +-
>>>>>>     net/dccp/ipv6.c                    |  2 +-
>>>>>>     net/ipv4/inet_connection_sock.c    | 19 +++++++++++++------
>>>>>>     net/ipv4/tcp_input.c               |  9 ++++++++-
>>>>>>     5 files changed, 25 insertions(+), 11 deletions(-)
>>>>>>
>>>>>> diff --git a/include/net/inet_connection_sock.h b/include/net/inet=
_connection_sock.h
>>>>>> index 7d6b1254c92d..8ebab6220dbc 100644
>>>>>> --- a/include/net/inet_connection_sock.h
>>>>>> +++ b/include/net/inet_connection_sock.h
>>>>>> @@ -263,8 +263,8 @@ struct dst_entry *inet_csk_route_child_sock(co=
nst struct sock *sk,
>>>>>>     struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
>>>>>>     				      struct request_sock *req,
>>>>>>     				      struct sock *child);
>>>>>> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct reques=
t_sock *req,
>>>>>> -				   unsigned long timeout);
>>>>>> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct reques=
t_sock *req,
>>>>>> +				   unsigned long timeout, bool *found_dup_sk);
>>>>>>     struct sock *inet_csk_complete_hashdance(struct sock *sk, stru=
ct sock *child,
>>>>>>     					 struct request_sock *req,
>>>>>>     					 bool own_req);
>>>>>> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
>>>>>> index ff41bd6f99c3..13aafdeb9205 100644
>>>>>> --- a/net/dccp/ipv4.c
>>>>>> +++ b/net/dccp/ipv4.c
>>>>>> @@ -657,7 +657,7 @@ int dccp_v4_conn_request(struct sock *sk, stru=
ct sk_buff *skb)
>>>>>>     	if (dccp_v4_send_response(sk, req))
>>>>>>     		goto drop_and_free;
>>>>>>    =20
>>>>>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
>>>>>> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
>>>>>>     	reqsk_put(req);
>>>>>>     	return 0;
>>>>>>    =20
>>>>>> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
>>>>>> index 85f4b8fdbe5e..493cdb12ce2b 100644
>>>>>> --- a/net/dccp/ipv6.c
>>>>>> +++ b/net/dccp/ipv6.c
>>>>>> @@ -400,7 +400,7 @@ static int dccp_v6_conn_request(struct sock *s=
k, struct sk_buff *skb)
>>>>>>     	if (dccp_v6_send_response(sk, req))
>>>>>>     		goto drop_and_free;
>>>>>>    =20
>>>>>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
>>>>>> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
>>>>>>     	reqsk_put(req);
>>>>>>     	return 0;
>>>>>>    =20
>>>>>> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_conne=
ction_sock.c
>>>>>> index d81f74ce0f02..2fa9b33ae26a 100644
>>>>>> --- a/net/ipv4/inet_connection_sock.c
>>>>>> +++ b/net/ipv4/inet_connection_sock.c
>>>>>> @@ -1122,25 +1122,32 @@ static void reqsk_timer_handler(struct tim=
er_list *t)
>>>>>>     	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
>>>>>>     }
>>>>>>    =20
>>>>>> -static void reqsk_queue_hash_req(struct request_sock *req,
>>>>>> -				 unsigned long timeout)
>>>>>> +static bool reqsk_queue_hash_req(struct request_sock *req,
>>>>>> +				 unsigned long timeout, bool *found_dup_sk)
>>>>>>     {
>>>>> Given any changes here in reqsk_queue_hash_req() conflicts with 4.1=
9
>>>>> (oldest stable) and DCCP does not check found_dup_sk, you can defin=
e
>>>>> found_dup_sk here, then you need not touch DCCP at all.
>>>> Apologies for not fully understanding your advice. If we cannot modi=
fy
>>>> the content of reqsk_queue_hash_req() and should avoid touching the =
DCCP
>>>> part, it seems the issue requires reworking some interfaces. Specifi=
cally:
>>>>
>>>> The call flow to add reqsk to ehash is as follows:
>>>>
>>>> tcp_conn_request()
>>>>
>>>> dccp_v4(6)_conn_request()
>>>>
>>>>        -> inet_csk_reqsk_queue_hash_add()
>>>>
>>>>            -> reqsk_queue_hash_req()
>>>>
>>>>                -> inet_ehash_insert()
>>>>
>>>> tcp_conn_request() needs to call the same interface inet_csk_reqsk_q=
ueue_hash_add()
>>>> as dccp_v4(6)_conn_request(), but the critical section for installat=
ion check and
>>>> insertion into ehash is within inet_ehash_insert().
>>>> If reqsk_queue_hash_req() should not be modified, then we need to re=
write
>>>> the interfaces to distinguish them. I don't see how redefining found=
_dup_sk
>>>> alone can resolve this conflict point.
>>> I just said we cannot avoid conflict so suggested avoiding found_dup_=
sk
>>> in inet_csk_reqsk_queue_hash_add().
>>>
>>> But I finally ended up modifying DCCP because we return before settin=
g
>>> refcnt.
>>>
>>> ---8<---
>>> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
>>> index ff41bd6f99c3..b2a8aed35eb0 100644
>>> --- a/net/dccp/ipv4.c
>>> +++ b/net/dccp/ipv4.c
>>> @@ -657,8 +657,11 @@ int dccp_v4_conn_request(struct sock *sk, struct=
 sk_buff *skb)
>>>    	if (dccp_v4_send_response(sk, req))
>>>    		goto drop_and_free;
>>>   =20
>>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
>>> -	reqsk_put(req);
>>> +	if (unlikely(inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_IN=
IT)))
>>> +		reqsk_free(req);
>>> +	else
>>> +		reqsk_put(req);
>>> +
>>>    	return 0;
>>>   =20
>>>    drop_and_free:
>>> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connecti=
on_sock.c
>>> index d81f74ce0f02..7dd6892b10b9 100644
>>> --- a/net/ipv4/inet_connection_sock.c
>>> +++ b/net/ipv4/inet_connection_sock.c
>>> @@ -1122,25 +1122,33 @@ static void reqsk_timer_handler(struct timer_=
list *t)
>>>    	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
>>>    }
>>>   =20
>>> -static void reqsk_queue_hash_req(struct request_sock *req,
>>> +static bool reqsk_queue_hash_req(struct request_sock *req,
>>>    				 unsigned long timeout)
>>>    {
>>> +	bool found_dup_sk;
>>> +
>>> +	if (!inet_ehash_insert(req_to_sk(req), NULL, &found_dup_sk))
>>> +		return false;
>>> +
>>>    	timer_setup(&req->rsk_timer, reqsk_timer_handler, TIMER_PINNED);
>>>    	mod_timer(&req->rsk_timer, jiffies + timeout);
>>>   =20
>>> -	inet_ehash_insert(req_to_sk(req), NULL, NULL);
>>>    	/* before letting lookups find us, make sure all req fields
>>>    	 * are committed to memory and refcnt initialized.
>>>    	 */
>>>    	smp_wmb();
>>>    	refcount_set(&req->rsk_refcnt, 2 + 1);
>>> +	return true;
>>>    }
>>>   =20
>>> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_s=
ock *req,
>>> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_s=
ock *req,
>>>    				   unsigned long timeout)
>>>    {
>>> -	reqsk_queue_hash_req(req, timeout);
>>> +	if (!reqsk_queue_hash_req(req, timeout))
>>> +		return false;
>>> +
>>>    	inet_csk_reqsk_queue_added(sk);
>>> +	return true;
>>>    }
>>>    EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
>>>   =20
>>> ---8<---
>> Thank you for your patient explanation. I understand
>> your point and will send out the V4 version, looking
>> forward to your review.
>>
>> Also, I'd like to confirm a detail with you. For the DCCP part, is it
>>    sufficient to simply call reqsk_free() for the return value, or sho=
uld
>> we use goto drop_and_free? The different return values here will
>> determine whether a reset is sent, and I lack a comprehensive
>> understanding of DCCP. so could you please help me confirm this
>> from a higher-level perspective?
> I think we need not send RST because in this case there's another
> establishing request already in ehash and we should not abort it
> as we don't do so in tcp_conn_request().
>
> Thanks!

Thank you for confirming. Best wishes!=C2=A0:)

>
>> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
>> index ff41bd6f99c3..5926159a6f20 100644
>> --- a/net/dccp/ipv4.c
>> +++ b/net/dccp/ipv4.c
>> @@ -657,8 +657,11 @@ int dccp_v4_conn_request(struct sock *sk, struct =
sk_buff *skb)
>>           if (dccp_v4_send_response(sk, req))
>>                   goto drop_and_free;
>>   =20
>> -       inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
>> -       reqsk_put(req);
>> +       if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIME=
OUT_INIT)))
>> +               reqsk_free(req);    // or  goto drop_and_free:   <=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> +       else
>> +               reqsk_put(req);
>> +
>>           return 0;
>>   =20
>> drop_and_free:
>>       reqsk_free(req);
>> drop:
>>       __DCCP_INC_STATS(DCCP_MIB_ATTEMPTFAILS);
>>       return -1;
>> }
