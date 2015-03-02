From: Florian Westphal <fw@strlen.de>
Date: Mon, 02 Mar 2015 17:40:24 +0000
Subject: [PATCH RFC 10/14] dccp: keep failed options on stack
Message-Id: <1425318028-26531-11-git-send-email-fw@strlen.de>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_skb_cb uses all available skb->cb size.

To eventually reduce skb->cb we thus need to shrink the existing users.
Keeping this state (only needed in rare case of invalid option) on the
stack would reduce dccp_skb_cb by 4 bytes.  This change doesn't alter
dccp_skb_cb size due to padding; we'll remove the padding in next patch.

Cc: dccp@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/linux/dccp.h |  9 ++++++++-
 net/dccp/dccp.h      | 26 ++++++++++++++------------
 net/dccp/input.c     | 17 ++++++++++-------
 net/dccp/ipv4.c      | 29 +++++++++++++++++++----------
 net/dccp/ipv6.c      | 29 +++++++++++++++++++----------
 net/dccp/minisocks.c |  9 +++++----
 net/dccp/options.c   | 10 ++++++----
 net/dccp/output.c    | 29 ++++++++++++++++-------------
 8 files changed, 97 insertions(+), 61 deletions(-)

diff --git a/include/linux/dccp.h b/include/linux/dccp.h
index 439ff69..8806848 100644
--- a/include/linux/dccp.h
+++ b/include/linux/dccp.h
@@ -166,6 +166,13 @@ struct dccp_request_sock {
 	__u32			 dreq_timestamp_time;
 };
 
+/* dccp_reset_state - Temporary information for reset generation
+ * @dccpd_reset_data: Data1..3 fields (depend on @dccpd_reset_code)
+ */
+struct dccp_reset_state {
+	__u8 dccpd_reset_data[3];
+};
+
 static inline struct dccp_request_sock *dccp_rsk(const struct request_sock *req)
 {
 	return (struct dccp_request_sock *)req;
@@ -174,7 +181,7 @@ static inline struct dccp_request_sock *dccp_rsk(const struct request_sock *req)
 extern struct inet_timewait_death_row dccp_death_row;
 
 extern int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
-			      struct sk_buff *skb);
+			      struct sk_buff *skb, struct dccp_reset_state *rst);
 
 struct dccp_options_received {
 	u64	dccpor_ndp:48;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index e4c144f..520c566 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -281,14 +281,16 @@ struct sock *dccp_v4_request_recv_sock(struct sock *sk, struct sk_buff *skb,
 				       struct dst_entry *dst);
 struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			    struct request_sock *req,
-			    struct request_sock **prev);
+			    struct request_sock **prev,
+			    struct dccp_reset_state *rst);
 
 int dccp_child_process(struct sock *parent, struct sock *child,
-		       struct sk_buff *skb);
+		       struct sk_buff *skb, struct dccp_reset_state *rst);
 int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			   struct dccp_hdr *dh, unsigned int len);
+			   struct dccp_hdr *dh, unsigned int len, struct dccp_reset_state *rst);
 int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			 const struct dccp_hdr *dh, const unsigned int len);
+			 const struct dccp_hdr *dh, const unsigned int len,
+			 struct dccp_reset_state *rst);
 
 int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized);
 void dccp_destroy_sock(struct sock *sk);
@@ -321,7 +323,8 @@ unsigned int dccp_poll(struct file *file, struct socket *sock,
 		       poll_table *wait);
 int dccp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len);
 
-struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *skb);
+struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *skb,
+				    const struct dccp_reset_state *rst);
 int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code);
 void dccp_send_close(struct sock *sk, const int active);
 int dccp_invalid_packet(struct sk_buff *skb);
