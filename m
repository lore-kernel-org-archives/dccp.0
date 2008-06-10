From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 10 Jun 2008 09:59:33 +0000
Subject: Re: [PATCH] DCCP: Initialize ireq6->pktopts before used it
Message-Id: <484E5085.1020106@cn.fujitsu.com>
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
Yes, You are right. The patch is valid after changed as you said.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

--- a/net/dccp/ipv6.c	2008-05-29 22:27:55.000000000 -0400
+++ b/net/dccp/ipv6.c	2008-06-05 07:02:08.000000000 -0400
@@ -410,6 +410,9 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
+	ireq6 = inet6_rsk(req);
+	ireq6->pktopts	= NULL;
+
 	if (dccp_reqsk_init(req, dccp_sk(sk), skb))
 		goto drop_and_free;
 
@@ -420,10 +423,8 @@ static int dccp_v6_conn_request(struct s
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
-	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||



