From: Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
Date: Mon, 07 Apr 2008 09:48:40 +0000
Subject: Re: [DCCP]: Add priority queuing policy
Message-Id: <47F9EDF8.3020001@grobelny.oswiecenia.net>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker pisze:
> Please revise this patch with regard to CodingStyle -- checkpatch gave
> 38 errors here.
> 
> | --- a/net/dccp/dccp.h
> | +++ b/net/dccp/dccp.h
> | @@ -330,10 +330,16 @@ struct dccp_skb_cb {
> |  	__u16 dccpd_opt_len;
> |  	__u64 dccpd_seq;
> |  	__u64 dccpd_ack_seq;
> | +	char  dccpd_policy[16];
> |  };
> |  
> |  #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
> |  
> | +struct dccp_policy_prio {
> | +	s8	priority;
> | +};
> | +#define SKB_PRIO(__skbcb) ((struct dccp_policy_prio *)&((__skbcb)->dccpd_policy[0]))
> | +
> There is an indirection here which is problematic:
>  * it pre-allocates 16 bytes but currently only uses one byte
>  * with regard to the recent patch for IPv4/v6 parameters, the skb_cb
>    space gets smaller, and there is no test such as BUILD_BUG_ON
>  * the element should be the struct (can remain anonymous), so there would not be
>    the double-indirection in the SKB_PRIO typecast (which is also too long)
> 
But the whole point is that this struct can be different for different 
queuing policies. Statically allocating fixed amount of bytes is one way 
(as for me it doesn't have to be 16), using a void pointer is second one 
and I don't see the third way if qpolicy should be able to define its 
own additional per-packet information. But I'm open to ideas...
-- 
Regards,
Tomasz Grobelny
