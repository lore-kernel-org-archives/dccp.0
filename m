From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 13 Nov 2006 15:43:27 +0000
Subject: [PATCH 6/7][DCCP]: Remove redundant statements in init_sequence (ISS)
Message-Id: <20061113154326.GK6947@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch removes the following redundancies:

 1) The test skb->protocol = htons(ETH_P_IPV6) in dccp_v6_init_sequence
    is always true since
     * dccp_v6_conn_request() is the only calling function
     * dccp_v6_conn_request() redirects all skb's with ETH_P_IP to
       dccp_v4_conn_request()

 2) The first argument, `struct sock *sk', of dccp_v{4,6}_init_sequence()
    is never used.

(This is similar for tcp_v{4,6}_init_sequence, an analogous patch has been
 submitted to netdev and merged.)

By the way - are the `sport' / `dport' arguments in the right order?
I have made them consistent among calls but they seem to be in the
reverse order.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ipv4.c |    5 ++---
 ipv6.c |   20 ++++++--------------
 2 files changed, 8 insertions(+), 17 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 84c0540..b56a2fa 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -366,8 +366,7 @@ void dccp_v4_send_check(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(dccp_v4_send_check);
 
-static inline u64 dccp_v4_init_sequence(const struct sock *sk,
-					const struct sk_buff *skb)
+static inline u64 dccp_v4_init_sequence(const struct sk_buff *skb)
 {
 	return secure_dccp_sequence_number(skb->nh.iph->daddr,
 					   skb->nh.iph->saddr,
@@ -663,7 +662,7 @@ int dccp_v4_conn_request(struct sock *sk
 	 */
 	dreq = dccp_rsk(req);
 	dreq->dreq_isr	   = dcb->dccpd_seq;
-	dreq->dreq_iss	   = dccp_v4_init_sequence(sk, skb);
+	dreq->dreq_iss	   = dccp_v4_init_sequence(skb);
 	dreq->dreq_service = service;
 
 	if (dccp_v4_send_response(sk, req, NULL))
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 339cc6a..ec9ed9a 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -76,20 +76,12 @@ static inline void dccp_v6_send_check(st
 	dh->dccph_checksum = dccp_v6_csum_finish(skb, &np->saddr, &np->daddr);
 }
 
-static __u32 dccp_v6_init_sequence(struct sock *sk, struct sk_buff *skb)
+static inline __u32 dccp_v6_init_sequence(const struct sk_buff *skb)
 {
-	const struct dccp_hdr *dh = dccp_hdr(skb);
-
-	if (skb->protocol = htons(ETH_P_IPV6))
-		return secure_tcpv6_sequence_number(skb->nh.ipv6h->daddr.s6_addr32,
-						    skb->nh.ipv6h->saddr.s6_addr32,
-						    dh->dccph_dport,
-						    dh->dccph_sport);
-
-	return secure_dccp_sequence_number(skb->nh.iph->daddr,
-					   skb->nh.iph->saddr,
-					   dh->dccph_dport,
-					   dh->dccph_sport);
+	return secure_tcpv6_sequence_number(skb->nh.ipv6h->daddr.s6_addr32,
+					    skb->nh.ipv6h->saddr.s6_addr32,
+					    dccp_hdr(skb)->dccph_dport,
+					    dccp_hdr(skb)->dccph_sport     );
 }
 
 static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -491,7 +483,7 @@ static int dccp_v6_conn_request(struct s
 	 */
 	dreq = dccp_rsk(req);
 	dreq->dreq_isr	   = dcb->dccpd_seq;
-	dreq->dreq_iss	   = dccp_v6_init_sequence(sk, skb);
+	dreq->dreq_iss	   = dccp_v6_init_sequence(skb);
 	dreq->dreq_service = service;
 
 	if (dccp_v6_send_response(sk, req, NULL))
