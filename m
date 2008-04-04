From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Fri, 04 Apr 2008 13:26:44 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <20080404132644.GA5989@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Fri, Apr 04, 2008 at 02:13:16PM +0200, Patrick McHardy escreveu:

> commit eced67957ee99f7b5fafdc73a58bcd037a1789b2
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Apr 4 14:10:23 2008 +0200
> 
>     [DCCP]: Fix skb->cb conflicts with IP
>     
>     dev_queue_xmit() and the other IP output functions expect to get a skb
>     with clear or properly initialized skb->cb. Unlike TCP and UDP, the
>     dccp_skb_cb doesn't contain a struct inet_skb_parm at the beginning,
>     so the DCCP-specific data is interpreted by the IP output functions.
>     This can cause false negatives for the conditional POST_ROUTING hook
>     invocation, making the packet bypass the hook.
>     
>     Add a inet_skb_parm/inet6_skb_parm union to the beginning of
>     dccp_skb_cb to avoid clashes. Also add a BUILD_BUG_ON to make
>     sure it fits in the cb.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Thanks Patrick,

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>
