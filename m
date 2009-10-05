From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 05 Oct 2009 10:53:10 +0000
Subject: [PATCH 1/4][RFC] dccp ccid-2: Overhaul CCID naming convention 1/2
Message-Id: <1254739993-5051-2-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch starts a less problematic naming convention for CCID structs.

The old naming convention used 'hc{tx,rx}->ccid?hc{tx,rx}->...' as 
recurring prefixes, which made the code
 * hard to write (not easy to fit into 80 characters);
 * hard to read  (most of the space is occupied by prefixes).

The new naming scheme:
 * struct entries for the TX socket are prefixed by 'tx_';
 * and those for the RX socket are prefixed by 'rx_'.

The identifiers then remain distinguishable when grep-ing through the tree:
 (a) RX/TX sockets are distinguished by the naming scheme,
 (b) individual CCIDs are distinguished by filename (ccid{2,3,4}.{c,h}).

This first patch implements the scheme for CCID-2.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |  273 ++++++++++++++++++++++++------------------------
 net/dccp/ccids/ccid2.h |   46 ++++----
 2 files changed, 158 insertions(+), 161 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -40,34 +40,34 @@ struct ccid2_seq {
 
 /**
  * struct ccid2_hc_tx_sock - CCID2 TX half connection
- * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
- * @ccid2hctx_packets_acked - Ack counter for deriving cwnd growth (RFC 3465)
- * @ccid2hctx_lastrtt -time RTT was last measured
- * @ccid2hctx_rpseq - last consecutive seqno
- * @ccid2hctx_rpdupack - dupacks since rpseq
+ * @tx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
+ * @tx_packets_acked:	     Ack counter for deriving cwnd growth (RFC 3465)
+ * @tx_lastrtt:		     time RTT was last measured
+ * @tx_rpseq:		     last consecutive seqno
+ * @tx_rpdupack:	     dupacks since rpseq
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
-	long			ccid2hctx_rto;
-	long			ccid2hctx_srtt;
-	long			ccid2hctx_rttvar;
-	unsigned long		ccid2hctx_lastrtt;
-	struct timer_list	ccid2hctx_rtotimer;
-	u64			ccid2hctx_rpseq;
-	int			ccid2hctx_rpdupack;
-	unsigned long		ccid2hctx_last_cong;
-	u64			ccid2hctx_high_ack;
+	u32			tx_cwnd;
+	u32			tx_ssthresh;
+	u32			tx_pipe;
+	u32			tx_packets_acked;
+	struct ccid2_seq	*tx_seqbuf[CCID2_SEQBUF_MAX];
+	int			tx_seqbufc;
+	struct ccid2_seq	*tx_seqh;
+	struct ccid2_seq	*tx_seqt;
+	long			tx_rto;
+	long			tx_srtt;
+	long			tx_rttvar;
+	unsigned long		tx_lastrtt;
+	struct timer_list	tx_rtotimer;
+	u64			tx_rpseq;
+	int			tx_rpdupack;
+	unsigned long		tx_last_cong;
+	u64			tx_high_ack;
 };
 
 struct ccid2_hc_rx_sock {
-	int	ccid2hcrx_data;
+	int	rx_data;
 };
 
 static inline struct ccid2_hc_tx_sock *ccid2_hc_tx_sk(const struct sock *sk)
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -37,16 +37,16 @@ static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 {
 	int len = 0;
 	int pipe = 0;
-	struct ccid2_seq *seqp = hctx->ccid2hctx_seqh;
+	struct ccid2_seq *seqp = hctx->tx_seqh;
 
 	/* there is data in the chain */
-	if (seqp != hctx->ccid2hctx_seqt) {
+	if (seqp != hctx->tx_seqt) {
 		seqp = seqp->ccid2s_prev;
 		len++;
 		if (!seqp->ccid2s_acked)
 			pipe++;
 
-		while (seqp != hctx->ccid2hctx_seqt) {
+		while (seqp != hctx->tx_seqt) {
 			struct ccid2_seq *prev = seqp->ccid2s_prev;
 
 			len++;
@@ -63,16 +63,16 @@ static void ccid2_hc_tx_check_sanity(const struct ccid2_hc_tx_sock *hctx)
 		}
 	}
 
-	BUG_ON(pipe != hctx->ccid2hctx_pipe);
+	BUG_ON(pipe != hctx->tx_pipe);
 	ccid2_pr_debug("len of chain=%d\n", len);
 
 	do {
 		seqp = seqp->ccid2s_prev;
 		len++;
-	} while (seqp != hctx->ccid2hctx_seqh);
+	} while (seqp != hctx->tx_seqh);
 
 	ccid2_pr_debug("total len=%d\n", len);
-	BUG_ON(len != hctx->ccid2hctx_seqbufc * CCID2_SEQBUF_LEN);
+	BUG_ON(len != hctx->tx_seqbufc * CCID2_SEQBUF_LEN);
 }
 #else
 #define ccid2_pr_debug(format, a...)
@@ -85,8 +85,8 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 	int i;
 
 	/* check if we have space to preserve the pointer to the buffer */
-	if (hctx->ccid2hctx_seqbufc >= (sizeof(hctx->ccid2hctx_seqbuf) /
-					sizeof(struct ccid2_seq*)))
+	if (hctx->tx_seqbufc >= (sizeof(hctx->tx_seqbuf) /
+				 sizeof(struct ccid2_seq *)))
 		return -ENOMEM;
 
 	/* allocate buffer and initialize linked list */
@@ -102,20 +102,20 @@ static int ccid2_hc_tx_alloc_seq(struct ccid2_hc_tx_sock *hctx)
 	seqp->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
 
 	/* This is the first allocation.  Initiate the head and tail.  */
-	if (hctx->ccid2hctx_seqbufc = 0)
-		hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt = seqp;
+	if (hctx->tx_seqbufc = 0)
+		hctx->tx_seqh = hctx->tx_seqt = seqp;
 	else {
 		/* link the existing list with the one we just created */
-		hctx->ccid2hctx_seqh->ccid2s_next = seqp;
-		seqp->ccid2s_prev = hctx->ccid2hctx_seqh;
+		hctx->tx_seqh->ccid2s_next = seqp;
+		seqp->ccid2s_prev = hctx->tx_seqh;
 
-		hctx->ccid2hctx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
-		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->ccid2hctx_seqt;
+		hctx->tx_seqt->ccid2s_prev = &seqp[CCID2_SEQBUF_LEN - 1];
+		seqp[CCID2_SEQBUF_LEN - 1].ccid2s_next = hctx->tx_seqt;
 	}
 
 	/* store the original pointer to the buffer so we can free it */
-	hctx->ccid2hctx_seqbuf[hctx->ccid2hctx_seqbufc] = seqp;
-	hctx->ccid2hctx_seqbufc++;
+	hctx->tx_seqbuf[hctx->tx_seqbufc] = seqp;
+	hctx->tx_seqbufc++;
 
 	return 0;
 }
