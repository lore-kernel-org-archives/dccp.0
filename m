From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 24 Oct 2006 14:01:15 +0000
Subject: [PATCH 15/17] [DCCP]: tidy up dccp_v{4,6}_conn_request
Message-Id: <200610241501.15330@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: tidy up dccp_v{4,6}_conn_request

This is a code simplification which removes reduplicated code
and instead concentrates shared code.

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


Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>
------------------------------------------------------------------------------

 net/dccp/dccp.h |   18 ++++++++++++------
 net/dccp/ipv4.c |   20 +++-----------------
 net/dccp/ipv6.c |   15 +++++----------
 3 files changed, 20 insertions(+), 33 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index f9fbc9c..a0e4e4f 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -13,6 +13,7 @@ #define _DCCP_H
  */
 
 #include <linux/dccp.h>
+#include <linux/random.h>
 #include <net/snmp.h>
 #include <net/sock.h>
 #include <net/tcp.h>
@@ -158,16 +159,13 @@ extern void dccp_set_state(struct sock *
 extern void dccp_done(struct sock *sk);
 
 static inline void dccp_openreq_init(struct request_sock *req,
-				     struct dccp_sock *dp,
 				     struct sk_buff *skb)
 {
-	/*
-	 * FIXME: fill in the other req fields from the DCCP options
-	 * received
-	 */
+	extern int  dccp_feat_default_sequence_window;
+
 	inet_rsk(req)->rmt_port = dccp_hdr(skb)->dccph_sport;
 	inet_rsk(req)->acked	= 0;
-	req->rcv_wnd = 0;
+	req->rcv_wnd		= dccp_feat_default_sequence_window;
 }
 
 extern int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb);
@@ -282,6 +280,14 @@ static inline int dccp_packet_without_ac
 #define DCCP_MAX_SEQNO ((((u64)1) << 48) - 1)
 #define DCCP_PKT_WITHOUT_ACK_SEQ (DCCP_MAX_SEQNO << 2)
 
+static inline __u32 dccp_v4_init_sequence(struct sock *sk, struct sk_buff *skb)
+{
+	return secure_dccp_sequence_number(skb->nh.iph->daddr,
+					   skb->nh.iph->saddr,
+					   dccp_hdr(skb)->dccph_dport,
+					   dccp_hdr(skb)->dccph_sport);
+}
+
 static inline void dccp_set_seqno(u64 *seqno, u64 value)
 {
 	if (value > DCCP_MAX_SEQNO)
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index a6cc844..cf8af58 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -14,7 +14,6 @@ #include <linux/dccp.h>
 #include <linux/icmp.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
-#include <linux/random.h>
 
 #include <net/icmp.h>
 #include <net/inet_common.h>
@@ -360,15 +359,6 @@ void dccp_v4_send_check(struct sock *sk,
 
 EXPORT_SYMBOL_GPL(dccp_v4_send_check);
 
-static inline u64 dccp_v4_init_sequence(const struct sock *sk,
-					const struct sk_buff *skb)
-{
-	return secure_dccp_sequence_number(skb->nh.iph->daddr,
-					   skb->nh.iph->saddr,
-					   dccp_hdr(skb)->dccph_dport,
-					   dccp_hdr(skb)->dccph_sport);
-}
-
 /*
  * The three way handshake has completed - we got a valid ACK or DATAACK -
  * now create the new socket.
@@ -636,11 +626,8 @@ static struct request_sock_ops dccp_requ
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
@@ -680,15 +667,14 @@ int dccp_v4_conn_request(struct sock *sk
 	if (dccp_parse_options(sk, skb))
 		goto drop_and_free;
 
-	dccp_openreq_init(req, &dp, skb);
+	dccp_openreq_init(req, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
 	ireq = inet_rsk(req);
-	ireq->loc_addr = daddr;
-	ireq->rmt_addr = saddr;
-	req->rcv_wnd	= dccp_feat_default_sequence_window;
+	ireq->loc_addr	= skb->nh.iph->daddr;
+	ireq->rmt_addr	= skb->nh.iph->saddr;
 	ireq->opt	= NULL;
 
 	/*
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 432b9a0..c122703 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -13,7 +13,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/random.h>
 #include <linux/xfrm.h>
 
 #include <net/addrconf.h>
@@ -66,7 +65,7 @@ static inline u16 dccp_v6_check(struct d
 	return csum_ipv6_magic(saddr, daddr, len, IPPROTO_DCCP, base);
 }
 
-static __u32 dccp_v6_init_sequence(struct sock *sk, struct sk_buff *skb)
+static inline __u32 dccp_v6_init_sequence(struct sock *sk, struct sk_buff *skb)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 
@@ -76,10 +75,7 @@ static __u32 dccp_v6_init_sequence(struc
 						    dh->dccph_dport,
 						    dh->dccph_sport);
 
-	return secure_dccp_sequence_number(skb->nh.iph->daddr,
-					   skb->nh.iph->saddr,
-					   dh->dccph_dport,
-					   dh->dccph_sport);
+	return dccp_v4_init_sequence(sk, skb);
 }
 
 static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
@@ -427,7 +423,6 @@ static struct sock *dccp_v6_hnd_req(stru
 
 static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 {
-	struct dccp_sock dp;
 	struct request_sock *req;
 	struct dccp_request_sock *dreq;
 	struct inet6_request_sock *ireq6;
@@ -459,9 +454,10 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
-	/* FIXME: process options */
+	if (dccp_parse_options(sk, skb))
+		goto drop_and_free;
 
-	dccp_openreq_init(req, &dp, skb);
+	dccp_openreq_init(req, skb);
 
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
@@ -469,7 +465,6 @@ static int dccp_v6_conn_request(struct s
 	ireq6 = inet6_rsk(req);
 	ipv6_addr_copy(&ireq6->rmt_addr, &skb->nh.ipv6h->saddr);
 	ipv6_addr_copy(&ireq6->loc_addr, &skb->nh.ipv6h->daddr);
-	req->rcv_wnd	= dccp_feat_default_sequence_window;
 	ireq6->pktopts	= NULL;
 
 	if (ipv6_opt_accepted(sk, skb) ||