@@ -339,13 +342,12 @@ static inline int dccp_bad_service_code(const struct sock *sk,
 
 /**
  * dccp_skb_cb  -  DCCP per-packet control information
+ * @dccpd_seq: sequence number
+ * @dccpd_ack_seq: acknowledgment number subheader field value
  * @dccpd_type: one of %dccp_pkt_type (or unknown)
  * @dccpd_ccval: CCVal field (5.1), see e.g. RFC 4342, 8.1
  * @dccpd_reset_code: one of %dccp_reset_codes
- * @dccpd_reset_data: Data1..3 fields (depend on @dccpd_reset_code)
  * @dccpd_opt_len: total length of all options (5.8) in the packet
- * @dccpd_seq: sequence number
- * @dccpd_ack_seq: acknowledgment number subheader field value
  *
  * This is used for transmission as well as for reception.
  */
@@ -356,13 +358,13 @@ struct dccp_skb_cb {
 		struct inet6_skb_parm	h6;
 #endif
 	} header;
+	__u64 dccpd_seq;
+	__u64 dccpd_ack_seq;
+
 	__u8  dccpd_type:4;
 	__u8  dccpd_ccval:4;
-	__u8  dccpd_reset_code,
-	      dccpd_reset_data[3];
+	__u8  dccpd_reset_code;
 	__u16 dccpd_opt_len;
-	__u64 dccpd_seq;
-	__u64 dccpd_ack_seq;
 };
 
 #define DCCP_SKB_CB(__skb) ((struct dccp_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/dccp/input.c b/net/dccp/input.c
index 3bd14e8..8de7a37 100644
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -366,12 +366,13 @@ discard:
 }
 
 int dccp_rcv_established(struct sock *sk, struct sk_buff *skb,
-			 const struct dccp_hdr *dh, const unsigned int len)
+			 const struct dccp_hdr *dh, const unsigned int len,
+			 struct dccp_reset_state *rst)
 {
 	if (dccp_check_seqno(sk, skb))
 		goto discard;
 
-	if (dccp_parse_options(sk, NULL, skb))
+	if (dccp_parse_options(sk, NULL, skb, rst))
 		return 1;
 
 	dccp_handle_ackvec_processing(sk, skb);
@@ -388,7 +389,8 @@ EXPORT_SYMBOL_GPL(dccp_rcv_established);
 static int dccp_rcv_request_sent_state_process(struct sock *sk,
 					       struct sk_buff *skb,
 					       const struct dccp_hdr *dh,
-					       const unsigned int len)
+					       const unsigned int len,
+					       struct dccp_reset_state *rst)
 {
 	/*
 	 *  Step 4: Prepare sequence numbers in REQUEST
@@ -421,7 +423,7 @@ static int dccp_rcv_request_sent_state_process(struct sock *sk,
 		 * dccp_v4_do_rcv() sends a Reset. The Reset code depends on
 		 * the option type and is set in dccp_parse_options().
 		 */
-		if (dccp_parse_options(sk, NULL, skb))
+		if (dccp_parse_options(sk, NULL, skb, rst))
 			return 1;
 
 		/* Obtain usec RTT sample from SYN exchange (used by TFRC). */
@@ -572,7 +574,7 @@ static int dccp_rcv_respond_partopen_state_process(struct sock *sk,
 }
 
 int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
-			   struct dccp_hdr *dh, unsigned int len)
+			   struct dccp_hdr *dh, unsigned int len, struct dccp_reset_state *rst)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(skb);
@@ -641,7 +643,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 	}
 
 	/*  Step 8: Process options */
-	if (dccp_parse_options(sk, NULL, skb))
+	if (dccp_parse_options(sk, NULL, skb, rst))
 		return 1;
 
 	/*
@@ -667,7 +669,7 @@ int dccp_rcv_state_process(struct sock *sk, struct sk_buff *skb,
 
 	switch (sk->sk_state) {
 	case DCCP_REQUESTING:
-		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len);
+		queued = dccp_rcv_request_sent_state_process(sk, skb, dh, len, rst);
 		if (queued >= 0)
 			return queued;
 
@@ -716,6 +718,7 @@ EXPORT_SYMBOL_GPL(dccp_rcv_state_process);
  */
 u32 dccp_sample_rtt(struct sock *sk, long delta)
 {
+
 	/* dccpor_elapsed_time is either zeroed out or set and > 0 */
 	delta -= dccp_sk(sk)->dccps_options_received.dccpor_elapsed_time * 10;
 
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index e45b968..e908e27 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -444,7 +444,8 @@ put_and_exit:
 }
 EXPORT_SYMBOL_GPL(dccp_v4_request_recv_sock);
 
