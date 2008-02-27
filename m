From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 27 Feb 2008 14:23:06 +0000
Subject: [PATCH 2/4] [CCID2]: Simplify dec_pipe and rearming of RTO timer
Message-Id: <1204122188-9984-3-git-send-email-gerrit@erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This removes the dec_pipe function and improves the way the RTO timer is rearmed
when a new acknowledgment comes in.

Details and justification for removal:
--------------------------------------
 1) The BUG_ON in dec_pipe is never triggered: pipe is only decremented for TX
    history entries between tail and head, for which it had previously been
    incremented in tx_packet_sent; and it is not decremented twice for the same
    entry, since it is
    - either decremented when a corresponding Ack Vector cell in state 0 or 1
      was received (and then ccid2s_acked=1),
    - or it is decremented when ccid2s_acked=0, as part of the loss detection
      in tx_packet_recv (and hence it can not have been decremented earlier).

 2) Restarting the RTO timer happens for every single entry in each Ack Vector
    parsed by tx_packet_recv (according to RFC 4340, 11.4 this can happen up to
    16192 times per Ack Vector).

 3) The RTO timer should not be restarted when all outstanding data has been
    acknowledged. This is currently done similar to (2), in dec_pipe, when
    pipe has reached 0.

The patch onsolidates the code which rearms the RTO timer, combining the
segments from new_ack and dec_pipe. As a result, the code becomes clearer
(compare with tcp_rearm_rto()).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid2.c |   27 ++++++++-------------------
 1 files changed, 8 insertions(+), 19 deletions(-)

--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -356,23 +356,6 @@ static inline void ccid2_new_ack(struct sock *sk,
 			       hctx->ccid2hctx_srtt, hctx->ccid2hctx_rttvar,
 			       hctx->ccid2hctx_rto, HZ, r);
 	}
-
-	/* we got a new ack, so re-start RTO timer */
-	ccid2_hc_tx_kill_rto_timer(sk);
-	ccid2_start_rto_timer(sk);
-}
-
-static void ccid2_hc_tx_dec_pipe(struct sock *sk)
-{
-	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
-
-	if (hctx->ccid2hctx_pipe = 0)
-		DCCP_BUG("pipe = 0");
-	else
-		hctx->ccid2hctx_pipe--;
-
-	if (hctx->ccid2hctx_pipe = 0)
-		ccid2_hc_tx_kill_rto_timer(sk);
 }
 
 static void ccid2_congestion_event(struct sock *sk, struct ccid2_seq *seqp)
@@ -522,7 +505,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 					seqp->ccid2s_acked = 1;
 					ccid2_pr_debug("Got ack for %llu\n",
 						       (unsigned long long)seqp->ccid2s_seq);
-					ccid2_hc_tx_dec_pipe(sk);
+					hctx->ccid2hctx_pipe--;
 				}
 				if (seqp = hctx->ccid2hctx_seqt) {
 					done = 1;
@@ -578,7 +561,7 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 				 * one ack vector.
 				 */
 				ccid2_congestion_event(sk, seqp);
-				ccid2_hc_tx_dec_pipe(sk);
+				hctx->ccid2hctx_pipe--;
 			}
 			if (seqp = hctx->ccid2hctx_seqt)
 				break;
@@ -596,6 +579,12 @@ static void ccid2_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		hctx->ccid2hctx_seqt = hctx->ccid2hctx_seqt->ccid2s_next;
 	}
 
+	/* restart RTO timer if not all outstanding data has been acked */
+	if (hctx->ccid2hctx_pipe = 0)
+		sk_stop_timer(sk, &hctx->ccid2hctx_rtotimer);
+	else
+		sk_reset_timer(sk, &hctx->ccid2hctx_rtotimer,
+			       jiffies + hctx->ccid2hctx_rto);
 done:
 	/* check if incoming Acks allow pending packets to be sent */
 	if (sender_was_blocked && !ccid2_cwnd_network_limited(hctx))
