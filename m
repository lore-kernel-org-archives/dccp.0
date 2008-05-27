From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 08:32:42 +0000
Subject: [PATCH 2/7] [CCID-2]: Remove ccid2hc{tx,rx}_ prefixes
Message-Id: <1211877167-10995-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fixes two problems caused by the ubiquitous long "hctx->ccid2htx_"
and "hcrx->ccid2hcrx_" prefixes:
 * code becomes hard to read;
 * multiple-line statements are almost inevitable even for simple expressions;
The prefixes are not really necessary (compare with "struct tcp_sock").

There had been previous discussion of this on dccp@vger, but so far this was
not followed up (most people agreed that the prefixes are too long).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Leandro Melo de Sales <leandroal@gmail.com>
---
 net/dccp/ccids/ccid2.c |  274 ++++++++++++++++++++++++------------------------
 net/dccp/ccids/ccid2.h |   48 ++++----
 2 files changed, 159 insertions(+), 163 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -39,16 +39,16 @@ static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
 	int len = 0;
 	int pipe = 0;
-	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
+	struct ccid2_seq *seqp = hctx->seqh;
 
 	/* there is data in the chain */
-	if (seqp != hctx->ccid2hctx_seqt) {
+	if (seqp != hctx->seqt) {
 		seqp = seqp->ccid2s_prev;
 		len++;
 		if (!seqp->ccid2s_acked)
 			pipe++;
 
-		while (seqp != hctx->ccid2hctx_seqt) {
+		while (seqp != hctx->seqt) {
 			struct ccid2_seq *prev = seqp->ccid2s_prev;
 
 			len++;
@@ -65,16 +65,16 @@ static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 		}
 	}
 
-	BUG_ON(pipe != hctx->ccid2hctx_pipe);
+	BUG_ON(pipe != hctx->pipe);
 	ccid2_pr_debug("len of chain=%d\n", len);
 
 	do {
 		seqp = seqp->ccid2s_prev;
 		len++;
-	} while (seqp != hctx->ccid2hctx_seqh);
+	} while (seqp != hctx->seqh);
 
 	ccid2_pr_debug("total len=%d\n", len);
-	BUG_ON(len != hctx->ccid2hctx_seqbufc * CCID2_SEQBUF_LEN);
+	BUG_ON(len != hctx->seqbufc * CCID2_SEQBUF_LEN);
 }
 #else
 #define ccid2_pr_debug(format, a...)
@@ -87,8 +87,7 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 	int i;
 
 	/* check if we have space to preserve the pointer to the buffer */
-	if (hctx->ccid2hctx_seqbufc >= (sizeof(hctx->ccid2hctx_seqbuf) /
-					sizeof(struct ccid2_seq*)))
+	if (hctx->seqbufc >= sizeof(hctx->seqbuf) / sizeof(struct ccid2_seq *))
 		return -ENOMEM;
 
 	/* allocate buffer and initialize linked list */
@@ -104,20 +103,20 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
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
@@ -126,7 +125,7 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd)
+	if (hctx->pipe < hctx->cwnd)
 		return 0;
 
 	return 1; /* XXX CCID should dequeue when ready instead of polling */
@@ -135,7 +134,7 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->ccid2hctx_cwnd, 2);
+	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->cwnd, 2);
 
 	/*
 	 * Ensure that Ack Ratio does not exceed ceil(cwnd/2), which is (2) from
@@ -160,7 +159,7 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
 {
 	ccid2_pr_debug("change SRTT to %ld\n", val);
-	hctx->ccid2hctx_srtt = val;
+	hctx->srtt = val;
 }
 
 static void ccid2_start_rto_timer(struct sock *sk);
@@ -173,8 +172,7 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
-		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-			       jiffies + HZ / 5);
+		sk_reset_timer(sk, &hctx->rtotimer, jiffies + HZ / 5);
 		goto out;
 	}
 
@@ -183,28 +181,28 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	ccid2_hc_tx_check_sanity(hctx);
 
 	/* back-off timer */
