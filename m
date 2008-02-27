From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Feb 2008 14:23:07 +0000
Subject: [PATCH 3/4] [CCID2]: Replace broken RTT estimator with better algorithm
Message-Id: <1204122188-9984-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The current CCID-2 RTT estimator code is in parts broken and lags behind the
suggestions in RFC2988 of using scaled variants for SRTT/RTTVAR.
That code is replaced by the present patch, which reuses the Linux TCP RTT
estimator code - reasons for this code duplication are given below.

Further details:
----------------
 1. The minimum RTO of previously one second has been replaced with TCP's, since
    RFC4341, sec. 5 says that the minimum of 1 sec. (suggested in RFC2988, 2.4)
    is not necessary. Instead, the TCP_RTO_MIN is used, which agrees with DCCP's
    concept of a default RTT (RFC 4340, 3.4).
 2. The maximum RTO has been set to DCCP_RTO_MAX (64 sec), which agrees with
    RFC2988, (2.5).
 3. De-inlined the function ccid2_new_ack().
 4. Added a FIXME: the RTT is sampled several times per Ack Vector, which will
    give the wrong estimate. It should be replaced with one sample per Ack.
    However, at the moment this can not be resolved easily, since
    - it depends on TX history code (which also needs some work),
    - the cleanest solution is not to use the `sent' time at all (saves 4 bytes
      per entry) and use DCCP timestamps / elapsed time to estimated the RTT,
      which however is non-trivial to get right (but needs to be done).

Reasons for reusing the Linux TCP estimator algorithm:
------------------------------------------------------
Some time was spent to find a better alternative, using basic RFC2988 as a first
step. Further analysis and experimentation showed that the Linux TCP RTO
estimator is superior to a basic RFC2988 implementation. A summary is on
http://www.erg.abdn.ac.uk/users/gerrit/dccp/notes/ccid2/rto_estimator/

In addition, this estimator fared well in a recent empirical evaluation:

    Rewaskar, Sushant, Jasleen Kaur and F. Donelson Smith.
    A Performance Study of Loss Detection/Recovery in Real-world TCP
    Implementations. Proceedings of 15th IEEE International
    Conference on Network Protocols (ICNP-07). 2007.

Thus there is significant benefit in reusing the existing TCP code.


Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |  168 ++++++++++++++++++++++++++---------------------
 net/dccp/ccids/ccid2.h |   20 ++++--
 2 files changed, 107 insertions(+), 81 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -43,8 +43,13 @@ struct ccid2_seq {
 /** struct ccid2_hc_tx_sock - CCID2 TX half connection
  *
  * @ccid2hctx_{cwnd,ssthresh,pipe}: as per RFC 4341, section 5
- * @ccid2hctx_packets_acked - Ack counter for deriving cwnd growth (RFC 3465)
- * @ccid2hctx_lastrtt -time RTT was last measured
+ * @ccid2hctx_packets_acked: Ack counter for deriving cwnd growth (RFC 3465)
+ * @ccid2hctx_srtt: smoothed RTT estimate, scaled by 2^3
+ * @ccid2hctx_mdev: smoothed RTT variation, scaled by 2^2
+ * @ccid2hctx_mdev_max: maximum of @mdev during one flight
+ * @ccid2hctx_rttvar: moving average/maximum of @mdev_max
+ * @ccid2hctx_rto: RTO value deriving from SRTT and RTTVAR (RFC 2988)
+ * @ccid2hctx_rtt_seq: to decay RTTVAR at most once per flight
  * @ccid2hctx_rpseq - last consecutive seqno
  * @ccid2hctx_rpdupack - dupacks since rpseq
  * @ccid2hctx_av_chunks: list of Ack Vectors received on current skb
@@ -58,10 +63,13 @@ struct ccid2_hc_tx_sock {
 	int			ccid2hctx_seqbufc;
 	struct ccid2_seq	*ccid2hctx_seqh;
 	struct ccid2_seq	*ccid2hctx_seqt;
-	long			ccid2hctx_rto;
-	long			ccid2hctx_srtt;
-	long			ccid2hctx_rttvar;
-	unsigned long		ccid2hctx_lastrtt;
+	/* RTT measurement: variables/principles are the same as in TCP */
+	u32			ccid2hctx_srtt,
+				ccid2hctx_mdev,
+				ccid2hctx_mdev_max,
+				ccid2hctx_rttvar,
+				ccid2hctx_rto;
+	u64			ccid2hctx_rtt_seq:48;
 	struct timer_list	ccid2hctx_rtotimer;
 	u64			ccid2hctx_rpseq;
 	int			ccid2hctx_rpdupack;
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -111,12 +111,6 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_change_srtt(struct ccid2_hc_tx_sock *hctx, long val)
-{
-	ccid2_pr_debug("change SRTT to %ld\n", val);
-	hctx->ccid2hctx_srtt = val;
-}
-
 static void ccid2_start_rto_timer(struct sock *sk);
 
 static void ccid2_hc_tx_rto_expire(unsigned long data)
@@ -124,7 +118,6 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	struct sock *sk = (struct sock *)data;
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	const bool sender_was_blocked = ccid2_cwnd_network_limited(hctx);
-	long s;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -137,10 +130,8 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 
 	/* back-off timer */
 	hctx->ccid2hctx_rto <<= 1;
-
-	s = hctx->ccid2hctx_rto / HZ;
-	if (s > 60)
-		hctx->ccid2hctx_rto = 60 * HZ;
+	if (hctx->ccid2hctx_rto > DCCP_RTO_MAX)
+		hctx->ccid2hctx_rto = DCCP_RTO_MAX;
 
 	/* adjust pipe, cwnd etc */
 	hctx->ccid2hctx_ssthresh = hctx->ccid2hctx_cwnd / 2;
@@ -282,9 +273,87 @@ static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
 	ccid2_pr_debug("deleted RTO timer\n");
 }
 
-static inline void ccid2_new_ack(struct sock *sk,
-				 struct ccid2_seq *seqp,
-				 unsigned int *maxincr)
+/**
+ * ccid2_rtt_estimator - Sample RTT and compute RTO using RFC2988 algorithm
+ * This code is almost identical with TCP's tcp_rtt_estimator(), since
+ * - it has a higher sampling frequency (recommended by RFC 1323),
+ * - the RTO does not collapse into RTT due to RTTVAR going towards zero,
+ * - it is simple (cf. more complex proposals such as Eifel timer or research
+ *   which suggests that the gain should be set according to window size),
+ * - in tests it was found to work well with CCID2 [gerrit].
+ */
+static void ccid2_rtt_estimator(struct sock *sk, const long mrtt)
+{
+	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
+	long m = mrtt ? : 1;
+
+	if (hctx->ccid2hctx_srtt = 0) {
+		/* First measurement m */
+		hctx->ccid2hctx_srtt = m << 3;
+		hctx->ccid2hctx_mdev = m << 1;
+
+		hctx->ccid2hctx_mdev_max = max(TCP_RTO_MIN, hctx->ccid2hctx_mdev);
+		hctx->ccid2hctx_rttvar	 = hctx->ccid2hctx_mdev_max;
+		hctx->ccid2hctx_rtt_seq	 = dccp_sk(sk)->dccps_gss;
+	} else {
+		/* Update scaled SRTT as SRTT += 1/8 * (m - SRTT) */
+		m -= (hctx->ccid2hctx_srtt >> 3);
+		hctx->ccid2hctx_srtt += m;
+
+		/* Similarly, update scaled mdev with regard to |m| */
+		if (m < 0) {
+			m = -m;
+			m -= (hctx->ccid2hctx_mdev >> 2);
+			/*
+			 * This neutralises RTO increase when RTT < SRTT - mdev
+			 * (see P. Sarolahti and * A. Kuznetsov,
+			 *     "Congestion Control in Linux TCP",
+			 *      USENIX 2002, pp. 49-62).
+			 */
+			if (m > 0)
+				m >>= 3;
+		} else {
+			m -= (hctx->ccid2hctx_mdev >> 2);
+		}
+		hctx->ccid2hctx_mdev += m;
+
+		if (hctx->ccid2hctx_mdev > hctx->ccid2hctx_mdev_max) {
+			hctx->ccid2hctx_mdev_max = hctx->ccid2hctx_mdev;
+			if (hctx->ccid2hctx_mdev_max > hctx->ccid2hctx_rttvar)
+				hctx->ccid2hctx_rttvar = hctx->ccid2hctx_mdev_max;
+		}
+
+		/*
+		 * Decay RTTVAR at most once per flight, exploiting that
+		 *  1) pipe <= cwnd <= Sequence_Window = W  (RFC 4340, 7.5.2)
+		 *  2) AWL = GSS-W+1 <= GAR <= GSS          (RFC 4340, 7.5.1)
+		 * GAR is a useful bound for FlightSize = pipe, AWL is probably
+		 * too low as it over-estimates pipe.
+		 */
+		if (after48(dccp_sk(sk)->dccps_gar, hctx->ccid2hctx_rtt_seq)) {
+			if (hctx->ccid2hctx_mdev_max < hctx->ccid2hctx_rttvar)
+				hctx->ccid2hctx_rttvar -= (hctx->ccid2hctx_rttvar - hctx->ccid2hctx_mdev_max) >> 2;
+			hctx->ccid2hctx_rtt_seq  = dccp_sk(sk)->dccps_gss;
+			hctx->ccid2hctx_mdev_max = TCP_RTO_MIN;
+		}
+	}
+
+	/*
+	 * Set RTO from SRTT and RTTVAR
+	 * Clock granularity is ignored since the minimum error for RTTVAR is
+	 * clamped to 50msec (corresponding to HZ ). This leads to a minimum
+	 * RTO of 200msec. This agrees with TCP and RFC 4341, 5.: "Because DCCP
+	 * does not retransmit data, DCCP does not require TCP's recommended
+	 * minimum timeout of one second".
+	 */
+	hctx->ccid2hctx_rto = (hctx->ccid2hctx_srtt >> 3) + hctx->ccid2hctx_rttvar;
+
+	if (hctx->ccid2hctx_rto > DCCP_RTO_MAX)
+		hctx->ccid2hctx_rto = DCCP_RTO_MAX;
+}
+
+static void ccid2_new_ack(struct sock *sk, struct ccid2_seq *seqp,
+			  unsigned int *maxincr)
 {
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 
@@ -298,64 +367,15 @@ static inline void ccid2_new_ack(struct sock *sk,
 			hctx->ccid2hctx_cwnd += 1;
 			hctx->ccid2hctx_packets_acked = 0;
 	}
-
-	/* update RTO */
-	if (hctx->ccid2hctx_srtt = -1 ||
-	    time_after(jiffies, hctx->ccid2hctx_lastrtt + hctx->ccid2hctx_srtt)) {
-		unsigned long r = (long)jiffies - (long)seqp->ccid2s_sent;
-		int s;
-
-		/* first measurement */
-		if (hctx->ccid2hctx_srtt = -1) {
-			ccid2_pr_debug("R: %lu Time=%lu seq=%llu\n",
-				       r, jiffies,
-				       (unsigned long long)seqp->ccid2s_seq);
-			ccid2_change_srtt(hctx, r);
-			hctx->ccid2hctx_rttvar = r >> 1;
-		} else {
-			/* RTTVAR */
-			long tmp = hctx->ccid2hctx_srtt - r;
-			long srtt;
-
-			if (tmp < 0)
-				tmp *= -1;
-
-			tmp >>= 2;
-			hctx->ccid2hctx_rttvar *= 3;
-			hctx->ccid2hctx_rttvar >>= 2;
-			hctx->ccid2hctx_rttvar += tmp;
-
-			/* SRTT */
-			srtt = hctx->ccid2hctx_srtt;
-			srtt *= 7;
-			srtt >>= 3;
-			tmp = r >> 3;
-			srtt += tmp;
-			ccid2_change_srtt(hctx, srtt);
-		}
-		s = hctx->ccid2hctx_rttvar << 2;
-		/* clock granularity is 1 when based on jiffies */
-		if (!s)
-			s = 1;
-		hctx->ccid2hctx_rto = hctx->ccid2hctx_srtt + s;
-
-		/* must be at least a second */
-		s = hctx->ccid2hctx_rto / HZ;
-		/* DCCP doesn't require this [but I like it cuz my code sux] */
-#if 1
-		if (s < 1)
-			hctx->ccid2hctx_rto = HZ;
-#endif
-		/* max 60 seconds */
-		if (s > 60)
-			hctx->ccid2hctx_rto = HZ * 60;
-
-		hctx->ccid2hctx_lastrtt = jiffies;
-
-		ccid2_pr_debug("srtt: %ld rttvar: %ld rto: %ld (HZ=%d) R=%lu\n",
-			       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
-			       hctx->ccid2hctx_rto, HZ, r);
-	}
+	/*
+	 * FIXME: RTT is sampled several times per acknowledgment (for each
+	 * entry in the Ack Vector), instead of once per Ack (as in TCP SACK).
+	 * This causes the RTT to be over-estimated, since the older entries
+	 * in the Ack Vector have earlier sending times.
+	 * The cleanest solution is to not use the ccid2s_sent field at all
+	 * and instead use DCCP timestamps - need to be resolved at some time.
+	 */
+	ccid2_rtt_estimator(sk, jiffies - seqp->ccid2s_sent);
 }
 
 static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
@@ -617,9 +637,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 	if (ccid2_hc_tx_alloc_seq(hctx))
 		return -ENOMEM;
 
-	hctx->ccid2hctx_rto	 = 3 * HZ;
-	ccid2_change_srtt(hctx, -1);
-	hctx->ccid2hctx_rttvar	 = -1;
+	hctx->ccid2hctx_rto	 = DCCP_TIMEOUT_INIT;
 	hctx->ccid2hctx_rpdupack = -1;
 	hctx->ccid2hctx_last_cong = jiffies;
 	setup_timer(&hctx->ccid2hctx_rtotimer, ccid2_hc_tx_rto_expire,
