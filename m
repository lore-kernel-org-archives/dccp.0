From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 12 Jul 2008 14:51:47 +0000
Subject: [PATCH 1/4] dccp ccid-3: Fix error in loss detection
Message-Id: <1215874310-10534-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The TFRC loss detection code used the wrong loss condition (RFC 4340, 7.7.1):
 * the difference between sequence numbers s1 and s2 instead of
 * the number of packets missing between s1 and s2 (one less than the distance).

Since this condition appears in many places of the code, it has been put into a
separate function, dccp_loss_free().

Further changes:
----------------
 * tidied up incorrect typing (it was using `int' for u64/s64 types);
 * optimised conditional statements for common case of non-reordered packets;
 * rewrote comments/documentation to match the changes.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/lib/packet_history.c |   73 +++++++++++++---------------------
 net/dccp/dccp.h                     |   15 +++++++
 2 files changed, 43 insertions(+), 45 deletions(-)

--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -153,6 +153,21 @@ static inline u64 max48(const u64 seq1, const u64 seq2)
 	return after48(seq1, seq2) ? seq1 : seq2;
 }
 
+/**
+ * dccp_loss_free  -  Evaluates condition for data loss from RFC 4340, 7.7.1
+ * @s1:	 start sequence number
+ * @s2:  end sequence number
+ * @ndp: NDP count on packet with sequence number @s2
+ * Returns true if the sequence range s1...s2 has no data loss.
+ */
+static inline bool dccp_loss_free(const u64 s1, const u64 s2, const u64 ndp)
+{
+	s64 delta = dccp_delta_seqno(s1, s2);
+
+	BUG_TRAP(delta >= 0);
+	return (u64)delta <= ndp + 1;
+}
+
 enum {
 	DCCP_MIB_NUM = 0,
 	DCCP_MIB_ACTIVEOPENS,			/* ActiveOpens */
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -215,22 +215,19 @@ static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2
 	u64 s0 = tfrc_rx_hist_loss_prev(h)->tfrchrx_seqno,
 	    s1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
 	    s2 = DCCP_SKB_CB(skb)->dccpd_seq;
-	int n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp,
-	   d12 = dccp_delta_seqno(s1, s2), d2;
 
-	if (d12 > 0) {			/* S1  <  S2 */
+	if (likely(dccp_delta_seqno(s1, s2) > 0)) {	/* S1  <  S2 */
 		h->loss_count = 2;
 		tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 2), skb, n2);
 		return;
 	}
 
 	/* S0  <  S2  <  S1 */
-	d2 = dccp_delta_seqno(s0, s2);
 
-	if (d2 = 1 || n2 >= d2) {	/* S2 is direct successor of S0 */
-		int d21 = -d12;
+	if (dccp_loss_free(s0, s2, n2)) {
+		u64 n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp;
 
-		if (d21 = 1 || n1 >= d21) {
+		if (dccp_loss_free(s2, s1, n1)) {
 			/* hole is filled: S0, S2, and S1 are consecutive */
 			h->loss_count = 0;
 			h->loss_start = tfrc_rx_hist_index(h, 1);
@@ -238,9 +235,9 @@ static void __one_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n2
 			/* gap between S2 and S1: just update loss_prev */
 			tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_loss_prev(h), skb, n2);
 
-	} else {			/* hole between S0 and S2 */
+	} else {	/* gap between S0 and S2 */
 		/*
-		 * Reorder history to insert S2 between S0 and s1
+		 * Reorder history to insert S2 between S0 and S1
 		 */
 		tfrc_rx_hist_swap(h, 0, 3);
 		h->loss_start = tfrc_rx_hist_index(h, 3);
@@ -256,22 +253,18 @@ static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
 	    s1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
 	    s2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_seqno,
 	    s3 = DCCP_SKB_CB(skb)->dccpd_seq;
-	int n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp,
-	   d23 = dccp_delta_seqno(s2, s3), d13, d3, d31;
 
-	if (d23 > 0) {			/* S2  <  S3 */
+	if (likely(dccp_delta_seqno(s2, s3) > 0)) {	/* S2  <  S3 */
 		h->loss_count = 3;
 		tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 3), skb, n3);
 		return 1;
 	}
 
 	/* S3  <  S2 */
-	d13 = dccp_delta_seqno(s1, s3);
 
-	if (d13 > 0) {
+	if (dccp_delta_seqno(s1, s3) > 0) {		/* S1  <  S3  <  S2 */
 		/*
-		 * The sequence number order is S1, S3, S2
-		 * Reorder history to insert entry between S1 and S2
+		 * Reorder history to insert S3 between S1 and S2
 		 */
 		tfrc_rx_hist_swap(h, 2, 3);
 		tfrc_rx_hist_entry_from_skb(tfrc_rx_hist_entry(h, 2), skb, n3);
@@ -280,17 +273,15 @@ static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
 	}
 
 	/* S0  <  S3  <  S1 */
-	d31 = -d13;
-	d3  = dccp_delta_seqno(s0, s3);
 
-	if (d3 = 1 || n3 >= d3) {	/* S3 is a successor of S0 */
+	if (dccp_loss_free(s0, s3, n3)) {
+		u64 n1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_ndp;
 
-		if (d31 = 1 || n1 >= d31) {
+		if (dccp_loss_free(s3, s1, n1)) {
 			/* hole between S0 and S1 filled by S3 */
-			int  d2 = dccp_delta_seqno(s1, s2),
-			     n2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_ndp;
+			u64 n2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_ndp;
 
-			if (d2 = 1 || n2 >= d2) {
+			if (dccp_loss_free(s1, s2, n2)) {
 				/* entire hole filled by S0, S3, S1, S2 */
 				h->loss_start = tfrc_rx_hist_index(h, 2);
 				h->loss_count = 0;
@@ -307,8 +298,8 @@ static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
 	}
 
 	/*
-	 * The remaining case: S3 is not a successor of S0.
-	 * Sequence order is S0, S3, S1, S2; reorder to insert between S0 and S1
+	 * The remaining case:  S0  <  S3  <  S1  <  S2;  gap between S0 and S3
+	 * Reorder history to insert S3 between S0 and S1.
 	 */
 	tfrc_rx_hist_swap(h, 0, 3);
 	h->loss_start = tfrc_rx_hist_index(h, 3);
@@ -318,33 +309,25 @@ static int __two_after_loss(struct tfrc_rx_hist *h, struct sk_buff *skb, u32 n3)
 	return 1;
 }
 
-/* return the signed modulo-2^48 sequence number distance from entry e1 to e2 */
-static s64 tfrc_rx_hist_delta_seqno(struct tfrc_rx_hist *h, u8 e1, u8 e2)
-{
-	DCCP_BUG_ON(e1 > h->loss_count || e2 > h->loss_count);
-
-	return dccp_delta_seqno(tfrc_rx_hist_entry(h, e1)->tfrchrx_seqno,
-				tfrc_rx_hist_entry(h, e2)->tfrchrx_seqno);
-}
-
 /* recycle RX history records to continue loss detection if necessary */
 static void __three_after_loss(struct tfrc_rx_hist *h)
 {
 	/*
-	 * The distance between S0 and S1 is always greater than 1 and the NDP
-	 * count of S1 is smaller than this distance. Otherwise there would
-	 * have been no loss. Hence it is only necessary to see whether there
-	 * are further missing data packets between S1/S2 and S2/S3.
+	 * At this stage we know already that there is a gap between S0 and S1
+	 * (since S0 was the highest sequence number received before detecting
+	 * the loss). To recycle the loss record, it is	thus only necessary to
+	 * check for other possible gaps between S1/S2 and between S2/S3.
 	 */
-	int d2 = tfrc_rx_hist_delta_seqno(h, 1, 2),
-	    d3 = tfrc_rx_hist_delta_seqno(h, 2, 3),
-	    n2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_ndp,
+	u64 s1 = tfrc_rx_hist_entry(h, 1)->tfrchrx_seqno,
+	    s2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_seqno,
+	    s3 = tfrc_rx_hist_entry(h, 3)->tfrchrx_seqno;
+	u64 n2 = tfrc_rx_hist_entry(h, 2)->tfrchrx_ndp,
 	    n3 = tfrc_rx_hist_entry(h, 3)->tfrchrx_ndp;
 
-	if (d2 = 1 || n2 >= d2) {	/* S2 is successor to S1 */
+	if (dccp_loss_free(s1, s2, n2)) {
 
-		if (d3 = 1 || n3 >= d3) {
-			/* S3 is successor of S2: entire hole is filled */
+		if (dccp_loss_free(s2, s3, n3)) {
+			/* no gap between S2 and S3: entire hole is filled */
 			h->loss_start = tfrc_rx_hist_index(h, 3);
 			h->loss_count = 0;
 		} else {
@@ -353,7 +336,7 @@ static void __three_after_loss(struct tfrc_rx_hist *h)
 			h->loss_count = 1;
 		}
 
-	} else {			/* gap between S1 and S2 */
+	} else {	/* gap between S1 and S2 */
 		h->loss_start = tfrc_rx_hist_index(h, 1);
 		h->loss_count = 2;
 	}
