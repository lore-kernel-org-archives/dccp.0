From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 19 Nov 2013 11:04:26 +0000
Subject: Re: [PATCH 2/2] ipv6: use sk_v6_copy_addrs when memcpy struct ipv6_pinfo
Message-Id: <528B45BA.8030808@redhat.com>
List-Id: <dccp.vger.kernel.org>
References: <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
In-Reply-To: <1384829247-8624-3-git-send-email-wangweidong1@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On 11/19/2013 04:32 AM, wangweidong wrote:
> On 2013/11/19 11:14, Hannes Frederic Sowa wrote:
>> On Tue, Nov 19, 2013 at 10:47:27AM +0800, Wang Weidong wrote:
>>> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
>>> index 0740f93..83d011e 100644
>>> --- a/net/ipv6/tcp_ipv6.c
>>> +++ b/net/ipv6/tcp_ipv6.c
>>> @@ -1116,6 +1116,10 @@ static struct sock * tcp_v6_syn_recv_sock(struct sock *sk, struct sk_buff *skb,
>>>   		newtp = tcp_sk(newsk);
>>>
>>>   		memcpy(newnp, np, sizeof(struct ipv6_pinfo));
>>> +		/* Don't forget copy the rcv_saddr and daddr when
>>> +		 * copy ipv6_pinfo.
>>> +		 */
>>> +		sk_v6_copy_addrs(newsk, sk);
>>>
>>>   		ipv6_addr_set_v4mapped(newinet->inet_daddr, &newsk->sk_v6_daddr);
>>>
>>
>> Hmm, how did you spot this?
>>
>> Greetings,
>>
>>    Hannes
>>
>
> When I did the lksctp-tools(1.0.15)/src/func_tests/test_getname_v6, I got a Segmentation fault.
> So I try to resolve it. I found the sctp_accept will call sctp_v6_create_accept_sk in IPV6,
> the function will memcpy the ipv6_pinfo, and not copy the sk_v6_rcv_saddr. But the getsockname
> will read the sk_v6_rcv_saddr, and the value is not true.

In SCTP code, "newsk->sk_v6_daddr = oldsk->sk_v6_daddr;" is redundant as it's already
done by "sctp_v6_to_sk_daddr(&asoc->peer.primary_addr, newsk);" for the primary path,
after we're doing the full copy of struct ipv6_pinfo to the new socket in
sctp_v6_create_accept_sk(). I've sent out an updated patch for SCTP.