-	hctx->ccid2hctx_rto <<= 1;
+	hctx->rto <<= 1;
 
-	s = hctx->ccid2hctx_rto / HZ;
+	s = hctx->rto / HZ;
 	if (s > 60)
-		hctx->ccid2hctx_rto = 60 * HZ;
+		hctx->rto = 60 * HZ;
 
 	ccid2_start_rto_timer(sk);
 
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
 	ccid2_hc_tx_check_sanity(hctx);
 out:
@@ -216,11 +214,11 @@ static void ccid2_start_rto_timer(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->ccid2hctx_rto);
+	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->rto);
 
-	BUG_ON(timer_pending(&hctx->ccid2hctx_rtotimer));
-	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-		       jiffies + hctx->ccid2hctx_rto);
+	BUG_ON(timer_pending(&hctx->rtotimer));
+	sk_reset_timer(sk, &hctx->rtotimer,
+		       jiffies + hctx->rto);
 }
 
 static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
@@ -229,27 +227,26 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
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
@@ -272,12 +269,12 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
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
@@ -287,28 +284,28 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
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
+	if (!timer_pending(&hctx->rtotimer))
 		ccid2_start_rto_timer(sk);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	do {
-		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
+		struct ccid2_seq *seqp = hctx->seqt;
 
-		while (seqp != hctx->ccid2hctx_seqh) {
+		while (seqp != hctx->seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
 				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
@@ -386,7 +383,7 @@ static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
+	sk_stop_timer(sk, &hctx->rtotimer);
 	ccid2_pr_debug("deleted RTO timer\n");
 }
 
@@ -396,73 +393,73 @@ static inline void ccid2_new_ack(struct sock *sk,
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
-		if (*maxincr > 0 && ++hctx->ccid2hctx_packets_acked = 2) {
-			hctx->ccid2hctx_cwnd += 1;
-			*maxincr	     -= 1;
-			hctx->ccid2hctx_packets_acked = 0;
+	if (hctx->cwnd < hctx->ssthresh) {
+		if (*maxincr > 0 && ++hctx->packets_acked = 2) {
+			hctx->cwnd += 1;
+			*maxincr   -= 1;
+			hctx->packets_acked = 0;
 		}
-	} else if (++hctx->ccid2hctx_packets_acked >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_cwnd += 1;
-			hctx->ccid2hctx_packets_acked = 0;
+	} else if (++hctx->packets_acked >= hctx->cwnd) {
+			hctx->cwnd += 1;
+			hctx->packets_acked = 0;
 	}
 
 	/* update RTO */
-	if (hctx->ccid2hctx_srtt = -1 ||
-	    time_after(jiffies, hctx->ccid2hctx_lastrtt + hctx->ccid2hctx_srtt)) {
+	if (hctx->srtt = -1 ||
+	    time_after(jiffies, hctx->lastrtt + hctx->srtt)) {
 		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 		int s;
 
 		/* first measurement */
-		if (hctx->ccid2hctx_srtt = -1) {
+		if (hctx->srtt = -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
 				       r, jiffies,
 				       (unsigned long long)seqp->ccid2s_seq);
 			ccid2_change_srtt(hctx, r);
-			hctx->ccid2hctx_rttvar = r >> 1;
+			hctx->rttvar = r >> 1;
 		} else {
 			/* RTTVAR */
-			long tmp = hctx->ccid2hctx_srtt - r;
+			long tmp = hctx->srtt - r;
 			long srtt;
 
 			if (tmp < 0)
 				tmp *= -1;
 
 			tmp >>= 2;
-			hctx->ccid2hctx_rttvar *= 3;
-			hctx->ccid2hctx_rttvar >>= 2;
-			hctx->ccid2hctx_rttvar += tmp;
+			hctx->rttvar *= 3;
+			hctx->rttvar >>= 2;
+			hctx->rttvar += tmp;
 
 			/* SRTT */
-			srtt = hctx->ccid2hctx_srtt;
+			srtt = hctx->srtt;
 			srtt *= 7;
 			srtt >>= 3;
 			tmp = r >> 3;
 			srtt += tmp;
 			ccid2_change_srtt(hctx, srtt);
 		}
-		s = hctx->ccid2hctx_rttvar << 2;
+		s = hctx->rttvar << 2;
 		/* clock granularity is 1 when based on jiffies */
 		if (!s)
 			s = 1;
-		hctx->ccid2hctx_rto = hctx->ccid2hctx_srtt + s;
+		hctx->rto = hctx->srtt + s;
 
 		/* must be at least a second */
-		s = hctx->ccid2hctx_rto / HZ;
+		s = hctx->rto / HZ;
 		/* DCCP doesn't require this [but I like it cuz my code sux] */
 #if 1
 		if (s < 1)
-			hctx->ccid2hctx_rto = HZ;
+			hctx->rto = HZ;
 #endif
 		/* max 60 seconds */
 		if (s > 60)
-			hctx->ccid2hctx_rto = HZ * 60;
+			hctx->rto = HZ * 60;
 
-		hctx->ccid2hctx_lastrtt = jiffies;
+		hctx->lastrtt = jiffies;
 
 		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
-			       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
-			       hctx->ccid2hctx_rto, HZ, r);
+			       hctx->srtt, hctx->rttvar,
+			       hctx->rto, HZ, r);
 	}
 
 	/* we got a new ack, so re-start RTO timer */
@@ -474,12 +471,12 @@ static void ccid2_hc_tx_dec_pipe(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_pipe = 0)
+	if (hctx->pipe = 0)
 		DCCP_BUG("pipe = 0");
 	else
-		hctx->ccid2hctx_pipe--;
+		hctx->pipe--;
 
-	if (hctx->ccid2hctx_pipe = 0)
+	if (hctx->pipe = 0)
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
@@ -487,19 +484,19 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
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
 
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -523,21 +520,21 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -546,7 +543,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* check forward path congestion */
 	/* still didn't send out new data packets */
-	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
+	if (hctx->seqh = hctx->seqt)
 		return;
 
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
@@ -558,14 +555,14 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
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
@@ -575,7 +572,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	 * packets per acknowledgement. Rounding up avoids that cwnd is not
 	 * advanced when Ack Ratio is 1 and gives a slight edge otherwise.
 	 */
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh)
+	if (hctx->cwnd < hctx->ssthresh)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
@@ -594,7 +591,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * seqnos.
 			 */
 			while (after48(seqp->ccid2s_seq, ackno)) {
-				if (seqp = hctx->ccid2hctx_seqt) {
+				if (seqp = hctx->seqt) {
 					done = 1;
 					break;
 				}
@@ -626,7 +623,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 						       (unsigned long long)seqp->ccid2s_seq);
 					ccid2_hc_tx_dec_pipe(sk);
 				}
-				if (seqp = hctx->ccid2hctx_seqt) {
+				if (seqp = hctx->seqt) {
 					done = 1;
 					break;
 				}
@@ -645,11 +642,11 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
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
@@ -660,7 +657,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			if (done = NUMDUPACK)
 				break;
 		}
-		if (seqp = hctx->ccid2hctx_seqt)
+		if (seqp = hctx->seqt)
 			break;
 		seqp = seqp->ccid2s_prev;
 	}
@@ -683,20 +680,20 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				ccid2_congestion_event(sk, seqp);
 				ccid2_hc_tx_dec_pipe(sk);
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
 
 	ccid2_hc_tx_check_sanity(hctx);
@@ -709,17 +706,17 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	u32 max_ratio;
 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
-	hctx->ccid2hctx_ssthresh  = ~0U;
+	hctx->ssthresh = ~0U;
 
 	/*
 	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
 	 * packets for new connections, following the rules from [RFC3390]".
 	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
 	 */
-	hctx->ccid2hctx_cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
+	hctx->cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
-	max_ratio = DIV_ROUND_UP(hctx->ccid2hctx_cwnd, 2);
+	max_ratio = DIV_ROUND_UP(hctx->cwnd, 2);
 	if (dp->dccps_l_ack_ratio = 0 || dp->dccps_l_ack_ratio > max_ratio)
 		dp->dccps_l_ack_ratio = max_ratio;
 
@@ -727,13 +724,12 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
-	hctx->ccid2hctx_rto	 = 3 * HZ;
+	hctx->rto	 = 3 * HZ;
 	ccid2_change_srtt(hctx, -1);
-	hctx->ccid2hctx_rttvar	 = -1;
-	hctx->ccid2hctx_rpdupack = -1;
-	hctx->ccid2hctx_last_cong = jiffies;
-	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
-			(unsigned long)sk);
+	hctx->rttvar	= -1;
+	hctx->rpdupack  = -1;
+	hctx->last_cong = jiffies;
+	setup_timer(&hctx->rtotimer, ccid2_hc_tx_rto_expire, (unsigned long)sk);
 
 	ccid2_hc_tx_check_sanity(hctx);
 	return 0;
