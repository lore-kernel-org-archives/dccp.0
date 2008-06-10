From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 10 Jun 2008 10:08:32 +0000
Subject: Re: [PATCH] DCCP: Initialize ireq6->pktopts before used it
Message-Id: <484E52A0.2000605@cn.fujitsu.com>
List-Id: <dccp.vger.kernel.org>
References: <484E42BE.9020408@cn.fujitsu.com>
In-Reply-To: <484E42BE.9020408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Gerrit Renker wrote:
>> I think I should add dccp_v6_reqsk_init() do to the init work since  
>> dccp_reqsk_init may be fail too.
>>
>>     
> I think this is not necessary, it can be done like this
>
>
> 	req = inet6_reqsk_alloc(&dccp6_request_sock_ops);
> 	if (req = NULL)
> 		goto drop;
>
> 	ireq6 = inet6_rsk(req);
> 	ireq6->pktopts = NULL;
>
> 	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
> 		goto drop_and_free;
>
> This is since dccp_reqsk_init() only initialises the inet_sk and dccp_sk
> parts, and does not do IPv6-specific initialisation.
>
> Irrespective of the oops, this is an error and will be fixed in the test
> tree today. 
>
> With regard to the oops, the log pointed to the dccp_v6_reqsk_destructor
> and so it would make sense, since the pktopts was not initialised to NULL 
> and since kfree_skb() calls skb->destructor().
>
> As before, thanks a lot for testing this code and for reporting this.
>
>   
Hi Gerrit:
  IPv4 may have the same problem althought it is hard to test it.

[PATCH] DCCP: Initialize inet_rsk(req)->opt before used it
dccp_reqsk_init() does not initialises the inet_rsk(req)->opt which will 
be used in dccp_v4_reqsk_destructor().

This patch fixed this problem.

--- a/net/dccp/minisocks.c	2008-05-29 22:27:56.000000000 -0400
+++ b/net/dccp/minisocks.c	2008-06-05 06:36:59.000000000 -0400
@@ -266,6 +266,7 @@ int dccp_reqsk_init(struct request_sock 
 
 	inet_rsk(req)->rmt_port	  = dccp_hdr(skb)->dccph_sport;
 	inet_rsk(req)->acked	  = 0;
+	inet_rsk(req)->opt	  = NULL;
 	dreq->dreq_timestamp_echo = 0;
 
 	/* inherit feature negotiation options from listening socket */
--- a/net/dccp/ipv4.c	2008-05-29 22:27:56.000000000 -0400
+++ b/net/dccp/ipv4.c	2008-06-05 06:41:48.000000000 -0400
@@ -607,7 +607,6 @@ int dccp_v4_conn_request(struct sock *sk
 	ireq = inet_rsk(req);
 	ireq->loc_addr = ip_hdr(skb)->daddr;
 	ireq->rmt_addr = ip_hdr(skb)->saddr;
-	ireq->opt	= NULL;
 
 	/*
 	 * Step 3: Process LISTEN state


