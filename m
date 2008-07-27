From: David Miller <davem@davemloft.net>
Date: Sun, 27 Jul 2008 12:03:07 +0000
Subject: Re: [pull-request] [net-2.6 PATCH 0/6] dccp: Revised ICMP / length
Message-Id: <20080727.050307.213455767.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <20080726112232.GA5582@gerrit.erg.abdn.ac.uk>
In-Reply-To: <20080726112232.GA5582@gerrit.erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 26 Jul 2008 12:22:33 +0100

> Patch #1: Implements support to distinguish original from retransmitted packets.
> Patch #2: Fixes a bug - AWL was never updated. Used by the third patch.
> Patch #3: Corrects ICMPv4 sequence number check to use AWL/H instead of SWL/H.
> Patch #4: Implements the check from patch #3 for ICMPv6.
> Patch #5: Fixes minimum-required length check for ICMPv4 embedded DCCP datagrams
> Patch #6: Same as patch #5, but for ICMPv6.
> 
> 
> These patches apply to net-2.6 (BUG_TRAP conversion) and can be pulled from
> 
>       git://eden-feed.erg.abdn.ac.uk/net-2.6		(subtree `master')

Pulled, thanks Gerrit.

> If necessary, I can prepare an upload for net-next-2.6 later.

net-next-2.6 can be ignored for at least another week or so.
