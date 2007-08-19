From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:49:59 +0000
Subject: [PATCH 05/15] Convert ccid3hcrx_tstamp_last_feedback to ktime_t
Message-Id: <20070819234959.GI24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   19 +++++++++++--------
 net/dccp/ccids/ccid3.h |    2 +-
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 63051eb..1a0c5ed 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -729,20 +729,21 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_rx_hist_entry *packet;
-	struct timeval now;
+	struct timeval tnow;
+	ktime_t now;
 	suseconds_t delta;
 
 	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
 
-	dccp_timestamp(sk, &now);
+	now = ktime_get_real();
 
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
 		hcrx->ccid3hcrx_x_recv = 0;
 		break;
 	case TFRC_RSTATE_DATA:
-		delta = timeval_delta(&now,
-				      &hcrx->ccid3hcrx_tstamp_last_feedback);
+		delta = ktime_us_delta(now,
+				       hcrx->ccid3hcrx_tstamp_last_feedback);
 		DCCP_BUG_ON(delta < 0);
 		hcrx->ccid3hcrx_x_recv  			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
@@ -764,7 +765,8 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
 	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
-	delta = timeval_delta(&now, &packet->dccphrx_tstamp);
+	tnow = ktime_to_timeval(now);
+	delta = timeval_delta(&tnow, &packet->dccphrx_tstamp);
 	DCCP_BUG_ON(delta < 0);
 	hcrx->ccid3hcrx_elapsed_time = delta / 10;
 
@@ -835,11 +837,13 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
+		struct timeval tstamp +			ktime_to_timeval(hcrx->ccid3hcrx_tstamp_last_feedback);
 		loss = 1;
 		dccp_li_update_li(sk,
 				  &hcrx->ccid3hcrx_li_hist,
 				  &hcrx->ccid3hcrx_hist,
-				  &hcrx->ccid3hcrx_tstamp_last_feedback,
+				  &tstamp,
 				  hcrx->ccid3hcrx_s,
 				  hcrx->ccid3hcrx_bytes_recv,
 				  hcrx->ccid3hcrx_x_recv,
@@ -989,9 +993,8 @@ static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	hcrx->ccid3hcrx_tstamp_last_ack = ktime_get_real();
 	hcrx->ccid3hcrx_tstamp_last_feedback -		ktime_to_timeval(hcrx->ccid3hcrx_tstamp_last_ack);
+		hcrx->ccid3hcrx_tstamp_last_ack = ktime_get_real();
 	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 0;
 	return 0;
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index a69cf88..7cbf2b1 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -152,7 +152,7 @@ struct ccid3_hc_rx_sock {
 					ccid3hcrx_ccval_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
-	struct timeval			ccid3hcrx_tstamp_last_feedback;
+	ktime_t				ccid3hcrx_tstamp_last_feedback;
 	ktime_t				ccid3hcrx_tstamp_last_ack;
 	struct list_head		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
-- 
1.5.2.2

