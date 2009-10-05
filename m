From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Oct 2009 10:53:12 +0000
Subject: [PATCH 3/4][RFC] dccp ccid-2: Remove CCID naming redundancy 1/2
Message-Id: <1254739993-5051-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes a redundancy in the CCID half-connection (hc) naming scheme:
 * instead of 'hctx->tx_...', write 'hc->tx_...';
 * instead of 'hcrx->rx_...', write 'hc->rx_...';

which works because the 'type' of the half-connection is encoded in the
'rx_' / 'tx_' prefixes.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |  322 ++++++++++++++++++++++++------------------------
 1 files changed, 161 insertions(+), 161 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -33,20 +33,20 @@
 static int ccid2_debug;
 #define ccid2_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid2_debug, format, ##a)
 
-static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
+static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hc)
 {
 	int len = 0;
 	int pipe = 0;
-	struct ccid2_seq *seqp = hctx->tx_seqh;
+	struct ccid2_seq *seqp = hc->tx_seqh;
 
 	/* there is data in the chain */
-	if (seqp != hctx->tx_seqt) {
+	if (seqp != hc->tx_seqt) {
 		seqp = seqp->ccid2s_prev;
 		len++;
 		if (!seqp->ccid2s_acked)
 			pipe++;
 
-		while (seqp != hctx->tx_seqt) {
+		while (seqp != hc->tx_seqt) {
 			struct ccid2_seq *prev = seqp->ccid2s_prev;
 
 			len++;
@@ -63,30 +63,30 @@ static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 		}
 	}
 
-	BUG_ON(pipe != hctx->tx_pipe);
+	BUG_ON(pipe != hc->tx_pipe);
 	ccid2_pr_debug("len of chain=%d\n", len);
 
 	do {
 		seqp = seqp->ccid2s_prev;
 		len++;
-	} while (seqp != hctx->tx_seqh);
+	} while (seqp != hc->tx_seqh);
 
 	ccid2_pr_debug("total len=%d\n", len);
-	BUG_ON(len != hctx->tx_seqbufc * CCID2_SEQBUF_LEN);
+	BUG_ON(len != hc->tx_seqbufc * CCID2_SEQBUF_LEN);
 }
 #else
 #define ccid2_pr_debug(format, a...)
-#define ccid2_hc_tx_check_sanity(hctx)
+#define ccid2_hc_tx_check_sanity(hc)
 #endif
 
-static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
+static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hc)
 {
 	struct ccid2_seq *seqp;
 	int i;
 
 	/* check if we have space to preserve the pointer to the buffer */
-	if (hctx->tx_seqbufc >= (sizeof(hctx->tx_seqbuf) /
-				 sizeof(struct ccid2_seq *)))
+	if (hc->tx_seqbufc >= (sizeof(hc->tx_seqbuf) /
+			       sizeof(struct ccid2_seq *)))
 		return -ENOMEM;
 
 	/* allocate buffer and initialize linked list */
@@ -102,29 +102,29 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 	seqp->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
 
 	/* This is the first allocation.  Initiate the head and tail.  */
-	if (hctx->tx_seqbufc = 0)
-		hctx->tx_seqh = hctx->tx_seqt = seqp;
+	if (hc->tx_seqbufc = 0)
+		hc->tx_seqh = hc->tx_seqt = seqp;
 	else {
 		/* link the existing list with the one we just created */
-		hctx->tx_seqh->ccid2s_next = seqp;
-		seqp->ccid2s_prev = hctx->tx_seqh;
+		hc->tx_seqh->ccid2s_next = seqp;
+		seqp->ccid2s_prev = hc->tx_seqh;
 
-		hctx->tx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
-		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->tx_seqt;
+		hc->tx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
+		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hc->tx_seqt;
 	}
 
 	/* store the original pointer to the buffer so we can free it */
-	hctx->tx_seqbuf[hctx->tx_seqbufc] = seqp;
-	hctx->tx_seqbufc++;
+	hc->tx_seqbuf[hc->tx_seqbufc] = seqp;
+	hc->tx_seqbufc++;
 
 	return 0;
 }
 
 static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	if (hctx->tx_pipe < hctx->tx_cwnd)
+	if (hc->tx_pipe < hc->tx_cwnd)
 		return 0;
 
 	return 1; /* XXX CCID should dequeue when ready instead of polling */
