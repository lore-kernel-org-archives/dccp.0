From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
Date: Fri, 06 Apr 2007 03:24:33 +0000
Subject: Re: [PATCH 1/4] [IPv6] Add link and site-local scope inline
Message-Id: <20070406.122433.60252840.yoshfuji@linux-ipv6.org>
List-Id: <dccp.vger.kernel.org>
References: <4615BCA1.6000608@hp.com>
In-Reply-To: <4615BCA1.6000608@hp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

In article <4615BCA1.6000608@hp.com> (at Thu, 05 Apr 2007 23:21:05 -0400), Brian Haley <brian.haley@hp.com> says:

> Add link and site-local scope inline to avoid calls to ipv6_addr_type().
> 

I disagree.  Multicast scopes should also be handled appropriately.

--yoshfuji