@@ -124,7 +124,7 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_pipe < hctx->ccid2hctx_cwnd)
+	if (hctx->tx_pipe < hctx->tx_cwnd)
 		return 0;
 
 	return 1; /* XXX CCID should dequeue when ready instead of polling */
@@ -133,7 +133,7 @@ static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
-	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->ccid2hctx_cwnd, 2);
+	u32 max_ratio = DIV_ROUND_UP(ccid2_hc_tx_sk(sk)->tx_cwnd, 2);
 
 	/*
 	 * Ensure that Ack Ratio does not exceed ceil(cwnd/2), which is (2) from
@@ -158,7 +158,7 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
 {
 	ccid2_pr_debug("change SRTT to %ld\n", val);
-	hctx->ccid2hctx_srtt = val;
+	hctx->tx_srtt = val;
 }
 
 static void ccid2_start_rto_timer(struct sock *sk);
@@ -171,8 +171,7 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
-		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-			       jiffies + HZ / 5);
+		sk_reset_timer(sk, &hctx->tx_rtotimer, jiffies + HZ / 5);
 		goto out;
 	}
 
@@ -181,28 +180,28 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	ccid2_hc_tx_check_sanity(hctx);
 
 	/* back-off timer */
-	hctx->ccid2hctx_rto <<= 1;
+	hctx->tx_rto <<= 1;
 
-	s = hctx->ccid2hctx_rto / HZ;
+	s = hctx->tx_rto / HZ;
 	if (s > 60)
