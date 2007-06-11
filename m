From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 11 Jun 2007 12:42:08 +0000
Subject: [PATCH 6/6]: Update TX RTT sampling to use ktime_t
Message-Id: <200706111342.08439@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Update TX RTT sampling to use ktime_t

Using the new TX history interface (which looks up send time in ktime_t units), the
CCID3 sender side is now upgraded to use the ktime_t interface for sampling RTT values.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   25 +++++++++----------------
 1 file changed, 9 insertions(+), 16 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -407,8 +407,7 @@ static void ccid3_hc_tx_packet_recv(stru
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
-	struct dccp_tx_hist_entry *packet;
-	struct timeval now;
+	ktime_t t_send, now;
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
 
@@ -424,14 +423,12 @@ static void ccid3_hc_tx_packet_recv(stru
 	switch (hctx->ccid3hctx_state) {
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
-		/* get packet from history to look up t_recvdata */
-		packet = dccp_tx_hist_find_entry(&hctx->ccid3hctx_hist,
-					      DCCP_SKB_CB(skb)->dccpd_ack_seq);
-		if (unlikely(packet = NULL)) {
-			DCCP_WARN("%s(%p), seqno %llu(%s) doesn't exist "
-				  "in history!\n",  dccp_role(sk), sk,
-			    (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq,
-				dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type));
+		/* estimate RTT from history if ACK number is valid */
+		if (! tfrc_tx_hist_when(&t_send, &hctx->ccid3hctx_hist,
+				        DCCP_SKB_CB(skb)->dccpd_ack_seq)) {
+			DCCP_WARN("%s(%p): %s with bogus ACK-%llu\n", dccp_role(sk), sk,
+				  dccp_packet_name(DCCP_SKB_CB(skb)->dccpd_type),
+				  (unsigned long long)DCCP_SKB_CB(skb)->dccpd_ack_seq);
 			return;
 		}
 
@@ -446,12 +443,11 @@ static void ccid3_hc_tx_packet_recv(stru
 		else				       /* can not exceed 100% */
 			hctx->ccid3hctx_p = 1000000 / pinv;
 
-		dccp_timestamp(sk, &now);
-
 		/*
 		 * Calculate new RTT sample and update moving average
 		 */
-		r_sample = dccp_sample_rtt(sk, &now, &packet->dccphtx_tstamp);
+		now = ktime_get_real();
+		r_sample = dccp_sample_rtt(sk, ktime_delta(now, t_send));
 		hctx->ccid3hctx_rtt = tfrc_ewma(hctx->ccid3hctx_rtt, r_sample, 9);
 
 		if (hctx->ccid3hctx_state = TFRC_SSTATE_NO_FBACK) {
@@ -493,9 +489,6 @@ static void ccid3_hc_tx_packet_recv(stru
 		/* unschedule no feedback timer */
 		sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
-		/* remove all packets older than the one acked from history */
-		dccp_tx_hist_purge_older(ccid3_tx_hist,
-					 &hctx->ccid3hctx_hist, packet);
 		/*
 		 * As we have calculated new ipi, delta, t_nom it is possible
 		 * that we now can send a packet, so wake up dccp_wait_for_ccid
