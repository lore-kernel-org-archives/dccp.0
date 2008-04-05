From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Sat, 05 Apr 2008 10:09:43 +0000
Subject: Re: DCCP conntrack/NAT
Message-Id: <47F74FE7.2040809@netfilter.org>
List-Id: <dccp.vger.kernel.org>
References: <47F64C0D.5080700@trash.net>
In-Reply-To: <47F64C0D.5080700@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Jan Engelhardt wrote:
> 
> On Friday 2008-04-04 17:41, Patrick McHardy wrote:
>> These two patches contain my old conntrack/NAT helper for DCCP,
>> updated to net-2.6.26.git and the missing parts (almost entirely)
>> added.
>>
>> They both depend on some other netfilter patches, I've attached
>> them only hoping for some review :) A git tree which contains
>> the full set of patches is (once upload finishes) located at:
>>
>> git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.26.git
> 
> Speaking of git... I noticed people.netfilter.org has a git-daemon,
> so that would be fine for iptables, no?
> 
>> A few words on the patches:
> 
> (Where's the SCTP patch for review? :)
> 
> 
>> +static int dccp_pkt_to_tuple(const struct sk_buff *skb, unsigned int
>> dataoff,
>> +                 struct nf_conntrack_tuple *tuple)
>> +{
>> +    struct dccp_hdr _hdr, *dh;
>> +
>> +    dh = skb_header_pointer(skb, dataoff, sizeof(_hdr), &_hdr);
>> +    if (dh = NULL)
>> +        return 0;
>> +
>> +    tuple->src.u.dccp.port = dh->dccph_sport;
>> +    tuple->dst.u.dccp.port = dh->dccph_dport;
>> +    return 1;
>> +}
> 
> Something related I have been wondering about ...
> (actually nf_conntrack_l3proto_ipv4)

Well, this is not really related with this patch, I think that it would
be a different thread since it has nothing to do with the DCCP friends.
Anyway...

> skb_header_pointer() is used for the case of a non-linear skb (has to
> do with IP fragments?).

Indeed.

> In ipv4_pkt_to_tuple in nf_conntrack_l3proto_ipv4.c,
> skb_header_pointer() is used to get the [source address of the] IP
> header. Since I figured the layer-3 header must always be
> unfragmented, would not it be simpler to use ip_hdr(), or is there
> something that mandates use of skb_header_pointer?

Right. I think that we can assume that the IP header is always linear (I
remember this from a conversation with Davem or Rusty), Patrick?

-- 
"Los honestos son inadaptados sociales" -- Les Luthiers
