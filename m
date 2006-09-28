From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 28 Sep 2006 05:16:53 +0000
Subject: [PATCH] CCID2: Fix compile warning on some platforms
Message-Id: <20060928051653.GA7898@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Explicitly cast argument to unsigned long long when using the %llu format string
[trick stolen from DaveM =D].  This will remove a compiler warning  on some
platforms when a u64 is printed.

Note to Arnaldo: This patch should be applied after the three you already have
in the queue.  Else, it may apply with some fuzz, or not at all.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 755f744..9d6eefd 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -352,14 +352,14 @@ static void ccid2_hc_tx_packet_sent(stru
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	ccid2_pr_debug("pipe=%d\n", hctx->ccid2hctx_pipe);
-	ccid2_pr_debug("Sent: seq=%llu\n", seq);
+	ccid2_pr_debug("Sent: seq=%llu\n", (unsigned long long) seq);
 	do {
 		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
 
 		while (seqp != hctx->ccid2hctx_seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
-			       	       seqp->ccid2s_seq, seqp->ccid2s_acked,
-				       seqp->ccid2s_sent);
+			       	       (unsigned long long) seqp->ccid2s_seq,
+				       seqp->ccid2s_acked, seqp->ccid2s_sent);
 			seqp = seqp->ccid2s_next;
 		}
 	} while (0);
@@ -480,7 +480,8 @@ static inline void ccid2_new_ack(struct 
 		/* first measurement */
 		if (hctx->ccid2hctx_srtt = -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
-			       	       r, jiffies, seqp->ccid2s_seq);
+			       	       r, jiffies,
+				       (unsigned long long) seqp->ccid2s_seq);
 			ccid2_change_srtt(hctx, r);
 			hctx->ccid2hctx_rttvar = r >> 1;
 		} else {
@@ -646,8 +647,9 @@ static void ccid2_hc_tx_packet_recv(stru
 			u64 ackno_end_rl;
 
 			dccp_set_seqno(&ackno_end_rl, ackno - rl);
-			ccid2_pr_debug("ackvec start:%llu end:%llu\n", ackno,
-				       ackno_end_rl);
+			ccid2_pr_debug("ackvec start:%llu end:%llu\n",
+				       (unsigned long long) ackno,
+				       (unsigned long long) ackno_end_rl);
 			/* if the seqno we are analyzing is larger than the
 			 * current ackno, then move towards the tail of our
 			 * seqnos.
@@ -682,7 +684,8 @@ static void ccid2_hc_tx_packet_recv(stru
 
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
-					       	       seqp->ccid2s_seq);
+					       	       (unsigned long long)
+						       seqp->ccid2s_seq);
 					ccid2_hc_tx_dec_pipe(sk);
 				}
 				if (seqp = hctx->ccid2hctx_seqt) {
@@ -735,6 +738,7 @@ static void ccid2_hc_tx_packet_recv(stru
 		while (1) {
 			if (!seqp->ccid2s_acked) {
 				ccid2_pr_debug("Packet lost: %llu\n",
+					       (unsigned long long)
 					       seqp->ccid2s_seq);
 				/* XXX need to traverse from tail -> head in
 				 * order to detect multiple congestion events in
