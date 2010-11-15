From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 15 Nov 2010 06:29:02 +0000
Subject: [PATCH 1/6] dccp ccid-2: Algorithm to update buffer state
Message-Id: <1289802547-5617-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This provides a routine to consistently update the buffer state when the
peer acknowledges receipt of Ack Vectors; updating state in the list of Ack
Vectors as well as in the circular buffer.

While based on RFC 4340, several additional (and necessary) precautions were
added to protect the consistency of the buffer state. These additions are
essential, since analysis and experience showed that the basic algorithm was
insufficient for this task (which lead to problems that were hard to debug).

The algorithm now
 * deals with HC-sender acknowledging to HC-receiver and vice versa,
 * keeps track of the last unacknowledged but received seqno in tail_ackno,
 * has special cases to reset the overflow condition when appropriate,
 * is protected against receiving older information (would mess up buffer state).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.h  |    1 +
 net/dccp/ackvec.c  |   88 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/dccp/input.c   |    4 +-
 net/dccp/options.c |    6 +--
 4 files changed, 93 insertions(+), 6 deletions(-)

--- a/net/dccp/ackvec.h
+++ b/net/dccp/ackvec.h
@@ -117,6 +117,7 @@ extern int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 			     const u8 *value, const u8 len);
 
 extern int  dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seq, u8 sum);
+extern void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno);
 extern u16  dccp_ackvec_buflen(const struct dccp_ackvec *av);
 
 static inline bool dccp_ackvec_is_empty(const struct dccp_ackvec *av)
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -92,6 +92,24 @@ int dccp_ackvec_update_records(struct dccp_ackvec *av, u64 seqno, u8 nonce_sum)
 	return 0;
 }
 
+static struct dccp_ackvec_record *dccp_ackvec_lookup(struct list_head *av_list,
+						     const u64 ackno)
+{
+	struct dccp_ackvec_record *avr;
+	/*
+	 * Exploit that records are inserted in descending order of sequence
+	 * number, start with the oldest record first. If @ackno is `before'
+	 * the earliest ack_ackno, the packet is too old to be considered.
+	 */
+	list_for_each_entry_reverse(avr, av_list, avr_node) {
+		if (avr->avr_ack_seqno = ackno)
+			return avr;
+		if (before48(ackno, avr->avr_ack_seqno))
+			break;
+	}
+	return NULL;
+}
+
 /*
  * Buffer index and length computation using modulo-buffersize arithmetic.
  * Note that, as pointers move from right to left, head is `before' tail.
@@ -356,6 +374,76 @@ int dccp_ackvec_parse(struct sock *sk, const struct sk_buff *skb,
 	return 0;
 }
 
+/**
+ * dccp_ackvec_clear_state  -  Perform house-keeping / garbage-collection
+ * This routine is called when the peer acknowledges the receipt of Ack Vectors
+ * up to and including @ackno. While based on on section A.3 of RFC 4340, here
+ * are additional precautions to prevent corrupted buffer state. In particular,
+ * we use tail_ackno to identify outdated records; it always marks the earliest
+ * packet of group (2) in 11.4.2.
+ */
+void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
+ {
+	struct dccp_ackvec_record *avr, *next;
+	u8 runlen_now, eff_runlen;
+	s64 delta;
+
+	avr = dccp_ackvec_lookup(&av->av_records, ackno);
+	if (avr = NULL)
+		return;
+	/*
+	 * Deal with outdated acknowledgments: this arises when e.g. there are
+	 * several old records and the acks from the peer come in slowly. In
+	 * that case we may still have records that pre-date tail_ackno.
+	 */
+	delta = dccp_delta_seqno(av->av_tail_ackno, avr->avr_ack_ackno);
+	if (delta < 0)
+		goto free_records;
+	/*
+	 * Deal with overlapping Ack Vectors: don't subtract more than the
+	 * number of packets between tail_ackno and ack_ackno.
+	 */
+	eff_runlen = delta < avr->avr_ack_runlen ? delta : avr->avr_ack_runlen;
+
+	runlen_now = dccp_ackvec_runlen(av->av_buf + avr->avr_ack_ptr);
+	/*
+	 * The run length of Ack Vector cells does not decrease over time. If
+	 * the run length is the same as at the time the Ack Vector was sent, we
+	 * free the ack_ptr cell. That cell can however not be freed if the run
+	 * length has increased: in this case we need to move the tail pointer
+	 * backwards (towards higher indices), to its next-oldest neighbour.
+	 */
+	if (runlen_now > eff_runlen) {
+
+		av->av_buf[avr->avr_ack_ptr] -= eff_runlen + 1;
+		av->av_buf_tail = __ackvec_idx_add(avr->avr_ack_ptr, 1);
+
+		/* This move may not have cleared the overflow flag. */
+		if (av->av_overflow)
+			av->av_overflow = (av->av_buf_head = av->av_buf_tail);
+	} else {
+		av->av_buf_tail	= avr->avr_ack_ptr;
+		/*
+		 * We have made sure that avr points to a valid cell within the
+		 * buffer. This cell is either older than head, or equals head
+		 * (empty buffer): in both cases we no longer have any overflow.
+		 */
+		av->av_overflow	= 0;
+	}
+
+	/*
+	 * The peer has acknowledged up to and including ack_ackno. Hence the
+	 * first packet in group (2) of 11.4.2 is the successor of ack_ackno.
+	 */
+	av->av_tail_ackno = ADD48(avr->avr_ack_ackno, 1);
+
+free_records:
+	list_for_each_entry_safe_from(avr, next, &av->av_records, avr_node) {
+		list_del(&avr->avr_node);
+		kmem_cache_free(dccp_ackvec_record_slab, avr);
+	}
+}
+
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
--- a/net/dccp/input.c
+++ b/net/dccp/input.c
@@ -165,8 +165,8 @@ static void dccp_event_ack_recv(struct sock *sk, struct sk_buff *skb)
 	struct dccp_sock *dp = dccp_sk(sk);
 
 	if (dp->dccps_hc_rx_ackvec != NULL)
-		dccp_ackvec_check_rcv_ackno(dp->dccps_hc_rx_ackvec, sk,
-					    DCCP_SKB_CB(skb)->dccpd_ack_seq);
+		dccp_ackvec_clear_state(dp->dccps_hc_rx_ackvec,
+					DCCP_SKB_CB(skb)->dccpd_ack_seq);
 }
 
 static void dccp_deliver_input_to_ccids(struct sock *sk, struct sk_buff *skb)
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -54,7 +54,6 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 	struct dccp_sock *dp = dccp_sk(sk);
 	const struct dccp_hdr *dh = dccp_hdr(skb);
 	const u8 pkt_type = DCCP_SKB_CB(skb)->dccpd_type;
-	u64 ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
 	unsigned char *options = (unsigned char *)dh + dccp_hdr_len(skb);
 	unsigned char *opt_ptr = options;
 	const unsigned char *opt_end = (unsigned char *)dh +
@@ -133,9 +132,8 @@ int dccp_parse_options(struct sock *sk, struct dccp_request_sock *dreq,
 		case DCCPO_ACK_VECTOR_1:
 			if (dccp_packet_without_ack(skb))   /* RFC 4340, 11.4 */
 				break;
-			if (dp->dccps_hc_rx_ackvec != NULL &&
-			    dccp_ackvec_parse(sk, skb, &ackno, opt, value, len))
-				goto out_invalid_option;
+			dccp_pr_debug("%s Ack Vector (len=%u)\n", dccp_role(sk),
+				      len);
 			break;
 		case DCCPO_TIMESTAMP:
 			if (len != 4)