-		hctx->ccid2hctx_rto = 60 * HZ;
+		hctx->tx_rto = 60 * HZ;
 
 	ccid2_start_rto_timer(sk);
 
 	/* adjust pipe, cwnd etc */
-	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
-	if (hctx->ccid2hctx_ssthresh < 2)
-		hctx->ccid2hctx_ssthresh = 2;
-	hctx->ccid2hctx_cwnd	 = 1;
-	hctx->ccid2hctx_pipe	 = 0;
+	hctx->tx_ssthresh = hctx->tx_cwnd / 2;
+	if (hctx->tx_ssthresh < 2)
+		hctx->tx_ssthresh = 2;
+	hctx->tx_cwnd	 = 1;
+	hctx->tx_pipe	 = 0;
 
 	/* clear state about stuff we sent */
-	hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqh;
-	hctx->ccid2hctx_packets_acked = 0;
+	hctx->tx_seqt = hctx->tx_seqh;
+	hctx->tx_packets_acked = 0;
 
 	/* clear ack ratio state. */
-	hctx->ccid2hctx_rpseq	 = 0;
-	hctx->ccid2hctx_rpdupack = -1;
+	hctx->tx_rpseq    = 0;
+	hctx->tx_rpdupack = -1;
 	ccid2_change_l_ack_ratio(sk, 1);
 	ccid2_hc_tx_check_sanity(hctx);
 out:
@@ -214,11 +213,10 @@ static void ccid2_start_rto_timer(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->ccid2hctx_rto);
+	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->tx_rto);
 
-	BUG_ON(timer_pending(&hctx->ccid2hctx_rtotimer));
-	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-		       jiffies + hctx->ccid2hctx_rto);
+	BUG_ON(timer_pending(&hctx->tx_rtotimer));
+	sk_reset_timer(sk, &hctx->tx_rtotimer, jiffies + hctx->tx_rto);
 }
 
 static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
@@ -227,27 +225,26 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	struct ccid2_seq *next;
 
-	hctx->ccid2hctx_pipe++;
+	hctx->tx_pipe++;
 
-	hctx->ccid2hctx_seqh->ccid2s_seq   = dp->dccps_gss;
-	hctx->ccid2hctx_seqh->ccid2s_acked = 0;
-	hctx->ccid2hctx_seqh->ccid2s_sent  = jiffies;
+	hctx->tx_seqh->ccid2s_seq   = dp->dccps_gss;
+	hctx->tx_seqh->ccid2s_acked = 0;
+	hctx->tx_seqh->ccid2s_sent  = jiffies;
 
-	next = hctx->ccid2hctx_seqh->ccid2s_next;
+	next = hctx->tx_seqh->ccid2s_next;
 	/* check if we need to alloc more space */
-	if (next = hctx->ccid2hctx_seqt) {
+	if (next = hctx->tx_seqt) {
 		if (ccid2_hc_tx_alloc_seq(hctx)) {
 			DCCP_CRIT("packet history - out of memory!");
 			/* FIXME: find a more graceful way to bail out */
 			return;
 		}
-		next = hctx->ccid2hctx_seqh->ccid2s_next;
-		BUG_ON(next = hctx->ccid2hctx_seqt);
+		next = hctx->tx_seqh->ccid2s_next;
+		BUG_ON(next = hctx->tx_seqt);
 	}
-	hctx->ccid2hctx_seqh = next;
+	hctx->tx_seqh = next;
 
-	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->ccid2hctx_cwnd,
-		       hctx->ccid2hctx_pipe);
+	ccid2_pr_debug("cwnd=%d pipe=%d\n", hctx->tx_cwnd, hctx->tx_pipe);
 
 	/*
 	 * FIXME: The code below is broken and the variables have been removed
@@ -270,12 +267,12 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	 */
 #if 0
 	/* Ack Ratio.  Need to maintain a concept of how many windows we sent */
-	hctx->ccid2hctx_arsent++;
+	hctx->tx_arsent++;
 	/* We had an ack loss in this window... */
