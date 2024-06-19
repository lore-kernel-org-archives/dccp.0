Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DBAED74062;
	Wed, 19 Jun 2024 07:05:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718780739; cv=none; b=eg78WOsxulXs8rQJFlKC2J7L9EUiZF4wpAgBunbIzncjtR0AeIiBM4GtGxJQ0w+GCZRjsANUGAaUinWJL7nUiCey215JVAq4+QvFhFQlOGG1kCfR+tQMS+wXnxIIohFuKkbNPMQhabwNeTQvX7UgcCNLKW6ncanFsHIu7+rqbfk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718780739; c=relaxed/simple;
	bh=vLxu3OkivXxxVVRVE1Q0z6iD753lqUyM5EL3Hr3aS3Y=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=RtsjtKKuq4r2IJY7+OSw7DWIWPplSya0oAC7bW4ZMKMyBc0p7gPS8j1nYITQseSG36Pg7db9qDfMomnxoV21b8ND/KTCr5fM5pB3fOI4Kn9emlOuy/s9HODSqQ9HeY9g86oIg3mAbiGvY2mBZh6omu0noyMeC4cBwQwu0edmGKY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: d07e09bc2e0811ef9305a59a3cc225df-20240619
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:35f24287-7864-4234-86c4-6d70ba1bc597,IP:20,
	URL:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTI
	ON:release,TS:5
X-CID-INFO: VERSION:1.1.38,REQID:35f24287-7864-4234-86c4-6d70ba1bc597,IP:20,UR
	L:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTION
	:release,TS:5
X-CID-META: VersionHash:82c5f88,CLOUDID:41f3b6aba82db87615039219a6aad05c,BulkI
	D:240617193145NAFL2O91,BulkQuantity:2,Recheck:0,SF:66|24|17|19|44|64|102,T
	C:nil,Content:0,EDM:-3,IP:-2,URL:0,File:nil,RT:nil,Bulk:40,QS:nil,BEC:nil,
	COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0
X-CID-BAS: 0,_,0,_
X-CID-FACTOR: TF_CID_SPAM_SNR,TF_CID_SPAM_FAS,TF_CID_SPAM_FSD,TF_CID_SPAM_FSI
X-UUID: d07e09bc2e0811ef9305a59a3cc225df-20240619
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 1811458425; Wed, 19 Jun 2024 14:54:46 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 18E77B80758A;
	Wed, 19 Jun 2024 14:54:46 +0800 (CST)
