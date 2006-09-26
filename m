From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Tue, 26 Sep 2006 21:48:23 +0000
Subject: [PATCH] CCID2: Fix format string for 64-bit quantities
Message-Id: <20060926214823.GA30020@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Use correct format string when printing 64 bit quantities (%L instead of %ll).

Note to Arnaldo: This patch is to be applied after the 3 patches I already sent
you.  Else, it will either apply with some fuzz, or not at all.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 755f744..7b1fa67 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -352,12 +352,12 @@ static void ccid2_hc_tx_packet_sent(stru
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
-	ccid2_pr_debug("Sent: seq=%llu\n", seq);
+	ccid2_pr_debug("Sent: seq=%Lu\n", seq);
 	do {
 		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
 
 		while (seqp != hctx->ccid2hctx_seqh) {
-			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
+			ccid2_pr_debug("out seq=%Lu acked=%d time=%lu\n",
 			       	       seqp->ccid2s_seq, seqp->ccid2s_acked,
 				       seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
@@ -479,7 +479,7 @@ static inline void ccid2_new_ack(struct 
 
 		/* first measurement */
 		if (hctx->ccid2hctx_srtt = -1) {
-			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
+			ccid2_pr_debug("R: %lu Time=%lu seq=%Lu\n",
 			       	       r, jiffies, seqp->ccid2s_seq);
 			ccid2_change_srtt(hctx, r);
 			hctx->ccid2hctx_rttvar = r >> 1;
@@ -646,7 +646,7 @@ static void ccid2_hc_tx_packet_recv(stru
 			u64 ackno_end_rl;
 
 			dccp_set_seqno(&ackno_end_rl, ackno - rl);
-			ccid2_pr_debug("ackvec start:%llu end:%llu\n", ackno,
+			ccid2_pr_debug("ackvec start:%Lu end:%Lu\n", ackno,
 				       ackno_end_rl);
 			/* if the seqno we are analyzing is larger than the
 			 * current ackno, then move towards the tail of our
@@ -681,7 +681,7 @@ static void ccid2_hc_tx_packet_recv(stru
 							      &maxincr);
 
 					seqp->ccid2s_acked = 1;
-					ccid2_pr_debug("Got ack for %llu\n",
+					ccid2_pr_debug("Got ack for %Lu\n",
 					       	       seqp->ccid2s_seq);
 					ccid2_hc_tx_dec_pipe(sk);
 				}
@@ -734,7 +734,7 @@ static void ccid2_hc_tx_packet_recv(stru
 		/* check for lost packets */
 		while (1) {
 			if (!seqp->ccid2s_acked) {
-				ccid2_pr_debug("Packet lost: %llu\n",
+				ccid2_pr_debug("Packet lost: %Lu\n",
 					       seqp->ccid2s_seq);
 				/* XXX need to traverse from tail -> head in
 				 * order to detect multiple congestion events in
