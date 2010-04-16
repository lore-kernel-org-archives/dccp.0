From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 16 Apr 2010 02:26:09 +0000
Subject: Re: [net-next-2.6 PATCH 2/2] net: replace ipfragok with	skb->local_df
Message-Id: <4BC7CAC1.4000803@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Herbert Xu wrote, at 04/15/2010 11:19 PM:
> On Thu, Apr 15, 2010 at 09:04:49PM +0800, Shan Wei wrote:
>> As Herbert Xu said: we should be able to simply replace ipfragok
>> with skb->local_df. commit f88037(sctp: Drop ipfargok in sctp_xmit function)
>> has droped ipfragok and set local_df value properly.
>>
>> The patch kills the ipfragok parameter of .queue_xmit().
> 
> Both patches look good to me.
> 
>> @@ -370,7 +370,7 @@ packet_routed:
>>  	skb_reset_network_header(skb);
>>  	iph = ip_hdr(skb);
>>  	*((__be16 *)iph) = htons((4 << 12) | (5 << 8) | (inet->tos & 0xff));
>> -	if (ip_dont_fragment(sk, &rt->u.dst) && !ipfragok)
>> +	if (ip_dont_fragment(sk, &rt->u.dst) && !skb->local_df)
>>  		iph->frag_off = htons(IP_DF);
>>  	else
>>  		iph->frag_off = 0;
> 
> This hunk looked suspecious at first.  However, it is OK because
> ever calls this with ipfragok = 1, or local_df = 1.
> 
> The first is obvious from this patch itself, the second not quite
> so obvious.
> 
> As nobody calls it with local_df = 1 anyway, and strictly speaking
> local_df shouldn't be set at all by the caller of ip_queue_xmit, we
> should simply remove the && ... bit and have 
> 
> 	if (ip_dont_fragment(sk, &rt->u.dst))

Now, PPPoX/PPPoL2TP driver still use ip_queue_xmit to send packets with ipfragok = 1.
So, now we can't remove the && ... bit. 


-- 
Best Regards
-----
Shan Wei

> 
> Cheers,


