From: Patrick McHardy <kaber@trash.net>
Date: Fri, 04 Apr 2008 13:40:55 +0000
Subject: Re: [DCCP]: Fix skb->cb conflicts with IP
Message-Id: <47F62FE7.9060508@trash.net>
List-Id: <dccp.vger.kernel.org>
References: <47F61B5C.8090105@trash.net>
In-Reply-To: <47F61B5C.8090105@trash.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
> Arnaldo,
> 
> just a thought - I recall that there used to be a bug related to this,
> which required to insert the following before sending an skb:
>      
>      memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt))
> 
> This was about 1+1/2 .. 2 years ago and lead to crashes when the memset
> was removed. Maybe with this solution the memsets are then no longer
> necessary? The reference is
>  * output.c:dccp_transmit_skb()
>  * ipv4.c:dccp_v4_send_response()


Yes, that shouldn't be needed anymore with this patch.

