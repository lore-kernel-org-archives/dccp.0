From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Feb 2008 14:23:08 +0000
Subject: [PATCH 4/4] [CCID2]: Remove wrappers around sk_{reset,stop}_timer()
Message-Id: <1204122188-9984-5-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the wrappers around the sk timer functions as it makes the code
clearer and not much is gained from using wrappers: the BUG_ON in
start_rto_timer will never trigger since that function was called only when
 * the RTO timer expired (rto_expire, and then timer_pending() is false);
 * in tx_packet_sent only if !timer_pending() (BUG_ON is redundant here);
 * previously in new_ack, after stopping the timer (timer_pending() false).

One further motive behind this patch is to replace the RTO timer with the
icsk retransmission timer, as it is already part of the DCCP socket.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   30 ++++++------------------------
 1 files changed, 6 insertions(+), 24 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -111,8 +111,6 @@ static void ccid2_change_l_ack_ratio(struct sock *sk, u32 val)
 	dp->dccps_l_ack_ratio = val;
 }
 
-static void ccid2_start_rto_timer(struct sock *sk);
-
 static void ccid2_hc_tx_rto_expire(unsigned long data)
 {
 	struct sock *sk = (struct sock *)data;
@@ -152,23 +150,14 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	/* if we were blocked before, we may now send cwnd=1 packet */
 	if (sender_was_blocked)
 		tasklet_schedule(&dccp_sk(sk)->dccps_xmitlet);
-	ccid2_start_rto_timer(sk);
+	/* restart backed-off timer */
+	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
+		       jiffies + hctx->ccid2hctx_rto);
 out:
 	bh_unlock_sock(sk);
 	sock_put(sk);
 }
 
-static void ccid2_start_rto_timer(struct sock *sk)
-{
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-
-	ccid2_pr_debug("setting RTO timeout=%ld\n", hctx->ccid2hctx_rto);
-
-	BUG_ON(timer_pending(&hctx->ccid2hctx_rtotimer));
-	sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
-		       jiffies + hctx->ccid2hctx_rto);
-}
-
 static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -248,7 +237,8 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 
 	/* setup RTO timer */
 	if (!timer_pending(&hctx->ccid2hctx_rtotimer))
-		ccid2_start_rto_timer(sk);
+		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
+			       jiffies + hctx->ccid2hctx_rto);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	do {
@@ -265,14 +255,6 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, unsigned int len)
 #endif
 }
 
-static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
-{
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-
-	sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
-	ccid2_pr_debug("deleted RTO timer\n");
-}
-
 /**
  * ccid2_rtt_estimator - Sample RTT and compute RTO using RFC2988 algorithm
  * This code is almost identical with TCP's tcp_rtt_estimator(), since
@@ -651,7 +633,7 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
 	int i;
 
-	ccid2_hc_tx_kill_rto_timer(sk);
+	sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
 
 	for (i = 0; i < hctx->ccid2hctx_seqbufc; i++)
 		kfree(hctx->ccid2hctx_seqbuf[i]);
