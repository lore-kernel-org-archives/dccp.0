From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Mon, 27 Nov 2006 22:35:50 +0000
Subject: [PATCH 1/3] [DCCP] ccid3: Consolidate timer resets
Message-Id: <20061127223549.GB11605@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch concerns updating the value of the nofeedback timer when no feedback
has been received so far.

Since in this case the value of R is still undefined according to [RFC 3448,
4.2], we can not perform step (3) of [RFC 3448, 4.3].  A clarification is
provided in [RFC 4342, sec. 5], which states that in these cases the nofeedback
timer (still) expires "after two seconds".

Many thanks to Ian McDonald for pointing this out and providing the
clarification.

The patch
  * implements [RFC 4342, sec. 5] with regard to the above case
  * consolidates handling timer restart by
	- adding an appropriate jump label and
	- initialising the timeout value

Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   18 +++++++++---------
 net/dccp/ccids/ccid3.h |    2 +-
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 6777a7f..9297fca 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -154,16 +154,14 @@ static void ccid3_hc_tx_update_x(struct 
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
@@ -183,9 +181,9 @@ static void ccid3_hc_tx_no_feedback_time
 			       dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
 			       hctx->ccid3hctx_x);
-		next_tmout = max_t(u32, 2 * usecs_div(hctx->ccid3hctx_s,
-						      hctx->ccid3hctx_x),
-					TFRC_INITIAL_TIMEOUT);
+		/* The value of R is still undefined and so we can not recompute
+		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
+		next_tmout = TFRC_INITIAL_TIMEOUT;
 		/*
 		 * FIXME - not sure above calculation is correct. See section
 		 * 5 of CCID3 11 should adjust tx_t_ipi and double that to
@@ -239,9 +237,11 @@ static void ccid3_hc_tx_no_feedback_time
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
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 4621652..9709217 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -46,7 +46,7 @@ #define TFRC_MIN_PACKET_SIZE	   16
 #define TFRC_STD_PACKET_SIZE	  256
 #define TFRC_MAX_PACKET_SIZE	65535
 
-/* Two seconds as per CCID3 spec */
+/* Two seconds as per RFC 3448 4.2 */
 #define TFRC_INITIAL_TIMEOUT	   (2 * USEC_PER_SEC)
 
 /* In usecs - half the scheduling granularity as per RFC3448 4.6 */
-- 
1.4.2.1.g3d5c

