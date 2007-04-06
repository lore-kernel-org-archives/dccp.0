From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
Date: Fri, 06 Apr 2007 06:55:50 +0000
Subject: Re: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Message-Id: <20070406.160030.75539924.yoshfuji@linux-ipv6.org>
List-Id: <dccp.vger.kernel.org>
References: <4615BCA1.6000608@hp.com>
In-Reply-To: <4615BCA1.6000608@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In article <4615EAC0.3080709@hp.com> (at Fri, 06 Apr 2007 02:37:52 -0400), Brian Haley <brian.haley@hp.com> says:

> static inline int ipv6_addr_scope_linklocal(const struct in6_addr *a)
> {
> return ((a->s6_addr32[0] & htonl(0xFFC00000)) = htonl(0xFE800000) ||
>          ((a->s6_addr32[0] & htonl(0xFF000000)) = htonl(0xFF000000) &&
>           ((a)->s6_addr[1] & 0x0f) = IPV6_ADDR_SCOPE_LINKLOCAL)))
> }
> 
> That's not that clean an inline anymore, but still doable...

I would prefer to have ipv6_addr_linklocal() and
ipv6_addr_mc_linklocal() aligning with RFC3493.

--yoshfuji
