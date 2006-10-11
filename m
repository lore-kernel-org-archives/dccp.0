From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 11 Oct 2006 15:27:00 +0000
Subject: [Patch 2/3]:  dccp: Oops in DCCPv6
Message-Id: <200610111627.00880@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This part just shifts the code in ipv4.c in order
to resolve dependencies among the static functions.

It applies on the previous patch (don't use it standalone).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 ipv4.c |  368 ++++++++++++++++++++++++++++++++---------------------------------
 1 file changed, 183 insertions(+), 185 deletions(-)

diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index d27e208..f87b0c0 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -193,86 +193,6 @@ static inline void dccp_do_pmtu_discover
 	} /* else let the usual retransmit timer handle it */
 }
 
-static void dccp_v4_reqsk_send_ack(struct sk_buff *rxskb,
-				   struct request_sock *req)
-{
-	int err;
-	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
-	const u32 dccp_hdr_ack_len = sizeof(struct dccp_hdr) +
-				     sizeof(struct dccp_hdr_ext) +
-				     sizeof(struct dccp_hdr_ack_bits);
-	struct sk_buff *skb;
-
-	if (((struct rtable *)rxskb->dst)->rt_type != RTN_LOCAL)
-		return;
-
-	skb = alloc_skb(dccp_v4_ctl_socket->sk->sk_prot->max_header, GFP_ATOMIC);
-	if (skb = NULL)
-		return;
-
-	/* Reserve space for headers. */
-	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
-
-	skb->dst = dst_clone(rxskb->dst);
-
-	skb->h.raw = skb_push(skb, dccp_hdr_ack_len);
-	dh = dccp_hdr(skb);
-	memset(dh, 0, dccp_hdr_ack_len);
-
-	/* Build DCCP header and checksum it. */
-	dh->dccph_type	   = DCCP_PKT_ACK;
-	dh->dccph_sport	   = rxdh->dccph_dport;
-	dh->dccph_dport	   = rxdh->dccph_sport;
-	dh->dccph_doff	   = dccp_hdr_ack_len / 4;
-	dh->dccph_x	   = 1;
-
-	dccp_hdr_set_seq(dh, DCCP_SKB_CB(rxskb)->dccpd_ack_seq);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
-			 DCCP_SKB_CB(rxskb)->dccpd_seq);
-
-	bh_lock_sock(dccp_v4_ctl_socket->sk);
-	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
-				    rxskb->nh.iph->daddr,
-				    rxskb->nh.iph->saddr, NULL);
-	bh_unlock_sock(dccp_v4_ctl_socket->sk);
-
-	if (err = NET_XMIT_CN || err = 0) {
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
-		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
-	}
-}
-
-static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
-				 struct dst_entry *dst)
-{
-	int err = -1;
-	struct sk_buff *skb;
-
-	/* First, grab a route. */
-	
-	if (dst = NULL && (dst = inet_csk_route_req(sk, req)) = NULL)
-		goto out;
-
-	skb = dccp_make_response(sk, dst, req);
-	if (skb != NULL) {
-		const struct inet_request_sock *ireq = inet_rsk(req);
-		struct dccp_hdr *dh = dccp_hdr(skb);
-
-		dh->dccph_checksum = dccp_v4_checksum(skb, ireq->loc_addr,
-						      ireq->rmt_addr);
-		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
-					    ireq->rmt_addr,
-					    ireq->opt);
-		if (err = NET_XMIT_CN)
-			err = 0;
-	}
-
-out:
-	dst_release(dst);
-	return err;
-}
-
 /*
  * This routine is called by the ICMP module when it gets some sort of error
  * condition. If err < 0 then the socket should be closed and the error
@@ -449,93 +369,6 @@ static inline u64 dccp_v4_init_sequence(
 					   dccp_hdr(skb)->dccph_sport);
 }
 
-int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
-{
-	struct inet_request_sock *ireq;
-	struct dccp_sock dp;
-	struct request_sock *req;
-	struct dccp_request_sock *dreq;
-	const __be32 saddr = skb->nh.iph->saddr;
-	const __be32 daddr = skb->nh.iph->daddr;
- 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
-	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
-	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
-
-	/* Never answer to DCCP_PKT_REQUESTs send to broadcast or multicast */
-	if (((struct rtable *)skb->dst)->rt_flags &
-	    (RTCF_BROADCAST | RTCF_MULTICAST)) {
-		reset_code = DCCP_RESET_CODE_NO_CONNECTION;
-		goto drop;
-	}
-
-	if (dccp_bad_service_code(sk, service)) {
-		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
-		goto drop;
- 	}
-	/*
-	 * TW buckets are converted to open requests without
-	 * limitations, they conserve resources and peer is
-	 * evidently real one.
-	 */
-	if (inet_csk_reqsk_queue_is_full(sk))
-		goto drop;
-
-	/*
-	 * Accept backlog is full. If we have already queued enough
-	 * of warm entries in syn queue, drop request. It is better than
-	 * clogging syn queue with openreqs with exponentially increasing
-	 * timeout.
-	 */
-	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
-		goto drop;
-
-	req = reqsk_alloc(&dccp_request_sock_ops);
-	if (req = NULL)
-		goto drop;
-
-	if (dccp_parse_options(sk, skb))
-		goto drop_and_free;
-
-	dccp_openreq_init(req, &dp, skb);
-
-	if (security_inet_conn_request(sk, skb, req))
-		goto drop_and_free;
-
-	ireq = inet_rsk(req);
-	ireq->loc_addr = daddr;
-	ireq->rmt_addr = saddr;
-	req->rcv_wnd	= dccp_feat_default_sequence_window;
-	ireq->opt	= NULL;
-
-	/* 
-	 * Step 3: Process LISTEN state
-	 *
-	 * Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
-	 *
-	 * In fact we defer setting S.GSR, S.SWL, S.SWH to
-	 * dccp_create_openreq_child.
-	 */
-	dreq = dccp_rsk(req);
-	dreq->dreq_isr	   = dcb->dccpd_seq;
-	dreq->dreq_iss	   = dccp_v4_init_sequence(sk, skb);
-	dreq->dreq_service = service;
-
-	if (dccp_v4_send_response(sk, req, NULL))
-		goto drop_and_free;
-
-	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
-	return 0;
-
-drop_and_free:
-	reqsk_free(req);
-drop:
-	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
-	dcb->dccpd_reset_code = reset_code;
-	return -1;
-}
-
-EXPORT_SYMBOL_GPL(dccp_v4_conn_request);
-
 /*
  * The three way handshake has completed - we got a valid ACK or DATAACK -
  * now create the new socket.
@@ -687,6 +520,85 @@ static struct dst_entry* dccp_v4_route_s
 	return &rt->u.dst;
 }
 
+static void dccp_v4_reqsk_send_ack(struct sk_buff *rxskb,
+				   struct request_sock *req)
+{
+	int err;
+	struct dccp_hdr *rxdh = dccp_hdr(rxskb), *dh;
+	const u32 dccp_hdr_ack_len = sizeof(struct dccp_hdr) +
+				     sizeof(struct dccp_hdr_ext) +
+				     sizeof(struct dccp_hdr_ack_bits);
+	struct sk_buff *skb;
+
+	if (((struct rtable *)rxskb->dst)->rt_type != RTN_LOCAL)
+		return;
+
+	skb = alloc_skb(dccp_v4_ctl_socket->sk->sk_prot->max_header, GFP_ATOMIC);
+	if (skb = NULL)
+		return;
+
+	/* Reserve space for headers. */
+	skb_reserve(skb, dccp_v4_ctl_socket->sk->sk_prot->max_header);
+
+	skb->dst = dst_clone(rxskb->dst);
+
+	skb->h.raw = skb_push(skb, dccp_hdr_ack_len);
+	dh = dccp_hdr(skb);
+	memset(dh, 0, dccp_hdr_ack_len);
+
+	/* Build DCCP header and checksum it. */
+	dh->dccph_type	   = DCCP_PKT_ACK;
+	dh->dccph_sport	   = rxdh->dccph_dport;
+	dh->dccph_dport	   = rxdh->dccph_sport;
+	dh->dccph_doff	   = dccp_hdr_ack_len / 4;
+	dh->dccph_x	   = 1;
+
+	dccp_hdr_set_seq(dh, DCCP_SKB_CB(rxskb)->dccpd_ack_seq);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb),
+			 DCCP_SKB_CB(rxskb)->dccpd_seq);
+
+	bh_lock_sock(dccp_v4_ctl_socket->sk);
+	err = ip_build_and_send_pkt(skb, dccp_v4_ctl_socket->sk,
+				    rxskb->nh.iph->daddr,
+				    rxskb->nh.iph->saddr, NULL);
+	bh_unlock_sock(dccp_v4_ctl_socket->sk);
+
+	if (err = NET_XMIT_CN || err = 0) {
+		DCCP_INC_STATS_BH(DCCP_MIB_OUTSEGS);
+		DCCP_INC_STATS_BH(DCCP_MIB_OUTRSTS);
+	}
+}
+
+static int dccp_v4_send_response(struct sock *sk, struct request_sock *req,
+				 struct dst_entry *dst)
+{
+	int err = -1;
+	struct sk_buff *skb;
+
+	/* First, grab a route. */
+
+	if (dst = NULL && (dst = inet_csk_route_req(sk, req)) = NULL)
+		goto out;
+
+	skb = dccp_make_response(sk, dst, req);
+	if (skb != NULL) {
+		const struct inet_request_sock *ireq = inet_rsk(req);
+		struct dccp_hdr *dh = dccp_hdr(skb);
+
+		dh->dccph_checksum = dccp_v4_checksum(skb, ireq->loc_addr,
+						      ireq->rmt_addr);
+		memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
+		err = ip_build_and_send_pkt(skb, sk, ireq->loc_addr,
+					    ireq->rmt_addr,
+					    ireq->opt);
+		if (err = NET_XMIT_CN)
+			err = 0;
+	}
+
+out:
+	dst_release(dst);
+	return err;
+}
 static void dccp_v4_ctl_send_reset(struct sk_buff *rxskb)
 {
 	int err;
@@ -757,6 +669,110 @@ out:
 	 dst_release(dst);
 }
 
