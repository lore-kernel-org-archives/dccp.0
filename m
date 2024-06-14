Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AB2DF19752F;
	Fri, 14 Jun 2024 12:42:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1718368942; cv=none; b=NavCr84QE7SPG5aYyDwtL2+Nn9510u2+FFQPQaFV/xmzGK0YKiUEsIKNLPi65L1nYsNP/mhTKUv3WeNXn1jgO64yv4yVBDZoYwFwqOH6otH1GTtFRAoaf7P4gWl5PZGR1riEoNk9DJgLFJQO37hZkhzW1ittbfrgRtJOU40RjBM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1718368942; c=relaxed/simple;
	bh=xX+0hJOY5wHV2sFTLz2I53WZq9oVZ069f2wFZkuYpXA=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=fPZYHYxFvmOY/nfJU3eHTZ2qbwCUedO2uJ8YKZ2IHhGxH0uoTT528TG/0kznpzymjGdJdhu6xtYmLmRdiFj3lHTUdStIuVG2M8r6z45ah0qhxWe3RzaxU3IQqh1WoXMdmQbTDW4bysp09SZMjP90rycFI503KUMIaVceA9AaHm8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 8485f3962a4b11ef9305a59a3cc225df-20240614
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:4eaac0dc-8ad9-48ef-8e6e-a3f37f87e633,IP:20,
	URL:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTI
	ON:release,TS:5
X-CID-INFO: VERSION:1.1.38,REQID:4eaac0dc-8ad9-48ef-8e6e-a3f37f87e633,IP:20,UR
	L:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:0,RULE:Release_Ham,ACTION
	:release,TS:5
X-CID-META: VersionHash:82c5f88,CLOUDID:36e2953cecde2afbdb3f01b0793d3341,BulkI
	D:240614185458SXRYECY3,BulkQuantity:1,Recheck:0,SF:64|66|24|17|19|44|102,T
	C:nil,Content:0,EDM:-3,IP:-2,URL:0,File:nil,RT:nil,Bulk:40,QS:nil,BEC:nil,
	COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 0,NGT
X-CID-BAS: 0,NGT,0,_
X-CID-FACTOR: TF_CID_SPAM_FSI,TF_CID_SPAM_SNR,TF_CID_SPAM_FAS,TF_CID_SPAM_FSD
X-UUID: 8485f3962a4b11ef9305a59a3cc225df-20240614
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 215960080; Fri, 14 Jun 2024 20:42:10 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 445C8B80758A;
	Fri, 14 Jun 2024 20:42:10 +0800 (CST)
X-ns-mid: postfix-666C3AA2-18629611
Received: from [10.42.12.252] (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id ADCC7B80758A;
	Fri, 14 Jun 2024 12:42:08 +0000 (UTC)
Message-ID: <7075bb26-ede9-0dc7-fe93-e18703e5ddaa@kylinos.cn>
Date: Fri, 14 Jun 2024 20:42:07 +0800
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
To: Florian Westphal <fw@strlen.de>
Cc: edumazet@google.com, davem@davemloft.net, dsahern@kernel.org,
 kuba@kernel.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 pabeni@redhat.com, kuniyu@amazon.com, dccp@vger.kernel.org
References: <20240614102628.446642-1-luoxuanqiang@kylinos.cn>
 <20240614105441.GA24596@breakpoint.cc>
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
In-Reply-To: <20240614105441.GA24596@breakpoint.cc>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable


=E5=9C=A8 2024/6/14 18:54, Florian Westphal =E5=86=99=E9=81=93:
> luoxuanqiang <luoxuanqiang@kylinos.cn> wrote:
>>   include/net/inet_connection_sock.h |  2 +-
>>   net/dccp/ipv4.c                    |  2 +-
>>   net/dccp/ipv6.c                    |  2 +-
>>   net/ipv4/inet_connection_sock.c    | 15 +++++++++++----
>>   net/ipv4/tcp_input.c               | 11 ++++++++++-
>>   5 files changed, 24 insertions(+), 8 deletions(-)
>>
>> diff --git a/include/net/inet_connection_sock.h b/include/net/inet_con=
nection_sock.h
>> index 7d6b1254c92d..8773d161d184 100644
>> --- a/include/net/inet_connection_sock.h
>> +++ b/include/net/inet_connection_sock.h
>> @@ -264,7 +264,7 @@ struct sock *inet_csk_reqsk_queue_add(struct sock =
*sk,
>>   				      struct request_sock *req,
>>   				      struct sock *child);
>>   void inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_s=
ock *req,
>> -				   unsigned long timeout);
>> +				   unsigned long timeout, bool *found_dup_sk);
> Nit:
>
> I think it would be preferrable to change retval to bool rather than
> bool *found_dup_sk extra arg, so one can do
>
> bool inet_csk_reqsk_queue_hash_add(struct sock *sk, struct request_sock=
 *req,
>    				   unsigned long timeout)
> {
> 	if (!reqsk_queue_hash_req(req, timeout))
> 		return false;
>
> i.e. let retval indicate wheter reqsk was inserted or not.
>
> Patch looks good to me otherwise.

Thank you for your confirmation!

Regarding your suggestion, I had considered it before,
but besides tcp_conn_request() calling inet_csk_reqsk_queue_hash_add(),
dccp_v4(v6)_conn_request() also calls it. However, there is no
consideration for a failed insertion within that function, so it's
reasonable to let the caller decide whether to check for duplicate
reqsk.

The purpose of my modification this time is solely to confirm if a
reqsk for the same connection has already been inserted into the ehash.
If the insertion fails, inet_ehash_insert() will handle the
non-insertion gracefully, and I only need to release the duplicate
reqsk. I believe this change is minimal and effective.

Those are my considerations.

