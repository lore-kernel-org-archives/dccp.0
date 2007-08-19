From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Sun, 19 Aug 2007 23:49:01 +0000
Subject: [PATCH 02/15] Make ccid3_hc_tx_update_x get a timestamp if needed
Message-Id: <20070819234901.GF24792@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The code was too complicated, if p > 0 in ccid3_hc_tx_no_feedback_timer the
timestamp was being obtained to be passed to ccid3_hc_tx_update_x, where only
if p > 0 the timestamp was needed, so just leave it to ccid3_hc_tx_update_x to
obtain the timestamp if needed.

This will help in the upcoming changesets where we'll convert t_ld to ktime_t.
We'll eventually try to reuse ktime_get_real() calls again.

Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   30 ++++++++++++++++--------------
 1 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index e91c2b9..d0763ad 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -128,7 +128,7 @@ static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
  *       throughout the code. Only X_calc is unscaled (in bytes/second).
  *
  */
-static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
+static void ccid3_hc_tx_update_x(struct sock *sk)
 
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
@@ -153,14 +153,20 @@ static void ccid3_hc_tx_update_x(struct sock *sk, struct timeval *now)
 					(((__u64)hctx->ccid3hctx_s) << 6) /
 								TFRC_T_MBI);
 
-	} else if (timeval_delta(now, &hctx->ccid3hctx_t_ld) -
-			(suseconds_t)hctx->ccid3hctx_rtt >= 0) {
+	} else {
+		struct timeval now;
 
-		hctx->ccid3hctx_x -			max(min(2 * hctx->ccid3hctx_x, min_rate),
-			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
-				       hctx->ccid3hctx_rtt));
-		hctx->ccid3hctx_t_ld = *now;
+		dccp_timestamp(sk, &now);
+
+		if ((timeval_delta(&now, &hctx->ccid3hctx_t_ld) -
+		     (suseconds_t)hctx->ccid3hctx_rtt) >= 0) {
+
+			hctx->ccid3hctx_x +				max(min(2 * hctx->ccid3hctx_x, min_rate),
+				    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
+					       hctx->ccid3hctx_rtt));
+			hctx->ccid3hctx_t_ld = now;
+		}
 	}
 
 	if (hctx->ccid3hctx_x != old_x) {
@@ -214,7 +220,6 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	struct timeval now;
 	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
@@ -265,15 +270,12 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 				max(hctx->ccid3hctx_x_recv / 2,
 				    (((__u64)hctx->ccid3hctx_s) << 6) /
 							      (2 * TFRC_T_MBI));
-
-			if (hctx->ccid3hctx_p = 0)
-				dccp_timestamp(sk, &now);
 		} else {
 			hctx->ccid3hctx_x_recv = hctx->ccid3hctx_x_calc;
 			hctx->ccid3hctx_x_recv <<= 4;
 		}
 		/* Now recalculate X [RFC 3448, 4.3, step (4)] */
-		ccid3_hc_tx_update_x(sk, &now);
+		ccid3_hc_tx_update_x(sk);
 		/*
 		 * Schedule no feedback timer to expire in
 		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
@@ -496,7 +498,7 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 					tfrc_calc_x(hctx->ccid3hctx_s,
 						    hctx->ccid3hctx_rtt,
 						    hctx->ccid3hctx_p);
-			ccid3_hc_tx_update_x(sk, &now);
+			ccid3_hc_tx_update_x(sk);
 
 			ccid3_pr_debug("%s(%p), RTT=%uus (sample=%uus), s=%u, "
 				       "p=%u, X_calc=%u, X_recv=%u, X=%u\n",
-- 
1.5.2.2

