From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:40:53 +0000
Subject: [PATCH 8/8] [DCCP]: Factor out common code for generating Resets
Message-Id: <20070926184053.GJ10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This factors code common to dccp_v{4,6}_ctl_send_reset into a separate function,
and adds support for filling in the Data 1 ... Data 3 fields from RFC 4340, 5.6.

It is useful to have this separate, since the following Reset codes will always
be generated from the control socket rather than via dccp_send_reset:
 * Code 3, "No Connection", cf. 8.3.1;
 * Code 4, "Packet Error" (identification for Data 1 added);
 * Code 5, "Option Error" (identification for Data 1..3 added, will be used later);
 * Code 6, "Mandatory Error" (same as Option Error);
 * Code 7, "Connection Refused" (what on Earth is the difference to "No Connection"?);
 * Code 8, "Bad Service Code";
 * Code 9, "Too Busy";
 * Code 10, "Bad Init Cookie" (not used).

Code 0 is not recommended by the RFC, the following codes would be used in
dccp_send_reset() instead, since they all relate to an established DCCP connection:
 * Code 1, "Closed";
 * Code 2, "Aborted";
 * Code 11, "Aggression Penalty" (12.3).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/dccp.h   |    2 ++
 net/dccp/ipv4.c   |   38 +++++---------------------------------
 net/dccp/ipv6.c   |   39 ++++++---------------------------------
 net/dccp/output.c |   52 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 65 insertions(+), 66 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index a602d92..ee97950 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -294,6 +294,8 @@ extern unsigned int dccp_poll(struct file *file, struct socket *sock,
 extern int	   dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr,
 				   int addr_len);
 
