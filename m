From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Tue, 10 Jun 2008 14:38:12 +0000
Subject: Re: [PATCH 7/7] dccp: Initialise option area of v4/v6 request
Message-Id: <20080610143812.GB26686@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
References: <1213102423-27486-8-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1213102423-27486-8-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Em Tue, Jun 10, 2008 at 01:53:43PM +0100, Gerrit Renker escreveu:
> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> This fixes the following bug:
>  * dccp_v4_reqsk_destructor() frees inet inet_rsk(req)->opt,
>  * but dccp_v4_conn_request() may fail before initialising inet_rsk(req)->opt;
>  * likewise, dccp_v6_reqsk_destructor() frees inet6_rsk(req)->pktopts,
>  * but dccp_v6_conn_request() may fail before initialising the pktopts.
> 
> The fix is in initialising the option areas in both request sockets before
> calling any other code that may fail and thus may end up calling the destructor.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The problem is present in TCP too, look at cookie_v4_check and
tcp_v4_conn_request, we may get to reqsk_free before we set ->opt if
security_inet_conn_request() returns non zero.

This is one case where bugs found on DCCP lead to an audit of the
similar code in TCP and the fix should be done on the common
infrastructure.

Please consider the following patch instead, it is compile tested only
but should be OK.

Thanks a lot,

- Arnaldo

commit f627bdaa7428f04b828abd70a8145cafb7ce366b
Author: Arnaldo Carvalho de Melo <acme@redhat.com>
Date:   Tue Jun 10 10:37:32 2008 -0300

    inet{6}_request_sock: Init ->opt and ->pktopts in the constructor
    
    Wei Yongjun noticed that we may call reqsk_free on request sock objects where
    the opt fields may not be initialized, fix it by introducing inet_reqsk_alloc
    where we initialize ->opt to NULL and set ->pktopts to NULL in
    inet6_reqsk_alloc.
    
    Cc: Gerrit Renker <gerrit@erg.abdn.ac.uk>
    Cc: Wei Yongjun <yjwei@cn.fujitsu.com>
    Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 10b666b..cde056e 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -396,8 +396,10 @@ static inline struct request_sock *inet6_reqsk_alloc(struct request_sock_ops *op
 {
 	struct request_sock *req = reqsk_alloc(ops);
 
-	if (req != NULL)
+	if (req != NULL) {
 		inet_rsk(req)->inet6_rsk_offset = inet6_rsk_offset(req);
+		inet6_rsk(req)->pktopts = NULL;
+	}
 
 	return req;
 }
diff --git a/include/net/inet_sock.h b/include/net/inet_sock.h
index a42cd63..9fabe5b 100644
--- a/include/net/inet_sock.h
+++ b/include/net/inet_sock.h
@@ -197,4 +197,14 @@ static inline int inet_iif(const struct sk_buff *skb)
 	return skb->rtable->rt_iif;
 }
 
+static inline struct request_sock *inet_reqsk_alloc(struct request_sock_ops *ops)
+{
+	struct request_sock *req = reqsk_alloc(ops);
+
+	if (req != NULL)
+		inet_rsk(req)->opt = NULL;
+
+	return req;
+}
+
 #endif	/* _INET_SOCK_H */
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index c22a378..37d27bc 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -589,7 +589,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = reqsk_alloc(&dccp_request_sock_ops);
+	req = inet_reqsk_alloc(&dccp_request_sock_ops);
 	if (req = NULL)
 		goto drop;
 
@@ -605,7 +605,6 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq->loc_addr = ip_hdr(skb)->daddr;
 	ireq->rmt_addr = ip_hdr(skb)->saddr;
-	ireq->opt	= NULL;
 
 	/*
 	 * Step 3: Process LISTEN state
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 9b1129b..f7fe2a5 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -421,7 +421,6 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &ipv6_hdr(skb)->daddr);
-	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
 	    np->rxopt.bits.rxinfo || np->rxopt.bits.rxoinfo ||
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 73ba989..d182a2a 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -285,7 +285,7 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		cookie_check_timestamp(&tcp_opt);
 
 	ret = NULL;
-	req = reqsk_alloc(&tcp_request_sock_ops); /* for safety */
+	req = inet_reqsk_alloc(&tcp_request_sock_ops); /* for safety */
 	if (!req)
 		goto out;
 
@@ -301,7 +301,6 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 	ireq->rmt_port		= th->source;
 	ireq->loc_addr		= ip_hdr(skb)->daddr;
 	ireq->rmt_addr		= ip_hdr(skb)->saddr;
-	ireq->opt		= NULL;
 	ireq->snd_wscale	= tcp_opt.snd_wscale;
 	ireq->rcv_wscale	= tcp_opt.rcv_wscale;
 	ireq->sack_ok		= tcp_opt.sack_ok;
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index cd601a8..4f8485c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1285,7 +1285,7 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
 		goto drop;
 
-	req = reqsk_alloc(&tcp_request_sock_ops);
+	req = inet_reqsk_alloc(&tcp_request_sock_ops);
 	if (!req)
 		goto drop;
 
diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
index 938ce4e..3ecc115 100644
--- a/net/ipv6/syncookies.c
+++ b/net/ipv6/syncookies.c
@@ -198,7 +198,6 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
 	ireq = inet_rsk(req);
 	ireq6 = inet6_rsk(req);
 	treq = tcp_rsk(req);
-	ireq6->pktopts = NULL;
 
 	if (security_inet_conn_request(sk, skb, req)) {
 		reqsk_free(req);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 715965f..cb46749 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1299,7 +1299,6 @@ static int tcp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	treq = inet6_rsk(req);
 	ipv6_addr_copy(&treq->rmt_addr, &ipv6_hdr(skb)->saddr);
 	ipv6_addr_copy(&treq->loc_addr, &ipv6_hdr(skb)->daddr);
-	treq->pktopts = NULL;
 	if (!want_cookie)
 		TCP_ECN_create_request(req, tcp_hdr(skb));
 
