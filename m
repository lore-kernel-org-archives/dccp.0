From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 14 May 2008 09:16:23 +0000
Subject: [CCID-4] [Patch 1/1]: Bug fix - no header penalty during slow-start
Message-Id: <20080514091623.GA21885@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

I haven't heard back so I put the following patch corresponding to your description
at the top of the ccid4 subtree. I can easily replace it if people
wanted this differently.

-------------------------> Patch <------------------------------------------
[CCID4]: No header penalty in slow-start

Bug fix reported by Roksana Boreli on 12/5/2008: header penalty was incorrectly
applied during slow-start.

For packet sizes s this meant that the slow-start degenerated into an 
exponential decrease, due to

 X_0   = RFC3390 initial rate
 X_i+1 = 2 / (1 + 36/s) * X_i	; for i >= 1

When s < 36, the multiplicative factor is less than 1, causing a reduction of X
each time during slow start.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid4.c |   19 ++++++-------------
 1 file changed, 6 insertions(+), 13 deletions(-)

--- a/net/dccp/ccids/ccid4.c
+++ b/net/dccp/ccids/ccid4.c
@@ -93,17 +93,6 @@ static void ccid4_update_send_interval(s
 }
 
 /**
- * ccid4_hc_tx_x_header_penalty  -  Update allowed sending rate X
- * @hctx: half-connection to adjust
- * This function adjusts sending rate according to [TFRC-SP, Section 5]
- */
-static inline void ccid4_hc_tx_x_header_penalty(struct tfrc_hc_tx_sock *hctx)
-{
-	hctx->x *= hctx->s;
-	do_div(hctx->x, (hctx->s + CCID4HCTX_H));
-}
-
-/**
  * ccid4_hc_tx_update_x  -  Update allowed sending rate X
  * @stamp: most recent time if available - can be left NULL.
  * This function tracks draft rfc3448bis, check there for latest details.
@@ -136,14 +125,18 @@ static void ccid4_hc_tx_update_x(struct 
 
 		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
 		low_thresh /= TFRC_T_MBI;
-		ccid4_hc_tx_x_header_penalty(hctx);
+		/*
+		 * CCID-4 Header Penalty:
+		 * Adjust sending rate according to [TFRC-SP, Section 5]
+		 */
+		hctx->x *= hctx->s;
+		do_div(hctx->x, hctx->s + CCID4HCTX_H);
 
 	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
 
 		hctx->x    = min(2 * old_x, min_rate);
 		low_thresh = scaled_div(low_thresh, hctx->rtt);
 		hctx->t_ld = now;
-		ccid4_hc_tx_x_header_penalty(hctx);
 	}
 
 	if (hctx->x != old_x) {
