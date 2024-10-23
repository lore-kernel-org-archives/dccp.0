Received: from smtp-fw-80008.amazon.com (smtp-fw-80008.amazon.com [99.78.197.219])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B7A73149E09;
	Wed, 23 Oct 2024 17:51:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=99.78.197.219
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1729705891; cv=none; b=XmobO2WCquvkpBM6ixXNj8DR+NrzTlViVv/fZRvYnZMOXg+0JfPEPPb3pQFPCiFUI0XuDgTOx/aIG69RvOHH+Bio4W69wQ+OEk9I58I8aUWTq2OoSRQEPqY+Klam4H687UG+zSan9NvCMFL0eZQyn32qV0dtTv27WKFVrr7ux0E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1729705891; c=relaxed/simple;
	bh=7UGEJDh8cB6Z0kHWv9AT3jEDcmm6WhV9zKiWq2oLLms=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=fxeCiyAUtbmKYZsajRAqJ/N1LDS7s2N5cOr+7BiA3FpVpdYjeEzaAzTLLobrH7swebJHpTcHrkxUd/+CuQ/7AvHKy7qdw1Y6mim+lyTd703YvwfFwThAfEh6xjFWrsK4CqRuSWAjZpnVLak21RPnD4M4ppm3fpLwJfE0c9/I28I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com; spf=pass smtp.mailfrom=amazon.co.jp; dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b=T67XovHq; arc=none smtp.client-ip=99.78.197.219
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=amazon.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=amazon.co.jp
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=amazon.com header.i=@amazon.com header.b="T67XovHq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
  d=amazon.com; i=@amazon.com; q=dns/txt; s=amazon201209;
  t=1729705889; x=1761241889;
  h=from:to:cc:subject:date:message-id:in-reply-to:
   references:mime-version:content-transfer-encoding;
  bh=cZIM83itd3mNB+9MFVWYQd89vYFQby5ErieMDVM9OCI=;
  b=T67XovHqqe7jb5fg+8K/c/31FZ3m2zbn/OgY04GBLn9lnEQYDIuYqpbD
   at4IENjKuRx4oMBFictN2MhneL70HSvDqgyxAmGMiZjPVPLvoa9tN+vQ5
   JyzzyURt22vqxCbxewC2uscZB9MBVUnUSEdzQkZ3co9JB+TSduVr3RAjf
   E=;
X-IronPort-AV: E=Sophos;i="6.11,226,1725321600"; 
   d="scan'208";a="140029519"
Received: from pdx4-co-svc-p1-lb2-vlan3.amazon.com (HELO smtpout.prod.us-west-2.prod.farcaster.email.amazon.dev) ([10.25.36.214])
  by smtp-border-fw-80008.pdx80.corp.amazon.com with ESMTP/TLS/ECDHE-RSA-AES256-GCM-SHA384; 23 Oct 2024 17:51:27 +0000
Received: from EX19MTAUWB001.ant.amazon.com [10.0.7.35:11118]
 by smtpin.naws.us-west-2.prod.farcaster.email.amazon.dev [10.0.14.226:2525] with esmtp (Farcaster)
 id 1a09fe51-e317-4f2c-ac7c-1337e41f87cb; Wed, 23 Oct 2024 17:51:27 +0000 (UTC)
X-Farcaster-Flow-ID: 1a09fe51-e317-4f2c-ac7c-1337e41f87cb
Received: from EX19D004ANA001.ant.amazon.com (10.37.240.138) by
 EX19MTAUWB001.ant.amazon.com (10.250.64.248) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.34;
 Wed, 23 Oct 2024 17:51:26 +0000
Received: from 6c7e67c6786f.amazon.com (10.106.100.17) by
 EX19D004ANA001.ant.amazon.com (10.37.240.138) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA) id 15.2.1258.35;
 Wed, 23 Oct 2024 17:51:24 +0000
From: Kuniyuki Iwashima <kuniyu@amazon.com>
To: <dmantipov@yandex.ru>
CC: <dccp@vger.kernel.org>, <kuniyu@amazon.com>, <netdev@vger.kernel.org>,
	<syzbot+554ccde221001ab5479a@syzkaller.appspotmail.com>
Subject: Re: KASAN: use-after-free Read in ccid2_hc_tx_packet_recv
Date: Wed, 23 Oct 2024 10:51:21 -0700
Message-ID: <20241023175121.36351-1-kuniyu@amazon.com>
X-Mailer: git-send-email 2.39.5 (Apple Git-154)
In-Reply-To: <938106e0-269a-4d5a-995f-2314fecedb3a@yandex.ru>
References: <938106e0-269a-4d5a-995f-2314fecedb3a@yandex.ru>
Precedence: bulk
X-Mailing-List: dccp@vger.kernel.org
List-Id: <dccp.vger.kernel.org>
List-Subscribe: <mailto:dccp+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:dccp+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: EX19D040UWB001.ant.amazon.com (10.13.138.82) To
 EX19D004ANA001.ant.amazon.com (10.37.240.138)