+extern struct sk_buff *dccp_ctl_make_reset(struct socket *ctl,
+					   struct sk_buff *skb);
 extern int	   dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 extern void	   dccp_send_close(struct sock *sk, const int active);
 extern int	   dccp_invalid_packet(struct sk_buff *skb);
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 58a79c2..2312b9f 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -510,17 +510,12 @@ out:
 static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 {
 	int err;
-	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
 	const struct iphdr *rxiph;
-	const int dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
-				       sizeof(struct dccp_hdr_ext) +
-				       sizeof(struct dccp_hdr_reset);
 	struct sk_buff *skb;
 	struct dst_entry *dst;
-	u64 seqno = 0;
 
 	/* Never send a reset in response to a reset. */
-	if (rxdh->dccph_type = DCCP_PKT_RESET)
+	if (dccp_hdr(rxskb)->dccph_type = DCCP_PKT_RESET)
 		return;
 
 	if (((struct rtable *)rxskb->dst)->rt_type != RTN_LOCAL)
@@ -530,37 +525,14 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (dst = NULL)
 		return;
 
-	skb = alloc_skb(dccp_v4_ctl_socket->sk->sk_prot->max_header,
-			GFP_ATOMIC);
+	skb = dccp_ctl_make_reset(dccp_v4_ctl_socket, rxskb);
 	if (skb = NULL)
 		goto out;
 
-	/* Reserve space for headers. */
-	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
-	skb->dst = dst_clone(dst);
-
-	dh = dccp_zeroed_hdr(skb, dccp_hdr_reset_len);
-
-	/* Build DCCP header and checksum it. */
-	dh->dccph_type	   = DCCP_PKT_RESET;
-	dh->dccph_sport	   = rxdh->dccph_dport;
-	dh->dccph_dport	   = rxdh->dccph_sport;
-	dh->dccph_doff	   = dccp_hdr_reset_len / 4;
-	dh->dccph_x	   = 1;
-	dccp_hdr_reset(skb)->dccph_reset_code -				DCCP_SKB_CB(rxskb)->dccpd_reset_code;
-
-	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
-	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		seqno = ADD48(DCCP_SKB_CB(rxskb)->dccpd_ack_seq, 1);
-
-	dccp_hdr_set_seq(dh, seqno);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
-
-	dccp_csum_outgoing(skb);
 	rxiph = ip_hdr(rxskb);
-	dh->dccph_checksum = dccp_v4_csum_finish(skb, rxiph->saddr,
-						 rxiph->daddr);
+	dccp_hdr(skb)->dccph_checksum = dccp_v4_csum_finish(skb, rxiph->saddr,
+								 rxiph->daddr);
+	skb->dst = dst_clone(dst);
 
 	bh_lock_sock(dccp_v4_ctl_socket->sk);
 	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index d954e83..b7c0f66 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -301,50 +301,23 @@ static void dccp_v6_reqsk_destructor(struct request_sock *req)
 
 static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 {
-	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
 	struct ipv6hdr *rxip6h;
-	const u32 dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
-				       sizeof(struct dccp_hdr_ext) +
-				       sizeof(struct dccp_hdr_reset);
 	struct sk_buff *skb;
 	struct flowi fl;
-	u64 seqno = 0;
 
-	if (rxdh->dccph_type = DCCP_PKT_RESET)
+	if (dccp_hdr(rxskb)->dccph_type = DCCP_PKT_RESET)
 		return;
 
 	if (!ipv6_unicast_destination(rxskb))
 		return;
 
-	skb = alloc_skb(dccp_v6_ctl_socket->sk->sk_prot->max_header,
-			GFP_ATOMIC);
+	skb = dccp_ctl_make_reset(dccp_v6_ctl_socket, rxskb);
 	if (skb = NULL)
 		return;
 
-	skb_reserve(skb, dccp_v6_ctl_socket->sk->sk_prot->max_header);
-
-	dh = dccp_zeroed_hdr(skb, dccp_hdr_reset_len);
-
-	/* Swap the send and the receive. */
-	dh->dccph_type	= DCCP_PKT_RESET;
-	dh->dccph_sport	= rxdh->dccph_dport;
-	dh->dccph_dport	= rxdh->dccph_sport;
-	dh->dccph_doff	= dccp_hdr_reset_len / 4;
-	dh->dccph_x	= 1;
-	dccp_hdr_reset(skb)->dccph_reset_code -				DCCP_SKB_CB(rxskb)->dccpd_reset_code;
-
-	/* See "8.3.1. Abnormal Termination" in RFC 4340 */
-	if (DCCP_SKB_CB(rxskb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
-		seqno = ADD48(DCCP_SKB_CB(rxskb)->dccpd_ack_seq, 1);
-
-	dccp_hdr_set_seq(dh, seqno);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), DCCP_SKB_CB(rxskb)->dccpd_seq);
-
-	dccp_csum_outgoing(skb);
 	rxip6h = ipv6_hdr(rxskb);
-	dh->dccph_checksum = dccp_v6_csum_finish(skb, &rxip6h->saddr,
-						      &rxip6h->daddr);
+	dccp_hdr(skb)->dccph_checksum = dccp_v6_csum_finish(skb, &rxip6h->saddr,
+							    &rxip6h->daddr);
 
 	memset(&fl, 0, sizeof(fl));
 	ipv6_addr_copy(&fl.fl6_dst, &rxip6h->saddr);
@@ -352,8 +325,8 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 
 	fl.proto = IPPROTO_DCCP;
 	fl.oif = inet6_iif(rxskb);
-	fl.fl_ip_dport = dh->dccph_dport;
-	fl.fl_ip_sport = dh->dccph_sport;
+	fl.fl_ip_dport = dccp_hdr(skb)->dccph_dport;
+	fl.fl_ip_sport = dccp_hdr(skb)->dccph_sport;
 	security_skb_classify_flow(rxskb, &fl);
 
 	/* sk = NULL, but it is safe for now. RST socket required. */
diff --git a/net/dccp/output.c b/net/dccp/output.c
index f4bde20..6a334ed 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -327,6 +327,58 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 
 EXPORT_SYMBOL_GPL(dccp_make_response);
 
+/* answer offending packet in @rcv_skb with Reset from control socket @ctl */
+struct sk_buff *dccp_ctl_make_reset(struct socket *ctl, struct sk_buff *rcv_skb)
+{
+	struct dccp_hdr *rxdh = dccp_hdr(rcv_skb), *dh;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(rcv_skb);
+	const u32 dccp_hdr_reset_len = sizeof(struct dccp_hdr) +
+				       sizeof(struct dccp_hdr_ext) +
+				       sizeof(struct dccp_hdr_reset);
+	struct dccp_hdr_reset *dhr;
+	struct sk_buff *skb;
+
+	skb = alloc_skb(ctl->sk->sk_prot->max_header, GFP_ATOMIC);
+	if (skb = NULL)
+		return NULL;
+
+	skb_reserve(skb, ctl->sk->sk_prot->max_header);
+
+	/* Swap the send and the receive. */
+	dh = dccp_zeroed_hdr(skb, dccp_hdr_reset_len);
+	dh->dccph_type	= DCCP_PKT_RESET;
+	dh->dccph_sport	= rxdh->dccph_dport;
+	dh->dccph_dport	= rxdh->dccph_sport;
+	dh->dccph_doff	= dccp_hdr_reset_len / 4;
+	dh->dccph_x	= 1;
+
+	dhr = dccp_hdr_reset(skb);
+	dhr->dccph_reset_code = dcb->dccpd_reset_code;
+
+	switch (dcb->dccpd_reset_code) {
+	case DCCP_RESET_CODE_PACKET_ERROR:
+		dhr->dccph_reset_data[0] = rxdh->dccph_type;
+		break;
+	case DCCP_RESET_CODE_OPTION_ERROR:	/* fall through */
+	case DCCP_RESET_CODE_MANDATORY_ERROR:
+		memcpy(dhr->dccph_reset_data, dcb->dccpd_reset_data, 3);
+		break;
+	}
+	/*
+	 * From RFC 4340, 8.3.1:
+	 *   If P.ackno exists, set R.seqno := P.ackno + 1.
+	 *   Else set R.seqno := 0.
+	 */
+	if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
+		dccp_hdr_set_seq(dh, ADD48(dcb->dccpd_ack_seq, 1));
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dcb->dccpd_seq);
+
+	dccp_csum_outgoing(skb);
+	return skb;
+}
+
+EXPORT_SYMBOL_GPL(dccp_ctl_make_reset);
+
 /* send Reset on established socket, to close or abort the connection */
 int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
 {
-- 
1.5.2.2