X-ns-mid: postfix-667280B5-9150993
Received: from [10.42.12.252] (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id 37A2DB80758A;
	Wed, 19 Jun 2024 06:54:41 +0000 (UTC)
Message-ID: <f1e13509-9544-0fa5-4cb4-520c068bde6a@kylinos.cn>
Date: Wed, 19 Jun 2024 14:54:15 +0800
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.11.0
Subject: Re: [PATCH net v3] Fix race for duplicate reqsk on identical SYN
Content-Language: en-US
To: Kuniyuki Iwashima <kuniyu@amazon.com>
Cc: alexandre.ferrieux@orange.com, davem@davemloft.net, dccp@vger.kernel.org,
 dsahern@kernel.org, edumazet@google.com, fw@strlen.de, kuba@kernel.org,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org, pabeni@redhat.com
References: <20240617075640.207570-1-luoxuanqiang@kylinos.cn>
 <20240617175907.60655-1-kuniyu@amazon.com>
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
In-Reply-To: <20240617175907.60655-1-kuniyu@amazon.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable


=E5=9C=A8 2024/6/18 01:59, Kuniyuki Iwashima =E5=86=99=E9=81=93:
> From: luoxuanqiang <luoxuanqiang@kylinos.cn>
> Date: Mon, 17 Jun 2024 15:56:40 +0800
>> When bonding is configured in BOND_MODE_BROADCAST mode, if two identic=
al
>> SYN packets are received at the same time and processed on different C=
PUs,
>> it can potentially create the same sk (sock) but two different reqsk
>> (request_sock) in tcp_conn_request().
>>
>> These two different reqsk will respond with two SYNACK packets, and si=
nce
>> the generation of the seq (ISN) incorporates a timestamp, the final tw=
o
>> SYNACK packets will have different seq values.
>>
>> The consequence is that when the Client receives and replies with an A=
CK
>> to the earlier SYNACK packet, we will reset(RST) it.
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> This behavior is consistently reproducible in my local setup,
>> which comprises:
>>
>>                    | NETA1 ------ NETB1 |
>> PC_A --- bond --- |                    | --- bond --- PC_B
>>                    | NETA2 ------ NETB2 |
>>
>> - PC_A is the Server and has two network cards, NETA1 and NETA2. I hav=
e
>>    bonded these two cards using BOND_MODE_BROADCAST mode and configure=
d
>>    them to be handled by different CPU.
>>
>> - PC_B is the Client, also equipped with two network cards, NETB1 and
>>    NETB2, which are also bonded and configured in BOND_MODE_BROADCAST =
mode.
>>
>> If the client attempts a TCP connection to the server, it might encoun=
ter
>> a failure. Capturing packets from the server side reveals:
>>
>> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
>> 10.10.10.10.45182 > localhost: Flags [S], seq 320236027,
>> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855116,
>> localhost > 10.10.10.10.45182: Flags [S.], seq 2967855123, <=3D=3D
>> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
>> 10.10.10.10.45182 > localhost: Flags [.], ack 4294967290,
>> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117, <=3D=3D
>> localhost > 10.10.10.10.45182: Flags [R], seq 2967855117,
>>
>> Two SYNACKs with different seq numbers are sent by localhost,
>> resulting in an anomaly.
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> The attempted solution is as follows:
>> In the tcp_conn_request(), while inserting reqsk into the ehash table,
>> it also checks if an entry already exists. If found, it avoids
>> reinsertion and releases it.
>>
>> Simultaneously, In the reqsk_queue_hash_req(), the start of the
>> req->rsk_timer is adjusted to be after successful insertion.
>>
>> Signed-off-by: luoxuanqiang <luoxuanqiang@kylinos.cn>
>> ---
>>   include/net/inet_connection_sock.h |  4 ++--
>>   net/dccp/ipv4.c                    |  2 +-
>>   net/dccp/ipv6.c                    |  2 +-
>>   net/ipv4/inet_connection_sock.c    | 19 +++++++++++++------
>>   net/ipv4/tcp_input.c               |  9 ++++++++-
>>   5 files changed, 25 insertions(+), 11 deletions(-)
>>
>> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_con=
nection_sock.h
>> index 7d6b1254c92d..8ebab6220dbc 100644
>> --- a/include/net/inet_connection_sock.h
>> +++ b/include/net/inet_connection_sock.h
>> @@ -263,8 +263,8 @@ struct dst_entry *inet_csk_route_child_sock(const =
struct sock *sk,
>>   struct sock *inet_csk_reqsk_queue_add(struct sock *sk,
>>   				      struct request_sock *req,
>>   				      struct sock *child);
>> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_so=
ck *req,
>> -				   unsigned long timeout);
>> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_so=
ck *req,
>> +				   unsigned long timeout, bool *found_dup_sk);
>>   struct sock *inet_csk_complete_hashdance(struct sock *sk, struct soc=
k *child,
>>   					 struct request_sock *req,
>>   					 bool own_req);
>> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
>> index ff41bd6f99c3..13aafdeb9205 100644
>> --- a/net/dccp/ipv4.c
>> +++ b/net/dccp/ipv4.c
>> @@ -657,7 +657,7 @@ int dccp_v4_conn_request(struct sock *sk, struct s=
k_buff *skb)
>>   	if (dccp_v4_send_response(sk, req))
>>   		goto drop_and_free;
>>  =20
>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
>> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
>>   	reqsk_put(req);
>>   	return 0;
>>  =20
>> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
>> index 85f4b8fdbe5e..493cdb12ce2b 100644
>> --- a/net/dccp/ipv6.c
>> +++ b/net/dccp/ipv6.c
>> @@ -400,7 +400,7 @@ static int dccp_v6_conn_request(struct sock *sk, s=
truct sk_buff *skb)
>>   	if (dccp_v6_send_response(sk, req))
>>   		goto drop_and_free;
>>  =20
>> -	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
>> +	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT, NULL);
>>   	reqsk_put(req);
>>   	return 0;
>>  =20
>> diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connectio=
n_sock.c
>> index d81f74ce0f02..2fa9b33ae26a 100644
>> --- a/net/ipv4/inet_connection_sock.c
>> +++ b/net/ipv4/inet_connection_sock.c
>> @@ -1122,25 +1122,32 @@ static void reqsk_timer_handler(struct timer_l=
ist *t)
>>   	inet_csk_reqsk_queue_drop_and_put(oreq->rsk_listener, oreq);
>>   }
>>  =20
>> -static void reqsk_queue_hash_req(struct request_sock *req,
>> -				 unsigned long timeout)
>> +static bool reqsk_queue_hash_req(struct request_sock *req,
>> +				 unsigned long timeout, bool *found_dup_sk)
>>   {
> Given any changes here in reqsk_queue_hash_req() conflicts with 4.19
> (oldest stable) and DCCP does not check found_dup_sk, you can define
> found_dup_sk here, then you need not touch DCCP at all.

Apologies for not fully understanding your advice. If we cannot modify
the content of reqsk_queue_hash_req() and should avoid touching the DCCP
part, it seems the issue requires reworking some interfaces. Specifically=
:

The call flow to add reqsk to ehash is as follows:

tcp_conn_request()

dccp_v4(6)_conn_request()

 =C2=A0=C2=A0=C2=A0 -> inet_csk_reqsk_queue_hash_add()

 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 -> reqsk_queue_hash_req()

 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 -> inet_ehash_i=
nsert()

tcp_conn_request() needs to call the same interface inet_csk_reqsk_queue_=
hash_add()
as dccp_v4(6)_conn_request(), but the critical section for installation c=
heck and
insertion into ehash is within inet_ehash_insert().
If reqsk_queue_hash_req() should not be modified, then we need to rewrite
the interfaces to distinguish them. I don't see how redefining found_dup_=
sk
alone can resolve this conflict point. I may be lacking a more holistic
perspective on this matter. I sincerely hope to receive further guidance
from you. Thanks! ORZ

>
>> +	if (!inet_ehash_insert(req_to_sk(req), NULL, found_dup_sk))
>> +		return false;
>> +
>> +	/* The timer needs to be setup after a successful insertion. */
>>   	timer_setup(&req->rsk_timer, reqsk_timer_handler, TIMER_PINNED);
>>   	mod_timer(&req->rsk_timer, jiffies + timeout);
>>  =20
>> -	inet_ehash_insert(req_to_sk(req), NULL, NULL);
>>   	/* before letting lookups find us, make sure all req fields
>>   	 * are committed to memory and refcnt initialized.
>>   	 */
>>   	smp_wmb();
>>   	refcount_set(&req->rsk_refcnt, 2 + 1);
>> +	return true;
>>   }
>>  =20
>> -void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_so=
ck *req,
>> -				   unsigned long timeout)
>> +bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_so=
ck *req,
>> +				   unsigned long timeout, bool *found_dup_sk)
>>   {
>> -	reqsk_queue_hash_req(req, timeout);
>> +	if (!reqsk_queue_hash_req(req, timeout, found_dup_sk))
>> +		return false;
>> +
>>   	inet_csk_reqsk_queue_added(sk);
>> +	return true;
>>   }
>>   EXPORT_SYMBOL_GPL(inet_csk_reqsk_queue_hash_add);
>>  =20
>> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
>> index 9c04a9c8be9d..e006c374f781 100644
>> --- a/net/ipv4/tcp_input.c
>> +++ b/net/ipv4/tcp_input.c
>> @@ -7255,8 +7255,15 @@ int tcp_conn_request(struct request_sock_ops *r=
sk_ops,
>>   	} else {
>>   		tcp_rsk(req)->tfo_listener =3D false;
>>   		if (!want_cookie) {
>> +			bool found_dup_sk =3D false;
>> +
>>   			req->timeout =3D tcp_timeout_init((struct sock *)req);
>> -			inet_csk_reqsk_queue_hash_add(sk, req, req->timeout);
>> +			if (unlikely(!inet_csk_reqsk_queue_hash_add(sk, req, req->timeout,
>> +								    &found_dup_sk))) {
>> +				reqsk_free(req);
>> +				return 0;
>> +			}
>> +
>>   		}
>>   		af_ops->send_synack(sk, dst, &fl, req, &foc,
>>   				    !want_cookie ? TCP_SYNACK_NORMAL :
>> --=20
>> 2.25.1