@@ -155,10 +155,10 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
+static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hc, long val)
 {
 	ccid2_pr_debug("change SRTT to %ld\n", val);
-	hctx->tx_srtt = val;
+	hc->tx_srtt = val;
 }
 
 static void ccid2_start_rto_timer(struct sock *sk);
@@ -166,44 +166,44 @@ static void ccid2_start_rto_timer(struct sock *sk);
 static void ccid2_hc_tx_rto_expire(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	long s;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
-		sk_reset_timer(sk, &hctx->tx_rtotimer, jiffies + HZ / 5);
+		sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + HZ / 5);
 		goto out;
 	}
 
 	ccid2_pr_debug("RTO_EXPIRE\n");
 
-	ccid2_hc_tx_check_sanity(hctx);
+	ccid2_hc_tx_check_sanity(hc);
 
 	/* back-off timer */
-	hctx->tx_rto <<= 1;
+	hc->tx_rto <<= 1;
 
-	s = hctx->tx_rto / HZ;
+	s = hc->tx_rto / HZ;
 	if (s > 60)
-		hctx->tx_rto = 60 * HZ;
+		hc->tx_rto = 60 * HZ;
 
 	ccid2_start_rto_timer(sk);
 
 	/* adjust pipe, cwnd etc */
-	hctx->tx_ssthresh = hctx->tx_cwnd / 2;
-	if (hctx->tx_ssthresh < 2)
-		hctx->tx_ssthresh = 2;
-	hctx->tx_cwnd	 = 1;
-	hctx->tx_pipe	 = 0;
+	hc->tx_ssthresh = hc->tx_cwnd / 2;
+	if (hc->tx_ssthresh < 2)
+		hc->tx_ssthresh = 2;
+	hc->tx_cwnd	 = 1;
+	hc->tx_pipe	 = 0;
 
 	/* clear state about stuff we sent */
-	hctx->tx_seqt = hctx->tx_seqh;
-	hctx->tx_packets_acked = 0;
+	hc->tx_seqt = hc->tx_seqh;
+	hc->tx_packets_acked = 0;
 
 	/* clear ack ratio state. */
-	hctx->tx_rpseq    = 0;
-	hctx->tx_rpdupack = -1;
+	hc->tx_rpseq    = 0;
+	hc->tx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
-	ccid2_hc_tx_check_sanity(hctx);
+	ccid2_hc_tx_check_sanity(hc);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -211,40 +211,40 @@ out:
 
 static void ccid2_start_rto_timer(struct sock *sk)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->tx_rto);
+	ccid2_pr_debug("setting RTO timeout=%ld\n", hc->tx_rto);
 
-	BUG_ON(timer_pending(&hctx->tx_rtotimer));
-	sk_reset_timer(sk, &hctx->tx_rtotimer, jiffies + hctx->tx_rto);
+	BUG_ON(timer_pending(&hc->tx_rtotimer));
+	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
 }
 
 static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	struct ccid2_seq *next;
 
-	hctx->tx_pipe++;
+	hc->tx_pipe++;
 
-	hctx->tx_seqh->ccid2s_seq   = dp->dccps_gss;
-	hctx->tx_seqh->ccid2s_acked = 0;
-	hctx->tx_seqh->ccid2s_sent  = jiffies;
+	hc->tx_seqh->ccid2s_seq   = dp->dccps_gss;
+	hc->tx_seqh->ccid2s_acked = 0;
+	hc->tx_seqh->ccid2s_sent  = jiffies;
 
-	next = hctx->tx_seqh->ccid2s_next;
+	next = hc->tx_seqh->ccid2s_next;
 	/* check if we need to alloc more space */
