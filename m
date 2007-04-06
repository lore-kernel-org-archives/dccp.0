From: Brian Haley <brian.haley@hp.com>
Date: Fri, 06 Apr 2007 06:37:52 +0000
Subject: Re: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Message-Id: <4615EAC0.3080709@hp.com>
List-Id: <dccp.vger.kernel.org>
References: <4615BCA1.6000608@hp.com>
In-Reply-To: <4615BCA1.6000608@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org



YOSHIFUJI Hideaki / ???? wrote:
> In article <4615BCA1.6000608@hp.com> (at Thu, 05 Apr 2007 23:21:05 -0400), Brian Haley <brian.haley@hp.com> says:
> 
>> Add link and site-local scope inline to avoid calls to ipv6_addr_type().
>>
> 
> I disagree.  Multicast scopes should also be handled appropriately.

Yes, I totally missed that 
ipv6_addr_scope2type(IPV6_ADDR_MC_SCOPE(addr)) in __ipv6_addr_type(), so 
the linklocal inline probably isn't worth it since it would have to be 
something like:

static inline int ipv6_addr_scope_linklocal(const struct in6_addr *a)
{
return ((a->s6_addr32[0] & htonl(0xFFC00000)) = htonl(0xFE800000) ||
         ((a->s6_addr32[0] & htonl(0xFF000000)) = htonl(0xFF000000) &&
          ((a)->s6_addr[1] & 0x0f) = IPV6_ADDR_SCOPE_LINKLOCAL)))
}

That's not that clean an inline anymore, but still doable...

I'll clean-up the rest based on your comments and re-send.

-Brian
