From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 12:53:43 +0000
Subject: [PATCH 7/7] dccp: Initialise option area of v4/v6 request socket
Message-Id: <1213102423-27486-8-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Wei Yongjun <yjwei@cn.fujitsu.com>

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
@@ -593,6 +593,9 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (req = NULL)
 		goto drop;
 
+	ireq = inet_rsk(req);
+	ireq->opt = NULL;
+
 	dccp_reqsk_init(req, skb);
 
 	dreq = dccp_rsk(req);
@@ -602,10 +605,8 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
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
@@ -409,6 +409,9 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (req = NULL)
 		goto drop;
 
+	ireq6 = inet6_rsk(req);
+	ireq6->pktopts = NULL;
+
 	dccp_reqsk_init(req, skb);
 
 	dreq = dccp_rsk(req);
@@ -418,10 +421,8 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
-	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
-	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
