From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 24 Nov 2006 16:19:33 +0000
Subject: [PATCH 4/10]: Consolidate timer resets
Message-Id: <200611241619.34008@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Consolidate timer resets

The specification in [RFC 3448, 4.4, step (3)] is impossible to
implement: when no feedback has been received, the value of RTT
is undefined as per [RFC 3448, 4.2]. Hence we can not set the
timeout value to max(4*R, 2*s/X) as step (3) suggests.

The most reasonable solution is to remain at the initial timeout
value of 2 seconds, as per [RFC 3448, 4.2] - until an estimate
for R has been computed.

The patch also consolidates handling timer restart by adding
an appropriate jump label and initialising the timeout value.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   18 +++++++++---------
 net/dccp/ccids/ccid3.h |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -172,16 +172,14 @@ static inline void ccid3_hc_tx_update_s(
 static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
-	unsigned long next_tmout = 0;
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	unsigned long next_tmout = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
 		/* Try again later. */
 		/* XXX: set some sensible MIB */
-		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-			       jiffies + HZ / 5);
-		goto out;
+		goto restart_timer;
 	}
 
 	ccid3_pr_debug("%s, sk=%p, state=%s\n", dccp_role(sk), sk,
@@ -201,9 +199,9 @@ static void ccid3_hc_tx_no_feedback_time
 			       dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
 			       hctx->ccid3hctx_x);
-		next_tmout = max_t(u32, 2 * usecs_div(hctx->ccid3hctx_s,
-						      hctx->ccid3hctx_x),
-					TFRC_INITIAL_TIMEOUT);
+		/* We cannot restart the timer as per [RFC 3448, 4.4] step (3),
+		 * since RTT is still undefined. We keep the previous value.  */
+		next_tmout = TFRC_INITIAL_TIMEOUT;
 		/*
 		 * FIXME - not sure above calculation is correct. See section
 		 * 5 of CCID3 11 should adjust tx_t_ipi and double that to
@@ -257,9 +255,11 @@ static void ccid3_hc_tx_no_feedback_time
 		goto out;
 	}
 
-	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer, 
-		      jiffies + max_t(u32, 1, usecs_to_jiffies(next_tmout)));
 	hctx->ccid3hctx_idle = 1;
+
+restart_timer:
+	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
+		           jiffies + usecs_to_jiffies(next_tmout));
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -42,7 +42,7 @@
 #include <linux/tfrc.h>
 #include "../ccid.h"
 
-/* Two seconds as per CCID3 spec */
+/* Two seconds as per RFC 3448 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
 /* In usecs - half the scheduling granularity as per RFC3448 4.6 */
