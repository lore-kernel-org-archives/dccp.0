From: Arnaldo Carvalho de Melo <acme@mandriva.com>
Date: Tue, 28 Nov 2006 21:59:21 +0000
Subject: [PATCH 7/7] [DCCP]: Use `unsigned' for packet lengths
Message-Id: <20061128215921.GP19882@mandriva.com>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This patch implements a suggestion by Ian McDonald and

 1) Avoids tests against negative packet lengths by using unsigned int
    for packet payload lengths in the CCID send_packet()/packet_sent() routines

 2) As a consequence, it removes an now unnecessary test with regard to `len > 0'
    in ccid3_hc_tx_packet_sent: that condition is always true, since
      * negative packet lengths are avoided
      * ccid3_hc_tx_send_packet flags an error whenever the payload length is 0.
        As a consequence, ccid3_hc_tx_packet_sent is never called as all errors
        returned by ccid_hc_tx_send_packet are caught in dccp_write_xmit

 3) Removes the third argument of ccid_hc_tx_send_packet (the `len' parameter),
    since it is currently always set to skb->len. The code is updated with regard
    to this parameter change.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@mandriva.com>
---
 net/dccp/ccid.h        |   12 +++----
 net/dccp/ccids/ccid2.c |    5 +--
 net/dccp/ccids/ccid3.c |   83 ++++++++++++++++++++++--------------------------
 net/dccp/output.c      |    6 +--
 4 files changed, 48 insertions(+), 58 deletions(-)

diff --git a/net/dccp/ccid.h b/net/dccp/ccid.h
index f7eb6c6..c7c2951 100644
--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -52,9 +52,9 @@ struct ccid_operations {
 						    unsigned char len, u16 idx,
 						    unsigned char* value);
 	int		(*ccid_hc_tx_send_packet)(struct sock *sk,
-						  struct sk_buff *skb, int len);
-	void		(*ccid_hc_tx_packet_sent)(struct sock *sk, int more,
-						  int len);
+						  struct sk_buff *skb);
+	void		(*ccid_hc_tx_packet_sent)(struct sock *sk,
+						  int more, unsigned int len);
 	void		(*ccid_hc_rx_get_info)(struct sock *sk,
 					       struct tcp_info *info);
 	void		(*ccid_hc_tx_get_info)(struct sock *sk,
@@ -94,16 +94,16 @@ extern void ccid_hc_rx_delete(struct cci
 extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
 static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
-					 struct sk_buff *skb, int len)
+					 struct sk_buff *skb)
 {
 	int rc = 0;
 	if (ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
-		rc = ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb, len);
+		rc = ccid->ccid_ops->ccid_hc_tx_send_packet(sk, skb);
 	return rc;
 }
 
 static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
-					  int more, int len)
+					  int more, unsigned int len)
 {
 	if (ccid->ccid_ops->ccid_hc_tx_packet_sent != NULL)
 		ccid->ccid_ops->ccid_hc_tx_packet_sent(sk, more, len);
diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index 207f7f9..2555be8 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -125,8 +125,7 @@ static int ccid2_hc_tx_alloc_seq(struct 
 	return 0;
 }
 
-static int ccid2_hc_tx_send_packet(struct sock *sk,
-				   struct sk_buff *skb, int len)
+static int ccid2_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct ccid2_hc_tx_sock *hctx;
 
@@ -268,7 +267,7 @@ static void ccid2_start_rto_timer(struct
 		       jiffies + hctx->ccid2hctx_rto);
 }
 
-static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, int len)
+static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index aa5440e..70ebe70 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -272,8 +272,7 @@ out:
  *   = 0: can send immediately
  *   < 0: error condition; do not send packet
  */
-static int ccid3_hc_tx_send_packet(struct sock *sk,
-				   struct sk_buff *skb, int len)
+static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
@@ -288,7 +287,7 @@ static int ccid3_hc_tx_send_packet(struc
 	 * zero-sized Data(Ack)s is theoretically possible, but for congestion
 	 * control this case is pathological - ignore it.
 	 */
-	if (unlikely(len = 0))
+	if (unlikely(skb->len = 0))
 		return -EBADMSG;
 
 	/* See if last packet allocated was not sent */
@@ -317,7 +316,7 @@ static int ccid3_hc_tx_send_packet(struc
 		ccid3_hc_tx_set_state(sk, TFRC_SSTATE_NO_FBACK);
 
 		/* Set initial sending rate to 1 packet per second */
-		ccid3_hc_tx_update_s(hctx, len);
+		ccid3_hc_tx_update_s(hctx, skb->len);
 		hctx->ccid3hctx_x     = hctx->ccid3hctx_s;
 
 		/* First timeout, according to [RFC 3448, 4.2], is 1 second */
@@ -356,59 +355,53 @@ static int ccid3_hc_tx_send_packet(struc
 	return 0;
 }
 
-static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, int len)
+static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, unsigned int len)
 {
 	const struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct timeval now;
+	unsigned long quarter_rtt;
+	struct dccp_tx_hist_entry *packet;
 
 	BUG_ON(hctx = NULL);
 
 	dccp_timestamp(sk, &now);
 
-	/* check if we have sent a data packet */
-	if (len > 0) {
-		unsigned long quarter_rtt;
-		struct dccp_tx_hist_entry *packet;
+	ccid3_hc_tx_update_s(hctx, len);
 
-		ccid3_hc_tx_update_s(hctx, len);
+	packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
+	if (unlikely(packet = NULL)) {
+		DCCP_WARN("packet doesn't exist in history!\n");
+		return;
+	}
+	if (unlikely(packet->dccphtx_sent)) {
+		DCCP_WARN("no unsent packet in history!\n");
+		return;
+	}
+	packet->dccphtx_tstamp = now;
+	packet->dccphtx_seqno  = dp->dccps_gss;
+	/*
+	 * Check if win_count have changed
+	 * Algorithm in "8.1. Window Counter Value" in RFC 4342.
+	 */
+	quarter_rtt = timeval_delta(&now, &hctx->ccid3hctx_t_last_win_count);
+	if (likely(hctx->ccid3hctx_rtt > 8))
+		quarter_rtt /= hctx->ccid3hctx_rtt / 4;
 
-		packet = dccp_tx_hist_head(&hctx->ccid3hctx_hist);
-		if (unlikely(packet = NULL)) {
-			DCCP_WARN("packet doesn't exist in history!\n");
-			return;
-		}
-		if (unlikely(packet->dccphtx_sent)) {
-			DCCP_WARN("no unsent packet in history!\n");
-			return;
-		}
-		packet->dccphtx_tstamp = now;
-		packet->dccphtx_seqno  = dp->dccps_gss;
-		/*
-		 * Check if win_count have changed
-		 * Algorithm in "8.1. Window Counter Value" in RFC 4342.
-		 */
-		quarter_rtt = timeval_delta(&now, &hctx->ccid3hctx_t_last_win_count);
-		if (likely(hctx->ccid3hctx_rtt > 8))
-			quarter_rtt /= hctx->ccid3hctx_rtt / 4;
-
-		if (quarter_rtt > 0) {
-			hctx->ccid3hctx_t_last_win_count = now;
-			hctx->ccid3hctx_last_win_count	 = (hctx->ccid3hctx_last_win_count +
-							    min_t(unsigned long, quarter_rtt, 5)) % 16;
-			ccid3_pr_debug("%s, sk=%p, window changed from "
-				       "%u to %u!\n",
-				       dccp_role(sk), sk,
-				       packet->dccphtx_ccval,
-				       hctx->ccid3hctx_last_win_count);
-		}
+	if (quarter_rtt > 0) {
+		hctx->ccid3hctx_t_last_win_count = now;
+		hctx->ccid3hctx_last_win_count	 = (hctx->ccid3hctx_last_win_count +
+						    min_t(unsigned long, quarter_rtt, 5)) % 16;
+		ccid3_pr_debug("%s, sk=%p, window changed from "
+			       "%u to %u!\n",
+			       dccp_role(sk), sk,
+			       packet->dccphtx_ccval,
+			       hctx->ccid3hctx_last_win_count);
+	}
 
-		hctx->ccid3hctx_idle = 0;
-		packet->dccphtx_rtt  = hctx->ccid3hctx_rtt;
-		packet->dccphtx_sent = 1;
-	} else
-		ccid3_pr_debug("%s, sk=%p, seqno=%llu NOT inserted!\n",
-			       dccp_role(sk), sk, dp->dccps_gss);
+	hctx->ccid3hctx_idle = 0;
+	packet->dccphtx_rtt  = hctx->ccid3hctx_rtt;
+	packet->dccphtx_sent = 1;
 }
 
 static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
diff --git a/net/dccp/output.c b/net/dccp/output.c
index bfd9c57..400c30b 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -195,8 +195,7 @@ static int dccp_wait_for_ccid(struct soc
 		if (signal_pending(current))
 			goto do_interrupted;
 
-		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
-					    skb->len);
+		rc = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 		if (rc <= 0)
 			break;
 		delay = msecs_to_jiffies(rc);
@@ -245,8 +244,7 @@ void dccp_write_xmit(struct sock *sk, in
 					   this we have other issues */
 
 	while ((skb = skb_peek(&sk->sk_write_queue))) {
-		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb,
-					 skb->len);
+		int err = ccid_hc_tx_send_packet(dp->dccps_hc_tx_ccid, sk, skb);
 
 		if (err > 0) {
 			if (!block) {
-- 
1.4.2.1.g3d5c

