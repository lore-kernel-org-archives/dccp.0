From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 30 Aug 2010 05:23:11 +0000
Subject: [PATCH 2/5] dccp ccid-2: Remove wrappers around sk_{reset,stop}_timer()
Message-Id: <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the wrappers around the sk timer functions, since not much is
gained from using them: the BUG_ON in start_rto_timer will never trigger
since that function is called only if:

 * the RTO timer expires (rto_expire, and then timer_pending() is false);
 * in tx_packet_sent only if !timer_pending() (BUG_ON is redundant here);
 * previously in new_ack, after stopping the timer (timer_pending() false).

Removing the wrappers also clears the way for eventually replacing the
RTO timer with the icsk-retransmission-timer, as it is already part of the
DCCP socket.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   28 +++-------------------------
 1 files changed, 3 insertions(+), 25 deletions(-)

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
@@ -131,7 +129,7 @@ static void ccid2_hc_tx_rto_expire(unsigned long data)
 	if (hc->tx_rto > DCCP_RTO_MAX)
 		hc->tx_rto = DCCP_RTO_MAX;
 
-	ccid2_start_rto_timer(sk);
+	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
 
 	/* adjust pipe, cwnd etc */
 	hc->tx_ssthresh = hc->tx_cwnd / 2;
@@ -153,16 +151,6 @@ out:
 	sock_put(sk);
 }
 
-static void ccid2_start_rto_timer(struct sock *sk)
-{
-	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
-
-	ccid2_pr_debug("setting RTO timeout=%u\n", hc->tx_rto);
-
-	BUG_ON(timer_pending(&hc->tx_rtotimer));
-	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
-}
-
 static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
@@ -239,9 +227,7 @@ static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 	}
 #endif
 
-	/* setup RTO timer */
-	if (!timer_pending(&hc->tx_rtotimer))
-		ccid2_start_rto_timer(sk);
+	sk_reset_timer(sk, &hc->tx_rtotimer, jiffies + hc->tx_rto);
 
 #ifdef CONFIG_IP_DCCP_CCID2_DEBUG
 	do {
@@ -320,14 +306,6 @@ out_invalid_option:
 	return -1;
 }
 
-static void ccid2_hc_tx_kill_rto_timer(struct sock *sk)
-{
-	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
-
-	sk_stop_timer(sk, &hc->tx_rtotimer);
-	ccid2_pr_debug("deleted RTO timer\n");
-}
-
 /**
  * ccid2_rtt_estimator - Sample RTT and compute RTO using RFC2988 algorithm
  * This code is almost identical with TCP's tcp_rtt_estimator(), since
@@ -692,7 +670,7 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 	struct ccid2_hc_tx_sock *hc = ccid2_hc_tx_sk(sk);
 	int i;
 
-	ccid2_hc_tx_kill_rto_timer(sk);
+	sk_stop_timer(sk, &hc->tx_rtotimer);
 
 	for (i = 0; i < hc->tx_seqbufc; i++)
 		kfree(hc->tx_seqbuf[i]);
