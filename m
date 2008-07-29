From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 29 Jul 2008 14:06:11 +0000
Subject: [PATCH 4/6] dccp ccid-3: Simplify computing and range-checking of t_ipi
Message-Id: <1217340373-12620-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch simplifies the computation of t_ipi, avoiding expensive computations
to enforce the minimum sending rate.

Both RFC 3448 and rfc3448bis (revision #06), as well as RFC 4342 sec 5., require
at various stages that at least one packet must be sent per t_mbi = 64 seconds.
This requires frequent divisions of the type X_min = s/t_mbi, which are later
converted back into an inter-packet-interval t_ipi_max = s/X_min = t_mbi.

The patch removes the expensive indirection; in the unlikely case of having
a sending rate less than one packet per 64 seconds, it also re-adjusts X.

The following cases document conformance with RFC 3448 / rfc3448bis-06:
 1) Time until receiving the first feedback packet:
   * if the sender has no initial RTT sample then X = s/1 Bps > s/t_mbi;
   * if the sender has an initial RTT sample or when the first feedback
     packet is received, X = W_init/R > s/t_mbi.

 2) Slow-start (p = 0 and feedback packets come in):
   * RFC 3448  (current code) enforces a minimum of s/R > s/t_mbi;
   * rfc3448bis (future code) enforces an even higher minimum of W_init/R.

 3) Congestion avoidance with no absence of feedback (p > 0):
   * when X_calc or X_recv/2 are too low, the minimum of X_min = s/t_mbi
     is enforced in update_x() when calling update_send_interval();
   * update_send_interval() is, as before, only called when X changes
     (i.e. either when increasing or decreasing, not when in equilibrium).

 4) Reduction of X without prior feedback or during slow-start (p = 0):
   * both RFC 3448 and rfc3448bis here halve X directly;
   * the associated constraint X >= s/t_mbi is nforced here by send_interval().

 5) Reduction of X when p > 0:
   * X is modified indirectly via X_recv (RFC 3448) or X_recv_set (rfc3448bis);
   * in both cases, control goes back to section 4.3 (in either document);
   * since p > 0, both documents use X = max(min(...), s/t_mbi), which is
     enforced in this patch by calling send_interval() from update_x().

I think that this analysis is exhaustive. Should I have forgotten a case,
the worst-case consideration arises when X sinks below s/t_mbi, and is then
increased back up to this minimum value. Even under this assumption, the
behaviour is correct, since all lower limits of X in RFC 3448 / rfc3448bis
are either equal to or greater than s/t_mbi.

Note on the condition X >= s/t_mbi  <=> t_ipi = s/X <= t_mbi: since X is
scaled by 64, and all time units are in microseconds, the coded condition is:

    t_ipi = s * 64 * 10^6 usec / X <= 64 * 10^6 usec

This simplifies to s / X <= 1 second <=> X * 1 second >= s > 0.
(An `s' of zero is not allowed by the CCID-3 sender code).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   18 ++++++++----------
 1 files changed, 8 insertions(+), 10 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -66,15 +66,15 @@ static inline u64 rfc3390_initial_rate(struct sock *sk)
 }
 
 /**
- * ccid3_update_send_interval  -  Calculate new t_ipi = s / X_inst
- * This respects the granularity of X_inst (64 * bytes/second).
+ * ccid3_update_send_interval  -  Calculate new t_ipi = s / X
+ * This respects the granularity of X (64 * bytes/second) and enforces the
+ * scaled minimum of s * 64 / t_mbi = `s' bytes/second as per RFC 3448/4342.
  */
 static void ccid3_update_send_interval(struct ccid3_hc_tx_sock *hctx)
 {
+	if (unlikely(hctx->x <= hctx->s))
+		hctx->x	= hctx->s;
 	hctx->t_ipi = scaled_div32(((u64)hctx->s) << 6, hctx->x);
-
-	ccid3_pr_debug("t_ipi=%u, s=%u, X=%u\n", hctx->t_ipi,
-		       hctx->s, (unsigned)(hctx->x >> 6));
 }
 
 static u32 ccid3_hc_tx_idle_rtt(struct ccid3_hc_tx_sock *hctx, ktime_t now)
@@ -115,7 +115,6 @@ static void ccid3_hc_tx_update_x(struct sock *sk, ktime_t *stamp)
 	if (hctx->p > 0) {
 
 		hctx->x = min(((u64)hctx->x_calc) << 6, min_rate);
-		hctx->x = max(hctx->x, (((u64)hctx->s) << 6) / TFRC_T_MBI);
 
 	} else if (ktime_us_delta(now, hctx->t_ld) - (s64)hctx->rtt >= 0) {
 
@@ -197,8 +196,9 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	if (hctx->t_rto = 0 || hctx->p = 0) {
 
 		/* halve send rate directly */
-		hctx->x = max(hctx->x / 2, (((u64)hctx->s) << 6) / TFRC_T_MBI);
+		hctx->x /= 2;
 		ccid3_update_send_interval(hctx);
+
 	} else {
 		/*
 		 *  Modify the cached value of X_recv
@@ -213,9 +213,7 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		BUG_ON(hctx->p && !hctx->x_calc);
 
 		if (hctx->x_calc > (hctx->x_recv >> 5))
-			hctx->x_recv -				max(hctx->x_recv / 2,
-				    (((__u64)hctx->s) << 6) / (2 * TFRC_T_MBI));
+			hctx->x_recv /= 2;
 		else {
 			hctx->x_recv = hctx->x_calc;
 			hctx->x_recv <<= 4;
