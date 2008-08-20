From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 20 Aug 2008 14:01:16 +0000
Subject: Re: [PATCH] dccp: Reponsed with Reset when packet is received with
Message-Id: <20080820140116.GL8075@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <48AB7147.2010003@cn.fujitsu.com>
In-Reply-To: <48AB7147.2010003@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Aug 20, 2008 at 09:20:07AM +0800, Wei Yongjun escreveu:
> RFC4340 said that if a packet is received with invalid option(such as Mandatory
> Option as the last byte of the option list), endpoint should reponsed with
> Reset. In LISTIN state and RESPOND state, the endpoint reponsed with reset
> correctly, but in REQUEST state and OPEN state, the endpoint just ignored
> the packet. The packet sequence is as the following:
>
> Case 1:
>
>  Endpoint A                           Endpoint B
>  (CLOSED)                             (CLOSED)
>
>               <----------------       REQUEST
>
>  RESPONSE     ----------------->      (*1)
>  (with invalid option)
>               <----------------       RESET
>                                       (with Reset Code 5, "Option Error")
>
>  (*1) it just be ignored currently, no reset is sent
>
> Case 2:
>
>  Endpoint A                           Endpoint B
>  (OPEN)                               (OPEN)
>
>  DATA-ACK     ----------------->      (*2)
>  (with invalid option)
>               <----------------       RESET
>                                       (with Reset Code 5, "Option Error")
>
>  (*2) it just be ignored currently, no reset is sent
>
> This patch fixed the problem by reponsed with Reset instead of ignore packet.
>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

God catch! Please also keep netdev@vger.kernel.org on the CC list.

Acked-by: Arnaldo Carvalho de Melo <acme@redhat.com>

> ---
> net/dccp/input.c |    4 ++--
> 1 files changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/dccp/input.c b/net/dccp/input.c
> index dab4cc9..df0e671 100644
> --- a/net/dccp/input.c
> +++ b/net/dccp/input.c
> @@ -370,7 +370,7 @@ int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
> 		goto discard;
>
> 	if (dccp_parse_options(sk, NULL, skb))
> -		goto discard;
> +		return 1;
>
> 	dccp_handle_ackvec_processing(sk, skb);
> 	dccp_deliver_input_to_ccids(sk, skb);
> @@ -631,7 +631,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
>
> 	/*  Step 8: Process options */
> 	if (dccp_parse_options(sk, NULL, skb))
> -		goto discard;
> +		return 1;
>
> 	/*
> 	 *  Step 9: Process Reset
> -- 
> 1.5.3.8
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe dccp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
