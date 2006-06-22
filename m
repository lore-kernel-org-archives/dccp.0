From: Andrea Bittau <a.bittau@cs.ucl.ac.uk>
Date: Thu, 22 Jun 2006 17:58:21 +0000
Subject: [PATCH 08/11] CCID2: Halve cwnd once upon multiple losses in a single RTT
Message-Id: <20060622175821.GH4230@shorty.sorbonet.org>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

When multiple losses occur in one RTT, the window should be halved only once [a
single "congestion event"].  This is now implemented, although not perfectly.
Slightly changed the interface for changing the cwnd: pass hctx instead of dp.
This is required in order to allow for change_cwnd to be called from _init().

Signed-off-by: Andrea Bittau <a.bittau@cs.ucl.ac.uk>

---

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index b2d140f..f0bc0b6 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -188,10 +188,8 @@ static void ccid2_change_l_ack_ratio(str
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_change_cwnd(struct sock *sk, int val)
+static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, int val)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-
 	if (val = 0)
 		val = 1;
 
@@ -235,7 +233,7 @@ static void ccid2_hc_tx_rto_expire(unsig
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd >> 1;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
-	ccid2_change_cwnd(sk, 1);
+	ccid2_change_cwnd(hctx, 1);
 
 	/* clear state about stuff we sent */
 	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
@@ -445,7 +443,7 @@ static inline void ccid2_new_ack(struct 
 			/* increase every 2 acks */
 			hctx->ccid2hctx_ssacks++;
 			if (hctx->ccid2hctx_ssacks = 2) {
-				ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd + 1);
+				ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd+1);
 				hctx->ccid2hctx_ssacks = 0;
 				*maxincr = *maxincr - 1;
 			}
@@ -458,7 +456,7 @@ static inline void ccid2_new_ack(struct 
 		hctx->ccid2hctx_acks++;
 
 		if (hctx->ccid2hctx_acks >= hctx->ccid2hctx_cwnd) {
-			ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd + 1);
+			ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd + 1);
 			hctx->ccid2hctx_acks = 0;
 		}
 	}
@@ -534,6 +532,22 @@ static void ccid2_hc_tx_dec_pipe(struct 
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
+static void ccid2_congestion_event(struct ccid2_hc_tx_sock *hctx,
+				   struct ccid2_seq *seqp)
+{
+	if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
+		dccp_pr_debug("Multiple losses in one RTT---treating as one\n");
+		return;
+	}	
+ 
+	hctx->ccid2hctx_last_cong = jiffies;
+	
+	ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd >> 1);
+	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd;
+	if (hctx->ccid2hctx_ssthresh < 2)
+		hctx->ccid2hctx_ssthresh = 2;
+}
+
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -544,7 +558,6 @@ static void ccid2_hc_tx_packet_recv(stru
 	unsigned char veclen;
 	int offset = 0;
 	int done = 0;
-	int loss = 0;
 	unsigned int maxincr = 0;
 
 	ccid2_hc_tx_check_sanity(hctx);
@@ -638,7 +651,8 @@ static void ccid2_hc_tx_packet_recv(stru
 				    !seqp->ccid2s_acked) {
 				    	if (state =
 					    DCCP_ACKVEC_STATE_ECN_MARKED) {
-						loss = 1;
+					    	ccid2_congestion_event(hctx,
+								       seqp);
 					} else
 						ccid2_new_ack(sk, seqp,
 							      &maxincr);
@@ -690,7 +704,13 @@ static void ccid2_hc_tx_packet_recv(stru
 		/* check for lost packets */
 		while (1) {
 			if (!seqp->ccid2s_acked) {
-				loss = 1;
+				ccid2_pr_debug("Packet lost: %llu\n",
+					       seqp->ccid2s_seq);
+				/* XXX need to traverse from tail -> head in
+				 * order to detect multiple congestion events in
+				 * one ack vector.
+				 */
+				ccid2_congestion_event(hctx, seqp);
 				ccid2_hc_tx_dec_pipe(sk);
 			}
 			if (seqp = hctx->ccid2hctx_seqt)
@@ -709,14 +729,6 @@ static void ccid2_hc_tx_packet_recv(stru
 		hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqt->ccid2s_next;
 	}
 
-	if (loss) {
-		/* XXX do bit shifts guarantee a 0 as the new bit? */
-		ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd >> 1);
-		hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd;
-		if (hctx->ccid2hctx_ssthresh < 2)
-			hctx->ccid2hctx_ssthresh = 2;
-	}
-
 	ccid2_hc_tx_check_sanity(hctx);
 }
 
@@ -724,7 +736,7 @@ static int ccid2_hc_tx_init(struct ccid 
 {
         struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid2hctx_cwnd	  = 1;
+	ccid2_change_cwnd(hctx, 1);
 	hctx->ccid2hctx_ssthresh  = 666666; /* "infinite" [for a while] */
 	hctx->ccid2hctx_numdupack = 3;
 	hctx->ccid2hctx_seqbufc   = 0;
@@ -739,6 +751,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_rttvar	 = -1;
 	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
+	hctx->ccid2hctx_last_cong = jiffies;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 1a7904e..3bc4b76 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -71,6 +71,7 @@ struct ccid2_hc_tx_sock {
 	u64			ccid2hctx_rpseq;
 	int			ccid2hctx_rpdupack;
 	int			ccid2hctx_sendwait;
+	unsigned long		ccid2hctx_last_cong;
 };
 
 struct ccid2_hc_rx_sock {
