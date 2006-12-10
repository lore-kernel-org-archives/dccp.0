From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Sun, 10 Dec 2006 03:01:24 +0000
Subject: [PATCH 7/22] [DCCP] ccid3: Replace scaled division operations
Message-Id: <20061210030124.GI17909@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This replaces the remaining uses of usecs_div with scaled_div32, which
internally uses 64bit division and produces a warning on overflow.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   27 +++------------------------
 1 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index aa355d4..bdd13de 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -41,27 +41,6 @@ #include "lib/loss_interval.h"
 #include "lib/tfrc.h"
 #include "ccid3.h"
 
-/*
- * Reason for maths here is to avoid 32 bit overflow when a is big.
- * With this we get close to the limit.
- */
-static u32 usecs_div(const u32 a, const u32 b)
-{
-	const u32 div = a < (UINT_MAX / (USEC_PER_SEC /    10)) ?    10 :
-			a < (UINT_MAX / (USEC_PER_SEC /    50)) ?    50 :
-			a < (UINT_MAX / (USEC_PER_SEC /   100)) ?   100 :
-			a < (UINT_MAX / (USEC_PER_SEC /   500)) ?   500 :
-			a < (UINT_MAX / (USEC_PER_SEC /  1000)) ?  1000 :
-			a < (UINT_MAX / (USEC_PER_SEC /  5000)) ?  5000 :
-			a < (UINT_MAX / (USEC_PER_SEC / 10000)) ? 10000 :
-			a < (UINT_MAX / (USEC_PER_SEC / 50000)) ? 50000 :
-								 100000;
-	const u32 tmp = a * (USEC_PER_SEC / div);
-	return (b >= 2 * div) ? tmp / (b / div) : tmp;
-}
-
-
-
 #ifdef CONFIG_IP_DCCP_CCID3_DEBUG
 static int ccid3_debug;
 #define ccid3_pr_debug(format, a...)	DCCP_PR_DEBUG(ccid3_debug, format, ##a)
@@ -731,8 +710,8 @@ static void ccid3_hc_rx_send_feedback(st
 	case TFRC_RSTATE_DATA: {
 		const u32 delta = timeval_delta(&now,
 					&hcrx->ccid3hcrx_tstamp_last_feedback);
-		hcrx->ccid3hcrx_x_recv = usecs_div(hcrx->ccid3hcrx_bytes_recv,
-						   delta);
+		hcrx->ccid3hcrx_x_recv +			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 	}
 		break;
 	case TFRC_RSTATE_TERM:
@@ -862,7 +841,7 @@ found:
 
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
-	x_recv = usecs_div(hcrx->ccid3hcrx_bytes_recv, delta);
+	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 
 	if (x_recv = 0)
 		x_recv = hcrx->ccid3hcrx_x_recv;
-- 
1.4.2.1.g3d5c

