From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:06 +0000
Subject: [PATCH 1/25]: Fix bug in the calculation of very low sending rates
Message-Id: <200703211844.06124@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Fix bug in the calculation of very low sending rates

This fixes an error in the calculation of t_ipi when X converges towards
very low sending rates (between 1 and 64 bytes per second).

Although this case may not sound likely, it can be reproduced by connecting,
hitting enter (1 byte sent) and waiting for some time, during which the
nofeedback timer halves the sending rate until finally it reaches the region
1..64 bytes/sec. Computing X is handled correctly (tested separately); but by
dividing X _before_ entering the calculation of t_ipi, X becomes zero as
a result.  This in turn triggers a BUG condition caught in scaled_div().

Fixed by replacing with equivalent statement and explicit typecast for good
measure.

Calculation verified and effect of patch tested - reduced never below 1 byte
per 64 seconds afterwards, i.e. not allowing divide-by-zero.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -102,8 +102,8 @@ static inline u64 rfc3390_initial_rate(s
 static inline void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
 	/* Calculate new t_ipi = s / X_inst (X_inst is in 64 * bytes/second) */
-	hctx->ccid3hctx_t_ipi = scaled_div(hctx->ccid3hctx_s,
-					   hctx->ccid3hctx_x >> 6);
+	hctx->ccid3hctx_t_ipi = scaled_div32(((u64)hctx->ccid3hctx_s) << 6,
+					     hctx->ccid3hctx_x);
 
 	/* Calculate new delta by delta = min(t_ipi / 2, t_gran / 2) */
 	hctx->ccid3hctx_delta = min_t(u32, hctx->ccid3hctx_t_ipi / 2,