-static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
+static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb,
+				    struct dccp_reset_state *rst)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const struct iphdr *iph = ip_hdr(skb);
@@ -455,7 +456,7 @@ static struct sock *dccp_v4_hnd_req(struct sock *sk, struct sk_buff *skb)
 						       dh->dccph_sport,
 						       iph->saddr, iph->daddr);
 	if (req != NULL)
-		return dccp_check_req(sk, skb, req, prev);
+		return dccp_check_req(sk, skb, req, prev, rst);
 
 	nsk = inet_lookup_established(sock_net(sk), &dccp_hashinfo,
 				      iph->saddr, dh->dccph_sport,
@@ -527,7 +528,8 @@ out:
 	return err;
 }
 
-static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
+static void __dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb,
+				     const struct dccp_reset_state *rst)
 {
 	int err;
 	const struct iphdr *rxiph;
@@ -547,7 +549,7 @@ static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (dst = NULL)
 		return;
 
-	skb = dccp_ctl_make_reset(ctl_sk, rxskb);
+	skb = dccp_ctl_make_reset(ctl_sk, rxskb, rst);
 	if (skb = NULL)
 		goto out;
 
@@ -569,6 +571,11 @@ out:
 	 dst_release(dst);
 }
 
+static void dccp_v4_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
+{
+	__dccp_v4_ctl_send_reset(sk, rxskb, NULL);
+}
+
 static void dccp_v4_reqsk_destructor(struct request_sock *req)
 {
 	dccp_feat_list_purge(&dccp_rsk(req)->dreq_featneg);
@@ -632,7 +639,7 @@ int dccp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	dreq = dccp_rsk(req);
-	if (dccp_parse_options(sk, dreq, skb))
+	if (dccp_parse_options(sk, dreq, skb, NULL))
 		goto drop_and_free;
 
 	if (security_inet_conn_request(sk, skb, req))
@@ -672,9 +679,10 @@ EXPORT_SYMBOL_GPL(dccp_v4_conn_request);
 int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_hdr *dh = dccp_hdr(skb);
+	struct dccp_reset_state reset_state = {};
 
 	if (sk->sk_state = DCCP_OPEN) { /* Fast path */
-		if (dccp_rcv_established(sk, skb, dh, skb->len))
+		if (dccp_rcv_established(sk, skb, dh, skb->len, &reset_state))
 			goto reset;
 		return 0;
 	}
@@ -703,24 +711,24 @@ int dccp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 	 *	 dccp_rcv_state_process
 	 */
 	if (sk->sk_state = DCCP_LISTEN) {
-		struct sock *nsk = dccp_v4_hnd_req(sk, skb);
+		struct sock *nsk = dccp_v4_hnd_req(sk, skb, &reset_state);
 
 		if (nsk = NULL)
 			goto discard;
 
 		if (nsk != sk) {
-			if (dccp_child_process(sk, nsk, skb))
+			if (dccp_child_process(sk, nsk, skb, &reset_state))
 				goto reset;
 			return 0;
 		}
 	}
 
-	if (dccp_rcv_state_process(sk, skb, dh, skb->len))
+	if (dccp_rcv_state_process(sk, skb, dh, skb->len, &reset_state))
 		goto reset;
 	return 0;
 
 reset:
-	dccp_v4_ctl_send_reset(sk, skb);
+	__dccp_v4_ctl_send_reset(sk, skb, &reset_state);
 discard:
 	kfree_skb(skb);
 	return 0;
@@ -898,6 +906,7 @@ no_dccp_socket:
 	if (dh->dccph_type != DCCP_PKT_RESET) {
 		DCCP_SKB_CB(skb)->dccpd_reset_code  					DCCP_RESET_CODE_NO_CONNECTION;
+
 		dccp_v4_ctl_send_reset(sk, skb);
 	}
 
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 6bcaa33..980f103 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -270,7 +270,8 @@ static void dccp_v6_reqsk_destructor(struct request_sock *req)
 	kfree_skb(inet_rsk(req)->pktopts);
 }
 
