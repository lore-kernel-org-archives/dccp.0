From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Nov 2006 15:45:33 +0000
Subject: [PATCH 4/6]: Simplify control flow of ccid3_hc_tx_send_packet
Message-Id: <200611211545.33274@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Simplify control flow of ccid3_hc_tx_send_packet

This makes some logically equivalent simplifications, by replacing
rc - values plus goto's with direct return statements.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   40 ++++++++++++++++++----------------------
 1 file changed, 18 insertions(+), 22 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -247,6 +247,12 @@ out:
 	sock_put(sk);
 }
 
+/*
+ * returns
+ *   > 0: delay (in msecs) that should pass before actually sending
+ *   = 0: can send immediately
+ *   < 0: error condition; do not send packet
+ */
 static int ccid3_hc_tx_send_packet(struct sock *sk,
 				   struct sk_buff *skb, int len)
 {
@@ -255,7 +261,6 @@ static int ccid3_hc_tx_send_packet(struc
 	struct dccp_tx_hist_entry *new_packet;
 	struct timeval now;
 	long delay;
-	int rc = -ENOTCONN;
 
 	BUG_ON(hctx = NULL);
 
@@ -265,7 +270,7 @@ static int ccid3_hc_tx_send_packet(struc
 	 * packets can have zero length, but why the comment about "pure ACK"?
 	 */
 	if (unlikely(len = 0))
-		goto out;
+		return -ENOTCONN;
 
 	/* See if last packet allocated was not sent */
 	new_packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
@@ -273,11 +278,10 @@ static int ccid3_hc_tx_send_packet(struc
 		new_packet = dccp_tx_hist_entry_new(ccid3_tx_hist,
 						    SLAB_ATOMIC);
 
-		rc = -ENOBUFS;
 		if (unlikely(new_packet = NULL)) {
 			DCCP_WARN("%s, sk=%p, not enough mem to add to history,"
 				  "send refused\n", dccp_role(sk), sk);
-			goto out;
+			return -ENOBUFS;
 		}
 
 		dccp_tx_hist_add_entry(&hctx->ccid3hctx_hist, new_packet);
@@ -299,7 +303,6 @@ static int ccid3_hc_tx_send_packet(struc
 
 		/* Set t_0 for initial packet */
 		hctx->ccid3hctx_t_nom = now;
-		rc = 0;
 		break;
 	case TFRC_SSTATE_NO_FBACK:
 	case TFRC_SSTATE_FBACK:
@@ -312,28 +315,21 @@ static int ccid3_hc_tx_send_packet(struc
 		 * else
 		 *       // send the packet in (t_nom - t_now) milliseconds.
 		 */
-		if (delay < hctx->ccid3hctx_delta)
-			rc = 0;
-		else
-			rc = delay/1000L;
+		if (delay >= hctx->ccid3hctx_delta)
+			return delay/1000L;
 		break;
 	case TFRC_SSTATE_TERM:
 		DCCP_BUG("Illegal %s state TERM, sk=%p", dccp_role(sk), sk);
-		rc = -EINVAL;
-		break;
+		return -EINVAL;
 	}
 
-	/* Can we send? if so add options and add to packet history */
-	if (rc = 0) {
-		dp->dccps_hc_tx_insert_options = 1;
-		new_packet->dccphtx_ccval -			DCCP_SKB_CB(skb)->dccpd_ccval -				hctx->ccid3hctx_last_win_count;
-		timeval_add_usecs(&hctx->ccid3hctx_t_nom,
-				  hctx->ccid3hctx_t_ipi);
-	}
-out:
-	return rc;
+	/* prepare to send now (add options etc.) */
+	dp->dccps_hc_tx_insert_options = 1;
+	new_packet->dccphtx_ccval = DCCP_SKB_CB(skb)->dccpd_ccval
+				  = hctx->ccid3hctx_last_win_count;
+	timeval_add_usecs(&hctx->ccid3hctx_t_nom, hctx->ccid3hctx_t_ipi);
+
+	return 0;
 }
 
 static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, int len)
