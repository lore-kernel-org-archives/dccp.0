From: Florian Westphal <fw@strlen.de>
Date: Wed, 01 Mar 2023 15:07:47 +0000
Subject: Re: [PATCH] [NETFILTER]: Keep conntrack reference until IPsecv6 policy checks are done
Message-Id: <20230301150747.GB4691@breakpoint.cc>
List-Id: <dccp.vger.kernel.org>
References: <20230301145534.421569-1-madhu.koriginja@nxp.com>
In-Reply-To: <20230301145534.421569-1-madhu.koriginja@nxp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Madhu Koriginja <madhu.koriginja@nxp.com> wrote:
> Keep the conntrack reference until policy checks have been performed for
> IPsec V6 NAT support. The reference needs to be dropped before a packet is
> queued to avoid having the conntrack module unloadable.

In the old days there was no ipv6 nat so its not surpising
that ipv6 discards the conntrack entry earlier than ipv4.

> -		if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
> -		    !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
> -			goto discard;
> +
> +		if (!ipprot->flags & INET6_PROTO_NOPOLICY) {

This looks wrong, why did you drop the () ?

if (!(ipprot->flags & INET6_PROTO_NOPOLICY)) { ...

rest LGTM.
