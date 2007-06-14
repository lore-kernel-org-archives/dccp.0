From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 14 Jun 2007 09:05:07 +0000
Subject: [PATCH 2/5]: History access is redundant when sending feedback
Message-Id: <200706141005.07993@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: History access is redundant when sending feedback

When receiving a new packet, the receiver needs to access the RX history twice:

   * first to create / add a new entry 
   * to send feedback, that selfsame entry must then be `found' via history lookup.

Meaning that, for the same information, it first needs an exclusive write-access
and then a (shared) read access. Without locking in between these calls, the history
information may have already changed.

This patch
  1. removes redundant use of packet history for sending feedback
     (data packet is no longer `found', just referenced);
  2. which obsoletes function dccp_rx_hist_find_data_packet - removed;
  3. removes an irrelevant state `TERM' (feedback is then not sent);
  4. removes redundant variable `last_ack' (duplicates `last_feedback');
  5. converts rx_send_feedback() to use the newer timeofday interface;
  6. simplify the computation of p/p_inv (see note below). 

Note regarding (3): The use of the feedback variable becomes clear later
     regarding (6): p will be updated by a separate function later in this changeset

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c              |   67 ++++++++++++++++--------------------
 net/dccp/ccids/ccid3.h              |    6 +--
 net/dccp/ccids/lib/packet_history.c |   16 --------
 net/dccp/ccids/lib/packet_history.h |    2 -
 4 files changed, 32 insertions(+), 59 deletions(-)

--- a/net/dccp/ccids/lib/packet_history.h
+++ b/net/dccp/ccids/lib/packet_history.h
@@ -145,8 +145,6 @@ static inline struct dccp_rx_hist_entry 
 
 extern int dccp_rx_hist_find_entry(const struct list_head *list, const u64 seq,
 				   u8 *ccval);
-extern struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list);
 
 extern void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 				    struct list_head *rx_list,
--- a/net/dccp/ccids/lib/packet_history.c
+++ b/net/dccp/ccids/lib/packet_history.c
@@ -212,22 +212,6 @@ int dccp_rx_hist_find_entry(const struct
 }
 
 EXPORT_SYMBOL_GPL(dccp_rx_hist_find_entry);
-struct dccp_rx_hist_entry *
-		dccp_rx_hist_find_data_packet(const struct list_head *list)
-{
-	struct dccp_rx_hist_entry *entry, *packet = NULL;
-
-	list_for_each_entry(entry, list, dccphrx_node)
-		if (entry->dccphrx_type = DCCP_PKT_DATA ||
-		    entry->dccphrx_type = DCCP_PKT_DATAACK) {
-			packet = entry;
-			break;
-		}
-
-	return packet;
-}
-
-EXPORT_SYMBOL_GPL(dccp_rx_hist_find_data_packet);
 
 void dccp_rx_hist_add_packet(struct dccp_rx_hist *hist,
 			    struct list_head *rx_list,
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -684,52 +684,38 @@ static inline void ccid3_hc_rx_update_s(
 		hcrx->ccid3hcrx_s = tfrc_ewma(hcrx->ccid3hcrx_s, len, 9);
 }
 
-static void ccid3_hc_rx_send_feedback(struct sock *sk)
+static void ccid3_hc_rx_send_feedback(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct dccp_rx_hist_entry *packet;
-	struct timeval now;
-	suseconds_t delta;
+	ktime_t now = ktime_get_real();
+	s64 delta = 0;
 
-	ccid3_pr_debug("%s(%p) - entry \n", dccp_role(sk), sk);
-
-	dccp_timestamp(sk, &now);
+	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_TERM))
+		return;
 
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
 		hcrx->ccid3hcrx_x_recv = 0;
+		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
 	case TFRC_RSTATE_DATA:
-		delta = timeval_delta(&now,
-				      &hcrx->ccid3hcrx_tstamp_last_feedback);
-		DCCP_BUG_ON(delta < 0);
-		hcrx->ccid3hcrx_x_recv -			scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
+		delta = ktime_delta(now, hcrx->ccid3hcrx_last_feedback);
+		if (delta <= 0)
+			DCCP_BUG("delta (%ld) <= 0", (long)delta);
+		else
+			hcrx->ccid3hcrx_x_recv +				scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 		break;
-	case TFRC_RSTATE_TERM:
-		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
-		return;
-	}
-
-	packet = dccp_rx_hist_find_data_packet(&hcrx->ccid3hcrx_hist);
-	if (unlikely(packet = NULL)) {
-		DCCP_WARN("%s(%p), no data packet in history!\n",
-			  dccp_role(sk), sk);
+	default:
 		return;
 	}
+	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
+		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
 