+static void dccp_v4_reqsk_destructor(struct request_sock *req)
+{
+	kfree(inet_rsk(req)->opt);
+}
+
+static struct request_sock_ops dccp_request_sock_ops = {
+	.family		= PF_INET,
+	.obj_size	= sizeof(struct dccp_request_sock),
+	.rtx_syn_ack	= dccp_v4_send_response,
+	.send_ack	= dccp_v4_reqsk_send_ack,
+	.destructor	= dccp_v4_reqsk_destructor,
+	.send_reset	= dccp_v4_ctl_send_reset,
+};
+
+static struct timewait_sock_ops dccp_timewait_sock_ops = {
+	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
+};
+
+int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
+{
+	struct inet_request_sock *ireq;
+	struct dccp_sock dp;
+	struct request_sock *req;
+	struct dccp_request_sock *dreq;
+	const __be32 saddr = skb->nh.iph->saddr;
+	const __be32 daddr = skb->nh.iph->daddr;
+ 	const __be32 service = dccp_hdr_request(skb)->dccph_req_service;
+	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
+	__u8 reset_code = DCCP_RESET_CODE_TOO_BUSY;
+
+	/* Never answer to DCCP_PKT_REQUESTs send to broadcast or multicast */
+	if (((struct rtable *)skb->dst)->rt_flags &
+	    (RTCF_BROADCAST | RTCF_MULTICAST)) {
+		reset_code = DCCP_RESET_CODE_NO_CONNECTION;
+		goto drop;
+	}
+
+	if (dccp_bad_service_code(sk, service)) {
+		reset_code = DCCP_RESET_CODE_BAD_SERVICE_CODE;
+		goto drop;
+ 	}
+	/*
+	 * TW buckets are converted to open requests without
+	 * limitations, they conserve resources and peer is
+	 * evidently real one.
+	 */
+	if (inet_csk_reqsk_queue_is_full(sk))
+		goto drop;
+
+	/*
+	 * Accept backlog is full. If we have already queued enough
+	 * of warm entries in syn queue, drop request. It is better than
+	 * clogging syn queue with openreqs with exponentially increasing
+	 * timeout.
+	 */
+	if (sk_acceptq_is_full(sk) && inet_csk_reqsk_queue_young(sk) > 1)
+		goto drop;
+
+	req = reqsk_alloc(&dccp_request_sock_ops);
+	if (req = NULL)
+		goto drop;
+
+	if (dccp_parse_options(sk, skb))
+		goto drop_and_free;
+
+	dccp_openreq_init(req, &dp, skb);
+
+	if (security_inet_conn_request(sk, skb, req))
+		goto drop_and_free;
+
+	ireq = inet_rsk(req);
+	ireq->loc_addr = daddr;
+	ireq->rmt_addr = saddr;
+	req->rcv_wnd	= dccp_feat_default_sequence_window;
+	ireq->opt	= NULL;
+
+	/*
+	 * Step 3: Process LISTEN state
+	 *
+	 *   Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookies
+	 *
+	 *   In fact we defer setting S.GSR, S.SWL, S.SWH to
+	 *   dccp_create_openreq_child.
+	 */
+	dreq = dccp_rsk(req);
+	dreq->dreq_isr	   = dcb->dccpd_seq;
+	dreq->dreq_iss	   = dccp_v4_init_sequence(sk, skb);
+	dreq->dreq_service = service;
+
+	if (dccp_v4_send_response(sk, req, NULL))
+		goto drop_and_free;
+
+	inet_csk_reqsk_queue_hash_add(sk, req, DCCP_TIMEOUT_INIT);
+	return 0;
+
+drop_and_free:
+	reqsk_free(req);
+drop:
+	DCCP_INC_STATS_BH(DCCP_MIB_ATTEMPTFAILS);
+	dcb->dccpd_reset_code = reset_code;
+	return -1;
+}
+EXPORT_SYMBOL_GPL(dccp_v4_conn_request);
+
 int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_hdr *dh = dccp_hdr(skb);
@@ -1015,24 +1031,6 @@ static int dccp_v4_init_sock(struct sock
 	return err;
 }
 
-static void dccp_v4_reqsk_destructor(struct request_sock *req)
-{
-	kfree(inet_rsk(req)->opt);
-}
-
-static struct request_sock_ops dccp_request_sock_ops = {
-	.family		= PF_INET,
-	.obj_size	= sizeof(struct dccp_request_sock),
-	.rtx_syn_ack	= dccp_v4_send_response,
-	.send_ack	= dccp_v4_reqsk_send_ack,
-	.destructor	= dccp_v4_reqsk_destructor,
-	.send_reset	= dccp_v4_ctl_send_reset,
-};
-
-static struct timewait_sock_ops dccp_timewait_sock_ops = {
-	.twsk_obj_size	= sizeof(struct inet_timewait_sock),
-};
-
 static struct proto dccp_v4_prot = {
 	.name			= "DCCP",
 	.owner			= THIS_MODULE,
