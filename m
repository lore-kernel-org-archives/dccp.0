From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Thu, 14 Sep 2006 17:14:11 +0000
Subject: [PATCH 9/10]: [DCCP] CCID2: Halve cwnd once upon multiple losses in a single RTT
Message-Id: <20060914171408.GK20651@mandriva.com>
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
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>

------------------------------------------------------------------------------

 ccid2.c |   49 +++++++++++++++++++++++++++++++------------------
 ccid2.h |    1 +
 2 files changed, 32 insertions(+), 18 deletions(-)

------------------------------------------------------------------------------

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 6ddd2cb..4fcd858 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -187,10 +187,8 @@ static void ccid2_change_l_ack_ratio(str
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_change_cwnd(struct sock *sk, int val)
+static void ccid2_change_cwnd(struct ccid2_hc_tx_sock *hctx, int val)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-
 	if (val = 0)
 		val = 1;
 
@@ -234,7 +232,7 @@ static void ccid2_hc_tx_rto_expire(unsig
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd >> 1;
 	if (hctx->ccid2hctx_ssthresh < 2)
 		hctx->ccid2hctx_ssthresh = 2;
-	ccid2_change_cwnd(sk, 1);
+	ccid2_change_cwnd(hctx, 1);
 
 	/* clear state about stuff we sent */
 	hctx->ccid2hctx_seqt	= hctx->ccid2hctx_seqh;
@@ -444,7 +442,7 @@ static inline void ccid2_new_ack(struct 
 			/* increase every 2 acks */
 			hctx->ccid2hctx_ssacks++;
 			if (hctx->ccid2hctx_ssacks = 2) {
-				ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd + 1);
+				ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd+1);
 				hctx->ccid2hctx_ssacks = 0;
 				*maxincr = *maxincr - 1;
 			}
@@ -457,7 +455,7 @@ static inline void ccid2_new_ack(struct 
 		hctx->ccid2hctx_acks++;
 
 		if (hctx->ccid2hctx_acks >= hctx->ccid2hctx_cwnd) {
-			ccid2_change_cwnd(sk, hctx->ccid2hctx_cwnd + 1);
+			ccid2_change_cwnd(hctx, hctx->ccid2hctx_cwnd + 1);
 			hctx->ccid2hctx_acks = 0;
 		}
 	}
@@ -532,6 +530,22 @@ static void ccid2_hc_tx_dec_pipe(struct 
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
+static void ccid2_congestion_event(struct ccid2_hc_tx_sock *hctx,
+				   struct ccid2_seq *seqp)
+{
+	if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
+		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
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
@@ -542,7 +556,6 @@ static void ccid2_hc_tx_packet_recv(stru
 	unsigned char veclen;
 	int offset = 0;
 	int done = 0;
-	int loss = 0;
 	unsigned int maxincr = 0;
 
 	ccid2_hc_tx_check_sanity(hctx);
@@ -636,7 +649,8 @@ static void ccid2_hc_tx_packet_recv(stru
 				    !seqp->ccid2s_acked) {
 				    	if (state =
 					    DCCP_ACKVEC_STATE_ECN_MARKED) {
-						loss = 1;
+					    	ccid2_congestion_event(hctx,
+								       seqp);
 					} else
 						ccid2_new_ack(sk, seqp,
 							      &maxincr);
@@ -688,7 +702,13 @@ static void ccid2_hc_tx_packet_recv(stru
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
@@ -707,14 +727,6 @@ static void ccid2_hc_tx_packet_recv(stru
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
 
@@ -722,7 +734,7 @@ static int ccid2_hc_tx_init(struct ccid 
 {
         struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
 
-	hctx->ccid2hctx_cwnd	  = 1;
+	ccid2_change_cwnd(hctx, 1);
 	/* Initialize ssthresh to infinity.  This means that we will exit the
 	 * initial slow-start after the first packet loss.  This is what we
 	 * want.
@@ -741,6 +753,7 @@ static int ccid2_hc_tx_init(struct ccid 
 	hctx->ccid2hctx_rttvar	 = -1;
 	hctx->ccid2hctx_lastrtt  = 0;
 	hctx->ccid2hctx_rpdupack = -1;
+	hctx->ccid2hctx_last_cong = jiffies;
 
 	hctx->ccid2hctx_rtotimer.function = &ccid2_hc_tx_rto_expire;
 	hctx->ccid2hctx_rtotimer.data	  = (unsigned long)sk;
diff --git a/net/dccp/ccids/ccid2.h b/net/dccp/ccids/ccid2.h
index 2a02ce0..5b2ef4a 100644
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -71,6 +71,7 @@ struct ccid2_hc_tx_sock {
 	u64			ccid2hctx_rpseq;
 	int			ccid2hctx_rpdupack;
 	int			ccid2hctx_sendwait;
+	unsigned long		ccid2hctx_last_cong;
 };
 
 struct ccid2_hc_rx_sock {
