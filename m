From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Fri, 25 Jul 2008 01:40:59 +0000
Subject: Re: [PATCH 0/4] Fix check for incorrect or missing sequence	mumbers
Message-Id: <48892F2B.2020202@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <488840B1.5070303@cn.fujitsu.com>
In-Reply-To: <488840B1.5070303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> | This patch fix the incorrect or missing sequence mumbers in ICMP
> | message, add the check for incorrect or missing sequence mumbers in
> | ICMPv6 message.
> | 
> | [PATCH 1/4] DCCP: Fix to check the sequence number in ICMP message correctly
> | [PATCH 2/4] DCCP: Add check for sequence number in ICMPv6 message
> | [PATCH 3/4] DCCP: Fix to check missing sequence number for ICMP message correctly
> | [PATCH 4/4] DCCP: Add check for missing sequence number in ICMPv6 message
> | 
> | 
> Thank you. I will work through these and review. Two comments so far
>  * they apply not cleanly (to 2.6.26) -- please check your kernel sources;
>  * in patches 3/4 the "if (skb->len < ihlen + 12" can be omitted, since
>    __dccp_basic_hdr_len() always returns minimally sizeof(struct dccp_hdr) = 12
>    (the header size of 8 seems to stem from an earlier draft version of DCCP)
Agree, I will fix the patch. I think she header size of 8 may be caome 
from the tcp code^_^?

