From: Arnaldo Carvalho de Melo <acme@redhat.com>
Date: Sun, 25 Nov 2007 00:21:40 +0000
Subject: [PATCH 15/18] [CCID2]: Remove redundant ack-counting variable
Message-Id: <1195950103-18102-16-git-send-email-acme@redhat.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>

The code used two different variables to count Acks, one of them redundant.
This patch reduces the number of Ack counters to one.

The type of the Ack counter has also been changed to u32 (twice the range of int);
and the variable has been renamed into `packets_acked' - for consistency with
RFC 3465 (and similarly named variables are used by TCP and SCTP).

Lastly, a slightly less aggressive `maxincr' increment is used (for even Ack Ratios,
maxincr was Ack Ratio/2 + 1 instead of Ack Ratio/2).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ccids/ccid2.c |   46 +++++++++++++++-------------------------------
 net/dccp/ccids/ccid2.h |    6 ++----
 2 files changed, 17 insertions(+), 35 deletions(-)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 4f6c352..02d126d 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -199,9 +199,8 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	hctx->ccid2hctx_pipe	 = 0;
 
 	/* clear state about stuff we sent */
-	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
-	hctx->ccid2hctx_ssacks	= 0;
-	hctx->ccid2hctx_acks	= 0;
+	hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqh;
+	hctx->ccid2hctx_packets_acked = 0;
 
 	/* clear ack ratio state. */
 	hctx->ccid2hctx_rpseq	 = 0;
@@ -406,31 +405,15 @@ static inline void ccid2_new_ack(struct sock *sk,
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	/* slow start */
 	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
-		hctx->ccid2hctx_acks = 0;
-
-		/* We can increase cwnd at most maxincr [ack_ratio/2] */
-		if (*maxincr) {
-			/* increase every 2 acks */
-			hctx->ccid2hctx_ssacks++;
-			if (hctx->ccid2hctx_ssacks = 2) {
-				hctx->ccid2hctx_cwnd++;
-				hctx->ccid2hctx_ssacks = 0;
-				*maxincr = *maxincr - 1;
-			}
-		} else {
-			/* increased cwnd enough for this single ack */
-			hctx->ccid2hctx_ssacks = 0;
-		}
-	} else {
-		hctx->ccid2hctx_ssacks = 0;
-		hctx->ccid2hctx_acks++;
-
-		if (hctx->ccid2hctx_acks >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_cwnd++;
-			hctx->ccid2hctx_acks = 0;
+		if (*maxincr > 0 && ++hctx->ccid2hctx_packets_acked = 2) {
+			hctx->ccid2hctx_cwnd += 1;
+			*maxincr	     -= 1;
+			hctx->ccid2hctx_packets_acked = 0;
 		}
+	} else if (++hctx->ccid2hctx_packets_acked >= hctx->ccid2hctx_cwnd) {
+			hctx->ccid2hctx_cwnd += 1;
+			hctx->ccid2hctx_packets_acked = 0;
 	}
 
 	/* update RTO */
@@ -596,12 +579,13 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		}
 	}
 
-	/* If in slow-start, cwnd can increase at most Ack Ratio / 2 packets for
-	 * this single ack.  I round up.
-	 * -sorbo.
+	/*
+	 * In slow-start, cwnd can increase up to a maximum of Ack Ratio/2
+	 * packets per acknowledgement. Rounding up avoids that cwnd is not
+	 * advanced when Ack Ratio is 1 and gives a slight edge otherwise.
 	 */
-	maxincr = dp->dccps_l_ack_ratio >> 1;
-	maxincr++;
+	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh)
+		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
 	while ((offset = ccid2_ackvector(sk, skb, offset,
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 2671f8e..2c94ca0 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -43,8 +43,7 @@ struct ccid2_seq {
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
  *
  * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
- * @ccid2hctx_ssacks - ACKs recv in slow start
- * @ccid2hctx_acks - ACKS recv in AI phase
+ * @ccid2hctx_packets_acked - Ack counter for deriving cwnd growth (RFC 3465)
  * @ccid2hctx_lastrtt -time RTT was last measured
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
@@ -53,8 +52,7 @@ struct ccid2_hc_tx_sock {
 	u32			ccid2hctx_cwnd;
 	u32			ccid2hctx_ssthresh;
 	u32			ccid2hctx_pipe;
-	int			ccid2hctx_ssacks;
-	int			ccid2hctx_acks;
+	u32			ccid2hctx_packets_acked;
 	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
 	int			ccid2hctx_seqbufc;
 	struct ccid2_seq	*ccid2hctx_seqh;
-- 
1.5.3.4

