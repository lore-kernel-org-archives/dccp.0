From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 21 Mar 2007 18:44:59 +0000
Subject: [PATCH 11/25]: Set idle state after nofeedback timer expiry
Message-Id: <200703211844.59673@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Set idle state after nofeedback timer expiry

This corrects a mistake with regard to draft rfc3448bis: the `idle' state was
mistakenly entered before the allowed sending rate X was recomputed. With
regard to draft rfc3448bis, section 4.3 / step (4) (implemented by
ccid3_hc_tx_update_x), which caused erroneous calculation.

Fixed by: moving the update to the `idle' state to the end of no_feedback_timer.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -233,8 +233,6 @@ static void ccid3_hc_tx_no_feedback_time
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 
-	hctx->ccid3hctx_idle = 1;
-
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
@@ -294,6 +292,8 @@ static void ccid3_hc_tx_no_feedback_time
 		goto out;
 	}
 
+	hctx->ccid3hctx_idle = 1;
+
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
