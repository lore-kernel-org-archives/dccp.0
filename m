From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 20 Jul 2006 18:04:23 +0000
Subject: [PATCH 3/3] ACKVEC & CCID2: Code optimizations
Message-Id: <20060720180423.GC3313@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These are code optimizations which are relevant when dealing with large windows.
They are not coded the way I would like to, but they do the job for the
short-term.  This patch should be more neat.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index 73cb055..d4c247d 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -428,19 +428,23 @@ static u64 dccp_ackvec_check_rcv_ackvect
 {
 	unsigned char i;
 	struct dccp_ackvec_record *avr;
+	int use_head = 1;
 
 	/* Check if we actually sent an ACK vector */
 	if (list_empty(&av->dccpav_records))
 		return ackno; /* It's OK, because we will always return */
 
 	i = len;
-	/*
-	 * XXX
-	 * I think it might be more efficient to work backwards. See comment on
-	 * rcv_ackno. -sorbo.
-	 */
-	avr = list_entry(av->dccpav_records.next, struct dccp_ackvec_record,
-			 dccpavr_node);
+	list_for_each_entry_reverse(avr, &av->dccpav_records, dccpavr_node) {
+		if (!before48(avr->dccpavr_ack_seqno, ackno)) {
+			use_head = 0;
+			break;
+		}
+	}
+	if (use_head)
+		avr = list_entry(av->dccpav_records.next,
+				 struct dccp_ackvec_record, dccpavr_node);
+
 	while (i--) {
 		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
 		u64 ackno_end_rl;
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 50da0f5..6d3a57b 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -780,8 +780,18 @@ static void ccid2_hc_tx_packet_recv(stru
 	}
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
-	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
-
+	if (ackno > hctx->ccid2hctx_high_ack)
+		hctx->ccid2hctx_high_ack = ackno;
+
+	seqp = hctx->ccid2hctx_seqt;
+	while (before48(seqp->ccid2s_seq, ackno)) {
+		seqp = seqp->ccid2s_next;
+		if (seqp = hctx->ccid2hctx_seqh) {
+			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+			break;
+		}
+	}
+	
 	/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
 	 * this single ack.  I round up.
 	 * -sorbo.
@@ -857,7 +867,14 @@ static void ccid2_hc_tx_packet_recv(stru
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
-	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+	seqp = hctx->ccid2hctx_seqt;
+	while (seqp->ccid2s_seq < hctx->ccid2hctx_high_ack) {
+		seqp = seqp->ccid2s_next;
+		if (seqp = hctx->ccid2hctx_seqh) {
+			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+			break;
+		}
+	}
 	done = 0;
 	while (1) {
 		if (seqp->ccid2s_acked) {
@@ -947,6 +964,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	hctx->ccid2hctx_last_cong = jiffies;
+	hctx->ccid2hctx_high_ack = 0;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 5f3e1c8..5f4720a 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -108,6 +108,7 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_sendwait;
 	unsigned long		ccid2hctx_last_cong;
 	struct ccid2_txprofile	ccid2hctx_profile;
+	u64			ccid2hctx_high_ack;
 };
 
 struct ccid2_hc_rx_sock {