-	if (next = hctx->tx_seqt) {
-		if (ccid2_hc_tx_alloc_seq(hctx)) {
+	if (next = hc->tx_seqt) {
+		if (ccid2_hc_tx_alloc_seq(hc)) {
 			DCCP_CRIT("packet history - out of memory!");
 			/* FIXME: find a more graceful way to bail out */
 			return;
 		}
-		next = hctx->tx_seqh->ccid2s_next;
-		BUG_ON(next = hctx->tx_seqt);
+		next = hc->tx_seqh->ccid2s_next;
+		BUG_ON(next = hc->tx_seqt);
 	}
-	hctx->tx_seqh = next;
+	hc->tx_seqh = next;
 
-	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->tx_cwnd, hctx->tx_pipe);
+	ccid2_pr_debug("cwnd=%d pipe=%d\n", hc->tx_cwnd, hc->tx_pipe);
 
 	/*
 	 * FIXME: The code below is broken and the variables have been removed
@@ -267,12 +267,12 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	 */
 #if 0
 	/* Ack Ratio.  Need to maintain a concept of how many windows we sent */
-	hctx->tx_arsent++;
+	hc->tx_arsent++;
 	/* We had an ack loss in this window... */
-	if (hctx->tx_ackloss) {
-		if (hctx->tx_arsent >= hctx->tx_cwnd) {
-			hctx->tx_arsent  = 0;
-			hctx->tx_ackloss = 0;
+	if (hc->tx_ackloss) {
+		if (hc->tx_arsent >= hc->tx_cwnd) {
+			hc->tx_arsent  = 0;
+			hc->tx_ackloss = 0;
 		}
 	} else {
 		/* No acks lost up to now... */
@@ -282,28 +282,28 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 			int denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio -
 				    dp->dccps_l_ack_ratio;
 
-			denom = hctx->tx_cwnd * hctx->tx_cwnd / denom;
+			denom = hc->tx_cwnd * hc->tx_cwnd / denom;
 
-			if (hctx->tx_arsent >= denom) {
+			if (hc->tx_arsent >= denom) {
 				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio - 1);
-				hctx->tx_arsent = 0;
+				hc->tx_arsent = 0;
 			}
 		} else {
 			/* we can't increase ack ratio further [1] */
-			hctx->tx_arsent = 0; /* or maybe set it to cwnd*/
+			hc->tx_arsent = 0; /* or maybe set it to cwnd*/
 		}
 	}
 #endif
 
 	/* setup RTO timer */
-	if (!timer_pending(&hctx->tx_rtotimer))
+	if (!timer_pending(&hc->tx_rtotimer))
 		ccid2_start_rto_timer(sk);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	do {
-		struct ccid2_seq *seqp = hctx->tx_seqt;
+		struct ccid2_seq *seqp = hc->tx_seqt;
 
-		while (seqp != hctx->tx_seqh) {
+		while (seqp != hc->tx_seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
 				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
@@ -311,7 +311,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 		}
 	} while (0);
 	ccid2_pr_debug("=====\n");
-	ccid2_hc_tx_check_sanity(hctx);
+	ccid2_hc_tx_check_sanity(hc);
 #endif
 }
 
@@ -379,9 +379,9 @@ out_invalid_option:
 
 static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	sk_stop_timer(sk, &hctx->tx_rtotimer);
+	sk_stop_timer(sk, &hc->tx_rtotimer);
 	ccid2_pr_debug("deleted RTO timer\n");
 }
 
@@ -389,75 +389,75 @@ static inline void ccid2_new_ack(struct sock *sk,
 				 struct ccid2_seq *seqp,
 				 unsigned int *maxincr)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	if (hctx->tx_cwnd < hctx->tx_ssthresh) {
-		if (*maxincr > 0 && ++hctx->tx_packets_acked = 2) {
-			hctx->tx_cwnd += 1;
-			*maxincr      -= 1;
-			hctx->tx_packets_acked = 0;
+	if (hc->tx_cwnd < hc->tx_ssthresh) {
+		if (*maxincr > 0 && ++hc->tx_packets_acked = 2) {
+			hc->tx_cwnd += 1;
+			*maxincr    -= 1;
+			hc->tx_packets_acked = 0;
 		}
-	} else if (++hctx->tx_packets_acked >= hctx->tx_cwnd) {
-			hctx->tx_cwnd += 1;
-			hctx->tx_packets_acked = 0;
+	} else if (++hc->tx_packets_acked >= hc->tx_cwnd) {
+			hc->tx_cwnd += 1;
+			hc->tx_packets_acked = 0;
 	}
 
 	/* update RTO */
-	if (hctx->tx_srtt = -1 ||
-	    time_after(jiffies, hctx->tx_lastrtt + hctx->tx_srtt)) {
+	if (hc->tx_srtt = -1 ||
+	    time_after(jiffies, hc->tx_lastrtt + hc->tx_srtt)) {
 		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 		int s;
 
 		/* first measurement */
-		if (hctx->tx_srtt = -1) {
+		if (hc->tx_srtt = -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
 				       r, jiffies,
 				       (unsigned long long)seqp->ccid2s_seq);
-			ccid2_change_srtt(hctx, r);
-			hctx->tx_rttvar = r >> 1;
+			ccid2_change_srtt(hc, r);
+			hc->tx_rttvar = r >> 1;
 		} else {
 			/* RTTVAR */
-			long tmp = hctx->tx_srtt - r;
+			long tmp = hc->tx_srtt - r;
 			long srtt;
 
 			if (tmp < 0)
 				tmp *= -1;
 
 			tmp >>= 2;
-			hctx->tx_rttvar *= 3;
-			hctx->tx_rttvar >>= 2;
-			hctx->tx_rttvar += tmp;
+			hc->tx_rttvar *= 3;
+			hc->tx_rttvar >>= 2;
+			hc->tx_rttvar += tmp;
 
 			/* SRTT */
-			srtt = hctx->tx_srtt;
+			srtt = hc->tx_srtt;
 			srtt *= 7;
 			srtt >>= 3;
 			tmp = r >> 3;
 			srtt += tmp;
-			ccid2_change_srtt(hctx, srtt);
+			ccid2_change_srtt(hc, srtt);
 		}
-		s = hctx->tx_rttvar << 2;
+		s = hc->tx_rttvar << 2;
 		/* clock granularity is 1 when based on jiffies */
 		if (!s)
 			s = 1;
-		hctx->tx_rto = hctx->tx_srtt + s;
+		hc->tx_rto = hc->tx_srtt + s;
 
 		/* must be at least a second */
-		s = hctx->tx_rto / HZ;
+		s = hc->tx_rto / HZ;
 		/* DCCP doesn't require this [but I like it cuz my code sux] */
 #if 1
 		if (s < 1)
-			hctx->tx_rto = HZ;
+			hc->tx_rto = HZ;
 #endif
 		/* max 60 seconds */
 		if (s > 60)
-			hctx->tx_rto = HZ * 60;
+			hc->tx_rto = HZ * 60;
 
-		hctx->tx_lastrtt = jiffies;
+		hc->tx_lastrtt = jiffies;
 
 		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
-			       hctx->tx_srtt, hctx->tx_rttvar,
-			       hctx->tx_rto, HZ, r);
+			       hc->tx_srtt, hc->tx_rttvar,
+			       hc->tx_rto, HZ, r);
 	}
 
 	/* we got a new ack, so re-start RTO timer */
@@ -467,40 +467,40 @@ static inline void ccid2_new_ack(struct sock *sk,
 
 static void ccid2_hc_tx_dec_pipe(struct sock *sk)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	if (hctx->tx_pipe = 0)
+	if (hc->tx_pipe = 0)
 		DCCP_BUG("pipe = 0");
 	else
-		hctx->tx_pipe--;
+		hc->tx_pipe--;
 
-	if (hctx->tx_pipe = 0)
+	if (hc->tx_pipe = 0)
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
 static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 
-	if (time_before(seqp->ccid2s_sent, hctx->tx_last_cong)) {
+	if (time_before(seqp->ccid2s_sent, hc->tx_last_cong)) {
 		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
 		return;
 	}
 
-	hctx->tx_last_cong = jiffies;
+	hc->tx_last_cong = jiffies;
 
-	hctx->tx_cwnd     = hctx->tx_cwnd / 2 ? : 1U;
-	hctx->tx_ssthresh = max(hctx->tx_cwnd, 2U);
+	hc->tx_cwnd      = hc->tx_cwnd / 2 ? : 1U;
+	hc->tx_ssthresh  = max(hc->tx_cwnd, 2U);
 
 	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
-	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->tx_cwnd)
-		ccid2_change_l_ack_ratio(sk, hctx->tx_cwnd);
+	if (dccp_sk(sk)->dccps_l_ack_ratio > hc->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hc->tx_cwnd);
 }
 
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	u64 ackno, seqno;
 	struct ccid2_seq *seqp;
 	unsigned char *vector;
@@ -509,7 +509,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	int done = 0;
 	unsigned int maxincr = 0;
 
-	ccid2_hc_tx_check_sanity(hctx);
+	ccid2_hc_tx_check_sanity(hc);
 	/* check reverse path congestion */
 	seqno = DCCP_SKB_CB(skb)->dccpd_seq;
 
@@ -518,21 +518,21 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	 * -sorbo.
 	 */
 	/* need to bootstrap */
-	if (hctx->tx_rpdupack = -1) {
-		hctx->tx_rpdupack = 0;
-		hctx->tx_rpseq    = seqno;
+	if (hc->tx_rpdupack = -1) {
+		hc->tx_rpdupack = 0;
+		hc->tx_rpseq    = seqno;
 	} else {
 		/* check if packet is consecutive */
-		if (dccp_delta_seqno(hctx->tx_rpseq, seqno) = 1)
-			hctx->tx_rpseq = seqno;
+		if (dccp_delta_seqno(hc->tx_rpseq, seqno) = 1)
+			hc->tx_rpseq = seqno;
 		/* it's a later packet */
-		else if (after48(seqno, hctx->tx_rpseq)) {
-			hctx->tx_rpdupack++;
+		else if (after48(seqno, hc->tx_rpseq)) {
+			hc->tx_rpdupack++;
 
 			/* check if we got enough dupacks */
-			if (hctx->tx_rpdupack >= NUMDUPACK) {
-				hctx->tx_rpdupack = -1; /* XXX lame */
-				hctx->tx_rpseq    = 0;
+			if (hc->tx_rpdupack >= NUMDUPACK) {
+				hc->tx_rpdupack = -1; /* XXX lame */
+				hc->tx_rpseq    = 0;
 
 				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
 			}
@@ -541,7 +541,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* check forward path congestion */
 	/* still didn't send out new data packets */
-	if (hctx->tx_seqh = hctx->tx_seqt)
+	if (hc->tx_seqh = hc->tx_seqt)
 		return;
 
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
@@ -553,14 +553,14 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
-	if (after48(ackno, hctx->tx_high_ack))
-		hctx->tx_high_ack = ackno;
+	if (after48(ackno, hc->tx_high_ack))
+		hc->tx_high_ack = ackno;
 
-	seqp = hctx->tx_seqt;
+	seqp = hc->tx_seqt;
 	while (before48(seqp->ccid2s_seq, ackno)) {
 		seqp = seqp->ccid2s_next;
-		if (seqp = hctx->tx_seqh) {
-			seqp = hctx->tx_seqh->ccid2s_prev;
+		if (seqp = hc->tx_seqh) {
+			seqp = hc->tx_seqh->ccid2s_prev;
 			break;
 		}
 	}
@@ -570,7 +570,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	 * packets per acknowledgement. Rounding up avoids that cwnd is not
 	 * advanced when Ack Ratio is 1 and gives a slight edge otherwise.
 	 */
-	if (hctx->tx_cwnd < hctx->tx_ssthresh)
+	if (hc->tx_cwnd < hc->tx_ssthresh)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
@@ -589,7 +589,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * seqnos.
 			 */
 			while (after48(seqp->ccid2s_seq, ackno)) {
-				if (seqp = hctx->tx_seqt) {
+				if (seqp = hc->tx_seqt) {
 					done = 1;
 					break;
 				}
@@ -621,7 +621,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 						       (unsigned long long)seqp->ccid2s_seq);
 					ccid2_hc_tx_dec_pipe(sk);
 				}
-				if (seqp = hctx->tx_seqt) {
+				if (seqp = hc->tx_seqt) {
 					done = 1;
 					break;
 				}
@@ -640,11 +640,11 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
-	seqp = hctx->tx_seqt;
-	while (before48(seqp->ccid2s_seq, hctx->tx_high_ack)) {
+	seqp = hc->tx_seqt;
+	while (before48(seqp->ccid2s_seq, hc->tx_high_ack)) {
 		seqp = seqp->ccid2s_next;
-		if (seqp = hctx->tx_seqh) {
-			seqp = hctx->tx_seqh->ccid2s_prev;
+		if (seqp = hc->tx_seqh) {
+			seqp = hc->tx_seqh->ccid2s_prev;
 			break;
 		}
 	}
@@ -655,7 +655,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			if (done = NUMDUPACK)
 				break;
 		}
-		if (seqp = hctx->tx_seqt)
+		if (seqp = hc->tx_seqt)
 			break;
 		seqp = seqp->ccid2s_prev;
 	}
@@ -678,86 +678,86 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				ccid2_congestion_event(sk, seqp);
 				ccid2_hc_tx_dec_pipe(sk);
 			}
-			if (seqp = hctx->tx_seqt)
+			if (seqp = hc->tx_seqt)
 				break;
 			seqp = seqp->ccid2s_prev;
 		}
 
-		hctx->tx_seqt = last_acked;
+		hc->tx_seqt = last_acked;
 	}
 
 	/* trim acked packets in tail */
-	while (hctx->tx_seqt != hctx->tx_seqh) {
-		if (!hctx->tx_seqt->ccid2s_acked)
+	while (hc->tx_seqt != hc->tx_seqh) {
+		if (!hc->tx_seqt->ccid2s_acked)
 			break;
 
-		hctx->tx_seqt = hctx->tx_seqt->ccid2s_next;
+		hc->tx_seqt = hc->tx_seqt->ccid2s_next;
 	}
 
-	ccid2_hc_tx_check_sanity(hctx);
+	ccid2_hc_tx_check_sanity(hc);
 }
 
 static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid_priv(ccid);
+	struct ccid2_hc_tx_sock *hc = ccid_priv(ccid);
 	struct dccp_sock *dp = dccp_sk(sk);
 	u32 max_ratio;
 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
-	hctx->tx_ssthresh = ~0U;
+	hc->tx_ssthresh = ~0U;
 
 	/*
 	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
 	 * packets for new connections, following the rules from [RFC3390]".
 	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
 	 */
-	hctx->tx_cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
+	hc->tx_cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
-	max_ratio = DIV_ROUND_UP(hctx->tx_cwnd, 2);
+	max_ratio = DIV_ROUND_UP(hc->tx_cwnd, 2);
 	if (dp->dccps_l_ack_ratio = 0 || dp->dccps_l_ack_ratio > max_ratio)
 		dp->dccps_l_ack_ratio = max_ratio;
 
 	/* XXX init ~ to window size... */
-	if (ccid2_hc_tx_alloc_seq(hctx))
+	if (ccid2_hc_tx_alloc_seq(hc))
 		return -ENOMEM;
 
-	hctx->tx_rto	   = 3 * HZ;
-	ccid2_change_srtt(hctx, -1);
-	hctx->tx_rttvar	   = -1;
-	hctx->tx_rpdupack  = -1;
-	hctx->tx_last_cong = jiffies;
-	setup_timer(&hctx->tx_rtotimer, ccid2_hc_tx_rto_expire,
+	hc->tx_rto	 = 3 * HZ;
+	ccid2_change_srtt(hc, -1);
+	hc->tx_rttvar    = -1;
+	hc->tx_rpdupack  = -1;
+	hc->tx_last_cong = jiffies;
+	setup_timer(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
 
-	ccid2_hc_tx_check_sanity(hctx);
+	ccid2_hc_tx_check_sanity(hc);
 	return 0;
 }
 
 static void ccid2_hc_tx_exit(struct sock *sk)
 {
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	int i;
 
 	ccid2_hc_tx_kill_rto_timer(sk);
 
-	for (i = 0; i < hctx->tx_seqbufc; i++)
-		kfree(hctx->tx_seqbuf[i]);
-	hctx->tx_seqbufc = 0;
+	for (i = 0; i < hc->tx_seqbufc; i++)
+		kfree(hc->tx_seqbuf[i]);
+	hc->tx_seqbufc = 0;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
-	struct ccid2_hc_rx_sock *hcrx = ccid2_hc_rx_sk(sk);
+	struct ccid2_hc_rx_sock *hc = ccid2_hc_rx_sk(sk);
 
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
 	case DCCP_PKT_DATA:
 	case DCCP_PKT_DATAACK:
-		hcrx->rx_data++;
-		if (hcrx->rx_data >= dp->dccps_r_ack_ratio) {
+		hc->rx_data++;
+		if (hc->rx_data >= dp->dccps_r_ack_ratio) {
 			dccp_send_ack(sk);
-			hcrx->rx_data = 0;
+			hc->rx_data = 0;
 		}
 		break;
 	}
