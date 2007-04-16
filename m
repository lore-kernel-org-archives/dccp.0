From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 16 Apr 2007 19:45:50 +0000
Subject: [PATCH 1/1]: Fix bug in computing elapsed time
Message-Id: <200704162045.50770@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID3]: Fix bug in computing elapsed time

This patch does the following:
 (a) modify existing patch set to dispense with interface
     timestamps (which were used to measure elapsed time,
     but did not find maintainer approval);
 (b) fix a bug in computing the elapsed time.

While (a) restores the original state of the CCID3 module with
regard to taking timestamps, (b) fixes a previously undiscovered bug:

 * the receive timestamp is taken when the skb enters the CCID3 module;
 * RFC 4342 requires to send an Elapsed Time estimate to the sender;
 * the bug is in computing the elapsed time as the time between `receiving'
   the packet (i.e. skb enters CCID module) and sending feedback,
     --> there is no layer-processing, queueing, or delay involved,
     --> hence the elapsed time is in the order of 1 function call
     --> this is in the dimension of 50 ... 100 usec
     --> which renders the use of elapsed time almost entirely useless.

The solution taken to fix (b) is in re-considering RFC 3448 in combination with
the requirements of RFC 4342:
 * RFC 3448, 3.2.1 requires the TFRC/CCID3 sender to provide timestamps;
 * RFC 4342, p. 10 makes it optional for the receiver to send either an Elapsed
   Time option (useless as per above), and/or a Timestamp Echo option;
 * the latter is automatically triggered in the DCCP module, since 
    - any received timestamp sets dccps_timestamp_echo and dccps_timestamp_time;
    - CCID3 feedback is sent via dccp_send_ack
    - dccp_send_ack sees that dccps_timestamp_echo is non-0 and calls 
      dccp_insert_option_timestamp_echo(), which supplies a timestamp echo option.

=> The result is a much more precise estimation of processing time, the problem
    of a useless time difference of 50...100usec disappears, as does the processing
    overhead to produce the negligible Elapsed Time estimate.

    As a further advantage, the now useless elapsed_time field can be removed from
    the socket, which slims the socket structure down by another full four bytes.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>    
---
 net/dccp/ccid.h        |   10 ++++++++++
 net/dccp/ccids/ccid3.c |   31 ++++++++++++++++++++-----------
 net/dccp/ccids/ccid3.h |    2 --
 net/dccp/options.c     |    6 ++++++
 4 files changed, 36 insertions(+), 13 deletions(-)

--- a/net/dccp/ccid.h
+++ b/net/dccp/ccid.h
@@ -43,6 +43,8 @@ struct ccid_operations {
 						    unsigned char* value);
 	int		(*ccid_hc_rx_insert_options)(struct sock *sk,
 						     struct sk_buff *skb);
+	int		(*ccid_hc_tx_insert_options)(struct sock *sk,
+						     struct sk_buff *skb);
 	void		(*ccid_hc_tx_packet_recv)(struct sock *sk,
 						  struct sk_buff *skb);
 	int		(*ccid_hc_tx_parse_options)(struct sock *sk,
@@ -152,6 +154,14 @@ static inline int ccid_hc_rx_insert_opti
 	return 0;
 }
 
+static inline int ccid_hc_tx_insert_options(struct ccid *ccid, struct sock *sk,
+					    struct sk_buff *skb)
+{
+	if (ccid->ccid_ops->ccid_hc_tx_insert_options != NULL)
+		return ccid->ccid_ops->ccid_hc_tx_insert_options(sk, skb);
+	return 0;
+}
+
 static inline void ccid_hc_rx_get_info(struct ccid *ccid, struct sock *sk,
 				       struct tcp_info *info)
 {
--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -615,6 +615,23 @@ static int ccid3_hc_tx_parse_options(str
 	return rc;
 }
 
+static int ccid3_hc_tx_insert_options(struct sock *sk, struct sk_buff *skb)
+{
+	if (!(sk->sk_state = DCCP_OPEN || sk->sk_state = DCCP_PARTOPEN))
+		return 0;
+
+	/*
+	 * Timestamp as required by RFC 3448, 3.2.1
+	 * The receiver will reply with a Timestamp Echo option (RFC 4340, 13.1)
+	 * so that RFC 4340, 6. is also satisfied. In addition, we get a much
+	 * better estimate of the receiver processing time: since receive time-
+	 * stamps are taken in the CCID3 module, the elapsed time never amounts
+	 * to more than mere function processing time - which is negligible in
+	 * comparison to genuine layer-processing delays.
+	 */
+	return dccp_insert_option_timestamp(sk, skb);
+}
+
 static int ccid3_hc_tx_init(struct ccid *ccid, struct sock *sk)
 {
 	struct ccid3_hc_tx_sock *hctx = ccid_priv(ccid);
@@ -747,7 +764,7 @@ static void ccid3_hc_rx_send_feedback(st
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	struct dccp_sock *dp = dccp_sk(sk);
-	struct timeval now, t_recv;
+	struct timeval now;
 	suseconds_t delta = 0;
 
 	dccp_timestamp(sk, &now);
@@ -771,12 +788,6 @@ static void ccid3_hc_rx_send_feedback(st
 	ccid3_pr_debug("Interval %ldusec, X_recv=%u, 1/p=%u\n", (long)delta,
 		       hcrx->ccid3hcrx_x_recv, hcrx->ccid3hcrx_pinv);
 
-	/* Elapsed time information [RFC 4340, 13.2] in units of 10 * usecs */
-	skb_get_timestamp(skb, &t_recv);
-	delta = timeval_delta(&now, &t_recv);
-	DCCP_BUG_ON(delta < 0);
-
-	hcrx->ccid3hcrx_elapsed_time	     = delta / 10;
 	hcrx->ccid3hcrx_tstamp_last_feedback = now;
 	hcrx->ccid3hcrx_ccval_last_counter   = dccp_hdr(skb)->dccph_ccval;
 	hcrx->ccid3hcrx_bytes_recv	     = 0;
@@ -801,10 +812,7 @@ static int ccid3_hc_rx_insert_options(st
 	x_recv = htonl(hcrx->ccid3hcrx_x_recv);
 	pinv   = htonl(hcrx->ccid3hcrx_pinv);
 
-	if ((hcrx->ccid3hcrx_elapsed_time != 0 &&
-	     dccp_insert_option_elapsed_time(sk, skb,
-					     hcrx->ccid3hcrx_elapsed_time)) ||
-	    dccp_insert_option_timestamp(sk, skb) ||
+	if (dccp_insert_option_timestamp(sk, skb) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_LOSS_EVENT_RATE,
 			       &pinv, sizeof(pinv)) ||
 	    dccp_insert_option(sk, skb, TFRC_OPT_RECEIVE_RATE,
@@ -1192,6 +1200,7 @@ static struct ccid_operations ccid3 = {
 	.ccid_hc_tx_packet_sent	   = ccid3_hc_tx_packet_sent,
 	.ccid_hc_tx_packet_recv	   = ccid3_hc_tx_packet_recv,
 	.ccid_hc_tx_parse_options  = ccid3_hc_tx_parse_options,
+	.ccid_hc_tx_insert_options = ccid3_hc_tx_insert_options,
 	.ccid_hc_rx_obj_size	   = sizeof(struct ccid3_hc_rx_sock),
 	.ccid_hc_rx_init	   = ccid3_hc_rx_init,
 	.ccid_hc_rx_exit	   = ccid3_hc_rx_exit,
--- a/net/dccp/options.c
+++ b/net/dccp/options.c
@@ -564,6 +564,12 @@ int dccp_insert_options(struct sock *sk,
 			return -1;
 	}
 
+	if (dp->dccps_hc_tx_insert_options) {
+		if (ccid_hc_tx_insert_options(dp->dccps_hc_tx_ccid, sk, skb))
+			return -1;
+		dp->dccps_hc_tx_insert_options = 0;
+	}
+
 	if (dp->dccps_hc_rx_insert_options) {
 		if (ccid_hc_rx_insert_options(dp->dccps_hc_rx_ccid, sk, skb))
 			return -1;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -140,7 +140,6 @@ enum ccid3_hc_rx_states {
  *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history
  *  @ccid3hcrx_li_hist  -  Loss Interval History
- *  @ccid3hcrx_elapsed_time  -  Time since packet reception
  */
 struct ccid3_hc_rx_sock {
 	u64				ccid3hcrx_seqno_nonloss:48,
@@ -156,7 +155,6 @@ struct ccid3_hc_rx_sock {
 	struct timeval			ccid3hcrx_tstamp_last_ack;
 	struct list_head		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
-	u32				ccid3hcrx_elapsed_time;
 };
 
 static inline struct ccid3_hc_tx_sock *ccid3_hc_tx_sk(const struct sock *sk)