-static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
+static void __dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb,
+				     const struct dccp_reset_state *rst)
 {
 	const struct ipv6hdr *rxip6h;
 	struct sk_buff *skb;
@@ -285,7 +286,7 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	if (!ipv6_unicast_destination(rxskb))
 		return;
 
-	skb = dccp_ctl_make_reset(ctl_sk, rxskb);
+	skb = dccp_ctl_make_reset(ctl_sk, rxskb, rst);
 	if (skb = NULL)
 		return;
 
@@ -316,6 +317,11 @@ static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
 	kfree_skb(skb);
 }
 
+static void dccp_v6_ctl_send_reset(struct sock *sk, struct sk_buff *rxskb)
+{
+	__dccp_v6_ctl_send_reset(sk, rxskb, NULL);
+}
+
 static struct request_sock_ops dccp6_request_sock_ops = {
 	.family		= AF_INET6,
 	.obj_size	= sizeof(struct dccp6_request_sock),
@@ -326,7 +332,8 @@ static struct request_sock_ops dccp6_request_sock_ops = {
 	.syn_ack_timeout = dccp_syn_ack_timeout,
 };
 
-static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
+static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb,
+				    struct dccp_reset_state *rst)
 {
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
@@ -339,7 +346,7 @@ static struct sock *dccp_v6_hnd_req(struct sock *sk,struct sk_buff *skb)
 							&iph->daddr,
 							inet6_iif(skb));
 	if (req != NULL)
