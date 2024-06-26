Received: from mailgw.kylinos.cn (mailgw.kylinos.cn [124.126.103.232])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C34E315A856;
	Wed, 26 Jun 2024 07:12:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=124.126.103.232
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1719385957; cv=none; b=mGUAXQGfS0/W7ujA1JpGhkhC24h9savn3sRb+qLQYWQC70kAcWj8hOIkilR5+e9QDKb4Jshefl+IMrYzeu6pt5akxY+1qaLcqRb8wgvOccY8b0t2cqg3N/og5ZC/A4Dcl8pche7bXRUzNeTG30BRRn0zD65U6ldQqJRvHsrsdHc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1719385957; c=relaxed/simple;
	bh=uvQNgV2jDCJ4VhyQQpkSfjrjwPjFCbXoN3isuczthlo=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=D3D3f4dqO0GB3c1gHvFIVqgkYSxI3qe9QR/V9zOnFqEGLN9xIeJuByHDkLQUzmCsmgPmyB/OUlk8NRcAYFHyM97z/mt+ewK2rpm4dV4VTdG12NoLwQmneHN9gfTZEtuJAsZxcixFS/MYZUFL3Rym6tk6oXTkqnv/C/CgGUP4SuQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn; spf=pass smtp.mailfrom=kylinos.cn; arc=none smtp.client-ip=124.126.103.232
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=kylinos.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=kylinos.cn
X-UUID: 6d3e4924338b11ef9305a59a3cc225df-20240626
X-CID-P-RULE: Release_Ham
X-CID-O-INFO: VERSION:1.1.38,REQID:1a41f925-4285-44e4-bd3e-c457bedf79f9,IP:10,
	URL:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:28,RULE:Release_Ham,ACT
	ION:release,TS:23
X-CID-INFO: VERSION:1.1.38,REQID:1a41f925-4285-44e4-bd3e-c457bedf79f9,IP:10,UR
	L:0,TC:0,Content:0,EDM:0,RT:0,SF:-15,FILE:0,BULK:28,RULE:Release_Ham,ACTIO
	N:release,TS:23
X-CID-META: VersionHash:82c5f88,CLOUDID:2b20dc882b6524ccfac790fa7b5a81d3,BulkI
	D:240622064849KEF3CG9W,BulkQuantity:4,Recheck:0,SF:64|66|38|24|17|19|44|10
	2,TC:nil,Content:0,EDM:-3,IP:-2,URL:0,File:nil,RT:nil,Bulk:40|20,QS:nil,BE
	C:nil,COL:0,OSI:0,OSA:0,AV:0,LES:1,SPR:NO,DKR:0,DKP:0,BRR:0,BRE:0
X-CID-BVR: 1,FCT|NGT
X-CID-BAS: 1,FCT|NGT,0,_
X-CID-FACTOR: TF_CID_SPAM_FSD,TF_CID_SPAM_FSI,TF_CID_SPAM_FCD,TF_CID_SPAM_SNR,
	TF_CID_SPAM_FAS
X-UUID: 6d3e4924338b11ef9305a59a3cc225df-20240626
Received: from node2.com.cn [(39.156.73.10)] by mailgw.kylinos.cn
	(envelope-from <luoxuanqiang@kylinos.cn>)
	(Generic MTA)
	with ESMTP id 432502532; Wed, 26 Jun 2024 15:12:19 +0800
Received: from node2.com.cn (localhost [127.0.0.1])
	by node2.com.cn (NSMail) with SMTP id 62A36B8075B2;
	Wed, 26 Jun 2024 15:12:19 +0800 (CST)
X-ns-mid: postfix-667BBF53-321303144
Received: from [10.42.12.252] (unknown [10.42.12.252])
	by node2.com.cn (NSMail) with ESMTPA id 0CB4EB8075B2;
	Wed, 26 Jun 2024 07:12:15 +0000 (UTC)
Message-ID: <dda6580f-636a-69da-60ef-cbdf0353d967@kylinos.cn>
Date: Wed, 26 Jun 2024 15:12:15 +0800
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101
 Thunderbird/102.11.0
Subject: Re: [PATCH net v4] Fix race for duplicate reqsk on identical SYN
Content-Language: en-US
To: Paolo Abeni <pabeni@redhat.com>, kuniyu@amazon.com, edumazet@google.com,
 kuba@kernel.org, davem@davemloft.net
Cc: dccp@vger.kernel.org, dsahern@kernel.org, fw@strlen.de,
 linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
 alexandre.ferrieux@orange.com
References: <20240621013929.1386815-1-luoxuanqiang@kylinos.cn>
 <35f497afd90fe16ba1408f25ea1ff62af6a73a90.camel@redhat.com>
From: luoxuanqiang <luoxuanqiang@kylinos.cn>
In-Reply-To: <35f497afd90fe16ba1408f25ea1ff62af6a73a90.camel@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable


=E5=9C=A8 2024/6/25 17:49, Paolo Abeni =E5=86=99=E9=81=93:
> On Fri, 2024-06-21 at 09:39 +0800, luoxuanqiang wrote:
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
>> Add a return value to inet_csk_reqsk_queue_hash_add() to confirm if th=
e
>> ehash insertion is successful (Up to now, the reason for unsuccessful
>> insertion is that a reqsk for the same connection has already been
>> inserted). If the insertion fails, release the reqsk.
>>
>> Due to the refcnt, Kuniyuki suggests also adding a return value check
>> for the DCCP module; if ehash insertion fails, indicating a successful
>> insertion of the same connection, simply release the reqsk as well.
>>
>> Simultaneously, In the reqsk_queue_hash_req(), the start of the
>> req->rsk_timer is adjusted to be after successful insertion.
>>
>> Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
> Just after applying the patch I wondered if the issue addressed here
> should be observable only after commit e994b2f0fb92 ("tcp: do not lock
> listener to process SYN packets")?
>
> In practice it should not matter as the latter commit it's older than
> the currently older LST, but I'm wondering if I read the things
> correctly?
>
> Thanks!
>
> Paolo
>
Hi, Paolo, I conducted some experiments on your concern by reverting e994=
b2f0fb92 on version 4.19 to observe how TCP handles this race condition.

Here are the observations:
where SYN-A is processed on CPUA and SYN-B is processed on CPUB

CPUA & CPUB

In tcp_v4_rcv(), both SYN-A and SYN-B obtained the same sk from __inet_lo=
okup_listener(), with the sk state being TCP_LISTEN.

 =C2=A0=C2=A0 =C2=A0CPUA

 =C2=A0=C2=A0=C2=A0 SYN-A acquired sk_lock and was processed in tcp_v4_do=
_rcv(), where it created reqsk-A while in TCP_LISTEN state and sent a SYN=
ACK packet.

    =20

 =C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=
=A0 CPUB

 =C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=A0 =C2=A0=C2=A0=C2=
=A0 After SYN-A was processed and sk_lock was released, SYN-B was process=
ed. Since it was the same sk still in TCP_LISTEN state, it created reqsk-=
B and sent a SYNACK packet with a different seq number.

The issue remains reproducible.

BRs!

