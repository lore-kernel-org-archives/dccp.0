From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 10 Jun 2008 12:53:38 +0000
Subject: [PATCH 2/7] dccp: Fix sparse warnings
Message-Id: <1213102423-27486-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch fixes the following sparse warnings:
 * nested min(max()) expression:
   net/dccp/ccids/ccid3.c:91:21: warning: symbol '__x' shadows an earlier one
   net/dccp/ccids/ccid3.c:91:21: warning: symbol '__y' shadows an earlier one

 * Declaration of function prototypes in .c instead of .h file, resulting in
   "should it be static?" warnings.

 * Declared "struct dccpw" static (local to dccp_probe).

 * Disabled dccp_delayed_ack() - not fully removed due to RFC 4340, 11.3
   ("Receivers SHOULD implement delayed acknowledgement timers ...").

 * Used a different local variable name to avoid
   net/dccp/ackvec.c:293:13: warning: symbol 'state' shadows an earlier one
   net/dccp/ackvec.c:238:33: originally declared here

 * Removed unused functions `dccp_ackvector_print' and `dccp_ackvec_print'.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ackvec.c         |   29 ++---------------------------
 net/dccp/ccids/ccid3.c    |    4 ++--
 net/dccp/ccids/lib/tfrc.c |    8 --------
 net/dccp/ccids/lib/tfrc.h |   11 +++++++++--
 net/dccp/output.c         |    2 ++
 net/dccp/probe.c          |    2 +-
 6 files changed, 16 insertions(+), 40 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -159,8 +159,8 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 	} else if (ktime_us_delta(now, hctx->ccid3hctx_t_ld)
 				- (s64)hctx->ccid3hctx_rtt >= 0) {
 
-		hctx->ccid3hctx_x -			max(min(2 * hctx->ccid3hctx_x, min_rate),
+		hctx->ccid3hctx_x = min(2 * hctx->ccid3hctx_x, min_rate);
+		hctx->ccid3hctx_x = max(hctx->ccid3hctx_x,
 			    scaled_div(((__u64)hctx->ccid3hctx_s) << 6,
 				       hctx->ccid3hctx_rtt));
 		hctx->ccid3hctx_t_ld = now;
--- a/net/dccp/probe.c
+++ b/net/dccp/probe.c
@@ -42,7 +42,7 @@ static int bufsize = 64 * 1024;
 
 static const char procname[] = "dccpprobe";
 
-struct {
+static struct {
 	struct kfifo	  *fifo;
 	spinlock_t	  lock;
 	wait_queue_head_t wait;
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
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -508,6 +508,7 @@ void dccp_send_ack(struct sock *sk)
 
 EXPORT_SYMBOL_GPL(dccp_send_ack);
 
+#if 0
 /* FIXME: Is this still necessary (11.3) - currently nowhere used by DCCP. */
 void dccp_send_delayed_ack(struct sock *sk)
 {
@@ -538,6 +539,7 @@ void dccp_send_delayed_ack(struct sock *sk)
 	icsk->icsk_ack.timeout = timeout;
 	sk_reset_timer(sk, &icsk->icsk_delack_timer, timeout);
 }
+#endif
 
 void dccp_send_sync(struct sock *sk, const u64 ackno,
 		    const enum dccp_pkt_type pkt_type)
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -290,12 +290,12 @@ int dccp_ackvec_add(struct dccp_ackvec *av, const struct sock *sk,
 
 		while (1) {
 			const u8 len = dccp_ackvec_len(av, index);
-			const u8 state = dccp_ackvec_state(av, index);
+			const u8 av_state = dccp_ackvec_state(av, index);
 			/*
 			 * valid packets not yet in av_buf have a reserved
 			 * entry, with a len equal to 0.
 			 */
-			if (state = DCCP_ACKVEC_STATE_NOT_RECEIVED &&
+			if (av_state = DCCP_ACKVEC_STATE_NOT_RECEIVED &&
 			    len = 0 && delta = 0) { /* Found our
 							 reserved seat! */
 				dccp_pr_debug("Found %llu reserved seat!\n",
@@ -325,31 +325,6 @@ out_duplicate:
 	return -EILSEQ;
 }
 
-#ifdef CONFIG_IP_DCCP_DEBUG
-void dccp_ackvector_print(const u64 ackno, const unsigned char *vector, int len)
-{
-	dccp_pr_debug_cat("ACK vector len=%d, ackno=%llu |", len,
-			 (unsigned long long)ackno);
-
-	while (len--) {
-		const u8 state = (*vector & DCCP_ACKVEC_STATE_MASK) >> 6;
-		const u8 rl = *vector & DCCP_ACKVEC_LEN_MASK;
-
-		dccp_pr_debug_cat("%d,%d|", state, rl);
-		++vector;
-	}
-
-	dccp_pr_debug_cat("\n");
-}
-
-void dccp_ackvec_print(const struct dccp_ackvec *av)
-{
-	dccp_ackvector_print(av->av_buf_ackno,
-			     av->av_buf + av->av_buf_head,
-			     av->av_vec_len);
-}
-#endif
-
 static void dccp_ackvec_throw_record(struct dccp_ackvec *av,
 				     struct dccp_ackvec_record *avr)
 {
