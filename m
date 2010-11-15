From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Nov 2010 06:29:07 +0000
Subject: [PATCH 6/6] dccp ccid-2: Separate option parsing from CCID processing
Message-Id: <1289802547-5617-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch replaces an almost identical replication of code: large parts
of dccp_parse_options() re-appeared as ccid2_ackvector() in ccid2.c.

Apart from the duplication, this caused two more problems:
 1. CCIDs should not need to be concerned with parsing header options;
 2. one can not assume that Ack Vectors appear as a contiguous area within an
    skb, it is legal to insert other options and/or padding in between. The
    current code would throw an error and stop reading in such a case.

Since Ack Vectors provide CCID-specific information, they are now processed
by the CCID directly, separating this functionality from the main DCCP code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/options.c     |   17 ++++---
 net/dccp/ackvec.h      |   19 +++++++
 net/dccp/ackvec.c      |   28 ++++++++++
 net/dccp/ccids/ccid2.c |  134 +++++++++++++++---------------------------------
 net/dccp/ccids/ccid2.h |    2 +
 5 files changed, 100 insertions(+), 100 deletions(-)

--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -128,13 +128,6 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			if (rc)
 				goto out_featneg_failed;
 			break;
-		case DCCPO_ACK_VECTOR_0:
-		case DCCPO_ACK_VECTOR_1:
-			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
-				break;
-			dccp_pr_debug("%s Ack Vector (len=%u)\n", dccp_role(sk),
-				      len);
-			break;
 		case DCCPO_TIMESTAMP:
 			if (len != 4)
 				goto out_invalid_option;
@@ -224,6 +217,16 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 						     pkt_type, opt, value, len))
 				goto out_invalid_option;
 			break;
+		case DCCPO_ACK_VECTOR_0:
+		case DCCPO_ACK_VECTOR_1:
+			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
+				break;
+			/*
+			 * Ack vectors are processed by the TX CCID if it is
+			 * interested. The RX CCID need not parse Ack Vectors,
+			 * since it is only interested in clearing old state.
+			 * Fall through.
+			 */
 		case DCCPO_MIN_TX_CCID_SPECIFIC ... DCCPO_MAX_TX_CCID_SPECIFIC:
 			if (ccid_hc_tx_parse_options(dp->dccps_hc_tx_ccid, sk,
 						     pkt_type, opt, value, len))
--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -114,4 +114,23 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
 {
 	return av->av_overflow = 0 && av->av_buf_head = av->av_buf_tail;
 }
+
+/**
+ * struct dccp_ackvec_parsed  -  Record offsets of Ack Vectors in skb
+ * @vec:	start of vector (offset into skb)
+ * @len:	length of @vec
+ * @nonce:	whether @vec had an ECN nonce of 0 or 1
+ * @node:	FIFO - arranged in descending order of ack_ackno
+ * This structure is used by CCIDs to access Ack Vectors in a received skb.
+ */
+struct dccp_ackvec_parsed {
+	u8		 *vec,
+			 len,
+			 nonce:1;
+	struct list_head node;
+};
+
+extern int dccp_ackvec_parsed_add(struct list_head *head,
+				  u8 *vec, u8 len, u8 nonce);
+extern void dccp_ackvec_parsed_cleanup(struct list_head *parsed_chunks);
 #endif /* _ACKVEC_H */
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -343,6 +343,34 @@ free_records:
 	}
 }
 
