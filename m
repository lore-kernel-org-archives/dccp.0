From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Wed, 04 Jun 2008 13:21:52 +0000
Subject: Re: [PATCH - test-tree] DCCP: Increment sequence number on
Message-Id: <20080604132152.GA17595@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <4846462F.3020004@cn.fujitsu.com>
In-Reply-To: <4846462F.3020004@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Wed, Jun 04, 2008 at 03:37:19PM +0800, Wei Yongjun escreveu:
> When retransmit the first REQUEST, the sequence number does not be  
> increased. This is because before retransmit the first REQUEST packet,  
> the icsk->icsk_retransmits is 0, so dccp_transmit_skb() will fetch the  
> dp->dccps_iss as the retransmit sequence number.
>
> This patch fix the problem.

Looks like a hack, ugh. Proper fix must be not bumping it on
dccp_transmit_skb when the packet is a REQUEST, no?

- Arnaldo

> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
>
> --- a/net/dccp/output.c	2008-05-29 22:27:55.000000000 -0400
> +++ b/net/dccp/output.c	2008-05-30 19:26:43.000000000 -0400
> @@ -69,9 +69,6 @@ static int dccp_transmit_skb(struct sock
>
> 		case DCCP_PKT_REQUEST:
> 			set_ack = 0;
> -			/* Use ISS on the first (non-retransmitted) Request. */
> -			if (icsk->icsk_retransmits = 0)
> -				dcb->dccpd_seq = dp->dccps_iss;
> 			/* fall through */
>
> 		case DCCP_PKT_SYNC:
> @@ -526,6 +523,8 @@ int dccp_connect(struct sock *sk)
>
> 	/* Initialise GAR as per 8.5; AWL/AWH are set in dccp_transmit_skb() */
> 	dp->dccps_gar = dp->dccps_iss;
> +	/* Initialise GSS to ISS - 1, will be increased in dccp_transmit_skb() */
> +	dp->dccps_gss = SUB48(dp->dccps_iss, 1);
>
> 	skb = alloc_skb(sk->sk_prot->max_header, sk->sk_allocation);
> 	if (unlikely(skb = NULL))
