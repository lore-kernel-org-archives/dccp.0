From: David Miller <davem@davemloft.net>
Date: Tue, 27 May 2008 13:35:33 +0000
Subject: Re: [PATCH 4/7] [CCID-3]: Fix "t_ipi explosion" bug
Message-Id: <20080527.063533.185406813.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1211877167-10995-5-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 09:32:44 +0100

> The identification of this bug is thanks to Cheng Wei and Tomasz Grobelny.
> 
> To avoid divide-by-zero, the implementation previously ignored RTTs smaller
> than 4 microseconds when performing integer division RTT/4.
> 
> When the RTT reached a value less than 4 microseconds (as observed on loopback),
> this prevented the Window Counter CCVal value from advancing. As a result, the
> receiver stopped sending feedback. This in turn caused non-ending expiries of
> the nofeedback timer at the sender, so that the sending rate was progressively
> reduced until reaching the minimum of one packet per 64 seconds.
> 
> The patch fixes this bug by handling integer division more intelligently. Due to
> consistent use of dccp_sample_rtt(), divide-by-zero-RTT is avoided.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>

Because you're mixing coding style cleanups, both of which I've
just NACK'd, with real bug fixes, you're making a lot of work for
me.

Bug fixes go into net-2.6 and anything else goes into net-next-2.6

I've backported this patch into net-2.6, therefore without all the
hctx prefix changes.

dccp ccid-3: Fix "t_ipi explosion" bug

The identification of this bug is thanks to Cheng Wei and Tomasz
Grobelny.

To avoid divide-by-zero, the implementation previously ignored RTTs
smaller than 4 microseconds when performing integer division RTT/4.

When the RTT reached a value less than 4 microseconds (as observed on
loopback), this prevented the Window Counter CCVal value from
advancing. As a result, the receiver stopped sending feedback. This in
turn caused non-ending expiries of the nofeedback timer at the sender,
so that the sending rate was progressively reduced until reaching the
minimum of one packet per 64 seconds.

The patch fixes this bug by handling integer division more
intelligently. Due to consistent use of dccp_sample_rtt(),
divide-by-zero-RTT is avoided.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/dccp/ccids/ccid3.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index cd61dea..f813077 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -193,22 +193,17 @@ static inline void ccid3_hc_tx_update_s(struct ccid3_hc_tx_sock *hctx, int len)
 
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
-	if (unlikely(hctx->ccid3hctx_rtt < 4))	/* avoid divide-by-zero */
-		return;
-
-	quarter_rtts = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count);
-	quarter_rtts /= hctx->ccid3hctx_rtt / 4;
+	u32 delta = ktime_us_delta(now, hctx->ccid3hctx_t_last_win_count),
+	    quarter_rtts = (4 * delta) / hctx->ccid3hctx_rtt;
 
 	if (quarter_rtts > 0) {
 		hctx->ccid3hctx_t_last_win_count = now;
-		hctx->ccid3hctx_last_win_count	+= min_t(u32, quarter_rtts, 5);
+		hctx->ccid3hctx_last_win_count  += min(quarter_rtts, 5U);
 		hctx->ccid3hctx_last_win_count	&= 0xF;		/* mod 16 */
 	}
 }
-- 
1.5.5.1.308.g1fbb5