+/*
+ *	Routines to keep track of Ack Vectors received in an skb
+ */
+int dccp_ackvec_parsed_add(struct list_head *head, u8 *vec, u8 len, u8 nonce)
+{
+	struct dccp_ackvec_parsed *new = kmalloc(sizeof(*new), GFP_ATOMIC);
+
+	if (new = NULL)
+		return -ENOBUFS;
+	new->vec   = vec;
+	new->len   = len;
+	new->nonce = nonce;
+
+	list_add_tail(&new->node, head);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(dccp_ackvec_parsed_add);
+
+void dccp_ackvec_parsed_cleanup(struct list_head *parsed_chunks)
+{
+	struct dccp_ackvec_parsed *cur, *next;
+
+	list_for_each_entry_safe(cur, next, parsed_chunks, node)
+		kfree(cur);
+	INIT_LIST_HEAD(parsed_chunks);
+}
+EXPORT_SYMBOL_GPL(dccp_ackvec_parsed_cleanup);
+
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -55,6 +55,7 @@ struct ccid2_seq {
  * @tx_rtt_seq:		     to decay RTTVAR at most once per flight
  * @tx_rpseq:		     last consecutive seqno
  * @tx_rpdupack:	     dupacks since rpseq
+ * @tx_av_chunks:	     list of Ack Vectors received on current skb
  */
 struct ccid2_hc_tx_sock {
 	u32			tx_cwnd;
@@ -79,6 +80,7 @@ struct ccid2_hc_tx_sock {
 	int			tx_rpdupack;
 	u32			tx_last_cong;
 	u64			tx_high_ack;
+	struct list_head	tx_av_chunks;
 };
 
 static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hc)
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -246,68 +246,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 #endif
 }
 
-/* XXX Lame code duplication!
- * returns -1 if none was found.
- * else returns the next offset to use in the function call.
- */
-static int ccid2_ackvector(struct sock *sk, struct sk_buff *skb, int offset,
-			   unsigned char **vec, unsigned char *veclen)
-{
-	const struct dccp_hdr *dh = dccp_hdr(skb);
-	unsigned char *options = (unsigned char *)dh + dccp_hdr_len(skb);
-	unsigned char *opt_ptr;
-	const unsigned char *opt_end = (unsigned char *)dh +
-					(dh->dccph_doff * 4);
-	unsigned char opt, len;
-	unsigned char *value;
-
-	BUG_ON(offset < 0);
-	options += offset;
-	opt_ptr = options;
-	if (opt_ptr >= opt_end)
-		return -1;
-
-	while (opt_ptr != opt_end) {
-		opt   = *opt_ptr++;
-		len   = 0;
-		value = NULL;
-
-		/* Check if this isn't a single byte option */
-		if (opt > DCCPO_MAX_RESERVED) {
-			if (opt_ptr = opt_end)
-				goto out_invalid_option;
-
-			len = *opt_ptr++;
-			if (len < 3)
-				goto out_invalid_option;
-			/*
-			 * Remove the type and len fields, leaving
-			 * just the value size
-			 */
-			len     -= 2;
-			value   = opt_ptr;
-			opt_ptr += len;
-
-			if (opt_ptr > opt_end)
-				goto out_invalid_option;
-		}
-
-		switch (opt) {
-		case DCCPO_ACK_VECTOR_0:
-		case DCCPO_ACK_VECTOR_1:
-			*vec	= value;
-			*veclen = len;
-			return offset + (opt_ptr - options);
-		}
-	}
-
-	return -1;
-
-out_invalid_option:
-	DCCP_BUG("Invalid option - this should not happen (previous parsing)!");
-	return -1;
-}
-
 /**
  * ccid2_rtt_estimator - Sample RTT and compute RTO using RFC2988 algorithm
  * This code is almost identical with TCP's tcp_rtt_estimator(), since
@@ -432,16 +370,28 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd);
 }
 
+static int ccid2_hc_tx_parse_options(struct sock *sk, u8 packet_type,
+				     u8 option, u8 *optval, u8 optlen)
+{
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+
+	switch (option) {
+	case DCCPO_ACK_VECTOR_0:
+	case DCCPO_ACK_VECTOR_1:
+		return dccp_ackvec_parsed_add(&hc->tx_av_chunks, optval, optlen,
+					      option - DCCPO_ACK_VECTOR_0);
+	}
+	return 0;
+}
+
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	const bool sender_was_blocked = ccid2_cwnd_network_limited(hc);
+	struct dccp_ackvec_parsed *avp;
 	u64 ackno, seqno;
 	struct ccid2_seq *seqp;
-	unsigned char *vector;
-	unsigned char veclen;
-	int offset = 0;
 	int done = 0;
 	unsigned int maxincr = 0;
 
@@ -475,17 +425,12 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* check forward path congestion */
-	/* still didn't send out new data packets */
-	if (hc->tx_seqh = hc->tx_seqt)
+	if (dccp_packet_without_ack(skb))
 		return;
 
-	switch (DCCP_SKB_CB(skb)->dccpd_type) {
-	case DCCP_PKT_ACK:
-	case DCCP_PKT_DATAACK:
-		break;
-	default:
-		return;
-	}
+	/* still didn't send out new data packets */
+	if (hc->tx_seqh = hc->tx_seqt)
+		goto done;
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	if (after48(ackno, hc->tx_high_ack))
@@ -509,15 +454,16 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
-	while ((offset = ccid2_ackvector(sk, skb, offset,
-					 &vector, &veclen)) != -1) {
+	list_for_each_entry(avp, &hc->tx_av_chunks, node) {
 		/* go through this ack vector */
-		while (veclen--) {
-			u64 ackno_end_rl = SUB48(ackno, dccp_ackvec_runlen(vector));
+		for (; avp->len--; avp->vec++) {
+			u64 ackno_end_rl = SUB48(ackno,
+						 dccp_ackvec_runlen(avp->vec));
 
-			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
+			ccid2_pr_debug("ackvec %llu |%u,%u|\n",
 				       (unsigned long long)ackno,
-				       (unsigned long long)ackno_end_rl);
+				       dccp_ackvec_state(avp->vec) >> 6,
+				       dccp_ackvec_runlen(avp->vec));
 			/* if the seqno we are analyzing is larger than the
 			 * current ackno, then move towards the tail of our
 			 * seqnos.
@@ -536,7 +482,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * run length
 			 */
 			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = dccp_ackvec_state(vector);
+				const u8 state = dccp_ackvec_state(avp->vec);
 
 				/* new packet received or marked */
 				if (state != DCCPAV_NOT_RECEIVED &&
@@ -563,7 +509,6 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				break;
 
 			ackno = SUB48(ackno_end_rl, 1);
-			vector++;
 		}
 		if (done)
 			break;
@@ -631,10 +576,11 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		sk_stop_timer(sk, &hc->tx_rtotimer);
 	else
 		sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
-
+done:
 	/* check if incoming Acks allow pending packets to be sent */
 	if (sender_was_blocked && !ccid2_cwnd_network_limited(hc))
 		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
+	dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
 }
 
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
@@ -663,6 +609,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	hc->tx_last_cong = ccid2_time_stamp;
 	setup_timer(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
+	INIT_LIST_HEAD(&hc->tx_av_chunks);
 	return 0;
 }
 
@@ -696,16 +643,17 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 }
 
 struct ccid_operations ccid2_ops = {
-	.ccid_id		= DCCPC_CCID2,
-	.ccid_name		= "TCP-like",
-	.ccid_hc_tx_obj_size	= sizeof(struct ccid2_hc_tx_sock),
-	.ccid_hc_tx_init	= ccid2_hc_tx_init,
-	.ccid_hc_tx_exit	= ccid2_hc_tx_exit,
-	.ccid_hc_tx_send_packet	= ccid2_hc_tx_send_packet,
-	.ccid_hc_tx_packet_sent	= ccid2_hc_tx_packet_sent,
-	.ccid_hc_tx_packet_recv	= ccid2_hc_tx_packet_recv,
-	.ccid_hc_rx_obj_size	= sizeof(struct ccid2_hc_rx_sock),
-	.ccid_hc_rx_packet_recv	= ccid2_hc_rx_packet_recv,
+	.ccid_id		  = DCCPC_CCID2,
+	.ccid_name		  = "TCP-like",
+	.ccid_hc_tx_obj_size	  = sizeof(struct ccid2_hc_tx_sock),
+	.ccid_hc_tx_init	  = ccid2_hc_tx_init,
+	.ccid_hc_tx_exit	  = ccid2_hc_tx_exit,
+	.ccid_hc_tx_send_packet	  = ccid2_hc_tx_send_packet,
+	.ccid_hc_tx_packet_sent	  = ccid2_hc_tx_packet_sent,
+	.ccid_hc_tx_parse_options = ccid2_hc_tx_parse_options,
+	.ccid_hc_tx_packet_recv	  = ccid2_hc_tx_packet_recv,
+	.ccid_hc_rx_obj_size	  = sizeof(struct ccid2_hc_rx_sock),
+	.ccid_hc_rx_packet_recv	  = ccid2_hc_rx_packet_recv,
 };
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
