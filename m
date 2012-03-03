From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 03 Mar 2012 16:33:53 +0000
Subject: [PATCH 2/2] dccp: fix bug in sequence number validation during connection setup
Message-Id: <1330792433-15415-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Samuel Jero <sj323707@ohio.edu>

This fixes a bug in the sequence number validation during the initial handshake.

The code did not treat the initial sequence numbers ISS and ISR as read-only and
did not keep state for GSR and GSS as required by the specification. This causes
problems with retransmissions during the initial handshake, causing the
budding connection to be reset.

This patch now treats ISS/ISR as read-only and tracks GSS/GSR as required.

Signed-off-by: Samuel Jero <sj323707@ohio.edu>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    8 ++++++--
 net/dccp/ipv4.c      |    8 +++++---
 net/dccp/ipv6.c      |    8 +++++---
 net/dccp/minisocks.c |   18 +++++++++++-------
 net/dccp/output.c    |   10 +++++-----
 5 files changed, 32 insertions(+), 20 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -376,8 +376,10 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
 /**
  * struct dccp_request_sock  -  represent DCCP-specific connection request
  * @dreq_inet_rsk: structure inherited from
- * @dreq_iss: initial sequence number sent on the Response (RFC 4340, 7.1)
- * @dreq_isr: initial sequence number received on the Request
+ * @dreq_iss: initial sequence number, sent on the first Response (RFC 4340, 7.1)
+ * @dreq_gss: greatest sequence number sent (for retransmitted Responses)
+ * @dreq_isr: initial sequence number received in the first Request
+ * @dreq_gsr: greatest sequence number received (for retransmitted Request(s))
  * @dreq_service: service code present on the Request (there is just one)
  * @dreq_featneg: feature negotiation options for this connection
  * The following two fields are analogous to the ones in dccp_sock:
@@ -387,7 +389,9 @@ static inline unsigned int dccp_hdr_len(const struct sk_buff *skb)
 struct dccp_request_sock {
 	struct inet_request_sock dreq_inet_rsk;
 	__u64			 dreq_iss;
+	__u64			 dreq_gss;
 	__u64			 dreq_isr;
+	__u64			 dreq_gsr;
 	__be32			 dreq_service;
 	struct list_head	 dreq_featneg;
 	__u32			 dreq_timestamp_echo;
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -300,7 +300,8 @@ static void dccp_v4_err(struct sk_buff *skb, u32 info)
 		 */
 		WARN_ON(req->sk);
 
