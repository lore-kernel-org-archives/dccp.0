From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Aug 2010 05:21:41 +0000
Subject: [PATCH 3/3] dccp ccid-2: Perform congestion-window validation
Message-Id: <1281676901-7018-4-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

CCID-2's cwnd increases exponentially during slow-start, like TCP.
This growth  of cwnd has implications for
 * the local Sequence Window value (should be > cwnd),
 * the Ack Ratio value.
Hence an exponential growth, if it does not reflect the actual network
conditions, can quickly lead to instability (in fact this was observed, after
a long application-limited time the sender suddenly threw out a huge burst of
packets which lead to the receiver getting out of synch).

This patch adds congestion-window validation (RFC2861) to CCID-2:
 * cwnd is constrained if the sender is application limited;
 * cwnd is reduced after a long idle period, as suggested in the '90 paper
   by Van Jacobson, in RFC 2581 (sec. 4.1);
 * cwnd is never reduced below the RFC 3390 initial window.

As marked in the comments, the code is actually almost a direct copy of the
TCP congestion-window-validation algorithms. By continuing this work, it may
in future be possible to use the TCP code (not possible at the moment).

The mechanism can be turned off using a module parameter. Sampling of the
currently-used window (moving-maximum) is however done constantly, this is
used to determine the expected window, which can be exploited to regulate
DCCP's Sequence Window value.

This patch also sets slow-start-after-idle (RFC 4341, 5.1), i.e. it behaves like
TCP when net.ipv4.tcp_slow_start_after_idle = 1.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.h |   10 ++++++
 net/dccp/ccids/ccid2.c |   84 ++++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 91 insertions(+), 3 deletions(-)

