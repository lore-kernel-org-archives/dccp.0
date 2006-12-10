From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:03:05 +0000
Subject: [PATCH 16/22] [DCCP] ccid3: Shift window counter computation
Message-Id: <20061210030305.GR17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

 This puts the window counter computation [RFC 4342, 8.1] into a separate
 function which is called whenever a new packet is ready for immediate
 transmission in ccid3_hc_tx_send_packet.

Justification:

 The window counter update was previously computed after the packet was sent. This has
 two drawbacks, both fixed by this patch:
   1) re-compute another timestamp almost directly after the packet was sent (expensive),
   2) the CCVal for the window counter is needed at the instant the packet is sent.

Further details:

 The initialisation of the window counter is left in the state NO_SENT, as before.
 The algorithm will do nothing if either RTT is initialised to 0 (which is ok) or if
 the RTT value remains below 4 microseconds (which is almost pathological).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   49 ++++++++++++++++++++++++++++--------------------
 1 files changed, 29 insertions(+), 20 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 122a716..1a2ffa1 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -161,6 +161,33 @@ static inline void ccid3_hc_tx_update_s(
 	 */
 }
 
+/*
+ * 	Update Window Counter using the algorithm from [RFC 4342, 8.1].
+ * 	The algorithm is not applicable if RTT < 4 microseconds.
+ */
+static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
+						struct timeval *now)
+{
+	suseconds_t delta;
+	u32 quarter_rtts;
+
+	if (unlikely(hctx->ccid3hctx_rtt < 4))	/* avoid divide-by-zero */
+		return;
+
+	delta = timeval_delta(now, &hctx->ccid3hctx_t_last_win_count);
+	DCCP_BUG_ON(delta < 0);
+
+	quarter_rtts = (u32)delta / (hctx->ccid3hctx_rtt / 4);
+
+	if (quarter_rtts > 0) {
+		hctx->ccid3hctx_t_last_win_count = *now;
+		hctx->ccid3hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
+		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
+
+		ccid3_pr_debug("now at %#X\n", hctx->ccid3hctx_last_win_count);
+	}
+}
+
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -333,6 +360,8 @@ static int ccid3_hc_tx_send_packet(struc
 		 */
 		if (delay - (suseconds_t)hctx->ccid3hctx_delta >= 0)
 			return delay / 1000L;
+
+		ccid3_hc_tx_update_win_count(hctx, &now);
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
@@ -353,7 +382,6 @@ static void ccid3_hc_tx_packet_sent(stru
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
-	suseconds_t quarter_rtt;
 	struct dccp_tx_hist_entry *packet;
 
 	BUG_ON(hctx = NULL);
@@ -373,25 +401,6 @@ static void ccid3_hc_tx_packet_sent(stru
 	}
 	packet->dccphtx_tstamp = now;
 	packet->dccphtx_seqno  = dp->dccps_gss;
-	/*
-	 * Check if win_count have changed
-	 * Algorithm in "8.1. Window Counter Value" in RFC 4342.
-	 */
-	quarter_rtt = timeval_delta(&now, &hctx->ccid3hctx_t_last_win_count);
-	if (likely(hctx->ccid3hctx_rtt > 8))
-		quarter_rtt /= hctx->ccid3hctx_rtt / 4;
-
-	if (quarter_rtt > 0) {
-		hctx->ccid3hctx_t_last_win_count = now;
-		hctx->ccid3hctx_last_win_count	 = (hctx->ccid3hctx_last_win_count +
-						    min_t(unsigned long, quarter_rtt, 5)) % 16;
-		ccid3_pr_debug("%s, sk=%p, window changed from "
-			       "%u to %u!\n",
-			       dccp_role(sk), sk,
-			       packet->dccphtx_ccval,
-			       hctx->ccid3hctx_last_win_count);
-	}
-
 	hctx->ccid3hctx_idle = 0;
 	packet->dccphtx_rtt  = hctx->ccid3hctx_rtt;
 	packet->dccphtx_sent = 1;
-- 
1.4.2.1.g3d5c

