From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 21 Feb 2008 09:09:28 +0000
Subject: [PATCH 10/10] [ACKVEC]: Separate option parsing from CCID processing
Message-Id: <1203584968-8957-11-git-send-email-gerrit@erg.abdn.ac.uk>
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

The patch provides a new data structure and associated list housekeeping.

Only small changes were necessary to integrate with CCID-2: data structure
initialisation, adapt list traversal routine, and add call to the provided
cleanup routine.

The latter also lead to fixing the following BUG: CCID-2 so far ignored
Ack Vectors on all packets other than Ack/DataAck, which is incorrect,
since Ack Vectors can be present on any packet that has an Ack field.

Details:
--------
 * received Ack Vectors are parsed by dccp_parse_options() alone, which passes
   the result on to the CCID-specific routine ccid_hc_tx_parse_options();
 * CCIDs interested in using/decoding Ack Vector information will add code
   to fetch parsed Ack Vectors via this interface;
 * a data structure, `struct dccp_ackvec_parsed' is provided as interface;
 * this structure arranges Ack Vectors of the same skb into a FIFO order;
 * a doubly-linked list is used to keep the required FIFO code small.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c      |   28 ++++++++++
 net/dccp/ackvec.h      |   19 +++++++
 net/dccp/ccids/ccid2.c |  136 +++++++++++++++---------------------------------
 net/dccp/ccids/ccid2.h |    2 +
 net/dccp/options.c     |   17 ++++---
 5 files changed, 102 insertions(+), 100 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -112,4 +112,23 @@ static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
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
@@ -345,6 +345,34 @@ free_records:
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
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -135,13 +135,6 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 			if (rc)
 				goto out_invalid_option;
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
@@ -229,6 +222,16 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 						     value) != 0)
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
 						     opt, len, value - options,
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -47,6 +47,7 @@ struct ccid2_seq {
  * @ccid2hctx_lastrtt -time RTT was last measured
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
+ * @ccid2hctx_av_chunks: list of Ack Vectors received on current skb
 */
 struct ccid2_hc_tx_sock {
 	u32			ccid2hctx_cwnd;
@@ -66,6 +67,7 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_rpdupack;
 	unsigned long		ccid2hctx_last_cong;
 	u64			ccid2hctx_high_ack;
+	struct list_head	ccid2hctx_av_chunks;
 };
 
 struct ccid2_hc_rx_sock {
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -320,68 +320,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
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
 static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
@@ -502,15 +440,28 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 		ccid2_change_l_ack_ratio(sk, hctx->ccid2hctx_cwnd);
 }
 
+static int ccid2_hc_tx_parse_options(struct sock *sk, unsigned char option,
+				     unsigned char len, u16 idx,
+				     unsigned char *value)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+
+	switch (option) {
+	case DCCPO_ACK_VECTOR_0:
+	case DCCPO_ACK_VECTOR_1:
+		return dccp_ackvec_parsed_add(&hctx->ccid2hctx_av_chunks, value,
+					      len, option - DCCPO_ACK_VECTOR_0);
+	}
+	return 0;
+}
+
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct dccp_ackvec_parsed *avp;
 	u64 ackno, seqno;
 	struct ccid2_seq *seqp;
-	unsigned char *vector;
-	unsigned char veclen;
-	int offset = 0;
 	int done = 0;
 	unsigned int maxincr = 0;
 
@@ -545,17 +496,12 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* check forward path congestion */
-	/* still didn't send out new data packets */
-	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
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
+	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
+		goto done;
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	if (after48(ackno, hctx->ccid2hctx_high_ack))
@@ -579,15 +525,16 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
-	while ((offset = ccid2_ackvector(sk, skb, offset,
-					 &vector, &veclen)) != -1) {
+	list_for_each_entry(avp, &hctx->ccid2hctx_av_chunks, node) {
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
@@ -606,7 +553,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * run length
 			 */
 			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = dccp_ackvec_state(vector);
+				const u8 state = dccp_ackvec_state(avp->vec);
 
 				/* new packet received or marked */
 				if (state != DCCPAV_NOT_RECEIVED &&
@@ -633,7 +580,6 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				break;
 
 			ackno = SUB48(ackno_end_rl, 1);
-			vector++;
 		}
 		if (done)
 			break;
@@ -697,6 +643,8 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	ccid2_hc_tx_check_sanity(hctx);
+done:
+	dccp_ackvec_parsed_cleanup(&hctx->ccid2hctx_av_chunks);
 }
 
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
@@ -731,6 +679,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	hctx->ccid2hctx_last_cong = jiffies;
 	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
+	INIT_LIST_HEAD(&hctx->ccid2hctx_av_chunks);
 
 	ccid2_hc_tx_check_sanity(hctx);
 	return 0;
@@ -766,17 +715,18 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 }
 
 static struct ccid_operations ccid2 = {
-	.ccid_id		= DCCPC_CCID2,
-	.ccid_name		= "TCP-like",
-	.ccid_owner		= THIS_MODULE,
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
+	.ccid_owner		  = THIS_MODULE,
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
