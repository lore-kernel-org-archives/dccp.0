From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Nov 2006 21:58:06 +0000
Subject: [PATCH 2/7] [DCCP] ccid3: Set NoFeedback Timeout according to RFC 3448
Message-Id: <20061128215805.GK19882@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This corrects the setting of the nofeedback timer with regard to RFC
3448 - previously it was not set to max(4*R, 2*s/X) as specified. Using
the maximum of 1 second as upper bound (as it was done before) can have
detrimental effects, especially if R is small.

Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccids/ccid3.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index f0ed67c..577fd0e 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -163,7 +163,7 @@ static void ccid3_hc_tx_no_feedback_time
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	unsigned long next_tmout = USEC_PER_SEC / 5;
+	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -191,7 +191,7 @@ static void ccid3_hc_tx_no_feedback_time
 			       hctx->ccid3hctx_x);
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
-		next_tmout = TFRC_INITIAL_TIMEOUT;
+		t_nfb = TFRC_INITIAL_TIMEOUT;
 		ccid3_update_send_time(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
@@ -228,10 +228,9 @@ static void ccid3_hc_tx_no_feedback_time
 		}
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * t_RTO, 2 * s/X)  =  max(4 * t_RTO, 2 * t_ipi)
-		 * XXX This is non-standard, RFC 3448, 4.3 uses 4 * R
+		 * max(4 * R, 2 * s/X)  =  max(4 * R, 2 * t_ipi)
 		 */
-		next_tmout = max(hctx->ccid3hctx_t_rto, 2*hctx->ccid3hctx_t_ipi);
+		t_nfb = max(4 * hctx->ccid3hctx_rtt, 2 * hctx->ccid3hctx_t_ipi);
 		break;
 	case TFRC_SSTATE_NO_SENT:
 		DCCP_BUG("Illegal %s state NO_SENT, sk=%p", dccp_role(sk), sk);
@@ -244,7 +243,7 @@ static void ccid3_hc_tx_no_feedback_time
 
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-		           jiffies + usecs_to_jiffies(next_tmout));
+		           jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -396,7 +395,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	struct ccid3_options_received *opt_recv;
 	struct dccp_tx_hist_entry *packet;
 	struct timeval now;
-	unsigned long next_tmout; 
+	unsigned long t_nfb;
 	u32 t_elapsed;
 	u32 pinv;
 	u32 x_recv;
@@ -498,18 +497,17 @@ static void ccid3_hc_tx_packet_recv(stru
 					      	   USEC_PER_SEC            );
 		/*
 		 * Schedule no feedback timer to expire in
-		 * max(4 * t_RTO, 2 * s/X)  =  max(4 * t_RTO, 2 * t_ipi)
-		 * XXX This is non-standard, RFC 3448, 4.3 uses 4 * R
+		 * max(4 * R, 2 * s/X)  =  max(4 * R, 2 * t_ipi)
 		 */
-		next_tmout = max(hctx->ccid3hctx_t_rto, 2*hctx->ccid3hctx_t_ipi);
+		t_nfb = max(4 * hctx->ccid3hctx_rtt, 2 * hctx->ccid3hctx_t_ipi);
 			
 		ccid3_pr_debug("%s, sk=%p, Scheduled no feedback timer to "
 			       "expire in %lu jiffies (%luus)\n",
 			       dccp_role(sk), sk,
-			       usecs_to_jiffies(next_tmout), next_tmout); 
+			       usecs_to_jiffies(t_nfb), t_nfb);
 
 		sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer, 
-				   jiffies + usecs_to_jiffies(next_tmout));
+				   jiffies + usecs_to_jiffies(t_nfb));
 
 		/* set idle flag */
 		hctx->ccid3hctx_idle = 1;   
-- 
1.4.2.1.g3d5c

