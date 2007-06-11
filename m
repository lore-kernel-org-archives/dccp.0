From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 14:39:35 +0000
Subject: [PATCH 3/5]: Use t_RTO as indicator for feedback reception
Message-Id: <200706111539.35440@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Use t_RTO as indicator for feedback reception

This patch uses t_RTO instead of ccid3hctx_state to check whether upon
expiry of the nofeedback timer feedback has been received yet.

Functionally, there is no change, but it facilitates an elegant testing of
state changes (used later in this patch set). This then makes it possible
to support nofeedback handling as per rfc3448bis (subsequent patch).

The main advantage is that ccid3hctx_state is now used to toggle between
the reception of feedback and no feedback as in "the nofeedback timer has 
expired". This is more efficient, since the state "packet sent but no initial
feedback" happens only _once_ during the lifetime of a connection, whereas the
other state change (feedback <-> nofeedback timer expires) happens frequently.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   19 ++++++++++---------
 1 file changed, 10 insertions(+), 9 deletions(-)
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -244,9 +244,6 @@ static void ccid3_hc_tx_no_feedback_time
 			       "bytes/s\n", dccp_role(sk), sk,
 			       ccid3_tx_state_name(hctx->ccid3hctx_state),
 			       (unsigned)(hctx->ccid3hctx_x >> 6));
-		/* The value of R is still undefined and so we can not recompute
-		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
-		t_nfb = TFRC_INITIAL_TIMEOUT;
 		ccid3_update_send_interval(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
@@ -278,12 +275,6 @@ static void ccid3_hc_tx_no_feedback_time
 		}
 		/* Now recalculate X [RFC 3448, 4.3, step (4)] */
 		ccid3_hc_tx_update_x(sk, &now);
-		/*
-		 * Schedule no feedback timer to expire in
-		 * max(t_RTO, 2 * s/X)  =  max(t_RTO, 2 * t_ipi)
-		 * See comments in packet_recv() regarding the value of t_RTO.
-		 */
-		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		DCCP_BUG("%s(%p) - Illegal state NO_SENT", dccp_role(sk), sk);
@@ -292,6 +283,15 @@ static void ccid3_hc_tx_no_feedback_time
 		goto out;
 	}
 
+	/*
+	 * Set new timeout for the nofeedback timer.
+	 * See comments in packet_recv() regarding the value of t_RTO.
+	 */
+	if (unlikely(hctx->ccid3hctx_t_rto = 0))	/* no feedback yet */
+		t_nfb = TFRC_INITIAL_TIMEOUT;
+	else
+		t_nfb = max(hctx->ccid3hctx_t_rto, 2 * hctx->ccid3hctx_t_ipi);
+
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
@@ -587,6 +587,7 @@ static int ccid3_hc_tx_init(struct ccid 
 
 	hctx->ccid3hctx_s     = 0;
 	hctx->ccid3hctx_rtt   = 0;
+	hctx->ccid3hctx_t_rto = 0;
 	hctx->ccid3hctx_state = TFRC_SSTATE_NO_SENT;
 	tfrc_tx_hist_init(&hctx->ccid3hctx_hist, ccid3_tx_hist);
 
