From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Mar 2008 16:20:08 +0000
Subject: [PATCH 4/7] [CCID-2/3]: Fix sparse warnings
Message-Id: <1206462011-24907-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fixes the following two sparse warnings:

 1. Due to a nested min(max()) expression, sparse gave the following warnings:

    net/dccp/ccids/ccid3.c:91:21: warning: symbol '__x' shadows an earlier one
    net/dccp/ccids/ccid3.c:91:21: warning: symbol '__y' shadows an earlier one

    In addition, in update_x(), the function call to scaled_div() appeared as
    macro parameter and was thus evaluated multiple times. 
    Fixed by disentangling the nested expression - code also clearer now.

 2. Declaration of function prototypes was in .c instead of .h file.
    This resulted in "should it be static" warnings. Corrected by moving the
    declarations to the tfrc.h file instead of the tfrc.c file.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c    |   11 +++++++----
 net/dccp/ccids/lib/tfrc.c |    8 --------
 net/dccp/ccids/lib/tfrc.h |   11 +++++++++--
 3 files changed, 16 insertions(+), 14 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -130,7 +130,8 @@ static u32 ccid3_hc_tx_idle_rtt(struct c
 static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	u64 min_rate = 2 * hctx->x_recv;
+	u64 min_rate = 2 * hctx->x_recv,
+	    low_thresh = ((u64)hctx->s) << 6;
 	const u64 old_x = hctx->x;
 	ktime_t now = stamp ? *stamp : ktime_get_real();
 
@@ -148,14 +149,16 @@ static void ccid3_hc_tx_update_x(struct 
 	if (hctx->p > 0) {
 
 		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
-		hctx->x = max(hctx->x, (((u64)hctx->s) << 6) / TFRC_T_MBI);
+		low_thresh /= TFRC_T_MBI;
 
 	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
 
-		hctx->x = max(min(2 * hctx->x, min_rate),
-			      scaled_div(((u64)hctx->s) << 6, hctx->rtt));
+		hctx->x = min(2 * old_x, min_rate);
+		low_thresh = scaled_div(low_thresh, hctx->rtt);
 		hctx->t_ld = now;
 	}
+	if (hctx->x < low_thresh)
+		hctx->x = low_thresh;
 
 	if (hctx->x != old_x) {
 		ccid3_pr_debug("X_prev=%u, X_now=%u, X_calc=%u, "
--- a/net/dccp/ccids/lib/tfrc.h
+++ b/net/dccp/ccids/lib/tfrc.h
@@ -58,7 +58,14 @@ static inline u32 tfrc_ewma(const u32 av
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
