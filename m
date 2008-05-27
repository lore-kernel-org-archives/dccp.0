From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 27 May 2008 08:32:46 +0000
Subject: [PATCH 6/7] [CCID-2/3]: Fix sparse warnings
Message-Id: <1211877167-10995-7-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fixes the following two sparse warnings:

 1. Due to a nested min(max()) expression, sparse gave the following warnings:

    net/dccp/ccids/ccid3.c:91:21: warning: symbol '__x' shadows an earlier one
    net/dccp/ccids/ccid3.c:91:21: warning: symbol '__y' shadows an earlier one

    (Didn't use clamp() here since this part is liketly to be split later, when
     implementing the changes from draft rfc3448bis.)

 2. Declaration of function prototypes was in .c instead of .h file.
    This resulted in "should it be static" warnings. Corrected by moving the
    declarations to the tfrc.h file instead of the tfrc.c file.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c    |    3 ++-
 net/dccp/ccids/lib/tfrc.c |    8 --------
 net/dccp/ccids/lib/tfrc.h |   11 +++++++++--
 3 files changed, 11 insertions(+), 11 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -150,7 +150,8 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 
 	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
 
-		hctx->x = max(min(2 * hctx->x, min_rate),
+		hctx->x = min(2 * hctx->x, min_rate);
+		hctx->x = max(hctx->x,
 			      scaled_div(((u64)hctx->s) << 6, hctx->rtt));
 		hctx->t_ld = now;
 	}
--- a/net/dccp/ccids/lib/tfrc.c
+++ b/net/dccp/ccids/lib/tfrc.c
@@ -14,14 +14,6 @@ module_param(tfrc_debug, bool, 0444);
 MODULE_PARM_DESC(tfrc_debug, "Enable debug messages");
 #endif
 
-extern int  tfrc_tx_packet_history_init(void);
-extern void tfrc_tx_packet_history_exit(void);
-extern int  tfrc_rx_packet_history_init(void);
-extern void tfrc_rx_packet_history_exit(void);
-
-extern int  tfrc_li_init(void);
-extern void tfrc_li_exit(void);
-
 static int __init tfrc_module_init(void)
 {
 	int rc = tfrc_li_init();
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -58,7 +58,14 @@ static inline u32 tfrc_ewma(const u32 avg, const u32 newval, const u8 weight)
 	return avg ? (weight * avg + (10 - weight) * newval) / 10 : newval;
 }
 
-extern u32 tfrc_calc_x(u16 s, u32 R, u32 p);
-extern u32 tfrc_calc_x_reverse_lookup(u32 fvalue);
+extern u32  tfrc_calc_x(u16 s, u32 R, u32 p);
+extern u32  tfrc_calc_x_reverse_lookup(u32 fvalue);
 
+extern int  tfrc_tx_packet_history_init(void);
+extern void tfrc_tx_packet_history_exit(void);
+extern int  tfrc_rx_packet_history_init(void);
+extern void tfrc_rx_packet_history_exit(void);
+
+extern int  tfrc_li_init(void);
+extern void tfrc_li_exit(void);
 #endif /* _TFRC_H_ */
-- 
1.5.5

