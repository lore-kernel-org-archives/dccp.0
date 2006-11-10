From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Fri, 10 Nov 2006 22:45:27 +0000
Subject: [PATCH 1/3][DCCP]: tidy up dccp_v{4,6}_conn_request
Message-Id: <20061110224526.GU23311@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a code simplification to remove reduplicated code
by concentrating and abstracting shared code.

Detailed Changes:
-----------------
 * dccp_v6_init_sequence includes the code from dccp_v4_init_sequence
    --moved dccp_v4_init_sequence into header file
    --inlined dccp_v6_init_sequence

 * tidied up dccp_v{4,6}_conn_request
    --struct dccp_sock dp is not used in any place (removed)
    --moved generic code into openreq_init

 * added dccp_parse_options(...) in dccp_v6_conn_request()
    --> this resolves a FIXME

 * tidied up openreq_init()
    --removed second argument (never used)
    --set the default sequence window there (generic code, is not AF-dependent)
    --removed FIXME regarding filling-in options: it seems that all sensible
      options are already filled in; so this note seems unnecessary.

Commiter note: I've changed the first bit, renaming dccp_openreq_init to
dccp_reqsk_init to get rid of some baggage from the past, when struct
request_sock was called openreq and uninlined it, idea is not to call anything
prefixed foo_v4_ in foo_v6 code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 dccp.h      |   13 +------------
 ipv4.c      |    9 +++------
 ipv6.c      |    7 +++----
 minisocks.c |    9 +++++++++
 4 files changed, 16 insertions(+), 22 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 7b859a7..2990bfb 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -155,18 +155,7 @@ extern const char *dccp_state_name(const
 extern void dccp_set_state(struct sock *sk, const int state);
 extern void dccp_done(struct sock *sk);
 
-static inline void dccp_openreq_init(struct request_sock *req,
-				     struct dccp_sock *dp,
-				     struct sk_buff *skb)
-{
-	/*
-	 * FIXME: fill in the other req fields from the DCCP options
-	 * received
-	 */
-	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
-	inet_rsk(req)->acked	= 0;
-	req->rcv_wnd = 0;
-}
+extern void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb);
 
 extern int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index ed62026..d75ce8c 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -636,11 +636,8 @@ static struct request_sock_ops dccp_requ
 int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 {
 	struct inet_request_sock *ireq;
-	struct dccp_sock dp;
 	struct request_sock *req;
 	struct dccp_request_sock *dreq;
-	const __be32 saddr = skb->nh.iph->saddr;
-	const __be32 daddr = skb->nh.iph->daddr;
  	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
 	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
@@ -680,14 +677,14 @@ int dccp_v4_conn_request(struct sock *sk
 	if (dccp_parse_options(sk, skb))
 		goto drop_and_free;
 
-	dccp_openreq_init(req, &dp, skb);
+	dccp_reqsk_init(req, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
 	ireq = inet_rsk(req);
-	ireq->loc_addr = daddr;
-	ireq->rmt_addr = saddr;
+	ireq->loc_addr = skb->nh.iph->daddr;
+	ireq->rmt_addr = skb->nh.iph->saddr;
 	req->rcv_wnd	= dccp_feat_default_sequence_window;
 	ireq->opt	= NULL;
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 4966369..c5f28ab 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -427,7 +427,6 @@ static struct sock *dccp_v6_hnd_req(stru
 
 static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct dccp_sock dp;
 	struct request_sock *req;
 	struct dccp_request_sock *dreq;
 	struct inet6_request_sock *ireq6;
@@ -459,9 +458,10 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
-	/* FIXME: process options */
+	if (dccp_parse_options(sk, skb))
+		goto drop_and_free;
 
-	dccp_openreq_init(req, &dp, skb);
+	dccp_reqsk_init(req, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
@@ -469,7 +469,6 @@ static int dccp_v6_conn_request(struct s
 	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &skb->nh.ipv6h->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &skb->nh.ipv6h->daddr);
-	req->rcv_wnd	= dccp_feat_default_sequence_window;
 	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index 5f3e1a4..0f228ab 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -293,3 +293,12 @@ void dccp_reqsk_send_ack(struct sk_buff 
 }
 
 EXPORT_SYMBOL_GPL(dccp_reqsk_send_ack);
+
+void dccp_reqsk_init(struct request_sock *req, struct sk_buff *skb)
+{
+	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
+	inet_rsk(req)->acked	= 0;
+	req->rcv_wnd		= dccp_feat_default_sequence_window;
+}
+
+EXPORT_SYMBOL_GPL(dccp_reqsk_init);
