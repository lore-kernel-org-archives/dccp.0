From: Florian Westphal <fw@strlen.de>
Date: Thu, 02 Mar 2023 11:35:23 +0000
Subject: Re: [PATCH] [net:netfilter]: Keep conntrack reference until IPsecv6 policy checks are done
Message-Id: <20230302113523.GD23204@breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Madhu Koriginja <madhu.koriginja@nxp.com> wrote:
> Keep the conntrack reference until policy checks have been performed for
> IPsec V6 NAT support. The reference needs to be dropped before a packet is
> queued to avoid having the conntrack module unloadable.

Subject Line should be:

[PATCH net] net: netfilter: Keep conntrack reference until IPsecv6 policy checks are done
or
[PATCH net-next] net: netfilter: Keep ..

see below why net-next makes more sense to me.

> Signed-off-by: Madhu Koriginja <madhu.koriginja@nxp.com>
> 	V1-V2: added missing () in ip6_input.c in below condition
> 	if (!(ipprot->flags & INET6_PROTO_NOPOLICY))

This should appear before your signed-off-by, or 
> ---
>  net/dccp/ipv6.c      |  1 +

... here.

I think its fine to place it here because in this case
the mini-changelog doesn't provide any additional context
worth keeping in git.

Paolo, Jakub, David: This is a bug, but its not a regression
either.  I would suggest that Madhu resubmits this AFTER
net-next re-opens.

Madhu, if thats the agreed-upon procedure, you may include

Reviewed-by: Florian Westphal <fw@strlen.de>

when you resend this patch as-is.