-	hcrx->ccid3hcrx_tstamp_last_feedback = now;
-	hcrx->ccid3hcrx_ccval_last_counter   = packet->dccphrx_ccval;
-	hcrx->ccid3hcrx_bytes_recv	     = 0;
-
-	if (hcrx->ccid3hcrx_p = 0)
-		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
-	else if (hcrx->ccid3hcrx_p > 1000000) {
-		DCCP_WARN("p (%u) > 100%%\n", hcrx->ccid3hcrx_p);
-		hcrx->ccid3hcrx_pinv = 1;	/* use 100% in this case */
-	} else
-		hcrx->ccid3hcrx_pinv = 1000000 / hcrx->ccid3hcrx_p;
+	hcrx->ccid3hcrx_last_feedback	   = now;
+	hcrx->ccid3hcrx_ccval_last_counter = dccp_hdr(skb)->dccph_ccval;
+	hcrx->ccid3hcrx_bytes_recv	   = 0;
 
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
@@ -835,10 +821,14 @@ found:
 		DCCP_WARN("RTT=0\n");
 		return ~0;
 	}
-
+/* XXX this also has a forward dependency, which is resolved in the patch
+ *     that does receiver RTT sampling. The problem with the code below is
+ *     that it still used the old, struct timeval based, interface, and that
+ *     the name of the variable `_last_feedback' is not yet adjusted.
 	dccp_timestamp(sk, &tstamp);
 	delta = timeval_delta(&tstamp, &hcrx->ccid3hcrx_tstamp_last_feedback);
 	DCCP_BUG_ON(delta <= 0);
+*/
 
 	x_recv = scaled_div32(hcrx->ccid3hcrx_bytes_recv, delta);
 	if (x_recv = 0) {		/* would also trigger divide-by-zero */
@@ -1024,7 +1014,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		ccid3_pr_debug("%s(%p, state=%s), skb=%p, sending initial "
 			       "feedback\n", dccp_role(sk), sk,
 			       dccp_state_name(sk->sk_state), skb);
-		ccid3_hc_rx_send_feedback(sk);
+		ccid3_hc_rx_send_feedback(sk, skb);
 		ccid3_hc_rx_set_state(sk, TFRC_RSTATE_DATA);
 		return;
 	case TFRC_RSTATE_DATA:
@@ -1032,12 +1022,17 @@ static void ccid3_hc_rx_packet_recv(stru
 		if (loss)
 			break;
 
+/* XXX periodic feedback is resolved later on, the problem with the following
+ *     code is that it introduces a second variable `_tstamp_last_ack'. A
+ *     solution is presented later on in the patch set, for the moment, we
+ *     comment this out.
 		dccp_timestamp(sk, &now);
 		if ((timeval_delta(&now, &hcrx->ccid3hcrx_tstamp_last_ack) -
 		     (suseconds_t)hcrx->ccid3hcrx_rtt) >= 0) {
 			hcrx->ccid3hcrx_tstamp_last_ack = now;
 			ccid3_hc_rx_send_feedback(sk);
 		}
+*/
 		return;
 	case TFRC_RSTATE_TERM:
 		DCCP_BUG("%s(%p) - Illegal state TERM", dccp_role(sk), sk);
@@ -1061,7 +1056,7 @@ static void ccid3_hc_rx_packet_recv(stru
 		DCCP_BUG("empty loss history");
 
 	if (hcrx->ccid3hcrx_p > p_prev) {
-		ccid3_hc_rx_send_feedback(sk);
+		ccid3_hc_rx_send_feedback(sk, skb);
 		return;
 	}
 }
@@ -1075,8 +1070,6 @@ static int ccid3_hc_rx_init(struct ccid 
 	hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA;
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_hist);
 	INIT_LIST_HEAD(&hcrx->ccid3hcrx_li_hist);
-	dccp_timestamp(sk, &hcrx->ccid3hcrx_tstamp_last_ack);
-	hcrx->ccid3hcrx_tstamp_last_feedback = hcrx->ccid3hcrx_tstamp_last_ack;
 	hcrx->ccid3hcrx_s   = 0;
 	hcrx->ccid3hcrx_rtt = 0;
 	return 0;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -133,8 +133,7 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
- *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
- *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
+ *  @ccid3hcrx_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history
  *  @ccid3hcrx_li_hist  -  Loss Interval History
  *  @ccid3hcrx_s  -  Received packet size in bytes
@@ -150,8 +149,7 @@ struct ccid3_hc_rx_sock {
 					ccid3hcrx_ccval_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
 	u32				ccid3hcrx_bytes_recv;
-	struct timeval			ccid3hcrx_tstamp_last_feedback;
-	struct timeval			ccid3hcrx_tstamp_last_ack;
+	ktime_t				ccid3hcrx_last_feedback;
 	struct list_head		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
 	u16				ccid3hcrx_s;
