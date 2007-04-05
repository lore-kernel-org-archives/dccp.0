From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 05 Apr 2007 15:33:18 +0000
Subject: [PATCH 3/43]: Use a function to update p_inv, and p is never used
Message-Id: <200704051633.19008@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

[CCID 3]: Use a function to update p_inv, and p is never used

This
 1) concentrates previously scattered computation of p_inv into one function;
 2) removes the `p' element of the CCID3 RX sock (it is redundant);
 3) makes the tfrc_rx_info structure standalone, only used on demand.

The reason for (2) is that the code essentially only uses p_inv = 1/p. It does not
need p, since all the relevant information is already in p_inv.
The motivation for (3) is that the embedded info structure will not be used often,
so that the extra cost of keeping p in synch with p_inv (which has to be done at
each packet reception) is overhead most of the time.

Advantages that this buys:
--------------------------
 * the RX sock loses further weight;
 * computation of p_inv is no longer scattered in different places;
 * not having to keep p in sync with p_inv speeds up computation
   (important, as p_inv has to be recomputed for each new data packet);
 * several test cases can now be removed since all is in one function;
 * the send_feedback and packet_recv code becomes simpler.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 net/dccp/ccids/ccid3.c |   57 +++++++++++++++++++++++++------------------------
 net/dccp/ccids/ccid3.h |   19 ++++++----------
 2 files changed, 38 insertions(+), 38 deletions(-)

--- a/net/dccp/ccids/ccid3.c
+++ b/net/dccp/ccids/ccid3.c
@@ -726,6 +726,25 @@ static inline void ccid3_hc_rx_update_s(
 		TFRC_EWMA(hcrx->ccid3hcrx_s, len, 9);
 }
 
+/* returns: 1 when p > p_prev (i.e. when feedback is required); 0 else */
+static int ccid3_hc_rx_update_p(struct ccid3_hc_rx_sock *hcrx)
+{
+	struct list_head *li_hist = &hcrx->ccid3hcrx_li_hist;
+	u32 pinv_prev = hcrx->ccid3hcrx_pinv;
+
+	if (list_empty(li_hist)) /* only empty if no loss so far, i.e. p = 0 */
+		return 0;
+
+	hcrx->ccid3hcrx_pinv = dccp_li_hist_calc_i_mean(li_hist);
+	if (hcrx->ccid3hcrx_pinv = 0) {
+		DCCP_BUG("non-empty LI history and yet I_mean = 0!");
+		return 0;
+	}
+
+	/* exploit that  p > p_prev  <=>  1/p < 1/p_prev  */
+	return (hcrx->ccid3hcrx_pinv < pinv_prev);
+}
+
 static void ccid3_hc_rx_send_feedback(struct sock *sk)
 {
 	struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
@@ -741,6 +760,7 @@ static void ccid3_hc_rx_send_feedback(st
 	switch (hcrx->ccid3hcrx_state) {
 	case TFRC_RSTATE_NO_DATA:
 		hcrx->ccid3hcrx_x_recv = 0;
+		hcrx->ccid3hcrx_pinv   = ~0U;	/* see RFC 4342, 8.5 */
 		break;
 	case TFRC_RSTATE_DATA:
 		delta = timeval_delta(&now,
@@ -770,14 +790,6 @@ static void ccid3_hc_rx_send_feedback(st
 	DCCP_BUG_ON(delta < 0);
 	hcrx->ccid3hcrx_elapsed_time = delta / 10;
 
-	if (hcrx->ccid3hcrx_p = 0)
-		hcrx->ccid3hcrx_pinv = ~0U;	/* see RFC 4342, 8.5 */
-	else if (hcrx->ccid3hcrx_p > 1000000) {
-		DCCP_WARN("p (%u) > 100%%\n", hcrx->ccid3hcrx_p);
-		hcrx->ccid3hcrx_pinv = 1;	/* use 100% in this case */
-	} else
-		hcrx->ccid3hcrx_pinv = 1000000 / hcrx->ccid3hcrx_p;
-
 	dp->dccps_hc_rx_insert_options = 1;
 	dccp_send_ack(sk);
 }
@@ -1016,7 +1028,7 @@ static void ccid3_hc_rx_packet_recv(stru
 	const struct dccp_options_received *opt_recv;
 	struct dccp_rx_hist_entry *packet;
 	struct timeval now;
-	u32 p_prev, r_sample, rtt_prev;
+	u32 r_sample, rtt_prev;
 	int loss, payload_size;
 
 	BUG_ON(hcrx = NULL);
@@ -1096,22 +1108,8 @@ static void ccid3_hc_rx_packet_recv(stru
 	ccid3_pr_debug("%s(%p, state=%s), data loss! Reacting...\n",
 		       dccp_role(sk), sk, dccp_state_name(sk->sk_state));
 
-	p_prev = hcrx->ccid3hcrx_p;
-
-	/* Calculate loss event rate */
-	if (!list_empty(&hcrx->ccid3hcrx_li_hist)) {
-		u32 i_mean = dccp_li_hist_calc_i_mean(&hcrx->ccid3hcrx_li_hist);
-
-		/* Scaling up by 1000000 as fixed decimal */
-		if (i_mean != 0)
-			hcrx->ccid3hcrx_p = 1000000 / i_mean;
-	} else
-		DCCP_BUG("empty loss history");
-
-	if (hcrx->ccid3hcrx_p > p_prev) {
+	if (ccid3_hc_rx_update_p(hcrx))
 		ccid3_hc_rx_send_feedback(sk);
-		return;
-	}
 }
 
 static int ccid3_hc_rx_init(struct ccid *ccid, struct sock *sk)
@@ -1165,6 +1163,11 @@ static int ccid3_hc_rx_getsockopt(struct
 {
 	const struct ccid3_hc_rx_sock *hcrx = ccid3_hc_rx_sk(sk);
 	const void *val;
+	struct tfrc_rx_info rx_info = {
+		.tfrcrx_x_recv	= hcrx->ccid3hcrx_x_recv,
+		.tfrcrx_rtt	= hcrx->ccid3hcrx_rtt,
+		.tfrcrx_p	= scaled_div(1, hcrx->ccid3hcrx_pinv)
+	};
 
 	/* Listen socks doesn't have a private CCID block */
 	if (sk->sk_state = DCCP_LISTEN)
@@ -1172,10 +1175,10 @@ static int ccid3_hc_rx_getsockopt(struct
 
 	switch (optname) {
 	case DCCP_SOCKOPT_CCID_RX_INFO:
-		if (len < sizeof(hcrx->ccid3hcrx_tfrc))
+		if (len < sizeof(rx_info))
 			return -EINVAL;
-		len = sizeof(hcrx->ccid3hcrx_tfrc);
-		val = &hcrx->ccid3hcrx_tfrc;
+		len = sizeof(rx_info);
+		val = &rx_info;
 		break;
 	default:
 		return -ENOPROTOOPT;
--- a/net/dccp/ccids/ccid3.h
+++ b/net/dccp/ccids/ccid3.h
@@ -127,38 +127,35 @@ enum ccid3_hc_rx_states {
 
 /** struct ccid3_hc_rx_sock - CCID3 receiver half-connection socket
  *
- *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448 4.3)
- *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
- *  @ccid3hcrx_p  -  current loss event rate (RFC 3448 5.4)
  *  @ccid3hcrx_seqno_nonloss  -  Last received non-loss sequence number
  *  @ccid3hcrx_ccval_nonloss  -  Last received non-loss Window CCVal
  *  @ccid3hcrx_ccval_last_counter  -  Tracks window counter (RFC 4342, 8.1)
  *  @ccid3hcrx_state  -  receiver state, one of %ccid3_hc_rx_states
+ *  @ccid3hcrx_s  -  Received packet size in bytes
  *  @ccid3hcrx_bytes_recv  -  Total sum of DCCP payload bytes
+ *  @ccid3hcrx_x_recv  -  Receiver estimate of send rate (RFC 3448, sec. 4.3)
+ *  @ccid3hcrx_rtt  -  Receiver estimate of rtt (non-standard)
+ *  @ccid3hcrx_pinv  -  Reciprocal of Loss Event Rate p (RFC 4342, sec. 8.5)
  *  @ccid3hcrx_tstamp_last_feedback  -  Time at which last feedback was sent
  *  @ccid3hcrx_tstamp_last_ack  -  Time at which last feedback was sent
  *  @ccid3hcrx_hist  -  Packet history
  *  @ccid3hcrx_li_hist  -  Loss Interval History
- *  @ccid3hcrx_s  -  Received packet size in bytes
- *  @ccid3hcrx_pinv  -  Inverse of Loss Event Rate (RFC 4342, sec. 8.5)
  *  @ccid3hcrx_elapsed_time  -  Time since packet reception
  */
 struct ccid3_hc_rx_sock {
-	struct tfrc_rx_info		ccid3hcrx_tfrc;
-#define ccid3hcrx_x_recv		ccid3hcrx_tfrc.tfrcrx_x_recv
-#define ccid3hcrx_rtt			ccid3hcrx_tfrc.tfrcrx_rtt
-#define ccid3hcrx_p			ccid3hcrx_tfrc.tfrcrx_p
 	u64				ccid3hcrx_seqno_nonloss:48,
 					ccid3hcrx_ccval_nonloss:4,
 					ccid3hcrx_ccval_last_counter:4;
 	enum ccid3_hc_rx_states		ccid3hcrx_state:8;
+	u16				ccid3hcrx_s;
 	u32				ccid3hcrx_bytes_recv;
+	u32				ccid3hcrx_x_recv;
+	u32				ccid3hcrx_rtt;
+	u32				ccid3hcrx_pinv;
 	struct timeval			ccid3hcrx_tstamp_last_feedback;
 	struct timeval			ccid3hcrx_tstamp_last_ack;
 	struct list_head		ccid3hcrx_hist;
 	struct list_head		ccid3hcrx_li_hist;
-	u16				ccid3hcrx_s;
-	u32				ccid3hcrx_pinv;
 	u32				ccid3hcrx_elapsed_time;
 };
 
