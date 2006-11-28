From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 28 Nov 2006 14:35:05 +0000
Subject: [PATCH 2/2]: Use `unsigned' for packet lengths
Message-Id: <200611281435.05466@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[DCCP]: Use `unsigned' for packet lengths

This patch implements a suggestion by Ian McDonald and

 1) avoids tests against negative packet lengths by using unsigned (u32)  
    for packet payload lengths in the CCID send_packet()/packet_sent() routines

 2) removes an now unnecessary test with regard to `len > 0': 
    this condition is always true, since
      * negative packet lengths are avoided
      * ccid3_hc_tx_send_packet flags an error whenever the payload length is 0.
        As a consequence, ccid3_hc_tx_packet_sent is never called as all errors
        returned by ccid_hc_tx_send_packet are caught in dccp_write_xmit

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>       
---
 net/dccp/ccid.h        |    8 ++---
 net/dccp/ccids/ccid2.c |    4 +-
 net/dccp/ccids/ccid3.c |   78 ++++++++++++++++++++++---------------------------
 3 files changed, 42 insertions(+), 48 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -52,9 +52,9 @@ struct ccid_operations {
 						    unsigned char len, u16 idx,
 						    unsigned char* value);
 	int		(*ccid_hc_tx_send_packet)(struct sock *sk,
-						  struct sk_buff *skb, int len);
+						  struct sk_buff *skb, u32 len);
 	void		(*ccid_hc_tx_packet_sent)(struct sock *sk, int more,
-						  int len);
+						  u32 len);
 	void		(*ccid_hc_rx_get_info)(struct sock *sk,
 					       struct tcp_info *info);
 	void		(*ccid_hc_tx_get_info)(struct sock *sk,
@@ -94,7 +94,7 @@ extern void ccid_hc_rx_delete(struct cci
 extern void ccid_hc_tx_delete(struct ccid *ccid, struct sock *sk);
 
 static inline int ccid_hc_tx_send_packet(struct ccid *ccid, struct sock *sk,
-					 struct sk_buff *skb, int len)
+					 struct sk_buff *skb, u32 len)
 {
 	int rc = 0;
 	if (ccid->ccid_ops->ccid_hc_tx_send_packet != NULL)
@@ -103,7 +103,7 @@ static inline int ccid_hc_tx_send_packet
 }
 
 static inline void ccid_hc_tx_packet_sent(struct ccid *ccid, struct sock *sk,
-					  int more, int len)
+					  int more, u32 len)
 {
 	if (ccid->ccid_ops->ccid_hc_tx_packet_sent != NULL)
 		ccid->ccid_ops->ccid_hc_tx_packet_sent(sk, more, len);
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -126,7 +126,7 @@ static int ccid2_hc_tx_alloc_seq(struct 
 }
 
 static int ccid2_hc_tx_send_packet(struct sock *sk,
-				   struct sk_buff *skb, int len)
+				   struct sk_buff *skb, u32 len)
 {
 	struct ccid2_hc_tx_sock *hctx;
 
@@ -268,7 +268,7 @@ static void ccid2_start_rto_timer(struct
 		       jiffies + hctx->ccid2hctx_rto);
 }
 
-static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, int len)
+static void ccid2_hc_tx_packet_sent(struct sock *sk, int more, u32 len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid2_hc_tx_sock *hctx = ccid2_hc_tx_sk(sk);
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -275,7 +275,7 @@ out:
  *   < 0: error condition; do not send packet
  */
 static int ccid3_hc_tx_send_packet(struct sock *sk,
-				   struct sk_buff *skb, int len)
+				   struct sk_buff *skb, u32 len)
 {
 	struct dccp_sock *dp = dccp_sk(sk);
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
@@ -358,59 +358,53 @@ static int ccid3_hc_tx_send_packet(struc
 	return 0;
 }
 
-static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, int len)
+static void ccid3_hc_tx_packet_sent(struct sock *sk, int more, u32 len)
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