-		return dccp_check_req(sk, skb, req, prev);
+		return dccp_check_req(sk, skb, req, prev, rst);
 
 	nsk = __inet6_lookup_established(sock_net(sk), &dccp_hashinfo,
 					 &iph->saddr, dh->dccph_sport,
@@ -394,7 +401,7 @@ static int dccp_v6_conn_request(struct sock *sk, struct sk_buff *skb)
 		goto drop_and_free;
 
 	dreq = dccp_rsk(req);
-	if (dccp_parse_options(sk, dreq, skb))
+	if (dccp_parse_options(sk, dreq, skb, NULL))
 		goto drop_and_free;
 
 	if (security_inet_conn_request(sk, skb, req))
@@ -616,6 +623,7 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sk_buff *opt_skb = NULL;
+	struct dccp_reset_state reset_state = {};
 
 	/* Imagine: socket is IPv6. IPv4 packet arrives,
 	   goes to IPv4 receive handler and backlogged.
@@ -657,7 +665,7 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		opt_skb = skb_clone(skb, GFP_ATOMIC);
 
 	if (sk->sk_state = DCCP_OPEN) { /* Fast path */
-		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
+		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len, &reset_state))
 			goto reset;
 		if (opt_skb) {
 			/* XXX This is where we would goto ipv6_pktoptions. */
@@ -691,7 +699,7 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	 *	 dccp_rcv_state_process
 	 */
 	if (sk->sk_state = DCCP_LISTEN) {
-		struct sock *nsk = dccp_v6_hnd_req(sk, skb);
+		struct sock *nsk = dccp_v6_hnd_req(sk, skb, &reset_state);
 
 		if (nsk = NULL)
 			goto discard;
@@ -701,7 +709,7 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		 * the new socket..
 		 */
 		if (nsk != sk) {
-			if (dccp_child_process(sk, nsk, skb))
+			if (dccp_child_process(sk, nsk, skb, &reset_state))
 				goto reset;
 			if (opt_skb != NULL)
 				__kfree_skb(opt_skb);
@@ -709,7 +717,8 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	if (dccp_rcv_state_process(sk, skb, dccp_hdr(skb), skb->len))
+	if (dccp_rcv_state_process(sk, skb, dccp_hdr(skb), skb->len,
+				   &reset_state))
 		goto reset;
 	if (opt_skb) {
 		/* XXX This is where we would goto ipv6_pktoptions. */
@@ -718,7 +727,7 @@ static int dccp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 	return 0;
 
 reset:
-	dccp_v6_ctl_send_reset(sk, skb);
+	__dccp_v6_ctl_send_reset(sk, skb, &reset_state);
 discard:
 	if (opt_skb != NULL)
 		__kfree_skb(opt_skb);
diff --git a/net/dccp/minisocks.c b/net/dccp/minisocks.c
index b50dc43..7dc5fe3 100644
--- a/net/dccp/minisocks.c
+++ b/net/dccp/minisocks.c
@@ -153,7 +153,8 @@ EXPORT_SYMBOL_GPL(dccp_create_openreq_child);
  */
 struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 			    struct request_sock *req,
-			    struct request_sock **prev)
+			    struct request_sock **prev,
+			    struct dccp_reset_state *rst)
 {
 	struct sock *child = NULL;
 	struct dccp_request_sock *dreq = dccp_rsk(req);
@@ -193,7 +194,7 @@ struct sock *dccp_check_req(struct sock *sk, struct sk_buff *skb,
 		goto drop;
 	}
 
-	if (dccp_parse_options(sk, dreq, skb))
+	if (dccp_parse_options(sk, dreq, skb, rst))
 		 goto drop;
 
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
@@ -224,14 +225,14 @@ EXPORT_SYMBOL_GPL(dccp_check_req);
  *  the new socket.
  */
 int dccp_child_process(struct sock *parent, struct sock *child,
-		       struct sk_buff *skb)
+		       struct sk_buff *skb, struct dccp_reset_state *rst)
 {
 	int ret = 0;
 	const int state = child->sk_state;
 
 	if (!sock_owned_by_user(child)) {
 		ret = dccp_rcv_state_process(child, skb, dccp_hdr(skb),
-					     skb->len);
+					     skb->len, rst);
 
 		/* Wakeup parent, send SIGIO */
 		if (state = DCCP_RESPOND && child->sk_state != state)
diff --git a/net/dccp/options.c b/net/dccp/options.c
index 9bce318..7848fbf 100644
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -49,7 +49,7 @@ u64 dccp_decode_value_var(const u8 *bf, const u8 len)
  * @dreq: request socket to use during connection setup, or NULL
  */
 int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
-		       struct sk_buff *skb)
+		       struct sk_buff *skb, struct dccp_reset_state *rst)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	const struct dccp_hdr *dh = dccp_hdr(skb);
@@ -258,9 +258,11 @@ out_invalid_option:
 out_featneg_failed:
 	DCCP_WARN("DCCP(%p): Option %d (len=%d) error=%u\n", sk, opt, len, rc);
 	DCCP_SKB_CB(skb)->dccpd_reset_code = rc;
-	DCCP_SKB_CB(skb)->dccpd_reset_data[0] = opt;
-	DCCP_SKB_CB(skb)->dccpd_reset_data[1] = len > 0 ? value[0] : 0;
-	DCCP_SKB_CB(skb)->dccpd_reset_data[2] = len > 1 ? value[1] : 0;
+	if (rst) {
+		rst->dccpd_reset_data[0] = opt;
+		rst->dccpd_reset_data[1] = len > 0 ? value[0] : 0;
+		rst->dccpd_reset_data[2] = len > 1 ? value[1] : 0;
+	}
 	return -1;
 }
 
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 0248e8a..f00cdf3 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -42,7 +42,8 @@ static struct sk_buff *dccp_skb_entail(struct sock *sk, struct sk_buff *skb)
  * IP so it can do the same plus pass the packet off to the
  * device.
  */
-static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
+static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb,
+			     enum dccp_reset_codes reset_code)
 {
 	if (likely(skb != NULL)) {
 		struct inet_sock *inet = inet_sk(sk);
@@ -126,8 +127,7 @@ static int dccp_transmit_skb(struct sock *sk, struct sk_buff *skb)
 			dp->dccps_awl = dp->dccps_iss;
 			break;
 		case DCCP_PKT_RESET:
-			dccp_hdr_reset(skb)->dccph_reset_code -							dcb->dccpd_reset_code;
+			dccp_hdr_reset(skb)->dccph_reset_code = reset_code;
 			break;
 		}
 
@@ -277,7 +277,7 @@ static void dccp_xmit_packet(struct sock *sk)
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATA;
 	}
 