-	if (hctx->ccid2hctx_ackloss) {
-		if (hctx->ccid2hctx_arsent >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_arsent	= 0;
-			hctx->ccid2hctx_ackloss	= 0;
+	if (hctx->tx_ackloss) {
+		if (hctx->tx_arsent >= hctx->tx_cwnd) {
+			hctx->tx_arsent  = 0;
+			hctx->tx_ackloss = 0;
 		}
 	} else {
 		/* No acks lost up to now... */
@@ -285,28 +282,28 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 			int denom = dp->dccps_l_ack_ratio * dp->dccps_l_ack_ratio -
 				    dp->dccps_l_ack_ratio;
 
-			denom = hctx->ccid2hctx_cwnd * hctx->ccid2hctx_cwnd / denom;
+			denom = hctx->tx_cwnd * hctx->tx_cwnd / denom;
 
-			if (hctx->ccid2hctx_arsent >= denom) {
+			if (hctx->tx_arsent >= denom) {
 				ccid2_change_l_ack_ratio(sk, dp->dccps_l_ack_ratio - 1);
-				hctx->ccid2hctx_arsent = 0;
+				hctx->tx_arsent = 0;
 			}
 		} else {
 			/* we can't increase ack ratio further [1] */
-			hctx->ccid2hctx_arsent = 0; /* or maybe set it to cwnd*/
+			hctx->tx_arsent = 0; /* or maybe set it to cwnd*/
 		}
 	}
 #endif
 
 	/* setup RTO timer */
-	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
+	if (!timer_pending(&hctx->tx_rtotimer))
 		ccid2_start_rto_timer(sk);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	do {
-		struct ccid2_seq *seqp = hctx->ccid2hctx_seqt;
+		struct ccid2_seq *seqp = hctx->tx_seqt;
 
-		while (seqp != hctx->ccid2hctx_seqh) {
+		while (seqp != hctx->tx_seqh) {
 			ccid2_pr_debug("out seq=%llu acked=%d time=%lu\n",
 				       (unsigned long long)seqp->ccid2s_seq,
 				       seqp->ccid2s_acked, seqp->ccid2s_sent);
@@ -384,7 +381,7 @@ static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
+	sk_stop_timer(sk, &hctx->tx_rtotimer);
 	ccid2_pr_debug("deleted RTO timer\n");
 }
 
@@ -394,73 +391,73 @@ static inline void ccid2_new_ack(struct sock *sk,
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh) {
-		if (*maxincr > 0 && ++hctx->ccid2hctx_packets_acked = 2) {
-			hctx->ccid2hctx_cwnd += 1;
-			*maxincr	     -= 1;
-			hctx->ccid2hctx_packets_acked = 0;
+	if (hctx->tx_cwnd < hctx->tx_ssthresh) {
+		if (*maxincr > 0 && ++hctx->tx_packets_acked = 2) {
+			hctx->tx_cwnd += 1;
+			*maxincr      -= 1;
+			hctx->tx_packets_acked = 0;
 		}
-	} else if (++hctx->ccid2hctx_packets_acked >= hctx->ccid2hctx_cwnd) {
-			hctx->ccid2hctx_cwnd += 1;
-			hctx->ccid2hctx_packets_acked = 0;
+	} else if (++hctx->tx_packets_acked >= hctx->tx_cwnd) {
+			hctx->tx_cwnd += 1;
+			hctx->tx_packets_acked = 0;
 	}
 
 	/* update RTO */
-	if (hctx->ccid2hctx_srtt = -1 ||
-	    time_after(jiffies, hctx->ccid2hctx_lastrtt + hctx->ccid2hctx_srtt)) {
+	if (hctx->tx_srtt = -1 ||
+	    time_after(jiffies, hctx->tx_lastrtt + hctx->tx_srtt)) {
 		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
 		int s;
 
 		/* first measurement */
-		if (hctx->ccid2hctx_srtt = -1) {
+		if (hctx->tx_srtt = -1) {
 			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
 				       r, jiffies,
 				       (unsigned long long)seqp->ccid2s_seq);
 			ccid2_change_srtt(hctx, r);
-			hctx->ccid2hctx_rttvar = r >> 1;
+			hctx->tx_rttvar = r >> 1;
 		} else {
 			/* RTTVAR */
-			long tmp = hctx->ccid2hctx_srtt - r;
+			long tmp = hctx->tx_srtt - r;
 			long srtt;
 
 			if (tmp < 0)
 				tmp *= -1;
 
 			tmp >>= 2;
-			hctx->ccid2hctx_rttvar *= 3;
-			hctx->ccid2hctx_rttvar >>= 2;
-			hctx->ccid2hctx_rttvar += tmp;
+			hctx->tx_rttvar *= 3;
+			hctx->tx_rttvar >>= 2;
+			hctx->tx_rttvar += tmp;
 
 			/* SRTT */
-			srtt = hctx->ccid2hctx_srtt;
+			srtt = hctx->tx_srtt;
 			srtt *= 7;
 			srtt >>= 3;
 			tmp = r >> 3;
 			srtt += tmp;
 			ccid2_change_srtt(hctx, srtt);
 		}
-		s = hctx->ccid2hctx_rttvar << 2;
+		s = hctx->tx_rttvar << 2;
 		/* clock granularity is 1 when based on jiffies */
 		if (!s)
 			s = 1;
-		hctx->ccid2hctx_rto = hctx->ccid2hctx_srtt + s;
+		hctx->tx_rto = hctx->tx_srtt + s;
 
 		/* must be at least a second */
-		s = hctx->ccid2hctx_rto / HZ;
+		s = hctx->tx_rto / HZ;
 		/* DCCP doesn't require this [but I like it cuz my code sux] */
 #if 1
 		if (s < 1)
-			hctx->ccid2hctx_rto = HZ;
+			hctx->tx_rto = HZ;
 #endif
 		/* max 60 seconds */
 		if (s > 60)
-			hctx->ccid2hctx_rto = HZ * 60;
+			hctx->tx_rto = HZ * 60;
 
-		hctx->ccid2hctx_lastrtt = jiffies;
+		hctx->tx_lastrtt = jiffies;
 
 		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
-			       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
-			       hctx->ccid2hctx_rto, HZ, r);
+			       hctx->tx_srtt, hctx->tx_rttvar,
+			       hctx->tx_rto, HZ, r);
 	}
 
 	/* we got a new ack, so re-start RTO timer */
@@ -472,12 +469,12 @@ static void ccid2_hc_tx_dec_pipe(struct sock *sk)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (hctx->ccid2hctx_pipe = 0)
+	if (hctx->tx_pipe = 0)
 		DCCP_BUG("pipe = 0");
 	else
-		hctx->ccid2hctx_pipe--;
+		hctx->tx_pipe--;
 
-	if (hctx->ccid2hctx_pipe = 0)
+	if (hctx->tx_pipe = 0)
 		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
@@ -485,19 +482,19 @@ static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
-	if (time_before(seqp->ccid2s_sent, hctx->ccid2hctx_last_cong)) {
+	if (time_before(seqp->ccid2s_sent, hctx->tx_last_cong)) {
 		ccid2_pr_debug("Multiple losses in an RTT---treating as one\n");
 		return;
 	}
 
-	hctx->ccid2hctx_last_cong = jiffies;
+	hctx->tx_last_cong = jiffies;
 
-	hctx->ccid2hctx_cwnd     = hctx->ccid2hctx_cwnd / 2 ? : 1U;
-	hctx->ccid2hctx_ssthresh = max(hctx->ccid2hctx_cwnd, 2U);
+	hctx->tx_cwnd     = hctx->tx_cwnd / 2 ? : 1U;
+	hctx->tx_ssthresh = max(hctx->tx_cwnd, 2U);
 
 	/* Avoid spurious timeouts resulting from Ack Ratio > cwnd */
-	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->ccid2hctx_cwnd)
-		ccid2_change_l_ack_ratio(sk, hctx->ccid2hctx_cwnd);
+	if (dccp_sk(sk)->dccps_l_ack_ratio > hctx->tx_cwnd)
+		ccid2_change_l_ack_ratio(sk, hctx->tx_cwnd);
 }
 
 static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -521,21 +518,21 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	 * -sorbo.
 	 */
 	/* need to bootstrap */
-	if (hctx->ccid2hctx_rpdupack = -1) {
-		hctx->ccid2hctx_rpdupack = 0;
-		hctx->ccid2hctx_rpseq = seqno;
+	if (hctx->tx_rpdupack = -1) {
+		hctx->tx_rpdupack = 0;
+		hctx->tx_rpseq    = seqno;
 	} else {
 		/* check if packet is consecutive */
-		if (dccp_delta_seqno(hctx->ccid2hctx_rpseq, seqno) = 1)
-			hctx->ccid2hctx_rpseq = seqno;
+		if (dccp_delta_seqno(hctx->tx_rpseq, seqno) = 1)
+			hctx->tx_rpseq = seqno;
 		/* it's a later packet */
-		else if (after48(seqno, hctx->ccid2hctx_rpseq)) {
-			hctx->ccid2hctx_rpdupack++;
+		else if (after48(seqno, hctx->tx_rpseq)) {
+			hctx->tx_rpdupack++;
 
 			/* check if we got enough dupacks */
-			if (hctx->ccid2hctx_rpdupack >= NUMDUPACK) {
-				hctx->ccid2hctx_rpdupack = -1; /* XXX lame */
-				hctx->ccid2hctx_rpseq = 0;
+			if (hctx->tx_rpdupack >= NUMDUPACK) {
+				hctx->tx_rpdupack = -1; /* XXX lame */
+				hctx->tx_rpseq    = 0;
 
 				ccid2_change_l_ack_ratio(sk, 2 * dp->dccps_l_ack_ratio);
 			}
@@ -544,7 +541,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 
 	/* check forward path congestion */
 	/* still didn't send out new data packets */
-	if (hctx->ccid2hctx_seqh = hctx->ccid2hctx_seqt)
+	if (hctx->tx_seqh = hctx->tx_seqt)
 		return;
 
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
@@ -556,14 +553,14 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	}
 
 	ackno = DCCP_SKB_CB(skb)->dccpd_ack_seq;
-	if (after48(ackno, hctx->ccid2hctx_high_ack))
-		hctx->ccid2hctx_high_ack = ackno;
+	if (after48(ackno, hctx->tx_high_ack))
+		hctx->tx_high_ack = ackno;
 
-	seqp = hctx->ccid2hctx_seqt;
+	seqp = hctx->tx_seqt;
 	while (before48(seqp->ccid2s_seq, ackno)) {
 		seqp = seqp->ccid2s_next;
-		if (seqp = hctx->ccid2hctx_seqh) {
-			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+		if (seqp = hctx->tx_seqh) {
+			seqp = hctx->tx_seqh->ccid2s_prev;
 			break;
 		}
 	}
@@ -573,7 +570,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	 * packets per acknowledgement. Rounding up avoids that cwnd is not
 	 * advanced when Ack Ratio is 1 and gives a slight edge otherwise.
 	 */
-	if (hctx->ccid2hctx_cwnd < hctx->ccid2hctx_ssthresh)
+	if (hctx->tx_cwnd < hctx->tx_ssthresh)
 		maxincr = DIV_ROUND_UP(dp->dccps_l_ack_ratio, 2);
 
 	/* go through all ack vectors */
@@ -592,7 +589,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 * seqnos.
 			 */
 			while (after48(seqp->ccid2s_seq, ackno)) {
-				if (seqp = hctx->ccid2hctx_seqt) {
+				if (seqp = hctx->tx_seqt) {
 					done = 1;
 					break;
 				}
@@ -624,7 +621,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 						       (unsigned long long)seqp->ccid2s_seq);
 					ccid2_hc_tx_dec_pipe(sk);
 				}
-				if (seqp = hctx->ccid2hctx_seqt) {
+				if (seqp = hctx->tx_seqt) {
 					done = 1;
 					break;
 				}
@@ -643,11 +640,11 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	/* The state about what is acked should be correct now
 	 * Check for NUMDUPACK
 	 */
-	seqp = hctx->ccid2hctx_seqt;
-	while (before48(seqp->ccid2s_seq, hctx->ccid2hctx_high_ack)) {
+	seqp = hctx->tx_seqt;
+	while (before48(seqp->ccid2s_seq, hctx->tx_high_ack)) {
 		seqp = seqp->ccid2s_next;
-		if (seqp = hctx->ccid2hctx_seqh) {
-			seqp = hctx->ccid2hctx_seqh->ccid2s_prev;
+		if (seqp = hctx->tx_seqh) {
+			seqp = hctx->tx_seqh->ccid2s_prev;
 			break;
 		}
 	}
@@ -658,7 +655,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			if (done = NUMDUPACK)
 				break;
 		}
-		if (seqp = hctx->ccid2hctx_seqt)
+		if (seqp = hctx->tx_seqt)
 			break;
 		seqp = seqp->ccid2s_prev;
 	}
@@ -681,20 +678,20 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				ccid2_congestion_event(sk, seqp);
 				ccid2_hc_tx_dec_pipe(sk);
 			}
-			if (seqp = hctx->ccid2hctx_seqt)
+			if (seqp = hctx->tx_seqt)
 				break;
 			seqp = seqp->ccid2s_prev;
 		}
 
-		hctx->ccid2hctx_seqt = last_acked;
+		hctx->tx_seqt = last_acked;
 	}
 
 	/* trim acked packets in tail */
-	while (hctx->ccid2hctx_seqt != hctx->ccid2hctx_seqh) {
-		if (!hctx->ccid2hctx_seqt->ccid2s_acked)
+	while (hctx->tx_seqt != hctx->tx_seqh) {
+		if (!hctx->tx_seqt->ccid2s_acked)
 			break;
 
-		hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqt->ccid2s_next;
+		hctx->tx_seqt = hctx->tx_seqt->ccid2s_next;
 	}
 
 	ccid2_hc_tx_check_sanity(hctx);
@@ -707,17 +704,17 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	u32 max_ratio;
 
 	/* RFC 4341, 5: initialise ssthresh to arbitrarily high (max) value */
-	hctx->ccid2hctx_ssthresh  = ~0U;
+	hctx->tx_ssthresh = ~0U;
 
 	/*
 	 * RFC 4341, 5: "The cwnd parameter is initialized to at most four
 	 * packets for new connections, following the rules from [RFC3390]".
 	 * We need to convert the bytes of RFC3390 into the packets of RFC 4341.
 	 */
-	hctx->ccid2hctx_cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
+	hctx->tx_cwnd = clamp(4380U / dp->dccps_mss_cache, 2U, 4U);
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
-	max_ratio = DIV_ROUND_UP(hctx->ccid2hctx_cwnd, 2);
+	max_ratio = DIV_ROUND_UP(hctx->tx_cwnd, 2);
 	if (dp->dccps_l_ack_ratio = 0 || dp->dccps_l_ack_ratio > max_ratio)
 		dp->dccps_l_ack_ratio = max_ratio;
 
@@ -725,12 +722,12 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
-	hctx->ccid2hctx_rto	 = 3 * HZ;
+	hctx->tx_rto	   = 3 * HZ;
 	ccid2_change_srtt(hctx, -1);
-	hctx->ccid2hctx_rttvar	 = -1;
-	hctx->ccid2hctx_rpdupack = -1;
-	hctx->ccid2hctx_last_cong = jiffies;
-	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
+	hctx->tx_rttvar	   = -1;
+	hctx->tx_rpdupack  = -1;
+	hctx->tx_last_cong = jiffies;
+	setup_timer(&hctx->tx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
 
 	ccid2_hc_tx_check_sanity(hctx);
@@ -744,9 +741,9 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 
 	ccid2_hc_tx_kill_rto_timer(sk);
 
-	for (i = 0; i < hctx->ccid2hctx_seqbufc; i++)
-		kfree(hctx->ccid2hctx_seqbuf[i]);
-	hctx->ccid2hctx_seqbufc = 0;
+	for (i = 0; i < hctx->tx_seqbufc; i++)
+		kfree(hctx->tx_seqbuf[i]);
+	hctx->tx_seqbufc = 0;
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
@@ -757,10 +754,10 @@ static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
 	case DCCP_PKT_DATA:
 	case DCCP_PKT_DATAACK:
-		hcrx->ccid2hcrx_data++;
-		if (hcrx->ccid2hcrx_data >= dp->dccps_r_ack_ratio) {
+		hcrx->rx_data++;
+		if (hcrx->rx_data >= dp->dccps_r_ack_ratio) {
 			dccp_send_ack(sk);
-			hcrx->ccid2hcrx_data = 0;
+			hcrx->rx_data = 0;
 		}
 		break;
 	}
