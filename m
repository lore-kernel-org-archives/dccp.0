From: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
Date: Wed, 26 Sep 2007 18:39:30 +0000
Subject: [PATCH 2/8] [CCID3]: Move NULL-protection into function
Message-Id: <20070926183930.GD10932@ghostprotocols.net>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

This moves several instances of testing against NULL into the function which is
used to de-reference the CCID-private data.

Committer note: Made the BUG_ON depend on having CONFIG_IP_DCCP_CCID3_DEBUG, as it
                is too much to have this on production code. Also made sure that
                the macro is used only after checking if sk_state is not LISTEN,
                to make it equivalent to what we had before.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Signed-off-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
---
 net/dccp/ccids/ccid3.c |   35 ++++++++++-------------------------
 net/dccp/ccids/ccid3.h |   20 ++++++++++++++------
 2 files changed, 24 insertions(+), 31 deletions(-)

diff --git a/net/dccp/ccids/ccid3.c b/net/dccp/ccids/ccid3.c
index 0bb338b..a409939 100644
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -302,8 +302,6 @@ static int ccid3_hc_tx_send_packet(struct sock *sk, struct sk_buff *skb)
 	ktime_t now = ktime_get_real();
 	s64 delay;
 
-	BUG_ON(hctx = NULL);
-
 	/*
 	 * This function is called only for Data and DataAck packets. Sending
 	 * zero-sized Data(Ack)s is theoretically possible, but for congestion
@@ -383,8 +381,6 @@ static void ccid3_hc_tx_packet_sent(struct sock *sk, int more,
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct dccp_tx_hist_entry *packet;
 
-	BUG_ON(hctx = NULL);
-
 	ccid3_hc_tx_update_s(hctx, len);
 
 	packet = dccp_tx_hist_entry_new(ccid3_tx_hist, GFP_ATOMIC);
@@ -409,8 +405,6 @@ static void ccid3_hc_tx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	unsigned long t_nfb;
 	u32 pinv, r_sample;
 
-	BUG_ON(hctx = NULL);
-
 	/* we are only interested in ACKs */
 	if (!(DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_ACK ||
 	      DCCP_SKB_CB(skb)->dccpd_type = DCCP_PKT_DATAACK))
@@ -551,8 +545,6 @@ static int ccid3_hc_tx_parse_options(struct sock *sk, unsigned char option,
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 	struct ccid3_options_received *opt_recv;
 
-	BUG_ON(hctx = NULL);
-
 	opt_recv = &hctx->ccid3hctx_options_received;
 
 	if (opt_recv->ccid3or_seqno != dp->dccps_gsr) {
@@ -626,8 +618,6 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
 
-	BUG_ON(hctx = NULL);
-
 	ccid3_hc_tx_set_state(sk, TFRC_SSTATE_TERM);
 	sk_stop_timer(sk, &hctx->ccid3hctx_no_feedback_timer);
 
@@ -637,14 +627,13 @@ static void ccid3_hc_tx_exit(struct sock *sk)
 
 static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	struct ccid3_hc_tx_sock *hctx;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	BUG_ON(hctx = NULL);
-
+	hctx = ccid3_hc_tx_sk(sk);
 	info->tcpi_rto = hctx->ccid3hctx_t_rto;
 	info->tcpi_rtt = hctx->ccid3hctx_rtt;
 }
@@ -652,13 +641,14 @@ static void ccid3_hc_tx_get_info(struct sock *sk, struct tcp_info *info)
 static int ccid3_hc_tx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_tx_sock *hctx = ccid3_hc_tx_sk(sk);
+	const struct ccid3_hc_tx_sock *hctx;
 	const void *val;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return -EINVAL;
 
+	hctx = ccid3_hc_tx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_TX_INFO:
 		if (len < sizeof(hctx->ccid3hctx_tfrc))
@@ -772,14 +762,13 @@ static void ccid3_hc_rx_send_feedback(struct sock *sk)
 
 static int ccid3_hc_rx_insert_options(struct sock *sk, struct sk_buff *skb)
 {
-	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	const struct ccid3_hc_rx_sock *hcrx;
 	__be32 x_recv, pinv;
 
-	BUG_ON(hcrx = NULL);
-
 	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
 		return 0;
 
+	hcrx = ccid3_hc_rx_sk(sk);
 	DCCP_SKB_CB(skb)->dccpd_ccval = hcrx->ccid3hcrx_ccval_last_counter;
 
 	if (dccp_packet_without_ack(skb))
@@ -870,8 +859,6 @@ static void ccid3_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
 	int loss, payload_size;
 	ktime_t now;
 
-	BUG_ON(hcrx = NULL);
-
 	opt_recv = &dccp_sk(sk)->dccps_options_received;
 
 	switch (DCCP_SKB_CB(skb)->dccpd_type) {
@@ -985,8 +972,6 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 
-	BUG_ON(hcrx = NULL);
-
 	ccid3_hc_rx_set_state(sk, TFRC_RSTATE_TERM);
 
 	/* Empty packet history */
@@ -998,14 +983,13 @@ static void ccid3_hc_rx_exit(struct sock *sk)
 
 static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 {
-	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	const struct ccid3_hc_rx_sock *hcrx;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return;
 
-	BUG_ON(hcrx = NULL);
-
+	hcrx = ccid3_hc_rx_sk(sk);
 	info->tcpi_ca_state = hcrx->ccid3hcrx_state;
 	info->tcpi_options  |= TCPI_OPT_TIMESTAMPS;
 	info->tcpi_rcv_rtt  = hcrx->ccid3hcrx_rtt;
@@ -1014,13 +998,14 @@ static void ccid3_hc_rx_get_info(struct sock *sk, struct tcp_info *info)
 static int ccid3_hc_rx_getsockopt(struct sock *sk, const int optname, int len,
 				  u32 __user *optval, int __user *optlen)
 {
-	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
+	const struct ccid3_hc_rx_sock *hcrx;
 	const void *val;
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
 		return -EINVAL;
 
+	hcrx = ccid3_hc_rx_sk(sk);
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
 		if (len < sizeof(hcrx->ccid3hcrx_tfrc))
diff --git a/net/dccp/ccids/ccid3.h b/net/dccp/ccids/ccid3.h
index 7cbf2b1..ae99ec4 100644
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -117,6 +117,15 @@ struct ccid3_hc_tx_sock {
 	struct ccid3_options_received	ccid3hctx_options_received;
 };
 
+static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
+{
+    struct ccid3_hc_tx_sock *hctx = ccid_priv(dccp_sk(sk)->dccps_hc_tx_ccid);
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
+    BUG_ON(hctx = NULL);
+#endif
+    return hctx;
+}
+
 /* TFRC receiver states */
 enum ccid3_hc_rx_states {
 	TFRC_RSTATE_NO_DATA = 1,
@@ -161,14 +170,13 @@ struct ccid3_hc_rx_sock {
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
+    struct ccid3_hc_rx_sock *hcrx = ccid_priv(dccp_sk(sk)->dccps_hc_rx_ccid);
+#ifdef CONFIG_IP_DCCP_CCID3_DEBUG
+    BUG_ON(hcrx = NULL);
+#endif
+    return hcrx;
 }
 
 #endif /* _DCCP_CCID3_H_ */
-- 
1.5.2.2

