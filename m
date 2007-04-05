From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:34:24 +0000
Subject: [PATCH 13/43]: CCID3 Packet Reception Step 6a  -  Basic loss detection
Message-Id: <200704051634.24432@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: CCID3 Packet Reception Step 6a  -  Basic loss detection

This implements loss detection for CCID3 atop of the new RX history. Features:
 * waiting for NDUPACK=3 packets to fill the hole;
 * coping with re-ordered/duplicate/late packets;
 * merging loss records when a late-arriving packet fills a hole.

All these cases are known to occur in practice, but do not always happen.
Hence the entire code has been verified using a test module which provides
test cases for each possible scenario.

Detailed documentation in section 3 of 
http://www.erg.abdn.ac.uk/users/gerrit/dccp/docs/ccid3_packet_reception/

NB - all datatypes for sequence number distances and NDP counts are `int', as
     figures of 2^30 lost packets or receiving 2^30 non-data packets are insane.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   62 --------------
 net/dccp/ccids/lib/packet_history.c |  153 ++++++++++++++++++++++++++++++++++++
 net/dccp/ccids/lib/packet_history.h |    1 
 3 files changed, 156 insertions(+), 60 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -221,6 +221,7 @@ static inline void tfrc_rx_hist_update(s
 	dccp_rx_hist_entry_from_skb(last_rcv(h), skb, ndp);
 }
 
+extern int  tfrc_rx_handle_loss(struct tfrc_rx_hist *, struct sk_buff *, u32);
 extern u32  tfrc_rx_sample_rtt(struct tfrc_rx_hist *, struct sk_buff *);
 extern int  tfrc_rx_hist_init(struct tfrc_rx_hist *);
 extern void tfrc_rx_hist_cleanup(struct tfrc_rx_hist *);
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -351,6 +351,159 @@ void tfrc_rx_hist_cleanup(struct tfrc_rx
 
 EXPORT_SYMBOL_GPL(tfrc_rx_hist_cleanup);
 
+/*
+ * Private helper functions for loss detection.
+ *
+ * In the descriptions, `Si' refers to the sequence number of entry number i,
+ * whose NDP count is `Ni' (lower case is used for variables).
+ * Note: All __after_loss functions expect that a test against duplicates has
+ *       been performed already: the seqno of the skb must not be less than the
+ *       seqno of loss_prev; and it must not equal that of any valid hist_entry.
+ */
+static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2)
+{
+	u64 s0 = loss_prev(h)->dccphrx_seqno,
+	    s1 = hist_entry(h, 1)->dccphrx_seqno,
+	    s2 = DCCP_SKB_CB(skb)->dccpd_seq;
+	int n1 = hist_entry(h, 1)->dccphrx_ndp,
+	   d12 = dccp_delta_seqno(s1, s2), d2;
+
+	if (d12 > 0) {			/* S1  <  S2 */
+		h->loss_count = 2;
+		dccp_rx_hist_entry_from_skb(hist_entry(h, 2), skb, n2);
+		return;
+	}
+
+	/* S0  <  S2  <  S1 */
+	d2 = dccp_delta_seqno(s0, s2);
+
+	if (d2 = 1 || n2 >= d2) {	/* S2 is direct successor of S0 */
+		int d21 = -d12;
+
+		if (d21 = 1 || n1 >= d21) {
+			/* hole is filled: S0, S2, and S1 are consecutive */
+			h->loss_count = 0;
+			h->loss_start = hist_index(h, 1);
+		} else
+			/* gap between S2 and S1: just update loss_prev */
+			dccp_rx_hist_entry_from_skb(loss_prev(h), skb, n2);
+
+	} else {			/* hole between S0 and S2 */
+		/*
+		 * Reorder history to insert S2 between S0 and s1
+		 */
+		tfrc_rx_hist_swap(&hist_entry(h, 0), &hist_entry(h, 3));
+		h->loss_start = hist_index(h, 3);
+		dccp_rx_hist_entry_from_skb(hist_entry(h, 1), skb, n2);
+		h->loss_count = 2;
+	}
+}
+
+/* return 1 if a new loss event has been identified */
+static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
+{
+	u64 s0 = loss_prev(h)->dccphrx_seqno,
+	    s1 = hist_entry(h, 1)->dccphrx_seqno,
+	    s2 = hist_entry(h, 2)->dccphrx_seqno,
+	    s3 = DCCP_SKB_CB(skb)->dccpd_seq;
+	int n1 = hist_entry(h, 1)->dccphrx_ndp,
+	   d23 = dccp_delta_seqno(s2, s3), d13, d3, d31;
+
+	if (d23 > 0) {			/* S2  <  S3 */
+		h->loss_count = 3;
+		dccp_rx_hist_entry_from_skb(hist_entry(h, 3), skb, n3);
+		return 1;
+	}
+
+	/* S3  <  S2 */
+	d13 = dccp_delta_seqno(s1, s3);
+
+	if (d13 > 0) {
+		/*
+		 * The sequence number order is S1, S3, S2
+		 * Reorder history to insert entry between S1 and S2
+		 */
+		tfrc_rx_hist_swap(&hist_entry(h, 2), &hist_entry(h, 3));
+		dccp_rx_hist_entry_from_skb(hist_entry(h, 2), skb, n3);
+		h->loss_count = 3;
+		return 1;
+	}
+
+	/* S0  <  S3  <  S1 */
+	d31 = -d13;
+	d3  = dccp_delta_seqno(s0, s3);
+
+	if (d3 = 1 || n3 >= d3) {	/* S3 is a successor of S0 */
+
+		if (d31 = 1 || n1 >= d31) {
+			/* hole between S0 and S1 filled by S3 */
+			int  d2 = dccp_delta_seqno(s1, s2),
+			     n2 = hist_entry(h, 2)->dccphrx_ndp;
+
+			if (d2 = 1 || n2 >= d2) {
+				/* entire hole filled by S0, S3, S1, S2 */
+				h->loss_start = hist_index(h, 2);
+				h->loss_count = 0;
+			} else {
+				/* gap remains between S1 and S2 */
+				h->loss_start = hist_index(h, 1);
+				h->loss_count = 1;
+			}
+
+		} else /* gap exists between S3 and S1, loss_count stays at 2 */
+			dccp_rx_hist_entry_from_skb(loss_prev(h), skb, n3);
+
+		return 0;
+	}
+
+	/*
+	 * The remaining case: S3 is not a successor of S0.
+	 * Sequence order is S0, S3, S1, S2; reorder to insert between S0 and S1
+	 */
+	tfrc_rx_hist_swap(&hist_entry(h, 0), &hist_entry(h, 3));
+	h->loss_start = hist_index(h, 3);
+	dccp_rx_hist_entry_from_skb(hist_entry(h, 1), skb, n3);
+	h->loss_count = 3;
+
+	return 1;
+}
+
+/* recycle RX history records to continue loss detection if necessary */
+static void __three_after_loss(struct tfrc_rx_hist *h)
+{
+	/* XXX do nothing for now, this is part of a subsequent patch */
+	h->loss_start = hist_index(h, 3);
+	h->loss_count = 0;
+}
+
+/**
+ *  tfrc_rx_handle_loss  -  Loss detection and further processing
+ *  @h:	      The non-empty history object
+ *  @skb:     Currently received packet
+ *  @ndp:     The NDP count belonging to skb
+ *  Returns 1 when caller should send feedback, 0 otherwise.
+ */
+int tfrc_rx_handle_loss(struct tfrc_rx_hist *h,
+			struct sk_buff *skb, u32 ndp)
+{
+	int is_new_loss = 0;
+
+	if (h->loss_count = 1)
+		__one_after_loss(h, skb, ndp);
+	else if (h->loss_count != 2)
+		DCCP_BUG("invalid loss_count %d", h->loss_count);
+	else if (__two_after_loss(h, skb, ndp)) {
+		/*
+		 * XXX part of subsequent patch
+		is_new_loss = update_li(li_hist, loss_prev(h));
+		*/
+		__three_after_loss(h);
+	}
+	return is_new_loss;
+}
+
+EXPORT_SYMBOL_GPL(tfrc_rx_handle_loss);
+
 /**
  * tfrc_rx_sample_rtt  -  Sample RTT from timestamp / CCVal
  * Based on ideas presented in RFC 4342, 8.1. Returns 0 if it was not able
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -906,61 +906,6 @@ static void ccid3_hc_rx_update_li(struct
 	}
 }
 
-#if 0	/* XXX obsoleted by subsequent patch */
-static int ccid3_hc_rx_detect_loss(struct sock *sk,
-				    struct dccp_rx_hist_entry *packet)
-{
-	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
-	struct dccp_rx_hist_entry *rx_hist -				dccp_rx_hist_head(&hcrx->ccid3hcrx_hist);
-	u64 seqno = packet->dccphrx_seqno;
-	u64 tmp_seqno;
-	int loss = 0;
-	u8 ccval;
-
-
-	tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
-
-	if (!rx_hist ||
-	   follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
-		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
-		goto detect_out;
-	}
-
-
-	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
-	   > TFRC_RECV_NUM_LATE_LOSS) {
-		loss = 1;
-		ccid3_hc_rx_update_li(sk, hcrx->ccid3hcrx_seqno_nonloss,
-		   hcrx->ccid3hcrx_ccval_nonloss);
-		tmp_seqno = hcrx->ccid3hcrx_seqno_nonloss;
-		dccp_inc_seqno(&tmp_seqno);
-		hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-		dccp_inc_seqno(&tmp_seqno);
-		while (dccp_rx_hist_find_entry(&hcrx->ccid3hcrx_hist,
-		   tmp_seqno, &ccval)) {
-			hcrx->ccid3hcrx_seqno_nonloss = tmp_seqno;
-			hcrx->ccid3hcrx_ccval_nonloss = ccval;
-			dccp_inc_seqno(&tmp_seqno);
-		}
-	}
-
-	/* FIXME - this code could be simplified with above while */
-	/* but works at moment */
-	if (follows48(packet->dccphrx_seqno, hcrx->ccid3hcrx_seqno_nonloss)) {
-		hcrx->ccid3hcrx_seqno_nonloss = seqno;
-		hcrx->ccid3hcrx_ccval_nonloss = packet->dccphrx_ccval;
-	}
-
-detect_out:
-	dccp_rx_hist_add_packet(ccid3_rx_hist, &hcrx->ccid3hcrx_hist,
-		   &hcrx->ccid3hcrx_li_hist, packet,
-		   hcrx->ccid3hcrx_seqno_nonloss);
-	return loss;
-}
-#endif
-
 static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -993,11 +938,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	 *	Handle pending losses and otherwise check for new loss
 	 */
 	if (tfrc_rx_loss_pending(&hcrx->ccid3hcrx_hist)) {
-		/*
-		 * Loss Handling
-		 *
-		 * XXX: part of subsequent patch
-		 */
+
+		do_feedback = tfrc_rx_handle_loss(&hcrx->ccid3hcrx_hist, skb, ndp);
 		goto sending_feedback;
 	}
 
