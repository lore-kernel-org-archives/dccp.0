From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 10:34:57 +0000
Subject: Re: [PATCH] DCCP: Initialize ireq6->pktopts before used it
Message-Id: <20080610103457.GC8582@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <484E42BE.9020408@cn.fujitsu.com>
In-Reply-To: <484E42BE.9020408@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

>  IPv4 may have the same problem althought it is hard to test it.
>
> [PATCH] DCCP: Initialize inet_rsk(req)->opt before used it
> dccp_reqsk_init() does not initialises the inet_rsk(req)->opt which will  
> be used in dccp_v4_reqsk_destructor().
>
> This patch fixed this problem.
>
Yes, correct - and it is the same problem, the dccp_v4_reqsk_destructor()
ends up trying to kfree the `opt' area.

Since this fixes also a problem for the mainline, I would like to add it to
the set of bug-fixes I am about to submit. Please check if you are ok with 
the combined patch as below, I will submit this later on today and the
fix will also be available in the test tree.

Really, thanks heaps for all your helpful work.

------------------------> Patch <---------------------------------------
dccp: Initialise option area of v4/v6 request socket

From: Wei Yongjun <yjwei@cn.fujitsu.com>

This fixes the following bug:
 * dccp_v4_reqsk_destructor() frees inet inet_rsk(req)->opt,
 * but dccp_v4_conn_request() may fail before initialising inet_rsk(req)->opt;
 * likewise, dccp_v6_reqsk_destructor() frees inet6_rsk(req)->pktopts,
 * but dccp_v6_conn_request() may fail before initialising the pktopts.

The fix is in initialising the option areas in both request sockets before
calling any other code that may fail and thus may end up calling the destructor.

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ipv4.c |    5 +++--
 net/dccp/ipv6.c |    5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -593,6 +593,9 @@ int dccp_v4_conn_request(struct sock *sk
 	if (req = NULL)
 		goto drop;
 
+	ireq = inet_rsk(req);
+	ireq->opt = NULL;
+
 	dccp_reqsk_init(req, skb);
 
 	dreq = dccp_rsk(req);
@@ -602,10 +605,8 @@ int dccp_v4_conn_request(struct sock *sk
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	ireq = inet_rsk(req);
 	ireq->loc_addr = ip_hdr(skb)->daddr;
 	ireq->rmt_addr = ip_hdr(skb)->saddr;
-	ireq->opt	= NULL;
 
 	/*
 	 * Step 3: Process LISTEN state
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -409,6 +409,9 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
+	ireq6 = inet6_rsk(req);
+	ireq6->pktopts = NULL;
+
 	dccp_reqsk_init(req, skb);
 
 	dreq = dccp_rsk(req);
@@ -418,10 +421,8 @@ static int dccp_v6_conn_request(struct s
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
-	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
