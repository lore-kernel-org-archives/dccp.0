From: Ian McDonald <ian.mcdonald@jandi.co.nz>
Date: Mon, 22 Jan 2007 22:22:17 +0000
Subject: [PATCH 1/1] DCCP: Fix dccp_calc_first_li
Message-Id: <200701231122.18624.ian.mcdonald@jandi.co.nz>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

dccp_calc_first_li is calculating incorrect values by observation.

We don't need to calculate rtt as it has already been calculated elsewhere.
The previous calculation was wrong from the logs.

The value for x_recv was wrong as it was calculating ALL bytes received
divided only by number of packets in last RTT. As we don't store bytes
received in packet history then calculate using s.

Also fix up comments as it is not returning usecs but packet interval.

Tidy up debugging a little too.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
---
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index fec5ba3..5026802 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -251,18 +251,19 @@ static int dccp_li_hist_interval_new(struct list_head *list,
 
 /* calculate first loss interval
  *
- * returns estimated loss interval in usecs */
+ * returns estimated loss interval */
 
 static u32 dccp_li_calc_first_li(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
-	u32 x_recv, p;
+	u32 x_recv, p, bytes_recv;
 	suseconds_t rtt, delta;
 	struct timeval tstamp = { 0, };
 	int interval = 0;
 	int win_count = 0;
 	int step = 0;
+	int pkt_count = 0;
 	u64 fval;
 
 	list_for_each_entry_safe(entry, next, &hcrx->ccid3hcrx_hist,
@@ -278,6 +279,7 @@ static u32 dccp_li_calc_first_li(struct sock *sk, struct sk_buff *skb)
 				break;
 			case 1:
 				interval = win_count - entry->dccphrx_ccval;
+				pkt_count++;
 				if (interval < 0)
 					interval += TFRC_WIN_COUNT_LIMIT;
 				if (interval > 4)
@@ -307,9 +309,7 @@ found:
 	delta = timeval_delta(&tstamp, &tail->dccphrx_tstamp);
 	DCCP_BUG_ON(delta < 0);
 
-	rtt = delta * 4 / interval;
-	dccp_pr_debug("%s(%p), approximated RTT to %dus\n",
-		       dccp_role(sk), sk, (int)rtt);
+	rtt = hcrx->ccid3hcrx_rtt;
 
 	/*
 	 * Determine the length of the first loss interval via inverse lookup.
@@ -328,7 +328,13 @@ found:
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
 	DCCP_BUG_ON(delta <= 0);
 
-	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+	bytes_recv = hcrx->ccid3hcrx_s * pkt_count;
+
+	dccp_pr_debug("%s(%p), rtt=%dus, delta=%dus, bytes_recv=%u "
+	              "pkt_count=%d\n", dccp_role(sk), sk, (int)rtt,
+		      (int)delta, bytes_recv, pkt_count);
+
+	x_recv = scaled_div32(bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
 		DCCP_WARN("X_recv=0\n");
 		if ((x_recv = hcrx->ccid3hcrx_x_recv) = 0) {
