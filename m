From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 14:30:41 +0000
Subject: [PATCH 5/8]: Allow to parse options on Request Sockets
Message-Id: <200709251530.41488@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Allow to parse options on Request Sockets

The option parsing code currently only parses on full sk's. This causes a problem for
options sent during the initial handshake (in particular timestamps and feature-negotiation
options). Therefore, this patch extends the option parsing code with an additional argument
for request_socks: if it is non-NULL, options are parsed on the request socket, otherwise
the normal path (parsing on the sk) is used. 

Subsequent patches, which implement feature negotiation during connection setup, make use
of this facility.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 include/linux/dccp.h |    5 +++--
 net/dccp/input.c     |    6 +++---
 net/dccp/ipv4.c      |    8 ++++----
 net/dccp/ipv6.c      |    8 ++++----
 net/dccp/options.c   |   34 +++++++++++++++++++++++-----------
 5 files changed, 37 insertions(+), 24 deletions(-)

--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -407,8 +407,6 @@ struct dccp_opt_pend {
 
 extern void dccp_minisock_init(struct dccp_minisock *dmsk);
 
-extern int dccp_parse_options(struct sock *sk, struct sk_buff *skb);
-
 struct dccp_request_sock {
 	struct inet_request_sock dreq_inet_rsk;
 	__u64			 dreq_iss;
@@ -423,6 +421,9 @@ static inline struct dccp_request_sock *
 
 extern struct inet_timewait_death_row dccp_death_row;
 
+extern int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
+			      struct sk_buff *skb);
+
 struct dccp_options_received {
 	u32	dccpor_ndp; /* only 24 bits */
 	u32	dccpor_timestamp;
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -39,7 +39,13 @@ static u32 dccp_decode_value_var(const u
 	return value;
 }
 
-int dccp_parse_options(struct sock *sk, struct sk_buff *skb)
+/**
+ * dccp_parse_options  -  Parse DCCP options present in @skb
+ * @sk: client|server|listening dccp socket (when @dreq != NULL)
+ * @dreq: request socket to use during connection setup, or NULL
+ */
+int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
+		       struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	const struct dccp_hdr *dh = dccp_hdr(skb);
@@ -84,6 +90,20 @@ int dccp_parse_options(struct sock *sk, 
 				goto out_invalid_option;
 		}
 
+		/*
+		 * CCID-Specific Options (from RFC 4340, sec. 10.3):
+		 *
+		 * Option numbers 128 through 191 are for options sent from the
+		 * HC-Sender to the HC-Receiver; option numbers 192 through 255
+		 * are for options sent from the HC-Receiver to	the HC-Sender.
+		 *
+		 * CCID-specific options are ignored during connection setup, as
+		 * negotiation may still be in progress (see RFC 4340, 10.3).
+		 *
+		 */
+		if (dreq != NULL && opt >= 128)
+			goto ignore_option;
+
 		switch (opt) {
 		case DCCPO_PADDING:
 			break;
@@ -142,6 +162,7 @@ int dccp_parse_options(struct sock *sk, 
 			opt_val = get_unaligned((u32 *)value);
 			opt_recv->dccpor_timestamp = ntohl(opt_val);
 
+			/* FIXME: if dreq != NULL, don't store this on listening socket */
 			dp->dccps_timestamp_echo = opt_recv->dccpor_timestamp;
 			dp->dccps_timestamp_time = ktime_get_real();
 
@@ -204,15 +225,6 @@ int dccp_parse_options(struct sock *sk, 
 			dccp_pr_debug("%s rx opt: ELAPSED_TIME=%d\n",
 				      dccp_role(sk), elapsed_time);
 			break;
-			/*
-			 * From RFC 4340, sec. 10.3:
-			 *
-			 *	Option numbers 128 through 191 are for
-			 *	options sent from the HC-Sender to the
-			 *	HC-Receiver; option numbers 192 through 255
-			 *	are for options sent from the HC-Receiver to
-			 *	the HC-Sender.
-			 */
 		case 128 ... 191: {
 			const u16 idx = value - options;
 
@@ -236,7 +248,7 @@ int dccp_parse_options(struct sock *sk, 
 				  "implemented, ignoring", sk, opt, len);
 			break;
 		}
-
+ignore_option:
 		if (opt != DCCPO_MANDATORY)
 			mandatory = 0;
 	}
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -290,7 +290,7 @@ int dccp_rcv_established(struct sock *sk
 	if (dccp_check_seqno(sk, skb))
 		goto discard;
 
-	if (dccp_parse_options(sk, skb))
+	if (dccp_parse_options(sk, NULL, skb))
 		goto discard;
 
 	if (DCCP_SKB_CB(skb)->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
@@ -348,7 +348,7 @@ static int dccp_rcv_request_sent_state_p
 			goto out_invalid_packet;
 		}
 
-		if (dccp_parse_options(sk, skb))
+		if (dccp_parse_options(sk, NULL, skb))
 			goto out_invalid_packet;
 
 		/* Obtain usec RTT sample from SYN exchange (used by CCID 3) */
@@ -530,7 +530,7 @@ int dccp_rcv_state_process(struct sock *
 		/*
 		 * Step 8: Process options and mark acknowledgeable
 		 */
-		if (dccp_parse_options(sk, skb))
+		if (dccp_parse_options(sk, NULL, skb))
 			goto discard;
 
 		if (dcb->dccpd_ack_seq != DCCP_PKT_WITHOUT_ACK_SEQ)
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -602,11 +602,12 @@ int dccp_v4_conn_request(struct sock *sk
 	if (req = NULL)
 		goto drop;
 
-	if (dccp_parse_options(sk, skb))
-		goto drop_and_free;
-
 	dccp_reqsk_init(req, skb);
 
+	dreq = dccp_rsk(req);
+	if (dccp_parse_options(sk, dreq, skb))
+		goto drop_and_free;
+
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
@@ -623,7 +624,6 @@ int dccp_v4_conn_request(struct sock *sk
 	 * In fact we defer setting S.GSR, S.SWL, S.SWH to
 	 * dccp_create_openreq_child.
 	 */
-	dreq = dccp_rsk(req);
 	dreq->dreq_isr	   = dcb->dccpd_seq;
 	dreq->dreq_iss	   = dccp_v4_init_sequence(skb);
 	dreq->dreq_service = service;
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -415,11 +415,12 @@ static int dccp_v6_conn_request(struct s
 	if (req = NULL)
 		goto drop;
 
-	if (dccp_parse_options(sk, skb))
-		goto drop_and_free;
-
 	dccp_reqsk_init(req, skb);
 
+	dreq = dccp_rsk(req);
+	if (dccp_parse_options(sk, dreq, skb))
+		goto drop_and_free;
+
 	if (security_inet_conn_request(sk, skb, req))
 		goto drop_and_free;
 
@@ -449,7 +450,6 @@ static int dccp_v6_conn_request(struct s
 	 *   In fact we defer setting S.GSR, S.SWL, S.SWH to
 	 *   dccp_create_openreq_child.
 	 */
-	dreq = dccp_rsk(req);
 	dreq->dreq_isr	   = dcb->dccpd_seq;
 	dreq->dreq_iss	   = dccp_v6_init_sequence(skb);
 	dreq->dreq_service = service;
