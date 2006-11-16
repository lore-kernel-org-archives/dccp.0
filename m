From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 16 Nov 2006 16:33:58 +0000
Subject: [PATCH 3/3][DCCP] CCID2: Code optimizations
Message-Id: <20061116163357.GE5195@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

These are code optimizations which are relevant when dealing with large
windows.  They are not coded the way I would like to, but they do the job for
the short-term.  This patch should be more neat.

Commiter note: Changed the seqno comparisions to use {after,before}48 to handle
               wrapping.

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid2.c |   22 ++++++++++++++++++++--
 net/dccp/ccids/ccid2.h |    1 +
 2 files changed, 21 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 162032b..6533cb2 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -619,7 +619,17 @@ static void ccid2_hc_tx_packet_recv(stru
 	}
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
-	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+	if (after48(ackno, hctx->ccid2hctx_high_ack))
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
 
 	/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
 	 * this single ack.  I round up.
@@ -697,7 +707,14 @@ static void ccid2_hc_tx_packet_recv(stru
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
-	seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+	seqp = hctx->ccid2hctx_seqt;
+	while (before48(seqp->ccid2s_seq, hctx->ccid2hctx_high_ack)) {
+		seqp = seqp->ccid2s_next;
+		if (seqp = hctx->ccid2hctx_seqh) {
+			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+			break;
+		}
+	}
 	done = 0;
 	while (1) {
 		if (seqp->ccid2s_acked) {
@@ -771,6 +788,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
 	hctx->ccid2hctx_last_cong = jiffies;
+	hctx->ccid2hctx_high_ack = 0;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 5b2ef4a..a97a899 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -72,6 +72,7 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_rpdupack;
 	int			ccid2hctx_sendwait;
 	unsigned long		ccid2hctx_last_cong;
+	u64			ccid2hctx_high_ack;
 };
 
 struct ccid2_hc_rx_sock {
-- 
1.4.2.1.g3d5c

