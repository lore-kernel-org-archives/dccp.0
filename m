From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Mon, 18 Jun 2007 02:07:10 +0000
Subject: [PATCH 3/4] [CCID3]: Sending time: update to ktime_t
Message-Id: <20070618020710.GD4226@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This updates the computation of t_nom and t_last_win_count to use the newer
gettimeofday interface.

Committer note: used ktime_to_timeval to set the 'now' variable to t_ld in
                ccid3hctx_no_feedback_timer

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   33 +++++++++++++--------------------
 net/dccp/ccids/ccid3.h |    5 +++--
 2 files changed, 16 insertions(+), 22 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 407f10c..94b3a1a 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -193,25 +193,20 @@ static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
  *	The algorithm is not applicable if RTT < 4 microseconds.
  */
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
-						struct timeval *now)
+						ktime_t now)
 {
-	suseconds_t delta;
 	u32 quarter_rtts;
 
 	if (unlikely(hctx->ccid3hctx_rtt < 4))	/* avoid divide-by-zero */
 		return;
 
-	delta = timeval_delta(now, &hctx->ccid3hctx_t_last_win_count);
-	DCCP_BUG_ON(delta < 0);
-
-	quarter_rtts = (u32)delta / (hctx->ccid3hctx_rtt / 4);
+	quarter_rtts = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
+	quarter_rtts /= hctx->ccid3hctx_rtt / 4;
 
 	if (quarter_rtts > 0) {
-		hctx->ccid3hctx_t_last_win_count = *now;
+		hctx->ccid3hctx_t_last_win_count = now;
 		hctx->ccid3hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
 		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
-
-		ccid3_pr_debug("now at %#X\n", hctx->ccid3hctx_last_win_count);
 	}
 }
 
@@ -311,8 +306,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct timeval now;
-	suseconds_t delay;
+	ktime_t now = ktime_get_real();
+	s64 delay;
 
 	BUG_ON(hctx = NULL);
 
@@ -324,8 +319,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
-	dccp_timestamp(sk, &now);
-
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_SENT:
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
@@ -348,7 +341,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 			ccid3_pr_debug("SYN RTT = %uus\n", dp->dccps_syn_rtt);
 			hctx->ccid3hctx_rtt  = dp->dccps_syn_rtt;
 			hctx->ccid3hctx_x    = rfc3390_initial_rate(sk);
-			hctx->ccid3hctx_t_ld = now;
+			hctx->ccid3hctx_t_ld = ktime_to_timeval(now);
 		} else {
 			/* Sender does not have RTT sample: X = MSS/second */
 			hctx->ccid3hctx_x = dp->dccps_mss_cache;
@@ -360,7 +353,7 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		delay = timeval_delta(&hctx->ccid3hctx_t_nom, &now);
+		delay = ktime_us_delta(hctx->ccid3hctx_t_nom, now);
 		ccid3_pr_debug("delay=%ld\n", (long)delay);
 		/*
 		 *	Scheduling of packet transmissions [RFC 3448, 4.6]
@@ -370,10 +363,10 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
-			return delay / 1000L;
+		if (delay - (s64)hctx->ccid3hctx_delta >= 0)
+			return (u32)delay / 1000L;
 
-		ccid3_hc_tx_update_win_count(hctx, &now);
+		ccid3_hc_tx_update_win_count(hctx, now);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
@@ -386,8 +379,8 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	hctx->ccid3hctx_idle = 0;
 
 	/* set the nominal send time for the next following packet */
-	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
-
+	hctx->ccid3hctx_t_nom = ktime_add_us(hctx->ccid3hctx_t_nom,
+					     hctx->ccid3hctx_t_ipi);
 	return 0;
 }
 
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 8d31b38..51d4b80 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -36,6 +36,7 @@
 #ifndef _DCCP_CCID3_H_
 #define _DCCP_CCID3_H_
 
+#include <linux/ktime.h>
 #include <linux/list.h>
 #include <linux/time.h>
 #include <linux/types.h>
@@ -108,10 +109,10 @@ struct ccid3_hc_tx_sock {
 	enum ccid3_hc_tx_states		ccid3hctx_state:8;
 	u8				ccid3hctx_last_win_count;
 	u8				ccid3hctx_idle;
-	struct timeval			ccid3hctx_t_last_win_count;
+	ktime_t				ccid3hctx_t_last_win_count;
 	struct timer_list		ccid3hctx_no_feedback_timer;
 	struct timeval			ccid3hctx_t_ld;
-	struct timeval			ccid3hctx_t_nom;
+	ktime_t				ccid3hctx_t_nom;
 	u32				ccid3hctx_delta;
 	struct list_head		ccid3hctx_hist;
 	struct ccid3_options_received	ccid3hctx_options_received;
-- 
1.5.0.6

