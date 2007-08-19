From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:49:21 +0000
Subject: [PATCH 03/15] Convert ccid3hctx_t_ld to ktime_t
Message-Id: <20070819234921.GG24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   12 +++++-------
 net/dccp/ccids/ccid3.h |    3 +--
 2 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index d0763ad..42d3dbc 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -154,12 +154,10 @@ static void ccid3_hc_tx_update_x(struct sock *sk)
 								TFRC_T_MBI);
 
 	} else {
-		struct timeval now;
+		const ktime_t now = ktime_get_real();
 
-		dccp_timestamp(sk, &now);
-
-		if ((timeval_delta(&now, &hctx->ccid3hctx_t_ld) -
-		     (suseconds_t)hctx->ccid3hctx_rtt) >= 0) {
+		if ((ktime_us_delta(now, hctx->ccid3hctx_t_ld) -
+		     (s64)hctx->ccid3hctx_rtt) >= 0) {
 
 			hctx->ccid3hctx_x  				max(min(2 * hctx->ccid3hctx_x, min_rate),
@@ -343,7 +341,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
 			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = ktime_to_timeval(now);
+			hctx->ccid3hctx_t_ld = now;
 		} else {
 			/* Sender does not have RTT sample: X = MSS/second */
 			hctx->ccid3hctx_x = dp->dccps_mss_cache;
@@ -477,7 +475,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 			 */
 			hctx->ccid3hctx_rtt  = r_sample;
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->ccid3hctx_t_ld = timeval_to_ktime(now);
 
 			ccid3_update_send_interval(hctx);
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 51d4b80..dcb6b67 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -38,7 +38,6 @@
 
 #include <linux/ktime.h>
 #include <linux/list.h>
-#include <linux/time.h>
 #include <linux/types.h>
 #include <linux/tfrc.h>
 #include "../ccid.h"
@@ -111,7 +110,7 @@ struct ccid3_hc_tx_sock {
 	u8				ccid3hctx_idle;
 	ktime_t				ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
-	struct timeval			ccid3hctx_t_ld;
+	ktime_t				ccid3hctx_t_ld;
 	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
 	struct list_head		ccid3hctx_hist;
-- 
1.5.2.2