-		if (seq != dccp_rsk(req)->dreq_iss) {
+		if (!between48(seq, dccp_rsk(req)->dreq_iss,
+				    dccp_rsk(req)->dreq_gss)) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -639,11 +640,12 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 	 *
 	 * Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
 	 *
-	 * In fact we defer setting S.GSR, S.SWL, S.SWH to
-	 * dccp_create_openreq_child.
+	 * Setting S.SWL/S.SWH to is deferred to dccp_create_openreq_child().
 	 */
 	dreq->dreq_isr	   = dcb->dccpd_seq;
+	dreq->dreq_gsr	   = dreq->dreq_isr;
 	dreq->dreq_iss	   = dccp_v4_init_sequence(skb);
+	dreq->dreq_gss     = dreq->dreq_iss;
 	dreq->dreq_service = service;
 
 	if (dccp_v4_send_response(sk, req, NULL))
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -193,7 +193,8 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		 */
 		WARN_ON(req->sk != NULL);
 
-		if (seq != dccp_rsk(req)->dreq_iss) {
+		if (!between48(seq, dccp_rsk(req)->dreq_iss,
+				    dccp_rsk(req)->dreq_gss)) {
 			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
 			goto out;
 		}
@@ -440,11 +441,12 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 	 *
 	 *   Set S.ISR, S.GSR, S.SWL, S.SWH from packet or Init Cookie
 	 *
-	 *   In fact we defer setting S.GSR, S.SWL, S.SWH to
-	 *   dccp_create_openreq_child.
+	 * Setting S.SWL/S.SWH to is deferred to dccp_create_openreq_child().
 	 */
 	dreq->dreq_isr	   = dcb->dccpd_seq;
+	dreq->dreq_gsr     = dreq->dreq_isr;
 	dreq->dreq_iss	   = dccp_v6_init_sequence(skb);
+	dreq->dreq_gss     = dreq->dreq_iss;
 	dreq->dreq_service = service;
 
 	if (dccp_v6_send_response(sk, req, NULL))
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -127,9 +127,11 @@ struct sock *dccp_create_openreq_child(struct sock *sk,
 		 *    activation below, as these windows all depend on the local
 		 *    and remote Sequence Window feature values (7.5.2).
 		 */
-		newdp->dccps_gss = newdp->dccps_iss = dreq->dreq_iss;
+		newdp->dccps_iss = dreq->dreq_iss;
+		newdp->dccps_gss = dreq->dreq_gss;
 		newdp->dccps_gar = newdp->dccps_iss;
-		newdp->dccps_gsr = newdp->dccps_isr = dreq->dreq_isr;
+		newdp->dccps_isr = dreq->dreq_isr;
+		newdp->dccps_gsr = dreq->dreq_gsr;
 
 		/*
 		 * Activate features: initialise CCIDs, sequence windows etc.
@@ -164,9 +166,9 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 	/* Check for retransmitted REQUEST */
 	if (dccp_hdr(skb)->dccph_type = DCCP_PKT_REQUEST) {
 
-		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_isr)) {
+		if (after48(DCCP_SKB_CB(skb)->dccpd_seq, dreq->dreq_gsr)) {
 			dccp_pr_debug("Retransmitted REQUEST\n");
-			dreq->dreq_isr = DCCP_SKB_CB(skb)->dccpd_seq;
+			dreq->dreq_gsr = DCCP_SKB_CB(skb)->dccpd_seq;
 			/*
 			 * Send another RESPONSE packet
 			 * To protect against Request floods, increment retrans
@@ -186,12 +188,14 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 		goto drop;
 
 	/* Invalid ACK */
-	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != dreq->dreq_iss) {
+	if (!between48(DCCP_SKB_CB(skb)->dccpd_ack_seq,
+				dreq->dreq_iss, dreq->dreq_gss)) {
 		dccp_pr_debug("Invalid ACK number: ack_seq=%llu, "
-			      "dreq_iss=%llu\n",
+			      "dreq_iss=%llu, dreq_gss=%llu\n",
 			      (unsigned long long)
 			      DCCP_SKB_CB(skb)->dccpd_ack_seq,
-			      (unsigned long long) dreq->dreq_iss);
+			      (unsigned long long) dreq->dreq_iss,
+			      (unsigned long long) dreq->dreq_gss);
 		goto drop;
 	}
 
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -408,10 +408,10 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 	skb_dst_set(skb, dst_clone(dst));
 
 	dreq = dccp_rsk(req);
-	if (inet_rsk(req)->acked)	/* increase ISS upon retransmission */
-		dccp_inc_seqno(&dreq->dreq_iss);
+	if (inet_rsk(req)->acked)	/* increase GSS upon retransmission */
+		dccp_inc_seqno(&dreq->dreq_gss);
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_RESPONSE;
-	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_iss;
+	DCCP_SKB_CB(skb)->dccpd_seq  = dreq->dreq_gss;
 
 	/* Resolve feature dependencies resulting from choice of CCID */
 	if (dccp_feat_server_ccid_dependencies(dreq))
@@ -429,8 +429,8 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 			   DCCP_SKB_CB(skb)->dccpd_opt_len) / 4;
 	dh->dccph_type	= DCCP_PKT_RESPONSE;
 	dh->dccph_x	= 1;
-	dccp_hdr_set_seq(dh, dreq->dreq_iss);
-	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_isr);
+	dccp_hdr_set_seq(dh, dreq->dreq_gss);
+	dccp_hdr_set_ack(dccp_hdr_ack_bits(skb), dreq->dreq_gsr);
 	dccp_hdr_response(skb)->dccph_resp_service = dreq->dreq_service;
 
 	dccp_csum_outgoing(skb);