-	err = dccp_transmit_skb(sk, skb);
+	err = dccp_transmit_skb(sk, skb, 0);
 	if (err)
 		dccp_pr_debug("transmit_skb() returned err=%d\n", err);
 	/*
@@ -387,7 +387,7 @@ int dccp_retransmit_skb(struct sock *sk)
 	/* this count is used to distinguish original and retransmitted skb */
 	inet_csk(sk)->icsk_retransmits++;
 
-	return dccp_transmit_skb(sk, skb_clone(sk->sk_send_head, GFP_ATOMIC));
+	return dccp_transmit_skb(sk, skb_clone(sk->sk_send_head, GFP_ATOMIC), 0);
 }
 
 struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
@@ -448,7 +448,8 @@ response_failed:
 EXPORT_SYMBOL_GPL(dccp_make_response);
 
 /* answer offending packet in @rcv_skb with Reset from control socket @ctl */
-struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *rcv_skb)
+struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *rcv_skb,
+				    const struct dccp_reset_state *rst)
 {
 	struct dccp_hdr *rxdh = dccp_hdr(rcv_skb), *dh;
 	struct dccp_skb_cb *dcb = DCCP_SKB_CB(rcv_skb);
@@ -481,7 +482,10 @@ struct sk_buff *dccp_ctl_make_reset(struct sock *sk, struct sk_buff *rcv_skb)
 		break;
 	case DCCP_RESET_CODE_OPTION_ERROR:	/* fall through */
 	case DCCP_RESET_CODE_MANDATORY_ERROR:
-		memcpy(dhr->dccph_reset_data, dcb->dccpd_reset_data, 3);
+		BUILD_BUG_ON(sizeof(dhr->dccph_reset_data) != sizeof(rst->dccpd_reset_data));
+		if (rst)
+			memcpy(dhr->dccph_reset_data, rst->dccpd_reset_data,
+					sizeof(dhr->dccph_reset_data));
 		break;
 	}
 	/*
@@ -519,9 +523,8 @@ int dccp_send_reset(struct sock *sk, enum dccp_reset_codes code)
 	/* Reserve space for headers and prepare control bits. */
 	skb_reserve(skb, sk->sk_prot->max_header);
 	DCCP_SKB_CB(skb)->dccpd_type	   = DCCP_PKT_RESET;
-	DCCP_SKB_CB(skb)->dccpd_reset_code = code;
 
-	return dccp_transmit_skb(sk, skb);
+	return dccp_transmit_skb(sk, skb, code);
 }
 
 /*
@@ -555,7 +558,7 @@ int dccp_connect(struct sock *sk)
 
 	DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_REQUEST;
 
-	dccp_transmit_skb(sk, dccp_skb_entail(sk, skb));
+	dccp_transmit_skb(sk, dccp_skb_entail(sk, skb), 0);
 	DCCP_INC_STATS(DCCP_MIB_ACTIVEOPENS);
 
 	/* Timer for repeating the REQUEST until an answer. */
@@ -586,7 +589,7 @@ void dccp_send_ack(struct sock *sk)
 		/* Reserve space for headers */
 		skb_reserve(skb, sk->sk_prot->max_header);
 		DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK;
-		dccp_transmit_skb(sk, skb);
+		dccp_transmit_skb(sk, skb, 0);
 	}
 }
 
@@ -652,7 +655,7 @@ void dccp_send_sync(struct sock *sk, const u64 ackno,
 	 */
 	dccp_sk(sk)->dccps_sync_scheduled = 0;
 
-	dccp_transmit_skb(sk, skb);
+	dccp_transmit_skb(sk, skb, 0);
 }
 
 EXPORT_SYMBOL_GPL(dccp_send_sync);
@@ -694,5 +697,5 @@ void dccp_send_close(struct sock *sk, const int active)
 		inet_csk_reset_xmit_timer(sk, ICSK_TIME_RETRANS,
 					  DCCP_TIMEOUT_INIT, DCCP_RTO_MAX);
 	}
-	dccp_transmit_skb(sk, skb);
+	dccp_transmit_skb(sk, skb, 0);
 }
-- 
2.0.5

