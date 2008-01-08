From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 08 Jan 2008 14:07:56 +0000
Subject: [PATCH 3/3] [CCID2]: Add option-parsing code to process Ack Vectors at the HC-sender
Message-Id: <1199801276-16955-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is patch 2 in the set and uses the routines provided by the previous
patch to implement parsing of received Ack Vectors, replacing duplicate code.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |  132 ++++++++++++++++--------------------------------
 net/dccp/ccids/ccid2.h |    2 +
 2 files changed, 46 insertions(+), 88 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -47,6 +47,7 @@ struct ccid2_seq {
  * @ccid2hctx_lastrtt -time RTT was last measured
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
+ * @ccid2hctx_parsed_ackvecs: list of Ack Vectors received on current skb
 */
 struct ccid2_hc_tx_sock {
 	u32			ccid2hctx_cwnd;
@@ -66,6 +67,7 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_rpdupack;
 	unsigned long		ccid2hctx_last_cong;
 	u64			ccid2hctx_high_ack;
+	struct list_head	ccid2hctx_parsed_ackvecs;
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
@@ -502,15 +440,30 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
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
+		return dccp_ackvec_parsed_add(&hctx->ccid2hctx_parsed_ackvecs,
+					      value, len, 0);
+	case DCCPO_ACK_VECTOR_1:
+		return dccp_ackvec_parsed_add(&hctx->ccid2hctx_parsed_ackvecs,
+					      value, len, 1);
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
 
@@ -545,13 +498,13 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	/* check forward path congestion */
-	/* still didn't send out new data packets */
-	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
-		return;
-
 	if (dccp_packet_without_ack(skb))
 		return;
 
+	/* still didn't send out new data packets */
+	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
+		goto done;
+
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	if (after48(ackno, hctx->ccid2hctx_high_ack))
 		hctx->ccid2hctx_high_ack = ackno;
@@ -574,16 +527,16 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
-	while ((offset = ccid2_ackvector(sk, skb, offset,
-					 &vector, &veclen)) != -1) {
+	list_for_each_entry(avp, &hctx->ccid2hctx_parsed_ackvecs, node) {
 		/* go through this ack vector */
-		while (veclen--) {
+		for (; avp->len--; avp->vec++) {
 			u64 ackno_end_rl = SUB48(ackno,
-						 dccp_ackvec_runlen(vector));
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
@@ -602,7 +555,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * run length
 			 */
 			while (between48(seqp->ccid2s_seq,ackno_end_rl,ackno)) {
-				const u8 state = dccp_ackvec_state(vector);
+				const u8 state = dccp_ackvec_state(avp->vec);
 
 				/* new packet received or marked */
 				if (state != DCCPAV_NOT_RECEIVED &&
@@ -629,7 +582,6 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				break;
 
 			ackno = SUB48(ackno_end_rl, 1);
-			vector++;
 		}
 		if (done)
 			break;
@@ -693,6 +645,8 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	ccid2_hc_tx_check_sanity(hctx);
+done:
+	dccp_ackvec_parsed_cleanup(&hctx->ccid2hctx_parsed_ackvecs);
 }
 
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
@@ -727,6 +681,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	hctx->ccid2hctx_last_cong = jiffies;
 	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
+	INIT_LIST_HEAD(&hctx->ccid2hctx_parsed_ackvecs);
 
 	ccid2_hc_tx_check_sanity(hctx);
 	return 0;
@@ -762,17 +717,18 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
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
