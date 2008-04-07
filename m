From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 07 Apr 2008 09:19:37 +0000
Subject: Re: [DCCP]: Add priority queuing policy
Message-Id: <20080407091936.GI6146@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
In-Reply-To: <200804052115.44319.tomasz@grobelny.oswiecenia.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Please revise this patch with regard to CodingStyle -- checkpatch gave
38 errors here.

| --- a/net/dccp/dccp.h
| +++ b/net/dccp/dccp.h
| @@ -330,10 +330,16 @@ struct dccp_skb_cb {
|  	__u16 dccpd_opt_len;
|  	__u64 dccpd_seq;
|  	__u64 dccpd_ack_seq;
| +	char  dccpd_policy[16];
|  };
| =20
|  #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
| =20
| +struct dccp_policy_prio {
| +	s8	priority;
| +};
| +#define SKB_PRIO(__skbcb) ((struct dccp_policy_prio *)&((__skbcb)->dccpd=
_policy[0]))
| +
There is an indirection here which is problematic:
 * it pre-allocates 16 bytes but currently only uses one byte
 * with regard to the recent patch for IPv4/v6 parameters, the skb_cb
   space gets smaller, and there is no test such as BUILD_BUG_ON
 * the element should be the struct (can remain anonymous), so there would =
not be
   the double-indirection in the SKB_PRIO typecast (which is also too long)

| --- /dev/null
| +++ b/net/dccp/qpolicy_prio.c
| @@ -0,0 +1,88 @@
| +/*
| + *  net/dccp/qpolicy_prio.c
| + *
| + *  An implementation of the DCCP protocol
| + *
| + *  Copyright (c) 2008 Tomasz Grobelny <tomasz@grobelny.oswiecenia.net>
| + *
| + *  This program is free software; you can redistribute it and/or
| + *  modify it under the terms of the GNU General Public License v2
| + *  as published by the Free Software Foundation.
| + */
| +
| +#include "qpolicy.h"
| +#define POLICY_ID 1
| +
=3D> General comment: the functions in this file can also all be declared
                     `static', since they are not used externally.
| +struct sk_buff *dccp_queue_get_worst(struct sk_buff_head *list)
| +{
| +	int i, worstp =3D -128;
| +	struct sk_buff *curr=3D(struct sk_buff*)list;
| +	struct sk_buff *worst=3DNULL;
| +	struct dccp_skb_cb *dcb;
| +	for(i=3D0;i<list->qlen;i++)
| +	{
For structs, ifs, for/while loops, please place curly bracket on same line,=
 cf. CodingStyle.=09
| +		curr=3Dcurr->next;
| +		dcb =3D DCCP_SKB_CB(curr);
| +		if(SKB_PRIO(dcb)->priority > worstp)
| +		{
| +			worstp=3DSKB_PRIO(dcb)->priority;
| +			worst=3Dcurr;
| +		}
| +	}
| +	return worst;
| +}
| +
| +void prio_push(struct sock *sk, struct sk_buff *skb, void* control, __ke=
rnel_size_t controllen)
| +{
| +	struct dccp_policy_prio *dcp =3D (struct dccp_policy_prio *)control;
| +	struct dccp_skb_cb *dcb =3D DCCP_SKB_CB(skb);
| +	SKB_PRIO(dcb)->priority =3D 127;
| +	if(dcp)
| +		memcpy(SKB_PRIO(dcb), dcp, min(sizeof(struct dccp_policy_prio), contro=
llen));
| +	skb_queue_tail(&sk->sk_write_queue, skb);
| +	if(sk->sk_write_queue.qlen >=3D sysctl_dccp_tx_qlen)
| +	{
| +		struct sk_buff* worst=DCcp_queue_get_worst(&sk->sk_write_queue);
| +		skb_unlink(worst, &sk->sk_write_queue);
| +		kfree_skb(worst);
| +	}
| +}
| +
| +/** no matter what we can push a packet into the queue =3D> queue is nev=
er full */
| +int prio_full(struct sock *sk)
| +{
| +	return 0;
| +}
| +
| +struct sk_buff* prio_top(struct sock *sk)
| +{
| +	int i, bestp=127;
Please leave spaces between '=3D'.
| +	struct sk_buff *curr=3D(struct sk_buff*)(&sk->sk_write_queue);
| +	struct sk_buff *best=3DNULL;
| +	struct dccp_skb_cb *dcb;
| +	for(i=3D0;i<sk->sk_write_queue.qlen;i++)
| +	{
| +		curr=3Dcurr->next;
| +		dcb =3D DCCP_SKB_CB(curr);
| +		if(SKB_PRIO(dcb)->priority < bestp)
| +		{
| +			bestp=3DSKB_PRIO(dcb)->priority;
| +			best=3Dcurr;
| +		}
| +	}
| +	return best;
| +}
| +
| +void prio_pop(struct sock *sk, struct sk_buff *skb)
| +{
| +	skb_unlink(skb, &sk->sk_write_queue);
| +}
| +
| +struct dccp_qpolicy_operations prio_policy_operations | +{
| +	.policy_id =3D POLICY_ID,
| +	.push =3D prio_push,
| +	.full =3D prio_full,
| +	.top =3D prio_top,
| +	.pop =3D prio_pop,
| +};


--=20


The University of Aberdeen is a charity registered in Scotland, No SC013683.

