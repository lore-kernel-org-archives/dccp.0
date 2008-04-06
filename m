From: Patrick McHardy <kaber@trash.net>
Date: Sun, 06 Apr 2008 00:28:35 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47F81933.4050102@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Pablo Neira Ayuso wrote:
> Jan Engelhardt wrote:
>   
>>> +static int dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int
>>> dataoff,
>>> +                 struct nf_conntrack_tuple *tuple)
>>> +{
>>> +    struct dccp_hdr _hdr, *dh;
>>> +
>>> +    dh = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
>>> +    if (dh = NULL)
>>> +        return 0;
>>> +
>> skb_header_pointer() is used for the case of a non-linear skb (has to
>> do with IP fragments?).
>>     
>
> Indeed.
>
>   
>> In ipv4_pkt_to_tuple in nf_conntrack_l3proto_ipv4.c,
>> skb_header_pointer() is used to get the [source address of the] IP
>> header. Since I figured the layer-3 header must always be
>> unfragmented, would not it be simpler to use ip_hdr(), or is there
>> something that mandates use of skb_header_pointer?
>>     
>
> Right. I think that we can assume that the IP header is always linear (I
> remember this from a conversation with Davem or Rusty), Patrick?
>   

Right, the IP header is linearized by ip_rcv() (or bridge netfilter).
The pkt_to_tuple functions may be called for the inner packet of an
ICMP message however, which might be in the non-linear area.


