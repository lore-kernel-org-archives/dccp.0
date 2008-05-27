From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 08:32:44 +0000
Subject: [PATCH 4/7] [CCID-3]: Fix "t_ipi explosion" bug
Message-Id: <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

The identification of this bug is thanks to Cheng Wei and Tomasz Grobelny.

To avoid divide-by-zero, the implementation previously ignored RTTs smaller
than 4 microseconds when performing integer division RTT/4.

When the RTT reached a value less than 4 microseconds (as observed on loopback),
this prevented the Window Counter CCVal value from advancing. As a result, the
receiver stopped sending feedback. This in turn caused non-ending expiries of
the nofeedback timer at the sender, so that the sending rate was progressively
reduced until reaching the minimum of one packet per 64 seconds.

The patch fixes this bug by handling integer division more intelligently. Due to
consistent use of dccp_sample_rtt(), divide-by-zero-RTT is avoided.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -181,22 +181,17 @@ static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 
 /*
  *	Update Window Counter using the algorithm from [RFC 4342, 8.1].
- *	The algorithm is not applicable if RTT < 4 microseconds.
+ *	As elsewhere, RTT > 0 is assumed by using dccp_sample_rtt().
  */
 static inline void ccid3_hc_tx_update_win_count(struct ccid3_hc_tx_sock *hctx,
 						ktime_t now)
 {
-	u32 quarter_rtts;
-
-	if (unlikely(hctx->rtt < 4))	/* avoid divide-by-zero */
-		return;
-
-	quarter_rtts = ktime_us_delta(now, hctx->t_last_win_count);
-	quarter_rtts /= hctx->rtt / 4;
+	u32 delta = ktime_us_delta(now, hctx->t_last_win_count),
+	    quarter_rtts = (4 * delta) / hctx->rtt;
 
 	if (quarter_rtts > 0) {
 		hctx->t_last_win_count = now;
-		hctx->last_win_count  += min_t(u32, quarter_rtts, 5);
+		hctx->last_win_count  += min(quarter_rtts, 5U);
 		hctx->last_win_count  &= 0xF;		/* mod 16 */
 	}
 }
-- 
1.5.5

