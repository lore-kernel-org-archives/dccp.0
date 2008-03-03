From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 03 Mar 2008 14:38:19 +0000
Subject: Re: [DCCP] [CCID]: Getting rid of unwieldy struct prefixes
Message-Id: <20080303143819.GA11747@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Revised patch below for reference. Thanks to Arnaldo and Leandro.

-----------------> Revised & uploaded patch <----------------------------------
[CCID-2]: Get rid of ccid2hc{tx,rx}_ prefixes

This patch fixes two problems caused by the ubiquitous long "hctx->ccid2htx_"
and "hcrx->ccid2hcrx_" prefixes:
 -> code becomes hard to read;
 -> multiple-line statements are almost inevitable even for simple expressions;
 -> the prefixes are not really necessary - compare with "struct tcp_sock".

There had been previous discussion of this on dccp@vger, but so far this
was not followed up (most people agreed that the prefixes are too long). 

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |  284 +++++++++++++++++++++++--------------------------
 net/dccp/ccids/ccid2.h |   66 +++++------
 2 files changed, 172 insertions(+), 178 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -42,49 +42,49 @@ struct ccid2_seq {
 
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
  *
- * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
- * @ccid2hctx_packets_acked: Ack counter for deriving cwnd growth (RFC 3465)
- * @ccid2hctx_srtt: smoothed RTT estimate, scaled by 2^3
- * @ccid2hctx_mdev: smoothed RTT variation, scaled by 2^2
- * @ccid2hctx_mdev_max: maximum of @mdev during one flight
- * @ccid2hctx_rttvar: moving average/maximum of @mdev_max
- * @ccid2hctx_rto: RTO value deriving from SRTT and RTTVAR (RFC 2988)
- * @ccid2hctx_rtt_seq: to decay RTTVAR at most once per flight
- * @ccid2hctx_rpseq - last consecutive seqno
- * @ccid2hctx_rpdupack - dupacks since rpseq
- * @ccid2hctx_av_chunks: list of Ack Vectors received on current skb
+ * @{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
+ * @packets_acked: Ack counter for deriving cwnd growth (RFC 3465)
+ * @srtt: smoothed RTT estimate, scaled by 2^3
+ * @mdev: smoothed RTT variation, scaled by 2^2
+ * @mdev_max: maximum of @mdev during one flight
+ * @rttvar: moving average/maximum of @mdev_max
+ * @rto: RTO value deriving from SRTT and RTTVAR (RFC 2988)
+ * @rtt_seq: to decay RTTVAR at most once per flight
+ * @rpseq - last consecutive seqno
+ * @rpdupack - dupacks since rpseq
+ * @av_chunks: list of Ack Vectors received on current skb
 */
 struct ccid2_hc_tx_sock {
-	u32			ccid2hctx_cwnd;
-	u32			ccid2hctx_ssthresh;
-	u32			ccid2hctx_pipe;
-	u32			ccid2hctx_packets_acked;
-	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
-	int			ccid2hctx_seqbufc;
-	struct ccid2_seq	*ccid2hctx_seqh;
-	struct ccid2_seq	*ccid2hctx_seqt;
+	u32			cwnd;
+	u32			ssthresh;
+	u32			pipe;
+	u32			packets_acked;
+	struct ccid2_seq	*seqbuf[CCID2_SEQBUF_MAX];
+	int			seqbufc;
+	struct ccid2_seq	*seqh;
+	struct ccid2_seq	*seqt;
 	/* RTT measurement: variables/principles are the same as in TCP */
-	u32			ccid2hctx_srtt,
-				ccid2hctx_mdev,
-				ccid2hctx_mdev_max,
-				ccid2hctx_rttvar,
-				ccid2hctx_rto;
-	u64			ccid2hctx_rtt_seq:48;
-	struct timer_list	ccid2hctx_rtotimer;
-	u64			ccid2hctx_rpseq;
-	int			ccid2hctx_rpdupack;
-	unsigned long		ccid2hctx_last_cong;
-	u64			ccid2hctx_high_ack;
-	struct list_head	ccid2hctx_av_chunks;
+	u32			srtt,
+				mdev,
+				mdev_max,
+				rttvar,
+				rto;
+	u64			rtt_seq:48;
+	struct timer_list	rtotimer;
+	u64			rpseq;
+	int			rpdupack;
+	unsigned long		last_cong;
+	u64			high_ack;
+	struct list_head	av_chunks;
 };
 
 static inline bool ccid2_cwnd_network_limited(struct ccid2_hc_tx_sock *hctx)
 {
-	return (hctx->ccid2hctx_pipe >= hctx->ccid2hctx_cwnd);
+	return (hctx->pipe >= hctx->cwnd);
 }
 
 struct ccid2_hc_rx_sock {
-	int	ccid2hcrx_data;
+	int	data;
 };
 
 static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -44,8 +44,7 @@ static int ccid2_hc_tx_alloc_seq(struct 
 	int i;
 
 	/* check if we have space to preserve the pointer to the buffer */
-	if (hctx->ccid2hctx_seqbufc >= (sizeof(hctx->ccid2hctx_seqbuf) /
-					sizeof(struct ccid2_seq*)))
+	if (hctx->seqbufc >= (sizeof(hctx->seqbuf) / sizeof(struct ccid2_seq*)))
 		return -ENOMEM;
 
 	/* allocate buffer and initialize linked list */
@@ -61,20 +60,20 @@ static int ccid2_hc_tx_alloc_seq(struct 
 	seqp->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
 
 	/* This is the first allocation.  Initiate the head and tail.  */
-	if (hctx->ccid2hctx_seqbufc = 0)
-		hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt = seqp;
+	if (hctx->seqbufc = 0)
+		hctx->seqh = hctx->seqt = seqp;
 	else {
 		/* link the existing list with the one we just created */
-		hctx->ccid2hctx_seqh->ccid2s_next = seqp;
-		seqp->ccid2s_prev = hctx->ccid2hctx_seqh;
+		hctx->seqh->ccid2s_next = seqp;
+		seqp->ccid2s_prev = hctx->seqh;
 
-		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
-		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->ccid2hctx_seqt;
+		hctx->seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
+		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->seqt;
 	}
 
 	/* store the original pointer to the buffer so we can free it */
-	hctx->ccid2hctx_seqbuf[hctx->ccid2hctx_seqbufc] = seqp;
-	hctx->ccid2hctx_seqbufc++;
+	hctx->seqbuf[hctx->seqbufc] = seqp;
+	hctx->seqbufc++;
 
 	return 0;
 }
@@ -89,7 +88,7 @@ static int ccid2_hc_tx_send_packet(struc
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->ccid2hctx_cwnd, 2);
+	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->cwnd, 2);
 
 	/*
 	 * Ensure that Ack Ratio does not exceed ceil(cwnd/2), which is (2) from
@@ -119,40 +118,38 @@ static void ccid2_hc_tx_rto_expire(unsig
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
-		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-			       jiffies + HZ / 5);
+		sk_reset_timer(sk, &hctx->rtotimer, jiffies + HZ / 5);
 		goto out;
 	}
 
 	ccid2_pr_debug("RTO_EXPIRE\n");
 
 	/* back-off timer */
-	hctx->ccid2hctx_rto <<= 1;
-	if (hctx->ccid2hctx_rto > DCCP_RTO_MAX)
-		hctx->ccid2hctx_rto = DCCP_RTO_MAX;
+	hctx->rto <<= 1;
+	if (hctx->rto > DCCP_RTO_MAX)
+		hctx->rto = DCCP_RTO_MAX;
 
 	/* adjust pipe, cwnd etc */
-	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
-	if (hctx->ccid2hctx_ssthresh < 2)
-		hctx->ccid2hctx_ssthresh = 2;
-	hctx->ccid2hctx_cwnd	 = 1;
-	hctx->ccid2hctx_pipe	 = 0;
+	hctx->ssthresh = hctx->cwnd / 2;
+	if (hctx->ssthresh < 2)
+		hctx->ssthresh = 2;
+	hctx->cwnd = 1;
+	hctx->pipe = 0;
 
 	/* clear state about stuff we sent */
-	hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqh;
-	hctx->ccid2hctx_packets_acked = 0;
+	hctx->seqt = hctx->seqh;
+	hctx->packets_acked = 0;
 
 	/* clear ack ratio state. */
-	hctx->ccid2hctx_rpseq	 = 0;
-	hctx->ccid2hctx_rpdupack = -1;
+	hctx->rpseq    = 0;
+	hctx->rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
 
 	/* if we were blocked before, we may now send cwnd=1 packet */
 	if (sender_was_blocked)
 		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
 	/* restart backed-off timer */
-	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-		       jiffies + hctx->ccid2hctx_rto);
+	sk_reset_timer(sk, &hctx->rtotimer, jiffies + hctx->rto);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -164,27 +161,26 @@ static void ccid2_hc_tx_packet_sent(stru
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	struct ccid2_seq *next;
 
-	hctx->ccid2hctx_pipe++;
+	hctx->pipe++;
 
-	hctx->ccid2hctx_seqh->ccid2s_seq   = dp->dccps_gss;
-	hctx->ccid2hctx_seqh->ccid2s_acked = 0;
-	hctx->ccid2hctx_seqh->ccid2s_sent  = jiffies;
+	hctx->seqh->ccid2s_seq   = dp->dccps_gss;
+	hctx->seqh->ccid2s_acked = 0;
+	hctx->seqh->ccid2s_sent  = jiffies;
 
-	next = hctx->ccid2hctx_seqh->ccid2s_next;
+	next = hctx->seqh->ccid2s_next;
 	/* check if we need to alloc more space */
-	if (next = hctx->ccid2hctx_seqt) {
+	if (next = hctx->seqt) {
 		if (ccid2_hc_tx_alloc_seq(hctx)) {
 			DCCP_CRIT("packet history - out of memory!");
 			/* FIXME: find a more graceful way to bail out */
 			return;
 		}
-		next = hctx->ccid2hctx_seqh->ccid2s_next;
-		BUG_ON(next = hctx->ccid2hctx_seqt);
+		next = hctx->seqh->ccid2s_next;
+		BUG_ON(next = hctx->seqt);
 	}
-	hctx->ccid2hctx_seqh = next;
+	hctx->seqh = next;
 
-	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->ccid2hctx_cwnd,
-		       hctx->ccid2hctx_pipe);
+	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->cwnd, hctx->pipe);
 
 	/*
 	 * FIXME: The code below is broken and the variables have been removed
@@ -207,12 +203,12 @@ static void ccid2_hc_tx_packet_sent(stru
 	 */
 #if 0
 	/* Ack Ratio.  Need to maintain a concept of how many windows we sent */
-	hctx->ccid2hctx_arsent++;
+	hctx->arsent++;
 	/* We had an ack loss in this window... */
-	if (hctx->ccid2hctx_ackloss) {
-		if (hctx->ccid2hctx_arsent >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_arsent	= 0;
-			hctx->ccid2hctx_ackloss	= 0;
+	if (hctx->ackloss) {
+		if (hctx->arsent >= hctx->cwnd) {
+			hctx->arsent  = 0;
+			hctx->ackloss = 0;
 		}
 	} else {
 		/* No acks lost up to now... */
@@ -222,29 +218,28 @@ static void ccid2_hc_tx_packet_sent(stru
 			int denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio -
 				    dp->dccps_l_ack_ratio;
 
-			denom = hctx->ccid2hctx_cwnd * hctx->ccid2hctx_cwnd / denom;
+			denom = hctx->cwnd * hctx->cwnd / denom;
 
-			if (hctx->ccid2hctx_arsent >= denom) {
+			if (hctx->arsent >= denom) {
 				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio - 1);
-				hctx->ccid2hctx_arsent = 0;
+				hctx->arsent = 0;
 			}
 		} else {
 			/* we can't increase ack ratio further [1] */
-			hctx->ccid2hctx_arsent = 0; /* or maybe set it to cwnd*/
+			hctx->arsent = 0; /* or maybe set it to cwnd*/
 		}
 	}
 #endif
 
 	/* setup RTO timer */
-	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
-		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-			       jiffies + hctx->ccid2hctx_rto);
+	if (!timer_pending(&hctx->rtotimer))
+		sk_reset_timer(sk, &hctx->rtotimer, jiffies + hctx->rto);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	do {
-		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
+		struct ccid2_seq *seqp = hctx->seqt;
 
-		while (seqp != hctx->ccid2hctx_seqh) {
+		while (seqp != hctx->seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
 				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
@@ -269,23 +264,23 @@ static void ccid2_rtt_estimator(struct s
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	long m = mrtt ? : 1;
 
-	if (hctx->ccid2hctx_srtt = 0) {
+	if (hctx->srtt = 0) {
 		/* First measurement m */
-		hctx->ccid2hctx_srtt = m << 3;
-		hctx->ccid2hctx_mdev = m << 1;
+		hctx->srtt = m << 3;
+		hctx->mdev = m << 1;
 
-		hctx->ccid2hctx_mdev_max = max(TCP_RTO_MIN, hctx->ccid2hctx_mdev);
-		hctx->ccid2hctx_rttvar	 = hctx->ccid2hctx_mdev_max;
-		hctx->ccid2hctx_rtt_seq	 = dccp_sk(sk)->dccps_gss;
+		hctx->mdev_max = max(TCP_RTO_MIN, hctx->mdev);
+		hctx->rttvar   = hctx->mdev_max;
+		hctx->rtt_seq  = dccp_sk(sk)->dccps_gss;
 	} else {
 		/* Update scaled SRTT as SRTT += 1/8 * (m - SRTT) */
-		m -= (hctx->ccid2hctx_srtt >> 3);
-		hctx->ccid2hctx_srtt += m;
+		m -= (hctx->srtt >> 3);
+		hctx->srtt += m;
 
 		/* Similarly, update scaled mdev with regard to |m| */
 		if (m < 0) {
 			m = -m;
-			m -= (hctx->ccid2hctx_mdev >> 2);
+			m -= (hctx->mdev >> 2);
 			/*
 			 * This neutralises RTO increase when RTT < SRTT - mdev
 			 * (see P. Sarolahti and * A. Kuznetsov,
@@ -295,14 +290,14 @@ static void ccid2_rtt_estimator(struct s
 			if (m > 0)
 				m >>= 3;
 		} else {
-			m -= (hctx->ccid2hctx_mdev >> 2);
+			m -= (hctx->mdev >> 2);
 		}
-		hctx->ccid2hctx_mdev += m;
+		hctx->mdev += m;
 
-		if (hctx->ccid2hctx_mdev > hctx->ccid2hctx_mdev_max) {
-			hctx->ccid2hctx_mdev_max = hctx->ccid2hctx_mdev;
-			if (hctx->ccid2hctx_mdev_max > hctx->ccid2hctx_rttvar)
-				hctx->ccid2hctx_rttvar = hctx->ccid2hctx_mdev_max;
+		if (hctx->mdev > hctx->mdev_max) {
+			hctx->mdev_max = hctx->mdev;
+			if (hctx->mdev_max > hctx->rttvar)
+				hctx->rttvar = hctx->mdev_max;
 		}
 
 		/*
@@ -312,11 +307,12 @@ static void ccid2_rtt_estimator(struct s
 		 * GAR is a useful bound for FlightSize = pipe, AWL is probably
 		 * too low as it over-estimates pipe.
 		 */
-		if (after48(dccp_sk(sk)->dccps_gar, hctx->ccid2hctx_rtt_seq)) {
-			if (hctx->ccid2hctx_mdev_max < hctx->ccid2hctx_rttvar)
-				hctx->ccid2hctx_rttvar -= (hctx->ccid2hctx_rttvar - hctx->ccid2hctx_mdev_max) >> 2;
-			hctx->ccid2hctx_rtt_seq  = dccp_sk(sk)->dccps_gss;
-			hctx->ccid2hctx_mdev_max = TCP_RTO_MIN;
+		if (after48(dccp_sk(sk)->dccps_gar, hctx->rtt_seq)) {
+			if (hctx->mdev_max < hctx->rttvar)
+				hctx->rttvar -= (hctx->rttvar -
+						 hctx->mdev_max) >> 2;
+			hctx->rtt_seq  = dccp_sk(sk)->dccps_gss;
+			hctx->mdev_max = TCP_RTO_MIN;
 		}
 	}
 
@@ -328,10 +324,10 @@ static void ccid2_rtt_estimator(struct s
 	 * does not retransmit data, DCCP does not require TCP's recommended
 	 * minimum timeout of one second".
 	 */
-	hctx->ccid2hctx_rto = (hctx->ccid2hctx_srtt >> 3) + hctx->ccid2hctx_rttvar;
+	hctx->rto = (hctx->srtt >> 3) + hctx->rttvar;
 
-	if (hctx->ccid2hctx_rto > DCCP_RTO_MAX)
-		hctx->ccid2hctx_rto = DCCP_RTO_MAX;
+	if (hctx->rto > DCCP_RTO_MAX)
+		hctx->rto = DCCP_RTO_MAX;
 }
 
 static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
@@ -339,15 +335,15 @@ static void ccid2_new_ack(struct sock *s
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
-		if (*maxincr > 0 && ++hctx->ccid2hctx_packets_acked = 2) {
-			hctx->ccid2hctx_cwnd += 1;
-			*maxincr	     -= 1;
-			hctx->ccid2hctx_packets_acked = 0;
-		}
-	} else if (++hctx->ccid2hctx_packets_acked >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_cwnd += 1;
-			hctx->ccid2hctx_packets_acked = 0;
+	if (hctx->cwnd < hctx->ssthresh) {
+		if (*maxincr > 0 && ++hctx->packets_acked = 2) {
+			hctx->cwnd += 1;
+			*maxincr   -= 1;
+			hctx->packets_acked = 0;
+		}
+	} else if (++hctx->packets_acked >= hctx->cwnd) {
+			hctx->cwnd += 1;
+			hctx->packets_acked = 0;
 	}
 	/*
 	 * FIXME: RTT is sampled several times per acknowledgment (for each
@@ -364,19 +360,19 @@ static void ccid2_congestion_event(struc
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
+	if (time_before(seqp->ccid2s_sent, hctx->last_cong)) {
 		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
 		return;
 	}
 
-	hctx->ccid2hctx_last_cong = jiffies;
+	hctx->last_cong = jiffies;
 
-	hctx->ccid2hctx_cwnd     = hctx->ccid2hctx_cwnd / 2 ? : 1U;
-	hctx->ccid2hctx_ssthresh = max(hctx->ccid2hctx_cwnd, 2U);
+	hctx->cwnd     = hctx->cwnd / 2 ? : 1U;
+	hctx->ssthresh = max(hctx->cwnd, 2U);
 
 	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
-	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->ccid2hctx_cwnd)
-		ccid2_change_l_ack_ratio(sk, hctx->ccid2hctx_cwnd);
+	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->cwnd)
+		ccid2_change_l_ack_ratio(sk, hctx->cwnd);
 }
 
 static int ccid2_hc_tx_parse_options(struct sock *sk, unsigned char option,
@@ -388,8 +384,8 @@ static int ccid2_hc_tx_parse_options(str
 	switch (option) {
 	case DCCPO_ACK_VECTOR_0:
 	case DCCPO_ACK_VECTOR_1:
-		return dccp_ackvec_parsed_add(&hctx->ccid2hctx_av_chunks, value,
-					      len, option - DCCPO_ACK_VECTOR_0);
+		return dccp_ackvec_parsed_add(&hctx->av_chunks, value, len,
+					      option - DCCPO_ACK_VECTOR_0);
 	}
 	return 0;
 }
@@ -413,21 +409,21 @@ static void ccid2_hc_tx_packet_recv(stru
 	 * -sorbo.
 	 */
 	/* need to bootstrap */
-	if (hctx->ccid2hctx_rpdupack = -1) {
-		hctx->ccid2hctx_rpdupack = 0;
-		hctx->ccid2hctx_rpseq = seqno;
+	if (hctx->rpdupack = -1) {
+		hctx->rpdupack = 0;
+		hctx->rpseq = seqno;
 	} else {
 		/* check if packet is consecutive */
-		if (dccp_delta_seqno(hctx->ccid2hctx_rpseq, seqno) = 1)
-			hctx->ccid2hctx_rpseq = seqno;
+		if (dccp_delta_seqno(hctx->rpseq, seqno) = 1)
+			hctx->rpseq = seqno;
 		/* it's a later packet */
-		else if (after48(seqno, hctx->ccid2hctx_rpseq)) {
-			hctx->ccid2hctx_rpdupack++;
+		else if (after48(seqno, hctx->rpseq)) {
+			hctx->rpdupack++;
 
 			/* check if we got enough dupacks */
-			if (hctx->ccid2hctx_rpdupack >= NUMDUPACK) {
-				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
-				hctx->ccid2hctx_rpseq = 0;
+			if (hctx->rpdupack >= NUMDUPACK) {
+				hctx->rpdupack = -1; /* XXX lame */
+				hctx->rpseq = 0;
 
 				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
 			}
@@ -439,18 +435,18 @@ static void ccid2_hc_tx_packet_recv(stru
 		return;
 
 	/* still didn't send out new data packets */
-	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
+	if (hctx->seqh = hctx->seqt)
 		goto done;
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
-	if (after48(ackno, hctx->ccid2hctx_high_ack))
-		hctx->ccid2hctx_high_ack = ackno;
+	if (after48(ackno, hctx->high_ack))
+		hctx->high_ack = ackno;
 
-	seqp = hctx->ccid2hctx_seqt;
+	seqp = hctx->seqt;
 	while (before48(seqp->ccid2s_seq, ackno)) {
 		seqp = seqp->ccid2s_next;
-		if (seqp = hctx->ccid2hctx_seqh) {
-			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+		if (seqp = hctx->seqh) {
+			seqp = hctx->seqh->ccid2s_prev;
 			break;
 		}
 	}
@@ -460,11 +456,11 @@ static void ccid2_hc_tx_packet_recv(stru
 	 * packets per acknowledgement. Rounding up avoids that cwnd is not
 	 * advanced when Ack Ratio is 1 and gives a slight edge otherwise.
 	 */
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh)
+	if (hctx->cwnd < hctx->ssthresh)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
-	list_for_each_entry(avp, &hctx->ccid2hctx_av_chunks, node) {
+	list_for_each_entry(avp, &hctx->av_chunks, node) {
 		/* go through this ack vector */
 		for (; avp->len--; avp->vec++) {
 			u64 ackno_end_rl = SUB48(ackno,
@@ -479,7 +475,7 @@ static void ccid2_hc_tx_packet_recv(stru
 			 * seqnos.
 			 */
 			while (after48(seqp->ccid2s_seq, ackno)) {
-				if (seqp = hctx->ccid2hctx_seqt) {
+				if (seqp = hctx->seqt) {
 					done = 1;
 					break;
 				}
@@ -507,9 +503,9 @@ static void ccid2_hc_tx_packet_recv(stru
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
 						       (unsigned long long)seqp->ccid2s_seq);
-					hctx->ccid2hctx_pipe--;
+					hctx->pipe--;
 				}
-				if (seqp = hctx->ccid2hctx_seqt) {
+				if (seqp = hctx->seqt) {
 					done = 1;
 					break;
 				}
@@ -527,11 +523,11 @@ static void ccid2_hc_tx_packet_recv(stru
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
-	seqp = hctx->ccid2hctx_seqt;
-	while (before48(seqp->ccid2s_seq, hctx->ccid2hctx_high_ack)) {
+	seqp = hctx->seqt;
+	while (before48(seqp->ccid2s_seq, hctx->high_ack)) {
 		seqp = seqp->ccid2s_next;
-		if (seqp = hctx->ccid2hctx_seqh) {
-			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+		if (seqp = hctx->seqh) {
+			seqp = hctx->seqh->ccid2s_prev;
 			break;
 		}
 	}
@@ -542,7 +538,7 @@ static void ccid2_hc_tx_packet_recv(stru
 			if (done = NUMDUPACK)
 				break;
 		}
-		if (seqp = hctx->ccid2hctx_seqt)
+		if (seqp = hctx->seqt)
 			break;
 		seqp = seqp->ccid2s_prev;
 	}
@@ -563,35 +559,34 @@ static void ccid2_hc_tx_packet_recv(stru
 				 * one ack vector.
 				 */
 				ccid2_congestion_event(sk, seqp);
-				hctx->ccid2hctx_pipe--;
+				hctx->pipe--;
 			}
-			if (seqp = hctx->ccid2hctx_seqt)
+			if (seqp = hctx->seqt)
 				break;
 			seqp = seqp->ccid2s_prev;
 		}
 
-		hctx->ccid2hctx_seqt = last_acked;
+		hctx->seqt = last_acked;
 	}
 
 	/* trim acked packets in tail */
-	while (hctx->ccid2hctx_seqt != hctx->ccid2hctx_seqh) {
-		if (!hctx->ccid2hctx_seqt->ccid2s_acked)
+	while (hctx->seqt != hctx->seqh) {
+		if (!hctx->seqt->ccid2s_acked)
 			break;
 
-		hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqt->ccid2s_next;
+		hctx->seqt = hctx->seqt->ccid2s_next;
 	}
 
 	/* restart RTO timer if not all outstanding data has been acked */
-	if (hctx->ccid2hctx_pipe = 0)
-		sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
+	if (hctx->pipe = 0)
+		sk_stop_timer(sk, &hctx->rtotimer);
 	else
-		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-			       jiffies + hctx->ccid2hctx_rto);
+		sk_reset_timer(sk, &hctx->rtotimer, jiffies + hctx->rto);
 done:
 	/* check if incoming Acks allow pending packets to be sent */
 	if (sender_was_blocked && !ccid2_cwnd_network_limited(hctx))
 		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
-	dccp_ackvec_parsed_cleanup(&hctx->ccid2hctx_av_chunks);
+	dccp_ackvec_parsed_cleanup(&hctx->av_chunks);
 }
 
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
@@ -601,17 +596,17 @@ static int ccid2_hc_tx_init(struct ccid 
 	u32 max_ratio;
 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
-	hctx->ccid2hctx_ssthresh  = ~0U;
+	hctx->ssthresh  = ~0U;
 
 	/*
 	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
 	 * packets for new connections, following the rules from [RFC3390]".
 	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
 	 */
-	hctx->ccid2hctx_cwnd = min(4U, max(2U, 4380U / dp->dccps_mss_cache));
+	hctx->cwnd = min(4U, max(2U, 4380U / dp->dccps_mss_cache));
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
-	max_ratio = DIV_ROUND_UP(hctx->ccid2hctx_cwnd, 2);
+	max_ratio = DIV_ROUND_UP(hctx->cwnd, 2);
 	if (dp->dccps_l_ack_ratio = 0 || dp->dccps_l_ack_ratio > max_ratio)
 		dp->dccps_l_ack_ratio = max_ratio;
 
@@ -619,12 +614,11 @@ static int ccid2_hc_tx_init(struct ccid 
 	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
-	hctx->ccid2hctx_rto	 = DCCP_TIMEOUT_INIT;
-	hctx->ccid2hctx_rpdupack = -1;
-	hctx->ccid2hctx_last_cong = jiffies;
-	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
-			(unsigned long)sk);
-	INIT_LIST_HEAD(&hctx->ccid2hctx_av_chunks);
+	hctx->rto       = DCCP_TIMEOUT_INIT;
+	hctx->rpdupack  = -1;
+	hctx->last_cong = jiffies;
+	setup_timer(&hctx->rtotimer, ccid2_hc_tx_rto_expire, (unsigned long)sk);
+	INIT_LIST_HEAD(&hctx->av_chunks);
 	return 0;
 }
 
@@ -633,11 +627,11 @@ static void ccid2_hc_tx_exit(struct sock
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	int i;
 
-	sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
+	sk_stop_timer(sk, &hctx->rtotimer);
 
-	for (i = 0; i < hctx->ccid2hctx_seqbufc; i++)
-		kfree(hctx->ccid2hctx_seqbuf[i]);
-	hctx->ccid2hctx_seqbufc = 0;
+	for (i = 0; i < hctx->seqbufc; i++)
+		kfree(hctx->seqbuf[i]);
+	hctx->seqbufc = 0;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -648,10 +642,10 @@ static void ccid2_hc_rx_packet_recv(stru
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
 	case DCCP_PKT_DATA:
 	case DCCP_PKT_DATAACK:
-		hcrx->ccid2hcrx_data++;
-		if (hcrx->ccid2hcrx_data >= dp->dccps_r_ack_ratio) {
+		hcrx->data++;
+		if (hcrx->data >= dp->dccps_r_ack_ratio) {
 			dccp_send_ack(sk);
-			hcrx->ccid2hcrx_data = 0;
+			hcrx->data = 0;
 		}
 		break;
 	}
