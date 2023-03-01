From: Madhu Koriginja <madhu.koriginja@nxp.com>
Date: Wed, 01 Mar 2023 15:19:01 +0000
Subject: RE: [EXT] Re: [PATCH] [NETFILTER]: Keep conntrack reference until IPsecv6 policy checks are done
Message-Id: <DB9PR04MB9648F84755C9894D720F996FFCAD9@DB9PR04MB9648.eurprd04.prod.outlook.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Hi Florian,
Got it, it's typo mistake. I will update the patch.
Thanks for quick review.
Regards,
Madhu K

-----Original Message-----
From: Florian Westphal <fw@strlen.de> 
Sent: Wednesday, March 1, 2023 8:38 PM
To: Madhu Koriginja <madhu.koriginja@nxp.com>
Cc: gerrit@erg.abdn.ac.uk; davem@davemloft.net; kuznet@ms2.inr.ac.ru; yoshfuji@linux-ipv6.org; edumazet@google.com; dccp@vger.kernel.org; netdev@vger.kernel.org; linux-kernel@vger.kernel.org; Vani Namala <vani.namala@nxp.com>
Subject: [EXT] Re: [PATCH] [NETFILTER]: Keep conntrack reference until IPsecv6 policy checks are done

Caution: EXT Email

Madhu Koriginja <madhu.koriginja@nxp.com> wrote:
> Keep the conntrack reference until policy checks have been performed 
> for IPsec V6 NAT support. The reference needs to be dropped before a 
> packet is queued to avoid having the conntrack module unloadable.

In the old days there was no ipv6 nat so its not surpising that ipv6 discards the conntrack entry earlier than ipv4.

> -             if (!(ipprot->flags & INET6_PROTO_NOPOLICY) &&
> -                 !xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
> -                     goto discard;
> +
> +             if (!ipprot->flags & INET6_PROTO_NOPOLICY) {

This looks wrong, why did you drop the () ?

if (!(ipprot->flags & INET6_PROTO_NOPOLICY)) { ...

rest LGTM.
