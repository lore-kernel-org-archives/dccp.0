From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 20:25:00 +0000
Subject: Re: [RFC] [PATCH 1/2]: Remove small typo
Message-Id: <200611282025.00852@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <200611281434.31175@strip-the-willow>
In-Reply-To: <200611281434.31175@strip-the-willow>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a Re-sent after discusssion with Ian. I have renamed
the variable also, as the term got too long for the 80 columns fixed
linelength - hope `t_nfb' is ok as mnemonic for the nofeedback timeout.

-----------------------> Commit Message <----------------------------
[CCID 3]: Set NoFeedback Timeout according to RFC 3448

This corrects the setting of the nofeedback timer with 
regard to RFC 3448 - previously it was not set to 
max(4*R, 2*s/X) as specified. Using the maximum of 1 second 
as upper bound (as it was done before) can have detrimental
effects, especially if R is small.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -183,7 +183,7 @@ static void ccid3_hc_tx_no_feedback_time
 {
 	struct sock *sk = (struct sock *)data;
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
-	unsigned long next_tmout = USEC_PER_SEC / 5;
+	unsigned long t_nfb = USEC_PER_SEC / 5;
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
@@ -208,7 +208,7 @@ static void ccid3_hc_tx_no_feedback_time
 			       hctx->ccid3hctx_x);
 		/* The value of R is still undefined and so we can not recompute
 		 * the timout value. Keep initial value as per [RFC 4342, 5]. */
-		next_tmout = TFRC_INITIAL_TIMEOUT;
+		t_nfb = TFRC_INITIAL_TIMEOUT;
 		ccid3_update_send_time(hctx);
 		break;
 	case TFRC_SSTATE_FBACK:
@@ -246,10 +246,9 @@ static void ccid3_hc_tx_no_feedback_time
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
@@ -262,7 +261,7 @@ static void ccid3_hc_tx_no_feedback_time
 
 restart_timer:
 	sk_reset_timer(sk, &hctx->ccid3hctx_no_feedback_timer,
-		           jiffies + usecs_to_jiffies(next_tmout));
+		           jiffies + usecs_to_jiffies(t_nfb));
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
@@ -420,7 +419,7 @@ static void ccid3_hc_tx_packet_recv(stru
 	struct ccid3_options_received *opt_recv;
 	struct dccp_tx_hist_entry *packet;
 	struct timeval now;
-	unsigned long next_tmout; 
+	unsigned long t_nfb;
 	u32 t_elapsed;
 	u32 pinv;
 	u32 r_sample;
@@ -523,18 +522,17 @@ static void ccid3_hc_tx_packet_recv(stru
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
