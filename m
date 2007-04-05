From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:35:49 +0000
Subject: [PATCH 26/43]: Move NULL-protection into function
Message-Id: <200704051635.49337@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Move NULL-protection into function

This moves 10 instances of testing against NULL into the function which is
used to de-reference the CCID-private data.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   20 --------------------
 net/dccp/ccids/ccid3.h |   18 ++++++++++++------
 2 files changed, 12 insertions(+), 26 deletions(-)

--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -119,6 +119,14 @@ struct ccid3_hc_tx_sock {
 	struct ccid3_options_received	ccid3hctx_options_received;
 };
 
+static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
+{
+	void *ccid3_tx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
+
+	BUG_ON(ccid3_tx_priv = NULL);
+	return ccid3_tx_priv;
+}
+
 /* TFRC receiver states */
 enum ccid3_hc_rx_states {
 	TFRC_RSTATE_NO_DATA = 1,
@@ -154,14 +162,12 @@ struct ccid3_hc_rx_sock {
 	u32				ccid3hcrx_elapsed_time;
 };
 
-static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
-{
-    return ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
-}
-
 static inline struct ccid3_hc_rx_sock *ccid3_hc_rx_sk(const struct sock *sk)
 {
-    return ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+	void *ccid3_rx_priv = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+
+	BUG_ON(ccid3_rx_priv = NULL);
+	return ccid3_rx_priv;
 }
 
 #endif /* _DCCP_CCID3_H_ */
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -302,8 +302,6 @@ static int ccid3_hc_tx_send_packet(struc
 	struct timeval now;
 	suseconds_t delay;
 
-	BUG_ON(hctx = NULL);
-
 	/*
 	 * This function is called only for Data and DataAck packets. Sending
 	 * zero-sized Data(Ack)s is theoretically possible, but for congestion
@@ -394,8 +392,6 @@ static void ccid3_hc_tx_packet_sent(stru
 	struct timeval now;
 	struct dccp_tx_hist_entry *packet;
 
-	BUG_ON(hctx = NULL);
-
 	ccid3_hc_tx_update_s(hctx, len);
 
 	packet = dccp_tx_hist_entry_new(ccid3_tx_hist, GFP_ATOMIC);
@@ -418,8 +414,6 @@ static void ccid3_hc_tx_packet_recv(stru
 	unsigned long t_nfb;
 	u32 pinv, r_sample, rc;
 
-	BUG_ON(hctx = NULL);
-
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
@@ -556,8 +550,6 @@ static int ccid3_hc_tx_parse_options(str
 	struct ccid3_options_received *opt_recv;
 	u32 opt_val;
 
-	BUG_ON(hctx = NULL);
-
 	opt_recv = &hctx->ccid3hctx_options_received;
 
 	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
@@ -633,8 +625,6 @@ static void ccid3_hc_tx_exit(struct sock
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
-	BUG_ON(hctx = NULL);
-
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 	net_disable_timestamp();
@@ -651,8 +641,6 @@ static void ccid3_hc_tx_get_info(struct 
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	BUG_ON(hctx = NULL);
-
 	info->tcpi_rto = hctx->ccid3hctx_t_rto;
 	info->tcpi_rtt = hctx->ccid3hctx_rtt;
 }
@@ -769,8 +757,6 @@ static int ccid3_hc_rx_insert_options(st
 	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	__be32 x_recv, pinv;
 
-	BUG_ON(hcrx = NULL);
-
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
@@ -845,8 +831,6 @@ static void ccid3_hc_rx_packet_recv(stru
 	    payload_size = skb->len - dccp_hdr(skb)->dccph_doff * 4;
 	u8  is_data_packet = dccp_data_packet(skb), do_feedback = 0;
 
-	BUG_ON(hcrx = NULL);
-
 	spin_lock(&hcrx->ccid3hcrx_hist.lock);
 
 	if (unlikely(hcrx->ccid3hcrx_state = TFRC_RSTATE_NO_DATA)) {
@@ -937,8 +921,6 @@ static void ccid3_hc_rx_exit(struct sock
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 
-	BUG_ON(hcrx = NULL);
-
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	tfrc_rx_hist_cleanup(&hcrx->ccid3hcrx_hist);
@@ -953,8 +935,6 @@ static void ccid3_hc_rx_get_info(struct 
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	BUG_ON(hcrx = NULL);
-
 	info->tcpi_ca_state = hcrx->ccid3hcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
 	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
