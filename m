From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:51:47 +0000
Subject: [PATCH 10/15] [DCCP] packet_history: convert dccphrx_tstamp to
Message-Id: <20070819235147.GN24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c              |   11 ++++-------
 net/dccp/ccids/lib/loss_interval.c  |   11 +++++------
 net/dccp/ccids/lib/loss_interval.h  |    4 ++--
 net/dccp/ccids/lib/packet_history.h |    6 +++---
 4 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 6b12e9f..b21d811 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -727,7 +727,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct dccp_rx_hist_entry *packet;
-	ktime_t now, t_hist;
+	ktime_t now;
 	suseconds_t delta;
 
 	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
@@ -762,8 +762,7 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
 	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
-	t_hist = timeval_to_ktime(packet->dccphrx_tstamp);
-	delta = ktime_us_delta(now, t_hist);
+	delta = ktime_us_delta(now, packet->dccphrx_tstamp);
 	DCCP_BUG_ON(delta < 0);
 	hcrx->ccid3hcrx_elapsed_time = delta / 10;
 
@@ -834,13 +833,11 @@ static int ccid3_hc_rx_detect_loss(struct sock *sk,
 
 	while (dccp_delta_seqno(hcrx->ccid3hcrx_seqno_nonloss, seqno)
 	   > TFRC_RECV_NUM_LATE_LOSS) {
-		struct timeval tstamp -			ktime_to_timeval(hcrx->ccid3hcrx_tstamp_last_feedback);
 		loss = 1;
 		dccp_li_update_li(sk,
 				  &hcrx->ccid3hcrx_li_hist,
 				  &hcrx->ccid3hcrx_hist,
-				  &tstamp,
+				  hcrx->ccid3hcrx_tstamp_last_feedback,
 				  hcrx->ccid3hcrx_s,
 				  hcrx->ccid3hcrx_bytes_recv,
 				  hcrx->ccid3hcrx_x_recv,
@@ -913,7 +910,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		return;
 	}
 
-	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, sk, opt_recv->dccpor_ndp,
+	packet = dccp_rx_hist_entry_new(ccid3_rx_hist, opt_recv->dccpor_ndp,
 					skb, GFP_ATOMIC);
 	if (unlikely(packet = NULL)) {
 		DCCP_WARN("%s(%p), Not enough mem to add rx packet "
diff --git a/net/dccp/ccids/lib/loss_interval.c b/net/dccp/ccids/lib/loss_interval.c
index 174d3f1..40ad428 100644
--- a/net/dccp/ccids/lib/loss_interval.c
+++ b/net/dccp/ccids/lib/loss_interval.c
@@ -125,14 +125,14 @@ static int dccp_li_hist_interval_new(struct list_head *list,
  * returns estimated loss interval in usecs */
 static u32 dccp_li_calc_first_li(struct sock *sk,
 				 struct list_head *hist_list,
-				 struct timeval *last_feedback,
+				 ktime_t last_feedback,
 				 u16 s, u32 bytes_recv,
 				 u32 previous_x_recv)
 {
 	struct dccp_rx_hist_entry *entry, *next, *tail = NULL;
 	u32 x_recv, p;
 	suseconds_t rtt, delta;
-	struct timeval tstamp = { 0, 0 };
+	ktime_t tstamp = ktime_set(0, 0);
 	int interval = 0;
 	int win_count = 0;
 	int step = 0;
@@ -176,7 +176,7 @@ found:
 		return ~0;
 	}
 
-	delta = timeval_delta(&tstamp, &tail->dccphrx_tstamp);
+	delta = ktime_us_delta(tstamp, tail->dccphrx_tstamp);
 	DCCP_BUG_ON(delta < 0);
 
 	rtt = delta * 4 / interval;
@@ -196,8 +196,7 @@ found:
 		return ~0;
 	}
 
-	dccp_timestamp(sk, &tstamp);
-	delta = timeval_delta(&tstamp, last_feedback);
+	delta = ktime_us_delta(ktime_get_real(), last_feedback);
 	DCCP_BUG_ON(delta <= 0);
 
 	x_recv = scaled_div32(bytes_recv, delta);
@@ -226,7 +225,7 @@ found:
 void dccp_li_update_li(struct sock *sk,
 		       struct list_head *li_hist_list,
 		       struct list_head *hist_list,
-		       struct timeval *last_feedback, u16 s, u32 bytes_recv,
+		       ktime_t last_feedback, u16 s, u32 bytes_recv,
 		       u32 previous_x_recv, u64 seq_loss, u8 win_loss)
 {
 	struct dccp_li_hist_entry *head;
diff --git a/net/dccp/ccids/lib/loss_interval.h b/net/dccp/ccids/lib/loss_interval.h
index 906c806..27bee92 100644
--- a/net/dccp/ccids/lib/loss_interval.h
+++ b/net/dccp/ccids/lib/loss_interval.h
@@ -13,8 +13,8 @@
  *  any later version.
  */
 
+#include <linux/ktime.h>
 #include <linux/list.h>
-#include <linux/time.h>
 
 extern void dccp_li_hist_purge(struct list_head *list);
 
@@ -23,7 +23,7 @@ extern u32 dccp_li_hist_calc_i_mean(struct list_head *list);
 extern void dccp_li_update_li(struct sock *sk,
 			      struct list_head *li_hist_list,
 			      struct list_head *hist_list,
-			      struct timeval *last_feedback, u16 s,
+			      ktime_t last_feedback, u16 s,
 			      u32 bytes_recv, u32 previous_x_recv,
 			      u64 seq_loss, u8 win_loss);
 #endif /* _DCCP_LI_HIST_ */
diff --git a/net/dccp/ccids/lib/packet_history.h b/net/dccp/ccids/lib/packet_history.h
index 60d00f0..d9d6896 100644
--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -37,6 +37,7 @@
 #ifndef _DCCP_PKT_HIST_
 #define _DCCP_PKT_HIST_
 
+#include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/time.h>
@@ -124,7 +125,7 @@ struct dccp_rx_hist_entry {
 			 dccphrx_ccval:4,
 			 dccphrx_type:4;
 	u32		 dccphrx_ndp; /* In fact it is from 8 to 24 bits */
-	struct timeval	 dccphrx_tstamp;
+	ktime_t		 dccphrx_tstamp;
 };
 
 struct dccp_rx_hist {
@@ -136,7 +137,6 @@ extern void 		dccp_rx_hist_delete(struct dccp_rx_hist *hist);
 
 static inline struct dccp_rx_hist_entry *
 			dccp_rx_hist_entry_new(struct dccp_rx_hist *hist,
-					       const struct sock *sk,
 					       const u32 ndp,
 					       const struct sk_buff *skb,
 					       const gfp_t prio)
@@ -151,7 +151,7 @@ static inline struct dccp_rx_hist_entry *
 		entry->dccphrx_ccval = dh->dccph_ccval;
 		entry->dccphrx_type  = dh->dccph_type;
 		entry->dccphrx_ndp   = ndp;
-		dccp_timestamp(sk, &entry->dccphrx_tstamp);
+		entry->dccphrx_tstamp = ktime_get_real();
 	}
 
 	return entry;
-- 
1.5.2.2

