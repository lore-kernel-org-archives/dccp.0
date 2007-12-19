From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 19 Dec 2007 14:25:52 +0000
Subject: [PATCH 11/14] [ACKVEC]: Implement algorithm to update buffer state
Message-Id: <1198074355-18842-12-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This implements an algorithm to consistently update the buffer state when
the peer acknowledges receipt of Ack Vectors; updating state in the list of
Ack Vectors as well as in the circular buffer.

The algorithm
 * deals with HC-sender acknowledging to HC-receiver and vice versa,
 * keeps track of the last unacknowledged but received seqno in tail_ackno,
 * has special cases to reset the overflow condition when appropriate,
 * is protected against receiving older information (would mess up buffer state).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c |   82 ++++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 62 insertions(+), 20 deletions(-)

--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -262,34 +262,76 @@ out_duplicate:
 	return -EILSEQ;
 }
 
-static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
-				     struct dccp_ackvec_record *avr)
-{
-	struct dccp_ackvec_record *next;
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
 
-	/* sort out vector length */
-	if (av->av_buf_head <= avr->avr_ack_ptr)
-		av->av_vec_len = avr->avr_ack_ptr - av->av_buf_head;
-	else
-		av->av_vec_len = DCCPAV_MAX_ACKVEC_LEN - 1 -
-				 av->av_buf_head + avr->avr_ack_ptr;
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
 
-	/* free records */
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
+		av->av_buf_tail = dccp_ackvec_idx_add(avr->avr_ack_ptr, 1);
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
 	list_for_each_entry_safe_from(avr, next, &av->av_records, avr_node) {
 		list_del(&avr->avr_node);
 		kmem_cache_free(dccp_ackvec_record_slab, avr);
 	}
 }
 
-void dccp_ackvec_clear_state(struct dccp_ackvec *av, const u64 ackno)
-{
-	struct dccp_ackvec_record *avr;
-
-	avr = dccp_ackvec_lookup(&av->av_records, ackno);
-	if (avr != NULL)
-		dccp_ackvec_throw_record(av, avr);
-}
-
 int __init dccp_ackvec_init(void)
 {
 	dccp_ackvec_slab = kmem_cache_create("dccp_ackvec",
-- 
1.5.3.GIT