From: Dmitry Antipov <dmantipov@yandex.ru>
Date: Wed, 23 Oct 2024 15:09:59 +0300
> Looking through https://syzkaller.appspot.com/bug?extid=554ccde221001ab5479a,
> I've found the problem which may be illustrated with the following patch:
> 
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 5926159a6f20..eb551872170c 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -678,6 +678,7 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
> 
>          if (sk->sk_state == DCCP_OPEN) { /* Fast path */
>                  if (dccp_rcv_established(sk, skb, dh, skb->len))
> +                       /* Go to reset here */
>                          goto reset;
>                  return 0;
>          }
> @@ -712,6 +713,7 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
> 
>   reset:
>          dccp_v4_ctl_send_reset(sk, skb, SK_RST_REASON_NOT_SPECIFIED);
> +       /* Freeing skb may leave dangling pointers in ack vectors */
>          kfree_skb(skb);
>          return 0;
>   }
> 
> I'm not an expert with DCCP protocol innards and have no idea whether ack
> vectors still needs to be processed after sending reset. But if it is so,
> the solution might be to copy all of the data from the relevant skbs instead
> of just saving the pointers, e.g.:
> 
> diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
> index 1cba001bb4c8..24c6ad06d896 100644
> --- a/net/dccp/ackvec.c
> +++ b/net/dccp/ackvec.c
> @@ -347,17 +347,18 @@ void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
>   }
> 
>   /*
> - *	Routines to keep track of Ack Vectors received in an skb
> + *	Routines to keep track of Ack Vectors copied from the received skb
>    */
>   int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce)
>   {
> -	struct dccp_ackvec_parsed *new = kmalloc(sizeof(*new), GFP_ATOMIC);
> -
> +	struct dccp_ackvec_parsed *new = kmalloc(struct_size(new, vec, len),
> +						 GFP_ATOMIC);
>   	if (new == NULL)
>   		return -ENOBUFS;
> -	new->vec   = vec;
> -	new->len   = len;
> +
> +	new->len = len;
>   	new->nonce = nonce;
> +	memcpy(new->vec, vec, len);
> 
>   	list_add_tail(&new->node, head);
>   	return 0;
> diff --git a/net/dccp/ackvec.h b/net/dccp/ackvec.h
> index d2c4220fb377..491fd587de90 100644
> --- a/net/dccp/ackvec.h
> +++ b/net/dccp/ackvec.h
> @@ -117,18 +117,18 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
> 
>   /**
>    * struct dccp_ackvec_parsed  -  Record offsets of Ack Vectors in skb
> - * @vec:	start of vector (offset into skb)
> + * @vec:	contents of ack vector (copied from skb)
>    * @len:	length of @vec
>    * @nonce:	whether @vec had an ECN nonce of 0 or 1
>    * @node:	FIFO - arranged in descending order of ack_ackno
>    *
> - * This structure is used by CCIDs to access Ack Vectors in a received skb.
> + * This structure is used by CCIDs to access Ack Vectors from the received skb.
>    */
>   struct dccp_ackvec_parsed {
> -	u8		 *vec,
> -			 len,
> -			 nonce:1;
>   	struct list_head node;
> +	u8 len;
> +	u8 nonce:1;
> +	u8 vec[] __counted_by(len);
>   };
> 
>   int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce);
> diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
> index d6b30700af67..a1f2da3c4fa9 100644
> --- a/net/dccp/ccids/ccid2.c
> +++ b/net/dccp/ccids/ccid2.c
> @@ -589,14 +589,15 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
>   	/* go through all ack vectors */
>   	list_for_each_entry(avp, &hc->tx_av_chunks, node) {
>   		/* go through this ack vector */
> -		for (; avp->len--; avp->vec++) {
> +		u8 *v;
> +		for (v = avp->vec; v < avp->vec + avp->len--; v++) {
>   			u64 ackno_end_rl = SUB48(ackno,
> -						 dccp_ackvec_runlen(avp->vec));
> +						 dccp_ackvec_runlen(v));
> 
>   			ccid2_pr_debug("ackvec %llu |%u,%u|\n",
>   				       (unsigned long long)ackno,
> -				       dccp_ackvec_state(avp->vec) >> 6,
> -				       dccp_ackvec_runlen(avp->vec));
> +				       dccp_ackvec_state(v) >> 6,
> +				       dccp_ackvec_runlen(v));
>   			/* if the seqno we are analyzing is larger than the
>   			 * current ackno, then move towards the tail of our
>   			 * seqnos.
> @@ -615,7 +616,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
>   			 * run length
>   			 */
>   			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
> -				const u8 state = dccp_ackvec_state(avp->vec);
> +				const u8 state = dccp_ackvec_state(v);
> 
>   				/* new packet received or marked */
>   				if (state != DCCPAV_NOT_RECEIVED &&
> 
> Comments are highly appreciated.

I wouldn't touch DCCP anymore unless the change is required for TCP.
(see b144fcaf46d43)
