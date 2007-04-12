From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Thu, 12 Apr 2007 21:18:07 +0000
Subject: [PATCH 29/29] History access is redundant when sending feedback
Message-Id: <20070412211807.GD21292@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This is a simplification to reduce the number of history accesses: when
receiving a new packet, the receiver needs to access the RX history twice:

 * first to create / add a new entry
 * then, when sending feedback, the just-created entry must be `found'
   via history lookup.

Meaning that, for the same information, it first needs an exclusive
write-access and then a (shared) read access. Without locking in between
these calls, the history information may have already changed.

This patch bypasses the double lookup by directly using the available data
from skb.  In addition, some more informative debugging information was added.

(NB: using the `packet' entry from rx_packet_recv() is not a good idea, since this
     can interfer with the RX history garbage collection: the entry may be garbage-
     collected at the same instant that send_feedback() tries to use it.)

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   35 ++++++++++++++---------------------
 1 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 26e8870..6e94496 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -745,15 +745,12 @@ static int ccid3_hc_rx_update_p(struct ccid3_hc_rx_sock *hcrx)
 	return (hcrx->ccid3hcrx_pinv < pinv_prev);
 }
 
-static void ccid3_hc_rx_send_feedback(struct sock *sk)
+static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_rx_hist_entry *packet;
-	struct timeval now;
-	suseconds_t delta;
-
-	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
+	struct timeval now, t_recv;
+	suseconds_t delta = 0;
 
 	do_gettimeofday(&now);
 
@@ -773,23 +770,19 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
 		return;
 	}
+	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
+		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
 
-	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), no data packet in history!\n",
-			  dccp_role(sk), sk);
-		return;
-	}
+	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
+	skb_get_timestamp(skb, &t_recv);
+	delta = timeval_delta(&now, &t_recv);
+	DCCP_BUG_ON(delta < 0);
 
+	hcrx->ccid3hcrx_elapsed_time	     = delta / 10;
 	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
+	hcrx->ccid3hcrx_ccval_last_counter   = dccp_hdr(skb)->dccph_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
 
-	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
-	delta = timeval_delta(&now, &packet->dccphrx_tstamp);
-	DCCP_BUG_ON(delta < 0);
-	hcrx->ccid3hcrx_elapsed_time = delta / 10;
-
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
 }
@@ -1084,7 +1077,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		ccid3_pr_debug("%s(%p, state=%s), skb=%p, sending initial "
 			       "feedback\n", dccp_role(sk), sk,
 			       dccp_state_name(sk->sk_state), skb);
-		ccid3_hc_rx_send_feedback(sk);
+		ccid3_hc_rx_send_feedback(sk, skb);
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
 	case TFRC_RSTATE_DATA:
@@ -1096,7 +1089,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
 		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
 			hcrx->ccid3hcrx_tstamp_last_ack = now;
-			ccid3_hc_rx_send_feedback(sk);
+			ccid3_hc_rx_send_feedback(sk, skb);
 		}
 		return;
 	case TFRC_RSTATE_TERM:
@@ -1109,7 +1102,7 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
 
 	if (ccid3_hc_rx_update_p(hcrx))
-		ccid3_hc_rx_send_feedback(sk);
+		ccid3_hc_rx_send_feedback(sk, skb);
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
-- 
1.5.0.6