--- a/net/dccp/ccids/ccid2.h
+++ b/net/dccp/ccids/ccid2.h
@@ -53,6 +53,10 @@ struct ccid2_seq {
  * @tx_rttvar:		     moving average/maximum of @mdev_max
  * @tx_rto:		     RTO value deriving from SRTT and RTTVAR (RFC 2988)
  * @tx_rtt_seq:		     to decay RTTVAR at most once per flight
+ * @tx_cwnd_used:	     actually used cwnd, W_used of RFC 2861
+ * @tx_expected_wnd:	     moving average of @tx_cwnd_used
+ * @tx_cwnd_stamp:	     to track idle periods in CWV
+ * @tx_lsndtime:	     last time (in jiffies) a data packet was sent
  * @tx_rpseq:		     last consecutive seqno
  * @tx_rpdupack:	     dupacks since rpseq
  * @tx_av_chunks:	     list of Ack Vectors received on current skb
@@ -76,6 +80,12 @@ struct ccid2_hc_tx_sock {
 	u64			tx_rtt_seq:48;
 	struct timer_list	tx_rtotimer;
 
+	/* Congestion Window validation (optional, RFC 2861) */
+	u32			tx_cwnd_used,
+				tx_expected_wnd,
+				tx_cwnd_stamp,
+				tx_lsndtime;
+
 	u64			tx_rpseq;
 	int			tx_rpdupack;
 	u32			tx_last_cong;
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -153,17 +153,93 @@ out:
 	sock_put(sk);
 }
 
+/*
+ *	Congestion window validation (RFC 2861).
+ */
+static int ccid2_do_cwv = 1;
+module_param(ccid2_do_cwv, bool, 0644);
+MODULE_PARM_DESC(ccid2_do_cwv, "Perform RFC2861 Congestion Window Validation");
+
+/**
+ * ccid2_update_used_window  -  Track how much of cwnd is actually used
+ * This is done in addition to CWV. The sender needs to have an idea of how many
+ * packets may be in flight, to set the local Sequence Window value accordingly
+ * (RFC 4340, 7.5.2). The CWV mechanism is exploited to keep track of the
+ * maximum-used window. We use an EWMA low-pass filter to filter out noise.
+ */
+static void ccid2_update_used_window(struct ccid2_hc_tx_sock *hc, u32 new_wnd)
+{
+	hc->tx_expected_wnd = (3 * hc->tx_expected_wnd + new_wnd) / 4;
+}
+
+/* This borrows the code of tcp_cwnd_application_limited() */
+static void ccid2_cwnd_application_limited(struct sock *sk, const u32 now)
+{
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+	/* don't reduce cwnd below the initial window (IW) */
+	u32 init_win = rfc3390_bytes_to_packets(dccp_sk(sk)->dccps_mss_cache),
+	    win_used = max(hc->tx_cwnd_used, init_win);
+
+	if (win_used < hc->tx_cwnd) {
+		hc->tx_ssthresh = max(hc->tx_ssthresh,
+				     (hc->tx_cwnd >> 1) + (hc->tx_cwnd >> 2));
+		hc->tx_cwnd = (hc->tx_cwnd + win_used) >> 1;
+	}
+	hc->tx_cwnd_used  = 0;
+	hc->tx_cwnd_stamp = now;
+}
+
+/* This borrows the code of tcp_cwnd_restart() */
+static void ccid2_cwnd_restart(struct sock *sk, const u32 now)
+{
+	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+	u32 cwnd = hc->tx_cwnd, restart_cwnd,
+	    iwnd = rfc3390_bytes_to_packets(dccp_sk(sk)->dccps_mss_cache);
+
+	hc->tx_ssthresh = max(hc->tx_ssthresh, (cwnd >> 1) + (cwnd >> 2));
+
+	/* don't reduce cwnd below the initial window (IW) */
+	restart_cwnd = min(cwnd, iwnd);
+	cwnd >>= (now - hc->tx_lsndtime) / hc->tx_rto;
+	hc->tx_cwnd = max(cwnd, restart_cwnd);
+
+	hc->tx_cwnd_stamp = now;
+	hc->tx_cwnd_used  = 0;
+}
+
 static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
+	const u32 now = ccid2_time_stamp;
 	struct ccid2_seq *next;
 
-	hc->tx_pipe++;
+	/* slow-start after idle periods (RFC 2581, RFC 2861) */
+	if (ccid2_do_cwv && !hc->tx_pipe &&
+	    (s32)(now - hc->tx_lsndtime) >= hc->tx_rto)
+		ccid2_cwnd_restart(sk, now);
+
+	hc->tx_lsndtime = now;
+	hc->tx_pipe    += 1;
+
+	/* see whether cwnd was fully used (RFC 2861), update expected window */
+	if (ccid2_cwnd_network_limited(hc)) {
+		ccid2_update_used_window(hc, hc->tx_cwnd);
+		hc->tx_cwnd_used  = 0;
+		hc->tx_cwnd_stamp = now;
+	} else {
+		if (hc->tx_pipe > hc->tx_cwnd_used)
+			hc->tx_cwnd_used = hc->tx_pipe;
+
+		ccid2_update_used_window(hc, hc->tx_cwnd_used);
+
+		if (ccid2_do_cwv && (s32)(now - hc->tx_cwnd_stamp) >= hc->tx_rto)
+			ccid2_cwnd_application_limited(sk, now);
+	}
 
 	hc->tx_seqh->ccid2s_seq   = dp->dccps_gss;
 	hc->tx_seqh->ccid2s_acked = 0;
-	hc->tx_seqh->ccid2s_sent  = ccid2_time_stamp;
+	hc->tx_seqh->ccid2s_sent  = now;
 
 	next = hc->tx_seqh->ccid2s_next;
 	/* check if we need to alloc more space */
@@ -596,6 +672,7 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 
 	/* Use larger initial windows (RFC 3390, rfc2581bis) */
 	hc->tx_cwnd = rfc3390_bytes_to_packets(dp->dccps_mss_cache);
+	hc->tx_expected_wnd = hc->tx_cwnd;
 
 	/* Make sure that Ack Ratio is enabled and within bounds. */
 	max_ratio = DIV_ROUND_UP(hc->tx_cwnd, 2);
@@ -608,7 +685,8 @@ static int ccid2_hc_tx_init(struct ccid *ccid, struct sock *sk)
 
 	hc->tx_rto	 = DCCP_TIMEOUT_INIT;
 	hc->tx_rpdupack  = -1;
-	hc->tx_last_cong = ccid2_time_stamp;
+	hc->tx_last_cong = hc->tx_lsndtime = hc->tx_cwnd_stamp = ccid2_time_stamp;
+	hc->tx_cwnd_used = 0;
 	setup_timer(&hc->tx_rtotimer, ccid2_hc_tx_rto_expire,
 			(unsigned long)sk);
 	INIT_LIST_HEAD(&hc->tx_av_chunks);