@@ -746,9 +742,9 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 
 	ccid2_hc_tx_kill_rto_timer(sk);
 
-	for (i = 0; i < hctx->ccid2hctx_seqbufc; i++)
-		kfree(hctx->ccid2hctx_seqbuf[i]);
-	hctx->ccid2hctx_seqbufc = 0;
+	for (i = 0; i < hctx->seqbufc; i++)
+		kfree(hctx->seqbuf[i]);
+	hctx->seqbufc = 0;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -759,10 +755,10 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
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
--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -42,34 +42,34 @@ struct ccid2_seq {
 
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
  *
- * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
- * @ccid2hctx_packets_acked - Ack counter for deriving cwnd growth (RFC 3465)
- * @ccid2hctx_lastrtt -time RTT was last measured
- * @ccid2hctx_rpseq - last consecutive seqno
- * @ccid2hctx_rpdupack - dupacks since rpseq
-*/
+ * @{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
+ * @packets_acked: Ack counter for deriving cwnd growth (RFC 3465)
+ * @lastrtt: time RTT was last measured
+ * @rpseq: last consecutive seqno
+ * @rpdupack: dupacks since rpseq
+ */
 struct ccid2_hc_tx_sock {
-	u32			ccid2hctx_cwnd;
-	u32			ccid2hctx_ssthresh;
-	u32			ccid2hctx_pipe;
-	u32			ccid2hctx_packets_acked;
-	struct ccid2_seq	*ccid2hctx_seqbuf[CCID2_SEQBUF_MAX];
-	int			ccid2hctx_seqbufc;
-	struct ccid2_seq	*ccid2hctx_seqh;
-	struct ccid2_seq	*ccid2hctx_seqt;
-	long			ccid2hctx_rto;
-	long			ccid2hctx_srtt;
-	long			ccid2hctx_rttvar;
-	unsigned long		ccid2hctx_lastrtt;
-	struct timer_list	ccid2hctx_rtotimer;
-	u64			ccid2hctx_rpseq;
-	int			ccid2hctx_rpdupack;
-	unsigned long		ccid2hctx_last_cong;
-	u64			ccid2hctx_high_ack;
+	u32			cwnd;
+	u32			ssthresh;
+	u32			pipe;
+	u32			packets_acked;
+	struct ccid2_seq	*seqbuf[CCID2_SEQBUF_MAX];
+	int			seqbufc;
+	struct ccid2_seq	*seqh;
+	struct ccid2_seq	*seqt;
+	long			rto;
+	long			srtt;
+	long			rttvar;
+	unsigned long		lastrtt;
+	struct timer_list	rtotimer;
+	u64			rpseq;
+	int			rpdupack;
+	unsigned long		last_cong;
+	u64			high_ack;
 };
 
 struct ccid2_hc_rx_sock {
-	int	ccid2hcrx_data;
+	int			data;
 };
 
 static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
-- 
1.5.5

