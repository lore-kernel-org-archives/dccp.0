From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:15:34 +0000
Subject: [PATCH 11/29] Set idle state after nofeedback timer expiry
Message-Id: <20070412211534.GL21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This corrects a mistake with regard to draft rfc3448bis: the `idle' state was
mistakenly entered before the allowed sending rate X was recomputed. With
regard to draft rfc3448bis, section 4.3 / step (4) (implemented by
ccid3_hc_tx_update_x), which caused erroneous calculation.

Fixed by: moving the update to the `idle' state to the end of no_feedback_timer.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index c3711e1..e166f5c 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -233,8 +233,6 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 	ccid3_pr_debug("%s(%p, state=%s) - entry \n", dccp_role(sk), sk,
 		       ccid3_tx_state_name(hctx->ccid3hctx_state));
 
-	hctx->ccid3hctx_idle = 1;
-
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 		/* RFC 3448, 4.4: Halve send rate directly */
@@ -294,6 +292,8 @@ static void ccid3_hc_tx_no_feedback_timer(unsigned long data)
 		goto out;
 	}
 
+	hctx->ccid3hctx_idle = 1;
+
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
 			   jiffies + usecs_to_jiffies(t_nfb));
-- 
1.5.0.6

